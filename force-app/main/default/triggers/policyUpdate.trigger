trigger policyUpdate on CanaryAMS__Policy__c (before update) {
  if (Test.isRunningTest()) {
    Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
  }

  for (Integer i = 0; i < Trigger.new.size(); ++i) {
    CanaryAMS__Policy__c policy = Trigger.new[i];
    
    if (policy.CanaryAMS__Carrier__c != null && policy.Days_Notice_for_Cancellation__c == null) {
      policy.Days_Notice_for_Cancellation__c = Carriers.getDaysNoticeForCancellation(policy.CanaryAMS__Carrier__c);
    }
  }
}