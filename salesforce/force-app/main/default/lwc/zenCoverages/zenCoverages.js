import { LightningElement, track, wire, api } from "lwc"
import { getRecord, getFieldValue } from "lightning/uiRecordApi"
import { refreshApex } from "@salesforce/apex"

import getCarriers from "@salesforce/apex/Carriers.getCarriers"
import getQuoteCoverages from "@salesforce/apex/QuoteCoverages.getQuoteCoverages"
import deleteQuoteCoverages from "@salesforce/apex/QuoteCoverages.deleteQuoteCoverages"
import getPolicyAndCoverageOptions from "@salesforce/apex/PolicyOptions.getPolicyAndCoverageOptions"
import updateFlowIndustryFromResumeLink from "@salesforce/apex/Accounts.updateFlowIndustryFromResumeLink"
import calculateQuotePremiumAndFees from "@salesforce/apex/Quotes.calculateQuotePremiumAndFees"
import calculatePolicyPremiumAndFees from "@salesforce/apex/Policies.calculatePolicyPremiumAndFees"

import QUOTE_TYPE from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Transaction_Type__c"
import QUOTE_ACCOUNT_FLOW_SLUG from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Account__r.Flow__r.Slug__c"
import QUOTE_ACCOUNT_INDUSTRY_SLUG from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Account__r.Industry_Rel__r.Slug__c"
import QUOTE_RESUME_LINK from "@salesforce/schema/CanaryAMS__Insurance_Product__c.Resume_Quote_Link__c"
import QUOTE_ID from "@salesforce/schema/CanaryAMS__Insurance_Product__c.Id"
import QUOTE_SUBMISSION_ID from "@salesforce/schema/CanaryAMS__Insurance_Product__c.ZEN_Submission_ID__c"
import QUOTE_BROKER_RESUME_LINK from "@salesforce/schema/CanaryAMS__Insurance_Product__c.ZEN_Broker_Resume_Link__c"

import POLICY_ACCOUNT_FLOW_SLUG from "@salesforce/schema/CanaryAMS__Policy__c.CanaryAMS__Account__r.Flow__r.Slug__c"
import POLICY_ACCOUNT_INDUSTRY_SLUG from "@salesforce/schema/CanaryAMS__Policy__c.CanaryAMS__Account__r.Industry_Rel__r.Slug__c"
import POLICY_ID from "@salesforce/schema/CanaryAMS__Policy__c.Id"
import POLICY_QUOTE_ID from "@salesforce/schema/CanaryAMS__Policy__c.CanaryAMS__Product__c"
import POLICY_QUOTE_RESUME_LINK from "@salesforce/schema/CanaryAMS__Policy__c.CanaryAMS__Product__r.Resume_Quote_Link__c"
import POLICY_QUOTE_SUBMISSION_ID from "@salesforce/schema/CanaryAMS__Policy__c.CanaryAMS__Product__r.ZEN_Submission_ID__c"

import { OBJECT_API_NAMES } from "./config.js"
import {
  quoteColumns,
  policyColumns,
  quoteReadOnlyColumns,
  policyReadOnlyColumns,
} from "./columns"

import { sortAndFormatCoverages, getLimitOptions } from "./utils"
import {
  persistQuoteCoverages,
  updateRawQuoteCoverages,
} from "./quoteCoverageProvider"
import { fieldsToProps } from "./quoteCoverageAdapter"
import { validateDraftValues } from "./quoteCoverageValidator"
import {
  isTemporaryId,
  generateRandomId,
  sortBy,
  updateTableData,
  updateDraftValuesWithDropdownChangeEvent,
  updateDraftValuesWithCellChangeEvent,
  toastEvent,
} from "c/shared"

const QUOTE_FIELDS = [
  QUOTE_ACCOUNT_FLOW_SLUG,
  QUOTE_ACCOUNT_INDUSTRY_SLUG,
  QUOTE_RESUME_LINK,
  QUOTE_ID,
  QUOTE_SUBMISSION_ID,
  QUOTE_TYPE,
  QUOTE_BROKER_RESUME_LINK,
]

