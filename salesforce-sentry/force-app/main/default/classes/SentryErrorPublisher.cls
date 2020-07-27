public with sharing class SentryErrorPublisher {
    @testVisible private static List<Sentry_Error__e> eventList = new List<Sentry_Error__e>();
    
    public static void publishSentryError(SentryEvent err) {
        Sentry_Error__e sentryError = new Sentry_Error__e(Content__c = JSON.serialize(err.toMessage()));
        EventBus.publish(sentryError);
        // store published events for testing only
        eventList.add(sentryError);
    }
}
