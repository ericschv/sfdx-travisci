import { LightningElement, api, track, wire } from "lwc"
import { getObjectInfo } from "lightning/uiObjectInfoApi"
import { updateRecord } from "lightning/uiRecordApi"

import groupQuoteCoveragesByCarrierAndPolicy from "@salesforce/apex/QuoteCoverages.groupQuoteCoveragesByCarrierAndPolicy"
import groupQuoteCoveragesByPreviousPolicy from "@salesforce/apex/QuoteCoverages.groupQuoteCoveragesByPreviousPolicy"
import createPolicyWithCoverages from "@salesforce/apex/Policies.createPolicyWithCoverages"
import findExistingPolicies from "@salesforce/apex/Policies.findExistingPolicies"
import getCarrierProducts from "@salesforce/apex/CarrierProducts.getCarrierProducts"
import setRenewingPoliciesStatusByQuoteId from "@salesforce/apex/Policies.setRenewingPoliciesStatusByQuoteId"

import POLICY_OBJECT from "@salesforce/schema/CanaryAMS__Policy__c"
import POLICY_NUMBER from "@salesforce/schema/CanaryAMS__Policy__c.CanaryAMS__Policy_Number__c"
import QUOTE_ID from "@salesforce/schema/CanaryAMS__Insurance_Product__c.Id"
import QUOTE_STATUS from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Stage__c"

import { debug, customEvent, toastEvent, sortBy } from "c/shared"
import { validateQuote, validateGroupedPolicies } from "./validation"
import {
  toGroupedPolicies,
  updatePolicyPremiumAndFees,
  setDefaultPolicyNumber,
  setDefaultRecordType,
  mergeFetchedPoliciesToGroupedPolicies,
} from "./utils"

export default class UserFriendlyPolicyCreation extends LightningElement {
  rawPolicies = []

  @track groupedPolicies = []
  @track carrierProducts = []
  @track recordTypes = []
  @track loading = false
  @track currentDraggedCoverage
  @track errors = []
  @track showErrors = false

  @api recordId
  @api isQuoteClosed

  _quote

  @api
  get quote() {
    return this._quote
  }
  set quote(quote) {
    this._quote = quote
    if (this.showErrors) {
      const quoteErrors = validateQuote(this.quote)
      // NOTE: dispatch errors event to Bind Policy parent component
      this.dispatchEvent(customEvent("validationerror", quoteErrors))
    }

    if (quote.id && quote.quoteType) {
      if (!this.areCoveragesLoaded) {
        this.loadInitialGroupedPolicies(quote.id, quote.quoteType)
          .then(() => (this.areCoveragesLoaded = true))
          .catch((error) =>
            debug("Failed to load initial grouped policies:", error),
          )
      } else {
        this.handleRefresh().catch((error) =>
          debug(
            "Failed to refresh grouped policies after initial load:",
            error,
          ),
        )
      }
    }
  }

  @wire(getCarrierProducts)
  wiredGetCarrierProducts({ error, data }) {
    if (data) {
      const carrierProducts = data.map(
        ({ Id, Name, CanaryAMS__Carrier__c }) => ({
          id: Id,
          name: Name,
          carrierId: CanaryAMS__Carrier__c,
        }),
      )

      this.carrierProducts = sortBy(carrierProducts, "name")
    }
  }

  @wire(getObjectInfo, { objectApiName: POLICY_OBJECT })
  wiredGetPolicyObjectInfo({ error, data }) {
    if (data && data.recordTypeInfos) {
      const recordTypes = Object.values(data.recordTypeInfos)
        .filter((recordType) => recordType.available)
        .reduce((recordTypes, { recordTypeId, name }) => {
          return [
            ...recordTypes,
            {
              id: recordTypeId,
              name,
            },
          ]
        }, [])

      this.recordTypes = sortBy(recordTypes, "name")

      if (this.groupedPolicies.length > 0) {
        this.groupedPolicies = setDefaultRecordType(
          this.groupedPolicies,
          recordTypes,
        )
      }
    }
  }

  async loadInitialGroupedPolicies(quoteId, quoteType) {
    let rawPolicies

    if (quoteType === "Renewal") {
      try {
        rawPolicies = await groupQuoteCoveragesByPreviousPolicy({
          quoteId: quoteId,
        })
      } catch (error) {
        debug("Failed to get coverages grouped by previous policy:", error)
      }
    } else {
      try {
        rawPolicies = await groupQuoteCoveragesByCarrierAndPolicy({
          quoteId: quoteId,
        })
      } catch (error) {
        debug("Failed to get coverages grouped by carrier and policy:", error)
      }
    }

    if (rawPolicies) {
      this.rawPolicies = rawPolicies

      let groupedPolicies = toGroupedPolicies(rawPolicies)

      groupedPolicies = setDefaultPolicyNumber(groupedPolicies)

      if (this.recordTypes.length > 0) {
        groupedPolicies = setDefaultRecordType(
          groupedPolicies,
          this.recordTypes,
        )
      }

      this.groupedPolicies = sortBy(groupedPolicies, "carrier")
    }
  }