const POLICY_FIELDS = [
  POLICY_ID,
  POLICY_QUOTE_ID,
  POLICY_QUOTE_RESUME_LINK,
  POLICY_ACCOUNT_FLOW_SLUG,
  POLICY_ACCOUNT_INDUSTRY_SLUG,
  POLICY_QUOTE_SUBMISSION_ID,
]

/** @typedef { import('../../../../../types').InputTextMenuItem } InputTextMenuItem */

function resumeLinkParamsFromUrl(resumeLinkUrl) {
  const params = new URL(`${resumeLinkUrl}`).searchParams

  return {
    token: params.get("token"),
    qid: params.get("qid"),
  }
}

export default class CoveragesDataTable extends LightningElement {
  selectedCoverages = []
  cachedData = []
  rawDataCache = []

  @track isReadOnly
  @track isLoading
  @track rowFilterMode = "all"
  @track filterMenuLabel = "All"
  @track draftValues = []
  @track displayData = []
  @track columns
  @track readOnlyColumns
  @track title

  @api recordId
  @api objectApiName

  @wire(getRecord, {
    recordId: "$recordId",
    optionalFields: [...QUOTE_FIELDS],
  })
  async wiredDataFromQuote({ error, data }) {
    if (error) {
      console.log("Error fetching Quote data for coverages component", error)
    }

    if (this.isQuoteObject() && data) {
      try {
        this.quoteId = this.recordId
        this.quoteResumeLink = getFieldValue(data, QUOTE_RESUME_LINK)
        this.submissionId = getFieldValue(data, QUOTE_SUBMISSION_ID)
        this.flowSlug = getFieldValue(data, QUOTE_ACCOUNT_FLOW_SLUG)
        this.industrySlug = getFieldValue(data, QUOTE_ACCOUNT_INDUSTRY_SLUG)
        this.quoteType = getFieldValue(data, QUOTE_TYPE)
        this.quoteBrokerResumeLink = getFieldValue(
          data,
          QUOTE_BROKER_RESUME_LINK,
        )
        this.columns = quoteColumns
        this.readOnlyColumns = quoteReadOnlyColumns
      } catch (error) {
        console.log("Error setting properties from salesforce fields:", error)
      }

      await this.onUpdateWiredQuote()
    }
  }

  @wire(getRecord, {
    recordId: "$recordId",
    optionalFields: [...POLICY_FIELDS],
  })
  async wiredDataFromPolicy({ error, data }) {
    if (error) {
      console.log("Error fetching Policy data for coverages component", error)
    }

    if (this.isPolicyObject() && data) {
      try {
        this.quoteId = getFieldValue(data, POLICY_QUOTE_ID)
        this.quoteResumeLink = getFieldValue(data, POLICY_QUOTE_RESUME_LINK)
        this.submissionId = getFieldValue(data, POLICY_QUOTE_SUBMISSION_ID)
        this.flowSlug = getFieldValue(data, POLICY_ACCOUNT_FLOW_SLUG)
        this.industrySlug = getFieldValue(data, POLICY_ACCOUNT_INDUSTRY_SLUG)
        this.columns = policyColumns
        this.readOnlyColumns = policyReadOnlyColumns
      } catch (error) {
        console.log("Error setting properties from salesforce fields:", error)
      }

      await this.onUpdateWiredQuote()
    }
  }

  async connectedCallback() {
    // Prepare carrier options on load
    const carriers = await getCarriers()

    this.carrierOptions = carriers.map((carrier) => ({
      label: carrier.Name,
      value: carrier.Id,
    }))
  }

  isPolicyObject() {
    return this.objectApiName === OBJECT_API_NAMES.POLICY
  }

  isQuoteObject() {
    return this.objectApiName === OBJECT_API_NAMES.QUOTE
  }

  async onUpdateWiredQuote() {
    // TODO: Uncomment this when it is ready to make the table read-only for the renewal team
    // this.isReadOnly = this.isQuoteObject() && this.quoteType === "Renewal"

    try {
      await this.updateAvailablePolicies()
    } catch (error) {
      console.error("Failed to update available policies:", error)
    }
  }

