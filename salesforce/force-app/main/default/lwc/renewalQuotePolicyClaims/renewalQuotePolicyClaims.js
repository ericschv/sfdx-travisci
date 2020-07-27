import { LightningElement, api } from "lwc"

export default class RenewalQuotePolicyClaims extends LightningElement {
  @api claims

  get hasClaims() {
    return !!this.claims.length
  }
}