  // On reload coverages, get coverages grouped by carrier and policy
  // and merge them into the current grouped policies
  async handleRefresh() {
    this.loading = true

    let rawPolicies

    try {
      rawPolicies = await groupQuoteCoveragesByCarrierAndPolicy({
        quoteId: this.recordId,
      })
    } catch (error) {
      debug(
        "failed to refetch quote coverages grouped by carrier and policy:",
        error,
      )
    }

    if (rawPolicies) {
      this.rawPolicies = rawPolicies
      let fetchedPolicies = toGroupedPolicies(rawPolicies)
      fetchedPolicies = setDefaultPolicyNumber(fetchedPolicies)
      fetchedPolicies = setDefaultRecordType(fetchedPolicies, this.recordTypes)

      const groupedPolicies = mergeFetchedPoliciesToGroupedPolicies(
        fetchedPolicies,
        this.groupedPolicies,
      )
      const sortedGroupedPolicies = sortBy(groupedPolicies, "carrier")

      this.validateAndUpdateGroupedPolicies(sortedGroupedPolicies)
    }

    this.loading = false
  }

  /**
   * Recalculate total premium and fees for each policy and update groupedPolicies with errors.
   * @param {Array} policies
   */
  validateAndUpdateGroupedPolicies(policies) {
    const updatedPolicies = updatePolicyPremiumAndFees(policies)
    const { policiesWithErrors: validatedPolicies } = validateGroupedPolicies(
      updatedPolicies,
    )

    this.groupedPolicies = validatedPolicies
  }

  async handleBindPolicy() {
    this.loading = true

    // Validate quote details and policies
    const isValid = await this.validateBindPolicy()
    if (!isValid) {
      this.loading = false
      return
    }

    // Prepare policies for binding
    const rawGroupedPolicies = this.updateRawPoliciesForBinding()

    try {
      // When all coverages get created with multiple policies,
      // CanaryAMS trigger (SetCoverageExtId) makes too many SOQL queries and System.LimitException gets thrown.
      // To avoid the exception, create each policy in a separate Apex call.

      await Promise.all(
        rawGroupedPolicies.map((p) =>
          createPolicyWithCoverages({
            groupedPolicy: p,
            quoteId: this.recordId,
          }),
        ),
      ).then((policies) => {
        // Coverages will be null if they weren't created sucessfully
        const errors = []
        for (const policyIndex in policies) {
          if (!policies[policyIndex]) {
            errors.push(
              rawGroupedPolicies[policyIndex].carrier.Name +
                ": " +
                rawGroupedPolicies[policyIndex].policyName,
            )
          }
        }
        if (errors.length) {
          console.log("Failed to create a policy: " + errors.join())
          throw errors.join(", ")
        }
      })

      //TODO: learn how to link to policies page. Or discuss what to do after
      this.dispatchEvent(
        toastEvent(
          "Policies created successfully!",
          "Please verify all policies were created correctly in the Policies tab.",
          "success",
        ),
      )

      try {
        await this.updateQuoteStatus("Closed Won")
      } catch (error) {
        debug("Failed to update quote status:", error)
      }

      if (this.quote.quoteType === "Renewal") {
        try {
          await setRenewingPoliciesStatusByQuoteId({
            quoteId: this.recordId,
          })
        } catch (error) {
          debug("Failed to update renewing policy statuses:", error)
        }
      }
    } catch (error) {
      this.dispatchEvent(
        toastEvent(
          "Failed to create a policy: \n" + error,
          'Please check created policies from the "Policies" tab and retry binding unsuccessful policies. Contact the BMS team for support.',
          "error",
        ),
      )
    }

    this.loading = false
  }

  /**
   * Validates quote details and policies data.
   * Calls an Apex method after validating data to check if there already exists
   * a policy with the same policy number and effective date.
   * @returns {boolean} True if all data is valid and policies are ready to be bound
   */
  async validateBindPolicy() {
    // Validate quote details and dispatch event to Bind Policy parent component
    const quoteErrors = validateQuote(this.quote)
    this.dispatchEvent(customEvent("validationerror", quoteErrors))

    // Validate policies and update groupedPolicies with errors
    const {
      doesErrorExist: doesPolicyErrorExist,
      policiesWithErrors,
    } = validateGroupedPolicies(this.groupedPolicies)

    this.groupedPolicies = policiesWithErrors

    // If there is any error in quote or policies,
    // show errors and a toast message and scroll to top
    if (quoteErrors.length || doesPolicyErrorExist) {
      this.showBindPolicyErrors(quoteErrors)
      return false
    }

    const existingPolicyError = await this.checkExistingPolicies()

    if (existingPolicyError) {
      this.dispatchEvent(
        toastEvent("Policies cannot be bound.", existingPolicyError, "error"),
      )
      return false
    }

    return true
  }

