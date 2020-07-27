@isTest
public with sharing class SentrySharedUtilsTest {

    @isTest static void testGetInstanceLabel() {
        String instanceLabel = SentrySharedUtils.getInstanceLabel();

        String expectedInstanceLabel = 'zensurance';

        System.assert(expectedInstanceLabel == instanceLabel);
    }

    @isTest static void testGenerateUuid() {
        String testUuid = SentrySharedUtils.generateUuid();

        String anotherTestUuid = SentrySharedUtils.generateUuid();

        Pattern regexHexadecimalPattern = Pattern.compile('[A-Fa-f0-9-]+');

        Matcher regexMatcher = regexHexadecimalPattern.matcher(testUuid);

        // check length
        System.assert(testUuid.length() == 36);

        // check alphanumeric (could also test that it's hexadecimal)
        System.assert(regexMatcher.matches() == true);

        // check uniqueness
        System.assert(testUuid != anotherTestUuid);
    }

    @isTest static void testGetInstanceType() {
        SentrySharedUtils.InstanceType instanceType = SentrySharedUtils.getInstanceType();

        System.assert(instanceType == SentrySharedUtils.InstanceType.SANDBOX || instanceType == SentrySharedUtils.InstanceType.PRODUCTION);
    }


    @isTest static void testGetInstanceTypeAsString() {
        String instanceType = SentrySharedUtils.getInstanceTypeAsString();

        System.assert(instanceType == 'SANDBOX' || instanceType == 'PRODUCTION');
    }

    @isTest static void testGetApiHost() {
        String apiDomain = SentrySharedUtils.getApiHost();

        System.assert(apiDomain == SentrySharedUtils.apiDomain.get('sandboxApi') || apiDomain == SentrySharedUtils.apiDomain.get('productionApi'));
    }

}
