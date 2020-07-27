import { sortBy } from "c/shared"

function formatToNumber(limit) {
  let returnLimit
  const returnValue = typeof limit === "string" ? limit.toLowerCase() : limit
  if (typeof limit === "string") {
    returnLimit = parseInt(limit.replace(/(?:\$|CA\$|,)/g, ""))
  }
  return returnLimit || returnValue
}

// adds commas to separate thousands
function formatToString(limit) {
  if (typeof limit !== "string") {
    console.log("Coverage Limit should be of type \"string\".")
    return null
  }

  const limitNumber = formatToNumber(limit)

  // leave limit unchanged if it's not numeric
  return typeof limitNumber === "number"
    ? limitNumber.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    : limit
}

// This will sort all numbers and number string in descending order of value, and put them at the top, below that follows "included",
// after that anything string input thats not a numbers, and at the very last it will put any excluded coverages, as well as ones without a limit.
const limitCompare = (a, b) => {
  const limitValueA = a.limit
  const limitValueB = b.limit

  if (!limitValueA && limitValueB) return 1
  if (limitValueA && !limitValueB) return -1
  if (!limitValueA && !limitValueB) return 0

  const limitA = formatToNumber(limitValueA)
  const limitB = formatToNumber(limitValueB)

  const aType = typeof limitA
  const bType = typeof limitB

  let returnValue = 0

  if (aType === "number" && bType === "number") {
    if (limitA > limitB) returnValue = -1
    else if (limitA < limitB) returnValue = 1
  }

  if (aType === "number" && bType === "string") returnValue = -1
  else if (aType === "string" && bType === "number") returnValue = 1

  if (aType === "string" && bType === "string") {
    if (limitB === "excluded") returnValue = -1
    else if (limitA === "excluded" && limitB !== "excluded") returnValue = 1
  }
  return returnValue
}

function onlyUnique(value, index, self) {
  return self.indexOf(value) === index
}

// This function will sort display data by the following: it will first group by policy label and then by limit.
export function sortAndFormatCoverages(coveragesArray) {
  const sortedByName = sortBy(coveragesArray, "policyName")

  const sortedUniquePolicyLabels = sortedByName
    .map((coverage) => coverage.policyName)
    .filter(onlyUnique)

  const sortedCoverages = []

  for (const policyLabel of sortedUniquePolicyLabels) {
    const coverages = coveragesArray.filter(
      (coverage) => coverage.policyName === policyLabel,
    )
    const sortedByLimit = coverages.slice().sort(limitCompare)

    // only show the first coverage name of each group
    for (let i = 1; i < sortedByLimit.length; i++) {
      sortedByLimit[i].policyShowTreeIcon = true
    }
    sortedByLimit[sortedByLimit.length - 1].policyShowTreeEnd = true

    sortedCoverages.push(...sortedByLimit)
  }

  for (const coverage of sortedCoverages) {
    coverage.limit = formatToString(coverage.limit)
  }

  return sortedCoverages
}

export function getLimitOptions({
  policies = [],
  policyId,
  coverageId,
  coverageType,
}) {
  const defaultLimitOptions = [
    {
      value: "Excluded",
      label: "Excluded",
    },
  ]

  const matchedPolicy = policies.find((policy) => policy.id === policyId)

  const matchedCoverage = matchedPolicy
    ? matchedPolicy.coverages.find((coverage) => {
        if (coverageId) {
          return coverage.id === coverageId
        } else if (coverageType) {
          return coverage.type === coverageType
        }

        return false
      })
    : null

  const limitOptionsExist =
    matchedCoverage &&
    Array.isArray(matchedCoverage.options) &&
    matchedCoverage.options.length

  const coverageLimitOptions = limitOptionsExist
    ? matchedCoverage.options.map((option) => ({
        value: option.limitValue,
        label: option.limitValue,
      }))
    : [
        {
          value: "Included",
          label: "Included",
        },
      ]

  return [...defaultLimitOptions, ...coverageLimitOptions]
}
