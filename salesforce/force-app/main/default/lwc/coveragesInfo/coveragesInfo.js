import { LightningElement, api, track } from "lwc"

export default class CoveragesInfo extends LightningElement {
  PREMIUM_THRESHOLD = 50000

  @track inputWarnings = []

  @api
  get coverages() {
    return this._coverages
  }
  set coverages(data) {
    this._coverages = data
    this.handleCoveragesUpdate(data)
  }

  handleCoveragesUpdate(coverages) {
    if (!Array.isArray(coverages)) {
      return
    }

    this.inputWarnings = []

    coverages.forEach((coverage) => {
      if (coverage.premium && coverage.premium >= this.PREMIUM_THRESHOLD) {
        let warning = `The premium seems too high for "${coverage.policy} - ${coverage.coverage}"`

        if (coverage.carrier) {
          warning += ` with ${coverage.carrier}.`
        } else {
          warning += `.`
        }

        this.inputWarnings.push(warning)
      }
    })
  }
}
