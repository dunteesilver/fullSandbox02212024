@isTest
public class BatchDeleteTest {
    static testMethod void testBatchDelete(){
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'uflex76', 
            email='unit.test@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Adam',
            lastname='Franks', 
            languagelocalekey='en_US',
            localesidkey='en_GB', 
            profileid = p.Id,
            timezonesidkey='Europe/London', 
            username='unit.test@unit.teleflex.com',
            Business_Unit__c = 'Surgical Disposables',
            Sharing_Key__c = 'Adam Franks',
            Admin_SMS_Notification__c='unit.test@unit.teleflex.com'
        );
        insert u;
        
        System.runAs(u){
            /*
            Id RecId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='Vascular_Customer_NA'].Id;
            Account a = new Account(
                Name = 'Test PP Account', 
                SAP_Sold_To__c ='100123', 
                ShippingStreet='123 Main Street ', 
                ShippingCity='Raleigh',
                ShippingState='NC', 
                ShippingPostalCode='27614',
                Customer_Group__c = '19',
                zBlock__c = '00',
                Account_Group__c = 'Z001',
                ERP_Active__c = FALSE,
                RecordTypeId = RecId
            );*/
            Account a = new Account(Name='Test Account asdf');
            insert a;
            
            
            BatchDelete BDel = new BatchDelete();
            BDel.query = 'SELECT Id FROM Account';
            ID batchprocessid = Database.executeBatch(BDel);
            System.debug('Returned batch process ID: ' + batchProcessId);
        }
    }
}