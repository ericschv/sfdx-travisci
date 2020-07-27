import { LightningElement, api, track } from "lwc"
import { customEvent, toastEvent } from "c/shared"

export default class UserFriendlyPolicy extends LightningElement {
  @track carrierProductOptions
  @track recordTypeOptions

  @api policy
  @api showErrors
  @api currentDraggedCoverage
  @api
  get carrierProducts() {
    return this.carrierProductOptions
  }
  set carrierProducts(products) {
    const filteredCarrierProducts = products.filter(
      (cp) => cp.carrierId === this.policy.carrierId,
    )

    this.carrierProductOptions = filteredCarrierProducts.map((cp) => ({
      label: cp.name,
      value: cp.id,
    }))
  }
  @api
  get recordTypes() {
    return this.recordTypeOptions
  }
  set recordTypes(types) {
    this.recordTypeOptions = types.map((recordType) => ({
      label: recordType.name,
      value: recordType.id,
    }))
  }

  numDraggedOverCoverage = 0

  handleDrop(evt) {
    this.template
      .querySelector(".coverage-container")
      .classList.remove("coverage-container--highlighted")

    if (this.currentCoverageCanBeAddedToThisPolicy()) {
      this.moveDraggedCoverage()
    } else {
      this.dispatchEvent(
        toastEvent(
          `You cannot move this coverage to this policy.`,
          `This policy only accepts coverages with the carrier - ${this.policy.carrier}.`,
          "error",
        ),
      )
    }
  }

  moveDraggedCoverage() {
    const event = customEvent("movecoverage", {
      coverage: this.currentDraggedCoverage,
      policy: this.policy,
    })

    this.dispatchEvent(event)
  }

  currentCoverageCanBeAddedToThisPolicy() {
    return this.currentDraggedCoverage.Carrier__c === this.policy.carrierId
  }

  cancelDragEvent(e) {
    e.preventDefault()
  }

  handleDragOver(e) {
    this.numDraggedOverCoverage = 1
    this.cancelDragEvent(e)
  }

  handleDragEnter(e) {
    this.numDraggedOverCoverage++
    this.template
      .querySelector(".coverage-container")
      .classList.add("coverage-container--highlighted")
    this.cancelDragEvent(e)
  }

  handleDragLeave(e) {
    this.numDraggedOverCoverage--
    if (this.numDraggedOverCoverage === 0) {
      this.template
        .querySelector(".coverage-container")
        .classList.remove("coverage-container--highlighted")
    }
    this.cancelDragEvent(e)
  }

  updateRecordType(e) {
    // bubble event to update policy here
    const event = customEvent("updaterecordtype", {
      policyId: this.policy.id,
      recordType: e.target.value,
    })

    this.dispatchEvent(event)
  }

  updatePolicyNumber(e) {
    // bubble event to update policy here
    const event = customEvent("updatepolicynumber", {
      policyId: this.policy.id,
      policyNumber: e.target.value,
    })

    this.dispatchEvent(event)
  }

  updateCarrierProduct(e) {
    // bubble event to update policy here
    const event = customEvent("updatecarrierproduct", {
      policyId: this.policy.id,
      carrierProduct: e.target.value,
    })

    this.dispatchEvent(event)
  }

  removePolicy(e) {
    if (confirm("Are you sure you want to remove this policy?") === true) {
      const event = customEvent("removepolicy", {
        policyId: this.policy.id,
      })

      this.dispatchEvent(event)
    }
  }
}
