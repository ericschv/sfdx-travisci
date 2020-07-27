@isTest
private class PoliciesTest {

    public static String TEST_POLICY_NAME = 'Test Policy 1';
    public static String RENEWING_POLICY_NAME_1 = 'Renewing Policy 1';
    public static String RENEWING_POLICY_NAME_2 = 'Renewing Policy 2';
    public static String RENEWING_POLICY_NUMBER_1 = '9348275iu34f';
    public static String RENEWING_POLICY_NUMBER_2 = 'c98h32';
    public static String TEST_CARRIER_1 = 'Carrier 1';
    public static String TEST_COVERAGE_NAME_1 ='General Liability: Liability';
    public static String TEST_COVERAGE_NAME_2 ='Professional Liability: Liability';
    public static String TEST_COVERAGE_NAME_3 ='General Liability: Contents';
    public static String TEST_POLICY_UPDATED_NAME = 'Test Policy 1 Updated Name';
    public static String ACCOUNT_NAME = 'AccountsTest Account';
    public static String FLOW_NAME = 'food';
    public static String INDUSTRY_NAME = 'food';
    public static String ADDITIONAL_INTEREST_NAME = 'Tyler';

    @testSetup static void setup() {
        // Create common test quote, coverages and related records
        CanaryAMS__Policy__c updatablePolicy = new CanaryAMS__Policy__c();
        updatablePolicy.Name = PoliciesTest.TEST_POLICY_NAME;
        insert updatablePolicy;

        Industry__c industry = new Industry__c();
        industry.Slug__c = PoliciesTest.INDUSTRY_NAME;
        insert industry;

        Flow__c flow = new Flow__c();
        flow.Slug__c = PoliciesTest.FLOW_NAME;
        insert flow;

        CanaryAMS__Source_Type__c sourceType = new CanaryAMS__Source_Type__c();
        sourceType.Name = 'World Wide Web Information Superhighway';
        insert sourceType;

        CanaryAMS__Source__c source = new CanaryAMS__Source__c();
        source.CanaryAMS__Source_Type__c = sourceType.Id;
        source.Name = 'website';
        insert source;

        CanaryAMS__Sub_Source__c subsource = new CanaryAMS__Sub_Source__c();
        subsource.Name = 'blue button';
        subsource.CanaryAMS__Source__c = source.Id;
        insert subsource;
        
        Account testAccount = new Account();
        testAccount.name = PoliciesTest.ACCOUNT_NAME;
        testAccount.Industry_Rel__c = industry.Id;
        testAccount.Flow__c = flow.Id;
        insert testAccount;

        CanaryAMS__Insurance_Product__c testQuote = new CanaryAMS__Insurance_Product__c();
        testQuote.CanaryAMS__Total_Agency_Fees__c = 50;
        testQuote.CanaryAMS__Total_Taxes_Fees__c = 20;
        testQuote.CanaryAMS__Quoted_Policy_Premium__c = 500;
        testQuote.CanaryAMS__Account__c = testAccount.Id;
        testQuote.CanaryAMS__Quote_Source__c  = source.Id;
        testQuote.CanaryAMS__Quote_Sub_Source__c = subsource.Id;
        testQuote.ZEN_Query_Param_Adgroup__c = 'adgroup 1';
        testQuote.ZEN_Query_Param_Keyword__c = 'keyword 1';
        testQuote.ZEN_Query_Param_UTM_Campaign__c = 'campaign 1';
        testQuote.ZEN_Query_Param_UTM_Content__c = 'content 1';
        testQuote.ZEN_Query_Param_UTM_Medium__c = 'medium 1';
        testQuote.ZEN_Query_Param_UTM_Source__c = 'source 1';
        testQuote.ZEN_Query_Param_UTM_Term__c = 'term 1';
        insert testQuote;

        CanaryAMS__Carrier__c carrier1 = new CanaryAMS__Carrier__c();
        carrier1.Name = PoliciesTest.TEST_CARRIER_1;
        carrier1.Logo_URL__c = 'https://zensurance.com/logo.1.png';
        insert carrier1;

        CanaryAMS__Carrier__c carrier2 = new CanaryAMS__Carrier__c();
        carrier2.Name = 'Carrier 2';
        carrier2.Logo_URL__c = 'https://zensurance.com/logo.2.png';
        insert carrier2;

        CanaryAMS__Coverage__c testCoverage1 = new CanaryAMS__Coverage__c();
        testCoverage1.API_Coverage_Id__c = 'liability';
        testCoverage1.API_Coverage_Name__c = 'Liability';
        testCoverage1.API_Coverage_Slug__c = 'liability';
        testCoverage1.API_Policy_Initial_Availability__c = 'public';
        testCoverage1.API_Coverage_Initial_Availability__c = 'public';
        testCoverage1.API_Policy_Id__c = 'general_liability';
        testCoverage1.API_Policy_Name__c = 'General Liability';
        testCoverage1.API_Policy_Slug__c = 'general_liability';
        testCoverage1.Name = PoliciesTest.TEST_COVERAGE_NAME_1;
        testCoverage1.Carrier__c = carrier1.Id;
        testCoverage1.CanaryAMS__Insurance_Product__c = testQuote.Id;
        testCoverage1.Agency_Fee__c = 100;
        testCoverage1.Carrier_Fee__c = 100;
        testCoverage1.CanaryAMS__Current_Term_Amount__c = 100;
        insert testCoverage1;

        CanaryAMS__Coverage__c testCoverage2 = new CanaryAMS__Coverage__c();
        testCoverage2.API_Coverage_Id__c = 'liability';
        testCoverage2.API_Coverage_Name__c = 'Liability';
        testCoverage2.API_Coverage_Slug__c = 'liability';
        testCoverage2.API_Policy_Initial_Availability__c = 'public';
        testCoverage2.API_Coverage_Initial_Availability__c = 'public';
        testCoverage2.API_Policy_Id__c = 'professional_liability';
        testCoverage2.API_Policy_Name__c = 'Professional Liability';
        testCoverage2.API_Policy_Slug__c = 'professional_liability';
        testCoverage2.Name = PoliciesTest.TEST_COVERAGE_NAME_2;
        testCoverage2.Carrier__c = carrier2.Id;
        testCoverage2.CanaryAMS__Insurance_Product__c = testQuote.Id;
        testCoverage2.Agency_Fee__c = 100;
        testCoverage2.Carrier_Fee__c = 100;
        testCoverage2.CanaryAMS__Current_Term_Amount__c = 100;
        insert testCoverage2;

        CanaryAMS__Coverage__c testCoverage3 = new CanaryAMS__Coverage__c();
        testCoverage3.API_Coverage_Id__c = 'contents';
        testCoverage3.API_Coverage_Name__c = 'Contents';
        testCoverage3.API_Coverage_Slug__c = 'contents';
        testCoverage3.API_Policy_Initial_Availability__c = 'public';
        testCoverage3.API_Coverage_Initial_Availability__c = 'public';
        testCoverage3.API_Policy_Id__c = 'general_liability';
        testCoverage3.API_Policy_Name__c = 'General Liability';
        testCoverage3.API_Policy_Slug__c = 'general_liability';
        testCoverage3.Name = PoliciesTest.TEST_COVERAGE_NAME_3;
        testCoverage3.Carrier__c = carrier1.Id;
        testCoverage3.CanaryAMS__Insurance_Product__c = testQuote.Id;
        testCoverage3.Agency_Fee__c = 100;
        testCoverage3.Carrier_Fee__c = 100;
        testCoverage3.CanaryAMS__Current_Term_Amount__c = 100;
        insert testCoverage3;


        CanaryAMS__Additional_Interests__c additionalInterest = new CanaryAMS__Additional_Interests__c();
        additionalInterest.Name = ADDITIONAL_INTEREST_NAME;
        additionalInterest.CanaryAMS__Address_1__c = '123 Fake St.';
        additionalInterest.CanaryAMS__City__c = 'Toronto';
        additionalInterest.CanaryAMS__Country__c = 'Canada';
        additionalInterest.CanaryAMS__StateProvCd__c = 'Ontario';
        additionalInterest.CanaryAMS__PostalCode__c = 'M2M 2M2';
        additionalInterest.CanaryAMS__Type__c = 'Additional Insured';
        additionalInterest.CanaryAMS__Notes__c = 'Notes';
        additionalInterest.Effective_Date__c = Date.today();
        additionalInterest.CanaryAMS__Insurance_Quote__c = testQuote.Id;

        insert additionalInterest;
    }

