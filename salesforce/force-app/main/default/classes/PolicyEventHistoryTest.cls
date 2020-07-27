@isTest
private class PolicyEventHistoryTest {

    public static String POLICY_ID = '12345';
    public static String POLICY_NAME = 'Tyler\'s awesome policy';
    public static String POLICY_ACTION = 'bindPolicy';
    public static String RECORD_TYPE = 'CanaryAMS__Policy__c';
    public static String RECORD_ID = '12345';
    public static String RECORD_NAME = 'Tyler\'s awesome policy';
    public static String RECORD_FIELD = 'CanaryAMS__Policy_Status__c';
    public static String OLD_VALUE = 'Active';
    public static String NEW_VALUE = 'Cancelled';
    public static String EVENT_STATUS = 'completed';

    @isTest static void testGetEventsByPolicyId() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('storeEventHistoryLog');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        List<PolicyEvent> policyEvents = PolicyEventHistory.getEventsByPolicyId('12345');

        System.assert(policyEvents.size() == 1, 'Expected ' + policyEvents.size() + ' to equal 1');
        System.assert(policyEvents[0].eventId == '1234567', 'Expected ' + policyEvents[0].eventId + ' to equal 1234567');
        System.assert(policyEvents[0].policyName == 'Tyler\'s policy', 'Expected ' + policyEvents[0].policyName + ' to equal Tyler\'s policy');
    }

    @isTest static void testGetEventsByPolicyIdAndStatus() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('storeEventHistoryLog');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        List<PolicyEvent> policyEvents = PolicyEventHistory.getEventsByPolicyIdAndStatus('12345', 'pending');

        System.assert(policyEvents.size() == 1, 'Expected ' + policyEvents.size() + ' to equal 1');
        System.assert(policyEvents[0].eventId == '1234567', 'Expected ' + policyEvents[0].eventId + ' to equal 1234567');
        System.assert(policyEvents[0].policyName == 'Tyler\'s policy', 'Expected ' + policyEvents[0].policyName + ' to equal Tyler\'s policy');
    }


    @isTest static void testGetPolicyEventJson() {
        // Create the mock response based on a static resource
        List<PolicyEvent> policyEvents = new List<PolicyEvent>();

        String policyEventJSON = PolicyEventHistory.getPolicyEventJson(policyEvents);

        System.assertEquals(policyEventJSON, '');

        PolicyEvent policyEvent = new PolicyEvent();
        policyEvent.policyId = PolicyEventHistoryTest.POLICY_ID;
        policyEvent.policyName = PolicyEventHistoryTest.POLICY_NAME;
        policyEvent.action = PolicyEventHistoryTest.POLICY_ACTION;
        policyEvent.recordType = PolicyEventHistoryTest.RECORD_TYPE;
        policyEvent.recordId = PolicyEventHistoryTest.RECORD_ID;
        policyEvent.recordName = PolicyEventHistoryTest.RECORD_NAME;
        policyEvent.field = PolicyEventHistoryTest.RECORD_FIELD;
        policyEvent.oldValue = PolicyEventHistoryTest.OLD_VALUE;
        policyEvent.newValue = PolicyEventHistoryTest.NEW_VALUE;
        policyEvent.status = PolicyEventHistoryTest.EVENT_STATUS;

        policyEvents.add(policyEvent);

        policyEventJSON = PolicyEventHistory.getPolicyEventJson(policyEvents);

        System.assertEquals(policyEventJSON, '{ "events": ' +  JSON.serialize(policyEvents, true) + ' }');
        
    }


    @isTest static void testStoreEvent() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('storeEventHistoryLog');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        List<PolicyEvent> policyEvents = new List<PolicyEvent>();
        PolicyEvent policyEvent = new PolicyEvent();

        policyEvent.policyId = PolicyEventHistoryTest.POLICY_ID;
        policyEvent.policyName = PolicyEventHistoryTest.POLICY_NAME;
        policyEvent.action = PolicyEventHistoryTest.POLICY_ACTION;
        policyEvent.recordType = PolicyEventHistoryTest.RECORD_TYPE;
        policyEvent.recordId = PolicyEventHistoryTest.RECORD_ID;
        policyEvent.recordName = PolicyEventHistoryTest.RECORD_NAME;
        policyEvent.field = PolicyEventHistoryTest.RECORD_FIELD;
        policyEvent.oldValue = PolicyEventHistoryTest.OLD_VALUE;
        policyEvent.newValue = PolicyEventHistoryTest.NEW_VALUE;
        policyEvent.status = PolicyEventHistoryTest.EVENT_STATUS;

        policyEvents.add(policyEvent);

        String policyEventJSON = JSON.serialize(policyEvents);
        
        HttpResponse eventHistoryStorageResult = PolicyEventHistory.calloutToStoreEvents(policyEventJSON);

        
        System.assert(eventHistoryStorageResult.getStatusCode() == 200, 'Expected ' + eventHistoryStorageResult.getStatusCode() + ' to equal 200');
    }


    @isTest static void testCalculatePremiumDelta() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PremiumDeltaTestResource');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        String policyId = 'testPolicyId54321';
        PolicyEventHistory.DeltaResponse deltaResponse = PolicyEventHistory.calculatePremiumDelta(policyId);

        System.assertEquals(deltaResponse.delta, 550);
    }

    @isTest static void testCalculatePremiumDeltaError() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PremiumDeltaTestResource');
        mock.setStatusCode(404);
        mock.setStatus('Not Found');
        Test.setMock(HttpCalloutMock.class, mock);

        String policyId = 'testPolicyId543219';
        PolicyEventHistory.DeltaResponse deltaResponse = PolicyEventHistory.calculatePremiumDelta(policyId);

        System.assertEquals(deltaResponse.error, 'Unable to calculate premium delta for policy: testPolicyId543219, status code: 404, status: Not Found');
    }


    @isTest static void testCreateUpdateCoverageEvents() {
        CanaryAMS__Policy__c policy = new CanaryAMS__Policy__c();
        policy.Name = 'New Policy Name';
        policy.CanaryAMS__Policy_Status__c = 'Active';

        List<PolicyEvent> policyEvents = PolicyEventHistory.createPolicyIssuanceEvent(policy);

        System.assertEquals(policyEvents.size(), 1);
        System.assertEquals(policyEvents[0].action, 'issuePolicy');
        System.assertEquals(policyEvents[0].operation, 'insert');
        System.assertEquals(policyEvents[0].status, 'completed');
        System.assertEquals(policyEvents[0].oldValue, 'N/A');
        System.assertEquals(policyEvents[0].newValue, 'Active');
        System.assertEquals(policyEvents[0].field, 'CanaryAMS__Policy_Status__c');
                
    }

    @isTest static void testCreateAddressChangeEvents() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PremiumDeltaTestResource');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        Industry__c industry = new Industry__c();
        industry.Slug__c = 'Test Industry';
        insert industry;

        Flow__c flow = new Flow__c();
        flow.Slug__c = 'Test Flow';
        insert flow;
        
        Account testAccount = new Account();
        testAccount.name = 'Test Account';
        testAccount.Industry_Rel__c = industry.Id;
        testAccount.Flow__c = flow.Id;
        testAccount.BillingCity = 'Toronto';
        testAccount.BillingStreet = '123 Fake Street';
        testAccount.BillingState = 'Ontario';
        testAccount.BillingCountry = 'Canada';

        Account testAccount2 = new Account();
        testAccount2.name = 'Test Account 2';
        testAccount2.Industry_Rel__c = industry.Id;
        testAccount2.Flow__c = flow.Id;
        testAccount2.BillingCity = 'Vancouver';
        testAccount2.BillingStreet = '1234 Fake Street';
        testAccount2.BillingState = 'BC';
        testAccount2.BillingCountry = 'Canada';
        testAccount2.BillingPostalCode = 'M4M 2I6';

        insert testAccount;
        insert testAccount2;

        CanaryAMS__Policy__c policy = new CanaryAMS__Policy__c();
        policy.Name = 'Test Policy';
        policy.CanaryAMS__Account__c = testAccount.Id;
        policy.CanaryAMS__Effective_Date__c = Date.newInstance(2020, 2, 21);

        CanaryAMS__Policy__c policy2 = new CanaryAMS__Policy__c();
        policy2.Name = 'Test Policy2';
        policy2.CanaryAMS__Account__c = testAccount.Id;
        policy2.CanaryAMS__Effective_Date__c = Date.newInstance(2020, 3, 4);

        insert policy;
        insert policy2;

        List<PolicyEvent> policyEvents = PolicyEventHistory.createAddressChangeEvents(testAccount, testAccount2);

        System.assertEquals(policyEvents.size(), 2);
        System.assertEquals(policyEvents[0].policyId, policy.Id);
        System.assertEquals(policyEvents[0].policyName, policy.Name);
        System.assertEquals(policyEvents[1].policyId, policy2.Id);
        System.assertEquals(policyEvents[1].policyName, policy2.Name);

        String oldAddress = '123 Fake Road';
        String newAddress = '123 Fake Street';

        PolicyEvent policyEvent = PolicyEventHistory.createAddressChangeEvent(testAccount, testAccount2, 'BillingAddress', policy, oldAddress, newAddress);

        System.assertEquals(policyEvent.policyId, policy.Id);
        System.assertEquals(policyEvent.oldValue, oldAddress);
        System.assertEquals(policyEvent.newValue, newAddress);
    }
}
