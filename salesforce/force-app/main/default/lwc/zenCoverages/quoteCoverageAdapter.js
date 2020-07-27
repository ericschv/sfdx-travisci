// Fields are Salesforce Object Fields coming from Apex controllers
// Props are the names we use in the Salesforce Lightning Web Component UI

import { OBJECT_API_NAMES } from "./config.js"
import { getLimitOptions } from "./utils"

import { isTemporaryId, getDeductibleTypeLabel } from "c/shared"

const fieldPropMap = {
  Id: "id",
  Name: "name",
  CanaryAMS__Current_Term_Amount__c: "premium",
  Zen_12_Month_Premium__c: "12MonthPremium",
  Agency_Fee__c: "agencyFee",
  Zen_12_Month_Agency_Fee__c: "12MonthAgencyFee",
  Carrier_Fee__c: "carrierFee",
  Zen_12_Month_Carrier_Fee__c: "12MonthCarrierFee",
  Zen_Deductible__c: "deductible",
}

// Saving Coverages to Salesforce
export function propsToFields(draftRow, recordId, objectApiName, settings) {
  const { availablePolicies } = settings
  const coverage = {}

  // NOTE: If it's temporary row (AKA a new record), add Quote ID
  if (
    isTemporaryId(draftRow["id"]) &&
    objectApiName === OBJECT_API_NAMES.QUOTE
  ) {
    coverage["CanaryAMS__Insurance_Product__c"] = recordId
  } else if (
    isTemporaryId(draftRow["id"]) &&
    objectApiName === OBJECT_API_NAMES.POLICY
  ) {
    coverage["CanaryAMS__Policy__c"] = recordId
  } else {
    coverage["Id"] = draftRow["id"]
  }

  const filteredAvailablePolicies = availablePolicies.filter(
    (aPolicy) => aPolicy.id === draftRow["policy"],
  )

  if (filteredAvailablePolicies.length === 1) {
    const {
      availability: policyAvailability,
      type: policyType,
      name: policyName,
      id: policyId,
    } = filteredAvailablePolicies[0]

    coverage["API_Policy_Id__c"] = policyId
    coverage["API_Policy_Initial_Availability__c"] = policyAvailability
    coverage["API_Policy_Name__c"] = policyName
    coverage["API_Policy_Slug__c"] = policyType

    const filteredCoverages = filteredAvailablePolicies[0].coverages.filter(
      (coverage) => coverage.id === draftRow["coverage"],
    )

    if (filteredCoverages.length === 1) {
      const {
        availability: coverageAvailability,
        type: coverageType,
        name: coverageName,
        id: coverageId,
      } = filteredCoverages[0]
      coverage["API_Coverage_Slug__c"] = coverageType
      coverage["API_Coverage_Initial_Availability__c"] = coverageAvailability
      coverage["API_Coverage_Name__c"] = coverageName

      // Ignore Temp Ids
      if (!/^temp\-/.test(coverageId)) {
        coverage["API_Coverage_Id__c"] = coverageId
      }
    }
  }

  if (coverage["API_Policy_Name__c"] && coverage["API_Coverage_Name__c"]) {
    const label = `${coverage["API_Policy_Name__c"]}: ${coverage["API_Coverage_Name__c"]}`

    const MAX_CHARS_LABEL = 79

    const trimmedLabel = label.trim().slice(0, MAX_CHARS_LABEL)

    coverage["Name"] = trimmedLabel
  } else {
    coverage["Name"] = draftRow["name"]
  }

  coverage["Zen_Limit__c"] = draftRow["limit"]

  coverage["CanaryAMS__Deductible_Type_Code__c"] = draftRow["deductibleType"]
  coverage["Zen_Deductible__c"] = draftRow["deductible"]
  coverage["CanaryAMS__Current_Term_Amount__c"] = draftRow["premium"]
  coverage["Zen_12_Month_Premium__c"] = draftRow["12MonthPremium"]
  coverage["Carrier__c"] = draftRow["carrier"]
  coverage["Agency_Fee__c"] = draftRow["agencyFee"]
  coverage["Zen_12_Month_Agency_Fee__c"] = draftRow["12MonthAgencyFee"]
  coverage["Carrier_Fee__c"] = draftRow["carrierFee"]
  coverage["Zen_12_Month_Carrier_Fee__c"] = draftRow["12MonthCarrierFee"]

  return coverage
}

// Converting fields to props that are coming from salesforce
export function fieldsToProps(coverage, settings) {
  const { availablePolicies } = settings
  const mappedProps = {}

  mappedProps["policy"] = coverage["API_Policy_Id__c"]
  mappedProps["policyName"] = coverage["API_Policy_Name__c"]

  mappedProps["coverage"] = coverage["API_Coverage_Id__c"]
  mappedProps["coverageName"] = coverage["API_Coverage_Name__c"] || " "

  mappedProps["limit"] =
    coverage["Zen_Limit__c"] ||
    coverage["CanaryAMS__Limit_Format_Integer__c"] ||
    ""

  mappedProps["limitOptions"] = getLimitOptions({
    policies: availablePolicies,
    policyId: mappedProps.policy,
    coverageType: coverage["API_Coverage_Slug__c"],
  })

  for (const [key, value] of Object.entries(coverage)) {
    if (fieldPropMap[key]) {
      mappedProps[fieldPropMap[key]] = value
    } else if (key === "Carrier__r") {
      mappedProps["carrier"] = value.Id
      mappedProps["carrierName"] = value.Name
    } else if (key === "CanaryAMS__Deductible_Type_Code__c") {
      mappedProps["deductibleType"] = value
      mappedProps["deductibleTypeLabel"] = getDeductibleTypeLabel(value)
    } else if (
      key === "CanaryAMS__Deductible_Format_Integer__c" &&
      !coverage["Zen_Deductible__c"]
    ) {
      mappedProps["deductible"] = value
    }
  }

  return mappedProps
}
