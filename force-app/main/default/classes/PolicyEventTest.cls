@isTest
private with sharing class  PolicyEventTest {
    @isTest static void testCreatePolicyEvent() {
        
        String recordName = 'New Policy Name';
        String eventOperation = 'updateCoverage';
        String oldValue = '30';
        String newValue = '50';
        String field = 'premium';
        String action = 'updateCoverage';
        String recordType = 'CanaryAMS__Coverage__c';
        String status = 'pending';
        
        CanaryAMS__Policy__c policy = new CanaryAMS__Policy__c();
        policy.Name = recordName;
        insert policy;

        PolicyEvent policyEvent = PolicyEvent.createPolicyEvent(policy, policy.Id, recordName, eventOperation, oldValue, newValue, field, action, recordType, status);

        System.assertEquals(policyEvent.recordType, recordType);
        System.assertEquals(policyEvent.recordId, policy.Id);
        System.assertEquals(policyEvent.status, status);
        System.assertEquals(policyEvent.operation, eventOperation);
        System.assertEquals(policyEvent.action, action);
        System.assertEquals(policyEvent.oldValue, oldValue);
        System.assertEquals(policyEvent.newValue, newValue);
    }
}
