trigger SentryError on Sentry_Error__e (after insert) {
    SentryErrorHandler handler = new SentryErrorHandler();
    handler.run();
}