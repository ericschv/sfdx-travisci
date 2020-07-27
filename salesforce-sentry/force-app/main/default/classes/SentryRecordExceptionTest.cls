@isTest
public with sharing class SentryRecordExceptionTest {
    private static void throwException() {
        // create a callout exception (although any kind of exception could do for this)
        CalloutException exceptionToThrow = new CalloutException();
        exceptionToThrow.setMessage('This is a constructed exception!');
        throw exceptionToThrow;
    }

    @isTest static void testSentryEventPublish() {
        List<String> errors = new List<String>();

        // mock POST request to sentry api to post exception
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        
        try {
            SentryRecordExceptionTest.throwException();
        } catch (Exception caughtException) {
            Sentry.record(caughtException);
        }

        Test.stopTest();

        List<Sentry_Error__e> newlyPublishedEvents = SentryErrorPublisher.eventList;

        System.assert(newlyPublishedEvents.size() == 1);
    }
}
