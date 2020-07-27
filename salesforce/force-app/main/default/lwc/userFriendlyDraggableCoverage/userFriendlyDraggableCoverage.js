import { LightningElement, api, track } from "lwc"
import { customEvent, deductibleTypeDropdownOptions } from "c/shared"

export default class UserFriendlyDraggableCoverage extends LightningElement {
  @track _coverage
  @track rawCoverage

  @api
  get coverage() {
    return this._coverage
  }
  set coverage(cov) {
    this.rawCoverage = cov

    const deductibleType = deductibleTypeDropdownOptions.find(
      (option) => option.id === cov.CanaryAMS__Deductible_Type_Code__c,
    )

    this._coverage = {
      name: cov.Name,
      coverage: cov.API_Policy_Name__c,
      subcoverage: cov.API_Coverage_Name__c,
      carrierName: cov.Carrier__r ? cov.Carrier__r.Name : "",
      deductibleType: deductibleType ? deductibleType.label : "",
      isDeductibleTypeCurrency: deductibleType && deductibleType.label === "$",
      limit: cov.Zen_Limit__c,
      deductible: cov.Zen_Deductible__c,
      premium: cov.CanaryAMS__Current_Term_Amount__c,
      agencyFee: cov.Agency_Fee__c,
      carrierFee: cov.Carrier_Fee__c,
    }
  }

  handleDragStart() {
    const event = customEvent("coveragedrag", this.rawCoverage)
    this.dispatchEvent(event)

    window.addEventListener("dragover", this.autoScroll)
  }

  handleDragEnd() {
    window.removeEventListener("dragover", this.autoScroll)
  }

  autoScroll(e) {
    const scrollDelta = 5
    const scrollStartThreshold = 200

    if (e.clientY < scrollStartThreshold) {
      window.scrollTo(0, window.scrollY - scrollDelta)
    } else if (window.innerHeight - e.clientY < scrollStartThreshold) {
      window.scrollTo(0, window.scrollY + scrollDelta)
    }
  }

  ignoreDragEvent(e) {
    e.preventDefault()
  }
}
