@istest
public class territory_Account_Shares_TEST {
    
    @testSetup static void dataSetup(){
        Quick_Disable__c cs = new Quick_Disable__c(
            Name = 'addAccountShares',
            Enable__c = TRUE
        );
        System.debug('insert cs-->' + cs);
        insert cs;
        
        Quick_Disable__c cs2 = new Quick_Disable__c(
            Name = 'addAccountShares_legacy',
            Enable__c = FALSE
        );
        System.debug('insert cs2-->' + cs2);
        insert cs2;
        
        Quick_Disable__c cs3 = new Quick_Disable__c(
            Name = 'territory_Account_Alignment',
            Enable__c = TRUE
        );
        System.debug('insert cs2-->' + cs3);
        insert cs3;        
        
        Quick_Disable__c cs4 = new Quick_Disable__c(
            Name = 'Territory_Automation_After',
            Enable__c = FALSE
        );
        System.debug('insert cs2-->' + cs4);
        insert cs4;
        
        Quick_Disable__c cs5 = new Quick_Disable__c(
            Name = 'Territory_Automation_Before',
            Enable__c = TRUE
        );
        System.debug('insert cs2-->' + cs5);
        insert cs5;
        
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
            username='unit.test@unit.teleflex.com'
        );
        insert u;
        
        User u2 = new User(
            Alias = 'stand2', 
            Email='standarduser77@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing2', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='TeleflexTESTER2@teleflex.test.com'
        );
        insert u2;
        System.debug('Insert User2-->' + u2);
        
        
        System.runAs(u){
            
            Territory_Master__c tm = new Territory_Master__c(
                Name = '800123',
                Territory_Number__c = '800123',
                Business_Unit__c = 'EMS',
                Role__c = 'Sales Rep',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com'
            );
            insert tm;
            System.debug('Insert Territory Master-->' + tm);
            
            Territory_Master__c tm2 = new Territory_Master__c(
                Name = '800124',
                Territory_Number__c = '800124',
                Business_Unit__c = 'EMS',
                Primary_Territory_User_Email__c = 'unit.test@unit.teleflex.com'
            );
            insert tm2;
            System.debug('Insert Territory Master-->' + tm);
            
            Territory_Master__c tm3 = new Territory_Master__c(
                Name = '800125',
                Territory_Number__c = '800125',
                Business_Unit__c = 'EMS',
                Territory_Name_2__c  = '800123'
            );
            insert tm3;
            System.debug('Insert Territory Master-->' + tm);
            
            Territory_Master__c tm4 = new Territory_Master__c(
                Name = '800126',
                Territory_Number__c = '800126',
                Business_Unit__c = 'EMS',
                Territory_Name_2__c  = '800123'
            );
            insert tm4;
            System.debug('Insert Territory Master-->' + tm);
            
            
            
            Territory_User__c tu = new Territory_User__c(
                Territory_Master__c = tm.Id,
                User__c = u.id
            );
            insert tu;
            System.debug('Insert Territory User-->' + tu);
            
            Territory_User__c tu2 = new Territory_User__c(
                Territory_Master__c = tm2.Id,
                User__c = u.id
            );
            insert tu2;
            System.debug('Insert Territory User-->' + tu);
            
            Territory_User__c tu3 = new Territory_User__c(
                Territory_Master__c = tm3.Id,
                User__c = u.id
            );
            insert tu3;
            System.debug('Insert Territory User-->' + tu);
            
            Territory_User__c tu4 = new Territory_User__c(
                Territory_Master__c = tm4.Id,
                User__c = u.id
            );
            insert tu4;
            System.debug('Insert Territory User-->' + tu);
            
            tu = new Territory_User__c(
                Territory_Master__c = tm.Id,
                User__c = u2.id
            );
            insert tu;
            System.debug('Insert Territory User-->' + tu);        
            
            
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
                ZPSA_Table__c = 'A681',
                Filter_Key__c = '999999-A681',
                Active__c = TRUE,
                Territory_Master__c = tm.Id,
                Business_Unit__c = 'EMS'
            );
            insert tarsap;
            
            Territory_Alignment__c tarstate = new Territory_Alignment__c(
                Key__c	= 'NC-800124',
                Region__c = 'NC',
                Territory__c = '800124',
                Territory_Name__c = '800124',
                Territory2__c = '800124',
                Territory_2_Name__c = '800124',
                Territory3__c = '',
                Territory_3_Name__c = '',
                Territory4__c = '',
                Territory_4_Name__c = '',
                ZPSA_Table__c = 'A659',
                Filter_Key__c = 'NC-A659',
                Active__c = TRUE,
                Territory_Master__c = tm.Id,
                Business_Unit__c = 'EMS'
            );
            insert tarstate;
            