  async updateAvailablePolicies() {
    if (this.flowSlug && this.industrySlug) {
      let availablePolicies = []

      try {
        const params = {
          industrySlug: this.industrySlug,
          flowSlug: this.flowSlug,
          subindustrySlug: "",
        }

        if (this.submissionId) {
          params.submissionId = this.submissionId
        }

        availablePolicies = await getPolicyAndCoverageOptions(params)
      } catch (error) {
        console.log("Error fetching policy and coverage options", error)
        return
      }

      // attaching temp id to coverages wihtout ids for later matching purposes
      const availablePoliciesWithCoverageIds = availablePolicies.map(
        (aPolicy) => {
          const coverages = aPolicy.coverages.map((cov) => ({
            ...cov,
            id: cov.id || "temp-" + generateRandomId(),
            label: cov.name,
          }))

          return {
            ...aPolicy,
            label: aPolicy.name,
            coverages: sortBy(coverages, "name"),
          }
        },
      )

      this.availablePolicies = sortBy(availablePoliciesWithCoverageIds, "name")

      this.policyOptions = this.availablePolicies.map((policy) => ({
        value: policy.id,
        label: policy.label,
      }))

      this.setDataWithRawData()
    } else if (this.quoteResumeLink && this.quoteId) {
      // NOTE: calling `updateFlowIndustryFromResumeLink` only if:
      // `flowId` && `insdustryId` are not available
      const { qid, token } = resumeLinkParamsFromUrl(this.quoteResumeLink)

      // TODO: After getting the flow information from Apex Controller
      // update this instance with the `flowId` and `industryId` and run function again.

      try {
        const {
          Flow__r: { Slug__c: flowSlug },
          Industry_Rel__r: { Slug__c: industrySlug },
        } = await updateFlowIndustryFromResumeLink({
          quoteId: this.quoteId,
          qid,
          token,
        })

        if (!industrySlug || !flowSlug)
          throw new Error(
            `Either "industrySlug"(${industrySlug}) or "flowSlug"(${flowSlug}) is not available.`,
          )

        this.industrySlug = industrySlug
        this.flowSlug = flowSlug

        this.updateAvailablePolicies()
      } catch (error) {
        console.error(
          "Failed to retrieve flow information from resume link",
          error,
        )
      }
    }
  }

  handleFilterMenu(event) {
    this.rowFilterMode = event.detail.value

    this.updateDisplayData()
  }

  updateDisplayData() {
    const isSelectedByUser = (dataRow) =>
      dataRow.limit && dataRow.limit.toLowerCase() !== "excluded"

    let displayData = this.cachedData

    switch (this.rowFilterMode) {
      case "selected":
        displayData = this.cachedData.filter(
          (dataRow) => isTemporaryId(dataRow.id) || isSelectedByUser(dataRow),
        )
        this.filterMenuLabel = "Selected"
        break
      case "notSelected":
        displayData = this.cachedData.filter(
          (dataRow) => isTemporaryId(dataRow.id) || !isSelectedByUser(dataRow),
        )
        this.filterMenuLabel = "Not Selected"
        break
      default:
        this.filterMenuLabel = "All"
    }

    this.displayData = sortAndFormatCoverages(displayData)
  }

  handleCancel() {
    this.draftValues = []
    // remove temp rows
    this.cachedData = this.cachedData.filter((row) => !isTemporaryId(row.id))
    this.updateDisplayData()
  }

  addCoverages() {
    const tempId = "temp" + "-" + Date.now()

    const updatedCacheData = [
      ...this.cachedData,
      {
        id: tempId,
        policyOptions: this.policyOptions,
        carrierOptions: this.carrierOptions,
      },
    ]

    // this is to display cancel save buttons as soon as a temp coverage row is displayed, cancelling will remove that row again
    this.draftValues = [...this.draftValues, { id: tempId }]

    this.cachedData = updatedCacheData

    this.updateDisplayData()
  }

