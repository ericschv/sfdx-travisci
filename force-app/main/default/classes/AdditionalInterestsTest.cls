@isTest
private with sharing class AdditionalInterestsTest {
    private static String POLICY_NAME1 = 'test policy 1';
    private static String POLICY_NAME2 = 'test policy 2';
    private static String COVERAGE_NAME1 = 'test cov 1';
    private static String COVERAGE_NAME2 = 'test cov 2';
    private static String CGL_COVERAGE_NAME = 'test cgl cov';
    private static String ADDITIONAL_INTEREST_NAME1 = 'test additional interest 1';
    private static String ADDITIONAL_INTEREST_NAME2 = 'test additional interest 2';
    
    @testSetup static void setup() {
        List<CanaryAMS__Policy__c> testPolicies = new List<CanaryAMS__Policy__c>();
        
        CanaryAMS__Policy__c policy1 = new CanaryAMS__Policy__c( Name = POLICY_NAME1 );
        testPolicies.add(policy1);
        
        CanaryAMS__Policy__c policy2 = new CanaryAMS__Policy__c( Name = POLICY_NAME2 );
        testPolicies.add(policy2);
        
        insert testPolicies;

        List<CanaryAMS__Coverage__c> testCoverages = new List<CanaryAMS__Coverage__c>();

        CanaryAMS__Coverage__c coverage1 = new CanaryAMS__Coverage__c ( 
            Name = COVERAGE_NAME1, 
            CanaryAMS__Policy__c = policy1.Id
        );
        testCoverages.add(coverage1);
        
        CanaryAMS__Coverage__c coverage2 = new CanaryAMS__Coverage__c ( 
            Name = COVERAGE_NAME2, 
            CanaryAMS__Policy__c = policy2.Id
        );
        testCoverages.add(coverage2);

        CanaryAMS__Coverage__c cgl = new CanaryAMS__Coverage__c ( 
            Name = CGL_COVERAGE_NAME, 
            CanaryAMS__Policy__c = policy1.Id,
            API_Policy_Slug__c = AdditionalInterests.CGL_POLICY_SLUGS[0]
        );
        testCoverages.add(cgl);
        
        insert testCoverages;

        List<CanaryAMS__Additional_Interests__c> testAdditionalInterests = new List<CanaryAMS__Additional_Interests__c>();

        CanaryAMS__Additional_Interests__c additionalInterest1 = new CanaryAMS__Additional_Interests__c ( 
            Name = ADDITIONAL_INTEREST_NAME1, 
            CanaryAMS__Policy__c = policy1.Id,
            Effective_Date__c = Date.newInstance(2020, 10, 10),
            CanaryAMS__Type__c = 'Additional Insured',
            CanaryAMS__Address_1__c = 'address1',
            CanaryAMS__City__c = 'city1',
            CanaryAMS__StateProvCd__c = 'state1',
            CanaryAMS__PostalCode__c = 'A1A 1A1'
        );
        testAdditionalInterests.add(additionalInterest1);

        CanaryAMS__Additional_Interests__c additionalInterest2 = new CanaryAMS__Additional_Interests__c ( 
            Name = ADDITIONAL_INTEREST_NAME2, 
            CanaryAMS__Policy__c = policy2.Id,
            Effective_Date__c = Date.newInstance(2020, 10, 10),
            CanaryAMS__Type__c = 'Additional Insured',
            CanaryAMS__Address_1__c = 'address2',
            CanaryAMS__City__c = 'city2',
            CanaryAMS__StateProvCd__c = 'state2',
            CanaryAMS__PostalCode__c = 'B2B 2B2'
        );
        testAdditionalInterests.add(additionalInterest2);
        
        insert testAdditionalInterests;
    }

    @isTest static void testGetAdditionalInterestsByPolicyId() {
        CanaryAMS__Policy__c policy1 = [
            SELECT Id, Name
            FROM CanaryAMS__Policy__c
            WHERE Name = :POLICY_NAME1
        ];
        List<CanaryAMS__Additional_Interests__c> additionalInterests = AdditionalInterests.getAdditionalInterestsByPolicyId(policy1.Id);

        System.assertEquals(additionalInterests.size(), 1);
        System.assertEquals(additionalInterests[0].Name, ADDITIONAL_INTEREST_NAME1);
    }

    @isTest static void testGetCGLCoveragesByPolicyId() {
        CanaryAMS__Policy__c policy1 = [
            SELECT Id, Name
            FROM CanaryAMS__Policy__c
            WHERE Name = :POLICY_NAME1
        ];
        List<CanaryAMS__Coverage__c> cglCoverages1 = AdditionalInterests.getCGLCoveragesByPolicyId(policy1.Id);

        System.assertEquals(cglCoverages1.size(), 1);
        System.assertEquals(cglCoverages1[0].Name, CGL_COVERAGE_NAME);

        CanaryAMS__Policy__c policy2 = [
            SELECT Id, Name
            FROM CanaryAMS__Policy__c
            WHERE Name = :POLICY_NAME2
        ];
        List<CanaryAMS__Coverage__c> cglCoverages2 = AdditionalInterests.getCGLCoveragesByPolicyId(policy2.Id);

        System.assertEquals(cglCoverages2.size(), 0);
    }
}
