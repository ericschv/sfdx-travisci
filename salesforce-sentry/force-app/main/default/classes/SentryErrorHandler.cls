public with sharing class SentryErrorHandler {
    public void run() {
        List<String> errors = new List<String>();

        for (Sentry_Error__e e : (List<Sentry_Error__e>) Trigger.new) {
            errors.add(e.Content__c);
        }

        if (errors.isEmpty() == true) {
            return;
        }
    
        sendErrors(errors);
    }

    @future(callout=true)
    public static void sendErrors(List<String> errors) {
        for (String error : errors) {
            SentryClient.sendEventToSentry(error);
        }
    }
}