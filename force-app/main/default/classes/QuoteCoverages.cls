public with sharing class QuoteCoverages {

    public static String STATUS_COVERAGES_UPDATED = 'Coverages updated successfully.';
    public static String STATUS_COVERAGES_DELETED = 'Coverages deleted successfully.';

    @AuraEnabled(cacheable=true)
    public static List<CanaryAMS__Coverage__c> getQuoteCoverages(String recordId, String objectApiName) {
        List<CanaryAMS__Coverage__c> coverages = new List<CanaryAMS__Coverage__c>();
        
        if (objectApiName == 'CanaryAMS__Insurance_Product__c') {
            coverages = [
                SELECT
                    Id, Name, CanaryAMS__Limit_Format_Integer__c, Zen_Limit__c,
                    Zen_Deductible__c, CanaryAMS__Deductible_Format_Integer__c,
                    CanaryAMS__Deductible_Type_Code__c, CanaryAMS__Current_Term_Amount__c,
                    CanaryAMS__Insurance_Product__c, Carrier__r.Name, API_Coverage_Initial_Availability__c,
                    API_Coverage_Id__c, API_Coverage_Name__c, API_Coverage_Slug__c,
                    API_Policy_Initial_Availability__c, API_Policy_Id__c, API_Policy_Name__c,
                    API_Policy_Slug__c, Carrier_Fee__c, Agency_Fee__c, Zen_12_Month_Premium__c,
                    Zen_12_Month_Carrier_Fee__c, Zen_12_Month_Agency_Fee__c, Is_Sub_Coverage__c
                FROM
                    CanaryAMS__Coverage__c
                WHERE
                    CanaryAMS__Insurance_Product__c = :recordId
            ];
        } else {
            coverages = [
                SELECT
                    Id, Name, CanaryAMS__Limit_Format_Integer__c, Zen_Limit__c,
                    Zen_Deductible__c, CanaryAMS__Deductible_Format_Integer__c,
                    CanaryAMS__Deductible_Type_Code__c, CanaryAMS__Current_Term_Amount__c,
                    Carrier__r.Name, API_Coverage_Initial_Availability__c,
                    API_Coverage_Id__c, API_Coverage_Name__c, API_Coverage_Slug__c,
                    API_Policy_Initial_Availability__c, API_Policy_Id__c,
                    API_Policy_Name__c, API_Policy_Slug__c, Carrier_Fee__c,
                    Agency_Fee__c, CanaryAMS__Policy__c, Zen_12_Month_Premium__c,
                    Zen_12_Month_Carrier_Fee__c, Zen_12_Month_Agency_Fee__c
                FROM
                    CanaryAMS__Coverage__c
                WHERE
                    CanaryAMS__Policy__c = :recordId
            ];
        }
        
        return coverages;
    }

    @AuraEnabled(cacheable=true)
    public static List<CanaryAMS__Coverage__c> getQuoteCoveragesWithPolicyId(String policyId) {
        List<CanaryAMS__Coverage__c> coverages = [SELECT Id, Name, CanaryAMS__Limit_Format_Integer__c, Zen_Limit__c, Zen_Deductible__c, CanaryAMS__Deductible_Format_Integer__c, CanaryAMS__Deductible_Type_Code__c, CanaryAMS__Current_Term_Amount__c, Carrier__r.Name, API_Coverage_Initial_Availability__c, API_Coverage_Id__c, API_Coverage_Name__c, API_Coverage_Slug__c, API_Policy_Initial_Availability__c, API_Policy_Id__c, API_Policy_Name__c, API_Policy_Slug__c, Carrier_Fee__c, Agency_Fee__c, Zen_12_Month_Premium__c, Zen_12_Month_Carrier_Fee__c, Zen_12_Month_Agency_Fee__c from CanaryAMS__Coverage__c WHERE CanaryAMS__Policy__c = :policyId];
        return coverages;
    }

    @AuraEnabled
    public static String upsertQuoteCoverages(List<CanaryAMS__Coverage__c> editedCoverageList) {
        try{
            upsert editedCoverageList;
            return STATUS_COVERAGES_UPDATED;
        } catch(Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static String deleteQuoteCoverages(List<CanaryAMS__Coverage__c> deleteCoverageList) {
        try{
            delete deleteCoverageList;
            return STATUS_COVERAGES_DELETED;
        } catch(Exception e) {
            return e.getMessage();
        }
    }
    
    private static List<CanaryAMS__Coverage__c> getCoveragesForGrouping(String quoteId) {
        return [
            SELECT
                Id,
                API_Coverage_Initial_Availability__c,
                API_Coverage_Id__c,
                API_Coverage_Name__c,
                API_Coverage_Slug__c,
                API_Policy_Initial_Availability__c,
                API_Policy_Id__c,
                API_Policy_Name__c,
                API_Policy_Slug__c,
                Name,
                Carrier__c,
                Carrier__r.Id,
                Carrier__r.Name,
                CanaryAMS__Current_Term_Amount__c,
                Agency_Fee__c,
                Carrier_Fee__c,
                Zen_Limit__c,
                Zen_Deductible__c,
                Zen_Previous_Policy__c,
                Zen_Previous_Policy__r.CanaryAMS__Carrier_Product__c,
                Zen_Previous_Policy__r.CanaryAMS__Policy_Number__c,
                Zen_Previous_Policy__r.RecordTypeId,
                CanaryAMS__Deductible_Type_Code__c,
                Zen_12_Month_Premium__c,
                Zen_12_Month_Carrier_Fee__c,
                Zen_12_Month_Agency_Fee__c
            FROM
                CanaryAMS__Coverage__c
            WHERE
                CanaryAMS__Insurance_Product__c = :quoteId
        ];
    }

    private static CanaryAMS__Insurance_Product__c getQuoteForGrouping(String quoteId) {
        return [
            SELECT
                Id,
                Name,
                CanaryAMS__Account__c,
                CanaryAMS__Contact_for_Quote__c,
                CanaryAMS__Producer__c,
                OwnerId,
                ZEN_Payment_Status__c,
                CanaryAMS__Policy_Effective_Date__c,
                CanaryAMS__Quoted_Term__c,
                CanaryAMS__Current_Retroactive_Date__c,
                CanaryAMS__Quote_Source__c,
                CanaryAMS__Quote_Sub_Source__c,
                ZEN_Query_Param_Adgroup__c,
                ZEN_Query_Param_Keyword__c,
                ZEN_Query_Param_UTM_Campaign__c,
                ZEN_Query_Param_UTM_Content__c,
                ZEN_Query_Param_UTM_Medium__c,
                ZEN_Query_Param_UTM_Source__c,
                ZEN_Query_Param_UTM_Term__c,
                CanaryAMS__Quoted_Carrier_Product__c,
                CanaryAMS__Quoted_Carrier__c,
                CanaryAMS__Policy_Expiration_Date__c,
                Xero_Invoice_Number__c
            FROM
                CanaryAMS__Insurance_Product__c
            WHERE
                Id = :quoteId
        ];
    }

    private enum GroupBy { CARRIER_AND_POLICY, PREVIOUS_POLICY }

    private static Policies.GroupedPolicy createGroupedPolicy(CanaryAMS__Insurance_Product__c quote, CanaryAMS__Coverage__c coverage, Boolean shouldBeGroupedByPreviousPolicy) {
        Policies.GroupedPolicy groupedPolicy = new Policies.GroupedPolicy();

        groupedPolicy.policyName = coverage.API_Policy_Name__c;
        groupedPolicy.displayName = quote.Name + ' - ' + coverage.API_Policy_Name__c;
        groupedPolicy.ownerId = quote.OwnerId;
        groupedPolicy.quoteId = quote.Id;
        groupedPolicy.term = quote.CanaryAMS__Quoted_Term__c;
        groupedPolicy.effectiveDate = quote.CanaryAMS__Policy_Effective_Date__c;
        groupedPolicy.billingType = quote.ZEN_Payment_Status__c;
        groupedPolicy.accountId = quote.CanaryAMS__Account__c;
        groupedPolicy.contactId = quote.CanaryAMS__Contact_for_Quote__c;
        groupedPolicy.carrier = coverage.Carrier__r;
        groupedPolicy.premium = coverage.CanaryAMS__Current_Term_Amount__c != NULL ? coverage.CanaryAMS__Current_Term_Amount__c : 0;
        groupedPolicy.agencyFee = coverage.Agency_Fee__c != NULL ? coverage.Agency_Fee__c : 0;
        groupedPolicy.carrierFee = coverage.Carrier_Fee__c != NULL ? coverage.Carrier_Fee__c : 0;
        groupedPolicy.coverages = new List<CanaryAMS__Coverage__c>();
        groupedPolicy.coverages.add(coverage);
        groupedPolicy.producerId = quote.CanaryAMS__Producer__c;
        groupedPolicy.retroactiveDate = quote.CanaryAMS__Current_Retroactive_Date__c;
        groupedPolicy.quoteSource = quote.CanaryAMS__Quote_Source__c;
        groupedPolicy.quoteSubSource = quote.CanaryAMS__Quote_Sub_Source__c;
        groupedPolicy.adgroup = quote.ZEN_Query_Param_Adgroup__c;
        groupedPolicy.keyword = quote.ZEN_Query_Param_Keyword__c;
        groupedPolicy.utmCampaign = quote.ZEN_Query_Param_UTM_Campaign__c;
        groupedPolicy.utmContent = quote.ZEN_Query_Param_UTM_Content__c;
        groupedPolicy.utmMedium = quote.ZEN_Query_Param_UTM_Medium__c;
        groupedPolicy.utmSource = quote.ZEN_Query_Param_UTM_Source__c;
        groupedPolicy.utmTerm = quote.ZEN_Query_Param_UTM_Term__c;
        groupedPolicy.xeroInvoiceNumber = quote.Xero_Invoice_Number__c;
        groupedPolicy.expirationDate = quote.CanaryAMS__Policy_Expiration_Date__c;

        CanaryAMS__Carrier__c zenMgaCarrier = Carriers.getZenMGACarrier();
        
        if (zenMgaCarrier != null && quote.CanaryAMS__Quoted_Carrier__c == zenMgaCarrier.Id) {
            groupedPolicy.carrierProduct = quote.CanaryAMS__Quoted_Carrier_Product__c;
        }

        if (shouldBeGroupedByPreviousPolicy) {
            groupedPolicy.carrierProduct = coverage.Zen_Previous_Policy__r.CanaryAMS__Carrier_Product__c;
            groupedPolicy.policyNumber = coverage.Zen_Previous_Policy__r.CanaryAMS__Policy_Number__c;
            groupedPolicy.recordType = coverage.Zen_Previous_Policy__r.RecordTypeId;
        }

        return groupedPolicy;
    }

    private static List<Policies.GroupedPolicy> groupQuoteCoveragesBy(String quoteId, GroupBy groupBy) {
        List<CanaryAMS__Coverage__c> coverages = QuoteCoverages.getCoveragesForGrouping(quoteId);
        CanaryAMS__Insurance_Product__c quote = QuoteCoverages.getQuoteForGrouping(quoteId);

        List<Policies.GroupedPolicy> policies = new List<Policies.GroupedPolicy>();
        Map<String, Policies.GroupedPolicy> policyMap = new Map<String, Policies.GroupedPolicy>();

        for (CanaryAMS__Coverage__c coverage: coverages) {
            String coverageKey;
            Boolean shouldBeGroupedByPreviousPolicy = groupBy == QuoteCoverages.GroupBy.PREVIOUS_POLICY && coverage.Zen_Previous_Policy__c != NULL;

            if (shouldBeGroupedByPreviousPolicy) {
                coverageKey = coverage.Zen_Previous_Policy__c;
            } else {
                coverageKey = coverage.Carrier__r.Name + ':' + coverage.API_Policy_Name__c;
            }

            if (coverage.Zen_Limit__c != 'Excluded') {
                if (policyMap.containsKey(coverageKey)) {
                    Policies.GroupedPolicy extantPolicy = policyMap.get(coverageKey);
                    Set<String> policyFields = extantPolicy.getAttributes();
                    extantPolicy.coverages.add(coverage);
                    
                    if (coverage.CanaryAMS__Current_Term_Amount__c != NULL) {
                        extantPolicy.premium = extantPolicy.premium + coverage.CanaryAMS__Current_Term_Amount__c;
                    }
                    
                    if (coverage.Agency_Fee__c != NULL) {
                        extantPolicy.agencyFee = extantPolicy.agencyFee + coverage.Agency_Fee__c;
                    }

                    if (coverage.Carrier_Fee__c != NULL) {
                        extantPolicy.carrierFee = extantPolicy.carrierFee + coverage.Carrier_Fee__c;
                    }
                } else {
                    Policies.GroupedPolicy policy = QuoteCoverages.createGroupedPolicy(quote, coverage, shouldBeGroupedByPreviousPolicy);
                    policyMap.put(coverageKey, policy);
                }
            }
        }

        policies.addAll(policyMap.values());

        return policies;
    }

    @AuraEnabled
    public static List<Policies.GroupedPolicy> groupQuoteCoveragesByCarrierAndPolicy(String quoteId) {
        return QuoteCoverages.groupQuoteCoveragesBy(quoteId, QuoteCoverages.GroupBy.CARRIER_AND_POLICY);
    }

    @AuraEnabled
    public static List<Policies.GroupedPolicy> groupQuoteCoveragesByPreviousPolicy(String quoteId) {
        return QuoteCoverages.groupQuoteCoveragesBy(quoteId, QuoteCoverages.GroupBy.PREVIOUS_POLICY);
    }
}