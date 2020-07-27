@isTest
private class CarriersTest {

    @testSetup static void setup() {
        // Create common test carriers

        Integer[] carrierNums = new Integer[]{0,1,2,3,4};
        List<CanaryAMS__Carrier__c> carriersToInsert = new List<CanaryAMS__Carrier__c>();

        for (Integer i : carrierNums) {
            CanaryAMS__Carrier__c carrier = new CanaryAMS__Carrier__c();
            carrier.Name = 'Carrier ' + String.valueOf(i);
            carrier.Logo_URL__c = 'https://zensurance.com/logo.' + String.valueOf(i) + '.png';
            carrier.Days_Notice_for_Cancellation__c = i * 10;
            carriersToInsert.add(carrier);
        }

        insert carriersToInsert;

        CanaryAMS__Carrier__c zenCarrier = new CanaryAMS__Carrier__c();
        zenCarrier.Name = Carriers.ZEN_MGA_CARRIER_NAME;
        zenCarrier.Logo_URL__c = 'https://zensurance.com/zen.png';
        insert zenCarrier;
    }

    @isTest static void testGetCarriers() {
        List<CanaryAMS__Carrier__c> retrievedCarriers = Carriers.getCarriers();

        System.assert(retrievedCarriers.size() == 6, 'Expecting 6 carriers to exist.');
        
        for (Integer i = 0; i < 6; i++) {
          if (i == 5) {
            System.assert(retrievedCarriers[i].Name == Carriers.ZEN_MGA_CARRIER_NAME, 'Expected ' + retrievedCarriers[i].Name + ' to equal Carrier ' + Carriers.ZEN_MGA_CARRIER_NAME);
          } else {
            System.assert(retrievedCarriers[i].Name == 'Carrier ' + String.valueOf(i), 'Expected ' + retrievedCarriers[i].Name + ' to equal Carrier ' + String.valueOf(i));
          }
        }
    }

    @isTest static void testGetZenMGACarrier() {
        CanaryAMS__Carrier__c zenCarrier = Carriers.getZenMGACarrier();

        System.assert(zenCarrier.Name == Carriers.ZEN_MGA_CARRIER_NAME, 'Expecting '+ zenCarrier.Name + ' to be ' + Carriers.ZEN_MGA_CARRIER_NAME + '.');
    }

    @isTest static void testGetDaysNoticeForCancellation() {
      CanaryAMS__Carrier__c testCarrier1 = [SELECT Id, Name FROM CanaryAMS__Carrier__c WHERE Name = :Carriers.ZEN_MGA_CARRIER_NAME LIMIT 1];
      Integer daysNotice1 = Carriers.getDaysNoticeForCancellation(testCarrier1.Id);

      System.assert(daysNotice1 == Carriers.DEFAULT_DAYS_NOTICE_FOR_CANCELLATION, 'Expected ' + daysNotice1 + ' to equal ' + Carriers.DEFAULT_DAYS_NOTICE_FOR_CANCELLATION);

      CanaryAMS__Carrier__c testCarrier2 = [SELECT Id, Name FROM CanaryAMS__Carrier__c WHERE Name = :'Carrier 2' LIMIT 1];
      Integer daysNotice2 = Carriers.getDaysNoticeForCancellation(testCarrier2.Id);

      System.assert(daysNotice2 == 20, 'Expected ' + daysNotice2 + ' to equal ' + 20);
    }
}