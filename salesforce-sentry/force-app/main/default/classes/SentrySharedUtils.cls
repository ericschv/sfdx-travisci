public with sharing class SentrySharedUtils {
    @TestVisible private enum InstanceType { PRODUCTION, SANDBOX }

    @TestVisible private static Map<String,String> apiDomain = new Map<String, String> { 
        'sandboxApi' => 'https://stg5-api.zensurance.com',
        'productionApi' => 'https://api.zensurance.com'
    };

    public static Boolean isSandbox() {
        Boolean isSandbox = [Select IsSandbox from Organization limit 1].IsSandbox;
        
        return isSandbox;
    }

    public static String getApiHost() {
        // determine whether we're in sandbox or prod.
        Boolean isSandbox = SentrySharedUtils.isSandbox();
        // Use the appropriate URL. This method will not work for questionnaires on your local env...
        String apiUrl = isSandbox ? apiDomain.get('sandboxApi') : apiDomain.get('productionApi');

        return apiUrl;
    }

    public static InstanceType getInstanceType() {
        Boolean isSandbox = SentrySharedUtils.isSandbox();

        return isSandbox ? InstanceType.SANDBOX : InstanceType.PRODUCTION;
    }

    public static String getInstanceTypeAsString() {
        return String.valueOf(getInstanceType());
    }

    private static List<String> getDomainFromUrl(String url) {
        List<String> protocalAndDomain = url.split('://');
        List<String> domainLevels = protocalAndDomain[1].split('\\.');

        return domainLevels;
    }

    public static String getInstanceLabel() {
        String orgUrl = Url.getOrgDomainUrl().toExternalForm();

        List<String> domainLevels = getDomainFromUrl(orgUrl);
        
        String subdomain = domainLevels[0];

        return subdomain.split('--')[0].toLowerCase();
    }

    public static String generateUuid() {
        Blob blobKey = Crypto.generateAesKey(128);
        String hexKey = EncodingUtil.convertToHex(blobKey);

        String id =  hexKey.substring(0,8)+ '-' + hexKey.substring(8,12) + '-' + hexKey.substring(12,16) + '-' + hexKey.substring(16,20) + '-' + hexKey.substring(20);

        return id;
    }

    public static String generateTimestamp() {
        String timestamp = Datetime.now().formatGmt('yyyy-MM-dd') + 'T' + Datetime.now().formatGmt('HH:mm:ss') + 'Z';

        return timestamp;
    }
}