  showBindPolicyErrors() {
    this.showErrors = true

    this.dispatchEvent(
      toastEvent(
        "Policies cannot be bound.",
        "Please fix the shown errors to create policies.",
        "error",
      ),
    )

    window.scrollTo({
      top: 0,
      behavior: "smooth",
    })
  }

  updateRawPoliciesForBinding() {
    return this.groupedPolicies.map((policy) => {
      const foundPolicy = this.rawPolicies
        .filter((rawPolicy) => !!rawPolicy.carrier)
        .find(
          (rawPolicy) =>
            policy.carrierId === rawPolicy.carrier.Id &&
            policy.policy.includes(rawPolicy.policyName),
        )

      if (foundPolicy) {
        return {
          ...foundPolicy,
          recordType: policy.recordType,
          policyNumber: policy.policyNumber,
          displayName: policy.displayName,
          carrierProduct: policy.carrierProduct,
          agencyFee: policy.agencyFee,
          carrierFee: policy.carrierFee,
          premium: policy.premium,
          coverages: policy.coverages,
        }
      }

      return policy
    })
  }

  updateQuoteStatus(status) {
    const recordInput = {
      fields: {
        [QUOTE_ID.fieldApiName]: this.recordId,
        [QUOTE_STATUS.fieldApiName]: status,
      },
    }

    return updateRecord(recordInput)
  }

  /**
   * Check if grouped policies are not using an existing combination of policy number and effective date.
   * @returns {(string|undefined)} An error message if there exists
   */
  async checkExistingPolicies() {
    const policyNumbers = this.groupedPolicies.map(
      (policy) => policy.policyNumber,
    )

    const existingPolicies = await findExistingPolicies({
      policyNumbers,
      effectiveDate: this.quote.effectiveDate,
    })

    const existingPolicyNumbers = existingPolicies.map(
      (existingPolicy) => `${existingPolicy[POLICY_NUMBER.fieldApiName]}`,
    )

    let existingPolicyError

    if (existingPolicyNumbers.length) {
      existingPolicyError = `Policy number "${existingPolicyNumbers.join(
        '" or "',
      )}" is already used with the same effective date (${
        this.quote.effectiveDate
      }).`
    }

    return existingPolicyError
  }

  handleCoverageDrag(event) {
    this.currentDraggedCoverage = event.detail
  }

  moveCoverage(event) {
    const { coverage, policy } = event.detail

    let groupedPolicies = JSON.parse(JSON.stringify(this.groupedPolicies))

    groupedPolicies = groupedPolicies.map((pol) => {
      pol.coverages = pol.coverages.filter((cov) => {
        return cov.Id !== coverage.Id
      })

      if (pol.id === policy.id) {
        pol.coverages.push(coverage)
      }

      return pol
    })

    this.validateAndUpdateGroupedPolicies(groupedPolicies)
  }

  updatePolicyNumberForPolicy(event) {
    const { policyId, policyNumber } = event.detail
    let groupedPolicies = JSON.parse(JSON.stringify(this.groupedPolicies))

    groupedPolicies = groupedPolicies.map((policy) => {
      if (policy.id === policyId) {
        policy.policyNumber = policyNumber
      }

      return policy
    })

    this.validateAndUpdateGroupedPolicies(groupedPolicies)
  }

  updateRecordTypeForPolicy(event) {
    const { policyId, recordType } = event.detail
    let groupedPolicies = JSON.parse(JSON.stringify(this.groupedPolicies))

    groupedPolicies = groupedPolicies.map((policy) => {
      if (policy.id === policyId) {
        policy.recordType = recordType
      }

      return policy
    })

    this.validateAndUpdateGroupedPolicies(groupedPolicies)
  }

  updateCarrierProductForPolicy(event) {
    const { policyId, carrierProduct } = event.detail
    let groupedPolicies = JSON.parse(JSON.stringify(this.groupedPolicies))

    groupedPolicies = groupedPolicies.map((policy) => {
      if (policy.id === policyId) {
        policy.carrierProduct = carrierProduct
      }

      return policy
    })

    this.validateAndUpdateGroupedPolicies(groupedPolicies)
  }

  removePolicy(event) {
    const { policyId } = event.detail
    let groupedPolicies = JSON.parse(JSON.stringify(this.groupedPolicies))

    groupedPolicies = groupedPolicies.filter((policy) => {
      return policy.id !== policyId
    })

    this.validateAndUpdateGroupedPolicies(groupedPolicies)
  }
}
