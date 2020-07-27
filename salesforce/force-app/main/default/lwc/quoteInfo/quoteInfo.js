import { LightningElement, api, track, wire } from "lwc"
import { getRecord, getFieldValue } from "lightning/uiRecordApi"

import getApiHost from "@salesforce/apex/SharedUtils.getApiHost"
import getRenewingPolicyIds from "@salesforce/apex/RenewalQuotes.getRenewingPolicyIds"
import claimExistsForRenewingPolicies from "@salesforce/apex/RenewalQuotes.claimExistsForRenewingPolicies"

import QUOTE_TYPE from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Transaction_Type__c"
import QUOTE_EFFECTIVE_DATE from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Policy_Effective_Date__c"

import { toastEvent } from "c/shared"

import { getMonthsUntil } from "./util"

export default class QuoteInfo extends LightningElement {
  EFFECTIVE_DATE_MONTHS_THRESHOLD = 5

  @track quote
  @track showInfo = false
  @track showWarning = false

  @api recordId

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [QUOTE_TYPE, QUOTE_EFFECTIVE_DATE],
  })
  async wiredQuote({ error, data }) {
    if (data) {
      const quote = {
        id: this.recordId,
        type: getFieldValue(data, QUOTE_TYPE),
        effectiveDate: getFieldValue(data, QUOTE_EFFECTIVE_DATE),
      }

      await this.handleQuoteUpdate(quote)
    }
  }

  async handleQuoteUpdate(quote) {
    this.quote = quote

    if (this.quote.type === "Renewal") {
      this.endorsementExists = await this.endorsementExistsForRenewingPolicies(
        this.quote.id,
      )

      this.claimExists = await claimExistsForRenewingPolicies({
        quoteId: this.quote.id,
      })
    }

    this.isEffectiveDateTooFar = getMonthsUntil(this.quote.effectiveDate) >= this.EFFECTIVE_DATE_MONTHS_THRESHOLD

    this.showInfo = this.endorsementExists || this.claimExists
    this.showWarning = this.isEffectiveDateTooFar
  }

  async endorsementExistsForRenewingPolicies(quoteId) {
    let endorsementExists = false
    const renewingPolicyIds = await getRenewingPolicyIds({ quoteId })

    if (!(Array.isArray(renewingPolicyIds) && renewingPolicyIds.length > 0)) {
      return false
    }

    const query = renewingPolicyIds.map((id) => `policyIds=${id}`).join("&")
    const apiUrl = await getApiHost()

    try {
      const response = await fetch(
        `${apiUrl}/v4/endorsements/byPolicyIds?${query}`,
      )

      if (response.status !== 200) throw new Error()

      const { data } = await response.json()

      endorsementExists = data.some(
        (item) =>
          Array.isArray(item.endorsements) && item.endorsements.length > 0,
      )
    } catch (error) {
      this.dispatchEvent(
        toastEvent(
          "Failed to fetch endorsement data for renewing policies.",
          "Please let the BMS team know of the issue.",
          "error",
        ),
      )
    }

    return endorsementExists
  }
}
