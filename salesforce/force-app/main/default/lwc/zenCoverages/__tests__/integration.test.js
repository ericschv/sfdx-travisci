import { createElement } from "lwc"
import zenCoverages from "c/zenCoverages"
import { registerApexTestWireAdapter } from "@salesforce/lwc-jest"
import getQuoteCoverages from "@salesforce/apex/QuoteCoverages.getQuoteCoverages"
import upsertQuoteCoverages from "@salesforce/apex/QuoteCoverages.upsertQuoteCoverages"
import deleteQuoteCoverages from "@salesforce/apex/QuoteCoverages.deleteQuoteCoverages"
import getCarriers from "@salesforce/apex/Carriers.getCarriers"

const getQuoteCoveragesData = require("./data/getQuoteCoverages.json")
const getQuoteCoveragesAdapter = registerApexTestWireAdapter(getQuoteCoverages)

describe("c-zen-coverages", () => {
  function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise((resolve) => setImmediate(resolve))
  }

  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild)
    }
  })

  it("should render a row per fetched coverage", () => {
    const element = createElement("c-zen-coverages", {
      is: zenCoverages,
    })
    document.body.appendChild(element)
    getQuoteCoveragesAdapter.emit(getQuoteCoveragesData)

    return flushPromises().then(() => {
      const customDatatable = element.shadowRoot.querySelector(
        "c-custom-datatable",
      )

      console.log(
        customDatatable.shadowRoot.querySelector("c-carrier-dropdown"),
      )
    })
  })

  xit("should allow adding a coverage", () => {})

  xit("should allow deleting one or more coverages", () => {})

  xit("should save changes made to cells and render them immediatly", () => {})

  xit("should allow cancelling changes if they havent been saved yet, rendering back to the previous values", () => {})
})
