@isTest
//created by Dunte'e Silver
public class batchUpdateContactBUTest {
    static testMethod void testBatchUpdateContactBU(){
        
        //create test users
       	list<User> users = new list<User>();
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            Profile p = [SELECT Id FROM Profile WHERE Name='system administrator'];
            for (Integer i=0;i<10;i++) {
                User u = new User(alias = 'tUsr'+i, email='testUser'+i+'@teleflex.com', 
                                   emailencodingkey='UTF-8', lastname='TestUser',
                                   languagelocalekey='en_US', 
                                   localesidkey='en_US', profileid = p.Id,
                                   UserRoleId='00EE0000000cNk8',
                                   timezonesidkey='America/New_York', 
                                   username='myTestUser'+i+'@teleflex.com');
                
                users.add(u);  
            }
            
            insert users;
            system.assertEquals(10,users.size());            
        }

        //code for test Accounts
        list<Account> acc = new list<Account>();
        for(integer n=0;n<10;n++){
        	Account a = new Account(Name='Test '+n);
        	acc.add(a);
        }
        insert acc;
        System.assertEquals(10,acc.size());

		//code for test Contacts
        list<Contact> con = new list<Contact>();
        for(integer n=0;n<10;n++){
        	Contact c = new Contact(FirstName ='Test',
            email = 'abc@123.com', LastName='testerama',Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)',AccountId=acc[n].id,OwnerId=users[n].id,Business_Unit1__c='Anesthesia');
        	con.add(c);
        }
        insert con;
        System.assertEquals(10,con.size());
        
        //loop thru to update Contact Business Unit field
        for(Contact curr : con){
            curr.Business_Unit1__c +=  ';' + 'Respiratory';
        }
        update con;
        
        batchUpdateContactBU b = new batchUpdateContactBU();
        ID batchprocessid = Database.executeBatch(b);

    }
}