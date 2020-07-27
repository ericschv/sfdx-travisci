import { LightningElement, api, track } from "lwc"

import Id from "@salesforce/user/Id"
import calculatePremiumDelta from "@salesforce/apex/PolicyEventHistory.calculatePremiumDelta"
import getEventsByPolicyIdAndStatus from "@salesforce/apex/PolicyEventHistory.getEventsByPolicyIdAndStatus"
import createEndorsements from "@salesforce/apex/Endorsements.createEndorsements"

import endorsementTypeOptions from "./endorsementTypeOptions"

import { toastEvent } from "c/shared"

export default class EndorsementCreationModal extends LightningElement {
  userId = Id
  endorsementTypeOptions = endorsementTypeOptions
  proratedPremium = ""
  
  @track oldTotalPremium
  @track newTotalPremium
  @track premiumDelta
  @track isPremiumDeltaValid
  @track endorsementTypeError
  @track proratedPremiumError
  @track effectiveDateError
  @track loading
  @track pendingEvents = []

  @api policy

  async connectedCallback() {
    this.newTotalPremium = this.policy.newTotalPremium

    // Fetch premium delta
    const { delta, error } = await calculatePremiumDelta({
      policyId: this.policy.id,
    })

    if (error) {
      console.error(error)
    } else {
      this.premiumDelta = parseFloat(delta)

      if (typeof this.premiumDelta === "number") {
        this.isPremiumDeltaValid = true
      } else {
        console.error(
          "Received invalid type of premium delta: ",
          this.premiumDelta,
        )
      }

      this.oldTotalPremium = this.newTotalPremium - this.premiumDelta
    }

    // Fetch all pending events
    this.pendingEvents = await getEventsByPolicyIdAndStatus({
      policyId: this.policy.id,
      status: "pending",
    })
  }

  dispatchCloseModalEvent() {
    this.dispatchEvent(new CustomEvent("closemodal"))
  }

  handleEndorsementTypeChange(event) {
    this.endorsementType = event.target.value
    this.endorsementTypeError = !this.endorsementType
  }

  handleEffectiveDateChange(event) {
    this.effectiveDate = event.target.value
    this.effectiveDateError = !this.effectiveDate
  }

  handleNotesChange(event) {
    this.notes = event.target.value
  }

  handleProratedPremiumFieldChange(event) {
    this.proratedPremium = event.target.value
    this.proratedPremiumError = !this.isValidProratedPremium()
  }

  cleanProratedPremiumField() {
    // sets proratedPremium to null if field is empty in modal
    this.proratedPremium = this.proratedPremium !== ""
        ? this.proratedPremium
        : null
  }

  isValidDollarAmount(amountToCheck) {
    let dollarValueRegex = new RegExp("^\\d+(\\.\\d{1,2}|)$")

    // string interpolate to stringify before test
    return dollarValueRegex.test(`${amountToCheck}`)
  }

  isValidProratedPremium() {
    const premiumToValidate = this.proratedPremium

    return (
      this.proratedPremium === "" || this.isValidDollarAmount(premiumToValidate)
    )
  }

  validateInputs() {
    this.cancelPolicyEndorsementError = false

    this.endorsementTypeError = !this.endorsementType
    this.effectiveDateError = !this.effectiveDate
    this.proratedPremiumError = !this.isValidProratedPremium()

    // If endorsing events as "Cancel Policy",
    // there must be a pending cancel policy event.
    if (this.endorsementType === "cancelPolicy") {
      const cancelPolicyEvent = this.pendingEvents.find(
        (event) =>
          event.status === "pending" && event.action === "cancelPolicy",
      )

      if (!cancelPolicyEvent) this.cancelPolicyEndorsementError = true
    }
  }

  async endorsePendingEvents() {
    this.validateInputs()

    if (this.cancelPolicyEndorsementError) {
      this.dispatchEvent(
        toastEvent(
          'Changes were not endorsed successfully with endorsement type \"Cancel Policy\".',
          "Make sure that the policy was cancelled and the change has not been endorsed yet.",
          "error",
        ),
      )
    }

    if (
      this.endorsementTypeError ||
      this.effectiveDateError ||
      this.cancelPolicyEndorsementError ||
      this.proratedPremiumError
    )
      return

    this.loading = true

    this.cleanProratedPremiumField()

    const endorsement = {
      endorsementType: this.endorsementType,
      effectiveDate: this.effectiveDate,
      premiumDelta: this.premiumDelta,
      oldTotalPremium: this.oldTotalPremium,
      newTotalPremium: this.newTotalPremium,
      policyId: this.policy.id,
      eventIds: this.pendingEvents.map((event) => event.eventId),
      notes: this.notes,
      userId: this.userId,
      proratedPremium: this.proratedPremium,
    }

    try {
      const { error } = await createEndorsements({
        endorsements: [endorsement],
      })

      if (error) {
        throw error
      } else {
        this.loading = false

        this.dispatchEvent(
          toastEvent(
            "Endorsed changes successfully!",
            "Please verify all changes are now marked as completed in the change history table.",
            "success",
          ),
        )
        this.dispatchEvent(new CustomEvent("createdendorsement"))
        this.dispatchCloseModalEvent()
      }
    } catch (error) {
      this.loading = false

      console.error(error)

      this.dispatchEvent(
        toastEvent(
          "Changes were not endorsed successfully.",
          "Please come talk with the BMS team for the error.",
          "error",
        ),
      )
    }
  }
}
