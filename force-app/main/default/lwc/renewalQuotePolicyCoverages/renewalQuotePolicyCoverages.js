import { LightningElement, api, track } from "lwc"
import { coverageColumns } from "./coverageColumns"

export default class RenewalQuotePolicyCoverages extends LightningElement {
  @api coverages
  @track coverageColumns = coverageColumns

  get hasCoverages() {
    return !!this.coverages.length
  }
}
