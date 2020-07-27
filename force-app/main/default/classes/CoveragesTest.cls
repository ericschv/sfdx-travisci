@isTest
private class CoveragesTest {
    @isTest static void testGetCoveragesByPolicyIds() {
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

        CanaryAMS__Coverage__c coverage1 = new CanaryAMS__Coverage__c();
        coverage1.Name = 'Coverage 1';
        coverage1.CanaryAMS__Policy__c = policy1.Id;
        insert coverage1;

        CanaryAMS__Coverage__c coverage2 = new CanaryAMS__Coverage__c();
        coverage2.Name = 'Coverage 2';
        coverage2.CanaryAMS__Policy__c = policy2.Id;
        insert coverage2;

        Set<Id> policyIds = new Set<Id>();
        policyIds.add(policy1.Id);
        policyIds.add(policy2.Id);

        List<CanaryAMS__Coverage__c> coverages = Coverages.getCoveragesByPolicyIds(policyIds);

        System.assert(coverages.size() == 2);

    }
}
