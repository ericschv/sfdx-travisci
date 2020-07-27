import { LightningElement, api } from "lwc"

import "./tableReadOnlyTreeIcon.css"

export default class TableReadOnlyTreeIcon extends LightningElement {
  @api showTreeIcon
  @api showTreeEnd
  @api selectedValue
}
