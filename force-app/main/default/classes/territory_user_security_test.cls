@istest
public class territory_user_security_test {
    public static testMethod void validate_addAccountShares() {
        
        // Disable all the Territory Triggers, we don't want those firing during the test.
        Quick_Disable__c cs = new Quick_Disable__c(
            Name = 'addAccountShares',
            Enable__c = FALSE
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
            Enable__c = FALSE
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
            Enable__c = FALSE
        );
        System.debug('insert cs2-->' + cs5);
        insert cs5;
        
        Quick_Disable__c cs6 = new Quick_Disable__c(
            Name = 'territory_user_maintenance',
            Enable__c = TRUE
        );
        System.debug('insert cs2-->' + cs6);
        insert cs6;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(
            Alias = 'standt', 
            Email='standarduser76@testorg.com', 
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
        
        User u2 = new User(
            Alias = 'standt', 
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
        System.debug('Insert User-->' + u2);
        
        User u3 = new User(
            Alias = 'standt', 
            Email='standarduser78@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing3', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='TeleflexTESTER3@teleflex.test.com'
        );
        insert u3;
        System.debug('Insert User-->' + u3);
        
        Account a = new account(
            Name = 'Test',
            SAP_Sold_To__c = '999999',
            BillingState = 'NC',
            BillingPostalCode = '27614',
            BillingCountry = 'US',
            Customer_Group__c = '02'
        );
        insert a;
        
        Contact c = new Contact(
            FirstName ='Test',
            email = 'abc@123.com',
            LastName = 'TestContact',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
            AccountId = a.Id
        );
        insert c;
        
        Territory_Master__c tm2 = new Territory_Master__c(
            Name = '700111',
            Territory_Number__c = '700111',
            Business_Unit__c = 'EMS'
        );
        insert tm2;
        System.debug('Insert Territory Master-->' + tm2);
        
        Territory_Master__c tm = new Territory_Master__c(
            Name = '700123',
            Territory_Number__c = '700123',
            Business_Unit__c = 'EMS',
            Compensation_Profile__c = 'EMS',
            Sales_Rep__c = u.Id,
            Sales_Rep_Email__c = 'standarduser76@testorg.com',
            Manager_Email__c = 'standarduser77@testorg.com',
            Region_Number__c = '700111'
        );
        
        master_TriggerHelperClass.runOnce('resetOnceSet');
        insert tm;
        System.debug('Insert Territory Master-->' + tm);
        
        tm.Build_Empty_Quotas__c = TRUE;
        tm.Tickle_Quota_s__c = TRUE;
        master_TriggerHelperClass.runOnce('resetOnceSet');
        update tm;
        
        //        master_TriggerHelperClass.runOnce('resetOnceSet');
        tm.Remove_Empty_Quotas__c = TRUE;
        update tm;        
        Territory_Master__c tm5 = new Territory_Master__c(
            Name = '800054',
            Territory_Name__c='Anesthesia Houston',
            Territory_Number__c = '800054',
            Business_Unit__c = 'Anesthesia',
            Compensation_Profile__c = 'Anesthesia',
            Sales_Rep__c = u.Id,
            Sales_Rep_Email__c = 'standarduser76@testorg.com',
            Manager_Email__c = 'standarduser77@testorg.com',
            Region_Number__c = '800640',
            Region_Name__c='ANESTHESIA RSM CENTRAL REGION'
        );   
        master_TriggerHelperClass.runOnce('resetOnceSet');
        insert tm5;
        System.debug('Insert Territory Master-->' + tm5);
        
        tm.Build_Empty_Quotas__c = TRUE;
        tm.Tickle_Quota_s__c = TRUE;
        master_TriggerHelperClass.runOnce('resetOnceSet');
        update tm5;
        
        //        master_TriggerHelperClass.runOnce('resetOnceSet');
        tm.Remove_Empty_Quotas__c = TRUE;
        update tm5;        
        
        Territory_Master__c tm3 = new Territory_Master__c(
            Name = '700007',
            Territory_Number__c = '700007',
            Business_Unit__c = 'EMS'
        );
        insert tm3;
        System.debug('Insert Territory Master-->' + tm3);
        
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
        
        Territory_User__c tu2 = new Territory_User__c(
            Territory_Master__c = tm2.Id,
            User__c = u.id,
            Primary__c = TRUE
        );
        master_TriggerHelperClass.runOnce('resetOnceSet');
        insert tu2;
        System.debug('Insert Territory User-->' + tu2);
        
        Territory_User__c tu3 = new Territory_User__c(
            Territory_Master__c = tm3.Id,
            User__c = u2.id,
            Primary__c = TRUE
        );
        master_TriggerHelperClass.runOnce('resetOnceSet');
        insert tu3;
        System.debug('Insert Territory User-->' + tu3);
        
        tu2.Territory_Master__c = tm3.Id;
        tu2.Primary__c = TRUE;
        master_TriggerHelperClass.runOnce('resetOnceSet');
        tu2.Rebuild_Territory_Alignments__c=true; //*******************updating to get test coverage**********//
        update tu2;
        
        
      
        
        
        Territory_Alignment__c tarstate = new Territory_Alignment__c(
            Key__c  = 'NC-700123',
            Region__c = 'NC',
            Territory__c = '700123',
            Territory_Name__c = '700123',
            Territory2__c = '700123',
            Territory_2_Name__c = '700123',
            Territory3__c = '',
            Territory_3_Name__c = '',
            Territory4__c = '',
            Territory_4_Name__c = '',
            ZPSA_Table__c = 'A659'
        );
        insert tarstate;
        
        Territory_Assignment__c terrAssignment = new Territory_Assignment__c (
            Name = 'NC-700123',
            Account__c = a.id,
            Territory_Alignment__c = tarstate.id,
            Territory__c = tm.Id,
            Territory_Number__c = '700123'
        );
        insert terrAssignment;
        
        master_TriggerHelperClass.runOnce('resetOnceSet');
        update a;
        
        Lead l = new lead(
            lastname = 'test',
            company = 'test',
            Status = 'Open',
            OwnerId = u.Id
        );
        insert l;
        
        l.OwnerId = u2.Id;
        master_TriggerHelperClass.runOnce('resetOnceSet');
        update l;
        
        l.OwnerId = u3.Id;
        master_TriggerHelperClass.runOnce('resetOnceSet');
        update l;
        
        string query = 'SELECT Account__c, Account_Owner_Id__c, Business_Unit__c ' + 
            'FROM Territory_Assignment__c ' +                                                  
            'WHERE Account__r.Territory_Alignment_Skip__c = FALSE AND Territory__r.Id = \'' + tm.id + '\'';
        system.debug('query: ' + query);
        string uname = 'John Smith';
        
        Test.startTest();
        
        // ADD
        territory_user_build_security usrBuild = new territory_user_build_security(query);
        usrBuild.query = query;
        usrBuild.usrId = u.id;
        usrBuild.uname = uname;
        Database.executeBatch(usrBuild);                 
        // DEL
        territory_user_remove_security usrRemove = new territory_user_remove_security(query);
        usrRemove.query = query;
        usrRemove.usrId = u.id;
        usrRemove.uname = uname;
        Database.executeBatch(usrRemove);
        
        
        Test.stopTest();
        
        // Opportunity Tests for: opportunity_Helper_Class.addTerritory - 24Jan2018 - ESC
        
        Pricebook2 pb = new pricebook2(
            Name='Pricing Portal US',
            IsActive = TRUE
        );
        insert pb;
        system.debug('pb: ' + pb);
        
        string pbid = pb.Id;
        pbid = pbid.left(15);
        
        insert new Price_Books__c(
            Name = 'US103010',
            Id__c = pbid,
            Price_Book_Name__c = 'Pricing Portal US'
        );
        
        Opportunity newOpp = new Opportunity(
            Name = 'Test Opp',
            AccountId = a.Id,
            CloseDate = Date.Today() + 90,
            Primary_Contact__c = c.Id,
            StageName = 'Qualified Prospect',
            Amount = 1.00,
            Product_Family__c = 'Airway',
            Product_of_Interest__c = 'EFx Shield;T Shield',
            //RecordTypeId = '01244000000NNcz',
            Business_Unit_GPL__c='Anesthesia',
            Product_Family_GPL__c='Airway',
            Product_of_Interest_GPL__c='MADgic',
            Pricebook2 = pb,
            OwnerId = u.Id,
            Territory_Update__c = TRUE
        );
        insert newOpp;
        
        
        
        
        List<Territory_Master__c> Tmaster = [SELECT Territory_Number__c, Territory_Name__c,Region_Number__c,Region_Name__c  
                                             FROM Territory_Master__c ];
        territory_user_maintenance.checkSalesRegion(Tmaster);
        
               
        
        
        
        
        
        
        
    }
    
}