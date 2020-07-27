public with sharing class CarrierProducts {

    @AuraEnabled(cacheable=true)
    public static List<CanaryAMS__Carrier_Product__c> getCarrierProducts() {
        return [SELECT Id, Name, CanaryAMS__Carrier__c FROM CanaryAMS__Carrier_Product__c ALL ROWS];
    }
    
}
