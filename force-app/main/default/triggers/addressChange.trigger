trigger addressChange on Account (after update) {
  if (Test.isRunningTest()) {
    Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
  }

  if (AccountChangeHandler.isFirstTriggeredEvent) {
    AccountChangeHandler.isFirstTriggeredEvent = false;
    List<PolicyEvent> policyEvents = new List<PolicyEvent>();
    
    for (Integer i = 0; i < Trigger.old.size(); ++i) {
      Account oldAccount = Trigger.old[i];
      Account newAccount = Trigger.new[i];

      policyEvents.addAll(PolicyEventHistory.createAddressChangeEvents(oldAccount, newAccount));
    }
    
    if (policyEvents.size() > 0) {
      String policyEventJSON = PolicyEventHistory.getPolicyEventJson(policyEvents);
      PolicyEventHistory.storeEvent(policyEventJSON);
    }
  }
}