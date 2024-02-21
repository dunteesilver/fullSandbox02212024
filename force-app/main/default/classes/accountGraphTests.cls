@isTest
public class accountGraphTests {
    static testMethod void accountGraphTests() {
    
        //Account a= new Account(;
        //a.Name= 
        Account ta1 = new Account(
            Name = 'testAccount1',
            SAP_Sold_To__c = '102059',
            Account_Group__c = 'Z002',
            Customer_Group__c = '16'/*,
            zBlock__c = '00',
            ERP_Active__c = TRUE,
            BillingState= 'Test',
            ShippingState='ShippingTest',
            Type='Bill To',
            Main_GPO__c ='ROI',
            Secondary_GPO__c ='Amerinet',
            Radiology__c = true,
            Emergency__c =true,
            Cath_Lab__c =true*/
        );
        insert ta1;

        //Profile p = [SELECT Id FROM Profile WHERE Name='Anesthesia Medical Sales Rep'];
        Profile p = [select id from profile where name='System Administrator'];
        User tu1 = new User(Username='testing1@teleflex.com.testuser',Email='testuser@teleflex.com',Business_Unit__c = 'Latin America', Lastname='User', Firstname='Test', Alias='tuser1',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', profileid=p.Id,timezonesidkey='America/New_York');
        User tu2 = new User(Username='testing2@teleflex.com.testuser',Email='testuser@teleflex.com',Business_Unit__c = 'Surgical', Lastname='User', Firstname='Test', Alias='tuser2',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', profileid=p.Id,timezonesidkey='America/New_York');
        User tu3 = new User(Username='testing3@teleflex.com.testuser',Email='testuser@teleflex.com',Business_Unit__c = 'Vascular', Lastname='User', Firstname='Test', Alias='tuser3',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', profileid=p.Id,timezonesidkey='America/New_York');
        User tu4 = new User(Username='testing4@teleflex.com.testuser',Email='testuser@teleflex.com',Business_Unit__c = 'Interventional', Lastname='User', Firstname='Test', Alias='tuser4',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', profileid=p.Id,timezonesidkey='America/New_York');
        User tu5 = new User(Username='testing5@teleflex.com.testuser',Email='testuser@teleflex.com',Business_Unit__c = 'Specialty', Lastname='User', Firstname='Test', Alias='tuser5',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', profileid=p.Id,timezonesidkey='America/New_York');
        User tu6 = new User(Username='testing6@teleflex.com.testuser',Email='testuser@teleflex.com',Business_Unit__c = 'Anesthesia/Respiratory', Lastname='User', Firstname='Test', Alias='tuser6',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', profileid=p.Id,timezonesidkey='America/New_York');

        insert tu1;
        insert tu2;
        insert tu3;
        insert tu4;
        insert tu5;
        insert tu6;

        system.runAs(tu1){
            accountGraph testing = new accountGraph(new ApexPages.StandardController(ta1));
            testing.getPieData();
        }
        system.runAs(tu2){
            accountGraph testing = new accountGraph(new ApexPages.StandardController(ta1));
            testing.getPieData();
        }
        system.runAs(tu3){
            accountGraph testing = new accountGraph(new ApexPages.StandardController(ta1));
            testing.getPieData();
        }
        system.runAs(tu4){
            accountGraph testing = new accountGraph(new ApexPages.StandardController(ta1));
            testing.getPieData();
        }
        system.runAs(tu5){
            accountGraph testing = new accountGraph(new ApexPages.StandardController(ta1));
            testing.getPieData();
        }
        system.runAs(tu6){
            accountGraph testing = new accountGraph(new ApexPages.StandardController(ta1));
            testing.getPieData();
        }

    }
}