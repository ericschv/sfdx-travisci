import { LightningElement, api, track, wire } from "lwc"
import { getObjectInfo } from "lightning/uiObjectInfoApi"

import POLICY_OBJECT from "@salesforce/schema/CanaryAMS__Policy__c"
import COVERAGE_OBJECT from "@salesforce/schema/CanaryAMS__Coverage__c"
import COVERAGE_CARRIER from "@salesforce/schema/CanaryAMS__Coverage__c.Carrier__c"
// import COVERAGE_PREMIUM from "@salesforce/schema/CanaryAMS__Coverage__c.CanaryAMS__Current_Term_Amount__c"
import COVERAGE_DEDUCTIBLE_TYPE from "@salesforce/schema/CanaryAMS__Coverage__c.CanaryAMS__Deductible_Type_Code__c"
import ACCOUNT_OBJECT from "@salesforce/schema/Account"

import getCarriers from "@salesforce/apex/Carriers.getCarriers"
import getApiHost from "@salesforce/apex/SharedUtils.getApiHost"

import {
  camelCaseToTitleCase,
  formatDate,
  deductibleTypeDropdownOptions,
  updateDraftValuesWithDropdownChangeEvent,
  toastEvent,
} from "c/shared"

import { columns, readOnlyColumns } from "./columns"

export default class EventHistoryTable extends LightningElement {
  @track columns = readOnlyColumns
  @track tableData = []
  @track draftValues = []
  @track isSaving = false
  @track _isEditable
  @track allTableData = []
  @track pageSize = 50
  @track firstIndex = 0
  @track lastIndex = 0
  @track totalLength = 0
  @track page = 1
  @track numPages = 0
  @track showPaginator = false

  @api
  get currentIndex() {
    return this.firstIndex + 1
  }

  @api
  get isEditable() {
    return this._isEditable
  }
  set isEditable(bool) {
    if (bool) {
      this.columns = columns
    } else {
      this.columns = readOnlyColumns
      this.resetDraftValues()
    }

    this._isEditable = bool
  }

  @api
  get rawData() {}
  set rawData(data) {
    if (Array.isArray(data)) {
      // This timeout is to give an enough time for all object info and
      // carrier data to be loaded before formatting table data on initial load
      if (this.isAllDataReady) {
        this.updateTableData(data)
      } else {
        setTimeout(() => {
          this.updateTableData(data)
          this.isAllDataReady = true
        }, 800)
      }
    }
  }

  async connectedCallback() {
    this.carriers = await getCarriers()
  }

  @wire(getObjectInfo, { objectApiName: POLICY_OBJECT })
  policyObjectInfo

  @wire(getObjectInfo, { objectApiName: COVERAGE_OBJECT })
  coverageObjectInfo

  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
  accountObjectInfo

  updateTableData(rawData) {
    this.allTableData = this.getTableData(rawData)
    this.totalLength = this.allTableData.length
    this.numPages = Math.ceil(this.totalLength / this.pageSize)
    this.showPaginator = this.numPages !== 1

    this.updateDisplayData()
  }

  getTableData(data) {
    return [...data]
      .sort((x, y) =>
        // reverse chronological order
        Date.parse(x.createdAt) > Date.parse(y.createdAt) ? -1 : 1,
      )
      .map((row, index) => this.getRowValues(row, index))
  }

