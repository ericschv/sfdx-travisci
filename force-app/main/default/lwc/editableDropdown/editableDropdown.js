import { LightningElement, api, track } from "lwc"
import { cellChangeEvent } from "c/shared"

export default class EditableDropdown extends LightningElement {
  @track _value = ""

  @api rowId
  @api columnName
  @api options
  @api
  get value() {
    return this._value
  }
  set value(val) {
    switch (typeof val) {
      case "string":
        this._value = val
        break
      case "number":
        this._value = val.toString()
        break
      default:
        this._value = ""
    }
  }

  handleInputChange(event) {
    event.stopPropagation()

    const { id, value } = event.detail

    const changeEvent = cellChangeEvent(id, this.columnName, value)

    this.dispatchEvent(changeEvent)
  }
}
