@isTest
public with sharing class SentryDsnTest {
    private static String MOCK_PUBLIC_KEY = 'PUBLIC';
    private static String MOCK_PRIVATE_KEY = 'PRIVATE';
    private static String MOCK_PROJECT_ID = 'PROJECT_ID';
    private static String MOCK_URL =  'https://' + MOCK_PUBLIC_KEY + ':' +  MOCK_PRIVATE_KEY + '@sentry.io/' + MOCK_PROJECT_ID;

    @isTest static void testSentryDsnCreation() {
        SentryDsn testDsn = new SentryDsn(MOCK_URL);

        String policyId = testDsn.projectId;
        String privateKey = testDsn.privateKey;
        String publicKey = testDsn.publicKey;

        System.assertEquals(policyId, MOCK_PROJECT_ID);
        System.assertEquals(privateKey, MOCK_PRIVATE_KEY);
        System.assertEquals(publicKey, MOCK_PUBLIC_KEY);
    }
}
