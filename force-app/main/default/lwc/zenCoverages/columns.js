import { deductibleTypeDropdownOptions } from "c/shared"

export const quoteColumns = [
  {
    label: "Coverage",
    fieldName: "policy",
    type: "dropdown",
    typeAttributes: {
      rowId: {
        fieldName: "id",
      },
      columnName: "policy",
      options: {
        fieldName: "policyOptions",
      },
      withEmptyOption: true,
      plainText: {
        fieldName: "policyName",
      },
      showTreeIcon: {
        fieldName: "policyShowTreeIcon",
      },
      showTreeEnd: {
        fieldName: "policyShowTreeEnd",
      },
    },
    initialWidth: 200,
  },
  {
    label: "Subcoverage",
    fieldName: "coverage",
    type: "dropdown",
    typeAttributes: {
      rowId: {
        fieldName: "id",
      },
      columnName: "coverage",
      options: {
        fieldName: "coverageOptions",
      },
      withEmptyOption: true,
      plainText: {
        fieldName: "coverageName",
      },
    },
    initialWidth: 210,
  },
  {
    label: "Name",
    fieldName: "name",
    initialWidth: 200,
    editable: true,
  },
  {
    label: "Limit",
    fieldName: "limit",
    type: "editableDropdown",
    typeAttributes: {
      rowId: {
        fieldName: "id",
      },
      columnName: "limit",
      options: {
        fieldName: "limitOptions",
      },
    },
    initialWidth: 100,
  },
  {
    label: "Deductible Type",
    fieldName: "deductibleType",
    type: "dropdown",
    typeAttributes: {
      rowId: {
        fieldName: "id",
      },
      columnName: "deductibleType",
      options: deductibleTypeDropdownOptions,
      withEmptyOption: true,
    },
    initialWidth: 145,
  },
  {
    label: "Deductible",
    fieldName: "deductible",
    type: "number",
    editable: true,
    initialWidth: 120,
  },
  {
    label: "Premium",
    fieldName: "premium",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    editable: true,
    initialWidth: 120,
  },
  {
    label: "Carrier Name",
    fieldName: "carrier",
    type: "dropdown",
    typeAttributes: {
      rowId: {
        fieldName: "id",
      },
      columnName: "carrier",
      options: {
        fieldName: "carrierOptions",
      },
      withEmptyOption: true,
    },
    initialWidth: 200,
  },
  {
    label: "Carrier Fee",
    fieldName: "carrierFee",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    editable: true,
    initialWidth: 120,
  },
  {
    label: "Agency Fee",
    fieldName: "agencyFee",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    editable: true,
    initialWidth: 120,
  },
]

export const policyColumns = [
  {
    label: "Coverage",
    fieldName: "policy",
    type: "dropdown",
    typeAttributes: {
      rowId: {
        fieldName: "id",
      },
      columnName: "policy",
      options: {
        fieldName: "policyOptions",
      },
      withEmptyOption: true,
      plainText: {
        fieldName: "policyName",
      },
      showTreeIcon: {
        fieldName: "policyShowTreeIcon",
      },
      showTreeEnd: {
        fieldName: "policyShowTreeEnd",
      },
    },
    initialWidth: 180,
  },
  {
    label: "Subcoverage",
    fieldName: "coverage",
    type: "dropdown",
    typeAttributes: {
      rowId: {
        fieldName: "id",
      },
      columnName: "coverage",
      options: {
        fieldName: "coverageOptions",
      },
      withEmptyOption: true,
      plainText: {
        fieldName: "coverageName",
      },
    },
    initialWidth: 210,
  },
  {
    label: "Name",
    fieldName: "name",
    initialWidth: 200,
    editable: true,
  },
  {
    label: "Limit",
    fieldName: "limit",
    type: "editableDropdown",
    typeAttributes: {
      rowId: {
        fieldName: "id",
      },
      columnName: "limit",
      options: {
        fieldName: "limitOptions",
      },
    },
    initialWidth: 100,
  },
  {
    label: "Deductible Type",
    fieldName: "deductibleType",
    type: "dropdown",
    typeAttributes: {
      rowId: {
        fieldName: "id",
      },
      columnName: "deductibleType",
      options: deductibleTypeDropdownOptions,
      withEmptyOption: true,
    },
    initialWidth: 145,
  },
  {
    label: "Deductible",
    fieldName: "deductible",
    type: "number",
    editable: true,
    initialWidth: 120,
  },
  {
    label: "Paid Premium",
    fieldName: "premium",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    editable: true,
    initialWidth: 150,
  },
  {
    label: "12-Month Premium",
    fieldName: "12MonthPremium",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    editable: true,
    initialWidth: 175,
  },
  {
    label: "Carrier Name",
    fieldName: "carrier",
    type: "dropdown",
    typeAttributes: {
      rowId: {
        fieldName: "id",
      },
      columnName: "carrier",
      options: {
        fieldName: "carrierOptions",
      },
      withEmptyOption: true,
    },
    initialWidth: 200,
  },
  {
    label: "Paid Carrier Fee",
    fieldName: "carrierFee",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    editable: true,
    initialWidth: 150,
  },
  {
    label: "12-Month Carrier Fee",
    fieldName: "12MonthCarrierFee",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    editable: true,
    initialWidth: 175,
  },
  {
    label: "Paid Agency Fee",
    fieldName: "agencyFee",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    editable: true,
    initialWidth: 150,
  },
  {
    label: "12-Month Agency Fee",
    fieldName: "12MonthAgencyFee",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    editable: true,
    initialWidth: 175,
  },
]

