public with sharing class AdditionalInterestEvents {

    public static List<PolicyEvent> createNewAdditionalInterestEvents(List<CanaryAMS__Additional_Interests__c> additionalInterests) {

        List<String> policyIds = new List<String>();
        for (CanaryAMS__Additional_Interests__c additionalInterest : additionalInterests) {
            policyIds.add(additionalInterest.CanaryAMS__Policy__c);
        }

        List<CanaryAMS__Policy__c> policies = [SELECT Id, Name FROM CanaryAMS__Policy__c WHERE Id IN :policyIds];
        Map<Id, CanaryAMS__Policy__c> policyMap = new Map<Id, CanaryAMS__Policy__c>(policies);

        List<PolicyEvent> policyEvents = new List<PolicyEvent>();
        for (CanaryAMS__Additional_Interests__c additionalInterest : additionalInterests) {
            CanaryAMS__Policy__c policy = policyMap.get(additionalInterest.CanaryAMS__Policy__c);
            String operation = 'addAdditionalInterest';
            String recordType = 'Additional Interest';
            String status = 'pending';

            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'insert', null, additionalInterest.Name, 'Additional Interest Name', operation, recordType, status));
            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'insert', null, additionalInterest.CanaryAMS__Type__c, 'Type', operation, recordType, status));
            if (additionalInterest.CanaryAMS__Type_Other_Description__c != null) policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'insert', null, additionalInterest.CanaryAMS__Type_Other_Description__c, 'Type - Other Description', operation, recordType, status));
            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'insert', null, additionalInterest.Effective_Date__c.format(), 'Effective Date', operation, recordType, status));
            if (additionalInterest.CanaryAMS__End_Date__c != null) policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'insert', null, additionalInterest.CanaryAMS__End_Date__c.format(), 'End Date', operation, recordType, status));
            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'insert', null, additionalInterest.CanaryAMS__Address_1__c, 'Address 1', operation, recordType, status));
            if (additionalInterest.CanaryAMS__Address_2__c != null) policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'insert', null, additionalInterest.CanaryAMS__Address_2__c, 'Address 2', operation, recordType, status));
            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'insert', null, additionalInterest.CanaryAMS__City__c, 'City', operation, recordType, status));
            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'insert', null, additionalInterest.CanaryAMS__StateProvCd__c, 'State', operation, recordType, status));
            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'insert', null, additionalInterest.CanaryAMS__PostalCode__c, 'Zip Code', operation, recordType, status));
            if (additionalInterest.CanaryAMS__Notes__c != null) policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'insert', null, additionalInterest.CanaryAMS__Notes__c, 'Notes', operation, recordType, status));
        }
        return policyEvents;
    }

    public static List<PolicyEvent> createDeleteAdditionalInterestEvents(List<CanaryAMS__Additional_Interests__c> additionalInterests) {

        List<String> policyIds = new List<String>();
        for (CanaryAMS__Additional_Interests__c additionalInterest : additionalInterests) {
            policyIds.add(additionalInterest.CanaryAMS__Policy__c);
        }

        List<CanaryAMS__Policy__c> policies = [SELECT Id, Name FROM CanaryAMS__Policy__c WHERE Id IN :policyIds];
        Map<Id, CanaryAMS__Policy__c> policyMap = new Map<Id, CanaryAMS__Policy__c>(policies);

        List<PolicyEvent> policyEvents = new List<PolicyEvent>();
        for (CanaryAMS__Additional_Interests__c additionalInterest : additionalInterests) {
            CanaryAMS__Policy__c policy = policyMap.get(additionalInterest.CanaryAMS__Policy__c);
            String operation = 'deleteAdditionalInterest';
            String recordType = 'Additional Interest';
            String status = 'pending';

            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'delete', additionalInterest.Name, null, 'Additional Interest Name', operation, recordType, status));
            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'delete', additionalInterest.CanaryAMS__Type__c, null, 'Type', operation, recordType, status));
            if (additionalInterest.CanaryAMS__Type_Other_Description__c != null) policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'delete', additionalInterest.CanaryAMS__Type_Other_Description__c, null, 'Type - Other Description', operation, recordType, status));
            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'delete', additionalInterest.Effective_Date__c.format(), null, 'Effective Date', operation, recordType, status));
            if (additionalInterest.CanaryAMS__End_Date__c != null) policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'delete', additionalInterest.CanaryAMS__End_Date__c.format(), null, 'End Date', operation, recordType, status));
            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'delete', additionalInterest.CanaryAMS__Address_1__c, null, 'Address 1', operation, recordType, status));
            if (additionalInterest.CanaryAMS__Address_2__c != null) policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'delete', additionalInterest.CanaryAMS__Address_2__c, null, 'Address 2', operation, recordType, status));
            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'delete', additionalInterest.CanaryAMS__City__c, null, 'City', operation, recordType, status));
            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'delete', additionalInterest.CanaryAMS__StateProvCd__c, null, 'State', operation, recordType, status));
            policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'delete', additionalInterest.CanaryAMS__PostalCode__c, null, 'Zip Code', operation, recordType, status));
            if (additionalInterest.CanaryAMS__Notes__c != null) policyEvents.add(PolicyEvent.createPolicyEvent(policy, additionalInterest.Id, additionalInterest.Name, 'delete', additionalInterest.CanaryAMS__Notes__c, null, 'Notes', operation, recordType, status));
        }
        return policyEvents;        
    }
}
