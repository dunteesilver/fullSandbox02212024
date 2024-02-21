@istest
public class territory_User_ShowAccounts_Test {
    @istest static void validate_User_ShowAccounts(){
        Quick_Disable__c cs = new Quick_Disable__c(
            Name = 'addAccountShares',
            Enable__c = TRUE
        );
        System.debug('insert cs-->' + cs);
        insert cs;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='TeleflexTESTER@teleflex.test.com'
        );
        insert u;
        System.debug('Insert User-->' + u);
        
        Account a = new account(
            Name = 'Test',
            SAP_Sold_To__c = '999999'
        );
        insert a;
        
        Contact c = new contact(
            FirstName ='Test',
            email = 'abc@123.com',  
            Lastname = 'Test1',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
            AccountID = a.Id
        );
        insert c;
        
        Territory_Master__c tm = new Territory_Master__c(
            Name = '800123',
            Territory_Number__c = '800123',
            Business_Unit__c = 'EMS'
        );
        insert tm;
        System.debug('Insert Territory Master-->' + tm);
        
        Territory_Account__c ta = new Territory_Account__c(
            //name = 'TERR-12312300',
            Account__c = a.Id,
            Territory_Master__c = tm.Id
        );
        insert ta;
        System.debug('Insert Territory Account-->' + ta);
        
        Territory_User__c tu = new Territory_User__c(
            Territory_Master__c = tm.Id,
            User__c = u.id
        );
        insert tu;
        System.debug('Insert Territory User-->' + tu);
        
        System.debug('Update a.Name-->' + a.Name);
        a.Name = 'Test 2';
        update a;        
        System.debug('After Update a.Name2-->' + a.Name);
        
        PageReference pageRef2 = new PageReference('/apex/territory_User_ShowAccounts?id=' + u.id );
        system.debug('PageRef2:' + pageRef2); 
        
        Test.setCurrentPage(pageRef2);
        
        territory_User_ShowAccounts tus = new territory_User_ShowAccounts();
        tus.getAccounts();
        tus.getuserName2();
        string uname = tus.userName;
        
        PageReference pageRef3 = new PageReference('/apex/territory_User_ShowAccounts?id=' + a.id );
        system.debug('pageRef3:' + pageRef3); 
        
        Test.setCurrentPage(pageRef3);
        
        territory_Account_ShowUsers tas = new territory_Account_ShowUsers();
        tas.getAccountShares();
        tas.getAccountTeamMembers();
        tas.getTerritories();
        tas.getUsers();
        string aid = tas.accid;
        string accid = tas.accountId;
        string accname = tas.accountName;
    }

}