import { LightningElement, api, wire, track } from "lwc"
import { getRecord, getFieldValue } from "lightning/uiRecordApi"

import QUOTE_TAX_AMOUNT from "@salesforce/schema/CanaryAMS__Insurance_Product__c.Tax_Amount__c"
import QUOTE_EFFECTIVE_DATE from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Policy_Effective_Date__c"
import QUOTE_EXPIRATION_DATE from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Policy_Expiration_Date__c"
import QUOTE_QUOTED_TERM from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Quoted_Term__c"
import QUOTE_PRODUCER from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Producer__r.Name"
import QUOTE_ZEN_PAYMENT_STATUS from "@salesforce/schema/CanaryAMS__Insurance_Product__c.ZEN_Payment_Status__c"
import QUOTE_INVOICED_AMOUNT from "@salesforce/schema/CanaryAMS__Insurance_Product__c.Invoiced_Amount__c"
import QUOTE_XERO_INVOICE_NUMBER from "@salesforce/schema/CanaryAMS__Insurance_Product__c.Xero_Invoice_Number__c"
import QUOTE_STATUS from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Stage__c"
import QUOTE_TYPE from "@salesforce/schema/CanaryAMS__Insurance_Product__c.CanaryAMS__Transaction_Type__c"

import { debug } from "c/shared"

export default class UserFriendlyPolicyPage extends LightningElement {
  @track errors = []
  @track isQuoteClosed

  @api quote = {}
  @api recordId
  @api objectApiName

  connectedCallback() {
    this.addEventListener("validationerror", this.handleValidationError)
  }

  disconnectedCallback() {
    this.removeEventListener("validationerror", this.handleValidationError)
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      QUOTE_TAX_AMOUNT,
      QUOTE_EFFECTIVE_DATE,
      QUOTE_EXPIRATION_DATE,
      QUOTE_QUOTED_TERM,
      QUOTE_PRODUCER,
      QUOTE_ZEN_PAYMENT_STATUS,
      QUOTE_INVOICED_AMOUNT,
      QUOTE_XERO_INVOICE_NUMBER,
      QUOTE_STATUS,
      QUOTE_TYPE,
    ],
  })
  async wiredQuote({ error, data }) {
    if (data) {
      this.quote = {
        id: this.recordId,
        producer: getFieldValue(data, QUOTE_PRODUCER),
        billingType: getFieldValue(data, QUOTE_ZEN_PAYMENT_STATUS),
        taxAmount: getFieldValue(data, QUOTE_TAX_AMOUNT)
          ? getFieldValue(data, QUOTE_TAX_AMOUNT) / 100
          : null,
        effectiveDate: getFieldValue(data, QUOTE_EFFECTIVE_DATE),
        invoicedAmount: getFieldValue(data, QUOTE_INVOICED_AMOUNT),
        term: getFieldValue(data, QUOTE_QUOTED_TERM),
        expirationDate: getFieldValue(data, QUOTE_EXPIRATION_DATE),
        xeroInvoiceNumber: getFieldValue(data, QUOTE_XERO_INVOICE_NUMBER),
        quoteType: getFieldValue(data, QUOTE_TYPE),
      }

      const status = getFieldValue(data, QUOTE_STATUS)
      this.isQuoteClosed = status === "Closed Won" || status === "Closed Lost"
    } else {
      debug("Didn't get valid data from wiredQuote:", data, error)
    }
  }

  handleValidationError({ detail: errors }) {
    this.errors = errors
  }
}
