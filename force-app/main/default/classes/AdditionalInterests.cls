public with sharing class AdditionalInterests {

    public static List<String> CGL_POLICY_SLUGS = new List<String>{'general_liability', 'general_professional_liability'};

    @AuraEnabled(cacheable=false)
    public static List<CanaryAMS__Additional_Interests__c> getAdditionalInterestsByPolicyId(String policyId) {
        List<CanaryAMS__Additional_Interests__c> policyAdditionalInterests = [
            SELECT
                Id, Name, CanaryAMS__Address_1__c, CanaryAMS__City__c, CanaryAMS__StateProvCd__c, CanaryAMS__PostalCode__c, CanaryAMS__Type__c, Effective_Date__c, CanaryAMS__End_Date__c
            FROM
                CanaryAMS__Additional_Interests__c
            WHERE
                CanaryAMS__Policy__c = :policyId
        ];
        return policyAdditionalInterests;
    }

    @AuraEnabled(cacheable=false)
    public static List<CanaryAMS__Coverage__c> getCGLCoveragesByPolicyId(String policyId) {
        List<CanaryAMS__Coverage__c> policyCGLCoverages = [
            SELECT
                Id, Name, CanaryAMS__Policy__c, API_Coverage_Name__c, API_Policy_Slug__c
            FROM
                CanaryAMS__Coverage__c
            WHERE
                CanaryAMS__Policy__c = :policyId AND API_Policy_Slug__c IN :AdditionalInterests.CGL_POLICY_SLUGS
        ];
        return policyCGLCoverages;
    }

    public static void copyAdditionalInterestsFromQuoteToPolicy(String quoteId, String policyId) {
        try {
            List<CanaryAMS__Additional_Interests__c> additionalInterests = [SELECT 
                Id, 
                Name, 
                CanaryAMS__Address_1__c, 
                CanaryAMS__Address_2__c, 
                CanaryAMS__City__c, 
                CanaryAMS__StateProvCd__c, 
                CanaryAMS__PostalCode__c, 
                CanaryAMS__Type__c, 
                Effective_Date__c, 
                CanaryAMS__End_Date__c,
                CanaryAMS__Email__c,
                CanaryAMS__isActive__c,
                CanaryAMS__Notes__c,
                CanaryAMS__Type_Other_Description__c,
                CanaryAMS__Insurance_Quote__c,
                CanaryAMS__Policy__c
            FROM
                CanaryAMS__Additional_Interests__c
            WHERE
                CanaryAMS__Insurance_Quote__c = :quoteId
            ];

            for (CanaryAMS__Additional_Interests__c additionalInterest : additionalInterests) {
                CanaryAMS__Additional_Interests__c clonedInterest = additionalInterest.clone(false, false, false, false);
                clonedInterest.CanaryAMS__Insurance_Quote__c = null;
                clonedInterest.CanaryAMS__Policy__c = policyId;
                insert clonedInterest;
            }

        } catch (Exception e) {
            if (!Test.isRunningTest()) {
            Sentry.record(e);
            }
        }

        
    }
}
