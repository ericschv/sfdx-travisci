public without sharing class Sentry {
    private static SentryEvent convertExceptionToError(Exception salesforceException) {
        return new SentryEvent(salesforceException);
    }

    public static void record(Exception salesforceException, String errorMessage) {
        salesforceException.setMessage(errorMessage);

        Sentry.record(salesforceException);
    }

    public static void record(String error) {
        SentryException err = new SentryException(error);
        
        Sentry.record(err);
    }

    public static void record(Exception salesforceException) {
        SentryEvent err = convertExceptionToError(salesforceException);

        sendEvent(err);
    }

    private static void sendEvent(SentryEvent err) {
        SentryErrorPublisher.publishSentryError(err);
    }
}