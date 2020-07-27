//NOTE: THIS IS JUST TO GET PAST SALESFORCE CHECKS
import { LightningElement } from "lwc"

//NOTE: Empty component just to allow us to share functionality using
// `c/shared` lib export.
// to use: `import { debug, ... } from 'c/shared'`
export default class Shared extends LightningElement {}

//NOTE: Export the libs below to share crode with other components
export * from "./debug"
export * from "./core"
export * from "./validation"
export * from "./salesforce-lwc"
