export const columns = [
  {
    fieldName: "tableIndex",
    type: "text",
    initialWidth: 30,
  },
  {
    label: "Action",
    fieldName: "action",
    type: "text",
  },
  {
    label: "Operation",
    fieldName: "operation",
    type: "text",
  },
  {
    label: "Record Type",
    fieldName: "recordType",
    type: "text",
  },
  {
    label: "Record",
    fieldName: "recordLink",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "recordName",
      },
      target: "_blank",
    },
  },
  {
    label: "Field",
    fieldName: "field",
    type: "text",
  },
  {
    label: "Old Value",
    fieldName: "oldValue",
    type: "text",
  },
  {
    label: "New Value",
    fieldName: "newValue",
    type: "text",
  },
  {
    label: "Status",
    fieldName: "selectedStatus",
    type: "dropdown",
    typeAttributes: {
      rowId: {
        fieldName: "rowId",
      },
      columnName: "selectedStatus",
      options: [
        {
          label: "Pending",
          value: "pending",
        },
        {
          label: "Ignored",
          value: "ignored",
        },
      ],
      plainText: {
        fieldName: "statusPlainText",
      },
    },
  },
  {
    label: "Created At",
    fieldName: "createdAt",
    type: "text",
  },
]

export const readOnlyColumns = [
  {
    fieldName: "tableIndex",
    type: "text",
    initialWidth: 30,
  },
  {
    label: "Action",
    fieldName: "action",
    type: "text",
  },
  {
    label: "Operation",
    fieldName: "operation",
    type: "text",
  },
  {
    label: "Record Type",
    fieldName: "recordType",
    type: "text",
  },
  {
    label: "Record",
    fieldName: "recordLink",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "recordName",
      },
      target: "_blank",
    },
  },
  {
    label: "Field",
    fieldName: "field",
    type: "text",
  },
  {
    label: "Old Value",
    fieldName: "oldValue",
    type: "text",
  },
  {
    label: "New Value",
    fieldName: "newValue",
    type: "text",
  },
  {
    label: "Status",
    fieldName: "statusLabel",
    type: "text",
  },
  {
    label: "Created At",
    fieldName: "createdAt",
    type: "text",
  },
]
