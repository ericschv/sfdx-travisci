public with sharing class PolicyEventHistory {
    
    private static final String apiUrl = SharedUtils.getApiHost();

    @testVisible public class DeltaResponse {
        @AuraEnabled public Decimal delta { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public String error { get; set; }
    } 

    public static List<PolicyEvent> getPolicyEvents(String queryString) {
        List<PolicyEvent> policyEvents = new List<PolicyEvent>();

        // send a GET request to the questionnaire endpoint to get the answerStore
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(PolicyEventHistory.apiUrl + '/v4/policy-events'+queryString);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            policyEvents = (List<PolicyEvent>) JSON.deserialize(response.getBody(), List<PolicyEvent>.class);
        } else {
            PolicyEvent event = new PolicyEvent();
            event.status = String.valueOf(response.getStatusCode());
            event.recordType = response.getStatus();
            event.recordName = PolicyEventHistory.apiUrl + '/v4/policy-events'+queryString;
            policyEvents.add(event);
        }

        return policyEvents;
    }

    @AuraEnabled(cacheable=false)
    public static List<PolicyEvent> getEventsByPolicyId(String policyId) {
        String queryString = '?policyId='+policyId;
        List<PolicyEvent> policyEvents = getPolicyEvents(queryString);

        return policyEvents;
    }

    @AuraEnabled(cacheable=false)
    public static List<PolicyEvent> getEventsByPolicyIdAndStatus(String policyId, String status) {
        String queryString = '?policyId='+policyId+'&status='+status;
        List<PolicyEvent> policyEvents = getPolicyEvents(queryString);

        return policyEvents;
    }


    // this is separated from storeEvent so that we can improve test coverage slightly.
    public static HttpResponse calloutToStoreEvents(String policyEvents) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(PolicyEventHistory.apiUrl + '/v4/policy-events');
        request.setMethod('POST');
        request.setHeader('content-type', 'application/json; charset=utf-8');
        request.setBody(policyEvents);
        request.setTimeout(30000);
        HttpResponse response = http.send(request);

        return response;
    }
    
    // @TODO: this method is untestable. Let's figure out how to write a unit test for a future method
    // that has no direct impact on anything in Salesforce.
    @future (callout=true)
    public static void storeEvent(String policyEvents) {
        if (!String.isBlank(policyEvents)) {
            HttpResponse response;

            try {
                // send a POST request to the policy event endpoint to create events
                response = PolicyEventHistory.calloutToStoreEvents(policyEvents);
            } catch (CalloutException error) {
                // TODO: Uncomment and send an error and policyEvents to sentry when sentry logging is available
                // Sentry.record(error);
                System.debug('Storing policy events took longer than 30 seconds: ' + policyEvents);
                return;
            }

            // If the request is not successful, log the error response.
            if (response.getStatusCode() != 200) {
                System.debug('Error storing policy history event: ' + String.valueOf(response.getStatusCode()) + ': ' + response.getStatus());
            }
        }
    }


    public static String getPolicyEventJson(List<PolicyEvent> policyEvents) {
        String policyEventJSON = '';
        if (policyEvents.size() > 0) {
            policyEventJSON = '{ "events": ' +  JSON.serialize(policyEvents, true) + ' }';
        }

        return policyEventJSON;
    }


    @AuraEnabled(cacheable=false)
    public static DeltaResponse calculatePremiumDelta(String policyId) {
        // make HTTP request to API to calculate premium delta for all "pending" policy events

        String apiUrl = SharedUtils.getApiHost();
        String queryString = '?policyId='+policyId+'&status=pending&field=CanaryAMS__Current_Term_Amount__c';
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(apiUrl + '/v4/policy-events/calculate-delta'+queryString);
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);

        DeltaResponse deltaResponse = new DeltaResponse();

        if (response.getStatusCode() == 200) {
            Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            deltaResponse.message = 'Successfully calculated premium delta.';
            deltaResponse.delta = (Decimal) deserializedResponse.get('delta');
        } else {
            deltaResponse.error = 'Unable to calculate premium delta for policy: ' + policyId + ', status code: ' + response.getStatusCode() + ', status: '  + response.getStatus();
            System.debug('Error calculating premium delta for policy: ' + policyId + ', API status code: ' + response.getStatusCode() + ', API Status: ' + response.getStatus());
        }

        return deltaResponse;
    }


    public static List<PolicyEvent> createPolicyIssuanceEvent(CanaryAMS__Policy__c policy) {
        // we are only concerned with policies whose status was changed from any value to "Cancelled"
        List<PolicyEvent> policyEvents = new List<PolicyEvent>();
        PolicyEvent policyEvent = new PolicyEvent();

        policyEvent.policyId = policy.Id;
        policyEvent.policyName = policy.Name;
        policyEvent.action = 'issuePolicy';
        policyEvent.operation = 'insert';
        policyEvent.recordType = 'CanaryAMS__Policy__c';
        policyEvent.recordId = policy.Id;
        policyEvent.recordName = policy.Name;
        policyEvent.field = 'CanaryAMS__Policy_Status__c';
        policyEvent.oldValue = 'N/A';
        policyEvent.newValue = policy.CanaryAMS__Policy_Status__c;
        policyEvent.status = 'completed';

        policyEvents.add(policyEvent);
        
        return policyEvents;
    }


    public static PolicyEvent createAddressChangeEvent(Account oldAccount, Account newAccount, String field, CanaryAMS__Policy__c policy, String oldAddress, String newAddress) {
        PolicyEvent policyEvent = new PolicyEvent();

        policyEvent.policyId = policy.Id;
        policyEvent.policyName = policy.Name;
        policyEvent.action = 'changeAddress';
        policyEvent.operation = 'update';
        policyEvent.recordType = 'Account';
        policyEvent.recordId = oldAccount.Id;
        policyEvent.recordName = newAccount.Name;
        policyEvent.field = field;
        policyEvent.oldValue = oldAddress;
        policyEvent.newValue = newAddress;
        policyEvent.status = 'pending';

        return policyEvent;
    }
    
    public static List<PolicyEvent> createAddressChangeEvents(Account oldAccount, Account newAccount) {
        List<String> billingAddressFields = new List<String>{'BillingStreet', 'BillingCity', 'BillingState', 'BillingPostalCode', 'BillingCountry'};
        List<String> shippingAddressFields = new List<String>{'ShippingStreet', 'ShippingCity', 'ShippingState', 'ShippingPostalCode', 'ShippingCountry'};
        List<CanaryAMS__Policy__c> policies = [SELECT Id, Name FROM CanaryAMS__policy__c WHERE CanaryAMS__Account__c = :oldAccount.Id];
        List<PolicyEvent> policyEvents = new List<PolicyEvent>();

        Boolean billingAddressChanged = Accounts.haveAddressFieldsChanged(oldAccount, newAccount, billingAddressFields);
        Boolean shippingAddressChanged = Accounts.haveAddressFieldsChanged(oldAccount, newAccount, shippingAddressFields);
        
        for (CanaryAMS__Policy__c policy : policies) {
            if (billingAddressChanged) {
                String oldAddress = Accounts.getFormattedBillingAddress(oldAccount);
                String newAddress = Accounts.getFormattedBillingAddress(newAccount);
                policyEvents.add(PolicyEventHistory.createAddressChangeEvent(oldAccount, newAccount, 'BillingAddress', policy, oldAddress, newAddress));
            }

            if (shippingAddressChanged) {
                String oldAddress = Accounts.getFormattedShippingAddress(oldAccount);
                String newAddress = Accounts.getFormattedShippingAddress(newAccount);
                policyEvents.add(PolicyEventHistory.createAddressChangeEvent(oldAccount, newAccount, 'ShippingAddress', policy, oldAddress, newAddress));
            }
        }

        return policyEvents;
    }
}