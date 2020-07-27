@isTest
private with sharing class PolicyDocumentsTest {

    @isTest static void getPolicyDocument() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PolicyDocumentResource');
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        PolicyDocuments.PolicyDocumentResponse policyDocumentResponse = PolicyDocuments.getPolicyDocument('test');

        String baseOrgUrl = String.valueOf(System.URL.getOrgDomainUrl().toExternalForm());

        System.assertEquals(policyDocumentResponse.url, baseOrgUrl + '/servlet/servlet.FileDownload?file=12345&operationContext=S1');
    }

    @isTest static void getPolicyDocumentError() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PolicyDocumentErrorResource');
        mock.setStatusCode(404);
        mock.setStatus('Not Found');
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        PolicyDocuments.PolicyDocumentResponse policyDocumentResponse = PolicyDocuments.getPolicyDocument('test');

        String baseOrgUrl = String.valueOf(System.URL.getOrgDomainUrl().toExternalForm());

        System.assertEquals(policyDocumentResponse.error, '404: Not Found');
    }
}
