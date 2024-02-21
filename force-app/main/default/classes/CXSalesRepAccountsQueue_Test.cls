@isTest
public class CXSalesRepAccountsQueue_Test {
    static testmethod void test1() {
        

         set<Id> accIds = new set<Id>();
         List<Id> SalesRepIDs = new List<Id>();
         map<Id,Set<Id>> SRvsAccsMap = new map<Id,Set<Id>>();
         map<Id,Set<Id>> SRvsAccsMapFinal = new map<Id,Set<Id>>();
         Boolean hasMoreRecs;
         Boolean StartNewTransaction;
         Id hasMoreRecsLmtID;
         Integer recsCnt = 0;
        
        List<Id> salRepLst = new List<Id>();      
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
            Business_Unit__c='BU'
        );
        insert u;
        
        Profile p1 = [select id from profile where name='System Administrator'];
        User u1 = new User(
            alias = 'uflex76',
            email='unit.test@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Adam',
            lastname='Franks',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p1.Id,
            timezonesidkey='Europe/London',
            username='test@unit.teleflex.com',
            Business_Unit__c='BU'
        );
        insert u1;
        
        Account acc = new Account();
        acc.Name = 'CXTestAcc';
        acc.SAP_Sold_To__c = '123456';
        acc.SAP_Code__c='123456';
        acc.Territory_Key__c='123456;234567';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'CXTestAcc1';
        acc1.SAP_Sold_To__c = '234567';
        acc1.SAP_Code__c='234567';
        acc1.Territory_Key__c='123456;234567';
        insert acc1;
        
        
        
        Territory_Master__c tm = new Territory_Master__c(
            Name = '700123',
            Territory_Number__c = '123456',
            Business_Unit__c = 'Surgical Disposables',
            Sales_Rep_Email__c = 'unit.test@unit.teleflex.com'
        );
        insert tm;
        
        Territory_Master__c tm1 = new Territory_Master__c(
            Name = '700123',
            Territory_Number__c = '234567',
            Business_Unit__c = 'Surgical Disposables',
            Sales_Rep_Email__c = 'unit.test@unit.teleflex.com'
        );
        insert tm1;
        
        Territory_User__c tu = new Territory_User__c(
            User__c = u.Id,
            Business_Unit__c = 'Surgical Disposables',
            Role__c = 'Sales Rep',
            Territory_Master__c = tm.Id,
            Territory_Number__c = '123456'
        );
        insert tu;
        
        Territory_User__c tu1 = new Territory_User__c(
            User__c = u1.Id,
            Business_Unit__c = 'Surgical Disposables',
            Role__c = 'Sales Rep',
            Territory_Master__c = tm1.Id,
            Territory_Number__c = '234567'
        );
        insert tu1;
        
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
            Business_Unit__c = 'Surgical Disposables',
            ZPSA_Table__c = 'A672'
        );
        insert tarbc;
        
        Territory_Alignment__c tarbc1 = new Territory_Alignment__c(
            Key__c = '276-02-70000',
            Zip3__c = '222',
            Customer_Group__c = '22',
            Customer_Group_Name__c = 'Dist/Dlr Emg Med Svc1',
            Territory__c = '70000',
            Territory_Name__c = '70000',
            Territory2__c = '70000',
            Territory_2_Name__c = '70000',
            Territory3__c = '',
            Territory_3_Name__c = '',
            Territory4__c = '',
            Territory_4_Name__c = '',
            Business_Unit__c = 'Surgical Disposables',
            ZPSA_Table__c = 'A671'
        );
        insert tarbc1;
        
        Territory_Assignment__c terrAssignment = new Territory_Assignment__c (
            Name = 'NC-700123',
            Account__c = acc.id,
            Territory_Alignment__c = tarbc.id,
            Territory__c = tm.Id,
            Territory_Number__c = '123456'
        );
        
        insert terrAssignment; 
        
        Territory_Assignment__c terrAssignment1 = new Territory_Assignment__c (
            Name = 'NC-700123',
            Account__c = acc1.id,
            Territory_Alignment__c = tarbc1.id,
            Territory__c = tm1.Id,
            Territory_Number__c = '234567'
        );
        
        insert terrAssignment1;
        
        
        
        salRepLst.add(u.Id);
        //salRepLst.add(u.Id);
        //salRepLst.add(u1.Id);
        accIds.add(acc.Id);
        accIds.add(acc1.Id);
        SalesRepIDs.add(u1.Id);
        SRvsAccsMap.put(u1.Id, accIds);
        SRvsAccsMapFinal.put(u1.Id, accIds);
        hasMoreRecs = true;
        StartNewTransaction = true;
        hasMoreRecsLmtID = terrAssignment1.Id;
        recsCnt = 60000;
        // startTest/stopTest block to force async processes 
        //   to run in the test.
        Test.startTest();
        
        System.enqueueJob(new CXSalesRepAccountsQueue(salRepLst));
        System.enqueueJob(new CXSalesRepAccountsQueue(accIds, SalesRepIDs, SRvsAccsMap, SRvsAccsMapFinal, hasMoreRecs, StartNewTransaction, hasMoreRecsLmtID, recsCnt));
        System.enqueueJob(new CXSalesRepAccountsQueue(accIds, salRepLst, SRvsAccsMap, SRvsAccsMapFinal, false, StartNewTransaction, hasMoreRecsLmtID, 50000));
        
        Test.stopTest();
    }
}