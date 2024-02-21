/*
* Test class for accountGraph class
*/

@isTest
private class accountGraphTest{
/*
    static testMethod void accountGraphTest() {
        list<User> users = new list<User>();
        list<string> business_Units = new list<string>{'Surgical','Vascular','Latin America','Interventional','Specialty','Anesthesia/Respiratory'};
     // Create some test items to be used by the test class.
        //User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

       // System.runAs (thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name='system administrator'];
            for (Integer i=0;i<6;i++) {
                User u = new User(alias = 'tUsr'+i, email='testUser'+i+'@acme.com',
                emailencodingkey='UTF-8', lastname='TestUser',Business_Unit__c =business_Units[i] ,
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles',
                username='myTestUser001'+i+'@acme.com');

                users.add(u);
            }
            User u1 = new User(alias = 'tUsr', email='testUser321@acme.com',
                emailencodingkey='UTF-8', lastname='TestUser',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles',
                username='myTestUser321@acme.com');

                users.add(u1);

            insert users;
            system.assertEquals(7,users.size());
      // }

    account[] accList = new list<account>();
        Account acct = new Account(
            Name='Test Account ',
            AR_PFY_2011__c = 2400.00, AR_PFY_2012__c = 2500.00,
            Vascular_PFY_2011__c = 2700.00, Vascular_PFY_2012__c = 2800.00, Vascular_PFY__c = 2900.00,Vascular_CFYTD__c = 3000.00,
            Surgical_PFY_2011__c = 3100.00, Surgical_PFY_2012__c = 3200.00, Surgical_PFY__c = 3300.00,Surgical_CFYTD__c  = 3400.00,
            IA_PFY_2011__c = 3100.00, IA_PFY_2012__c = 3200.00, IA_PFY__c  = 3300.00, IA_CFYTD__c = 3400.00,
            Specialty_PFY_2011__c = 3100.00, Specialty_PFY_2012__c = 3200.00, Specialty_PFY__c  = 3300.00, Specialty_CFYTD__c = 3400.00,
            Latam_PFY_2011__c = 3100.00, Latam_PFY_2012__c = 3200.00, Latam_PFY__c  = 3300.00, Latam_CFYTD__c = 3400.00
        );
   accList.add(acct);
   Account acct1 = new Account(Name = 'Test Account');
   accList.add(acct1);

    insert accList;
    system.assertEquals(2,accList.size());
    //Create a reference to the VF page
    PageReference pageRef = Page.accountsAR;
    Test.setCurrentPageReference(pageRef);
    // if you wanted to test an existing lead, use the line below (assuming your extension expects the ID param to be set)
   // ApexPages.currentPage().getParameters().put('id', ld.Id);

    system.runAs(users[0]){
     // create an instance of your extension
        accountGraph extension = new accountGraph(new ApexPages.StandardController(accList[0]));
        extension.getPieData();
        accountGraph extension1 = new accountGraph(new ApexPages.StandardController(accList[1]));
    }

    system.runAs(users[1]){
     // create an instance of your extension
        accountGraph extension = new accountGraph(new ApexPages.StandardController(accList[0]));
        extension.getPieData();
        accountGraph extension1 = new accountGraph(new ApexPages.StandardController(accList[1]));
    }

    system.runAs(users[2]){
     // create an instance of your extension
        accountGraph extension = new accountGraph(new ApexPages.StandardController(accList[0]));
        extension.getPieData();
        accountGraph extension1 = new accountGraph(new ApexPages.StandardController(accList[1]));
    }

    system.runAs(users[3]){
     // create an instance of your extension
        accountGraph extension = new accountGraph(new ApexPages.StandardController(accList[0]));
        extension.getPieData();
        accountGraph extension1 = new accountGraph(new ApexPages.StandardController(accList[1]));
    }

    system.runAs(users[4]){
     // create an instance of your extension
        accountGraph extension = new accountGraph(new ApexPages.StandardController(accList[0]));
        extension.getPieData();
        accountGraph extension1 = new accountGraph(new ApexPages.StandardController(accList[1]));
    }

    system.runAs(users[5]){
     // create an instance of your extension
        accountGraph extension = new accountGraph(new ApexPages.StandardController(accList[0]));
        extension.getPieData();
        accountGraph extension1 = new accountGraph(new ApexPages.StandardController(accList[1]));
    }
    system.runAs(users[6]){
     // create an instance of your extension
        accountGraph extension = new accountGraph(new ApexPages.StandardController(accList[0]));
        extension.getPieData();
        accountGraph extension1 = new accountGraph(new ApexPages.StandardController(accList[1]));
    }
  }*/
}