export const quoteReadOnlyColumns = [
  {
    label: "Coverage",
    fieldName: "policyName",
    type: "readOnlyTreeIcon",
    typeAttributes: {
      showTreeIcon: {
        fieldName: "policyShowTreeIcon",
      },
      showTreeEnd: {
        fieldName: "policyShowTreeEnd",
      },
    },
    initialWidth: 180,
  },
  {
    label: "Subcoverage",
    fieldName: "coverageName",
    initialWidth: 210,
  },
  {
    label: "Name",
    fieldName: "name",
    initialWidth: 200,
  },
  {
    label: "Limit",
    fieldName: "limit",
    initialWidth: 100,
  },
  {
    label: "Deductible Type",
    fieldName: "deductibleTypeLabel",
    initialWidth: 145,
  },
  {
    label: "Deductible",
    fieldName: "deductible",
    type: "number",
    initialWidth: 120,
  },
  {
    label: "Premium",
    fieldName: "premium",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    initialWidth: 120,
  },
  {
    label: "Carrier Name",
    fieldName: "carrierName",
    initialWidth: 150,
  },
  {
    label: "Carrier Fee",
    fieldName: "carrierFee",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    initialWidth: 120,
  },
  {
    label: "Agency Fee",
    fieldName: "agencyFee",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    initialWidth: 120,
  },
]

export const policyReadOnlyColumns = [
  {
    label: "Coverage",
    fieldName: "policyName",
    type: "readOnlyTreeIcon",
    typeAttributes: {
      showTreeIcon: {
        fieldName: "policyShowTreeIcon",
      },
      showTreeEnd: {
        fieldName: "policyShowTreeEnd",
      },
    },
    initialWidth: 180,
  },
  {
    label: "Subcoverage",
    fieldName: "coverageName",
    initialWidth: 210,
  },
  {
    label: "Name",
    fieldName: "name",
    initialWidth: 200,
  },
  {
    label: "Limit",
    fieldName: "limit",
    initialWidth: 100,
  },
  {
    label: "Deductible Type",
    fieldName: "deductibleTypeLabel",
    initialWidth: 145,
  },
  {
    label: "Deductible",
    fieldName: "deductible",
    type: "number",
    initialWidth: 120,
  },
  {
    label: "Paid Premium",
    fieldName: "premium",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    initialWidth: 150,
  },
  {
    label: "12 Month Premium",
    fieldName: "12MonthPremium",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    initialWidth: 175,
  },
  {
    label: "Carrier Name",
    fieldName: "carrierName",
    initialWidth: 200,
  },
  {
    label: "Paid Carrier Fee",
    fieldName: "carrierFee",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    initialWidth: 150,
  },
  {
    label: "12 Month Carrier Fee",
    fieldName: "12MonthCarrierFee",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    initialWidth: 175,
  },
  {
    label: "Paid Agency Fee",
    fieldName: "agencyFee",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    initialWidth: 150,
  },
  {
    label: "12 Month Agency Fee",
    fieldName: "12MonthAgencyFee",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    initialWidth: 175,
  },
]
