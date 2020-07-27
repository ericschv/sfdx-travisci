import { ShowToastEvent } from "lightning/platformShowToastEvent"

export function customEvent(eventName, detail) {
  return new CustomEvent(eventName, {
    composed: true,
    bubbles: true,
    detail,
  })
}

export function cellChangeEvent(rowId, columnName, value) {
  return customEvent("cellchange", {
    draftValues: [
      {
        id: rowId,
        [columnName]: value,
      },
    ],
  })
}

// Valid variants: "success", "warning", "error", "info"
export function toastEvent(title, message, variant = "info") {
  return new ShowToastEvent({
    title,
    message,
    variant,
  })
}

export function tableDropdownChangeEvent({
  rowId,
  columnName,
  selectedValue,
  selectedLabel,
}) {
  return customEvent("tabledropdownchange", {
    rowId,
    columnName,
    selectedValue,
    selectedLabel,
  })
}

/**
 * Given table data (e.g. draft values or display data) and updates, clone the table data,
 * apply the updates and return the updated table data.
 *
 * @param {*} draftValues
 * @param {*} updates - Array of updates in the format of { rowId, columnName, value }
 * @returns {*} updatedTableData - Updated table data
 */
export function updateTableData(tableData, updates) {
  const updatedTableData = [...tableData]

  updates.forEach(({ rowId, columnName, value }) => {
    const foundDraftValue = updatedTableData.find(
      (draftValue) => draftValue.id === rowId,
    )

    if (foundDraftValue) {
      foundDraftValue[columnName] = value
    } else {
      updatedTableData.push({
        id: rowId,
        [columnName]: value,
      })
    }
  })

  return updatedTableData
}

export function updateDraftValuesWithDropdownChangeEvent(draftValues, event) {
  const { rowId, columnName, selectedValue } = event.detail

  return updateTableData(draftValues, [
    { rowId, columnName, value: selectedValue },
  ])
}

export function updateDraftValuesWithCellChangeEvent(draftValues, event) {
  const [draftChange] = event.detail.draftValues
  const draftRows = [...draftValues]

  const foundDraftRow = draftRows.find(
    (draftRow) => draftRow.id === draftChange.id,
  )

  if (foundDraftRow) {
    Object.assign(foundDraftRow, draftChange)
  } else {
    draftRows.push(draftChange)
  }

  return draftRows
}
