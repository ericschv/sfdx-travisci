@isTest
private class PolicyCancellationEventsTest {
    @isTest static void testCreateUpdateCoverageEvents() {
        CanaryAMS__Policy__c oldPolicy = new CanaryAMS__Policy__c();
        oldPolicy.Name = 'New Policy Name';
        oldPolicy.CanaryAMS__Policy_Status__c = 'Active';

        CanaryAMS__Policy__c newPolicy = new CanaryAMS__Policy__c();
        newPolicy.Name = 'New Policy Name';
        newPolicy.CanaryAMS__Policy_Status__c = 'Cancelled';

        List<PolicyEvent> policyEvents = PolicyCancellationEvents.createPolicyCancellationEvents(oldPolicy, newPolicy);

        System.assertEquals(policyEvents.size(), 1);
        System.assertEquals(policyEvents[0].action, 'cancelPolicy');
        System.assertEquals(policyEvents[0].action, 'cancelPolicy');
        System.assertEquals(policyEvents[0].oldValue, 'Active');
        System.assertEquals(policyEvents[0].newValue, 'Cancelled');
        System.assertEquals(policyEvents[0].field, 'CanaryAMS__Policy_Status__c');
                
    }
    
}
