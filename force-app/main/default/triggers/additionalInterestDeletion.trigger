trigger additionalInterestDeletion on CanaryAMS__Additional_Interests__c (after delete) {
  if (Test.isRunningTest()) {
    Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
  }

  List<CanaryAMS__Additional_Interests__c> oldAdditionalInterests = new List<CanaryAMS__Additional_Interests__c>();

  for (CanaryAMS__Additional_Interests__c additionalInterest : Trigger.old) {
    if (additionalInterest.CanaryAMS__Policy__c != null) {
      oldAdditionalInterests.add(additionalInterest);
    }
  }
  
  if (oldAdditionalInterests.size() > 0) {       
    List<PolicyEvent> additionalInterestEvents = AdditionalInterestEvents.createDeleteAdditionalInterestEvents(oldAdditionalInterests);
    
    if (additionalInterestEvents.size() > 0) {
      String additionalInterestEventJSON = PolicyEventHistory.getPolicyEventJson(additionalInterestEvents);
      PolicyEventHistory.storeEvent(additionalInterestEventJSON);
    }
  }
}