            Territory_Alignment__c tarzip = new Territory_Alignment__c(
                Key__c	= '27614-800125',
                Zip10__c = '27614',
                Territory__c = '800125',
                Territory_Name__c = '800125',
                Territory2__c = '800125',
                Territory_2_Name__c = '800125',
                Territory3__c = '',
                Territory_3_Name__c = '',
                Territory4__c = '',
                Territory_4_Name__c = '',
                ZPSA_Table__c = 'A626',
                Filter_Key__c = '27614-A626',
                Active__c = TRUE,
                Territory_Master__c = tm.Id,
                Business_Unit__c = 'EMS'
            );
            insert tarzip;
            
            Territory_Alignment__c tarbc = new Territory_Alignment__c(
                Key__c = '276-02-800126',
                Zip3__c = '276',
                Customer_Group__c = '02',
                Customer_Group_Name__c = 'Dist/Dlr Emg Med Svc',
                Territory__c = '800126',
                Territory_Name__c = '800126',
                Territory2__c = '800126',
                Territory_2_Name__c = '800126',
                Territory3__c = '',
                Territory_3_Name__c = '',
                Territory4__c = '',
                Territory_4_Name__c = '',
                ZPSA_Table__c = 'A672',
                Filter_Key__c = '27602-A672',
                Active__c = TRUE,
                Territory_Master__c = tm.Id,
                Business_Unit__c = 'EMS'
            );
            insert tarbc;

            Id aRecId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Vascular_Customer_NA' LIMIT 1].Id;
            
            master_TriggerHelperClass.runOnce('resetOnceSet');
            Account a = new account(
                Name = 'Test',
                SAP_Sold_To__c = '999999',
                BillingState = 'NC',
                BillingPostalCode = '27614',
                BillingCountry = 'US',
                Customer_Group__c = '02',
                Territory_Key__c = '800123',
                RecordTypeId = aRecId
            );
            insert a;
            
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update a;
            
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
            
            Account a2 = new account(
                Name = 'Test2',
                SAP_Sold_To__c = '999991',
                BillingState = 'NC',
                BillingCountry = 'US',
                BillingPostalCode = '27614',
                Customer_Group__c = '02',
                Territory_Key__c = '800123',
                RecordTypeId = aRecId
            );
            master_TriggerHelperClass.runOnce('resetOnceSet');
            insert a2;
            
            System.debug('Update a.Name-->' + a.Name);
            a.Name = 'Test 2';
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update a;
            system.debug('Catch! ' + a);
            system.debug('Catch2! ' + a.RecordType.Name );
            
            Territory_Account__c ta = new Territory_Account__c(
                //name = 'TERR-12312300',
                Account__c = a.Id,
                Territory_Master__c = tm.Id
            );
            insert ta;
            System.debug('Insert Territory Account-->' + ta);
        }
    }
    @isTest static void territory_Account_Check() {
        
        //Id aid = [SELECT Id FROM Account WHERE Territory_Alignment_Skip__c = FALSE LIMIT 1].Id;
        Id aid = [SELECT Id FROM Account WHERE SAP_Sold_To__c = '999999' LIMIT 1].Id;

        string query = 'SELECT Id, SAP_Sold_to__c, BillingState, BillingPostalCode, Customer_Group__c FROM Account WHERE Territory_Alignment_Skip__c = FALSE';
        
        Test.startTest();
        
        PageReference pageRef = new PageReference('/apex/territory_Account_Check?id=' + aid );
        system.debug('pageRef:' + pageRef); 
        
        Test.setCurrentPage(pageRef);
        
        territory_Account_Check tac = new territory_Account_Check();
        tac.getAccount();
        
        // Test Class for territory_user_build_security
        territory_master_build_security tBuild = new territory_master_build_security(query);
        tBuild.query = query;
        tBuild.territory = '800123';
        Database.executeBatch(tBuild); 
        
        Build_Account_Access_Batch accRefresh = new Build_Account_Access_Batch();
        Database.executeBatch(accRefresh);

        String CRON_EXP = '0 0 0 15 3 ? 2099';
        String jobId;
        String jobId2;
        
        jobId = System.schedule('Build_Account_Access_Schedule', CRON_EXP, new Build_Account_Access_Schedule());
        jobId2 = System.schedule('ZPSA_Maintenance_Scheduler', CRON_EXP, new ZPSA_Maintenance_Scheduler());
        
        Test.stopTest();
        
    }
}