public with sharing class Coverages {
    
    public static List<CanaryAMS__Coverage__c> getCoveragesByPolicyIds(Set<Id> policyIds){
        List<CanaryAMS__Coverage__c> coverages = [SELECT Id, CanaryAMS__Policy__c, API_Coverage_Initial_Availability__c, API_Coverage_Id__c, API_Coverage_Name__c, API_Coverage_Slug__c, API_Policy_Initial_Availability__c, API_Policy_Id__c, API_Policy_Name__c, API_Policy_Slug__c, Name, Carrier__c, Carrier__r.Id, Carrier__r.Name, CanaryAMS__Current_Term_Amount__c, Agency_Fee__c, Carrier_Fee__c, Zen_12_Month_Premium__c, Zen_12_Month_Carrier_Fee__c, Zen_12_Month_Agency_Fee__c, Zen_Limit__c, Zen_Deductible__c, CanaryAMS__Deductible_Type_Code__c  FROM CanaryAMS__Coverage__c WHERE CanaryAMS__Policy__c IN :policyIds];

        return coverages;
    }
}
