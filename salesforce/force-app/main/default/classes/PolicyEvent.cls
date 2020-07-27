public class PolicyEvent {
    @AuraEnabled public String eventId { get; set; }
    @AuraEnabled public String policyId { get; set; }
    @AuraEnabled public String policyName { get; set; }
    @AuraEnabled public String action { get; set; }
    @AuraEnabled public String operation { get; set; }
    @AuraEnabled public String recordType { get; set; }
    @AuraEnabled public String recordId { get; set; }
    @AuraEnabled public String recordName { get; set; }
    @AuraEnabled public String field { get; set; }
    @AuraEnabled public String oldValue { get; set; }
    @AuraEnabled public String newValue { get; set; }
    @AuraEnabled public String status { get; set; }
    @AuraEnabled public String createdAt { get; set; }


    public static PolicyEvent createPolicyEvent(CanaryAMS__Policy__c policy, String recordId, String recordName, String eventOperation, String oldValue, String newValue, String field, String action, String recordType, String status) {
    
      // add policyEvent on update
      PolicyEvent policyEvent = new PolicyEvent();
      
      List<String> calculatableFields = new List<String>{'CanaryAMS__Current_Term_Amount__c', 'Carrier_Fee__c','Agency_Fee__c'};
      if (calculatableFields.contains(field)) {
        if (newValue == null) {
          newValue = '0';
        }
        if (oldValue == null) {
          oldValue = '0';
        }
      }      

      policyEvent.policyId = policy.Id;
      policyEvent.policyName = policy.Name;
      policyEvent.action = action;
      policyEvent.operation = eventOperation;
      policyEvent.recordType = recordType;
      policyEvent.recordId = recordId;
      policyEvent.recordName = recordName;
      policyEvent.field = field;
      policyEvent.oldValue = oldValue;
      policyEvent.newValue = newValue;
      policyEvent.status = status;
    
      return policyEvent;
  }
}
