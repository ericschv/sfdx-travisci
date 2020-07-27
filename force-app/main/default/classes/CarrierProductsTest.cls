@isTest
public with sharing class CarrierProductsTest {
    @testSetup static void setup() {
        Integer[] carrierProductIDs = new Integer[]{1,2,3,4,5};
        List<CanaryAMS__Carrier_Product__c> carrierProducts = new List<CanaryAMS__Carrier_Product__c>();

        for (Integer i : carrierProductIDs) {
            CanaryAMS__Carrier__c carrier = new CanaryAMS__Carrier__c(
                Name = 'Carrier ' + String.valueOf(i),
                Logo_URL__c = 'https://zensurance.com/logo.' + String.valueOf(i) + '.png'
            );

            insert carrier;

            CanaryAMS__Carrier_Product__c carrierProduct = new CanaryAMS__Carrier_Product__c(
                Name = 'Carrier Product ' + String.valueOf(i),
                CanaryAMS__Carrier__c = carrier.Id
            );

            carrierProducts.add(carrierProduct);
        }

        insert carrierProducts;
    }

    @isTest static void testGetCarrierProducts() {
        List<CanaryAMS__Carrier_Product__c> carrierProducts = CarrierProducts.getCarrierProducts();

        System.assert(carrierProducts.size() == 5, 'Expecting 5 carrier products to exist.');
        
        Integer i = 1;
        for (CanaryAMS__Carrier_Product__c carrierProduct: carrierProducts) {
            System.assert(carrierProduct.Name == 'Carrier Product ' + String.valueOf(i), 'Expected ' + carrierProduct.Name + ' to equal Carrier Product ' + String.valueOf(i));
            ++i;
        }
    }

}
