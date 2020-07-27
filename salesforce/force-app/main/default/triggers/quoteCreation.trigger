trigger quoteCreation on CanaryAMS__Insurance_Product__c (before insert) {
  Quotes.copyOwnerToProducer(Trigger.new);
}