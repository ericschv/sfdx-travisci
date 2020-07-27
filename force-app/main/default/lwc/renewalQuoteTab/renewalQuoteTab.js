import { LightningElement, track, wire, api } from "lwc"
import { getRecord } from "lightning/uiRecordApi"

import getRenewalPolicies from "@salesforce/apex/Quotes.getRenewalPolicies"
import getUserById from "@salesforce/apex/Users.getUserById"

import QUOTE_ID from "@salesforce/schema/CanaryAMS__Insurance_Product__c.Id"
import QUOTE_TYPE from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Transaction_Type__c"
import QUOTE_ACCOUNT from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Account__c"

import { camelCaseToTitleCase, formatDate } from "c/shared"

const QUOTE_FIELDS = [QUOTE_ID, QUOTE_TYPE, QUOTE_ACCOUNT]

export default class RenewalQuoteTab extends LightningElement {
  @track policies
  @track loading
  @track quote
  @api recordId

  get isRenewalQuote() {
    if (this.quote) {
      return this.quote.CanaryAMS__Transaction_Type__c.value == "Renewal"
    } else return false
  }

  async formatEndorsements(endorsements) {
    return Promise.all(
      endorsements
        .sort((x, y) =>
          // reverse chronological order
          Date.parse(x.createdAt) > Date.parse(y.createdAt) ? -1 : 1,
        )
        .map(async (endorsement) => {
          const user = await getUserById({ userId: endorsement.userId })

          const endorsementType = camelCaseToTitleCase(
            endorsement.endorsementType,
          )
          const createdAt = formatDate({ value: endorsement.createdAt })
          const effectiveDate = formatDate({
            value: endorsement.effectiveDate,
            onlyDate: true,
          })

          const endorsementMetadata = {
            proratedPremiumExists: this.doesProratedPremiumExist(
              endorsement.proratedPremium,
            ),
          }

          return {
            createdAt: createdAt,
            endorsementType: endorsementType,
            effectiveDate: effectiveDate,
            newTotalPremium: endorsement.newTotalPremium,
            oldTotalPremium: endorsement.oldTotalPremium,
            premiumDelta: endorsement.premiumDelta,
            userLink: `/${endorsement.userId}`,
            userName: user ? user.Name : endorsement.userId,
            notes: endorsement.notes,
            events: endorsement.events,
            proratedPremium: endorsement.proratedPremium,
            endorsementMetadata,
          }
        }),
    )
  }

  doesProratedPremiumExist(proratedPremium) {
    return proratedPremium !== null && typeof proratedPremium !== "undefined"
  }

  formatCoverages(rawCoverages) {
    const deductibleTypeMap = {
      PT: "%",
      FL: "$",
      hours: "hours",
    }

    const coverages = rawCoverages.map((coverage) => {
      if (coverage.CanaryAMS__Deductible_Type_Code__c) {
        coverage.CanaryAMS__Deductible_Type_Code__c =
          deductibleTypeMap[coverage.CanaryAMS__Deductible_Type_Code__c]
      }
      if (coverage.Carrier__r && coverage.Carrier__r.Name) {
        coverage.carrierName = coverage.Carrier__r.Name
      } else coverage.carrierName = ""

      return coverage
    })

    return coverages
  }

  async formatPolicies(rawPolicies) {
    const policies = Promise.all(
      rawPolicies.map(async (policy) => {
        policy.coverages = this.formatCoverages(policy.coverages)
        policy.endorsements = await this.formatEndorsements(policy.endorsements)
        policy.policy.fullName = `${policy.policy.Name} (${policy.policy.CanaryAMS__Policy_Number__c})`
        return policy
      }),
    )

    return policies
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: QUOTE_FIELDS,
  })
  async wiredDataFromQuote({ error, data }) {
    if (error) {
      console.log("Error fetching Quote data for coverages component", error)
    }

    if (data) {
      try {
        this.loading = true
        this.quote = data.fields

        const rawPolicies = await getRenewalPolicies({
          quoteId: this.quote.Id.value,
        })
        this.policies = await this.formatPolicies(rawPolicies)
        this.loading = false
      } catch (error) {
        console.log("Error setting properties from salesforce fields:", error)
        this.loading = false
      }
    }
  }
}
