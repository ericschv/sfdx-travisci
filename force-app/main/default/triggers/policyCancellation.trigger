trigger policyCancellation on CanaryAMS__Policy__c (after update) {
  if (Test.isRunningTest()) {
    Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
  }

  CanaryAMS__Policy__c oldPolicy = Trigger.old[0];
  CanaryAMS__Policy__c newPolicy = Trigger.new[0];

  List<PolicyEvent> policyEvents = PolicyCancellationEvents.createPolicyCancellationEvents(oldPolicy, newPolicy);
  
  if (policyEvents.size() > 0) {
    String policyEventJSON = PolicyEventHistory.getPolicyEventJson(policyEvents);
    PolicyEventHistory.storeEvent(policyEventJSON);
  }
}