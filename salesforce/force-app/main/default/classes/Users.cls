public with sharing class Users {

    @AuraEnabled(cacheable=true)
    public static User getUserById(String userId) {
        return [SELECT Id, Name FROM User WHERE Id=:userId];
    }

}
