import { LightningElement, api } from "lwc"

export default class RenewalQuotePolicyEndorsementList extends LightningElement {
  @api endorsements

  get hasEndorsements() {
    return !!this.endorsements.length
  }
}
