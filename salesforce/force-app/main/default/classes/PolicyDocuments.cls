public with sharing class PolicyDocuments {

    @testVisible public class PolicyDocumentResponse {
        @AuraEnabled public String url { get; set; }
        @AuraEnabled public String error { get; set; }
    }
    
    @AuraEnabled(cacheable=false)
    public static PolicyDocuments.PolicyDocumentResponse getPolicyDocument(String policyId) {
        String documentUrl;
        
        // determine whether we're in sandbox or prod.
        Boolean isSandbox = [Select IsSandbox from Organization limit 1].IsSandbox;
        
        String apiUrl = SharedUtils.getApiHost();
        String baseOrgUrl = String.valueOf(System.URL.getOrgDomainUrl().toExternalForm());

        JSONGenerator requestBody = JSON.createGenerator(true);
        requestBody.writeStartObject();
        requestBody.writeStringField('policyId', policyId);
        requestBody.writeEndObject();

        // send a POST(!) request to the questionnaire endpoint to get the answerStore
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl + '/v4/policy-documents');
        request.setMethod('POST');
        request.setBody(requestBody.getAsString());
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        HttpResponse response = http.send(request);

        PolicyDocuments.PolicyDocumentResponse resp = new PolicyDocuments.PolicyDocumentResponse();
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 201) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String documentId = (String) results.get('id');
            
            resp.url = baseOrgUrl + '/servlet/servlet.FileDownload?file='+ documentId +'&operationContext=S1';
        } else {
            resp.error = response.getStatusCode() + ': ' + response.getStatus();
        }

        return resp;
    }

}
