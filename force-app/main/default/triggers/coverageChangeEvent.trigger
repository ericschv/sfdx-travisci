trigger coverageChangeEvent on CanaryAMS__Coverage__c (after insert, after update, after delete) {
  if (Test.isRunningTest()) {
    Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
  }

  private static void createUpdateCoverageEvents() {
    List<CanaryAMS__Coverage__c> oldCoverages = Trigger.old;
    List<CanaryAMS__Coverage__c> newCoverages = Trigger.new;

    List<PolicyEvent> policyEvents = PolicyCoverageEvents.createUpdateCoverageEvents(oldCoverages, newCoverages);

    if (policyEvents.size() > 0) {
      String policyEventJSON = PolicyEventHistory.getPolicyEventJson(policyEvents);
      PolicyEventHistory.storeEvent(policyEventJSON);
    }
  }

  private static void createDeleteCoverageEvents() {
    List<CanaryAMS__Coverage__c> oldCoverages = Trigger.old;
    List<PolicyEvent> policyEvents = PolicyCoverageEvents.createDeleteCoverageEvents(oldCoverages);
    
    if (policyEvents.size() > 0) {
      String policyEventJSON = PolicyEventHistory.getPolicyEventJson(policyEvents);
      PolicyEventHistory.storeEvent(policyEventJSON);
    }
  }

  private static void createInsertCoverageEvents() {
    List<CanaryAMS__Coverage__c> newCoverages = Trigger.new;
    if (newCoverages.size() > 0) {       
      List<PolicyEvent> policyEvents = PolicyCoverageEvents.createInsertCoverageEvents(newCoverages);
      
      if (policyEvents.size() > 0) {
        String policyEventJSON = PolicyEventHistory.getPolicyEventJson(policyEvents);
        PolicyEventHistory.storeEvent(policyEventJSON);
      }
    }
  }

  if (Trigger.isUpdate) {
    createUpdateCoverageEvents();
  }

  if (Trigger.isDelete) {
    createDeleteCoverageEvents();
  }

  if (Trigger.isInsert) {
    createInsertCoverageEvents();
  }  
}