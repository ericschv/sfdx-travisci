@isTest
private with sharing class PolicyOptionsTest {

    @testSetup static void setup() {}

    @isTest static void testParsePoliciesFromResponse() {
        String policiesJSON = '[{"id":"startup-crime-3wnxruhH9Ct","type":"crime","name":"Crime","availability":"private","trigger":{"flowName":"startup","industry":{"$in":["tech","mediaMarketing","consultant"]}},"coverages":[{"id":"startup-crime_employee_dishonesty-GQQsS_FPwLG","type":"crime_employee_dishonesty","name":"Crime: Employee Dishonesty","availability":"private","trigger":{"flowName":"startup","industry":{"$in":["tech","mediaMarketing","consultant"]}},"options":[{"limit":5000},{"limit":10000},{"limit":25000},{"limit":50000},{"limit":100000},{"limit":250000}]},{"id":"startup-crime_money_securities-aWS9PoKhLTk","type":"crime_money_securities","name":"Crime: Money & Securities","availability":"private","trigger":{"flowName":"startup","industry":{"$in":["tech","mediaMarketing","consultant"]}},"options":[{"limit":5000},{"limit":10000},{"limit":25000},{"limit":50000},{"limit":100000},{"limit":250000}]},{"id":"startup-crime_third_party_extension-3U3L4QiWsV-","type":"crime_third_party_extension","name":"Crime: Third Party Extension","availability":"private","trigger":{"flowName":"startup","industry":{"$in":["tech","mediaMarketing","consultant"]}},"options":[{"limit":"Included"}]}]}]';

        List<Object> policiesList = PolicyOptions.parsePolicies(policiesJSON);

        System.assertEquals(policiesList.size(), 1);
    }

    @isTest static void testGetPolicyAndCoverageOptions() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PolicyOptionsResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        List<Object> policiesList = PolicyOptions.getPolicyAndCoverageOptions('industrySlug', 'flowSlug', 'subindustrySlug', 'submissionId');

        System.assertEquals(policiesList.size(), 7);
    }
}
