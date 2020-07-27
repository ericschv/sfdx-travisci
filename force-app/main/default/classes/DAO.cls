public with sharing class DAO {

    public Flow__c getFlowBySlug(String slug) {
        return [SELECT Id, Slug__c FROM Flow__c WHERE Slug__c = :slug];
    }

    public Industry__c getIndustryBySlug(String slug) {
        return [SELECT Id, Slug__c FROM Industry__c WHERE Slug__c = :slug];
    }

    public CanaryAMS__Insurance_Product__c getQuoteById(String quoteId) {
        return [SELECT Id, CanaryAMS__Account__c FROM CanaryAMS__Insurance_Product__c WHERE Id = :quoteId];
    }

    public Account getAccountById(String accountId) {
        return [SELECT Id, Industry_Rel__c, Flow__c, Flow__r.Slug__c, Industry_Rel__r.Slug__c FROM Account WHERE Id = :accountId];
    }

    public void upsertAccount(Account account) {
        upsert account;
    }

}
