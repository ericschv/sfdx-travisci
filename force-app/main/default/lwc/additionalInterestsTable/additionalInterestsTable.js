import { LightningElement, api, track, wire } from "lwc"
import { getRecord } from "lightning/uiRecordApi"

import getAdditionalInterestsByPolicyId from "@salesforce/apex/AdditionalInterests.getAdditionalInterestsByPolicyId"
import getCGLCoveragesByPolicyId from "@salesforce/apex/AdditionalInterests.getCGLCoveragesByPolicyId"
import getApiHost from "@salesforce/apex/SharedUtils.getApiHost"

import { toastEvent } from "c/shared"

import POLICY_ID from "@salesforce/schema/CanaryAMS__Policy__c.Id"

const POLICY_FIELDS = [POLICY_ID]

const addInterestColumns = [
  { label: "Name", fieldName: "Name" },
  { label: "Primary Address", fieldName: "CanaryAMS__Address_1__c" },
  { label: "City", fieldName: "CanaryAMS__City__c" },
  { label: "State/Province", fieldName: "CanaryAMS__StateProvCd__c" },
  { label: "Zip/Postal Code", fieldName: "CanaryAMS__PostalCode__c" },
  { label: "Type", fieldName: "CanaryAMS__Type__c" },
  { label: "Effective Date", fieldName: "Effective_Date__c" },
  { label: "End Date", fieldName: "CanaryAMS__End_Date__c" },
]

export default class AdditionalInterestsTable extends LightningElement {
  @track additionalInterests = []
  @track addInterestColumns = addInterestColumns
  @track loading
  @track buttonDisabled = true

  @api recordId

  @wire(getRecord, {
    recordId: "$recordId",
    fields: POLICY_FIELDS,
  })
  async wiredDataFromPolicy({ error, data }) {

    if (error) {
      console.log("Error fetching Policy data for coverages component", error)
    }

    if (data) {
      try {
        this.loading = true
        this.policy = data.fields

        this.additionalInterests = await getAdditionalInterestsByPolicyId({
          policyId: this.policy.Id.value,
        })
        this.loading = false
      } catch (error) {
        console.log("Error fetching additional interests from salesforce fields:", error)
        this.loading = false
      }
    } 
  }

  get hasAdditionalInterests() {
    return !!this.additionalInterests.length
  }

  handleRowSelection(event) {
    this.buttonDisabled = !event.detail.selectedRows.length
  }
  
  async handleClick(event) {
    // Get selected Additional Interests
    const selectedRows = this.template.querySelector('.additional-interests-table').getSelectedRows();
    
    const additionalInterests = []
    for (let i = 0; i < selectedRows.length; i++) {
      additionalInterests.push(selectedRows[i].Id)
    }

    // flag for sending certificates request
    let errors = false
    this.loading = true
    
    try {
      const CGLCoverages = await getCGLCoveragesByPolicyId({policyId: this.policy.Id.value})
      
      // policy must have cgl coverage for certificates
      if (!CGLCoverages.length) {
        errors = true
        this.dispatchEvent(
          toastEvent(
            "No CGL coverage found.",
            "Please ensure a CGL coverage exists before generating the certificate.",
            "warning",
          ),
        )
      }
    } catch (error) {
      errors = true
      this.dispatchEvent(
        toastEvent(
          "Failed to query CGL Coverages.",
          "Please try again and talk to the BMS team if the problem persists.",
          "error",
        ),
      )
    }

    if (!errors) {
      const apiUrl = await getApiHost()

      const data = {
        policyId: this.policy.Id.value,
        additionalInterests: additionalInterests
      }

      fetch(`${apiUrl}/v4/certificates`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
      })
        .then((response) => {
          // should have created a certificate
          if (response.status !== 201) throw new Error()

          this.dispatchEvent(
            toastEvent(
              "Certificates generated successfully.",
              "Please reload this page to see new certificates under the Documents section.",
              "success",
            ),
          )
        })
        .catch(() => {
          this.dispatchEvent(
            toastEvent(
              "Failed to generate certificates.",
              "Please try again and talk to the BMS team if the problem persists.",
              "error",
            ),
          )
        })
        .finally(() => {
          this.loading = false
        })
    } else {
      this.loading = false
    }
  }
}
