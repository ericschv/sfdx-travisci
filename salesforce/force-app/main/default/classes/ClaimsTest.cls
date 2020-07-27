@isTest
private class ClaimsTest {
    @isTest static void testGetClaimsByPolicyIds() {
        Account  testAccount = new Account();
        testAccount.Name = 'Tyler Test';
        insert testAccount;

        CanaryAMS__Policy__c policy1 = new CanaryAMS__Policy__c();
        policy1.Name = 'General Liability';
        policy1.CanaryAMS__Policy_Number__c = '4252345';
        insert policy1;

        CanaryAMS__Policy__c policy2 = new CanaryAMS__Policy__c();
        policy2.Name = 'Professional Liability';
        policy2.CanaryAMS__Policy_Number__c = '2f233';
        insert policy2;

        CanaryAMS__Claim__c claim1 = new CanaryAMS__Claim__c();
        claim1.Name = '1234';
        claim1.Zen_Claim_Code__c = 'AB';
        claim1.Coverage_Type__c = 'Auto';
        claim1.CanaryAMS__Policy__c = policy1.Id;
        insert claim1;

        CanaryAMS__Claim__c claim2 = new CanaryAMS__Claim__c();
        claim2.Name = '5678';
        claim2.Zen_Claim_Code__c = 'AB';
        claim2.Coverage_Type__c = 'Auto';
        claim2.CanaryAMS__Policy__c = policy2.Id;
        insert claim2;

        Set<Id> policyIds = new Set<Id>();
        policyIds.add(policy1.Id);
        policyIds.add(policy2.Id);

        List<CanaryAMS__Claim__c> claims = Claims.getClaimsByPolicyIds(policyIds);

        System.assert(claims.size() == 2);

    }

}
