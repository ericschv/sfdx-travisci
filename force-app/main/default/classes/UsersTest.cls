@isTest
private class UsersTest {
    private static String TEST_USER_EMAIL = 'apextest@zensurance.com';
    private static String TEST_USER_ALIAS = 'apextest';
    private static String TEST_USER_FIRST_NAME = 'Apex';
    private static String TEST_USER_LAST_NAME = 'Test';
    private static String TEST_USER_NAME = TEST_USER_FIRST_NAME + ' ' + TEST_USER_LAST_NAME;

    @testSetup
    static void setup(){
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User user = new User(
            UserName=TEST_USER_EMAIL,
            Email=TEST_USER_EMAIL,
            Alias=TEST_USER_ALIAS,
            FirstName=TEST_USER_FIRST_NAME,
            LastName=TEST_USER_LAST_NAME,
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_CA',
            LanguageLocaleKey='en_US',
            EmailEncodingKey='UTF-8',
            ProfileId=profile.Id
        );

        insert user;
    }

    @isTest
    static void testGetUserById() {
        User user = [SELECT Id, Name FROM User WHERE UserName=:TEST_USER_EMAIL];

        User foundUser = Users.getUserById(user.Id);

        System.assertEquals(TEST_USER_NAME, foundUser.Name);
    }
}
