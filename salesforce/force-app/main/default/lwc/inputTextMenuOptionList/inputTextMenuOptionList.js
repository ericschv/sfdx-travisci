import { LightningElement, api } from "lwc"

export default class InputTextMenuOptionList extends LightningElement {
  @api listId
  @api items

  renderedCallback() {
    this.template.querySelector("datalist").id = this.listId
  }
}
