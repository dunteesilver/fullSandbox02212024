@isTest
public class account_Helper_Class_Test {
   

    @testSetup static void dataSetup(){
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
            Business_Unit__c = 'Anesthesia'
        );
        insert u;
        
        User u2 = new User(
            alias = 'uflex76',
            email='unit2.test@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Dun',
            lastname='Silver',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p.Id,
            timezonesidkey='Europe/London',
            username='unit2.test@unit.teleflex.com',
            Business_Unit__c = 'Anesthesia'
        );
        insert u2;

        User updateUser = new User(Id=u.Id, ManagerId=u2.Id);
        update updateUser;
       
        IDN_Picklist__c idnTest = new IDN_Picklist__c(
            Key__c = 'IDN-001',
            Name = 'TestAccount7',
            Sales_Org_Key__c = 'US',
            Active__c = true
        );
        insert idnTest;
        
        System.runAs(u){
            Account accTest = new Account(
                Name = 'TestAccount',
                SAP_Sold_To__c = '102059',
                Account_Group__c = 'Z002',
                Customer_Group__c = '16',
                zBlock__c = '00',
                ERP_Active__c = TRUE,
                Sales_Org__c = 'US60',
                Distribution_Channel__c='20'
            );
            insert accTest;

            Account accTest2 = new Account(
                Name = 'TestAccount2',
                SAP_Sold_To__c = '110069',
                Account_Group__c = 'Z002',
                Customer_Group__c = '01',
                zBlock__c = '00',
                ERP_Active__c = FALSE,
                Sales_Org__c = 'AU10'
            );
            insert accTest2;

            Account accTest5 = new Account(
                Name = 'TestAccount5',
                zBlock__c = '00',
                ERP_Active__c = FALSE,
                Sales_Org__c = 'CO10',
                Account_Group__c = 'Z001'
            );
            insert accTest5;

            Account accTest6 = new Account(
                Name = 'TestAccount6',
                SAP_Sold_To__c = '150322',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '01',
                ERP_Active__c = TRUE
            );
            insert accTest6;
            
            Account accTest7 = new Account(
                Name = 'TestAccount7',
                SAP_Sold_To__c = 'IDN-001',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '00',
                BillingCountry = 'US',
                ERP_Active__c = TRUE,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IDN Account').getRecordTypeId()
            );
            insert accTest7;
            
            Account accTest8 = new Account(
                Name = 'TestAccount8',
                SAP_Sold_To__c = 'GPO-001',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '00',
                Sales_Org__c = 'US60',
                Type = 'Sold-To (Z001)',
                ERP_Active__c = FALSE,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GPO Account').getRecordTypeId()
            );
            insert accTest8;
            
            Account accTest9 = new Account(
                Name = 'TestAccount9',
                SAP_Sold_To__c = '123456',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '01',
                Sales_Org__c = 'BR10',
                Distribution_Channel__c='10',
                Type = 'Ship-To (Z002)',
                ERP_Active__c = FALSE,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
            );
            insert accTest9;

            Account accTest10 = new Account(
                Name = 'TestAccount10',
                SAP_Sold_To__c = '123457',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '01',
                Sales_Org__c = 'DE10',
                Distribution_Channel__c='10',
                Type = 'Sold-To (Z001)',
                ERP_Active__c = TRUE,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EMEA Customer').getRecordTypeId()
            );
            insert accTest10;
            
            Account accTest11 = new Account(
                Name = 'TestAccount11',
                SAP_Sold_To__c = 'IDN-002',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '01',
                BillingCountry = 'US',
                ParentId = accTest7.Id,
                ERP_Active__c = FALSE,
                Type = 'Sold-To (Z001)',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IDN Account').getRecordTypeId()
            );
            insert accTest11;
            Account accTest12= new Account(
                Name = 'TestAccountMayo Healthcare PtyÃŸ., Ltd',
                Account_Name_2__c = 'TestAccountMayo Healthcare PtyÃŸ., Ltd',
                Incoterms_1__c = 'ÃŸÃ¼ÄÅ‚',
                Incoterms_2__c = 'ÃŸÃ¼ÄÅ‚',
                Terms__c = 'ÃŸÃ¼ÄÅ‚',
                ShippingCity = 'ÃŸÃ¼ÄÅ‚',
                ShippingStreet = 'ÃŸÃ¼ÄÅ‚',
                ShippingState = 'ÃŸÃ¼',
                SAP_Sold_To__c = '8888',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '01',
                ERP_Active__c = TRUE,
                Sales_Org__c = 'CH10',
                Distribution_Channel__c='10',
                Type = 'Ship-To (Z002)',
                ParentId = accTest11.Id,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EMEA Customer').getRecordTypeId()
            );
            insert accTest12;
            //System.assertEquals(accTest10.RecordTypeId, Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId());


        }//end of System.runAs
        
    }//end of test data
    
    @isTest static void acctRecTypeTest(){
        List<Account> accList = [SELECT Id, Name, Sales_Org__c, Sap_Sold_To__c, Account_Group__c, Customer_Group__c,
                                 zBlock__c, RecordTypeId, Account_Group_Name__c, Distribution_Channel__c, ERP_Active__c, Type, ParentId
                                 FROM Account
                                 WHERE Name LIKE 'TestAccount%' AND Sap_Sold_To__c != NULL];
        
        account_Helper_Class.accRecordTypeCheck(accList);
        account_Helper_Class.updateAccountType(accList);
        account_Helper_Class.addIDNs(accList);
        account_Helper_Class.addParentAccount(accList);
        account_Helper_Class.addIdnCustomSetting(accList);
        account_Helper_Class.updateAccountFields(accList);
    }//end of rectype test
    
}//end of class