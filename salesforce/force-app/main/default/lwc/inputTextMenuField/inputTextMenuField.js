import { LightningElement, api } from "lwc"

import { customEvent } from "c/shared"

export default class InputTextMenuField extends LightningElement {
  @api placeholder
  @api value
  @api listId

  handleInput() {
    this.dispatchEvent(
      customEvent("change", {
        value: this.template.querySelector("input").value,
      }),
    )
  }

  handleFocus() {
    this.dispatchEvent(
      customEvent("focus", {
        value: this.value,
      }),
    )
  }

  handleBlur() {
    this.dispatchEvent(
      customEvent("blur", {
        value: this.value,
      }),
    )
  }
}