  removeEmptyDraftRows(draftRows) {
    return draftRows.filter(
      (row) => !(isTemporaryId(row.id) && Object.keys(row).length === 1),
    )
  }

  // When policy value is changed, reset coverage value and options.
  // Also, reset limit options to be empty as it is dependent on coverage value.
  onPolicyChange(rowId, policyId) {
    const draftValueUpdates = [
      { rowId, columnName: "policy", value: policyId },
      { rowId, columnName: "coverage", value: null },
    ]

    const selectedPolicyData = this.availablePolicies.find(
      (policy) => policy.id === policyId,
    )

    const coverageOptions = selectedPolicyData
      ? selectedPolicyData.coverages.map((coverage) => ({
          value: coverage.id,
          label: coverage.label,
        }))
      : []

    const displayDataUpdates = [
      { rowId, columnName: "coverageOptions", value: coverageOptions },
      { rowId, columnName: "limitOptions", value: [] },
    ]

    this.draftValues = updateTableData(this.draftValues, draftValueUpdates)
    this.displayData = updateTableData(this.displayData, displayDataUpdates)
  }

  // When coverage value is changed, reset limit options.
  onCoverageChange(rowId, coverageId) {
    const draftValueUpdates = [
      { rowId, columnName: "coverage", value: coverageId },
    ]

    // On coverage change, policy id can be found from draft values
    // as coverage should only be editable after policy is set in a newly created row
    const updatedRow = this.draftValues.find((row) => row.id === rowId)

    const limitOptions =
      updatedRow && coverageId
        ? getLimitOptions({
            policies: this.availablePolicies,
            policyId: updatedRow.policy,
            coverageId: coverageId,
          })
        : []

    const displayDataUpdates = [
      { rowId, columnName: "limitOptions", value: limitOptions },
    ]

    this.draftValues = updateTableData(this.draftValues, draftValueUpdates)
    this.displayData = updateTableData(this.displayData, displayDataUpdates)
  }

  // When carrier value is changed, update the value for all selected rows as well.
  onCarrierChange(rowId, carrierId) {
    const selectedRowUpdates = this.selectedCoverages.map((coverage) => ({
      rowId: coverage.id,
      columnName: "carrier",
      value: carrierId,
    }))

    const draftValueUpdates = [
      ...selectedRowUpdates,
      { rowId, columnName: "carrier", value: carrierId },
    ]

    this.draftValues = updateTableData(this.draftValues, draftValueUpdates)
  }

  onDropdownChange(event) {
    this.draftValues = updateDraftValuesWithDropdownChangeEvent(
      this.draftValues,
      event,
    )
  }

  handleDropdownChange(event) {
    const { rowId, columnName, selectedValue } = event.detail

    switch (columnName) {
      case "policy":
        this.onPolicyChange(rowId, selectedValue)
        break
      case "coverage":
        this.onCoverageChange(rowId, selectedValue)
        break
      case "carrier":
        this.onCarrierChange(rowId, selectedValue)
        break
      default:
        this.onDropdownChange(event)
    }
  }

  handleCellChange(event) {
    this.draftValues = updateDraftValuesWithCellChangeEvent(
      this.draftValues,
      event,
    )
  }

  validateUpdatedRows(draftData, cachedData) {
    try {
      if (draftData.length === 0) {
        throw "You can't save an empty coverage."
      }

      validateDraftValues(draftData, cachedData)
    } catch (error) {
      this.dispatchEvent(
        toastEvent("Unable to save coverages.", error, "error"),
      )
      return false
    }
    return true
  }

  async handleSave() {
    this.isLoading = true
    const filteredDraftValues = this.removeEmptyDraftRows(this.draftValues)

    const draftDataIsValid = this.validateUpdatedRows(
      filteredDraftValues,
      this.cachedData,
    )

    if (draftDataIsValid) {
      try {
        await persistQuoteCoverages(
          filteredDraftValues,
          this.recordId,
          this.objectApiName,
          {
            availablePolicies: this.availablePolicies || [],
          },
        )
      } catch (error) {
        console.log("Failed to save coverages: ", error)
        this.dispatchEvent(
          toastEvent(
            "Coverages were not saved successfully.",
            "Please let the BMS team know of the issue.",
            "error",
          ),
        )
      }

      await refreshApex(this.wiredCoverages)

      this.draftValues = []

      this.calculateTotalPremiumAndFees()
    }

    this.isLoading = false
  }

