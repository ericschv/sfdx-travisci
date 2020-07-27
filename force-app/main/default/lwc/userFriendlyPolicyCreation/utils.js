import { generateRandomId } from "c/shared"

/**
 * Given raw grouped policies, filter out the ones that do not have a carrier,
 * and map only necessary information for the UI. Fields that will not be modified in the UI
 * do not have to be mapped in this method.
 * @param {Array} rawPolicies - raw grouped policies fetched with an apex method
 * @returns {Array} groupedPolicies - grouped policies for UI
 */
export function toGroupedPolicies(rawPolicies) {
  const groupedPolicies = rawPolicies
    .filter(({ carrier }) => carrier)
    .map(
      ({
        policyName,
        carrier,
        carrierFee,
        agencyFee,
        premium,
        coverages,
        carrierProduct,
        policyNumber,
        recordType,
      }) => ({
        id: `${carrier.Id}-${policyName}`,
        policy: policyName,
        carrier: carrier.Name,
        carrierId: carrier.Id,
        policyNumber,
        carrierProduct,
        recordType,
        carrierFee,
        agencyFee,
        premium,
        coverages,
      }),
    )

  return groupedPolicies
}

function sumPremiumAndFees(coverageA, coverageB) {
  return {
    CanaryAMS__Current_Term_Amount__c: coverageB.CanaryAMS__Current_Term_Amount__c
      ? coverageA.CanaryAMS__Current_Term_Amount__c +
        coverageB.CanaryAMS__Current_Term_Amount__c
      : coverageA.CanaryAMS__Current_Term_Amount__c,
    Agency_Fee__c: coverageB.Agency_Fee__c
      ? coverageA.Agency_Fee__c + coverageB.Agency_Fee__c
      : coverageA.Agency_Fee__c,
    Carrier_Fee__c: coverageB.Carrier_Fee__c
      ? coverageA.Carrier_Fee__c + coverageB.Carrier_Fee__c
      : coverageA.Carrier_Fee__c,
  }
}

export function updatePolicyPremiumAndFees(policies) {
  const recalculatedPolicies = policies.map((policy) => {
    const originalPremiumAndFees = {
      CanaryAMS__Current_Term_Amount__c: 0,
      Agency_Fee__c: 0,
      Carrier_Fee__c: 0,
    }

    if (policy.coverages.length) {
      const totalPremium = policy.coverages.reduce(
        sumPremiumAndFees,
        originalPremiumAndFees,
      )

      policy.premium = totalPremium.CanaryAMS__Current_Term_Amount__c
      policy.agencyFee = totalPremium.Agency_Fee__c
      policy.carrierFee = totalPremium.Carrier_Fee__c
    } else {
      policy.premium = originalPremiumAndFees.CanaryAMS__Current_Term_Amount__c
      policy.agencyFee = originalPremiumAndFees.Agency_Fee__c
      policy.carrierFee = originalPremiumAndFees.Carrier_Fee__c
    }

    return policy
  })

  return recalculatedPolicies
}

/**
 * Given a list of policies, assign a random policy number to each policy
 * if it does not have a policy number.
 *
 * @param {Array} policies
 * @returns {Array} policies with default policy number
 */
export function setDefaultPolicyNumber(policies) {
  return policies.map((policy) => {
    let { policyNumber } = policy

    // Set a random policy number if it is null
    if (!policyNumber) {
      policyNumber = `TBD${generateRandomId()}`
    }

    return {
      ...policy,
      policyNumber,
    }
  })
}

/**
 * For each policy, if it does not have a record type
 * find a record type based on a policy name and assign it.
 *
 * @param {Array} policies
 * @param {Array} recordTypes
 * @returns {Array} policies with default record type
 */
export function setDefaultRecordType(policies, recordTypes) {
  return policies.map((policy) => {
    const { policy: policyName } = policy

    if (!policy.recordType) {
      const foundRecordType = recordTypes.find((recordType) =>
        policyName.includes(recordType.name.replace(/and/gm, "&")),
      )

      if (foundRecordType) {
        policy.recordType = foundRecordType.id
      }
    }

    return policy
  })
}

/**
 * Merge coverages from fetchedPolicies to groupedPolicies.
 * @param {Array} fetchedPolicies
 * @param {Array} groupedPolicies
 * @returns {Array} merged groupedPolicies
 */
export function mergeFetchedPoliciesToGroupedPolicies(
  fetchedPolicies,
  groupedPolicies,
) {
  // Prepare data to udpate groupedPolicies
  const clonedGroupedPolicies = JSON.parse(JSON.stringify(groupedPolicies))
  const groupedCoverages = flattenPoliciesToCoverages(clonedGroupedPolicies)
  const fetchedCoverages = flattenPoliciesToCoverages(fetchedPolicies)

  const { updatedCoverages } = upsertCoveragesToPolicies(
    fetchedCoverages,
    clonedGroupedPolicies,
  )

  const coveragesToDelete = groupedCoverages.filter(
    (coverage) => !updatedCoverages.includes(coverage.coverage.Id),
  )

  if (coveragesToDelete.length > 0) {
    deleteCoveragesFromPolicies(coveragesToDelete, clonedGroupedPolicies)
  }

  return clonedGroupedPolicies
}

function flattenPoliciesToCoverages(policies) {
  return policies.reduce((coverages, policy) => {
    policy.coverages.forEach((coverage) => {
      coverages.push({
        policy,
        coverage,
      })
    })
    return coverages
  }, [])
}

function upsertCoveragesToPolicies(coverages, policies) {
  const existingCoverages = flattenPoliciesToCoverages(policies)
  const updatedCoverages = []
  const insertedCoverages = []

  coverages.forEach((coverageToUpsert) => {
    const existingCoverage = existingCoverages.find(
      (coverage) => coverage.coverage.Id === coverageToUpsert.coverage.Id,
    )

    const hasCoverageCarrierChanged =
      existingCoverage &&
      existingCoverage.coverage.Carrier__c !==
        coverageToUpsert.coverage.Carrier__c

    if (existingCoverage && !hasCoverageCarrierChanged) {
      // UPDATE existing coverage data with fetched data
      Object.assign(existingCoverage.coverage, coverageToUpsert.coverage)
      updatedCoverages.push(existingCoverage.coverage.Id)
    } else {
      // INSERT a coverage into an appropriate policy.
      const foundPolicy = policies.find(
        (policy) => policy.id === coverageToUpsert.policy.id,
      )

      // If a policy was found, add the coverage to it.
      // If not, create one.
      if (foundPolicy) {
        foundPolicy.coverages.push(coverageToUpsert.coverage)
      } else {
        const newPolicy = coverageToUpsert.policy
        newPolicy.coverages = [coverageToUpsert.coverage]
        policies.push(newPolicy)
      }

      insertedCoverages.push(coverageToUpsert.coverage.Id)
    }
  })

  return {
    updatedCoverages,
    insertedCoverages,
  }
}

function deleteCoveragesFromPolicies(coverages, policies) {
  coverages.forEach((coverageToDelete) => {
    let foundPolicyIndex

    const foundPolicy = policies.find((policy, index) => {
      if (policy.id === coverageToDelete.policy.id) {
        foundPolicyIndex = index
        return true
      }
    })

    // Delete coverage from policy if it exists
    if (foundPolicy) {
      foundPolicy.coverages = foundPolicy.coverages.filter(
        (coverage) => coverage.Id !== coverageToDelete.coverage.Id,
      )
    }

    // Delete found policy if there is no coverages after deletion
    if (foundPolicy && foundPolicy.coverages.length === 0) {
      policies.splice(foundPolicyIndex, 1)
    }
  })
}
