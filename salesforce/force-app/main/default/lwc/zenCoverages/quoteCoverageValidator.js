// NOTE: This validator structure is necessary because there can be differences between draft rows
// and cached rows, and sometimes one will be filled in while the other isn't.
const validators = {
  coverage: {
    cacheField: "coverageName",
    draftField: "coverage",
    errorMessage:
      "You must select a valid Subcoverage for each row in the table.",
  },
  policy: {
    cacheField: "policy",
    draftField: "policy",
    errorMessage: "You must select a valid Coverage for each row in the table.",
  },
}

function validateDraftRow(draftRow, cachedRow) {
  for (const key of Object.keys(validators)) {
    if (
      !cachedRow[validators[key].cacheField] &&
      !draftRow[validators[key].draftField]
    ) {
      throw validators[key].errorMessage
    }
  }
}

export function validateDraftValues(draftCoverages, cachedCoverages) {
  draftCoverages.map((draftRow) => {
    const cachedRow = cachedCoverages.find(
      (cachedCoverage) => cachedCoverage.id == draftRow.id,
    )
    validateDraftRow(draftRow, cachedRow)
  })
}
