public with sharing class Carriers {

    public static String ZEN_MGA_CARRIER_NAME = 'ZenMGA - BeazMark E&O';
    public static Integer DEFAULT_DAYS_NOTICE_FOR_CANCELLATION = 45;
    
    @AuraEnabled(cacheable=true)
    public static List<CanaryAMS__Carrier__c> getCarriers() {
        return [SELECT Id, Name FROM CanaryAMS__Carrier__c ALL ROWS];
    }

    @AuraEnabled(cacheable=true)
    public static CanaryAMS__Carrier__c getZenMGACarrier() {
      try {
        CanaryAMS__Carrier__c zenMgaCarrier = [SELECT Id, Name FROM CanaryAMS__Carrier__c WHERE Name = :Carriers.ZEN_MGA_CARRIER_NAME];

        return zenMgaCarrier;
      } catch (Exception e) {
        if (!Test.isRunningTest()) {
          Sentry.record(e);
        }

        return null;
      }
    }

  @AuraEnabled
  public static Integer getDaysNoticeForCancellation(String carrierId) {
    try {
      CanaryAMS__Carrier__c carrier = [SELECT Id, Days_Notice_for_Cancellation__c FROM CanaryAMS__Carrier__c WHERE Id = :carrierId LIMIT 1];

      return carrier.Days_Notice_for_Cancellation__c == null ? DEFAULT_DAYS_NOTICE_FOR_CANCELLATION : carrier.Days_Notice_for_Cancellation__c.intValue();
    } catch (Exception e) {
      if (!Test.isRunningTest()) {
        Sentry.record(e);
      }
      return null;
    }
  }
}
