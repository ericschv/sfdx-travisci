public with sharing class SentryClient {

    private static SentryDsn dsn = SentryConfig.getDsn();

    public class SentryResponse {
        public String id { get; set; }
        public String error { get; set; }
    }

    public static SentryClient.SentryResponse sendEventToSentry(String serializedEvent) {
        HttpRequest request = new HttpRequest();
    
        // you'll have to register a remote site for this url, but can probably just do a generic https://sentry.io...

        String sentryLogEndpoint = dsn.sentryEndpoint;

        request.setEndpoint(sentryLogEndpoint);

        request.setHeader('content-type', 'application/json');

        addSentryRequestHeaders(request);

        request.setMethod('POST');
                
        request.setBody(serializedEvent);

        HttpResponse resp = new Http().send(request);

        SentryClient.SentryResponse response = new SentryClient.SentryResponse();

        if (resp.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            String sentryExceptionId = (String) results.get('id');
            
            response.id = sentryExceptionId;
        } else {
            response.error = resp.getStatusCode() + ': ' + resp.getStatus();
        }

        return response;
    }

    private static void addSentryRequestHeaders(HttpRequest req) {
        Map<String, String> headers = new Map<String, String> {
                'sentry_version' => '7',
                'sentry_client' => 'salesforce/47.0',
                'sentry_sdk' => 'sentry.php',
                'sentry_key' => dsn.publicKey
        };

        if (dsn.privateKey != null) {
            headers.put('sentry_secret', dsn.privateKey);
        }

        String[] headerSets = new List<String>();
        for (String key : headers.keySet()) {
            headerSets.add(key + '=' + headers.get(key));
        }
        
        String header = 'Sentry ' + String.join(headerSets, ', ');

        req.setHeader('X-Sentry-Auth', header);
    }
}