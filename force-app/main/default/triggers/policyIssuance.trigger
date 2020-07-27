trigger policyIssuance on CanaryAMS__Policy__c (after insert) {
  if (Test.isRunningTest()) {
    Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
  }

  List<PolicyEvent> policyEvents = new List<PolicyEvent>();
  
  for (Integer i = 0; i < Trigger.new.size(); ++i) {
    CanaryAMS__Policy__c policy = Trigger.new[i];
    policyEvents.addAll(PolicyEventHistory.createPolicyIssuanceEvent(policy));
  }

  if (policyEvents.size() > 0) {
    String policyEventJSON = PolicyEventHistory.getPolicyEventJson(policyEvents);
    PolicyEventHistory.storeEvent(policyEventJSON);
  }
}