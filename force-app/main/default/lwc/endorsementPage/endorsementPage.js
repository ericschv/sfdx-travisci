import { LightningElement, api, track, wire } from "lwc"
import { getRecord } from "lightning/uiRecordApi"

import POLICY_ID from "@salesforce/schema/CanaryAMS__Policy__c.Id"

import getEndorsementsByPolicyId from "@salesforce/apex/Endorsements.getEndorsementsByPolicyId"
import getUserById from "@salesforce/apex/Users.getUserById"

import { camelCaseToTitleCase, formatDate } from "c/shared"

export default class EndorsementPage extends LightningElement {
  @track endorsements
  @track loading = true

  @api recordId

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [POLICY_ID],
  })
  wiredPolicy({ error, data }) {
    if (error) {
      console.error("Failed to get policy record:", error)
    }

    if (data) {
      // Fetch endorsements when record id is ready
      this.fetchEndorsements()
    }
  }

  async fetchEndorsements() {
    this.loading = true

    const rawData = await getEndorsementsByPolicyId({ policyId: this.recordId })

    if (rawData) {
      try {
        this.endorsements = await this.formatEndorsements(rawData)
      } catch (error) {
        console.error("Failed to format endorsements: ", error)
      }
    } else {
      console.error("Failed to fetch endorsements for policy:", this.recordId)
    }

    this.loading = false
  }

  doesProratedPremiumExist(proratedPremium) {
    return proratedPremium !== null && typeof proratedPremium !== "undefined"
  }

  async formatEndorsements(endorsements) {
    return Promise.all(
      endorsements
        .sort((x, y) =>
          // reverse chronological order
          Date.parse(x.createdAt) > Date.parse(y.createdAt) ? -1 : 1,
        )
        .map(async (endorsement) => {
          const user = await getUserById({ userId: endorsement.userId })

          const endorsementType = camelCaseToTitleCase(
            endorsement.endorsementType,
          )
          const createdAt = formatDate({ value: endorsement.createdAt })
          const effectiveDate = formatDate({
            value: endorsement.effectiveDate,
            onlyDate: true,
          })

          const endorsementMetadata = {
            proratedPremiumExists: this.doesProratedPremiumExist(
              endorsement.proratedPremium,
            ),
          }

          return {
            createdAt: createdAt,
            endorsementType: endorsementType,
            effectiveDate: effectiveDate,
            newTotalPremium: endorsement.newTotalPremium,
            oldTotalPremium: endorsement.oldTotalPremium,
            premiumDelta: endorsement.premiumDelta,
            userLink: `/${endorsement.userId}`,
            userName: user ? user.Name : endorsement.userId,
            notes: endorsement.notes,
            events: endorsement.events,
            proratedPremium: endorsement.proratedPremium,
            endorsementMetadata,
          }
        }),
    )
  }
}
