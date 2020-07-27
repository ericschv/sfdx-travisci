public with sharing class RenewalQuotes {
    @AuraEnabled(cacheable=true)
    public static List<String> getRenewingPolicyIds(String quoteId){
        List<String> renewingPolicyIds = new List<String>();

        List<CanaryAMS__Policy__c> renewingPolicies = [
            SELECT
                Id
            FROM
                CanaryAMS__Policy__c
            WHERE
                Zen_Renewal_Quote__c = :quoteId
        ];

        for (CanaryAMS__Policy__c renewingPolicy : renewingPolicies) {
            renewingPolicyIds.add(renewingPolicy.Id);
        }

        return renewingPolicyIds;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean claimExistsForRenewingPolicies(String quoteId){
        List<CanaryAMS__Claim__c> claims = [
            SELECT
                Id
            FROM
                CanaryAMS__Claim__c
            WHERE
                CanaryAMS__Policy__r.Zen_Renewal_Quote__c = :quoteId
        ];

        return claims.size() != 0;
    }
}
