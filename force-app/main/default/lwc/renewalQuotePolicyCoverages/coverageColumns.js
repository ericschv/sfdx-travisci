export const coverageColumns = [
  { label: "Coverage", fieldName: "API_Policy_Name__c", initialWidth: 210 },
  {
    label: "Subcoverage",
    fieldName: "API_Coverage_Name__c",
    initialWidth: 210,
  },
  { label: "Limit", fieldName: "Zen_Limit__c", initialWidth: 125 },
  {
    label: "Deductible Type",
    fieldName: "CanaryAMS__Deductible_Type_Code__c",
    initialWidth: 145,
  },
  { label: "Deductible", fieldName: "Zen_Deductible__c", initialWidth: 120 },
  {
    label: "Paid Premium",
    fieldName: "CanaryAMS__Current_Term_Amount__c",
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
    fieldName: "Zen_12_Month_Premium__c",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    initialWidth: 175,
  },
  { label: "Carrier", fieldName: "carrierName", initialWidth: 150 },
  {
    label: "Paid Carrier Fee",
    fieldName: "Carrier_Fee__c",
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
    fieldName: "Zen_12_Month_Carrier_Fee__c",
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
    fieldName: "Agency_Fee__c",
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
    fieldName: "Zen_12_Month_Agency_Fee__c",
    type: "number",
    typeAttributes: {
      maximumFractionDigits: 2,
      minimumFractionDigits: 2,
    },
    cellAttributes: { alignment: "left" },
    initialWidth: 175,
  },
]
