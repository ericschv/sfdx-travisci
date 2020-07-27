@isTest
public with sharing class SentryEventTest {

    private static String commonExceptionMessage = 'This is a constructed exception!';

    private static Exception createException() {
        CalloutException exceptionToReturn = new CalloutException();
        exceptionToReturn.setMessage(commonExceptionMessage);
        return exceptionToReturn;
    }

    @isTest static void testCreateSentryEventWithRegularException() {
        Exception createdException = SentryEventTest.createException();
        SentryEvent sentryEvent = new SentryEvent(createdException);

        Map<String, String> expectedSdk = new Map<String, String> { 'name' => 'sentry.apex', 'version' => '1' };

        System.assert(sentryEvent.environment == 'PRODUCTION' || sentryEvent.environment == 'SANDBOX'); 
        System.assert(sentryEvent.platform == 'salesforce');
        System.assert(expectedSdk.equals(sentryEvent.sdk));
        System.assert(sentryEvent.level == 'error');
        System.assert(sentryEvent.message == commonExceptionMessage);
    }
}
