import { LightningElement, api } from "lwc"

import { customEvent } from "c/shared"

/** @typedef { import('../../../../../types').InputTextMenuItem } InputTextMenuItem */

export default class InputTextMenu extends LightningElement {
  /**
   * @type {InputTextMenuItem[]}
   */
  @api items = []
  @api inputValue = ""
  @api label
  @api keyId

  @api listId = `textMenuDataList-${Date.now()}`

  handleOptionSelect(event) {
    // NOTE: Prevent propagation to not trigger unintended handlers up in the tree
    event.stopPropagation()

    const { label, value } = event.detail

    this.inputValue = label
  }

  handleInputChange(event) {
    // NOTE: Prevent propagation to not trigger unintended handlers up in the tree
    event.stopPropagation()

    const { value } = event.detail

    this.inputValue = value

    this.dispatchEvent(
      customEvent("inputchange", {
        id: this.keyId,
        value,
      }),
    )
  }

  preventKeydownPropagation(event) {
    event.stopPropagation()
  }

  handleFocus(event) {
    // NOTE: Prevent propagation to not trigger unintended handlers up in the tree
    event.stopPropagation()

    this.addEventListener("keydown", this.preventKeydownPropagation)
  }

  handleBlur(event) {
    // NOTE: Prevent propagation to not trigger unintended handlers up in the tree
    event.stopPropagation()

    this.removeEventListener("keydown", this.preventKeydownPropagation)
  }
}
