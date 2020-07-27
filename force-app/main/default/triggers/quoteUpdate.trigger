trigger quoteUpdate on CanaryAMS__Insurance_Product__c (before update) {
  List<CanaryAMS__Insurance_Product__c> quotesToCopyField = new List<CanaryAMS__Insurance_Product__c>();

  for (Integer i = 0; i < Trigger.new.size(); ++i) {
    CanaryAMS__Insurance_Product__c oldQuote = Trigger.old[i];
    CanaryAMS__Insurance_Product__c newQuote = Trigger.new[i];

    if (newQuote.CanaryAMS__Stage__c != NULL && (newQuote.CanaryAMS__Stage__c.equals(Quotes.CLOSED_WON_STATUS) || newQuote.CanaryAMS__Stage__c.equals(Quotes.CLOSED_LOST_STATUS))) {
      newQuote.CanaryAMS__Closed_Date__c = Quotes.getClosedDate(newQuote);
    }

    if (oldQuote.OwnerId != newQuote.OwnerId) {
      quotesToCopyField.add(newQuote);
    }
    
    if (newQuote.ZEN_Payment_Status__c != oldQuote.ZEN_Payment_Status__c && newQuote.ZEN_Payment_Status__c != NULL && !newQuote.ZEN_Payment_Status__c.equals(Quotes.NONE_PAYMENT_STATUS)) {
      newQuote.Payment_Date__c = Date.today();
    } else {
      newQuote.Payment_Date__c = oldQuote.Payment_Date__c;
    }
  }

  if (quotesToCopyField.size() > 0) {
    Quotes.copyOwnerToProducer(quotesToCopyField);
  }
}