public with sharing class Policies {
    static String STATUS_POLICIES_UPDATED_SUCCESS = 'Policies updated successfully.';
    static String STATUS_POLICIES_CREATED_SUCCESS = 'Policies created successfully.';
    static String STATUS_ACTIVE = 'Active';
    public static String OTHER_TERM = 'Other';
    public static String SOURCE_BIND = 'bind';

    @testVisible public class ExtendedPolicy {
        @AuraEnabled public CanaryAMS__Policy__c policy { get; set; }
        @AuraEnabled public List<CanaryAMS__Coverage__c> coverages { get; set; }
        @AuraEnabled public List<CanaryAMS__Claim__c> claims { get; set; }
        @AuraEnabled public List<Endorsements.Endorsement> endorsements { get; set; }
    }


    @testVisible public class GroupedPolicy {
        @AuraEnabled public String displayName { get; set; }
        @AuraEnabled public String policyName { get; set; }
        @AuraEnabled public String accountId { get; set; }
        @AuraEnabled public String contactId { get; set; }
        @AuraEnabled public String quoteId { get; set; }
        @AuraEnabled public Date effectiveDate { get; set; }
        @AuraEnabled public CanaryAMS__Carrier__c carrier { get; set; }
        @AuraEnabled public String carrierProduct { get; set; }
        @AuraEnabled public List<CanaryAMS__Coverage__c> coverages { get; set; }
        @AuraEnabled public Decimal premium { get; set; }
        @AuraEnabled public Decimal agencyFee { get; set; }
        @AuraEnabled public Decimal carrierFee { get; set; }
        @AuraEnabled public String ownerId { get; set; }
        @AuraEnabled public String billingType { get; set; }
        @AuraEnabled public String recordType { get; set; }
        @AuraEnabled public String term { get; set; }
        @AuraEnabled public Date expirationDate { get; set; }
        @AuraEnabled public String policyNumber { get; set; }
        @AuraEnabled public String producerId { get; set; }
        @AuraEnabled public String xeroInvoiceNumber { get; set; }
        @AuraEnabled public Date retroactiveDate { get; set; }
        @AuraEnabled public String quoteSource { get; set; }
        @AuraEnabled public String quoteSubSource { get; set; }
        @AuraEnabled public String adgroup { get; set; }
        @AuraEnabled public String keyword { get; set; }
        @AuraEnabled public String utmCampaign { get; set; }
        @AuraEnabled public String utmContent { get; set; }
        @AuraEnabled public String utmMedium { get; set; }
        @AuraEnabled public String utmSource { get; set; }
        @AuraEnabled public String utmTerm { get; set; }
        
        public Set<String> getAttributes() {
            // Serialize our Object into JSON
            String s = JSON.serialize(this);

            // Deserialize it back into a key/value map
            Map<String,Object> obj = 
                (Map<String,Object>) JSON.deserializeUntyped(s);

            // Return a Set of the field names
            return obj.keyset().clone();
        }
    }

    public static AggregateResult getPolicyPremiumAndFees(String policyId) {
        return [
            SELECT
                SUM(CanaryAMS__Current_Term_Amount__c)premium,
                SUM(Agency_Fee__c)agencyfee,
                SUM(Carrier_Fee__c)carrierfee,
                SUM(Zen_12_Month_Premium__c)zen_12_month_premium,
                SUM(Zen_12_Month_Carrier_Fee__c)zen_12_month_carrier_fee,
                SUM(Zen_12_Month_Agency_Fee__c)zen_12_month_agency_fee
            FROM
                CanaryAMS__Coverage__c
            where
                CanaryAMS__Policy__c = :policyId
                AND Zen_Limit__c != 'Excluded'
        ][0];
    }

    @AuraEnabled
    public static CanaryAMS__Policy__c calculatePolicyPremiumAndFees(String policyId) {
        AggregateResult calculatedResult = Policies.getPolicyPremiumAndFees(policyId);

        try {
            CanaryAMS__Policy__c policy = [SELECT Id FROM CanaryAMS__Policy__c WHERE Id=:policyId LIMIT 1];

            Double calculatedPremium = calculatedResult.get('premium') != NULL ? double.valueOf(calculatedResult.get('premium')) : 0;
            Double calculatedAgencyFee = calculatedResult.get('agencyfee') != NULL ? double.valueOf(calculatedResult.get('agencyfee')) : 0;
            Double calculatedCarrierFee = calculatedResult.get('carrierfee') != NULL ? double.valueOf(calculatedResult.get('carrierfee')) : 0;
            Double calculated12MonthPremium = calculatedResult.get('zen_12_month_premium') != NULL ? double.valueOf(calculatedResult.get('zen_12_month_premium')) : 0;
            Double calculated12MonthCarrierFee = calculatedResult.get('zen_12_month_carrier_fee') != NULL ? double.valueOf(calculatedResult.get('zen_12_month_carrier_fee')) : 0;
            Double calculated12MonthAgencyFee = calculatedResult.get('zen_12_month_agency_fee') != NULL ? double.valueOf(calculatedResult.get('zen_12_month_agency_fee')) : 0;

            policy.CanaryAMS__Net_Premium__c = calculatedPremium;
            policy.CanaryAMS__Total_Agency_Fees__c = calculatedAgencyFee;
            policy.CanaryAMS__Total_Taxes_Fees__c = calculatedCarrierFee;
            policy.Zen_Calculated_12_Month_Premium__c = calculated12MonthPremium;
            policy.Zen_Calculated_12_Month_Carrier_Fee__c = calculated12MonthCarrierFee;
            policy.Zen_Calculated_12_Month_Agency_Fee__c = calculated12MonthAgencyFee;

            update policy; 

            return policy;
        } catch(QueryException e) {
            // throw new zenQueryException('There was an error calculating quote premium and fees: ' + e.getMessage() + ': ' + policyId);
            System.debug('There was an error calculating quote premium and fees: ' + e.getMessage() + ': ' + policyId);
            return null;
        }
    }

    @AuraEnabled
    public static List<CanaryAMS__Policy__c> findExistingPolicies(List<String> policyNumbers, Date effectiveDate) {
        List<CanaryAMS__Policy__c> existingPolicies = [
            SELECT
                CanaryAMS__Policy_Number__c,
                CanaryAMS__Effective_Date__c
            FROM
                CanaryAMS__Policy__c
            WHERE
                CanaryAMS__Policy_Number__c in :policyNumbers
                AND CanaryAMS__Effective_Date__c = :effectiveDate
        ];

        return existingPolicies;
    }

    private static CanaryAMS__Policy__c insertPolicyWithGroupPolicy(GroupedPolicy groupedPolicy) {
        CanaryAMS__Policy__c policy = new CanaryAMS__Policy__c();
        CanaryAMS__Insurance_Product__c quote = Quotes.getQuoteForUpdate(groupedPolicy.quoteId);

        policy.Name = groupedPolicy.displayName;
        policy.CanaryAMS__Policy_Status__c = STATUS_ACTIVE;
        policy.CanaryAMS__Account__c = groupedPolicy.accountId; // Account
        policy.CanaryAMS__Contact_for_Policy__c = groupedPolicy.contactId; // Primary Contact
        policy.OwnerId = groupedPolicy.ownerId;
        policy.CanaryAMS__Close_Date__c = Date.today();
        policy.CanaryAMS__Effective_Date__c = groupedPolicy.effectiveDate;
        policy.CanaryAMS__Product__c = groupedPolicy.quoteId;
        // NOTE: if `quote.CanaryAMS__Transaction_Type__c` is set to `Cross_Sell` it will 
        // get overwritten to `New Business`
        policy.CanaryAMS__Policy_Type__c = quote.CanaryAMS__Transaction_Type__c;
        policy.RecordTypeId = groupedPolicy.recordType;
        policy.CanaryAMS__Policy_Term__c = groupedPolicy.term;
        policy.CanaryAMS__Policy_Number__c = groupedPolicy.policyNumber;
        policy.CanaryAMS__Net_Premium__c = groupedPolicy.premium;
        policy.CanaryAMS__Total_Agency_Fees__c = groupedPolicy.agencyFee;
        policy.CanaryAMS__Total_Taxes_Fees__c = groupedPolicy.carrierFee;
        policy.Zen_Calculated_12_Month_Premium__c = groupedPolicy.premium;
        policy.Zen_Calculated_12_Month_Agency_Fee__c = groupedPolicy.agencyFee;
        policy.Zen_Calculated_12_Month_Carrier_Fee__c = groupedPolicy.carrierFee;
        policy.CanaryAMS__Producer__c = groupedPolicy.producerId;
        policy.CanaryAMS__Carrier__c = groupedPolicy.carrier.Id;
        policy.CanaryAMS__Carrier_Product__c = groupedPolicy.carrierProduct;
        policy.Biling_Type__c = groupedPolicy.billingType;
        policy.Xero_Invoice_Number__c = groupedPolicy.xeroInvoiceNumber;
        policy.CanaryAMS__Current_Retroactive_Date__c = groupedPolicy.retroactiveDate;
        policy.CanaryAMS__Policy_Source__c = groupedPolicy.quoteSource;
        policy.CanaryAMS__Policy_Sub_Source__c = groupedPolicy.quoteSubSource;
        policy.ZEN_Query_Param_Adgroup__c = groupedPolicy.adgroup;
        policy.ZEN_Query_Param_Keyword__c = groupedPolicy.keyword;
        policy.ZEN_Query_Param_UTM_Campaign__c = groupedPolicy.utmCampaign;
        policy.ZEN_Query_Param_UTM_Content__c = groupedPolicy.utmContent;
        policy.ZEN_Query_Param_UTM_Medium__c = groupedPolicy.utmMedium;
        policy.ZEN_Query_Param_UTM_Source__c = groupedPolicy.utmSource;
        policy.ZEN_Query_Param_UTM_Term__c = groupedPolicy.utmTerm;

        // Carry over expiration date only if the term "Other" is selected.
        // Expiration date is autocalculated on policy for non-other terms.
        if (groupedPolicy.term == Policies.OTHER_TERM) {
            policy.CanaryAMS__Renewal_Date_2__c = groupedPolicy.expirationDate;
        }

        insert policy;

        return policy;
    }

    @AuraEnabled 
    public static CanaryAMS__Policy__c createPolicyWithCoverages(GroupedPolicy groupedPolicy, String quoteId){
        Savepoint sp = Database.setSavepoint();

        List<CanaryAMS__Coverage__c> coveragesToCreate = new List<CanaryAMS__Coverage__c>();
        CanaryAMS__Policy__c policy;

        try {
            policy = insertPolicyWithGroupPolicy(groupedPolicy);
        } catch (Exception e) {
            String quoteIdToLog = !String.isBlank(groupedPolicy.quoteId) ? groupedPolicy.quoteId : 'Unknown Quote Id';

            String producerIdToLog = !String.isBlank(groupedPolicy.producerId) ? groupedPolicy.producerId : 'Unknown Producer Id';

            String errorMessage = e.getMessage() + '\nQuote Id : ' + quoteIdToLog + '\nProducer Id: ' + producerIdToLog;

            Sentry.record(e, errorMessage);
            return null;
        }

        Boolean copyAdditionalInterests = false;


        for (CanaryAMS__Coverage__c originalCoverage: groupedPolicy.coverages) {
            CanaryAMS__Coverage__c coverage = originalCoverage.clone(false, false, false, false);
            coverage.CanaryAMS__Policy__c = policy.Id;
            coverage.Zen_12_Month_Premium__c = coverage.CanaryAMS__Current_Term_Amount__c;
            coverage.Zen_12_Month_Carrier_Fee__c = coverage.Carrier_Fee__c;
            coverage.Zen_12_Month_Agency_Fee__c = coverage.Agency_Fee__c;
            coverage.CanaryAMS__Insurance_Product__c = null;
            coverage.Zen_Source__c = SOURCE_BIND;
            coveragesToCreate.add(coverage);
            if (coverage.API_Policy_Slug__c == 'general_liability' ||
                coverage.API_Policy_Slug__c == 'general_professional_liability') {
                copyAdditionalInterests = true;
            }
        }

        if (copyAdditionalInterests) {
            AdditionalInterests.copyAdditionalInterestsFromQuoteToPolicy(quoteId, policy.Id);
        }
        
        try {
            upsert coveragesToCreate;
            return policy;
        } catch (Exception e) {
            Sentry.record(e);
            Database.rollback(sp);
            return null;
        }
    }

    @AuraEnabled
    public static String upsertPolicies(List<CanaryAMS__Policy__c> policyList) {
        try{
            upsert policyList;
            return STATUS_POLICIES_UPDATED_SUCCESS;
        } catch(Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<CanaryAMS__Policy__c> setRenewingPoliciesStatusByQuoteId(String quoteId) {
        List<CanaryAMS__Policy__c> renewingPolicies = Policies.getPoliciesByRenewalQuoteId(quoteId);

        for (CanaryAMS__Policy__c policy: renewingPolicies) {
            policy.CanaryAMS__Policy_Status__c = 'Renewed';
        }

        update renewingPolicies;

        return renewingPolicies;
    }


    @AuraEnabled(cacheable=false)
    public static List<CanaryAMS__Policy__c> getPoliciesByRenewalQuoteId(String quoteId){
        List<CanaryAMS__Policy__c> policies = [SELECT Id, Name, CanaryAMS__Carrier__r.Id, CanaryAMS__Carrier__r.Name, RecordType.Name, CanaryAMS__Net_Premium__c, CanaryAMS__Total_Agency_Fees__c, CanaryAMS__Total_Taxes_Fees__c, CanaryAMS__Policy_Number__c FROM CanaryAMS__Policy__c WHERE Zen_Renewal_Quote__c = :quoteId];

        return policies;
    }
}
