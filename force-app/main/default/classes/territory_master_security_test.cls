@istest
public class territory_master_security_test {
    public static testMethod void validate_addTerritoryMasterAlignments() {
        
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
        
        Account a = new account(
            Name = 'Test',
            SAP_Sold_To__c = '999999',
            BillingState = 'NC',
            BillingPostalCode = '27614',
            BillingCountry = 'US',
            Customer_Group__c = '02'
        );
        insert a;
        
        Territory_Master__c tm = new Territory_Master__c(
            Name = '700123',
            Territory_Number__c = '700123',
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
        
        /*
        Territory_User__c tu = new Territory_User__c(
            Territory_Master__c = tm.Id,
            User__c = u.id
        );
        insert tu;
        System.debug('Insert Territory User-->' + tu);
        */       
          
        
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
            ZPSA_Table__c = 'A659',
            Filter_Key__c = 'NC-A659',
            Active__c = TRUE,
            Territory_Master__c = tm.Id,
            Business_Unit__c = 'EMS'
        );
        insert tarstate;
        
        Territory_Alignment__c tarsap = new Territory_Alignment__c(
            Key__c	= '999999-700123',
            SAP_Code__c	= '999999',
            Account_Name__c	= 'Test',
            Territory__c = '700123',
            Territory_Name__c = '700123',
            Territory2__c = '700123',
            Territory_2_Name__c = '700123',
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
 
        Territory_Alignment__c tarzip = new Territory_Alignment__c(
            Key__c	= '27614-700123',
            Zip10__c = '27614',
            Territory__c = '700123',
            Territory_Name__c = '700123',
            Territory2__c = '700123',
            Territory_2_Name__c = '700123',
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
            Key__c = '276-02-700123',
            Zip3__c = '276',
            Customer_Group__c = '02',
            Customer_Group_Name__c = 'Dist/Dlr Emg Med Svc',
            Territory__c = '700123',
            Territory_Name__c = '700123',
            Territory2__c = '700123',
            Territory_2_Name__c = '700123',
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
        
        string query = 'SELECT Id, SAP_Sold_to__c, BillingState, BillingPostalCode, Customer_Group__c ' + 
            'FROM Account ' +                                                  
            'WHERE Territory_Alignment_Skip__c = FALSE';
        system.debug('query: ' + query);
        
        tm.Update_Territory_Alignments__c = TRUE;
        master_TriggerHelperClass.runOnce('resetOnceSet');
        update tm;
        
        Test.startTest();
        
        // Test Class
        territory_master_build_security tBuild = new territory_master_build_security(query);
        tBuild.query = query;
        tBuild.territory = tm.Name;
        Database.executeBatch(tBuild);                 
        
        
        
        Test.stopTest();
        
        
        
    }
    
}