    @isTest static void testCalculatePolicyPremiumAndFees() {
        CanaryAMS__Policy__c policy = [SELECT Id FROM CanaryAMS__Policy__c WHERE Name=:TEST_POLICY_NAME LIMIT 1];

        List<String> coverageNames = new List<String>{
            PoliciesTest.TEST_COVERAGE_NAME_1,
            PoliciesTest.TEST_COVERAGE_NAME_2,
            PoliciesTest.TEST_COVERAGE_NAME_3
        };

        List<CanaryAMS__Coverage__c> coverages = [
            SELECT Id
            FROM CanaryAMS__Coverage__c
            WHERE Name IN :coverageNames
        ];
        
        for (CanaryAMS__Coverage__c coverage: coverages) {
            coverage.CanaryAMS__Policy__c = policy.Id;
        }

        update coverages;

        AggregateResult coverageTotal = [
            SELECT
                SUM(Agency_Fee__c)agencyfee,
                SUM(Carrier_Fee__c)carrierfee,
                SUM(CanaryAMS__Current_Term_Amount__c)premium
            FROM CanaryAMS__Coverage__c
            WHERE Name IN :coverageNames
        ][0];

        CanaryAMS__Policy__c calculatedPolicy = Policies.calculatePolicyPremiumAndFees(policy.Id);

        System.assertEquals(calculatedPolicy.CanaryAMS__Total_Agency_Fees__c, coverageTotal.get('agencyfee'));
        System.assertEquals(calculatedPolicy.CanaryAMS__Total_Taxes_Fees__c, coverageTotal.get('carrierfee'));
        System.assertEquals(calculatedPolicy.CanaryAMS__Net_Premium__c, coverageTotal.get('premium'));
    }

