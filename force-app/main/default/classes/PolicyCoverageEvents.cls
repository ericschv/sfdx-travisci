public with sharing class PolicyCoverageEvents {

    public static List<PolicyEvent> createUpdateCoverageEvents(List<CanaryAMS__Coverage__c> oldCoverages, List<CanaryAMS__Coverage__c> newCoverages) {
        List<PolicyEvent> policyEvents = new List<PolicyEvent>();    
    
        for (Integer i = 0; i < oldCoverages.size(); ++i) {
            if (!String.isBlank(oldCoverages[i].CanaryAMS__Policy__c)) {
                CanaryAMS__Policy__c policy = [SELECT Id, Name FROM CanaryAMS__Policy__c WHERE Id = :oldCoverages[i].CanaryAMS__Policy__c];
                
                String recordName = newCoverages[i].API_Policy_Name__c + ' - ' + newCoverages[i].API_Coverage_Name__c;
                String eventOperation = 'update';
                
                // if the coverage paid premium has changed, add a policy event for paid premium
                if (oldCoverages[i].CanaryAMS__Current_Term_Amount__c != newCoverages[i].CanaryAMS__Current_Term_Amount__c) {
                    PolicyEvent premiumPolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].CanaryAMS__Current_Term_Amount__c), String.valueOf(newCoverages[i].CanaryAMS__Current_Term_Amount__c), 'CanaryAMS__Current_Term_Amount__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                    policyEvents.add(premiumPolicyEvent);
                }

                // if the coverage deductible type has changed, add a policy event for deductible type
                if (oldCoverages[i].CanaryAMS__Deductible_Type_Code__c != newCoverages[i].CanaryAMS__Deductible_Type_Code__c) {
                    PolicyEvent deductibleTypePolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, oldCoverages[i].CanaryAMS__Deductible_Type_Code__c, newCoverages[i].CanaryAMS__Deductible_Type_Code__c, 'CanaryAMS__Deductible_Type_Code__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                    policyEvents.add(deductibleTypePolicyEvent);
                }

                // if the coverage deductible has changed, add a policy event for deductible
                if (oldCoverages[i].Zen_Deductible__c != newCoverages[i].Zen_Deductible__c) {
                    PolicyEvent deductiblePolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].Zen_Deductible__c), String.valueOf(newCoverages[i].Zen_Deductible__c), 'Zen_Deductible__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                    policyEvents.add(deductiblePolicyEvent);
                }

                // if the coverage limit has changed, add a policy event for limit
                if (oldCoverages[i].Zen_Limit__c != newCoverages[i].Zen_Limit__c) {
                    PolicyEvent limitPolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, oldCoverages[i].Zen_Limit__c, newCoverages[i].Zen_Limit__c, 'Zen_Limit__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                    policyEvents.add(limitPolicyEvent);
                }

                // if the coverage carrier has changed, add a policy event for carrier
                if (oldCoverages[i].Carrier__c != newCoverages[i].Carrier__c) {
                    PolicyEvent carrierPolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, oldCoverages[i].Carrier__c, newCoverages[i].Carrier__c, 'Carrier__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                    policyEvents.add(carrierPolicyEvent);
                }

                // if the coverage paid carrier fee has changed, add a policy event for paid carrier fee
                if (oldCoverages[i].Carrier_Fee__c != newCoverages[i].Carrier_Fee__c) {
                    PolicyEvent carrierFeePolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].Carrier_Fee__c), String.valueOf(newCoverages[i].Carrier_Fee__c), 'Carrier_Fee__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                    policyEvents.add(carrierFeePolicyEvent);
                }

                // if the coverage paid agency fee has changed, add a policy event for paid agency fee
                if (oldCoverages[i].Agency_Fee__c != newCoverages[i].Agency_Fee__c) {
                    PolicyEvent agencyFeePolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].Agency_Fee__c), String.valueOf(newCoverages[i].Agency_Fee__c), 'Agency_Fee__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                    policyEvents.add(agencyFeePolicyEvent);
                }

                // if the 12 month coverage premium has changed, add a policy event for 12 month premium
                if (oldCoverages[i].Zen_12_Month_Premium__c != newCoverages[i].Zen_12_Month_Premium__c) {
                    PolicyEvent premium12MonthPolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].Zen_12_Month_Premium__c), String.valueOf(newCoverages[i].Zen_12_Month_Premium__c), 'Zen_12_Month_Premium__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                    policyEvents.add(premium12MonthPolicyEvent);
                }

                // if the coverage 12 month agency fee has changed, add a policy event for 12 month agency fee
                if (oldCoverages[i].Zen_12_Month_Agency_Fee__c != newCoverages[i].Zen_12_Month_Agency_Fee__c) {
                    PolicyEvent agencyFee12MonthPolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].Zen_12_Month_Agency_Fee__c), String.valueOf(newCoverages[i].Zen_12_Month_Agency_Fee__c), 'Zen_12_Month_Agency_Fee__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                    policyEvents.add(agencyFee12MonthPolicyEvent);
                }

                // if the 12 month coverage carrier fee has changed, add a policy event for 12 month carrier fee
                if (oldCoverages[i].Zen_12_Month_Carrier_Fee__c != newCoverages[i].Zen_12_Month_Carrier_Fee__c) {
                    PolicyEvent carrierFee12MonthPolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].Zen_12_Month_Carrier_Fee__c), String.valueOf(newCoverages[i].Zen_12_Month_Carrier_Fee__c), 'Zen_12_Month_Carrier_Fee__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                    policyEvents.add(carrierFee12MonthPolicyEvent);
                }
            }
        }
        return policyEvents;
    }


    public static List<PolicyEvent> createDeleteCoverageEvents(List<CanaryAMS__Coverage__c> oldCoverages) {
        List<PolicyEvent> policyEvents = new List<PolicyEvent>();
        
        for (Integer i = 0; i < oldCoverages.size(); ++i) {
            if (!String.isBlank(oldCoverages[i].CanaryAMS__Policy__c)) {
                String recordName = oldCoverages[i].API_Policy_Name__c + ' - ' + oldCoverages[i].API_Coverage_Name__c;
                String eventOperation = 'delete';
                CanaryAMS__Policy__c policy = [SELECT Id, Name FROM CanaryAMS__Policy__c WHERE Id = :oldCoverages[i].CanaryAMS__Policy__c];
                
                PolicyEvent premiumPolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].CanaryAMS__Current_Term_Amount__c), '0', 'CanaryAMS__Current_Term_Amount__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent agencyFeePolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].Agency_Fee__c), '0', 'Agency_Fee__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent carrierFeePolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].Carrier_Fee__c), '0', 'Carrier_Fee__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent premium12MonthPolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].Zen_12_Month_Premium__c), '0', 'Zen_12_Month_Premium__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent agencyFee12MonthPolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].Zen_12_Month_Agency_Fee__c), '0', 'Zen_12_Month_Agency_Fee__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent carrierFee12MonthPolicyEvent = PolicyEvent.createPolicyEvent(policy, oldCoverages[i].Id, recordName, eventOperation, String.valueOf(oldCoverages[i].Zen_12_Month_Carrier_Fee__c), '0', 'Zen_12_Month_Carrier_Fee__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');

                policyEvents.add(premiumPolicyEvent);
                policyEvents.add(agencyFeePolicyEvent);
                policyEvents.add(carrierFeePolicyEvent);
                policyEvents.add(premium12MonthPolicyEvent);
                policyEvents.add(agencyFee12MonthPolicyEvent);
                policyEvents.add(carrierFee12MonthPolicyEvent);
            }
        }

        return policyEvents;
    }


    public static List<PolicyEvent> createInsertCoverageEvents(List<CanaryAMS__Coverage__c> newCoverages) {
        List<PolicyEvent> policyEvents = new List<PolicyEvent>();

        for (Integer i = 0; i < newCoverages.size(); ++i) {
            if (!String.isBlank(newCoverages[i].CanaryAMS__Policy__c) && newCoverages[i].Zen_Source__c != Policies.SOURCE_BIND) {
                CanaryAMS__Policy__c policy = [SELECT Id, Name FROM CanaryAMS__Policy__c WHERE Id = :newCoverages[i].CanaryAMS__Policy__c];
                String recordName = newCoverages[i].API_Policy_Name__c + ' - ' + newCoverages[i].API_Coverage_Name__c;
                String eventOperation = 'insert';
                
                PolicyEvent premiumPolicyEvent = PolicyEvent.createPolicyEvent(policy, newCoverages[i].Id, recordName, eventOperation, '0', String.valueOf(newCoverages[i].CanaryAMS__Current_Term_Amount__c), 'CanaryAMS__Current_Term_Amount__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent agencyFeePolicyEvent = PolicyEvent.createPolicyEvent(policy, newCoverages[i].Id, recordName, eventOperation, '0', String.valueOf(newCoverages[i].Agency_Fee__c), 'Agency_Fee__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent carrierFeePolicyEvent = PolicyEvent.createPolicyEvent(policy, newCoverages[i].Id, recordName, eventOperation, '0', String.valueOf(newCoverages[i].Carrier_Fee__c), 'Carrier_Fee__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent premium12MonthPolicyEvent = PolicyEvent.createPolicyEvent(policy, newCoverages[i].Id, recordName, eventOperation, '0', String.valueOf(newCoverages[i].Zen_12_Month_Premium__c), 'Zen_12_Month_Premium__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent agencyFee12MonthPolicyEvent = PolicyEvent.createPolicyEvent(policy, newCoverages[i].Id, recordName, eventOperation, '0', String.valueOf(newCoverages[i].Zen_12_Month_Agency_Fee__c), 'Zen_12_Month_Agency_Fee__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent carrierFee12MonthPolicyEvent = PolicyEvent.createPolicyEvent(policy, newCoverages[i].Id, recordName, eventOperation, '0', String.valueOf(newCoverages[i].Zen_12_Month_Carrier_Fee__c), 'Zen_12_Month_Carrier_Fee__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent limitPolicyEvent = PolicyEvent.createPolicyEvent(policy, newCoverages[i].Id, recordName, eventOperation, '0', String.valueOf(newCoverages[i].Zen_Limit__c), 'Zen_Limit__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent deductiblePolicyEvent = PolicyEvent.createPolicyEvent(policy, newCoverages[i].Id, recordName, eventOperation, '0', String.valueOf(newCoverages[i].Zen_Deductible__c), 'Zen_Deductible__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent deductibleTypePolicyEvent = PolicyEvent.createPolicyEvent(policy, newCoverages[i].Id, recordName, eventOperation, '', newCoverages[i].CanaryAMS__Deductible_Type_Code__c, 'CanaryAMS__Deductible_Type_Code__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');
                PolicyEvent carrierPolicyEvent = PolicyEvent.createPolicyEvent(policy, newCoverages[i].Id, recordName, eventOperation, '', newCoverages[i].Carrier__c, 'Carrier__c', 'updateCoverage', 'CanaryAMS__Coverage__c', 'pending');

                policyEvents.add(premiumPolicyEvent);
                policyEvents.add(agencyFeePolicyEvent);
                policyEvents.add(carrierFeePolicyEvent);
                policyEvents.add(premium12MonthPolicyEvent);
                policyEvents.add(agencyFee12MonthPolicyEvent);
                policyEvents.add(carrierFee12MonthPolicyEvent);
                policyEvents.add(limitPolicyEvent);
                policyEvents.add(deductiblePolicyEvent);
                policyEvents.add(deductibleTypePolicyEvent);
                policyEvents.add(carrierPolicyEvent);
            }
        }

        return policyEvents;
    }
    
}
