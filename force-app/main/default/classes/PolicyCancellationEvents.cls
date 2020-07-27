public with sharing class PolicyCancellationEvents {
    public static List<PolicyEvent> createPolicyCancellationEvents(CanaryAMS__Policy__c oldPolicy, CanaryAMS__Policy__c newPolicy) {
        // we are only concerned with policies whose status was changed from any value to "Cancelled"
        List<PolicyEvent> policyEvents = new List<PolicyEvent>();
        if (oldPolicy.CanaryAMS__Policy_Status__c != newPolicy.CanaryAMS__Policy_Status__c && 
            newPolicy.CanaryAMS__Policy_Status__c == 'Cancelled') {
                
                PolicyEvent policyEvent = new PolicyEvent();

                policyEvent.policyId = newPolicy.Id;
                policyEvent.policyName = newPolicy.Name;
                policyEvent.action = 'cancelPolicy';
                policyEvent.operation = 'update';
                policyEvent.recordType = 'CanaryAMS__Policy__c';
                policyEvent.recordId = newPolicy.Id;
                policyEvent.recordName = newPolicy.Name;
                policyEvent.field = 'CanaryAMS__Policy_Status__c';
                policyEvent.oldValue = oldPolicy.CanaryAMS__Policy_Status__c;
                policyEvent.newValue = newPolicy.CanaryAMS__Policy_Status__c;
                policyEvent.status = 'pending';

                policyEvents.add(policyEvent);
        }
        return policyEvents;
    }
}
