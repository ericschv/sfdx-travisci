@isTest
private class AccountsTest {

    public static String ACCOUNT_NAME = 'AccountsTest Account';
    public static String ACCOUNT_NAME_2 = 'AccountsTest Account2';
    public static String FLOW_NAME = 'food';
    public static String INDUSTRY_NAME = 'food';

    @testSetup static void setup() {
        // Create common test account, quote and related records

        Industry__c industry = new Industry__c();
        industry.Slug__c = AccountsTest.INDUSTRY_NAME;
        insert industry;

        Flow__c flow = new Flow__c();
        flow.Slug__c = AccountsTest.FLOW_NAME;
        insert flow;
        
        Account testAccount = new Account();
        testAccount.name = AccountsTest.ACCOUNT_NAME;
        testAccount.Industry_Rel__c = industry.Id;
        testAccount.Flow__c = flow.Id;
        testAccount.BillingCity = 'Toronto';
        testAccount.BillingStreet = '123 Fake Street';
        testAccount.BillingState = 'Ontario';
        testAccount.BillingCountry = 'Canada';

        insert testAccount;


        Account testAccount2 = new Account();
        testAccount2.name = AccountsTest.ACCOUNT_NAME_2;
        testAccount2.Industry_Rel__c = industry.Id;
        testAccount2.Flow__c = flow.Id;
        testAccount2.ShippingCity = 'Vancouver';
        testAccount2.ShippingStreet = '1234 Fake Street';
        testAccount2.ShippingState = 'British Columbia';
        testAccount2.ShippingCountry = 'Canada';
        testAccount2.ShippingPostalCode = 'L0V 4H8';
        testAccount2.BillingCity = 'Vancouver';
        testAccount2.BillingStreet = '1234 Fake Street';
        testAccount2.BillingState = 'British Columbia';
        testAccount2.BillingCountry = 'Canada';
        testAccount2.BillingPostalCode = 'L0V 4H8';

        insert testAccount2;

        CanaryAMS__Insurance_Product__c quote = new CanaryAMS__Insurance_Product__c();
        quote.CanaryAMS__Account__c = testAccount.Id;
        insert quote;        
    }

    @isTest static void testUpdateFlowIndustryFromResumeLink() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetQuestionnaireForAccountResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = :AccountsTest.ACCOUNT_NAME];
        CanaryAMS__Insurance_Product__c quote = [SELECT Id, CanaryAMS__Account__c FROM CanaryAMS__Insurance_Product__c WHERE CanaryAMS__Account__c = :testAccount.Id];      
      
         Account testResponseAccount = Accounts.updateFlowIndustryFromResumeLink(quote.Id, 'qid', 'token');

         System.assert(testResponseAccount.Id == testAccount.Id, 'Expected ' + testResponseAccount.Id + ' to equal ' + testAccount.Id);
    }


    @isTest static void testGetFormattedBillingAddress() {
        Account testAccount = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account WHERE Name = :AccountsTest.ACCOUNT_NAME];
        String formattedAddress = Accounts.getFormattedBillingAddress(testAccount);

        System.assertEquals('123 Fake Street, Toronto, Ontario, Canada', formattedAddress);
    }

    @isTest static void testGetFormattedShippingAddress() {
        Account testAccount = [SELECT Id, Name, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode FROM Account WHERE Name = :AccountsTest.ACCOUNT_NAME_2];
        String formattedAddress = Accounts.getFormattedShippingAddress(testAccount);

        System.assertEquals('1234 Fake Street, Vancouver, British Columbia, Canada, L0V 4H8', formattedAddress);
    }

    @isTest static void testHaveAddressFieldsChanged() {
        Account testAccount = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account WHERE Name = :AccountsTest.ACCOUNT_NAME];
        Account testAccount2 = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account WHERE Name = :AccountsTest.ACCOUNT_NAME_2];
        List<String> addressFields = new List<String>{'BillingStreet', 'BillingCity', 'BillingState', 'BillingPostalCode', 'BillingCountry'};
        Boolean isAddressChanged = Accounts.haveAddressFieldsChanged(testAccount, testAccount2, addressFields);

        System.assertEquals(true, isAddressChanged);
    }


}