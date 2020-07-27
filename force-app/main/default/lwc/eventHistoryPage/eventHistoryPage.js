import { LightningElement, track, api, wire } from "lwc"
import { getRecord, getFieldValue } from "lightning/uiRecordApi"

import { refreshApex } from "@salesforce/apex"
import getEventsByPolicyId from "@salesforce/apex/PolicyEventHistory.getEventsByPolicyId"

import POLICY_ID from "@salesforce/schema/CanaryAMS__Policy__c.Id"
import POLICY_NET_PREMIUM from "@salesforce/schema/CanaryAMS__Policy__c.CanaryAMS__Net_Premium__c"

const fields = [POLICY_ID, POLICY_NET_PREMIUM]

export default class EventHistoryPage extends LightningElement {
  areEventsLoaded = false

  @track eventLogs
  @track pendingEvents
  @track isModalOpen
  @track policy
  @track isEditing = false

  @api recordId

  @wire(getRecord, {
    recordId: "$recordId",
    fields,
  })
  getPolicy(policy) {
    this.wiredPolicy = policy

    if (policy.error) {
      console.error("Failed to get a policy record:", policy.error)
    }

    if (policy.data) {
      this.policy = {
        id: getFieldValue(policy.data, POLICY_ID),
        newTotalPremium: getFieldValue(policy.data, POLICY_NET_PREMIUM),
      }

      if (!this.areEventsLoaded) {
        this.fetchEvents()
        this.areEventsLoaded = true
      }
    }
  }

  async reloadPolicy() {
    await refreshApex(this.wiredPolicy)
  }

  async fetchEvents() {
    this.cancelEditing()

    try {
      this.eventLogs = await getEventsByPolicyId({ policyId: this.policy.id })
      this.pendingEvents = this.eventLogs.filter(
        (event) => event.status === "pending",
      )
    } catch (error) {
      console.error("Could not fetch events for policy:", error)
    }
  }

  async openModal() {
    await this.reloadPolicy()
    this.isModalOpen = true
  }

  closeModal() {
    this.isModalOpen = false
  }

  startEditing() {
    this.isEditing = true
  }

  cancelEditing() {
    this.isEditing = false
  }
}
