@isTest
private class PolicyCoverageEventsTest {
    @isTest static void testCreateUpdateCoverageEvents() {
        List<CanaryAMS__Coverage__c> oldCoverages = new List<CanaryAMS__Coverage__c>();
        List<CanaryAMS__Coverage__c> newCoverages = new List<CanaryAMS__Coverage__c>();

        List<PolicyEvent> policyEvents = PolicyCoverageEvents.createUpdateCoverageEvents(oldCoverages, newCoverages);
        System.assertEquals(policyEvents.size(), 0);

        CanaryAMS__Carrier__c carrier1 = new CanaryAMS__Carrier__c();
        carrier1.Logo_URL__c = 'http://logo.com/logo.gif';
        carrier1.Name = 'Tyler';

        CanaryAMS__Carrier__c carrier2 = new CanaryAMS__Carrier__c();
        carrier2.Logo_URL__c = 'http://logo2.com/logo2.gif';
        carrier2.Name = 'Tyler New';

        insert carrier1;
        insert carrier2;

        CanaryAMS__Policy__c policy = new CanaryAMS__Policy__c();
        policy.Name = 'New Policy Name';
        insert policy;

        CanaryAMS__Coverage__c oldCoverage = new CanaryAMS__Coverage__c();
        oldCoverage.CanaryAMS__Policy__c = policy.Id;
        oldCoverage.Name = 'Old Coverage Name';
        oldCoverage.CanaryAMS__Current_Term_Amount__c = 100;
        oldCoverage.CanaryAMS__Deductible_Type_Code__c = 'PT';
        oldCoverage.Zen_Deductible__c = '12';
        oldCoverage.Zen_Limit__c = '1,000,000';
        oldCoverage.Carrier__c = carrier1.Id;
        oldCoverage.Carrier_Fee__c = 15;
        oldCoverage.Agency_Fee__c = 0;
        oldCoverage.Zen_12_Month_Premium__c = 100;
        oldCoverage.Zen_12_Month_Carrier_Fee__c = 30;
        oldCoverage.Zen_12_Month_Agency_Fee__c = 10;

        oldCoverages.add(oldCoverage);

        CanaryAMS__Coverage__c newCoverage = new CanaryAMS__Coverage__c();
        newCoverage.CanaryAMS__Policy__c = policy.Id;
        newCoverage.Name = 'New Coverage Name';
        newCoverage.CanaryAMS__Current_Term_Amount__c = 200;
        newCoverage.CanaryAMS__Deductible_Type_Code__c = 'FL';
        newCoverage.Zen_Deductible__c = '6';
        newCoverage.Zen_Limit__c = '2,000,000';
        newCoverage.Carrier__c = carrier2.Id;
        newCoverage.Carrier_Fee__c = 11;
        newCoverage.Agency_Fee__c = 10;
        newCoverage.Zen_12_Month_Premium__c = 200;
        newCoverage.Zen_12_Month_Carrier_Fee__c = 60;
        newCoverage.Zen_12_Month_Agency_Fee__c = 20;

        newCoverages.add(newCoverage);

        policyEvents = PolicyCoverageEvents.createUpdateCoverageEvents(oldCoverages, newCoverages);

        System.assertEquals(policyEvents.size(), 10);
        System.assertEquals(policyEvents[0].recordType, 'CanaryAMS__Coverage__c');
        System.assertEquals(policyEvents[0].action, 'updateCoverage');
        System.assertEquals(policyEvents[0].operation, 'update');
        System.assertEquals(policyEvents[0].field, 'CanaryAMS__Current_Term_Amount__c');
        System.assertEquals(policyEvents[1].field, 'CanaryAMS__Deductible_Type_Code__c');
        System.assertEquals(policyEvents[2].field, 'Zen_Deductible__c');
        System.assertEquals(policyEvents[3].field, 'Zen_Limit__c');
        System.assertEquals(policyEvents[4].field, 'Carrier__c');
        System.assertEquals(policyEvents[5].field, 'Carrier_Fee__c');
        System.assertEquals(policyEvents[6].field, 'Agency_Fee__c');
        System.assertEquals(policyEvents[7].field, 'Zen_12_Month_Premium__c');
        System.assertEquals(policyEvents[8].field, 'Zen_12_Month_Agency_Fee__c');
        System.assertEquals(policyEvents[9].field, 'Zen_12_Month_Carrier_Fee__c');
    }



