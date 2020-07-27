@isTest
private class DAOTest {
    @isTest static void testGetAccountById() {
        Account  testAccount = new Account();
        testAccount.Name = 'Tyler Test';
        insert testAccount;

        DAO dao = new DAO();
        Account account = dao.getAccountById(testAccount.Id);

        System.assert(account.Id == testAccount.Id);

    }

    @isTest static void testGetIndustryBySlug() {
        Industry__c testIndustry = new Industry__c();
        testIndustry.Slug__c = 'food';
        insert testIndustry;

        DAO dao = new DAO();
        Industry__c industry = dao.getIndustryBySlug(testIndustry.Slug__c);

        System.assert(testIndustry.Id == industry.Id);
    }

    @isTest static void testGetFlowBySlug() {
        Flow__c testFlow = new Flow__c();
        testFlow.Slug__c = 'food';
        insert testFlow;

        DAO dao = new DAO();
        Flow__c flow = dao.getFlowBySlug(testFlow.Slug__c);

        System.assert(testFlow.Id == flow.Id);
    }

    @isTest static void testGetQuoteById() {
        Industry__c industry = new Industry__c( Name = 'food' );
        insert industry;

        Account  testAccount = new Account();
        testAccount.Name = 'Tyler Test';
        testAccount.Industry_Rel__c = industry.Id;
        insert testAccount;
        
        CanaryAMS__Insurance_Product__c testQuote = new CanaryAMS__Insurance_Product__c();
        testQuote.CanaryAMS__Account__c = testAccount.Id;
        insert testQuote;

        DAO dao = new DAO();
        CanaryAMS__Insurance_Product__c quote = dao.getQuoteById(testQuote.Id);

        System.assert(testQuote.Id == quote.Id);
        System.assert(testQuote.CanaryAMS__Account__c == quote.CanaryAMS__Account__c);
    }
}
