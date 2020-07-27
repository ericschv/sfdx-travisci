@isTest
public with sharing class EndorsementsTest {
    @isTest static void testGetEndorsements() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('EndorsementsTestResource');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        
        String policyId = 'testPolicyId1234';
        List<Endorsements.Endorsement> endorsements = Endorsements.getEndorsementsByPolicyId(policyId);
        
        System.assertEquals(endorsements.size(), 3, 'Expected ' + endorsements.size() + ' to equal 3');
        System.assertEquals(endorsements[0].id, '12345', 'Expected ' + endorsements[0].id + ' to equal 12345');
        System.assertEquals(endorsements[0].proratedPremium, 1100, 'Expected ' + endorsements[0].proratedPremium + ' to equal 1100');
        System.assertEquals(endorsements[0].events.size(), 2, 'Expected ' + endorsements[0].events.size() + ' to equal 2');
    }


    @isTest static void testGetEndorsementsByPolicyIds() {
        CanaryAMS__Policy__c policy1 = new CanaryAMS__Policy__c();
        policy1.Name = 'General Liability';
        policy1.CanaryAMS__Policy_Number__c = '2342342';
        insert policy1;
        
        Test.startTest();
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PolicyEndorsementsTestResource');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        
        
        Set<Id> policyIds = new Set<Id>();
        List<Endorsements.PolicyEndorsements> emptyEndorsements = Endorsements.getEndorsementsByPolicyIds(policyIds);
        System.assertEquals(emptyEndorsements.size(), 0, 'Expected ' + emptyEndorsements.size() + ' to equal 0');

        policyIds.add(policy1.Id);
        List<Endorsements.PolicyEndorsements> endorsements = Endorsements.getEndorsementsByPolicyIds(policyIds);

        System.assertEquals(endorsements.size(), 1, 'Expected ' + endorsements.size() + ' to equal 1');
        System.assertEquals(endorsements[0].endorsements.size(), 3, 'Expected ' + endorsements[0].endorsements.size() + ' to equal 3');
        System.assertEquals(endorsements[0].policyId, 'a0Ac0000007szPoEAI');
        Test.stopTest();
    }

    @isTest static void testCreateEndorsement() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('storeEventHistoryLog');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        List<String> policyEventIds = new List<String>();
        policyEventIds.add('123456');
        policyEventIds.add('654321');

        List<Endorsements.Endorsement> endorsementList = new List<Endorsements.Endorsement>();

        Endorsements.Endorsement endorsement = new Endorsements.Endorsement();
        endorsement.endorsementType = 'updateCoverage';
        endorsement.effectiveDate = '2020-01-20';
        endorsement.oldTotalPremium = 900;
        endorsement.newTotalPremium = 1000;
        endorsement.policyId = 'testPolicyId12345';
        endorsement.eventIds = policyEventIds;
        endorsement.notes = 'Making it a bit more expensive';
        endorsement.userId = 'userId32342342';
        endorsement.proratedPremium = 1000;

        endorsementList.add(endorsement);
        
        Endorsements.CreateEndorsementResponse createEndorsementResponse = Endorsements.createEndorsements(endorsementList);
        System.assertEquals(createEndorsementResponse.message, 'Endorsement created successfully: { "endorsements": ' + JSON.serialize(endorsementList, true) + ' }');
    }


    @isTest static void testCreateEndorsementError() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('storeEventHistoryLog');
        mock.setStatusCode(404);
        mock.setStatus('Not Found');
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        List<Endorsements.Endorsement> endorsementList = new List<Endorsements.Endorsement>();
        Endorsements.Endorsement endorsement = new Endorsements.Endorsement();

        endorsementList.add(endorsement);

        String expectedResponse = '{ "endorsements": ' + JSON.serialize(endorsementList, true) + ' }';

        Endorsements.CreateEndorsementResponse createEndorsementResponse = Endorsements.createEndorsements(endorsementList);

        System.assertEquals(createEndorsementResponse.error, 'There was an error creating the endorsement: 404: Not Found: ' + expectedResponse);
    }
}