    @isTest static void testCreateDeleteCoverageEvents() {
        List<CanaryAMS__Coverage__c> oldCoverages = new List<CanaryAMS__Coverage__c>();

        List<PolicyEvent> policyEvents = PolicyCoverageEvents.createDeleteCoverageEvents(oldCoverages);
        System.assertEquals(policyEvents.size(), 0);

        CanaryAMS__Carrier__c carrier1 = new CanaryAMS__Carrier__c();
        carrier1.Logo_URL__c = 'http://logo.com/logo.gif';
        carrier1.Name = 'Tyler';

        insert carrier1;

        CanaryAMS__Policy__c policy = new CanaryAMS__Policy__c();
        policy.Name = 'New Policy Name';
        insert policy;

        CanaryAMS__Coverage__c oldCoverage = new CanaryAMS__Coverage__c();
        oldCoverage.CanaryAMS__Policy__c = policy.Id;
        oldCoverage.Name = 'Old Coverage Name';
        oldCoverage.CanaryAMS__Current_Term_Amount__c = 100;
        oldCoverage.CanaryAMS__Deductible_Type_Code__c = 'PT';
        oldCoverage.Zen_Deductible__c = '5';
        oldCoverage.Zen_Limit__c = '1,000,000';
        oldCoverage.Carrier__c = carrier1.Id;
        oldCoverage.Carrier_Fee__c = 15;
        oldCoverage.Agency_Fee__c = 0;
        oldCoverage.Zen_12_Month_Premium__c = 200;
        oldCoverage.Zen_12_Month_Carrier_Fee__c = 60;
        oldCoverage.Zen_12_Month_Agency_Fee__c = 20;

        oldCoverages.add(oldCoverage);

        policyEvents = PolicyCoverageEvents.createDeleteCoverageEvents(oldCoverages);

        System.assertEquals(policyEvents.size(), 6);
        System.assertEquals(policyEvents[0].operation, 'delete');
        System.assertEquals(policyEvents[0].action, 'updateCoverage');
        System.assertEquals(policyEvents[0].field, 'CanaryAMS__Current_Term_Amount__c');

        System.assertEquals(policyEvents[1].operation, 'delete');
        System.assertEquals(policyEvents[1].action, 'updateCoverage');
        System.assertEquals(policyEvents[1].field, 'Agency_Fee__c');
        System.assertEquals(policyEvents[1].newValue, '0');

        System.assertEquals(policyEvents[2].operation, 'delete');
        System.assertEquals(policyEvents[2].action, 'updateCoverage');
        System.assertEquals(policyEvents[2].field, 'Carrier_Fee__c');

        System.assertEquals(policyEvents[3].operation, 'delete');
        System.assertEquals(policyEvents[3].action, 'updateCoverage');
        System.assertEquals(policyEvents[3].field, 'Zen_12_Month_Premium__c');

        System.assertEquals(policyEvents[4].operation, 'delete');
        System.assertEquals(policyEvents[4].action, 'updateCoverage');
        System.assertEquals(policyEvents[4].field, 'Zen_12_Month_Agency_Fee__c');

        System.assertEquals(policyEvents[5].operation, 'delete');
        System.assertEquals(policyEvents[5].action, 'updateCoverage');
        System.assertEquals(policyEvents[5].field, 'Zen_12_Month_Carrier_Fee__c');
    }


    @isTest static void testCreateInsertCoverageEvents() {
        List<CanaryAMS__Coverage__c> newCoverages = new List<CanaryAMS__Coverage__c>();

        List<PolicyEvent> policyEvents = PolicyCoverageEvents.createInsertCoverageEvents(newCoverages);
        System.assertEquals(policyEvents.size(), 0);

        CanaryAMS__Carrier__c carrier1 = new CanaryAMS__Carrier__c();
        carrier1.Logo_URL__c = 'http://logo.com/logo.gif';
        carrier1.Name = 'Tyler';

        insert carrier1;

        CanaryAMS__Policy__c policy = new CanaryAMS__Policy__c();
        policy.Name = 'New Policy Name';
        insert policy;

        CanaryAMS__Coverage__c newCoverage = new CanaryAMS__Coverage__c();
        newCoverage.CanaryAMS__Policy__c = policy.Id;
        newCoverage.Name = 'New Coverage Name';
        newCoverage.CanaryAMS__Current_Term_Amount__c = 200;
        newCoverage.CanaryAMS__Deductible_Type_Code__c = 'FL';
        newCoverage.Zen_Deductible__c = '6';
        newCoverage.Zen_Limit__c = '2,000,000';
        newCoverage.Carrier__c = carrier1.Id;
        newCoverage.Carrier_Fee__c = 11;
        newCoverage.Agency_Fee__c = 10;
        newCoverage.Zen_12_Month_Premium__c = 200;
        newCoverage.Zen_12_Month_Carrier_Fee__c = 60;
        newCoverage.Zen_12_Month_Agency_Fee__c = 20;

        newCoverages.add(newCoverage);

        policyEvents = PolicyCoverageEvents.createInsertCoverageEvents(newCoverages);
        System.assertEquals(policyEvents.size(), 10);

        System.assertEquals(policyEvents[0].operation, 'insert');
        System.assertEquals(policyEvents[0].action, 'updateCoverage');
        System.assertEquals(policyEvents[0].field, 'CanaryAMS__Current_Term_Amount__c');
        System.assertEquals(policyEvents[1].field, 'Agency_Fee__c');
        System.assertEquals(policyEvents[2].field, 'Carrier_Fee__c');
        System.assertEquals(policyEvents[3].field, 'Zen_12_Month_Premium__c');
        System.assertEquals(policyEvents[4].field, 'Zen_12_Month_Agency_Fee__c');
        System.assertEquals(policyEvents[5].field, 'Zen_12_Month_Carrier_Fee__c');
        System.assertEquals(policyEvents[6].field, 'Zen_Limit__c');
        System.assertEquals(policyEvents[7].field, 'Zen_Deductible__c');
        System.assertEquals(policyEvents[8].field, 'CanaryAMS__Deductible_Type_Code__c');
        System.assertEquals(policyEvents[9].field, 'Carrier__c');
    }
}
