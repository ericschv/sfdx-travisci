@isTest
public with sharing class AdditionalInterestEventsTest {
    @isTest static void testCreateNewAdditionalInterestEvents() {
        List<CanaryAMS__Additional_Interests__c> newAdditionalInterests = new List<CanaryAMS__Additional_Interests__c>();

        List<PolicyEvent> policyEvents = AdditionalInterestEvents.createNewAdditionalInterestEvents(newAdditionalInterests);
        System.assertEquals(policyEvents.size(), 0);

        CanaryAMS__Policy__c policy1 = new CanaryAMS__Policy__c( Name = 'test policy 1' );
        insert policy1;

        CanaryAMS__Additional_Interests__c newAdditionalInterest = new CanaryAMS__Additional_Interests__c(
            CanaryAMS__Policy__c = policy1.Id,
            Name = 'test additional interest 1',
            CanaryAMS__Type__c = 'Additional Insured',
            Effective_Date__c = Date.today(),
            CanaryAMS__Address_1__c = 'test address 1',
            CanaryAMS__City__c = 'test city 1',
            CanaryAMS__StateProvCd__c = 'test province 1',
            CanaryAMS__PostalCode__c = 'A1A1A1'
        );

        newAdditionalInterests.add(newAdditionalInterest);

        policyEvents = AdditionalInterestEvents.createNewAdditionalInterestEvents(newAdditionalInterests);
        
        System.assertEquals(policyEvents.size(), 7);
        System.assertEquals(policyEvents[0].operation, 'insert');
        System.assertEquals(policyEvents[0].action, 'addAdditionalInterest');

        System.assertEquals(policyEvents[0].oldValue, null);
        System.assertEquals(policyEvents[1].oldValue, null);
        System.assertEquals(policyEvents[2].oldValue, null);
        System.assertEquals(policyEvents[3].oldValue, null);
        System.assertEquals(policyEvents[4].oldValue, null);

        System.assertEquals(policyEvents[0].newValue, 'test additional interest 1');
        System.assertEquals(policyEvents[1].newValue, 'Additional Insured');
        System.assertEquals(policyEvents[2].newValue, Date.today().format());
        System.assertEquals(policyEvents[3].newValue, 'test address 1');
        System.assertEquals(policyEvents[4].newValue, 'test city 1');
    }

    @isTest static void testCreateDeleteAdditionalInterestEvents() {
        List<CanaryAMS__Additional_Interests__c> oldAdditionalInterests = new List<CanaryAMS__Additional_Interests__c>();

        List<PolicyEvent> policyEvents = AdditionalInterestEvents.createDeleteAdditionalInterestEvents(oldAdditionalInterests);
        System.assertEquals(policyEvents.size(), 0);

        CanaryAMS__Policy__c policy2 = new CanaryAMS__Policy__c( Name = 'test policy 2' );
        insert policy2;

        CanaryAMS__Additional_Interests__c oldAdditionalInterest = new CanaryAMS__Additional_Interests__c(
            CanaryAMS__Policy__c = policy2.Id,
            Name = 'test additional interest 2',
            CanaryAMS__Type__c = 'Other',
            CanaryAMS__Type_Other_Description__c = 'other description',
            Effective_Date__c = Date.today(),
            CanaryAMS__End_Date__c = Date.today().addDays(30),
            CanaryAMS__Address_1__c = 'test address 1',
            CanaryAMS__Address_2__c = 'test address 2',
            CanaryAMS__City__c = 'test city 2',
            CanaryAMS__StateProvCd__c = 'test province 2',
            CanaryAMS__PostalCode__c = 'A1A1A1',
            CanaryAMS__Notes__c = 'test note 2'
        );

        insert oldAdditionalInterest;

        oldAdditionalInterests.add(oldAdditionalInterest);

        policyEvents = AdditionalInterestEvents.createDeleteAdditionalInterestEvents(oldAdditionalInterests);

        System.assertEquals(policyEvents.size(), 11);
        System.assertEquals(policyEvents[0].operation, 'delete');
        System.assertEquals(policyEvents[0].action, 'deleteAdditionalInterest');

        System.assertEquals(policyEvents[0].oldValue, 'test additional interest 2');
        System.assertEquals(policyEvents[1].oldValue, 'Other');
        System.assertEquals(policyEvents[2].oldValue, 'other description');
        System.assertEquals(policyEvents[3].oldValue, Date.today().format());
        System.assertEquals(policyEvents[4].oldValue, Date.today().addDays(30).format());

        System.assertEquals(policyEvents[0].newValue, null);
        System.assertEquals(policyEvents[1].newValue, null);
        System.assertEquals(policyEvents[2].newValue, null);
        System.assertEquals(policyEvents[3].newValue, null);
        System.assertEquals(policyEvents[4].newValue, null);

        delete oldAdditionalInterest;
    }
}
