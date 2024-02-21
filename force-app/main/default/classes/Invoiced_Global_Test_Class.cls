/*********************************************************************
* Description     : Main test class for Invoiced_Sales_Helper_Class
* Covered Classes : Invoiced_Sales_Helper_Class, Invoiced_Sales_Tracking_Class
* Author(s)       : Dunte'e Silver
**********************************************************************/
@isTest
public class Invoiced_Global_Test_Class { 
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
            Business_Unit__c = 'Surgical Disposables',
            Sharing_Key__c = 'Adam Franks'
        );
        insert u;
        
        User umg = new User(
            alias = 'tsmiths', 
            email='unit.test.manager@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Tim',
            lastname='Smiths', 
            languagelocalekey='en_US',
            localesidkey='en_GB', 
            profileid = p.Id,
            timezonesidkey='Europe/London', 
            username='unit.test.manager@unit.teleflex.com',
            Business_Unit__c = 'Surgical Disposables'
        );
        insert umg;
        
        Test.startTest();
        list<Maintenance_Objects__c> moList = new list<Maintenance_Objects__c>();
        Maintenance_Objects__c mo = new Maintenance_Objects__c(
            Name = 'Open_Orders__c',
            Limit__c = 10000,
            Type__c = 'Sales',
            Pretty_Name__c = 'Open Orders',
            Report_Id__c = '123'
        );
        moList.add(mo);
        
        mo = new Maintenance_Objects__c(
            Name = 'Invoiced_Sales__c',
            Limit__c = 50000,
            Type__c = 'Sales',
            Pretty_Name__c = 'Invoiced Sales',
            Report_Id__c = '123'
        );
        moList.add(mo);
        
        mo = new Maintenance_Objects__c(
            Name = 'Invoiced_Sales_Detail__c',
            Limit__c = 50000,
            Type__c = 'Sales',
            Pretty_Name__c = 'Invoiced Sales Detail',
            Report_Id__c = '123'
        );
        moList.add(mo);
        
        mo = new Maintenance_Objects__c(
            Name = 'Contract_Material__c',
            Pretty_Name__c = 'Contract Material',
            Limit__c = 40000,
            Type__c = 'PP',
            Report_Id__c = '123'
        );
        moList.add(mo);
        
        mo = new Maintenance_Objects__c(
            Name = 'Contract_Customer__c',
            Pretty_Name__c = 'Contract Customer',
            Limit__c = 40000,
            Type__c = 'PP',
            Report_Id__c = '123'
        );
        moList.add(mo);
        
        insert moList;
        
        Maintenance_Email_Addresses__c newMEA = new Maintenance_Email_Addresses__c(
            Name = 'Adam Franks',
            Email__c = 'unit.test@unit.teleflex.com',
            Invoiced_Sales__c = TRUE,
            Invoiced_Sales_Detail__c = TRUE,
            Open_Orders__c = TRUE,
            Contract_Customer__c = TRUE,
            Contract_Material__c = TRUE,
            SMS_Notification__c = 'unit.test@unit.teleflex.com'
        );
        insert newMEA;
        
        // Disable all the Territory Triggers, we don't want those firing during the test.
        List<Quick_Disable__c> csList = new List<Quick_Disable__c>();
        Quick_Disable__c cs = new Quick_Disable__c(
            Name = 'addAccountShares',
            Enable__c = FALSE
        );
        System.debug('insert cs-->' + cs);
        csList.add(cs);
        
        Quick_Disable__c cs2 = new Quick_Disable__c(
            Name = 'addAccountShares_legacy',
            Enable__c = FALSE
        );
        System.debug('insert cs2-->' + cs2);
        csList.add(cs2);
        
        Quick_Disable__c cs3 = new Quick_Disable__c(
            Name = 'territory_Account_Alignment',
            Enable__c = FALSE
        );
        System.debug('insert cs3-->' + cs3);
        csList.add(cs3);        
        
        Quick_Disable__c cs4 = new Quick_Disable__c(
            Name = 'Territory_Automation_After',
            Enable__c = FALSE
        );
        System.debug('insert cs4-->' + cs4);
        csList.add(cs4);
        
        Quick_Disable__c cs5 = new Quick_Disable__c(
            Name = 'Territory_Automation_Before',
            Enable__c = FALSE
        );
        System.debug('insert cs5-->' + cs5);
        csList.add(cs5);
        
        Quick_Disable__c cs6 = new Quick_Disable__c(
            Name = 'territory_user_maintenance',
            Enable__c = FALSE
        );
        System.debug('insert cs6-->' + cs6);
        csList.add(cs6);
        
        insert csList;
        
        BaseQuotaException__c bqe = new BaseQuotaException__c(
            Name = 'territory_user_maintenance',
            IsException__c = TRUE
        );
        insert bqe;
        
        list<Business_Unit__c> buList = new list<Business_Unit__c>();
        Business_Unit__c newBU = new Business_Unit__c(
            Name = 'Vascular',
            Key__c = 'VASC'
        );
        buList.add(newBU);

        newBU = new Business_Unit__c(
            Name = 'Surgical Disposables',
            Active__c = TRUE,
            Page__c = 'account',
            Key__c = 'SDIS'
        );
        buList.add(newBU);
        
        newBU = new Business_Unit__c(
            Name = 'Anesthesia',
            Active__c = TRUE,
            Page__c = 'account',
            Key__c = 'ANES'
        );
        buList.add(newBU);
        //insert bu2;                
        insert buList;
		
        System.runAs(u){
            Group g1 = new Group(Name='Contracts Team', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Contract_Renewal__c');
            insert q1;
            //Id contractsGroupId = [SELECT QueueId FROM QueueSobject WHERE queue.Name = 'Contracts Team' and SobjectType = 'Contract_Renewal__c'].QueueId;

            list<Account> alist = new list<Account>();
            list<Contact> clist = new list<Contact>();
            
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
                ERP_Active__c = FALSE
            );
            master_TriggerHelperClass.runOnce('resetOnceSet');
            alist.add(a);
            //insert a;
            
            Account a2 = new Account(
                Name = 'Test PP Account2', 
                SAP_Sold_To__c ='100555', 
                ShippingStreet='1234 Main Street ', 
                ShippingCity='Raleigh',
                ShippingState='NC', 
                ShippingPostalCode='27613',
                Customer_Group__c = '19',
                Sales_by_BU_Key__c = '123',
                zBlock__c = '01',
                Account_Group__c = 'Z002',
                ERP_Active__c = TRUE
                
            );
            master_TriggerHelperClass.runOnce('resetOnceSet');
            alist.add(a2);
            //insert a2;
            
            insert alist;
            
            Customer_Master_Reference__c cmr = new Customer_Master_Reference__c (
                Name = 'CMR Test',
                Account_Group__c = 'Z001', 
                City__c = 'Raleigh', 
                Country__c = 'US', 
                State__c = 'NC',  
                Street__c = '123 Main St.',
                Zip_Code__c = '27614',
                SAP_Code__c = '10170226', 
                zBlock__c = 'Z1'
            );
            insert cmr;
            
            List<Contact> coList = new List<Contact>();
            Contact c = new Contact(
                FirstName='Test',
                LastName = 'Test',
                Email='abc@123.com',
                AccountId = a.Id,
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                Business_Unit1__c = 'Surgical Disposables'
            );
            coList.add(c);
            
            Contact c2 = new Contact(
                FirstName='Test',
                LastName = 'Test2',
                Email='abc@123.com',
                AccountId = a.Id,
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                Business_Unit1__c = 'Anesthesia'
            );
            coList.add(c2);
            insert coList;
            
            c2.Business_Unit1__c = 'EMS';
            update c2;
            
            List<Territory_Master__c> tmList = new List<Territory_Master__c>();
            Territory_Master__c tm = new Territory_Master__c(
                Name = '700123',
                Territory_Number__c = '700123',
                Business_Unit__c = 'Surgical Disposables',
                Compensation_Profile__c = 'Surgical Disposables',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com',
                Manager_Email__c = 'unit.test.manager@unit.teleflex.com',
                Primary_Territory_User_Email__c = 'unit.test@unit.teleflex.com',
                Sharing_Key__c = 'Adam Franks'
                
            );
            tmList.add(tm);
            System.debug('Insert Territory Master-->' + tm);
            
            Territory_Master__c tm2 = new Territory_Master__c(
                Name = '700124',
                Territory_Number__c = '700124',
                Business_Unit__c = 'Vascular',
                Compensation_Profile__c = 'Vascular',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com',
                Manager_Email__c = 'unit.test.manager@unit.teleflex.com',
                Primary_Territory_User_Email__c = 'unit.test@unit.teleflex.com',
                Role__c = 'KAM',
                Sharing_Key__c = 'Adam Franks'
                
            );
            tmList.add(tm2);

            Territory_Master__c tm3 = new Territory_Master__c(
                Name = '700125',
                Territory_Number__c = '700125',
                Business_Unit__c = 'Vascular',
                Compensation_Profile__c = 'Vascular',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com',
                Manager_Email__c = 'unit.test.manager@unit.teleflex.com',
                Primary_Territory_User_Email__c = 'unit.test@unit.teleflex.com',
                Sharing_Key__c = 'Adam Franks'
            );
            tmList.add(tm3);
             
            Territory_Master__c tm4 = new Territory_Master__c(
                Name = '800205',
                Territory_Number__c = '800205',
                Business_Unit__c = 'Vascular',
                Compensation_Profile__c = 'Vascular',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com',
                Manager_Email__c = 'unit.test.manager@unit.teleflex.com',
                Primary_Territory_User_Email__c = 'unit.test@unit.teleflex.com',
                Role__c = 'KAM',
                Sharing_Key__c = 'Adam Franks'
                
            );
            tmList.add(tm4);
            
            Territory_Master__c tm5 = new Territory_Master__c(
                Name = '800321',
                Territory_Number__c = '800321',
                Business_Unit__c = 'Vascular',
                Compensation_Profile__c = 'Vascular',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com',
                Manager_Email__c = 'unit.test.manager@unit.teleflex.com',
                Primary_Territory_User_Email__c = 'unit.test@unit.teleflex.com',
                Role__c = 'ASR'                
            );
            tmList.add(tm5);
            insert tmList;
            
            Territory_User__c tu = new Territory_User__c(
                User__c = u.Id,
                Business_Unit__c = 'Surgical Disposables',
                Role__c = 'Sales Rep',
                Territory_Master__c = tm.Id,
                Territory_Number__c = '700123'
            );
            insert tu;
            
            list<Territory_Alignment__c> talist = new list<Territory_Alignment__c>();
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
                Business_Unit__c = 'Surgical Disposables',
                ZPSA_Table__c = 'A659'
            );
            talist.add(tarstate);
            
            
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
                Business_Unit__c = 'Surgical Disposables',
                ZPSA_Table__c = 'A681'
            );
            talist.add(tarsap);
            //insert tarsap;
            
            tarsap = new Territory_Alignment__c(
                Key__c	= '999998-700124',
                SAP_Code__c	= '999998',
                Account_Name__c	= 'Test',
                Territory__c = '700123',
                Territory_Name__c = '700123',
                Territory2__c = '700124',
                Territory_2_Name__c = '700124',
                Territory3__c = '800205',
                Territory_3_Name__c = '800205',
                Territory4__c = '800321',
                Territory_4_Name__c = '800321',
                Business_Unit__c = 'Vascular',
                ZPSA_Table__c = 'A681'
            );
            talist.add(tarsap);
            
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
                Business_Unit__c = 'Surgical Disposables',
                ZPSA_Table__c = 'A626'
            );
            talist.add(tarzip);
            //insert tarzip;
            
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
            talist.add(tarbc);
            //insert tarbc;
            
            insert talist;
            
            Territory_Assignment__c terrAssignment = new Territory_Assignment__c (
                Name = 'NC-700123',
                Account__c = a.id,
                Territory_Alignment__c = tarstate.id,
                Territory__c = tm.Id,
                Territory_Number__c = '700123'
            );
            insert terrAssignment;
            
            //RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='OBJECT_NAME_HERE' AND Name='RECORDTYPE_NAME_HERE' LIMIT 1];

            list<Product2> plist = new list<Product2>();
            
            Product2 prod = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='30', 
                Family = 'Hardware',
                Material__c='AA-10511-1',
                Brand_Name__c='Arrow',
                Buom__c='EA',
                Cost__c=11587.40,
                Cost_Price_Unit__c=1000,
                Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Qty_Sales_Unit__c=5,
                Sales_Unit__c='CS',
                List_Price__c=380.00,
                Rep_Price__c=350.00,
                RSM_Price__c=330.00,
                Material_Key__c = 'AA-10511-1-US30-10',
                Sales_Org_Key__c = 'US103010',
                Sales_Org__c = 'US30',
                Distribution_Channel__c = '10',
                Product_Class__c = '0033',
                Product_Group__c = '00270003',
                Product_Sub_Group__c = '000700010001',
                Product_Line__c = '000700010002000003',
                Class__c = 'Cardiac Care Specialty',
                Group__c  = 'Interventional Access',
                SubGroup__c = 'TransRadial Access',
                Product_Line_Text__c = 'TransRadial Access',
                VPS_Consumable__c = TRUE,
                Valuated_Unrestricted_Use_Stock__c = 10,
                Average_Weekly_Demand__c = 1,
                Surgical_Disposables__c = 'Core'

            );
            plist.add(prod);
            //insert prod;
            
            Product2 prod2 = new Product2(
                Name = 'AA-10511-11',
                Material_Key__c = 'AA-10511-11-US30-11',
                Sales_Org_Key__c = 'US103010',
                Sales_Org__c = 'US30',
                Distribution_Channel__c = '10',
                Product_Class__c = '1',
                Product_Group__c = '2',
                Product_Sub_Group__c = '3',
                Product_Line__c = '4',
                Valuated_Unrestricted_Use_Stock__c = 300,
                Average_Weekly_Demand__c = 3,
                Surgical_Disposables__c = 'Core'
                
            );
            plist.add(prod2);
            //insert prod3;
            
            Product2 prod3 = new Product2(
                Name = 'AA-10511-12',
                Material_Key__c = 'AA-10511-12-US30-12',
                Sales_Org_Key__c = 'US103010',
                Sales_Org__c = 'US30',
                Distribution_Channel__c = '10',
                Product_Class__c = '1',
                Product_Group__c = '2',
                Product_Sub_Group__c = '3',
                Product_Line__c = '4',
                Valuated_Unrestricted_Use_Stock__c = 200,
                Average_Weekly_Demand__c = 2,
                Surgical_Disposables__c = 'Core'
                
            );
            plist.add(prod3);
            //insert prod3;
            
            Product2 prod4 = new Product2(
                Name = 'AA-10511-13',
                Material_Key__c = 'AA-10511-13-US30-13',
                Sales_Org_Key__c = 'US103010',
                Sales_Org__c = 'US30',
                Distribution_Channel__c = '10',
                Product_Class__c = '1',
                Product_Group__c = '2',
                Product_Sub_Group__c = '3',
                Product_Line__c = '4',
                Valuated_Unrestricted_Use_Stock__c = 100,
                Average_Weekly_Demand__c = 3,
                Surgical_Disposables__c = 'Not Applicable'
            );
            plist.add(prod4);
            //insert prod4;
            
            insert plist;
            
            Backorder_Replacement_Matrix__c bpm = new Backorder_Replacement_Matrix__c(
                Product__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Sales_Org__c = 'US30',
                Distribution_Channel__c = '10',
                Alt_Product_1__c = 'AA-10511-11',
                Alt_Product_2__c = 'AA-10511-12',
                Alt_Product_3__c = 'AA-10511-13'
            );
            insert bpm;
            
            New_Product_Tracking__c  newNPT = new New_Product_Tracking__c(
                Name = 'EFx Shield',
                Business_Unit__c = 'Surgical',
                Start_Date__c = Date.today() - 90,
                End_Date__c = Date.today() + 90,
                New_Product_Key__c = 'Surgical-EFx Shield'
            );
            insert newNPT;
            
            New_Product_Tracking_Rule__c newNPTR = new New_Product_Tracking_Rule__c(
                Product__c = 'AA-10511-1',
                Business_Unit__c = 'Surgical',
                Key__c = 'Surgical-AA-10511-1',
                New_Product_Tracking__c = newNPT.Id,
                IsProductSales__c = TRUE,
                IsProductOfInterest__c = TRUE
            );
            insert newNPTR;
            
            List<Sales_by_BU__c> ssbuList = new List<Sales_by_BU__c>();
            Sales_by_BU__c ssbu = new Sales_by_BU__c(
                Account__c = a.Id,
                Business_Unit__c = 'Surgical Disposables',
                Current_YTD__c = 321.00,
                Previous_YTD__c = 123.00,
                Key__c = '100123-Surgical Disposables',
                SAP_Code__c = '100123'
            );
            ssbuList.add(ssbu);
            
            Sales_by_BU__c ssbu2 = new Sales_by_BU__c(
                Account__c = a.Id,
                Business_Unit__c = 'Vascular',
                Current_YTD__c = 321.00,
                Previous_YTD__c = 123.00,
                Key__c = '100123-VAS',
                SAP_Code__c = '100123'
            );
            ssbuList.add(ssbu2);
            insert ssbuList;
            
            Contract_Header__c chTest = new Contract_Header__c(
                Name = '50009064',
                Agreement_Number__c = '50009064',
                Description__c = 'Test Description',
                Owner__c = '123310',
                GPO_Contract_Ref__c = '',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 45
            );
            insert chTest;
            
            Contract_Customer__c ccTest = new Contract_Customer__c(
                Name = '50009064',
                Agreement__c = chTest.Id,
                Account__c = a.Id,
                SAP_Code__c = '102059',
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 45,
                Distribution_Channel__c = '10',
                Condition__c = 'XNAF'
            );
            insert ccTest;
            
            Contract_Material__c cmTest = new Contract_Material__c(
                Name = '50009064',
                Agreement__c = chTest.Id,
                Material_Name__c = 'AA-10511-1',
                Product__c = prod.Id,
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 45,
                Material_Division__c = '10',
                Price__c = 380.00
            );
            insert cmTest;
            
            date salesDate = Date.today();
            date salesDateLY = salesDate.addYears(-1);
            salesDate = salesDate.addMonths(-2);
            
            // Start Specific: Invoiced Sales Helper Class
            Territory_Quota__c tq = new Territory_Quota__c(
                Territory_Number__c = '700123',
                Date__c = salesDate,
                Quota__c = 44915.47
            );
            insert tq;
            
            Business_Days__c bd1 = new Business_Days__c(
                Date__c = Date.today()
            );
            insert bd1;
            
            Compensation_Rules__c cr1 = new Compensation_Rules__c(
                Business_Unit__c = 'Surgical Disposables', 
                Product_Class__c = '0033',
                Key__c = 'Surgical Disposables-0033'
            );
            Compensation_Rules__c cr2 = new Compensation_Rules__c(
                Business_Unit__c = 'Surgical Disposables', 
                Product_Group__c = '00270003',
                Key__c = 'Surgical Disposables-00270003'
            );
            Compensation_Rules__c cr3 = new Compensation_Rules__c(
                Business_Unit__c = 'Surgical Disposables', 
                Product_Sub_Group__c = '000700010001',
                Key__c = 'Surgical Disposables-000700010001'
            );
            Compensation_Rules__c cr4 = new Compensation_Rules__c(
                Business_Unit__c = 'Surgical Disposables', 
                Product_Line__c = '000700010002000003',
                Key__c = 'Surgical Disposables-000700010002000003'
            );
            Compensation_Rules__c cr1a = new Compensation_Rules__c(
                Business_Unit__c = 'Surgical Disposables', 
                Product_Class__c = '0001',
                Key__c = 'Surgical Disposables-0001'
            );
            Compensation_Rules__c cr2a = new Compensation_Rules__c(
                Business_Unit__c = 'Surgical Disposables', 
                Product_Group__c = '00010002',
                Key__c = 'Surgical Disposables-00010002'
            );
            Compensation_Rules__c cr3a = new Compensation_Rules__c(
                Business_Unit__c = 'Surgical Disposables', 
                Product_Sub_Group__c = '00010001003',
                Key__c = 'Surgical Disposables-00010001003'
            );
            Compensation_Rules__c cr4a = new Compensation_Rules__c(
                Business_Unit__c = 'Surgical Disposables', 
                Product_Line__c = '000100010001000004',
                Key__c = 'Surgical Disposables-000100010001000004'
            );

            //Create Invoiced_Sales_Tracking_Class_CS__c custom setting
            Invoiced_Sales_Tracking_Class_CS__c csTest1 = testDataFactoryPP.createCsClass('addShipping', true);
            insert csTest1;
            
            //Create Sample_Request_Line_Item_Class_CS__c custom setting
            //Sample_Request_Line_Item_Class_CS__c csTest2 = testDataFactoryPP.createCsClass1('manuallyLockSampleRequestLineItems', true);
            //insert csTest2;
            
            list<Invoiced_Sales__c> isList = new list<Invoiced_Sales__c>();
            Invoiced_Sales__c is1 = new Invoiced_Sales__c(
                Account__c = a.Id,
                //Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Product__c = prod.Id,
                Sales_Deal__c = chTest.Name,
                Sales_Org__c = 'US10',
                Sales__c = 321.00,
                Date__c = salesDateLY,
                SAP_Code__c = '100123',
                Parent_SAP_Code__c = '100123',
                Territory__c = tm3.Id,
                Territory_Number__c = '700123',
                Maintenance_Key__c = '234'
            );
            isList.add(is1);

            // Testing KAM
            is1 = new Invoiced_Sales__c(
                Account__c = a.Id,
                //Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Product__c = prod.Id,
                Sales_Deal__c = chTest.Name,
                Sales_Org__c = 'US10',
                Sales__c = 321.00,
                Date__c = salesDateLY,
                SAP_Code__c = '999998',
                Territory_Number__c = '700125',
                Maintenance_Key__c = '123',
                Business_Unit__c = 'Vascular'
            );
            isList.add(is1);
            
            Invoiced_Sales__c is_cmr = new Invoiced_Sales__c(
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Sales_Deal__c = '50009064',
                Sales_Org__c = 'US10',
                Sales__c = 321.00,
                Date__c = salesDateLY,
                SAP_Code__c = '10170226',
                Parent_Account_Key__c = '10170226',
                Territory_Number__c = '700123',
                CurrencyIsoCode = 'CAD',
                Maintenance_Key__c = '123'
            );
            //insert is_cmr;
            isList.add(is_cmr);
            list<Invoiced_Sales_Tracking__c> istList = new list<Invoiced_Sales_Tracking__c>();
            
            // UPS #1
            Invoiced_Sales_Tracking__c newIST = new Invoiced_Sales_Tracking__c(
                Sales_Order_Key__c = '111-10-AAA',
                Key__c = 'ABC1',
                Sales_Order_Number__c = '111',
                Sales_Order_Line_Number__c = '10',
                Delivery_Number__c = '8002237856',
                Delivery_Line_Number__c = '10',
                Material_Name__c = 'PT-03000-R',
                Batch_Number__c = '13F18A0233',
                Plant__c = 'US22',
                Quantity_Shipped__c = 3,
                UOM__c = 'EA',
                PO_Number__c = 'PO123',
                Tracking_Number__c = '1Z6069200277798760',
                External_Handling_Unit_Identification__c = '1007014377',
                Ship_Date__c = date.today(),
                Delivery_Priority_2_Digit__c = '06',
                Delivery_Priority__c = 'UPS 2nd Day Air',
                Invoice_Order_Number__c = 'AAA'
            );
            istList.add(newIST);
            
            // UPS #2
            newIST = new Invoiced_Sales_Tracking__c(
                Sales_Order_Key__c = '111-10-AAA',
                Key__c = 'ABC2',
                Sales_Order_Number__c = '111',
                Sales_Order_Line_Number__c = '10',
                Delivery_Number__c = '8002237856',
                Delivery_Line_Number__c = '10',
                Material_Name__c = 'PT-03000-R',
                Batch_Number__c = '13F18A0233',
                Plant__c = 'US22',
                Quantity_Shipped__c = 3,
                UOM__c = 'EA',
                PO_Number__c = 'PO123',
                Tracking_Number__c = '1Z6069200277798761',
                External_Handling_Unit_Identification__c = '1007014377',
                Ship_Date__c = date.today(),
                Delivery_Priority_2_Digit__c = '06',
                Delivery_Priority__c = 'UPS 2nd Day Air',
                Invoice_Order_Number__c = 'AAA'
            );
            istList.add(newIST);
            
            // FedEx #1
            newIST = new Invoiced_Sales_Tracking__c(
                Sales_Order_Key__c = '222-10-BBB',
                Key__c = 'ABC3',
                Sales_Order_Number__c = '222',
                Sales_Order_Line_Number__c = '10',
                Delivery_Number__c = '8002237856',
                Delivery_Line_Number__c = '10',
                Material_Name__c = 'PT-03000-R',
                Batch_Number__c = '13F18A0233',
                Plant__c = 'US22',
                Quantity_Shipped__c = 3,
                UOM__c = 'EA',
                PO_Number__c = 'PO123',
                Tracking_Number__c = '1Z6069200277798762',
                External_Handling_Unit_Identification__c = '1007014377',
                Ship_Date__c = date.today(),
                Delivery_Priority_2_Digit__c = '06',
                Delivery_Priority__c = 'FedEx Ground',
                Invoice_Order_Number__c = 'BBB'
            );
            istList.add(newIST);
            
            // FedEx #2
            newIST = new Invoiced_Sales_Tracking__c(
                Sales_Order_Key__c = '222-10-BBB',
                Key__c = 'ABC4',
                Sales_Order_Number__c = '222',
                Sales_Order_Line_Number__c = '10',
                Delivery_Number__c = '8002237856',
                Delivery_Line_Number__c = '10',
                Material_Name__c = 'PT-03000-R',
                Batch_Number__c = '13F18A0233',
                Plant__c = 'US22',
                Quantity_Shipped__c = 3,
                UOM__c = 'EA',
                PO_Number__c = 'PO123',
                Tracking_Number__c = '1Z6069200277798763',
                External_Handling_Unit_Identification__c = '1007014377',
                Ship_Date__c = date.today(),
                Delivery_Priority_2_Digit__c = '06',
                Delivery_Priority__c = 'FedEx Ground',
                Invoice_Order_Number__c = 'BBB'
            );
            istList.add(newIST);
            
            // AAA Cooper #5
            newIST = new Invoiced_Sales_Tracking__c(
                Sales_Order_Key__c = '222-10-BBB',
                Key__c = 'ABC5',
                Sales_Order_Number__c = '222',
                Sales_Order_Line_Number__c = '10',
                Tracking_Number__c = '1Z6069200277798764',
                Ship_Date__c = date.today(),
                Delivery_Priority__c = 'AAA Cooper',
                Invoice_Order_Number__c = 'BBB'
            );
            istList.add(newIST);
            
            // Air Freight #6
            newIST = new Invoiced_Sales_Tracking__c(
                Sales_Order_Key__c = '222-10-BBB',
                Key__c = 'ABC6',
                Sales_Order_Number__c = '222',
                Sales_Order_Line_Number__c = '10',
                Tracking_Number__c = '1Z6069200277798765',
                Ship_Date__c = date.today(),
                Delivery_Priority__c = 'Air Freight',
                Invoice_Order_Number__c = 'BBB'
            );
            istList.add(newIST);
            
            // Road Runner #1
            newIST = new Invoiced_Sales_Tracking__c(
                Sales_Order_Key__c = '222-10-BBB',
                Key__c = 'ABC7',
                Sales_Order_Number__c = '222',
                Sales_Order_Line_Number__c = '10',
                Tracking_Number__c = '1Z6069200277798766',
                Ship_Date__c = date.today(),
                Delivery_Priority__c = 'Road Runner',
                Invoice_Order_Number__c = 'BBB'
            );
            istList.add(newIST);
            
            // Sea Freight #1
            newIST = new Invoiced_Sales_Tracking__c(
                Sales_Order_Key__c = '222-10-BBB',
                Key__c = 'ABC8',
                Sales_Order_Number__c = '222',
                Sales_Order_Line_Number__c = '10',
                Tracking_Number__c = '1Z6069200277798767',
                Ship_Date__c = date.today(),
                Delivery_Priority__c = 'Sea Freight',
                Invoice_Order_Number__c = 'BBB'
            );
			istList.add(newIST);
            
            // Purolator #1
            newIST = new Invoiced_Sales_Tracking__c(
                Sales_Order_Key__c = '222-10-BBB',
                Key__c = 'ABC9',
                Sales_Order_Number__c = '222',
                Sales_Order_Line_Number__c = '10',
                Tracking_Number__c = '1Z6069200277798799',
                Ship_Date__c = date.today(),
                Delivery_Priority__c = 'Purolator',
                Invoice_Order_Number__c = 'BBB'
            );
            istList.add(newIST);
            
            // YRC Freight #1
            newIST = new Invoiced_Sales_Tracking__c(
                Sales_Order_Key__c = '222-10-BBB',
                Key__c = 'ABC10',
                Sales_Order_Number__c = '222',
                Sales_Order_Line_Number__c = '10',
                Tracking_Number__c = '1Z6069200277798769',
                Ship_Date__c = date.today(),
                Delivery_Priority__c = 'YRC Freight',
                Invoice_Order_Number__c = 'BBB'
            );
            istList.add(newIST);
            
            insert istList;
            
            /*Open_Orders__c oo_cmr = new Open_Orders__c(
                SAP_Code__c = '10170226',
                Account__c = ,
                
                Territory_Number__c = '700123',
                Order_Number__c = '3139447',
                Line_Item_Number__c = '10',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Product_Class__c = '0033',
                Order_Date__c = salesDate,
                Scheduled_Ship_Date__c = salesDate
            );
            insert oo_cmr;*/
            
            Invoiced_Sales__c is2 = new Invoiced_Sales__c(
                Account__c = a.Id,
                Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Product__c = prod.Id,
                Sales_Deal__c = chTest.Name,
                Sales_Org__c = 'US10',
                Sales__c = 321.00,
                Date__c = salesDate,
                SAP_Code__c = '100123',
                Territory__c = tm.Id,
                Territory_Number__c = '700123',
                Maintenance_Key__c = '123'
            );
            //insert is2;
            isList.add(is2);
            insert isList;
                        
            Sales_Accounts__c salesAcct = new Sales_Accounts__c(
                Account__c = a.Id,
                Key__c = a.Id + '-' + tm.Id,
                Sales_YTD__c = 200,
                Sales_PYTD__c = 100,
                Territory__c = tm.Id,
                Last_Order_Date__c = salesDate
            );
            insert salesAcct;
			
        }//end system.runas
        Test.stopTest();
    }
    
    /*@isTest static void testBatchClass() {
        Test.startTest();

        Open_Orders_Maintenance_Batch ismb = new Open_Orders_Maintenance_Batch();
        Database.executeBatch(ismb);
        
        Test.stopTest();
    }*/
    
    @isTest static void testCompPOC() {
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/compensation_Export?id=Surgical_Disposables__c');
        Test.setCurrentPage(pageRef);
        
        compensation_POC cPOC = new compensation_POC();
        cPOC.refreshing();
        Invoiced_Sales_Helper_Class.randomKey();
        Invoiced_Sales_Helper_Class check = new Invoiced_Sales_Helper_Class();
        string mKey = check.getMaintenanceKey('Invoiced_Sales_Detail__c');
        Test.stopTest();
    }
    
    @isTest static void testCompRules() {
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/compensation_Rules?id=Surgical_Disposables__c');
        Test.setCurrentPage(pageRef);
        
        compensation_Rules cRules = new compensation_Rules();
        cRules.save();
        cRules.refreshing();
        Test.stopTest();
    }
    
    @isTest static void testVFPages() {
        
        Test.startTest();
        
        // Sales Accounts - Main Page
        PageReference pageRef = new PageReference('/apex/sales_Accounts?id=700123');
        Test.setCurrentPage(pageRef);
        //System.currentPageReference().getParameters().put('redir', TRUE);
        
        sales_Accounts newSA = new sales_Accounts();
        newSA.redir = TRUE;
        newSA.redirect();
        string newSA_lastYear = newSA.lastYear;
        string newSA_thisYear = newSA.thisYear;
      
        pageRef = new PageReference('/apex/sales_Accounts');
        Test.setCurrentPage(pageRef);
        newSA = new sales_Accounts();
        
        string tid = [SELECT Id FROM Territory_Master__c WHERE Territory_Number__c = '700123'].Id;
        string aid = [SELECT Id FROM Account WHERE SAP_Sold_To__c = '100123'].Id;
        
        
        // sales_Accounts_Detail
        pageRef = new PageReference('/apex/sales_Accounts_Detail?id=' + tid + '&aid=' + aid);
        Test.setCurrentPage(pageRef);
        
        sales_Accounts_Detail sad = new sales_Accounts_Detail();
        
        Test.stopTest();

    }
    
    @isTest static void testVFPages2() {
        
        Test.startTest();

        // Sales Rosters
        PageReference pageRef = new PageReference('/apex/sales_Rosters');
        Test.setCurrentPage(pageRef);
        
        sales_Rosters saro = new sales_Rosters();
        
        pageRef = new PageReference('/apex/sales_Rosters?bu=Surgical%20Disposables');
        Test.setCurrentPage(pageRef);
        
        saro = new sales_Rosters();
        
        Test.stopTest();
    }
    
    @isTest static void testVFPages3() {
        
        Test.startTest();
        
        string tid = [SELECT Id FROM Territory_Master__c WHERE Territory_Number__c = '700123'].Id;
        string aid = [SELECT Id FROM Account WHERE SAP_Sold_To__c = '100123'].Id;

        //open_Orders
        PageReference pageRef = new PageReference('/apex/open_Orders?id=' + tid + '&aid=' + aid);
        Test.setCurrentPage(pageRef);
        
        open_Orders openOrders = new open_Orders();
        
        pageRef = new PageReference('/apex/open_Orders?id=' + tid);
        Test.setCurrentPage(pageRef);
        
        openOrders = new open_Orders();
        
        pageRef = new PageReference('/apex/open_Orders');
        Test.setCurrentPage(pageRef);
        
        openOrders = new open_Orders();
        
        Test.stopTest();
                
    }
    
    @isTest static void testRecentSalesOrders() {
        Test.startTest();
        string tid = [SELECT Id FROM Territory_Master__c WHERE Territory_Number__c = '700123'].Id;
        string aid = [SELECT Id FROM Account WHERE SAP_Sold_To__c = '100123'].Id;

        // Recent_Sales_Orders
        PageReference pageRef = new PageReference('/apex/Recent_Sales_Orders?id=' + tid + '&aid=' + aid);
        Test.setCurrentPage(pageRef);
        
        Recent_Sales_Orders rso = new Recent_Sales_Orders();
        
        pageRef = new PageReference('/apex/Recent_Sales_Orders?id=' + tid);
        Test.setCurrentPage(pageRef);
        
        rso = new Recent_Sales_Orders();
        Test.stopTest();
    }
    
    // Start Contract Renewal Build batch and scheduler classes
    @isTest static void testScheduleClasses() {
        
        Test.startTest();
        String CRON_EXP = '0 0 0 15 3 ? 2030';
        String jobId;
        String jobId2;
        String jobId3;
        String jobId4;
        String jobId5;
        String jobId6;
        
        jobId = System.schedule('Build_Contract_Renewals_Scheduler', CRON_EXP, new Build_Contract_Renewals_Scheduler());
        jobId2 = System.schedule('territory_Quota_Maintenance_Scheduler', CRON_EXP, new territory_Quota_Maintenance_Scheduler());
        jobId3 = System.schedule('Open_Orders_Maintenance_Scheduler', CRON_EXP, new Open_Orders_Maintenance_Scheduler());
        jobId4 = System.schedule('Build_Open_Order_Summary_Schedule', CRON_EXP, new Build_Open_Order_Summary_Schedule());
        jobId5 = System.schedule('PP_Daily_Cleanup', CRON_EXP, new PP_Daily_Cleanup());
        jobId6 = System.schedule('Invoice_Daily_Cleanup', CRON_EXP, new Invoice_Daily_Cleanup());
        Test.stopTest();
    } 
    
      @isTest static void testBackupAlternatives(){
       
        date salesDate = Date.today();
        date salesDateLY = salesDate.addYears(-1);
        salesDate = salesDate.addMonths(-2);
        List<Account> acc = [SELECT Id FROM Account WHERE Name = 'Test PP Account'];
        List<Product2> prod = [SELECT Id FROM Product2 WHERE Name IN ('AA-10511-1', 'AA-10511-13') ];
        
       //Test data for Open Orders
        list<Open_Orders__c> oList = new list<Open_Orders__c>();
            Open_Orders__c openOrder = new Open_Orders__c(
                Account__c = acc[0].Id,
                Territory_Number__c = '700123',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Order_Number__c = '3139447',
                Business_Unit__c='Surgical Disposables',
                Line_Item_Number__c = '10',
                Product__c = prod[0].Id,
                Product_Class__c = '0033',
                Order_Date__c = salesDate,
                Scheduled_Ship_Date__c = salesDate,
                Maintenance_Key__c = '123',
                PO_Number__c = 'abc123',
                Open_Order_Qty__c = 3,
                Open_Order_Total__c = 123
            );
            oList.add(openOrder);
      
            
            Open_Orders__c openOrder2 = new Open_Orders__c(
                Account__c = acc[0].Id,
                Territory_Number__c = '700123',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Order_Number__c = '3139446',
                Business_Unit__c='Surgical Disposables',
                Line_Item_Number__c = '10',
                Product__c = prod[0].Id,
                Product_Class__c = '0033',
                Order_Date__c = salesDate,
                SAP_Code__c = '10170226',
                Parent_Account_Key__c = '10170226',
                Scheduled_Ship_Date__c = salesDate,
                Maintenance_Key__c = '234',
                PO_Number__c = 'abc123',
                Open_Order_Qty__c = 3,
                Open_Order_Total__c = 123
            );
            oList.add(openOrder2);
     
            insert oList;
            
        Test.startTest();
        Invoiced_Sales_Helper_Class.backupAlternatives(oList);
        List<Open_Orders__c> updatedRecords =[SELECT Sub_1__c,Sub_1_Stock__c,Sub_1_Status__c, Subs_1_Product_on_Hand__c, Material_Key__c FROM Open_Orders__c WHERE Id IN:oList];
      for(Open_Orders__c opOrder :updatedRecords){
          System.debug('Sub_1 ' +opOrder.Sub_1__c+' Sub_1_Stock__c '+opOrder.Sub_1_Stock__c+' Sub_1_Status__c '+opOrder.Sub_1_Status__c+' Subs_1_Product_on_Hand__c '+opOrder.Subs_1_Product_on_Hand__c);
      }
      
                  
     System.debug('Printing updatedRecords '+updatedRecords);
        Test.stopTest();
        
    }
     @isTest static void testAddShipping(){
         date salesDate = Date.today();
        date salesDateLY = salesDate.addYears(-1);
        salesDate = salesDate.addMonths(-2);
        List<Account> acc = [SELECT Id, Name FROM Account WHERE Name = 'Test PP Account'];
        List<Product2> prod = [SELECT Id, Name FROM Product2 WHERE Name IN ('AA-10511-1', 'AA-10511-13') ];
          Contract_Header__c chTest = new Contract_Header__c(
                Name = '50009064',
                Agreement_Number__c = '50009064',
                Description__c = 'Test Description',
                Owner__c = '123310',
                GPO_Contract_Ref__c = '',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 45
            );
            insert chTest;  
          list<Invoiced_Sales_Detail__c> isdList = new list<Invoiced_Sales_Detail__c>();
            Invoiced_Sales_Detail__c isd_cmr = new Invoiced_Sales_Detail__c(
                Account__c = acc[0].Id,
                Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1a',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Sales_Deal__c = chTest.Name,
                Sales_Org__c = 'US10',
                Sales__c = 321.00,
                Sales_Order_Key__c='111-10-AAA',
                Date__c = salesDateLY,
                SAP_Code__c = '10170226',
                Parent_Account_Key__c = '10170226',
                Territory_Number__c = '700123',
                Commissionable_Date__c = salesDate,
                Order_Number__c = '3139447',
                Line_Item_Number__c = 10,
                Maintenance_Key__c = '123',
                Invoice_Order_Number__c = 'AAA',
                Sales_Order_Number__c = '111'
            );
            isdList.add(isd_cmr);
         insert isdList;
          //inserting custom setting for Invoiced Sales Tracking Class
        Invoiced_Sales_Tracking_Class_CS__c  customSettingIstClass =new Invoiced_Sales_Tracking_Class_CS__c();
        customSettingIstClass.Execute__c=true;
        customSettingIstClass.Name='addShipping';
        insert customSettingIstClass;
      
      //inserting Invoice Sales Tracking related to Invoiced Detail
      list<Invoiced_Sales_Tracking__c> invSalesTrackList=new list<Invoiced_Sales_Tracking__c>();
     Invoiced_Sales_Tracking__c invSalesTrack1= new Invoiced_Sales_Tracking__c(
         Key__c=isd_cmr.Id,
      Sales_Order_Key__c='111-10-AAA',
      Tracking_Number__c='1Z6069230376727116',
      Delivery_Priority__c='UPS');
      invSalesTrackList.add(invSalesTrack1);
       insert invSalesTrackList;
      
      //Inserting Invoiced Sales
       List<Invoiced_Sales__c> listSObject=new List<Invoiced_Sales__c>();
       Invoiced_Sales__c invSales1 = new Invoiced_Sales__c(
                Distribution_Channel__c = '10',
                Material_Name__c = '5571',
                Material_Key__c = '5571-US60-10',
                Sales_Org__c = 'US60',
                Date__c =date.today() ,
                CurrencyIsoCode = 'USD',
                 Product_Class__c = '0030',
                Product_Group__c = '00300011',
                Product_Sub_Group__c = '003000110002',
                Product_Line__c = '003000110002000001'
            );
        
        listSObject.add(invSales1);
        insert listSObject;
  
        
        Test.startTest();
             
        
       List<Invoiced_Sales_Detail__c> invSalesDetList = [SELECT Id, Account__c,Business_Unit__c, Distribution_Channel__c, Key__c,
                                                  Material_Name__c, Material_Key__c, Product__c, Sales_Deal__c, Sales_Org__c, 
                                                  Sales__c, Date__c, Territory_Number__c, Sales_Order_Key__c
                                                  FROM Invoiced_Sales_Detail__c WHERE Sales_Order_Key__c='111-10-AAA'
                                                  ];
            
        System.debug('size of the list '+invSalesDetList.size());
        System.debug('***Printing isdlist*** queried Invoice detail '+invSalesDetList);
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
       List<Invoiced_Sales_Tracking__c> trackingUPS=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
        //Fedex scenario
        List<Invoiced_Sales_Tracking__c> updateToFedex=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackFed:trackingUPS){
            if(trackFed.Delivery_Priority__c!=NULL){
               trackFed.Delivery_Priority__c='Fed';
            }
           updateToFedex.add(trackFed);
        }
        update updateToFedex;
         
       
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Fedex tracking records*** '+updateToFedex);
       
        //Purolator scenario
        List<Invoiced_Sales_Tracking__c> trackingPur=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
        List<Invoiced_Sales_Tracking__c> updateToPur=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackPur:trackingPur){
            if(trackPur.Delivery_Priority__c!=NULL){
                trackPur.Delivery_Priority__c='Pur';
            }
            updateToPur.add(trackPur);
        }
        update updateToPur;
        
      
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Puralator tracking records*** '+updateToPur);
       
        //YRC Freight scenario
        List<Invoiced_Sales_Tracking__c> trackingYRC=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
        List<Invoiced_Sales_Tracking__c> updateToYRC=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackYRC:trackingYRC){
            if(trackYRC.Delivery_Priority__c!=NULL){
                trackYRC.Delivery_Priority__c='YRC';
            }
            updateToYRC.add(trackYRC);
        }
        update updateToYRC;
        
       Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
       System.debug('***Printing YRC Freight tracking records*** '+updateToYRC);

       
        
        //AAA Cooper
          List<Invoiced_Sales_Tracking__c> trackingAAA=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
        List<Invoiced_Sales_Tracking__c> updateToAAA=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackAAA:trackingAAA){
            if(trackAAA.Delivery_Priority__c!=NULL){
                trackAAA.Delivery_Priority__c='AAA';
            }
            updateToAAA.add(trackAAA);
        }
        update updateToAAA;
        
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing AAA cooper tracking records*** '+updateToAAA);
        
        //Air Freight
        List<Invoiced_Sales_Tracking__c> trackingAir=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
         List<Invoiced_Sales_Tracking__c> updateToAir=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackAir:trackingAir){
            if(trackAir.Delivery_Priority__c!=NULL){
                trackAir.Delivery_Priority__c='Air';
            }
            updateToAAA.add(trackAir);
        }
        update updateToAir;
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Air Freight tracking records*** '+updateToAir);

        //Roa Runner
        List<Invoiced_Sales_Tracking__c> trackingRoa=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
         List<Invoiced_Sales_Tracking__c> updateToRoa=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackRoa:trackingRoa){
            if(trackRoa.Delivery_Priority__c!=NULL){
                trackRoa.Delivery_Priority__c='Roa';
            }
            updateToRoa.add(trackRoa);
        }
        update updateToRoa;
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Roa Runner tracking records*** '+updateToRoa);
        
        //Sea Freight
        List<Invoiced_Sales_Tracking__c> trackingSea=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
         List<Invoiced_Sales_Tracking__c> updateToSea=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackSea:trackingSea){
            if(trackSea.Delivery_Priority__c!=NULL){
                trackSea.Delivery_Priority__c='Sea';
            }
            updateToSea.add(trackSea);
        }
        update updateToSea;
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Sea Freight tracking records*** '+updateToSea);
        
       //Old Dominion
        List<Invoiced_Sales_Tracking__c> trackingOld=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
         List<Invoiced_Sales_Tracking__c> updateToOld=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackOld:trackingOld){
            if(trackOld.Delivery_Priority__c!=NULL){
                trackOld.Delivery_Priority__c='Old';
            }
            updateToOld.add(trackOld);
        }
        update updateToOld;
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Old Dominion tracking records*** '+updateToOld);
        
        //Holland
         List<Invoiced_Sales_Tracking__c> trackingHol=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
         List<Invoiced_Sales_Tracking__c> updateToHol=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackHol:trackingHol){
            if(trackHol.Delivery_Priority__c!=NULL){
                trackHol.Delivery_Priority__c='Hol';
            }
            updateToHol.add(trackHol);
        }
        update updateToHol;
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Holland tracking records*** '+updateToHol);
        
        Test.stopTest();
    }
    
   @isTest static void testCheckProduct(){
        //Test data for the Sobject
       List<Invoiced_Sales__c> listInvSales=[SELECT  Material_Key__c, Material_Name__c, CurrencyIsoCode, Product__c 
                                              FROM Invoiced_Sales__c 
                                              WHERE Material_Name__c='5571' ];
            
        Test.startTest();
        Invoiced_Sales_Helper_Class.checkProduct(listInvSales);
        
        Test.stopTest();
        
        
        
    }
    
    @isTest static void testCurrency(){
        
        List<Invoiced_Sales__c> listInvSales1=[SELECT  Material_Key__c, Material_Name__c, CurrencyIsoCode 
                                              FROM Invoiced_Sales__c 
                                              WHERE Material_Name__c='5571' ];
        List<Invoiced_Sales__c> updateCurrency=new List<Invoiced_Sales__c> ();
        for(Invoiced_Sales__c invSale:listInvSales1){
            if(invSale.CurrencyIsoCode!=null){
                invSale.CurrencyIsoCode='AUD';
            }
            updateCurrency.add(invSale);
        }
        update updateCurrency;
        
         List<Invoiced_Sales__c> updateToAUD=[SELECT  Material_Key__c, Material_Name__c, CurrencyIsoCode 
                                              FROM Invoiced_Sales__c 
                                              WHERE Material_Name__c='5571' ];
        Invoiced_Sales_Helper_Class.currencyReset(updateToAUD);
        System.debug('Printing NZD currency List '+updateToAUD);
        
        List<Invoiced_Sales__c> updateNZD=new List<Invoiced_Sales__c> ();
        for(Invoiced_Sales__c invSale:listInvSales1){
            if(invSale.CurrencyIsoCode!=null){
                invSale.CurrencyIsoCode='NZD';
            }
            updateNZD.add(invSale);
        }
        update updateNZD;
        List<Invoiced_Sales__c> updateToNZD=[SELECT  Material_Key__c, Material_Name__c, CurrencyIsoCode 
                                              FROM Invoiced_Sales__c 
                                              WHERE Material_Name__c='5571' ];
        Invoiced_Sales_Helper_Class.currencyReset(updateToNZD);
        System.debug('Printing NZD currency List '+updateToNZD);
    }

	
    
}//end of class