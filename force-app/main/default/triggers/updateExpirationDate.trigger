trigger updateExpirationDate on CanaryAMS__Insurance_Product__c (before update) {
  for (Integer i = 0; i < Trigger.new.size(); ++i) {
    CanaryAMS__Insurance_Product__c oldQuote = Trigger.old[i];
    CanaryAMS__Insurance_Product__c newQuote = Trigger.new[i];

    if (oldQuote.CanaryAMS__Policy_Effective_Date__c != newQuote.CanaryAMS__Policy_Effective_Date__c ||
        oldQuote.CanaryAMS__Quoted_Term__c != newQuote.CanaryAMS__Quoted_Term__c) {
          Quotes.updateExpirationDate(newQuote);
    }
  }
}