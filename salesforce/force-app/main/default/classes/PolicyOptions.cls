public with sharing class PolicyOptions {

    class ApiLimit {
        @AuraEnabled public String limitValue { get; set; }
    }
    
    class ApiCoverage {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String premium { get; set; }
        @AuraEnabled public String agencyFee { get; set; }
        @AuraEnabled public String carrierFee { get; set; }
        @AuraEnabled public String availability { get; set; } 
        @AuraEnabled public List<ApiLimit> options { get; set; }

    }
    
    class ApiPolicy {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String availability { get; set; } 
        @AuraEnabled public List<ApiCoverage> coverages { get; set; }
    }

    public static List<ApiPolicy> parsePolicies(String policyJSON) {
        List<ApiPolicy> policies = (List<ApiPolicy>) JSON.deserialize(policyJSON, List<ApiPolicy>.class);

        for (ApiPolicy policy: policies) {
            if (policy.availability == null) {
                policy.availability = 'public';
            }
        }

        return policies;
    }

    @AuraEnabled(cacheable=true)
    public static List<ApiPolicy> getPolicyAndCoverageOptions(String industrySlug, String flowSlug, String subindustrySlug, String submissionId) {
        
        String apiUrl = SharedUtils.getApiHost();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String queryString = '?flowName='+flowSlug+'&industry='+industrySlug;
        queryString += '&subindustry=' + subindustrySlug;
        queryString += '&availability=public,private';
        
        if (!String.isBlank(submissionId)) { queryString += '&submissionId=' + submissionId; }

        request.setEndpoint(apiUrl + '/v4/policy-options'+queryString);
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            // NOTE:  This string replace is bad. But "limit" is a reserved word in Apex and we can't deserialize the JSON into an 
            // object with that property name.
            String fixedResponse = response.getBody().replace('"limit":', '"limitValue":');
            // Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(fixedBody);
            // String policyJSON = JSON.serialize(deserializedResponse.get('policies'));

            // return apiUrl + '/policy-options'+queryString;
            return parsePolicies(fixedResponse);
        }

        return null;
    }
}