    @isTest static void testFindExistingPolicies() {
        List<string> policyNumbers = new List<string>{'test0', 'test1'};
        Date effectiveDate = Date.newInstance(2020, 10, 10);

        List<CanaryAMS__Policy__c> existingPolicies = Policies.findExistingPolicies(policyNumbers, effectiveDate);
        System.assertEquals(existingPolicies.size(), 0);

        CanaryAMS__Policy__c policy = [SELECT Id, Name FROM CanaryAMS__Policy__c WHERE Name = :PoliciesTest.TEST_POLICY_NAME];

        policy.CanaryAMS__Policy_Number__c = 'test0';
        update policy;

        existingPolicies = Policies.findExistingPolicies(policyNumbers, effectiveDate);
        System.assertEquals(existingPolicies.size(), 0);

        policy.CanaryAMS__Effective_Date__c = Date.newInstance(2020, 10, 10);
        update policy;
        
        existingPolicies = Policies.findExistingPolicies(policyNumbers, effectiveDate);
        System.assertEquals(existingPolicies.size(), 1);
    }

    @isTest static void testCreatePolicyWithCoverages() {
        Account account = [SELECT Name, Id FROM Account WHERE Name = :PoliciesTest.ACCOUNT_NAME];
        CanaryAMS__Insurance_Product__c quote = [SELECT Id, Name, CanaryAMS__Quote_Source__c, CanaryAMS__Quote_Sub_Source__c, ZEN_Query_Param_Adgroup__c, ZEN_Query_Param_Keyword__c, ZEN_Query_Param_UTM_Campaign__c, ZEN_Query_Param_UTM_Content__c, ZEN_Query_Param_UTM_Medium__c, ZEN_Query_Param_UTM_Source__c, ZEN_Query_Param_UTM_Term__c FROM CanaryAMS__Insurance_Product__c WHERE CanaryAMS__Account__c = :account.Id];

        List<Policies.GroupedPolicy> groupedPolicies = QuoteCoverages.groupQuoteCoveragesByCarrierAndPolicy(quote.Id);

        Date effectiveDate = Date.newInstance(2020, 6, 15);
        Date expirationDate = Date.newInstance(2020, 10, 31);

        groupedPolicies[0].recordType = '01246000000pkuUAAQ';
        groupedPolicies[0].policyNumber = 'afioaw';
        groupedPolicies[0].billingType = 'Zen One-Pay - Credit Card';
        groupedPolicies[0].effectiveDate = effectiveDate;
        groupedPolicies[0].term = Policies.OTHER_TERM;
        groupedPolicies[0].expirationDate = expirationDate;

        CanaryAMS__Policy__c policy = Policies.createPolicyWithCoverages(groupedPolicies[0], quote.Id);

        List<CanaryAMS__Additional_Interests__c> additionalInterests = [SELECT Id, Name FROM CanaryAMS__Additional_Interests__c WHERE CanaryAMS__Policy__c = :policy.Id];
        System.assertEquals(additionalInterests.size(), 1);
        System.assertEquals(additionalInterests[0].Name, ADDITIONAL_INTEREST_NAME);

        System.assertEquals(policy.Name, quote.Name + ' - General Liability', 'Expected ' + policy.Name + ' to equal ' + quote.Name + ' - General Liability.');
        System.assertEquals(policy.CanaryAMS__Effective_Date__c, effectiveDate);
        System.assertEquals(policy.CanaryAMS__Policy_Term__c, Policies.OTHER_TERM);
        System.assertEquals(policy.CanaryAMS__Renewal_Date_2__c, expirationDate);
        System.assertEquals(policy.CanaryAMS__Policy_Source__c, quote.CanaryAMS__Quote_Source__c);
        System.assertEquals(policy.CanaryAMS__Policy_Sub_Source__c, quote.CanaryAMS__Quote_Sub_Source__c);
        System.assertEquals(policy.ZEN_Query_Param_Adgroup__c, quote.ZEN_Query_Param_Adgroup__c);
        System.assertEquals(policy.ZEN_Query_Param_Keyword__c, quote.ZEN_Query_Param_Keyword__c);
        System.assertEquals(policy.ZEN_Query_Param_UTM_Campaign__c, quote.ZEN_Query_Param_UTM_Campaign__c);
        System.assertEquals(policy.ZEN_Query_Param_UTM_Content__c, quote.ZEN_Query_Param_UTM_Content__c);
        System.assertEquals(policy.ZEN_Query_Param_UTM_Medium__c, quote.ZEN_Query_Param_UTM_Medium__c);
        System.assertEquals(policy.ZEN_Query_Param_UTM_Source__c, quote.ZEN_Query_Param_UTM_Source__c);
        System.assertEquals(policy.ZEN_Query_Param_UTM_Term__c, quote.ZEN_Query_Param_UTM_Term__c);
        System.assertEquals(groupedPolicies[0].coverages.size(), 2, 'Expected ' + groupedPolicies[0].coverages.size() + ' to equal 2.');
        System.assertEquals(groupedPolicies[0].coverages[0].Name, 'General Liability: Liability');
    }

