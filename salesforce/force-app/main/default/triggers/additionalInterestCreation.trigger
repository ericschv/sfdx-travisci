trigger additionalInterestCreation on CanaryAMS__Additional_Interests__c (after insert) {
  if (Test.isRunningTest()) {
    Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
  }

  List<CanaryAMS__Additional_Interests__c> newAdditionalInterests = new List<CanaryAMS__Additional_Interests__c>();
    
  for (CanaryAMS__Additional_Interests__c additionalInterest : Trigger.new) {
    if (additionalInterest.CanaryAMS__Policy__c != null) {
      newAdditionalInterests.add(additionalInterest);
    }
  }

  if (newAdditionalInterests.size() > 0) {       
    List<PolicyEvent> additionalInterestEvents = AdditionalInterestEvents.createNewAdditionalInterestEvents(newAdditionalInterests);
    
    if (additionalInterestEvents.size() > 0) {
      String additionalInterestEventJSON = PolicyEventHistory.getPolicyEventJson(additionalInterestEvents);
      PolicyEventHistory.storeEvent(additionalInterestEventJSON);
    }
  }
}