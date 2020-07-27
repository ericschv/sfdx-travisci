public with sharing class Accounts {
    @AuraEnabled
    public static Account updateFlowIndustryFromResumeLink(String quoteId, String qid, String token) {
        
        // determine whether we're in sandbox or prod.
        String apiUrl = SharedUtils.getApiHost();

        // send a GET request to the questionnaire endpoint to get the answerStore
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl + '/questionnaires/' + qid + '?token=' + token);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // Cast the values in the 'answerStore' key as a list
            
            Map<String, Object> questionnaire =
                (Map<String, Object>)results.get('questionnaire');
            
            Map<String, Object> answerStore =
                (Map<String, Object>)questionnaire.get('answerStore');

            String flowName = (String) answerStore.get('flowName');
            String industryName = (String) answerStore.get('industry');

            
            DAO dao = new DAO();
                      
            
            Flow__c flow = dao.getFlowBySlug(flowName);  
            Industry__c industry = dao.getIndustryBySlug(industryName);
            CanaryAMS__Insurance_Product__c quote = dao.getQuoteById(quoteId);
            
            Account account = dao.getAccountById(quote.CanaryAMS__Account__c);
            account.Industry_Rel__c = industry.Id;
            account.Flow__c = flow.Id;

            dao.upsertAccount(account);
            
            account = dao.getAccountById(quote.CanaryAMS__Account__c);

            return account;
        }        

        return null;        
    }


    public static String getFormattedBillingAddress(Account acct) {
        String formattedAddress = '';
        
        formattedAddress += !String.isBlank(acct.BillingStreet) ? acct.BillingStreet + ', ' : '';
        formattedAddress += !String.isBlank(acct.BillingCity) ? acct.BillingCity + ', ' : '';
        formattedAddress += !String.isBlank(acct.BillingState) ? acct.BillingState + ', ' : '';
        formattedAddress += !String.isBlank(acct.BillingCountry) ? acct.BillingCountry + ', ' : '';
        formattedAddress += !String.isBlank(acct.BillingPostalCode) ? acct.BillingPostalCode : '';
        formattedAddress = formattedAddress.removeEnd(', ');
        formattedAddress = formattedAddress.removeEnd(',');

        return formattedAddress;
    }

    public static String getFormattedShippingAddress(Account acct) {
        String formattedAddress = '';
        
        formattedAddress += !String.isBlank(acct.ShippingStreet) ? acct.ShippingStreet + ', ' : '';
        formattedAddress += !String.isBlank(acct.ShippingCity) ? acct.ShippingCity + ', ' : '';
        formattedAddress += !String.isBlank(acct.ShippingState) ? acct.ShippingState + ', ' : '';
        formattedAddress += !String.isBlank(acct.ShippingCountry) ? acct.ShippingCountry + ', ' : '';
        formattedAddress += !String.isBlank(acct.ShippingPostalCode) ? acct.ShippingPostalCode : '';
        formattedAddress = formattedAddress.removeEnd(', ');
        formattedAddress = formattedAddress.removeEnd(',');

        return formattedAddress;
    }


    public static Boolean haveAddressFieldsChanged(Account oldAccount, Account newAccount, List<String> addressFields) {
        Boolean addressFieldsChanged = false;

        for (String addressField : addressFields) {
            if (oldAccount.get(addressField) != newAccount.get(addressField)) {
                addressFieldsChanged = true;
                break;
            }
        }

        return addressFieldsChanged;
    }

}
