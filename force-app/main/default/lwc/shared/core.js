export function isValidJSON(value) {
  try {
    const parsedValue = JSON.parse(value)

    return typeof parsedValue === "object" && parsedValue !== null
  } catch (error) {
    return false
  }
}

export function generateRandomId() {
  return (
    Math.random()
      .toString(36)
      .substring(2, 15) +
    Math.random()
      .toString(36)
      .substring(2, 15)
  )
}

export function isTemporaryId(id) {
  return /^temp\-[^]*/.test(id)
}

/**
 * Sort a collection by an attribute in ASCE order
 * @param {Array} collection
 * @param {string} attribute
 * @returns {Array} sorted array
 */
export function sortBy(collection, attribute) {
  return collection.sort((x, y) => (x[attribute] < y[attribute] ? -1 : 1))
}

/**
 * Convert camel case to title case (e.g forExample => For Example)
 * @param {*} str
 */
export function camelCaseToTitleCase(str) {
  if (typeof str === "string") {
    return str
      .replace(/([A-Z][a-z])/g, " $1")
      .replace(/^./, function(firstChar) {
        return firstChar.toUpperCase()
      })
  }

  return str
}

/**
 * Format date string.
 * @param {Object} date - The date to format.
 * @param {string} date.value - The string value of the date.
 * @param {boolean} date.onlyDate - The boolean flag to determine if it should only return date.
 */
export function formatDate({ value, onlyDate = false }) {
  if (value) {
    const date = new Date(value)

    if (onlyDate) {
      // If only date is needed, return the date without converting the time to local time
      return date.toLocaleDateString("en-US", { timeZone: "UTC" })
    } else {
      return date.toLocaleString()
    }
  }

  return value
}

export const deductibleTypeDropdownOptions = [
  {
    value: "FL", // NOTE: We are using FL for currency to support legacy records
    label: "$",
  },
  {
    value: "PT", // NOTE: We are using PT for percentage to support legacy records
    label: "%",
  },
  {
    value: "hours",
    label: "Hours",
  },
]

export function getDeductibleTypeLabel(code) {
  const deductibleTypeOption = deductibleTypeDropdownOptions.find(
    (option) => option.value === code,
  )

  if (deductibleTypeOption) {
    return deductibleTypeOption.label
  }
}