  handleRowSelection(event) {
    const coverages = event.detail.selectedRows.map((row) => {
      row["Id"] = row.id
      return row
    })
    this.selectedCoverages = coverages
  }

  async deleteCoverages() {
    this.isLoading = true

    const coveragesToDelete = this.selectedCoverages.filter(
      (selectedCoverage) => !/^temp\-/.test(selectedCoverage.id),
    )

    try {
      await deleteQuoteCoverages({
        deleteCoverageList: coveragesToDelete,
      })

      if (coveragesToDelete.length === this.cachedData.length) {
        this.cachedData = []
        this.updateDisplayData()
      }
    } catch (error) {
      console.log("Failed to delete coverages:", error)
      this.dispatchEvent(
        toastEvent(
          "Coverages were not deleted successfully.",
          "Please let the BMS team know of the issue.",
          "error",
        ),
      )
    }

    await refreshApex(this.wiredCoverages)

    this.isLoading = false

    this.calculateTotalPremiumAndFees()
  }

  async calculateTotalPremiumAndFees() {
    if (this.isQuoteObject()) {
      await calculateQuotePremiumAndFees({ quoteId: this.recordId })
    }

    if (this.isPolicyObject()) {
      await calculatePolicyPremiumAndFees({ policyId: this.recordId })
    }
  }

  setDataWithRawData() {
    const mappedData = this.rawDataCache.map((dataSet) => {
      const props = fieldsToProps(dataSet, {
        availablePolicies: this.availablePolicies,
      })

      return {
        ...props,
        policyOptions: this.policyOptions,
        carrierOptions: this.carrierOptions,
      }
    })

    this.cachedData = mappedData
    this.displayData = sortAndFormatCoverages(mappedData)
    this.title = `Coverages (${this.cachedData.length})`
  }

  async updateQuoteCoveragesAndRewire(rowsToUpdate) {
    await updateRawQuoteCoverages(rowsToUpdate)

    await refreshApex(this.wiredCoverages)
  }

  @wire(getQuoteCoverages, {
    recordId: "$recordId",
    objectApiName: "$objectApiName",
  })
  async getCoverages(wiredValue) {
    this.wiredCoverages = wiredValue
    const { error, data } = wiredValue
    if (Array.isArray(data) && data.length) {
      // TODO: refactor this functionality
      // Checks if old field have values and new ones dont, if they do, update SF database asynchronously.
      // The adapter will ensure that the values get pushed to the table even when theyre not saves yet
      // ----->>>
      const rowsToUpdate = data
        .filter((dataSet) => {
          return (
            (!dataSet.Zen_Limit__c &&
              dataSet.CanaryAMS__Limit_Format_Integer__c) ||
            (!dataSet.Zen_Deductible__c &&
              dataSet.CanaryAMS__Deductible_Format_Integer__c)
          )
        })
        .map((dataSet) => {
          let addIn = {}
          if (dataSet.CanaryAMS__Deductible_Format_Integer__c)
            addIn = {
              ...addIn,
              Zen_Deductible__c:
                dataSet.CanaryAMS__Deductible_Format_Integer__c + "",
            }
          if (dataSet.CanaryAMS__Limit_Format_Integer__c)
            addIn = {
              ...addIn,
              Zen_Limit__c: dataSet.CanaryAMS__Limit_Format_Integer__c + "",
            }
          return {
            Id: dataSet.Id,
            ...addIn,
          }
        })

      if (rowsToUpdate.length > 0) {
        this.updateQuoteCoveragesAndRewire(rowsToUpdate)
      }
      //// <------

      this.rawDataCache = data

      this.setDataWithRawData()
    } else if (error) {
      this.error = error
    }
  }
}
