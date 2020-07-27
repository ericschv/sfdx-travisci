import { validate } from "c/shared"

const validBillingTypes = [
  "Direct One-Pay",
  "Direct Financed",
  "Zen One-Pay - Credit Card",
  "Zen One-Pay - e-Transfer",
  "Zen One-Pay - Cheque",
  "Zen Financed",
  "Zen Financed - Credit Card",
  "Zen Financed - Bank Account",
]

// Validation configuration objects
export const quoteValidations = {
  producer: {
    notEmpty: `"Producer" cannot be empty.`,
  },
  billingType: {
    notEmpty: `"Payment Status" cannot be empty.`,
    notInvalidType: `"Payment Status" must be one of the following: ${validBillingTypes
      .map((billingType) => `"${billingType}"`)
      .join(", ")}`,
  },
  effectiveDate: {
    notEmpty: `"Effective Date" cannot be empty.`,
  },
  term: {
    notEmpty: `"Term" cannot be empty.`,
  },
  expirationDate: {
    notEmpty: `"Expiration Date" cannot be empty.`,
  },
}

export const groupedPolicyValidations = {
  carrierId: {
    notEmpty: `"Carrier" cannot be empty. Select a "Carrier" in the Coverages tab.`,
  },
  coverages: { notEmpty: `A policy must have at least one coverage.` },
  premium: {
    notEmpty: `"Premium" cannot be empty.`,
    greaterThanZero: `The total "Premium" must be greater than $0 (zero).`,
  },
  policyNumber: { notEmpty: `"Policy Number" cannot be empty.` },
  recordType: { notEmpty: `"Record Type" cannot be empty.` },
  carrierProduct: { notEmpty: `"Carrier Product" cannot be empty.` },
}

// Custom validators to extend core functionality
export function quoteValidators() {
  const notInvalidType = (value) => validBillingTypes.includes(value)

  return { notInvalidType }
}

// Validation utilities invoking underlying `validate` function
// from core validation lib
export function validateQuote(quote) {
  return validate({ ...quote }, quoteValidations, quoteValidators())
}

export function validateGroupedPolicies(groupedPolicies) {
  let doesErrorExist = false
  const policies = JSON.parse(JSON.stringify(groupedPolicies))

  const policiesWithErrors = policies.map((policy) => {
    const errors = validate(policy, groupedPolicyValidations)

    if (errors.length > 0) {
      doesErrorExist = true
    }

    return {
      ...policy,
      errors,
    }
  })

  return {
    doesErrorExist,
    policiesWithErrors,
  }
}
