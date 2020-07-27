@isTest
private with sharing class QuoteCoveragesTest {
    private static String POLICY_NAME = 'policy';
    private static String QUOTE_NAME = 'quote';
    private static String RENEWAL_QUOTE_NAME = 'renewal quote';
    private static String CARRIER_NAME_1 = 'carrier1';
    private static String CARRIER_NAME_2 = 'carrier2';
    private static String COVERAGE_NAME_1 = 'cov1';
    private static String COVERAGE_NAME_2 = 'cov2';
    private static String COVERAGE_NAME_3 = 'cov3';
    private static String COVERAGE_NAME_4 = 'cov4';
    private static String COVERAGE_NAME_5 = 'cov5';
    private static String INDUSTRY_NAME = 'test industry';
    private static String ACCOUNT_NAME = 'test account';
    
    @TestSetup static void setup() {
        Industry__c industry = new Industry__c( Name = INDUSTRY_NAME );

        Account acc1 = new Account(
            Name = ACCOUNT_NAME,
            Industry_Rel__c = industry.Id
        );

        insert industry;
        insert acc1;

        // carriers for coverages
        CanaryAMS__Carrier__c carrier1 = new CanaryAMS__Carrier__c(
            Name = CARRIER_NAME_1,
            Logo_URL__c = 'https://zensurance.com/logo.1.png'
        );
        CanaryAMS__Carrier__c carrier2 = new CanaryAMS__Carrier__c(
            Name = CARRIER_NAME_2,
            Logo_URL__c = 'https://zensurance.com/logo.2.png'
        );

        CanaryAMS__Carrier__c zenCarrier = new CanaryAMS__Carrier__c(
            Name = Carriers.ZEN_MGA_CARRIER_NAME,
            Logo_URL__c = 'https://zensurance.com/logo.2.png'
        );

        insert carrier1;  
        insert carrier2;
        insert zenCarrier;

        CanaryAMS__Carrier_Product__c zenCarrierProduct = new CanaryAMS__Carrier_Product__c();
        zenCarrierProduct.Name = 'ZenCarrierProductName';
        zenCarrierProduct.CanaryAMS__Carrier__c = zenCarrier.Id;
        insert zenCarrierProduct;

        CanaryAMS__Policy__c policy = new CanaryAMS__Policy__c( Name = POLICY_NAME );
        CanaryAMS__Insurance_Product__c quote = new CanaryAMS__Insurance_Product__c(
            Name = QUOTE_NAME,
            CanaryAMS__Account__c = acc1.Id,
            CanaryAMS__Quoted_Carrier__c = zenCarrier.Id,
            CanaryAMS__Quoted_Carrier_Product__c = zenCarrierProduct.Id
        );
        CanaryAMS__Insurance_Product__c renewalQuote = new CanaryAMS__Insurance_Product__c(
            Name = RENEWAL_QUOTE_NAME,
            CanaryAMS__Account__c = acc1.Id,
            CanaryAMS__Transaction_Type__c = 'Renewal'
        );

        // coverages for quote
        CanaryAMS__Coverage__c cov1 = new CanaryAMS__Coverage__c(
            Name = COVERAGE_NAME_1,
            API_Coverage_Id__c = 'liability',
            API_Coverage_Name__c = 'Liability',
            API_Coverage_Slug__c = 'liability',
            API_Policy_Initial_Availability__c = 'public',
            API_Coverage_Initial_Availability__c = 'public',
            API_Policy_Id__c = 'general_liability',
            API_Policy_Name__c = 'General Liability',
            API_Policy_Slug__c = 'general_liability',
            Carrier__c = carrier1.Id,
            Agency_Fee__c = 100,
            Carrier_Fee__c = 100,
            CanaryAMS__Current_Term_Amount__c = 100
        );
        CanaryAMS__Coverage__c cov2 = new CanaryAMS__Coverage__c(
            Name = COVERAGE_NAME_2,
            API_Coverage_Id__c = 'liability',
            API_Coverage_Name__c = 'Liability',
            API_Coverage_Slug__c = 'liability',
            API_Policy_Initial_Availability__c = 'public',
            API_Coverage_Initial_Availability__c = 'public',
            API_Policy_Id__c = 'professional_liability',
            API_Policy_Name__c = 'Professional Liability',
            API_Policy_Slug__c = 'professional_liability',
            Carrier__c = zenCarrier.Id,
            Agency_Fee__c = 100,
            Carrier_Fee__c = 100,
            CanaryAMS__Current_Term_Amount__c = 100
        );
        CanaryAMS__Coverage__c cov3 = new CanaryAMS__Coverage__c(
            Name = COVERAGE_NAME_3,
            API_Coverage_Id__c = 'contents',
            API_Coverage_Name__c = 'Contents',
            API_Coverage_Slug__c = 'contents',
            API_Policy_Initial_Availability__c = 'public',
            API_Coverage_Initial_Availability__c = 'public',
            API_Policy_Id__c = 'general_liability',
            API_Policy_Name__c = 'General Liability',
            API_Policy_Slug__c = 'general_liability',
            Carrier__c = carrier1.Id,
            Agency_Fee__c = 100,
            Carrier_Fee__c = 100,
            CanaryAMS__Current_Term_Amount__c = 100
        );
        
        //coverages for policy
        CanaryAMS__Coverage__c cov4 = new CanaryAMS__Coverage__c( Name = COVERAGE_NAME_4 );

        insert quote;

        insert renewalQuote;

        policy.CanaryAMS__Product__c = quote.Id;
        insert policy;

        cov1.CanaryAMS__Insurance_Product__c = quote.Id;
        insert cov1;

        cov2.CanaryAMS__Insurance_Product__c = quote.Id;
        insert cov2;
        
        cov3.CanaryAMS__Insurance_Product__c = quote.Id;
        insert cov3;

        cov4.CanaryAMS__Policy__c = policy.Id;
        insert cov4;
    }
    
    @isTest static void testGetQuoteCoveragesForPolicies() {
       CanaryAMS__Policy__c policy = [
            SELECT Id, Name
            FROM CanaryAMS__Policy__c
            WHERE Name = :POLICY_NAME
        ];
        CanaryAMS__Coverage__c cov4 = [
            SELECT Id, Name, CanaryAMS__Policy__c
            FROM CanaryAMS__Coverage__c
            WHERE Name = :COVERAGE_NAME_4
        ];

        List<CanaryAMS__Coverage__c> policyCoveragesList = QuoteCoverages.getQuoteCoverages(
            String.valueOf(policy.Id),
            'CanaryAMS__Policy__c'
        );
        System.assertEquals(policyCoveragesList.size(), 1);
        System.assert(policyCoveragesList.contains(cov4), 'Expected ' + String.valueOf(policyCoveragesList) + ' to contain ' + String.valueOf(cov4));
    }

    @isTest static void testGetQuoteCoveragesForQuotes() {
        CanaryAMS__Insurance_Product__c quote = [
            SELECT Id, Name
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME
        ];
        CanaryAMS__Coverage__c cov1 = [
            SELECT Id
            FROM CanaryAMS__Coverage__c
            WHERE Name = :COVERAGE_NAME_1
        ];
        CanaryAMS__Coverage__c cov2 = [
            SELECT Id
            FROM CanaryAMS__Coverage__c
            WHERE Name = :COVERAGE_NAME_2
        ];
        CanaryAMS__Coverage__c cov3 = [
            SELECT Id
            FROM CanaryAMS__Coverage__c
            WHERE Name = :COVERAGE_NAME_3
        ];

        List<CanaryAMS__Coverage__c> quoteCoveragesList = QuoteCoverages.getQuoteCoverages(
            String.valueOf(quote.Id),
            'CanaryAMS__Insurance_Product__c'
        );

        List<String> quoteCoverageIds = new List<String>();

        for (CanaryAMS__Coverage__c coverage: quoteCoveragesList) {
            quoteCoverageIds.add(coverage.Id);
        }

        System.assertEquals(quoteCoveragesList.size(), 3, 'Expected ' + String.valueOf(quoteCoveragesList) + ' to be of size');
        System.assert(quoteCoverageIds.contains(cov1.Id), 'Expected ' + String.valueOf(quoteCoverageIds) + ' to contain ' + String.valueOf(cov1.Id));
        System.assert(quoteCoverageIds.contains(cov2.Id), 'Expected ' + String.valueOf(quoteCoverageIds) + ' to contain ' + String.valueOf(cov2.Id));        
        System.assert(quoteCoverageIds.contains(cov3.Id), 'Expected ' + String.valueOf(quoteCoverageIds) + ' to contain ' + String.valueOf(cov3.Id));
    }

    @isTest static void testGetQuoteCoveragesWithPolicyId() {
        CanaryAMS__Policy__c policy = [
            SELECT Id, Name
            FROM CanaryAMS__Policy__c
            WHERE Name = :POLICY_NAME
        ];

        List<CanaryAMS__Coverage__c> quoteCoveragesList = QuoteCoverages.getQuoteCoveragesWithPolicyId(policy.Id);

        System.assertEquals(quoteCoveragesList.size(), 1, 'Expected ' + String.valueOf(quoteCoveragesList));
    }

    @isTest static void testUpsertQuoteCoverages() {
        CanaryAMS__Coverage__c cov1 = [
            SELECT Id, Name, CanaryAMS__Insurance_Product__c
            FROM CanaryAMS__Coverage__c
            WHERE Name = :COVERAGE_NAME_1
        ];

        String COV_NEW_NAME = 'Coverage new name';
        cov1.Name = COV_NEW_NAME;

        CanaryAMS__Coverage__c cov5 = new CanaryAMS__Coverage__c( Name = COVERAGE_NAME_5 );

        List<CanaryAMS__Coverage__c> coverageList = new List<CanaryAMS__Coverage__c>();
        coverageList.add(cov1);
        coverageList.add(cov5);

        String result = QuoteCoverages.upsertQuoteCoverages(coverageList);

        List<CanaryAMS__Coverage__c> coverages = [
            SELECT Id, Name
            FROM CanaryAMS__Coverage__c
        ];
        CanaryAMS__Coverage__c updatedCov1 = [
            SELECT Id, Name
            FROM CanaryAMS__Coverage__c
            WHERE Name = :COV_NEW_NAME
        ];

        System.assertEquals(result, QuoteCoverages.STATUS_COVERAGES_UPDATED);
        System.assertEquals(coverages.size(), 5, 'Expected ' + String.valueOf(coverages) + ' to be of size');
        System.assert(coverages.contains(cov5), 'Expected ' + String.valueOf(coverages) + ' to contain ' + String.valueOf(cov5));
        System.assertEquals(updatedCov1.Name, COV_NEW_NAME);
    }

    @isTest static void testDeleteQuoteCoverages() {
        CanaryAMS__Coverage__c cov1 = [
            SELECT Id, Name, CanaryAMS__Insurance_Product__c
            FROM CanaryAMS__Coverage__c
            WHERE Name = :COVERAGE_NAME_1
        ];
        CanaryAMS__Coverage__c cov2 = [
            SELECT Id, Name, CanaryAMS__Insurance_Product__c
            FROM CanaryAMS__Coverage__c
            WHERE Name = :COVERAGE_NAME_2
        ];

        List<CanaryAMS__Coverage__c> coverageList = new List<CanaryAMS__Coverage__c>();
        coverageList.add(cov1);
        coverageList.add(cov2);

        String result = QuoteCoverages.deleteQuoteCoverages(coverageList);

        List<CanaryAMS__Coverage__c> coverages = [
            SELECT Id, Name
            FROM CanaryAMS__Coverage__c
        ];

        System.assertEquals(result, QuoteCoverages.STATUS_COVERAGES_DELETED);
        System.assertEquals(coverages.size(), 2, 'Expected ' + String.valueOf(coverages) + ' to be of size');
    }

    @isTest static void testGroupQuoteCoveragesByCarrierAndPolicy() {
        CanaryAMS__Insurance_Product__c quote = [SELECT Id, CanaryAMS__Quoted_Carrier_Product__c FROM CanaryAMS__Insurance_Product__c WHERE Name = :QUOTE_NAME];

        List<Policies.GroupedPolicy> groupedPolicies = QuoteCoverages.groupQuoteCoveragesByCarrierAndPolicy(quote.Id);

        System.assertEquals(groupedPolicies[0].carrierProduct, quote.CanaryAMS__Quoted_Carrier_Product__c, 'Expected ' + groupedPolicies[0].carrierProduct + ' to equal ' + quote.CanaryAMS__Quoted_Carrier_Product__c);
        System.assertEquals(groupedPolicies.size(), 2, 'Expected ' + String.valueOf(groupedPolicies.size()) + ' to equal 2');
    }

    @isTest static void testGroupQuoteCoveragesByPreviousPolicy() {
        CanaryAMS__Insurance_Product__c renewalQuote = [
            SELECT Id
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :RENEWAL_QUOTE_NAME
        ];
        CanaryAMS__Policy__c previousPolicy = [
            SELECT Id
            FROM CanaryAMS__Policy__c
            WHERE Name = :POLICY_NAME
        ];
        CanaryAMS__Coverage__c cov1 = [
            SELECT Id
            FROM CanaryAMS__Coverage__c
            WHERE Name = :COVERAGE_NAME_1
        ];
        CanaryAMS__Coverage__c cov2 = [
            SELECT Id
            FROM CanaryAMS__Coverage__c
            WHERE Name = :COVERAGE_NAME_2
        ];
        CanaryAMS__Coverage__c cov3 = [
            SELECT Id
            FROM CanaryAMS__Coverage__c
            WHERE Name = :COVERAGE_NAME_3
        ];

        // Update coverages for renewal quote
        cov1.CanaryAMS__Insurance_Product__c = renewalQuote.Id;
        cov2.CanaryAMS__Insurance_Product__c = renewalQuote.Id;
        cov3.CanaryAMS__Insurance_Product__c = renewalQuote.Id;
        cov1.Zen_Previous_Policy__c = previousPolicy.Id;
        cov2.Zen_Previous_Policy__c = previousPolicy.Id;
        cov3.Zen_Previous_Policy__c = previousPolicy.Id;

        List<CanaryAMS__Coverage__c> coverageList = new List<CanaryAMS__Coverage__c>();
        coverageList.add(cov1);
        coverageList.add(cov2);
        coverageList.add(cov3);

        QuoteCoverages.upsertQuoteCoverages(coverageList);

        List<Policies.GroupedPolicy> groupedPolicies = QuoteCoverages.groupQuoteCoveragesByPreviousPolicy(renewalQuote.Id);

        System.assertEquals(groupedPolicies.size(), 1, 'Expected ' + String.valueOf(groupedPolicies.size()) + ' to equal 1');
    }
}
