import { LightningElement, api, track } from "lwc"
import { tableDropdownChangeEvent, sortBy } from "c/shared"

import "./tableDropdown.css"

export default class TableDropdown extends LightningElement {
  @track optionData = []

  @api rowId
  @api columnName
  @api plainText
  @api showTreeIcon
  @api showTreeEnd
  @api
  get options() {
    return this._options
  }
  set options(options) {
    this._options = options
    this.optionData = this.getOptionData()
  }
  @api
  get selectedValue() {
    return this._selectedValue
  }
  set selectedValue(val) {
    this._selectedValue = val
    this.optionData = this.getOptionData()
  }
  @api
  get withEmptyOption() {
    return this._withEmptyOption
  }
  set withEmptyOption(val) {
    this._withEmptyOption = val
    this.optionData = this.getOptionData()
  }

  getOptionData() {
    let options = Array.isArray(this.options)
      ? this.options.map((option) => {
          return {
            ...option,
            isSelected: option.value === this.selectedValue,
          }
        })
      : []

    options = sortBy(options, "label")

    return this.withEmptyOption ? [{}, ...options] : options
  }

  handleSelect(e) {
    const selectedValue = e.target.value
    const selectedOption = this.optionData.find(
      (option) => option.value === selectedValue,
    )

    const changeEvent = tableDropdownChangeEvent({
      rowId: this.rowId,
      columnName: this.columnName,
      selectedValue,
      selectedLabel: selectedOption ? selectedOption.label : "",
    })

    this.dispatchEvent(changeEvent)
  }
}
