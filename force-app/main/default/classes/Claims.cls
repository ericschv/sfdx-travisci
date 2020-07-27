public with sharing class Claims {
    
    public static List<CanaryAMS__Claim__c> getClaimsByPolicyIds(Set<Id> policyIds){
        List<CanaryAMS__Claim__c> claims = [SELECT Id, CanaryAMS__ClaimStatusCd__c, CanaryAMS__Date_of_Loss__c, CanaryAMS__Date_Reported__c, CanaryAMS__Close_Date__c, CanaryAMS__Description__c, CanaryAMS__Amount_Reserved__c, CanaryAMS__TotalIndemnityPaidAmt__c, CanaryAMS__Notes__c, Name, CanaryAMS__Adjuster_Name__c, CanaryAMS__Adjuster_Phone_Number__c, CanaryAMS__Adjuster_Email__c, CanaryAMS__Policy__c FROM CanaryAMS__Claim__c WHERE CanaryAMS__Policy__c IN :policyIds];
        
        return claims;
    }

}
