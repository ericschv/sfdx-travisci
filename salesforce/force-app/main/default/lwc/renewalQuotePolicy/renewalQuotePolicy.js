import { LightningElement, api, track } from "lwc"

export default class RenewalQuotePolicy extends LightningElement {
  @api coverages
  @api endorsements
  @api claims
  @api policy

  get coveragesLabel() {
    return "Coverages (" + this.coverages.length + ")"
  }

  get endorsementsLabel() {
    return "Endorsements (" + this.endorsements.length + ")"
  }

  get claimsLabel() {
    return "Claims (" + this.claims.length + ")"
  }
}
