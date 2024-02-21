@istest
public class territory_Account_Alignment_Test {
    
        @isTest static void account_Check() {
            Quick_Disable__c cs = new Quick_Disable__c(
            Name = 'territory_user_maintenance',
            Enable__c = TRUE
        );
            insert cs;
            
            Territory_Master__c tm = new Territory_Master__c(
                Name = '800123',
                Territory_Number__c = '800123',
                Business_Unit__c = 'EMS',
                Region_Number__c ='900041',
                Role__c = 'Sales Rep'
            );
            insert tm;
            System.debug('Insert Territory Master-->' + tm);
            
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
            
            Territory_User__c tu = new Territory_User__c(
                Territory_Master__c = tm.Id,
                User__c = u.id
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
                Key__c	= 'NC-800123',
                Region__c = 'NC',
                Territory__c = '800123',
                Territory_Name__c = '800123',
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
                Key__c	= '27614-800123',
                Zip10__c = '27614',
                Territory__c = '800123',
                Territory_Name__c = '800123',
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
                Key__c = '276-02-800123',
                Zip3__c = '276',
                Customer_Group__c = '02',
                Customer_Group_Name__c = 'Dist/Dlr Emg Med Svc',
                Territory__c = '800123',
                Territory_Name__c = '800123',
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
            
            master_TriggerHelperClass.runOnce('resetOnceSet');
            Account a = new account(
                Name = 'Test',
                SAP_Sold_To__c = '999999',
                BillingState = 'NC',
                BillingPostalCode = '27614',
                BillingCountry = 'US',
                Customer_Group__c = '02',
                Territory_Key__c = '800123'
            );
            insert a;
            
            Account a2 = new account(
                Name = 'Test',
                SAP_Sold_To__c = '999997',
                BillingState = 'NC',
                BillingPostalCode = '27614',
                BillingCountry = 'US',
                Customer_Group__c = '02',
                Territory_Key__c = '800123'
            );
            insert a2;
         
        territory_user_maintenance.checkSalesRegion(new list<territory_master__c>{tm});
        
        }
    
}