    @isTest static void testGroupedPolicy() {
        CanaryAMS__Carrier__c carrier = [SELECT Id, Name FROM CanaryAMS__Carrier__c WHERE Name = :PoliciesTest.TEST_CARRIER_1];

        
        Policies.GroupedPolicy groupedPolicy = new Policies.GroupedPolicy();
        groupedPolicy.policyName = 'Policy Name';
        groupedPolicy.carrier = carrier;
        groupedPolicy.premium = 500.00;
        groupedPolicy.agencyFee = 20.00;
        groupedPolicy.carrierFee = 10.00;

        List<String> groupedPolicyKeys = new List<String>();
        Set<String> groupedPolicySet = groupedPolicy.getAttributes();
        groupedPolicyKeys.addAll(groupedPolicySet);

        System.assertEquals(30, groupedPolicyKeys.size());
        System.assert(groupedPolicyKeys.contains('policyName') == true);
    }

    @isTest static void testUpsertPolicies() {
        List<CanaryAMS__Policy__c> policyList = new List<CanaryAMS__Policy__c>();

        CanaryAMS__Policy__c originalPolicy = [SELECT Id, Name FROM CanaryAMS__Policy__c WHERE Name = :PoliciesTest.TEST_POLICY_NAME];
        originalPolicy.Name = PoliciesTest.TEST_POLICY_UPDATED_NAME;

        policyList.add(originalPolicy);
        String response = Policies.upsertPolicies(policyList);
        System.assert(response == 'Policies updated successfully.');

        CanaryAMS__Policy__c updatedPolicy = [SELECT Id, Name FROM CanaryAMS__Policy__c WHERE Id = :originalPolicy.Id];
        System.assert(updatedPolicy.Name == PoliciesTest.TEST_POLICY_UPDATED_NAME);
    }