  getRowValues(row, index) {
    let recordType = row.recordType
    let field = row.field
    let oldValue = row.oldValue
    let newValue = row.newValue

    // Map Salesforce api names to labels for record type, field, and values
    // TODO: Abstract this away if this logic grows
    switch (row.recordType) {
      case POLICY_OBJECT.objectApiName:
        if (this.policyObjectInfo.data) {
          recordType = this.policyObjectInfo.data.label
          field = this.policyObjectInfo.data.fields[field].label
        } else {
          console.log("Policy object info is not ready yet")
        }
        break
      case COVERAGE_OBJECT.objectApiName:
        if (this.coverageObjectInfo.data) {
          recordType = this.coverageObjectInfo.data.label

          if (field === COVERAGE_CARRIER.fieldApiName && this.carriers) {
            const oldCarrier = this.carriers.find(
              (carrier) => carrier.Id === oldValue,
            )
            const newCarrier = this.carriers.find(
              (carrier) => carrier.Id === newValue,
            )

            if (oldCarrier) oldValue = oldCarrier.Name
            if (newCarrier) newValue = newCarrier.Name
          }

          if (field === COVERAGE_DEDUCTIBLE_TYPE.fieldApiName) {
            const oldDeductibleTypeOption = deductibleTypeDropdownOptions.find(
              (option) => option.value === oldValue,
            )
            const newDeductibleTypeOption = deductibleTypeDropdownOptions.find(
              (option) => option.value === newValue,
            )

            if (oldDeductibleTypeOption)
              oldValue = oldDeductibleTypeOption.label
            if (newDeductibleTypeOption)
              newValue = newDeductibleTypeOption.label
          }

          field = this.coverageObjectInfo.data.fields[field].label
        } else {
          console.log("Coverage object info is not ready yet")
        }
        break
      case ACCOUNT_OBJECT.objectApiName:
        if (this.accountObjectInfo.data) {
          recordType = this.accountObjectInfo.data.label
          field = this.accountObjectInfo.data.fields[field].label
        } else {
          console.log("Account object info is not ready yet")
        }
        break
    }

    // Uncomment this if we want to disable dropdown for premium change
    // const isCoveragePremiumChange =
    //   row.recordType === COVERAGE_OBJECT.objectApiName &&
    //   row.field === COVERAGE_PREMIUM.fieldApiName

    // show a plain text instead of dropdown in edit mode if this change has already been endorsed
    const statusPlainText /* isCoveragePremiumChange || */ =
      row.status === "completed" ? camelCaseToTitleCase(row.status) : null

    return {
      eventId: row.eventId,
      rowId: `row-${index}`, // for table dropdown
      action: camelCaseToTitleCase(row.action),
      operation: camelCaseToTitleCase(row.operation),
      recordType,
      recordLink: row.recordId ? `/${row.recordId}` : ``,
      recordName: row.recordName,
      field,
      oldValue,
      newValue,
      statusLabel: camelCaseToTitleCase(row.status), // for readonly mode
      selectedStatus: row.status, // for edit mode
      statusPlainText,
      tableIndex: index + 1,
      createdAt: formatDate({ value: row.createdAt }),
    }
  }

  updateDisplayData() {
    this.lastIndex =
      this.firstIndex + this.pageSize > this.totalLength
        ? this.totalLength
        : this.firstIndex + this.pageSize

    this.tableData = this.allTableData.slice(
      this.firstIndex,
      this.firstIndex + this.pageSize,
    )
  }

  handlePrevious() {
    if (this.page > 1) {
      this.firstIndex -= this.pageSize
      this.page--

      this.updateDisplayData()
    }
  }

  handleNext() {
    if (this.page < this.numPages) {
      this.firstIndex += this.pageSize
      this.page++

      this.updateDisplayData()
    }
  }

  resetDraftValues() {
    this.draftValues = []
  }

  handleDropdownChange(event) {
    this.draftValues = updateDraftValuesWithDropdownChangeEvent(
      this.draftValues,
      event,
    )
  }

  async handleSave() {
    this.isSaving = true

    const events = this.draftValues.map((draftValue) => {
      const foundRow = this.allTableData.find((row) => row.rowId === draftValue.id)
      return {
        _id: foundRow.eventId,
        status: draftValue.selectedStatus,
      }
    })

    const apiUrl = await getApiHost()
    const payload = { events }

    try {
      const response = await fetch(`${apiUrl}/v4/policy-events`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      })

      const { updatedEvents, failedEvents } = await response.json()

      if (response.status === 200) {
        this.dispatchEvent(
          toastEvent(
            "Changes were updated successfully.",
            "Please verify all changes were updated correctly in the table.",
            "success",
          ),
        )
      } else if (
        response.status === 500 &&
        failedEvents &&
        failedEvents.length > 0
      ) {
        const failedRowNumbers = failedEvents
          .map((failedEvent) => {
            const failedRow = this.allTableData.find(
              (row) => row.eventId === failedEvent._id,
            )

            const failedRowNumber =
              parseInt(failedRow.rowId.replace("row-", "")) + 1

            return failedRowNumber
          })
          .sort()

        this.dispatchEvent(
          toastEvent(
            "Some changes were not updated successfully.",
            `Failed to update row ${failedRowNumbers.join(
              ", ",
            )}. Please try again and talk to the BMS team if the problem persists.`,
            "warning",
          ),
        )
      } else {
        throw new Error()
      }
    } catch (error) {
      this.dispatchEvent(
        toastEvent(
          "Changes were not updated successfully.",
          "Please let the BMS team know of the issue.",
          "error",
        ),
      )
    }

    const saveEvent = new CustomEvent("savepolicyeventchange")
    this.dispatchEvent(saveEvent)

    this.isSaving = false
  }

  handleCancel() {
    this.resetDraftValues()
    const cancelEvent = new CustomEvent("cancelpolicyeventchange")
    this.dispatchEvent(cancelEvent)
  }
}
