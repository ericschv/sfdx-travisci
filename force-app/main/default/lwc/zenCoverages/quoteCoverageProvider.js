import upsertQuoteCoverages from "@salesforce/apex/QuoteCoverages.upsertQuoteCoverages"
import { propsToFields } from "./quoteCoverageAdapter"

export async function persistQuoteCoverages(
  draftCoverages,
  recordId,
  objectApiName,
  settings,
) {
  const coverages = draftCoverages.map((draftRow) =>
    propsToFields(draftRow, recordId, objectApiName, settings),
  )

  try {
    await upsertQuoteCoverages({ editedCoverageList: coverages })
  } catch (error) {
    console.error("Failed to upsert quote coverages", error)
  }
}

export async function updateRawQuoteCoverages(rawCoverages) {
  try {
    await upsertQuoteCoverages({ editedCoverageList: rawCoverages })
  } catch (error) {
    console.error("Failed to upsert raw quote coverages", error)
  }
}