    @isTest static void testGetPoliciesByRenewalQuoteId() {
        Account account = [SELECT Name, Id FROM Account WHERE Name = :PoliciesTest.ACCOUNT_NAME];
        
        CanaryAMS__Insurance_Product__c testQuote = new CanaryAMS__Insurance_Product__c();
        testQuote.CanaryAMS__Account__c = account.Id;
        testQuote.CanaryAMS__Total_Agency_Fees__c = 50;
        testQuote.CanaryAMS__Total_Taxes_Fees__c = 20;
        testQuote.CanaryAMS__Quoted_Policy_Premium__c = 500;
        insert testQuote;


        CanaryAMS__Policy__c renewingPolicy1 = new CanaryAMS__Policy__c();
        renewingPolicy1.Name = PoliciesTest.RENEWING_POLICY_NAME_1;
        renewingPolicy1.CanaryAMS__Policy_Number__c = PoliciesTest.RENEWING_POLICY_NUMBER_1;
        renewingPolicy1.Zen_Renewal_Quote__c = testQuote.Id;
        insert renewingPolicy1;

        CanaryAMS__Policy__c renewingPolicy2 = new CanaryAMS__Policy__c();
        renewingPolicy2.Name = PoliciesTest.RENEWING_POLICY_NAME_2;
        renewingPolicy2.CanaryAMS__Policy_Number__c = PoliciesTest.RENEWING_POLICY_NUMBER_2;
        renewingPolicy2.Zen_Renewal_Quote__c = testQuote.Id;
        insert renewingPolicy2;
        
        
        List<CanaryAMS__Policy__c> policies = Policies.getPoliciesByRenewalQuoteId(testQuote.Id);

        System.assert(policies.size() == 2);
        System.assertEquals(policies[0].Id, renewingPolicy1.Id);
        System.assertEquals(policies[1].Id, renewingPolicy2.Id);
    }

    @isTest static void testSetRenewingPoliciesStatusByQuoteId() {
        Account account = [SELECT Name, Id FROM Account WHERE Name = :PoliciesTest.ACCOUNT_NAME];
        
        CanaryAMS__Insurance_Product__c testQuote = new CanaryAMS__Insurance_Product__c();
        testQuote.CanaryAMS__Account__c = account.Id;
        testQuote.CanaryAMS__Total_Agency_Fees__c = 50;
        testQuote.CanaryAMS__Total_Taxes_Fees__c = 20;
        testQuote.CanaryAMS__Quoted_Policy_Premium__c = 500;
        insert testQuote;


        CanaryAMS__Policy__c renewingPolicy1 = new CanaryAMS__Policy__c();
        renewingPolicy1.Name = PoliciesTest.RENEWING_POLICY_NAME_1;
        renewingPolicy1.CanaryAMS__Policy_Number__c = PoliciesTest.RENEWING_POLICY_NUMBER_1;
        renewingPolicy1.Zen_Renewal_Quote__c = testQuote.Id;
        insert renewingPolicy1;

        CanaryAMS__Policy__c renewingPolicy2 = new CanaryAMS__Policy__c();
        renewingPolicy2.Name = PoliciesTest.RENEWING_POLICY_NAME_2;
        renewingPolicy2.CanaryAMS__Policy_Number__c = PoliciesTest.RENEWING_POLICY_NUMBER_2;
        renewingPolicy2.Zen_Renewal_Quote__c = testQuote.Id;
        insert renewingPolicy2;
        
        
        List<CanaryAMS__Policy__c> policies = Policies.setRenewingPoliciesStatusByQuoteId(testQuote.Id);

        CanaryAMS__Policy__c testPolicy = [SELECT Id, CanaryAMS__Policy_Status__c FROM CanaryAMS__Policy__c WHERE Id = :renewingPolicy1.Id];

        System.assert(policies.size() == 2);
        System.assertEquals(policies[0].Id, renewingPolicy1.Id);
        System.assertEquals(policies[0].CanaryAMS__Policy_Status__c, 'Renewed');
        System.assertEquals(policies[1].Id, renewingPolicy2.Id);
        System.assertEquals(policies[1].CanaryAMS__Policy_Status__c, 'Renewed');
        System.assertEquals(testPolicy.CanaryAMS__Policy_Status__c, 'Renewed');
    }
}