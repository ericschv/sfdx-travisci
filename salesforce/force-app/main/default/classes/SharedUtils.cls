public with sharing class SharedUtils {
    
    @AuraEnabled(cacheable=true)
    public static String getApiHost() {
        // determine whether we're in sandbox or prod.
        Boolean isSandbox = [Select IsSandbox from Organization limit 1].IsSandbox;
        // Use the appropriate URL. This method will not work for questionnaires on your local env...
        String apiUrl = isSandbox ? 'https://stg7-api.zensurance.com' : 'https://api.zensurance.com';

        return apiUrl;
    }
}