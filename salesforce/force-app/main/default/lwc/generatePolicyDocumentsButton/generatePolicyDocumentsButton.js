import { LightningElement, api, wire, track } from "lwc"
import { getRecord } from "lightning/uiRecordApi"

import getPolicyDocument from "@salesforce/apex/PolicyDocuments.getPolicyDocument"

import POLICY_CARRIER_NAME from "@salesforce/schema/CanaryAMS__Policy__c.CanaryAMS__Carrier__r.Name"

export default class generatePolicyDocumentsButton extends LightningElement {
  @track visible = false
  @track loading = false
  @track label = "Generate Policy Documents"

  @api recordId

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [POLICY_CARRIER_NAME],
  })
  async wiredPolicy({ error, data }) {
    if (data) {
      this.carrierName =
        data.fields.CanaryAMS__Carrier__r.value.fields.Name.value
      if (this.carrierName === "ZenMGA - BeazMark E&O") {
        this.visible = true
      } else {
        this.visible = false
      }
    }
  }

  async handleClick(event) {
    console.log(
      `Generating Policy Documents of policy with id: "${this.recordId}" and CarrierName: "${this.carrierName}"`,
    )

    this.loading = true
    // Create Apex Controller to make ZENAPI call using policyId and return pdf URL
    // Hit that Apex controller and get the URL
    const policyId = this.recordId
    let urlObj
    try {
      urlObj = await getPolicyDocument({ policyId: policyId })
    } catch (error) {
      console.log(
        "Error thrown when trying to fetch policy document URL with apex controller",
        error,
      )
    }
    if (urlObj.error) {
      console.log(
        "Apex Controller returned an Error when trying to fetch policy document URL",
        urlObj.error,
      )
    } else {
      // use the returend URL to open a new tab with that URL
      // const mockURL = `https://google.com`

      const documentURL = urlObj.url
      window.open(documentURL, "_blank")
    }
    this.loading = false
  }
}
