@istest
public class territory_Account_Check_Test {
    @istest static void validate_User_ShowAccounts(){
        /*
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
            SAP_Sold_To__c = '999999',
            Territory_Key__c = '800123'
        );
        insert a;
        
        Contact c = new contact(
            Lastname = 'Test1',
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
        
        // Rule
        Territory_Alignment__c tarsap = new Territory_Alignment__c(
            Key__c	= '999999-800123',
            SAP_Code__c	= '999999',
            Account_Name__c	= 'Test',
            Territory__c = '800123',
            Territory_Name__c = '800123',
            Territory2__c = '800123',
            Territory_2_Name__c = '800123',
            Territory3__c = '',
            Territory_3_Name__c = '',
            Territory4__c = '',
            Territory_4_Name__c = '',
            ZPSA_Table__c = 'A681'
        );
        insert tarsap;
        
        // Connect
        Territory_Assignment__c terraAssign = new Territory_Assignment__c(
            Account__c = a.Id, 
            Territory_Alignment__c = tarsap.Id,
            Territory__c = tm.id
        );
        insert terraAssign;
        
        PageReference pageRef = new PageReference('/apex/territory_Account_Check?id=' + a.id );
        system.debug('pageRef:' + pageRef); 
        
        ///apex/territory_Account_Check?id=001E000000fvdNN
        Test.setCurrentPage(pageRef);
        
        territory_Account_Check tac = new territory_Account_Check();
        tac.getAccount();
        */
    }
}