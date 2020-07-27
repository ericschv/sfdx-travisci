function notEmpty(value) {
  return (
    // NOTE: `Number.isFinite` also covers `NaN`
    (typeof value === "number" && Number.isFinite(value)) ||
    (typeof value === "string" && value.length) ||
    (Array.isArray(value) && value.length) ||
    (typeof value === "object" && value !== null && Object.keys(value).length)
  )
}

function notNone(value) {
  const normalizedValue = ((typeof value === "string" && value) || "")
    .toLowerCase()
    .trim()
    .replace(/\-+/gm, "")

  return (
    typeof normalizedValue === "string" &&
    normalizedValue.length &&
    normalizedValue !== "none"
  )
}

function greaterThanZero(value) {
  return typeof value === "number" && value > 0
}

// NOTE: you must add validators below before you can reference them
const coreValidators = {
  notEmpty,
  greaterThanZero,
  notNone,
}

/**
 * @param {*} obj Object to validate
 * @param {*} validations Validation rules for values in object
 * @returns {Array} Array of error messages
 */
export function validate(obj, validations, extraValidators) {
  const errors = []

  const validators = {
    ...coreValidators,
    ...(notEmpty(extraValidators) ? extraValidators : {}),
  }

  for (const [prop, validation] of Object.entries(validations)) {
    const value = obj[prop]

    for (const [validatorName, errorMessage] of Object.entries(validation)) {
      if (!validators[validatorName](value)) errors.push(errorMessage)
    }
  }

  return errors
}
