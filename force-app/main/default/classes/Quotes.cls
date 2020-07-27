public with sharing class Quotes {
    public static String INSURANCE_ZENSURANCE_USER_ID = '0054o000002c50mAAA';
    public static String ASSIGNMENT_FALLBACK_USER_ID = '005460000014mJbAAI';
    public static String CLOSED_WON_STATUS = 'Closed Won';
    public static String CLOSED_LOST_STATUS = 'Closed Lost';
    public static String NONE_PAYMENT_STATUS = 'None';
    
    public static final Map<String, Integer> TERMS = new Map<String, Integer> {
        '1 Month' => 1,
        '2 Month' => 2,
        '3 Month' => 3,
        '4 Month' => 4,
        '6 Month' => 6,
        '12 Month' => 12        
    };

    public static AggregateResult getQuotePremiumAndFees(String quoteId) {
        return [
            SELECT
                SUM(CanaryAMS__Current_Term_Amount__c)premium,
                SUM(Agency_Fee__c)agencyfee,
                SUM(Carrier_Fee__c)carrierfee
            FROM
                CanaryAMS__Coverage__c
            where
                CanaryAMS__Insurance_Product__c = :quoteId
                AND Zen_Limit__c != 'Excluded'
        ][0];
    }

    public static CanaryAMS__Insurance_Product__c getQuoteForUpdate(String quoteId) {
        return [
            SELECT
                Id,
                Name,
                Zen_Calculated_Premium__c,
                Zen_Calculated_Agency_Fee__c,
                Zen_Calculated_Carrier_Fee__c,
                Override_Calculated_Premium_Fees__c,
                CanaryAMS__Total_Agency_Fees__c,
                CanaryAMS__Total_Taxes_Fees__c,
                CanaryAMS__Quoted_Policy_Premium__c,
                CanaryAMS__Transaction_Type__c
            FROM
                CanaryAMS__Insurance_Product__c
            WHERE
                Id = :quoteId
            FOR UPDATE
        ];
    }

    @AuraEnabled
    public static CanaryAMS__Insurance_Product__c calculateQuotePremiumAndFees(String quoteId) {
        AggregateResult calculatedResult = Quotes.getQuotePremiumAndFees(quoteId);

        try {
            CanaryAMS__Insurance_Product__c quote = Quotes.getQuoteForUpdate(quoteId);

            Double calculatedPremium = calculatedResult.get('premium') != NULL ? double.valueOf(calculatedResult.get('premium')) : 0;
            Double calculatedAgencyFee = calculatedResult.get('agencyfee') != NULL ? double.valueOf(calculatedResult.get('agencyfee')) : 0;
            Double calculatedCarrierFee = calculatedResult.get('carrierfee') != NULL ? double.valueOf(calculatedResult.get('carrierfee')) : 0;

            quote.Zen_Calculated_Premium__c = calculatedPremium;
            quote.Zen_Calculated_Agency_Fee__c = calculatedAgencyFee;
            quote.Zen_Calculated_Carrier_Fee__c = calculatedCarrierFee;

            quote.CanaryAMS__Quoted_Policy_Premium__c = calculatedPremium;
            quote.CanaryAMS__Total_Agency_Fees__c = calculatedAgencyFee;
            quote.CanaryAMS__Total_Taxes_Fees__c = calculatedCarrierFee;

            update quote; 

            return quote;
        } catch(QueryException e) {
            // throw new zenQueryException('There was an error calculating quote premium and fees: ' + e.getMessage() + ': ' + quoteId);
            System.debug('There was an error calculating quote premium and fees: ' + e.getMessage() + ': ' + quoteId);
            return null;
        }
    }


    @AuraEnabled(cacheable=false)
    public static List<Policies.ExtendedPolicy> getRenewalPolicies(String quoteId) {
        List<Policies.ExtendedPolicy> extendedPolicies = new List<Policies.ExtendedPolicy>();       
        List<CanaryAMS__Policy__c> policies = Policies.getPoliciesByRenewalQuoteId(quoteId);

        Set<Id> policyIds = new Map<Id, CanaryAMS__Policy__c>(policies).keySet();

        List<CanaryAMS__Claim__c> claims = Claims.getClaimsByPolicyIds(policyIds);
        List<CanaryAMS__Coverage__c> coverages = Coverages.getCoveragesByPolicyIds(policyIds);
        List<Endorsements.PolicyEndorsements> endorsements = Endorsements.getEndorsementsByPolicyIds(policyIds);

        for (CanaryAMS__Policy__c policy: policies) {
            Policies.ExtendedPolicy extendedPolicy = new Policies.ExtendedPolicy();
            extendedPolicy.policy = policy;
            extendedPolicy.claims = new List<CanaryAMS__Claim__c>();
            extendedPolicy.coverages = new List<CanaryAMS__Coverage__c>();
            extendedPolicy.endorsements = new List<Endorsements.Endorsement>();
            
            // Get all endorsements/claims/coverages in single calls and then assign them to the correct policy.
            // This reduces the number of HTTP requests and SOQL queries needed to get all of the required information.
            for (Endorsements.PolicyEndorsements policyEndorsements: endorsements) {
                if (policyEndorsements.policyId == policy.Id) {
                    extendedPolicy.endorsements.addAll(policyEndorsements.endorsements);
                }
            }

            for (CanaryAMS__Claim__c claim: claims) {
                if (claim.CanaryAMS__Policy__c == policy.Id) {
                    extendedPolicy.claims.add(claim);
                }
            }

            for (CanaryAMS__Coverage__c coverage: coverages) {
                if (coverage.CanaryAMS__Policy__c == policy.Id) {
                    extendedPolicy.coverages.add(coverage);
                }
            }

            extendedPolicies.add(extendedPolicy);
        }

        return extendedPolicies;
    }

    // Given owner ids, create a owners map with "User.Id" as a key
    // and "User.Name" as a value
    private static Map<Id, String> createOwnersMapFromIds(List<Id> ids) {
        List<User> owners = [
            SELECT Id, Name
            FROM User
            WHERE Id IN :ids
        ];

        Map<Id, String> ownersMap = new Map<Id, String>();

        for (User owner: owners) {
            ownersMap.put(owner.Id, owner.Name);
        }

        return ownersMap;
    }

    // Given producer names, create a producers map with "CanaryAMS__Producers__c.Name"
    // as a key and a list of "CanaryAMS__Producers__c" as a value
    private static Map<String, List<CanaryAMS__Producers__c>> createProducersMapFromNames(List<String> names) {
        List<CanaryAMS__Producers__c> foundProducers = [
            SELECT Id, Name, CanaryAMS__Type__c
            FROM CanaryAMS__Producers__c
            WHERE Name IN :names
        ];

        Map<String, List<CanaryAMS__Producers__c>> producersMap = new Map<String, List<CanaryAMS__Producers__c>>();
        
        for (CanaryAMS__Producers__c producer: foundProducers) {
            List<CanaryAMS__Producers__c> extantProducer = producersMap.get(producer.Name);
            if (extantProducer != NULL) {
                extantProducer.add(producer);
            } else {
                producersMap.put(producer.Name, new List<CanaryAMS__Producers__c>{producer});
            }
        }
        
        return producersMap;
    }

    public class CannotCopyOwnerToProducerException extends Exception {}
    public class CheckoutExpirationException extends Exception {}

    public static void copyOwnerToProducer(List<CanaryAMS__Insurance_Product__c> quotesToCopyField) {
        List<String> ownerIds = new List<String>();

        for(CanaryAMS__Insurance_Product__c quote : quotesToCopyField) {
            if (quote.OwnerId != NULL) {
                ownerIds.add(quote.OwnerId);
            }
        }

        Map<Id, String> ownersMap = Quotes.createOwnersMapFromIds(ownerIds);

        List<String> ownerNames = ownersMap.values();
        Map<String, List<CanaryAMS__Producers__c>> producersMap = Quotes.createProducersMapFromNames(ownerNames);

        for(CanaryAMS__Insurance_Product__c quote : quotesToCopyField) {
            // Ignore when owner is empty or "Insurance Zensurance" or "Cheryl Fearon"
            if (quote.OwnerId == NULL || quote.OwnerId == Quotes.INSURANCE_ZENSURANCE_USER_ID || quote.OwnerId == Quotes.ASSIGNMENT_FALLBACK_USER_ID) {
                quote.CanaryAMS__Producer__c = NULL;
                continue;
            }

            String ownerName = ownersMap.get(quote.OwnerId);
            List<CanaryAMS__Producers__c> producers = producersMap.get(ownerName);

            if (producers == NULL) {
                quote.CanaryAMS__Producer__c = NULL;

                Sentry.record(
                    new CannotCopyOwnerToProducerException(
                        'Failed to copy over owner to producer for a quote: ' + quote.Name + '.\n' +
                        'There is no producer with the name: ' + ownerName
                    )
                );

                continue;
            }
            
            // choose "Producer" when multiple Producer/CSRs are found
            if (producers.size() > 1) {
                for (CanaryAMS__Producers__c producer : producers) {
                    if (producer.CanaryAMS__Type__c == 'Producer') {
                        producers[0] = producer;
                        break;
                    }
                }
            } 

            quote.CanaryAMS__Producer__c = producers[0].Id;
        }
    }

    public static Date getClosedDate(CanaryAMS__Insurance_Product__c newQuote) {
        return newQuote.CanaryAMS__Stage__c.equals(CLOSED_WON_STATUS) ? newQuote.CanaryAMS__Closed_Won_Date__c : newQuote.CanaryAMS__Closed_Lost_Date__c;
    }

    public static void updateCheckoutExpirationDate(String quoteId) {
        try {
            CanaryAMS__Insurance_Product__c quote = [SELECT Id, Name, Zen_Checkout_Link_Expiration_Date__c, CanaryAMS__Transaction_Type__c FROM CanaryAMS__Insurance_Product__c WHERE Id = :quoteId];
            Integer daysToExpiration = quote.CanaryAMS__Transaction_Type__c == 'Renewal' ? 60 : 30;

            quote.Zen_Checkout_Link_Expiration_Date__c = Date.today().addDays(daysToExpiration);
            update quote;
        } catch(QueryException e) {
            Sentry.record(
                new CheckoutExpirationException(
                    'There was an error updating the Checkout Link Expiration Date for quote: ' + quoteId + ' >> ' + e.getMessage()
                )
            );
        }
    }

    public static void updateExpirationDate(CanaryAMS__Insurance_Product__c quote) {
        try {
            if (quote.CanaryAMS__Quoted_Term__c != 'Other' && Quotes.TERMS.containsKey(quote.CanaryAMS__Quoted_Term__c)) {
                Integer monthsToExpiration = Quotes.TERMS.get(quote.CanaryAMS__Quoted_Term__c);
                quote.CanaryAMS__Policy_Expiration_Date__c = quote.CanaryAMS__Policy_Effective_Date__c.addMonths(monthsToExpiration);

                update quote;
            }
        } catch (Exception e) {
            Sentry.record(e);
        }
    }
}

