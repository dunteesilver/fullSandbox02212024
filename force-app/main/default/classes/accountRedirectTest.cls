/*
* Test class for accountRedirect class
*/

@isTest
private class accountRedirectTest{
    static testMethod void accountRedirectTest() {
        list<User> users = new list<User>();
        list<string> business_Units = new list<string>{'Surgical','Anesthesia/Respiratory','Vascular','Canada','OEM', 'Interventional','Specialty','National Accounts', 'Latin America', 'Latin America Distributor', 'Vascular Vendor'};
     // Create some test items to be processed by the batch job.
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs (thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name='system administrator'];
            for (Integer i=0;i<11;i++) {
                User u1 = new User(alias = 'tUsr'+i, email='testUser'+i+'@acme.com',
                emailencodingkey='UTF-8', lastname='TestUser',Business_Unit__c =business_Units[i] ,
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles',
                username='myTestUser001'+i+'@acme.com');

                users.add(u1);
            }

            insert users;
            system.assertEquals(11,users.size());
       }

    // create a new lead...
    Account acct = new Account(Name='Test Account ');
    // ...set additional fields...
    insert acct;

    //Create a reference to the VF page
    PageReference pageRef = Page.accountsRedirect;
    Test.setCurrentPageReference(pageRef);
    // if you wanted to test an existing lead, use the line below (assuming your extension expects the ID param to be set)
    ApexPages.currentPage().getParameters().put('id', acct.Id);

    system.runAs(users[0]){
     // create an instance of your extension
        accountRedirect extension = new accountRedirect(new ApexPages.StandardController(acct));
        extension.redirect();
    }

    system.runAs(users[1]){
     // create an instance of your extension
        accountRedirect extension = new accountRedirect(new ApexPages.StandardController(acct));
        extension.redirect();
    }
    system.runAs(users[2]){
     // create an instance of your extension
        accountRedirect extension = new accountRedirect(new ApexPages.StandardController(acct));
        extension.redirect();
    }
    system.runAs(users[3]){
     // create an instance of your extension
        accountRedirect extension = new accountRedirect(new ApexPages.StandardController(acct));
        extension.redirect();
    }
    system.runAs(users[4]){
     // create an instance of your extension
        accountRedirect extension = new accountRedirect(new ApexPages.StandardController(acct));
        extension.redirect();
    }
    system.runAs(users[5]){
     // create an instance of your extension
        accountRedirect extension = new accountRedirect(new ApexPages.StandardController(acct));
        extension.redirect();
    }
    system.runAs(users[6]){
     // create an instance of your extension
        accountRedirect extension = new accountRedirect(new ApexPages.StandardController(acct));
        extension.redirect();
    }
    system.runAs(users[7]){
     // create an instance of your extension
        accountRedirect extension = new accountRedirect(new ApexPages.StandardController(acct));
        extension.redirect();
    }
    system.runAs(users[8]){
     // create an instance of your extension
        accountRedirect extension = new accountRedirect(new ApexPages.StandardController(acct));
        extension.redirect();
    }
    system.runAs(users[9]){
     // create an instance of your extension
        accountRedirect extension = new accountRedirect(new ApexPages.StandardController(acct));
        extension.redirect();
    }
    system.runAs(users[10]){
     // create an instance of your extension
        accountRedirect extension = new accountRedirect(new ApexPages.StandardController(acct));
        extension.redirect();
    }



}

}