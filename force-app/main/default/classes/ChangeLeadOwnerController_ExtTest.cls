/**
 * An apex test class to verify functionality of ChangeLeadOwnerController_Ext
 */
@IsTest global with sharing class ChangeLeadOwnerController_ExtTest {
  /*
    @IsTest(SeeAllData=true)
    global static void testChangeOwner () {
        // Create lead
        Lead lead = new Lead(lastname='leadLastName', company='leadCompany');
        insert lead;

        // Create user
        String userId = insertUser('test1', 'user1');

        // Test the changeOwner method
        boolean result = ChangeLeadOwnerController_Ext.changeOwner(lead.Id, userId);
        System.assertEquals(true,result);
        // Query the lead ownerId from db, should be change to the owner id passed
        String queryString = 'SELECT OwnerId FROM Lead WHERE id=\'' + lead.Id + '\'';
        Lead updatedLead = (Lead) Database.query(queryString);
        System.assertEquals(userId, updatedLead.ownerId);
    }

    @IsTest(SeeAllData=true)
    global static void testGetUserRecs () {
        String queryString = 'SELECT Id FROM User WHERE (UserType LIKE \'Standard%\' OR UserType LIKE \'%Partner%\') ORDER BY name ASC';
        List<SObject> existingUsers = Database.query(queryString);

        // Create 2 users
        String user1Id = insertUser('test2', 'user2');
        String user2Id = insertUser('test3', 'user3');

        Integer expectedUserCount = existingUsers.size() + 2;
        // Test the getUserRecs method
        List<User> users = ChangeLeadOwnerController_Ext.getUserRecs();
        System.assertEquals(expectedUserCount, users.size());
    }

        @IsTest(SeeAllData=true)
    global static void testLeadIdGetterSetter () {
        // Create lead
        Lead lead = new Lead(lastname='leadLastName', company='leadCompany');
        insert lead;


        ApexPages.StandardController sc = new ApexPages.StandardController(Lead);
        ChangeLeadOwnerController_Ext controller = new ChangeLeadOwnerController_Ext(sc);
        controller.setLeadRec(lead.Id);
        String leadIdFromGetter = controller.getLeadRec();

        String expectedLeadId = lead.Id;
        System.assertEquals(true, expectedLeadId.equals(leadIdFromGetter));
    }

    // Helper to create a new user with Standard User profile
    private static String insertUser(String firstName, String lastName) {
        List<Profile> profileIds = [select id from profile where name = 'Standard User' LIMIT 1];
        String profileId = profileIds.get(0).Id;

        User user = new User();
        user.Username = firstName + lastName + '@company.com';
        user.Email =  firstName + lastName + '@company.com';
        user.Lastname = lastName;
        user.Firstname = firstName;
        user.Alias =  lastName;
        user.CommunityNickname =  firstName + lastName;
        user.ProfileId = profileId;
        user.TimeZoneSidKey = 'GMT';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.UserPermissionsMobileUser = false;
        insert(user);
        return user.Id;
    }
  */ 
}