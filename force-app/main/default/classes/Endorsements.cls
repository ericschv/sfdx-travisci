public with sharing class Endorsements {

    @testVisible public class Endorsement {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String createdAt { get; set; }
        @AuraEnabled public String updatedAt { get; set; }
        @AuraEnabled public String endorsementType { get; set; }
        @AuraEnabled public String effectiveDate { get; set; }
        @AuraEnabled public Decimal newTotalPremium { get; set; }
        @AuraEnabled public Decimal oldTotalPremium { get; set; }
        @AuraEnabled public Decimal premiumDelta { get; set; }
        @AuraEnabled public Decimal proratedPremium { get; set; }
        @AuraEnabled public List<PolicyEvent> events { get; set; }
        @AuraEnabled public List<String> eventIds { get; set; }
        @AuraEnabled public String policyId { get; set; }
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public String notes { get; set; }        
    }

    @testVisible public class CreateEndorsementResponse {
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public String error { get; set; }     
    }

    @testVisible public class PolicyEndorsements {
        @AuraEnabled public String policyId { get; set; }
        @AuraEnabled public List<Endorsements.Endorsement> endorsements { get; set; }
    }

    @AuraEnabled(cacheable=false)
    public static Endorsements.CreateEndorsementResponse createEndorsements(List<Endorsements.Endorsement> endorsements) {
        // make HTTP request to API to create the given endorsement on the API
        String apiUrl = SharedUtils.getApiHost();
        
        String requestJSON = '{ "endorsements": ' + JSON.serialize(endorsements, true) + ' }';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl + '/v4/endorsements');
        request.setMethod('POST');
        request.setHeader('content-type', 'application/json; charset=utf-8');
        request.setBody(requestJSON);
        HttpResponse response = http.send(request);

        CreateEndorsementResponse restResponse = new CreateEndorsementResponse();

        if (response.getStatusCode() == 200) {
            restResponse.message = 'Endorsement created successfully: ' + requestJSON;
        } else {
            restResponse.error = 'There was an error creating the endorsement: ' + response.getStatusCode() + ': ' + response.getStatus() + ': ' + requestJSON;
            System.debug('There was an error creating the endorsement: ' + response.getStatusCode() + ': ' + response.getStatus() + ': ' + requestJSON);
        }

        return restResponse;
    }


    @AuraEnabled(cacheable=false)
    public static List<Endorsements.Endorsement> getEndorsementsByPolicyId(String policyId) {
        // make HTTP request to API to get all Endorsements for policyId
        String apiUrl = SharedUtils.getApiHost();
        List<Endorsements.Endorsement> policyEndorsements;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String queryString = '?policyId='+policyId;
        
        request.setEndpoint(apiUrl + '/v4/endorsements/byPolicyId'+queryString);
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String endorsementJSON = JSON.serialize(deserializedResponse.get('endorsements'));
            policyEndorsements = (List<Endorsements.Endorsement>) JSON.deserialize(endorsementJSON, List<Endorsements.Endorsement>.class);
        } else {
            System.debug('There was an error fetching endorsements for policy: ' + policyId + ', API Status: ' + response.getStatusCode() + ': ' + response.getStatus());
        }

        return policyEndorsements;
    }

    public static List<Endorsements.PolicyEndorsements> getEndorsementsByPolicyIds(Set<Id> policyIds) {
        List<Endorsements.PolicyEndorsements> policyEndorsements = new List<Endorsements.PolicyEndorsements>();

        if (policyIds.isEmpty()) return policyEndorsements;

        // make HTTP request to API to get all Endorsements for policyId
        String apiUrl = SharedUtils.getApiHost();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // build the query string using the Policy Ids
        List<String> policyIdQueryStrings = new List<String>();
        for (String policyId : policyIds) {
            policyIdQueryStrings.add('policyIds='+policyId);
        }
        String queryString = '?' + String.join(policyIdQueryStrings, '&');

        request.setEndpoint(apiUrl + '/v4/endorsements/byPolicyIds'+queryString);
        request.setHeader('content-type', 'application/json; charset=utf-8');
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String endorsementJSON = JSON.serialize(deserializedResponse.get('data'));
            policyEndorsements = (List<Endorsements.PolicyEndorsements>) JSON.deserialize(endorsementJSON, List<Endorsements.PolicyEndorsements>.class);
        } else {
            System.debug('There was an error fetching endorsements for policies: ' + String.join(policyIdQueryStrings, ', ') + ', API Status: ' + response.getStatusCode() + ': ' + response.getStatus());
            // Sentry.record('There was an error fetching endorsements for policies: ' + requestJSON + ', API Status: ' + response.getStatusCode() + ': ' + response.getStatus());
        }

        return policyEndorsements;
    }

}
