@isTest
public with sharing class RenewalQuotesTest {
    private static String INDUSTRY_NAME = 'food';
    private static String FLOW_NAME = 'food';
    private static String ACCOUNT_NAME = 'Test Account';
    private static String QUOTE_NAME = 'test quote';
    private static String POLICY_NAME_1 = 'test policy 1';
    private static String POLICY_NAME_2 = 'test policy 2';
    private static String POLICY_NAME_3 = 'test policy 3';

    @testSetup
    static void setup(){
        Industry__c testIndustry = new Industry__c(
            Slug__c = INDUSTRY_NAME
        );
        insert testIndustry;

        Flow__c testFlow = new Flow__c(
            Slug__c = FLOW_NAME
        );
        insert testFlow;

        Account testAccount = new Account(
            name = ACCOUNT_NAME,
            Industry_Rel__c = testIndustry.Id,
            Flow__c = testFlow.Id
        );

        insert testAccount;

        CanaryAMS__Insurance_Product__c testQuote = new CanaryAMS__Insurance_Product__c(
            Name = QUOTE_NAME,
            CanaryAMS__Account__c = testAccount.Id,
            CanaryAMS__Transaction_Type__c = 'Renewal'
        );

        insert testQuote;

        CanaryAMS__Policy__c testPolicy1 = new CanaryAMS__Policy__c(
            Name = POLICY_NAME_1,
            CanaryAMS__Policy_Number__c = 'policy-number-1',
            CanaryAMS__Effective_Date__c = Date.newInstance(2020, 2, 21),
            Zen_Renewal_Quote__c = testQuote.Id
        );

        CanaryAMS__Policy__c testPolicy2 = new CanaryAMS__Policy__c(
            Name = POLICY_NAME_2,
            CanaryAMS__Policy_Number__c = 'policy-number-2',
            CanaryAMS__Effective_Date__c = Date.newInstance(2020, 2, 21),
            Zen_Renewal_Quote__c = testQuote.Id
        );

        CanaryAMS__Policy__c testPolicy3 = new CanaryAMS__Policy__c(
            Name = POLICY_NAME_3,
            CanaryAMS__Policy_Number__c = 'policy-number-3',
            CanaryAMS__Effective_Date__c = Date.newInstance(2020, 2, 21)
        );

        insert testPolicy1;
        insert testPolicy2;
        insert testPolicy3;
    }

    @isTest static void testGetRenewingPolicyIds() {
        CanaryAMS__Insurance_Product__c quote = [
            SELECT Id, Name
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME
        ];

        List<String> policyNames = new List<String>{POLICY_NAME_1, POLICY_NAME_2};

        List<CanaryAMS__Policy__c> policies = [
            SELECT Id, Name
            FROM CanaryAMS__Policy__c
            WHERE Name IN :policyNames
        ];

        List<String> renewingPolicyIds = RenewalQuotes.getRenewingPolicyIds(quote.Id);

        System.assertEquals(renewingPolicyIds.size(), 2);
        for (CanaryAMS__Policy__c policy : policies) {
            String policyId = policy.Id;
            System.assert(renewingPolicyIds.contains(policyId));
        }
    }

    @isTest static void testClaimExistsForRenewingPolicies() {
        CanaryAMS__Insurance_Product__c quote = [
            SELECT Id, Name
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME
        ];

        Boolean claimExistsInitially = RenewalQuotes.claimExistsForRenewingPolicies(quote.Id);

        System.assertEquals(claimExistsInitially, false);

        CanaryAMS__Policy__c policy1 = [
            SELECT Id, Name
            FROM CanaryAMS__Policy__c
            WHERE Name = :POLICY_NAME_1
        ];

        CanaryAMS__Claim__c testClaim = new CanaryAMS__Claim__c(
            Name = 'test claim',
            Zen_Claim_Code__c = 'AB',
            Coverage_Type__c = 'Auto',
            CanaryAMS__Policy__c = policy1.Id
        );

        insert testClaim;

        Boolean claimExists = RenewalQuotes.claimExistsForRenewingPolicies(quote.Id);

        System.assertEquals(claimExists, true);
    }
}
