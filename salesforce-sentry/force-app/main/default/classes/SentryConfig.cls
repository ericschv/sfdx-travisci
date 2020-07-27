public with sharing class SentryConfig {
    /* 
    Find the Sentry DSN by going to
    `Settings` -> `Projects` -> Select applicable Salesforce sentry project -> `Client Keys (DSN)`
    and then copy the deprecated DSN (as this version requires the secret to be available)
    */

    // Urls are of the following format: 'https://PUBLIC:PRIVATE@sentry.io/PROJECT_ID';
    // or alternatively: 'https://PUBLIC@sentry.io/PROJECT_ID';

    private static String sandboxDsnUrl = 'https://5c735f32b3e44dc0964711abfcab0201:4367f396a5ca479f80840b806a54e6f1@sentry.io/2640851';

    private static String productionDsnUrl = 'https://aa9a730c102b414db645061631b9f6fa:685348da311e4722aa7850df9fc6ba3f@sentry.io/2640891';

    private static Map<String, SentryDsn> sentryDsn = new Map<String, SentryDsn> {
                'sandboxEndpoint' => new SentryDsn(SentryConfig.sandboxDsnUrl),
                'productionEndpoint' => new SentryDsn(SentryConfig.productionDsnUrl)
    }; 

    private static String environmentName = SentrySharedUtils.getInstanceTypeAsString();

    public static SentryDsn getDsn() {
        Boolean isSandbox = SentrySharedUtils.isSandbox();

        return isSandbox ? sentryDsn.get('sandboxEndpoint') : sentryDsn.get('productionEndpoint');
    }

    public static String getEnvironmentName() {
        return environmentName;
    }
}
