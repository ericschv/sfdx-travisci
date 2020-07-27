/* myDatatable.js */
import LightningDatatable from "lightning/datatable"
import dropdown from "./dropdown.html"
import editableDropdown from "./editableDropdown"
import readOnlyTreeIcon from "./readOnlyTreeIcon"

export default class CustomDatatable extends LightningDatatable {
  // NOTE: custom types used in this datatable subclass
  static customTypes = {
    dropdown: {
      template: dropdown,
      typeAttributes: [
        "rowId",
        "columnName",
        "options",
        "withEmptyOption",
        "plainText",
        "showTreeIcon",
        "showTreeEnd",
      ],
    },
    editableDropdown: {
      template: editableDropdown,
      typeAttributes: ["rowId", "columnName", "options"],
    },
    readOnlyTreeIcon: {
      template: readOnlyTreeIcon,
      typeAttributes: [
        "showTreeIcon",
        "showTreeEnd",
      ],
    }
  }

  handleTableKeydown(event) {
    // NOTE: only proxy to `super` when `event.target` is available
    // This prevents an odd issue related to `input-text-menu` options
    if (event.target) super.handleTableKeydown(event)
  }
}
