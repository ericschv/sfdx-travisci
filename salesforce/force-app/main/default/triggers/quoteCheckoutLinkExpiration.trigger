trigger quoteCheckoutLinkExpiration on CanaryAMS__Insurance_Product__c (after update) {
  for (Integer i = 0; i < Trigger.new.size(); ++i) {
    CanaryAMS__Insurance_Product__c oldQuote = Trigger.old[i];
    CanaryAMS__Insurance_Product__c newQuote = Trigger.new[i];

    if (oldQuote.Ready_to_Purchase__c == false && newQuote.Ready_to_Purchase__c == true) {
      Quotes.updateCheckoutExpirationDate(newQuote.Id);
    }
  }
}