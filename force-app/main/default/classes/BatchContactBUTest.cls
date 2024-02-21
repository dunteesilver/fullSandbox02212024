/*********************************************************************
* Description      : Test coverage for BatchContactBU process.
* Coverage         : Classes(BatchContactBU)
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
@isTest
public class BatchContactBUTest {
    static testMethod void testBatchContactBU(){
        
        //Profile p = [SELECT Id FROM Profile WHERE Id='00eE0000000j6PB'];
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(
            Username='trey.flowers@teleflex.com.testing1',
            Email='trflowers@teleflex.com',
            Business_Unit__c = 'Anesthesia',
            Lastname='User',
            Firstname='Test',
            Alias='tuser',
            emailencodingkey='UTF-8',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid=p.Id,
            timezonesidkey='America/New_York'
        );
        insert u;
        
        
        Account a = new Account(Name='Test Account ');
        insert a;
        
        Contact c = new Contact( 
            FirstName ='Test',
            email = 'abc@123.com',
            LastName='testerama',
            AccountId=a.id,
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
            OwnerId=u.id,
            Business_Unit1__c = NULL
        );
        insert c;
        
        //Test to cover Contact w/ same BU
        Contact c1 = new Contact(
            
            FirstName ='Test1',
            email = 'abc@123.com',
            LastName='testerama1',
            AccountId=a.id,
            OwnerId=u.id,
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
            Business_Unit1__c = 'Anesthesia'
        );
        insert c1;
        
        //Test to cover Contact w/ different BU
        Contact c2 = new Contact(
            FirstName ='Test2',
            email = 'abc@123.com',
            LastName='testerama2',
            AccountId=a.id,
            OwnerId=u.id,
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
            Business_Unit1__c = 'Vascular'
        );
        insert c2;
        
        BatchContactBU assign = new BatchContactBU();
        ID batchprocessid12 = Database.executeBatch(assign);
        
    }
}