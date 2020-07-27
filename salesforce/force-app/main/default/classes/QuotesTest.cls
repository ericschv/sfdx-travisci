@isTest
private with sharing class QuotesTest {
    private static String QUOTE_NAME1 = 'test quote 1';
    private static String QUOTE_NAME2 = 'test quote 2';
    private static String QUOTE_NAME3 = 'Test Checkout Expiration Quote';
    private static String COVERAGE_NAME = 'test cov';
    private static String INDUSTRY_NAME = 'test industry';
    private static String ACCOUNT_NAME = 'test account';
    private static String USER_EMAIL = 'apextest@zensurance.com';
    private static String USER_ALIAS = 'apextest';
    private static String USER_FIRST_NAME = 'Apex';
    private static String USER_LAST_NAME = 'Test';
    private static String USER_NAME = USER_FIRST_NAME + ' ' + USER_LAST_NAME;

    @testSetup static void setup() {
        Industry__c industry = new Industry__c( Name = INDUSTRY_NAME );

        Account acc1 = new Account(
            Name = ACCOUNT_NAME,
            Industry_Rel__c = industry.Id
        );

        insert industry;
        insert acc1;

        CanaryAMS__Insurance_Product__c quote1 = new CanaryAMS__Insurance_Product__c(
            Name = QUOTE_NAME1,
            CanaryAMS__Account__c = acc1.Id,
            CanaryAMS__Stage__c = Quotes.CLOSED_WON_STATUS,
            CanaryAMS__Closed_Won_Date__c = Date.today()
        );

        CanaryAMS__Insurance_Product__c quote2 = new CanaryAMS__Insurance_Product__c(
            Name = QUOTE_NAME2,
            CanaryAMS__Account__c = acc1.Id,
            CanaryAMS__Transaction_Type__c = 'New Business'
        );

        CanaryAMS__Insurance_Product__c quote3 = new CanaryAMS__Insurance_Product__c(
            Name = QUOTE_NAME3,
            CanaryAMS__Account__c = acc1.Id,
            CanaryAMS__Transaction_Type__c = 'Renewal'
        );

        CanaryAMS__Coverage__c cov1 = new CanaryAMS__Coverage__c(
            Name = COVERAGE_NAME
        );
        cov1.Agency_Fee__c = 100;
        cov1.Carrier_Fee__c = 50;
        cov1.CanaryAMS__Current_Term_Amount__c = 200; //premium

        insert quote1;
        insert quote2;
        insert quote3;

        cov1.CanaryAMS__Insurance_Product__c = quote1.Id;
        insert cov1;

        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User user = new User(
            UserName=USER_EMAIL,
            Email=USER_EMAIL,
            Alias=USER_ALIAS,
            FirstName=USER_FIRST_NAME,
            LastName=USER_LAST_NAME,
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_CA',
            LanguageLocaleKey='en_US',
            EmailEncodingKey='UTF-8',
            ProfileId=profile.Id
        );

        insert user;

        CanaryAMS__Producers__c producer = new CanaryAMS__Producers__c(
            Name=USER_NAME, CanaryAMS__Type__c = 'Producer'
        );

        insert producer;
    }

    @isTest static void testGetQuoteForUpdate() {
        CanaryAMS__Insurance_Product__c quote = [
            SELECT Id, Name
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME1
        ];
        
        CanaryAMS__Insurance_Product__c queriedQuote = Quotes.getQuoteForUpdate(quote.Id);

        System.assertEquals(quote.Name, QUOTE_NAME1);
        System.assertEquals(queriedQuote.Name, QUOTE_NAME1);
        System.assertEquals(quote.Id, queriedQuote.Id);
    }

    @isTest static void testCalculateQuotePremiumAndFees() {
        CanaryAMS__Insurance_Product__c quote = [
            SELECT Id, Name
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME1
        ];
        CanaryAMS__Coverage__c cov1 = [
            SELECT
                Id, Name, CanaryAMS__Insurance_Product__c, Agency_Fee__c,
                Carrier_Fee__c, CanaryAMS__Current_Term_Amount__c
            FROM CanaryAMS__Coverage__c
            WHERE Name = :COVERAGE_NAME
        ];

        CanaryAMS__Insurance_Product__c calculatedQuote = Quotes.calculateQuotePremiumAndFees(quote.Id);

        System.assertEquals(cov1.CanaryAMS__Insurance_Product__c, quote.Id);
        System.assertEquals(calculatedQuote.Zen_Calculated_Agency_Fee__c, cov1.Agency_Fee__c);
        System.assertEquals(calculatedQuote.Zen_Calculated_Carrier_Fee__c, cov1.Carrier_Fee__c);
        System.assertEquals(calculatedQuote.Zen_Calculated_Premium__c, cov1.CanaryAMS__Current_Term_Amount__c);
    }


    @isTest static void testGetRenewalPolicies() {
        CanaryAMS__Insurance_Product__c quote = [
            SELECT Id, Name
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME1
        ];

        CanaryAMS__Policy__c policy1 = new CanaryAMS__Policy__c();
        policy1.Name = 'General Liability';
        policy1.CanaryAMS__Policy_Number__c = '4252345';
        policy1.Zen_Renewal_Quote__c = quote.Id;
        insert policy1;

        CanaryAMS__Policy__c policy2 = new CanaryAMS__Policy__c();
        policy2.Name = 'Professional Liability';
        policy2.CanaryAMS__Policy_Number__c = '2f233';
        policy2.Zen_Renewal_Quote__c = quote.Id;
        insert policy2;

        CanaryAMS__Coverage__c coverage1 = new CanaryAMS__Coverage__c();
        coverage1.Name = 'Coverage 1';
        coverage1.CanaryAMS__Policy__c = policy1.Id;
        insert coverage1;

        CanaryAMS__Coverage__c coverage2 = new CanaryAMS__Coverage__c();
        coverage2.Name = 'Coverage 2';
        coverage2.CanaryAMS__Policy__c = policy2.Id;
        insert coverage2;

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


        Test.startTest();
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PolicyEndorsementsTestResource');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        
        List<Policies.ExtendedPolicy> policies = Quotes.getRenewalPolicies(quote.Id);

        System.assertEquals(policies.size(), 2);
        System.assertEquals(policies[0].endorsements.size(), 0);
        System.assertEquals(policies[0].coverages.size(), 1);
        System.assertEquals(policies[0].coverages[0].Id, coverage1.Id);
        System.assertEquals(policies[0].claims.size(), 1);
        

        Test.stopTest();
    }

    @isTest static void testCopyOwnerToProducer() {
        List<CanaryAMS__Insurance_Product__c> quotesToCopyField = new List<CanaryAMS__Insurance_Product__c>();

        User user = [
            SELECT Id
            FROM User
            WHERE Name = :USER_NAME
        ];

        CanaryAMS__Producers__c producer = [
            SELECT Id
            FROM CanaryAMS__Producers__c
            WHERE Name = :USER_NAME
        ];

        CanaryAMS__Insurance_Product__c quote1 = [
            SELECT Id, Name, OwnerId
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME1
        ];

        CanaryAMS__Insurance_Product__c quote2 = [
            SELECT Id, Name, OwnerId
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME2
        ];

        quotesToCopyField.add(quote1);
        quotesToCopyField.add(quote2);

        quote1.OwnerId = user.Id;
        quote2.OwnerId = user.Id;

        Quotes.copyOwnerToProducer(quotesToCopyField);

        System.assertEquals(quote1.CanaryAMS__Producer__c, producer.Id);
        System.assertEquals(quote2.CanaryAMS__Producer__c, producer.Id);

        quote1.OwnerId = Quotes.INSURANCE_ZENSURANCE_USER_ID;

        Quotes.copyOwnerToProducer(quotesToCopyField);

        System.assertEquals(quote1.CanaryAMS__Producer__c, NULL);
        System.assertEquals(quote2.CanaryAMS__Producer__c, producer.Id);

        quote1.OwnerId = Quotes.ASSIGNMENT_FALLBACK_USER_ID;

        Quotes.copyOwnerToProducer(quotesToCopyField);

        System.assertEquals(quote1.CanaryAMS__Producer__c, NULL);
        System.assertEquals(quote2.CanaryAMS__Producer__c, producer.Id);

        quote2.OwnerId = NULL;

        Quotes.copyOwnerToProducer(quotesToCopyField);

        System.assertEquals(quote1.CanaryAMS__Producer__c, NULL);
        System.assertEquals(quote2.CanaryAMS__Producer__c, NULL);

        CanaryAMS__Producers__c producerWithDuplicateName = new CanaryAMS__Producers__c(
            Name=USER_NAME, CanaryAMS__Type__c = 'CSR'
        );
        insert producerWithDuplicateName;
        quote1.OwnerId = user.Id;

        Quotes.copyOwnerToProducer(quotesToCopyField);

        System.assertEquals(quote1.CanaryAMS__Producer__c, producer.Id);
        System.assertEquals(quote2.CanaryAMS__Producer__c, NULL);
    }

    @isTest static void testGetClosedDate() {
        CanaryAMS__Insurance_Product__c quote = [
            SELECT Id, Name, CanaryAMS__Stage__c, CanaryAMS__Closed_Won_Date__c, CanaryAMS__Closed_Lost_Date__c
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME1
        ];

        System.assertEquals(Quotes.getClosedDate(quote), Date.today());
    }


    @isTest static void testUpdateCheckoutExpirationDateRenewal() {
        CanaryAMS__Insurance_Product__c renewalQuote = [
            SELECT Id, Name, OwnerId, Ready_to_Purchase__c
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME3
        ];

        renewalQuote.Ready_to_Purchase__c = true;
        update renewalQuote;

        CanaryAMS__Insurance_Product__c updatedRenewalQuote = [
            SELECT Id, Name, OwnerId, Zen_Checkout_Link_Expiration_Date__c
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME3
        ];

        System.assertEquals(updatedRenewalQuote.Zen_Checkout_Link_Expiration_Date__c, Date.today().addDays(60));
    }

    @isTest static void testUpdateCheckoutExpirationDateNewBiz() {
        CanaryAMS__Insurance_Product__c newBizQuote = [
            SELECT Id, Name, OwnerId, Ready_to_Purchase__c
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME2
        ];

        newBizQuote.Ready_to_Purchase__c = true;
        update newBizQuote;

        CanaryAMS__Insurance_Product__c updatedNewBizQuote = [
            SELECT Id, Name, OwnerId, Zen_Checkout_Link_Expiration_Date__c
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME2
        ];

        System.assertEquals(updatedNewBizQuote.Zen_Checkout_Link_Expiration_Date__c, Date.today().addDays(30));
    }

    @isTest static void testUpdateExpirationDate() {
        CanaryAMS__Insurance_Product__c quote = [
            SELECT Id, Name, OwnerId, Ready_to_Purchase__c, CanaryAMS__Policy_Effective_Date__c, CanaryAMS__Quoted_Term__c, CanaryAMS__Policy_Expiration_Date__c
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME1
        ];

        quote.CanaryAMS__Policy_Effective_Date__c = Date.newInstance(2020, 2, 17);
        quote.CanaryAMS__Quoted_Term__c = 'asdf';

        update quote;

        CanaryAMS__Insurance_Product__c refreshedQuote = [
            SELECT Id, Name, OwnerId, Ready_to_Purchase__c, CanaryAMS__Policy_Effective_Date__c, CanaryAMS__Quoted_Term__c, CanaryAMS__Policy_Expiration_Date__c
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME1
        ];

        System.assertEquals(refreshedQuote.CanaryAMS__Policy_Expiration_Date__c, null);

        quote.CanaryAMS__Policy_Effective_Date__c = Date.newInstance(2020, 2, 17);
        quote.CanaryAMS__Quoted_Term__c = '12 Month';

        update quote;

        refreshedQuote = [
            SELECT Id, Name, OwnerId, Ready_to_Purchase__c, CanaryAMS__Policy_Effective_Date__c, CanaryAMS__Quoted_Term__c, CanaryAMS__Policy_Expiration_Date__c
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME1
        ];

        System.assertEquals(refreshedQuote.CanaryAMS__Policy_Expiration_Date__c, refreshedQuote.CanaryAMS__Policy_Effective_Date__c.addMonths(12));


        quote.CanaryAMS__Policy_Effective_Date__c = Date.newInstance(2020, 2, 17);
        quote.CanaryAMS__Quoted_Term__c = '1 Month';

        update quote;

        refreshedQuote = [
            SELECT Id, Name, OwnerId, Ready_to_Purchase__c, CanaryAMS__Policy_Effective_Date__c, CanaryAMS__Quoted_Term__c, CanaryAMS__Policy_Expiration_Date__c
            FROM CanaryAMS__Insurance_Product__c
            WHERE Name = :QUOTE_NAME1
        ];

        System.assertEquals(refreshedQuote.CanaryAMS__Policy_Expiration_Date__c, refreshedQuote.CanaryAMS__Policy_Effective_Date__c.addMonths(1));

    }
}
