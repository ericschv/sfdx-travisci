import { LightningElement, api, track } from "lwc"
import dataMap from "./dataMap"

export default class Alert extends LightningElement {
  baseContainerClass = "slds-notify slds-notify_alert slds-theme_alert-texture"

  @track data = dataMap["info"]
  @track containerClass
  @track outerContainerClass

  @api
  get variant() {
    return this.data
  }
  set variant(variant) {
    this.data = dataMap[variant] || dataMap["info"]
    this.updateContainerClass()
  }
  @api dismissible = false

  connectedCallback() {
    this.updateContainerClass()
  }

  dismiss() {
    this.outerContainerClass = "outer-container--dismissed"
  }

  updateContainerClass() {
    this.containerClass = [this.baseContainerClass, this.data.containerClass].join(" ")
  }
}
