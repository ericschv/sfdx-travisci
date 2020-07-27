@isTest
global with sharing class MockHttpResponseGenerator implements HttpCalloutMock {
    private static String generateMockJsonBody() {

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        gen.writeStringField('testField', 'test');
        gen.writeEndObject();

        return gen.getAsString();
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/json');

        String body = MockHttpResponseGenerator.generateMockJsonBody();

        res.setBody(body);

        res.setStatusCode(200);
        return res;
    }
}