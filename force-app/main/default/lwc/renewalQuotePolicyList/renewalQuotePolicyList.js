import { LightningElement, api } from "lwc"

export default class RenewalQuotePolicyList extends LightningElement {
  @api policies

  get hasPolicies() {
    if (this.policies) {
      return !!this.policies.length
    } else return false
  }
}
