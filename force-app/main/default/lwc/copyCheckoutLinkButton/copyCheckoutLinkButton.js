import { LightningElement, api, track, wire } from "lwc"
import { getRecord, getFieldValue } from "lightning/uiRecordApi"
import { toastEvent } from "c/shared"

import getQuoteCoverages from "@salesforce/apex/QuoteCoverages.getQuoteCoverages"

import QUOTE_READY_TO_PURCHASE from "@salesforce/schema/CanaryAMS__Insurance_Product__c.Ready_to_Purchase__c"
import QUOTE_ZEN_PAYMENT_STATUS from "@salesforce/schema/CanaryAMS__Insurance_Product__c.ZEN_Payment_Status__c"
import QUOTE_ZEN_CALCULATED_PREMIUM from "@salesforce/schema/CanaryAMS__Insurance_Product__c.Zen_Calculated_Premium__c"
import QUOTE_SUBMITTED from "@salesforce/schema/CanaryAMS__Insurance_Product__c.quote_submitted__c"
import QUOTE_ALLOW_FINANCING from "@salesforce/schema/CanaryAMS__Insurance_Product__c.Allow_Financing__c"
import QUOTE_QUOTED_CARRIER from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Quoted_Carrier__c"
import QUOTE_ZEN_CHECKOUT_LINK from "@salesforce/schema/CanaryAMS__Insurance_Product__c.ZENEsignCheckoutLink__c"

export default class CopyCheckoutLinkButton extends LightningElement {

  @track quote
  @track errors = []
  @track showErrors = false
  @track showLink = false
  
  @api recordId
  @api objectApiName

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      QUOTE_READY_TO_PURCHASE,
      QUOTE_ZEN_PAYMENT_STATUS,
      QUOTE_ZEN_CALCULATED_PREMIUM,
      QUOTE_SUBMITTED,
      QUOTE_ALLOW_FINANCING,
      QUOTE_QUOTED_CARRIER,
      QUOTE_ZEN_CHECKOUT_LINK,
    ],
  })
  async wiredQuote({ error, data }) {
    if (data) {
      this.quote = {
        id: this.recordId,
        readyToPurchase: getFieldValue(data, QUOTE_READY_TO_PURCHASE),
        zenPaymentStatus: getFieldValue(data, QUOTE_ZEN_PAYMENT_STATUS),
        zenCalculatedPremium: getFieldValue(data, QUOTE_ZEN_CALCULATED_PREMIUM),
        quoteSubmitted: getFieldValue(data, QUOTE_SUBMITTED),
        allowFinancing: getFieldValue(data, QUOTE_ALLOW_FINANCING),
        quotedCarrier: getFieldValue(data, QUOTE_QUOTED_CARRIER),
        zenCheckoutLink: getFieldValue(data, QUOTE_ZEN_CHECKOUT_LINK),
      }
      await this.checkQuoteErrors()
    } else {
      console.log("Error fetching quote data: ", error)
    }
  }

  @wire(getQuoteCoverages, {
    recordId: "$recordId",
    objectApiName: "$objectApiName",
  })
  async getCoverages({error, data}) {
    if (data) {
      this.coverages = data
      if (this.quote){
        await this.checkQuoteErrors()
      }
    } else {
      console.log("Error fetching coverage data: ", error)
    }
  }

  async handleClick() {
    this.showErrors = true
    await this.checkQuoteErrors()
    
    if (!this.quote.zenCheckoutLink) {
      this.dispatchEvent(
        toastEvent(
          "Unable to copy checkout link.",
          "E-Sign checkout link is currently not available for this quote.",
          "error",
        ),
      )
    } else if (!this.errors.length) {
      this.showLink = true
      this.copyLinkToClipboard(this.quote.zenCheckoutLink)
      this.dispatchEvent(
        toastEvent(
          "Checkout link copied to clipboard.",
          "",
          "success",
        ),
      )
    } else {
      this.dispatchEvent(
        toastEvent(
          "Unable to copy checkout link.",
          "Please fix the shown errors and try again.",
          "error",
        ),
      )
    }
  }

  async checkQuoteErrors() {
    this.errors = []
    if (this.recordId === null) {
      this.dispatchEvent(
        toastEvent(
          "Unable to find this quote in Salesforce.",
          "Please contact the BMS team for support.",
          "error",
        ),
      )
      return
    }

    if (!this.quote.readyToPurchase) 
      this.errors.push('"Ready to Purchase" must be checked')
    
    if (this.quote.zenPaymentStatus && this.quote.zenPaymentStatus !== 'None' && this.quote.zenPaymentStatus !== 'Zen One-Pay - Pre-Auth') 
      this.errors.push('"Payment Status" must be "None" or "Zen One-Pay - Pre-Auth"')

    if (this.quote.zenCalculatedPremium <= 0) 
      this.errors.push('"Zen Calculated Premium" must be greater than 0')
    
    if (!this.quote.quoteSubmitted) 
      this.errors.push('"Quote Submitted" must be checked')

    if (this.quote.allowFinancing && (!this.quote.quotedCarrier || this.quote.zenCalculatedPremium < 650)) 
      this.errors.push('"Quoted Carrier" must be filled in and "Zen Calculated Premium" must be at least $650 when "Allow Financing" is checked')

    if (this.coverages) {
      for (let coverage of this.coverages) {
        if (!coverage.Is_Sub_Coverage__c && coverage.Zen_Limit__c !== 'Excluded' && !coverage.Carrier__c) {
          this.errors.push(`"${coverage.API_Coverage_Name__c}" must have a carrier or be excluded.\n`)
        }
      }
    }

    if (this.showLink && this.errors.length) {
      this.showLink = false
    }
  }

  copyLinkToClipboard(link) {
    let temp = document.createElement('textarea');
    temp.value = link;

    temp.setAttribute('readonly', '');
    temp.style = {position: 'absolute', left: '-1000px'};

    document.body.appendChild(temp);
    temp.select();

    document.execCommand('copy');
    document.body.removeChild(temp);
  }
}