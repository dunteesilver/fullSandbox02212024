@isTest
public class account_Page_Helper_Test {
    
    @testSetup static void dataSetup(){
        Profile p = [select id from profile where name='System Administrator'];
        
        Business_Unit__c SURG = new Business_Unit__c(
            Name = 'Surgical',
            Key__c = 'SURG',
            Active__c = TRUE
        );
        insert SURG;
        
        User u = new User(
            alias = 'uflex76', 
            email='unit.test@unit1.teleflex.com',
            emailencodingkey='UTF-8', 
            firstname='Adam',
            lastname='Franks', 
            languagelocalekey='en_US',
            localesidkey='en_GB', 
            profileid = p.Id,
            timezonesidkey='Europe/London', 
            username='unit.test@unit.teleflex.com',
            Business_Unit__c = 'Surgical'
        );
        insert u;
        
        List<Quick_Disable__c> qds = new List<Quick_Disable__c>();
        // Disable all the Territory Triggers, we don't want those firing during the test.
        Quick_Disable__c cs = new Quick_Disable__c(
            Name = 'addAccountShares',
            Enable__c = FALSE
        );
        System.debug('insert cs-->' + cs);
        qds.add(cs);
        
        Quick_Disable__c cs2 = new Quick_Disable__c(
            Name = 'addAccountShares_legacy',
            Enable__c = FALSE
        );
        System.debug('insert cs2-->' + cs2);
        qds.add(cs2);
        
        Quick_Disable__c cs3 = new Quick_Disable__c(
            Name = 'territory_Account_Alignment',
            Enable__c = FALSE
        );
        System.debug('insert cs3-->' + cs3);
        qds.add(cs3);        
        
        Quick_Disable__c cs4 = new Quick_Disable__c(
            Name = 'Territory_Automation_After',
            Enable__c = FALSE
        );
        System.debug('insert cs4-->' + cs4);
        qds.add(cs4);
        
        Quick_Disable__c cs5 = new Quick_Disable__c(
            Name = 'Territory_Automation_Before',
            Enable__c = FALSE
        );
        System.debug('insert cs5-->' + cs5);
        qds.add(cs5);
        
        Quick_Disable__c cs6 = new Quick_Disable__c(
            Name = 'territory_user_maintenance',
            Enable__c = FALSE
        );
        System.debug('insert cs6-->' + cs6);
        qds.add(cs6);
        insert qds;
        
        BaseQuotaException__c bqe = new BaseQuotaException__c(
            Name = 'territory_user_maintenance',
            IsException__c = TRUE
        );
        insert bqe;
        
        System.runAs(u){
            
            Account a = new Account(
                Name = 'Test PP Account', 
                SAP_Sold_To__c ='100123', 
                ShippingStreet='123 Main Street ', 
                ShippingCity='Raleigh',
                ShippingState='NC', 
                ShippingPostalCode='27614',
                Customer_Group__c = '19',
                zBlock__c = 'Z1',
                Account_Group__c = 'Z001',
                ERP_Active__c = FALSE,
                Territory_Key__c = '700123',
                Sales_by_BU_Key__c='ALTC'
            );
            master_TriggerHelperClass.runOnce('resetOnceSet');
            insert a;
            
            Customer_Master_Reference__c  cmr = new Customer_Master_Reference__c (
                Name = 'Test PP Account', 
                SAP_Code__c = '100123', 
                Street__c = '123 Main Street ', 
                City__c = 'Raleigh',
                State__c = 'NC', 
                Zip_Code__c = '27614',
                Customer_Group__c = '19',
                zBlock__c = '00',
                Account_Group__c = 'Z001'
            );            
            insert cmr;
            
            Account a2 = new Account(
                Name = 'Test PP Account2', 
                SAP_Sold_To__c ='100553', 
                ShippingStreet='1234 Main Street ', 
                ShippingCity='Raleigh',
                ShippingState='NC', 
                ShippingPostalCode='27613',
                Customer_Group__c = '19',
                Sales_by_BU_Key__c = '123',
                zBlock__c = '01',
                Account_Group__c = 'Z002',
                ERP_Active__c = TRUE,
                Territory_Key__c = '700123'
            
                
            );
            master_TriggerHelperClass.runOnce('resetOnceSet');
            insert a2;
            
            List<Contact> conts = new List<Contact>();
            Contact c = new Contact(
                FirstName ='Test',
                LastName = 'Test',
                AccountId = a.Id,
                email = 'abc@123.com',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                Business_Unit1__c = 'Surgical Disposables'
            );
            conts.add(c);
            
            Contact c2 = new Contact(
                FirstName ='Test2',
                LastName = 'Test2',
                AccountId = a.Id,
                email = 'abc@1234.com',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                Business_Unit1__c = 'Anesthesia'
            );
            conts.add(c2);
            insert conts;
            
            c2.Business_Unit1__c = 'EMS';
            update c2;
            
            New_Product_Tracking__c  newNPT = new New_Product_Tracking__c(
                Name = 'EFx Shield',
                Activity_Task_Type__c = 'EFx Shield',
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
            
            // Product_Tracking_Helper_Class
            Product_Tracking__c pt = new Product_Tracking__c (
                SAP_Code__c = '100553',
                //Business_Unit_GPL__c = 'EMS',
                Name = 'Test 000111',
                Product_Family__c = 'Airway',
                Product_of_Interest__c = 'Airtraq;DispoGrip'
            );
            insert pt;
            
            Territory_Master__c tm = new Territory_Master__c(
                Name = '700123',
                Territory_Number__c = '700123',
                Business_Unit__c = 'Surgical Disposables',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com'
            );
            insert tm;
            System.debug('Insert Territory Master-->' + tm);
            
            Territory_User__c tu = new Territory_User__c(
                User__c = u.Id,
                Business_Unit__c = 'Surgical Disposables',
                Role__c = 'Sales Rep',
                Territory_Master__c = tm.Id,
                Territory_Number__c = '700123'
            );
            insert tu;
            
            List<Territory_Alignment__c> tas = new List<Territory_Alignment__c>();
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
            tas.add(tarstate);
            
            Territory_Alignment__c tarsap = new Territory_Alignment__c(
                Key__c  = '999999-700123',
                SAP_Code__c = '999999',
                Account_Name__c = 'Test',
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
            tas.add(tarsap);
            
            Territory_Alignment__c tarzip = new Territory_Alignment__c(
                Key__c  = '27614-700123',
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
            tas.add(tarzip);
            
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
            tas.add(tarbc);
            insert tas;
            
            Territory_Assignment__c terrAssignment = new Territory_Assignment__c (
                Name = 'NC-700123',
                Account__c = a.id,
                Territory_Alignment__c = tarstate.id,
                Territory__c = tm.Id,
                Territory_Number__c = '700123'
            );
            insert terrAssignment;
            
            //RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='OBJECT_NAME_HERE' AND Name='RECORDTYPE_NAME_HERE' LIMIT 1];
            
            
            Business_Unit__c bu = new Business_Unit__c(
                Name = 'Surgical Disposables',
                Active__c = TRUE,
                Page__c = 'account',
                Key__c = 'SDIS'
            );
            insert bu;
            
            Business_Unit__c bu2 = new Business_Unit__c(
                Name = 'Anesthesia',
                Active__c = TRUE,
                Page__c = 'account',
                Key__c = 'ANES'
            );
            insert bu2;
            
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
                Class__c='Cardiac Care Specialty',
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
                Sales_Org__c = 'US10',
                Distribution_Channel__c = '10',
                Product_Class__c = '0033',
                Product_Group__c = '00270003',
                Product_Sub_Group__c = '000700010001',
                Product_Line__c = '000700010002000003',
                VPS_Consumable__c = TRUE
            );
            insert prod;
            
            Product2 prod2 = new Product2(
                Name = 'AA-10511-2',
                ProductCode= 'AA-10511-2',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='30', 
                Family = 'Hardware',
                Material__c='AA-10511-2',
                Brand_Name__c='Arrow',
                Buom__c='EA',
                Class__c='Cardiac Care Specialty',
                Cost__c=11587.40,
                Cost_Price_Unit__c=1000,
                Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Qty_Sales_Unit__c=5,
                Sales_Unit__c='CS',
                List_Price__c=380.00,
                Rep_Price__c=350.00,
                RSM_Price__c=330.00,
                Material_Key__c = 'AA-10511-2-US30-10',
                Sales_Org_Key__c = 'US103010',
                Sales_Org__c = 'US10',
                Distribution_Channel__c = '10',
                Product_Class__c = '0033',
                Product_Group__c = '00270003',
                Product_Sub_Group__c = '000700010001',
                Product_Line__c = '000700010002000003',
                Heater_Consumables__c = TRUE 
            );
            insert prod2;
            
            Sales_by_BU__c ssbu = new Sales_by_BU__c(
                Account__c = a.Id,
                Business_Unit__c = 'Surgical Disposables',
                Current_YTD__c = 321.00,
                Previous_YTD__c = 123.00,
                Key__c = '100123-Surgical Disposables',
                SAP_Code__c = '100123'
            );
            insert ssbu;
            
            Sales_by_BU__c ssbu2 = new Sales_by_BU__c(
                Account__c = a.Id,
                Business_Unit__c = 'Vascular',
                Current_YTD__c = 321.00,
                Previous_YTD__c = 123.00,
                Key__c = '100123-VAS',
                SAP_Code__c = '100123'
            );
            insert ssbu2;
            
            Contract_Header__c chTest = new Contract_Header__c(
                Name = '50009064',
                Agreement_Number__c = '50009064',
                Description__c = 'Test Description',
                Owner__c = '123310',
                GPO_Contract_Ref__c = '',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000
            );
            insert chTest;
            
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
            
            
            
            
            Sales_by_Product__c ssp = new Sales_by_Product__c(
                Account__c = a.Id,
                Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Product__c = prod.Id,
                Sales_Org__c = 'US10',
                Sales_Prior_Year__c = 123.00,
                Sales_YTD__c = 321.00,
                Sales__c = 321.00,
                Date__c = salesDateLY,
                SAP_Code__c = '100123',
                Territory__c = tm.Id,
                Territory_Number__c = '700123'
            );
            insert ssp;
            Sales_by_Product__c ssp2 = new Sales_by_Product__c(
                Account__c = a.Id,
                Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Product__c = prod.Id,
                Sales_Org__c = 'US10',
                Sales_Prior_Year__c = 123.00,
                Sales_YTD__c = 321.00,
                Sales__c = 321.00,
                Date__c = salesDate,
                SAP_Code__c = '100123',
                Territory__c = tm.Id,
                Territory_Number__c = '700123'
            );
            insert ssp2;
            List<Invoiced_Sales__c> invSales = new List<Invoiced_Sales__c>();
            Invoiced_Sales__c is1 = new Invoiced_Sales__c(
                Account__c = a.Id,
                Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Product__c = prod.Id,
                Sales_Deal__c = chTest.Name,
                Sales_Org__c = 'US10',
                Sales__c = 321.00,
                Date__c = salesDateLY,
                SAP_Code__c = '100123',
                Territory__c = tm.Id,
                Territory_Number__c = '700123',
                OwnerId= u.Id
            );
            invSales.add(is1);
            
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
                OwnerId= u.Id
            );
            invSales.add(is2);
            
            Invoiced_Sales__c is3 = new Invoiced_Sales__c(
                Account__c = a.Id,
                Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Product__c = prod2.Id,
                Sales_Deal__c = chTest.Name,
                Sales_Org__c = 'US10',
                Sales__c = 321.00,
                Date__c = salesDate,
                SAP_Code__c = '100123',
                Territory__c = tm.Id,
                Territory_Number__c = '700123',
                OwnerId= u.Id
            );
            invSales.add(is3);
            insert invSales;
            
        
            
            
     
      
        Test.startTest();
        account_Active_Sales_Batch acct = new  account_Active_Sales_Batch ();
        database.executebatch(acct,100);
        String sch='0 0 0 ? * * *';
        //String jobId = System.schedule('account_Active_Sales_Batch', sch , acct);
        //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        //System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        List<Account> acc = [SELECT Id, SAP_Sold_To__c, Sales_by_BU_Key__c, Territory_Key__c FROM Account Where SAP_Sold_To__c != NULL];
       // system.assertEquals(16, acc.size());
        
            
    
            
            // Start VPS Consumable Testing
            Date ValidFromDate = Date.today();
            Date ValidToDate = ValidFromDate.addYears(2);
            
            map<String, Id> recTypeMap = new map<String, Id>();
            for(RecordType RT : [SELECT Id,DeveloperName 
                                 FROM RecordType 
                                 WHERE SobjectType = 'VPS__c'])
            {
                recTypeMap.put(RT.DeveloperName, RT.Id);
            }
            
            VPS__c vps = new VPS__c(
                Name = 'Test VPS',
                Account__c = a.Id,
                Lease_Contract__c = '123',
                Loaner_Start_Date__c = ValidFromDate,
                Loaner_Expiration_Date__c = ValidToDate,
                Total_of_Units__c = '1',
                Sales_Rep__c = UserInfo.getUserId(),
                Active__c = TRUE
            );
            if(recTypeMap.containsKey('Heater_Contracts')){
                vps.RecordTypeId = recTypeMap.get('Heater_Contracts');
            }
            insert vps;
            
            VPS__c vps2 = new VPS__c(
                Name = 'Test VPS2',
                Account__c = a.Id,
                Lease_Contract__c = '1234',
                Loaner_Start_Date__c = ValidFromDate,
                Loaner_Expiration_Date__c = ValidToDate,
                Total_of_Units__c = '1',
                Sales_Rep__c = UserInfo.getUserId(),
                Active__c = TRUE
            );
            if(recTypeMap.containsKey('VPS_Contracts')){
                vps2.RecordTypeId = recTypeMap.get('VPS_Contracts');
            }
            insert vps2;
            
            //Start Business_Metrics__c
            Business_Metrics__c BMX = new Business_Metrics__c(
                Name = 'Account Sales',
                Section__c = 'Leads',
                Business_Unit__c = 'Surgical',
                Sorting_Order__c = 1,
                Report_Label_Name__c = '123',
                Type__c = 'Report',
                Business_Unit_Key__c = 'All'
            );
            insert BMX;
            
            Business_Metrics__c BMX2 = new Business_Metrics__c(
                Name = 'Account Sales',
                Section__c = 'Leads',
                Business_Unit__c = 'Surgical',
                Sorting_Order__c = 1,
                Report_Label_Name__c = '123',
                Type__c = 'Report',
                Business_Unit_Key__c = 'All'
            );
            insert BMX2;
            
            list<Task> newTasks = new list<Task>();
            
            // Task Test Class - Territory
            Task newTask = new Task(
                OwnerId = u.Id,
                Subject = 'Test',
                WhatId = a.Id,
                Status = 'Not Started',
                Priority = 'Normal'
            );
            newTasks.add(newTask);
            
            // Task - New Product Tracking
            map<String, Id> rtMap = new map<String, Id>();
            for(RecordType r : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Task'])
            {
                rtMap.put(r.Name, r.Id);
            }
            Task newNPTTask = new Task(
                RecordTypeId = rtMap.get('Imperative Task'),
                Type__c = 'EFx Shield',
                OwnerId = u.Id,
                WhatId = a.Id,
                Status = 'Not Started',
                Priority = 'Normal'
            );
            newTasks.add(newNPTTask);
            
            insert newNPTTask;
            
            Survey_Cardiac_Service__c scs = new Survey_Cardiac_Service__c(
                Contact__c = c.Id,
                X2_Multi_Catch__c = 'The Service representative was easy to contact = Strongly Disagree\nThe Service representative was knowledgeable about our products and services = Disagree\nThe Service representative was able to solve my problem, or was able to get me to the right resource to solve my problem = Neutral\nThe Service representative was able to resolve my issue in a timely manner = Agree\nOverall I was very satisfied with the last interaction with the Service Representative = Strongly Agree'
                /*
X1_Contact_Initiation__c 
X1a_Contact_Initiation_Other__c 
X3_Likeliness_to_refer_a_colleague__c 
X3a_Why_Unlikely_very_unlikely__c 
X3b_Other_Likely_Unlikely_to_Ref__c 
X4Would_you_like_to_be_contacted__c = TRUE,

Name__c 
Title__c 
Phone__c 
Email__c 
More_info_requested__c */
                
            );
            insert scs;
            
        }
    }
    
    
    @istest static void testAccountPage(){
        
        Test.startTest();
        
        Account a = [SELECT Id FROM Account WHERE SAP_Sold_To__c = '100123'];
        
        
        //User u= [SELECT Id FROM User WHERE Email='unit.test@unit1.teleflex.com' LIMIT 1];
        User u1 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'puser000@amamama.com',
             Username = 'puser000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        INSERT u1;
        
        AccountTeamMember teamMember= new AccountTeamMember();
        teamMember.AccountId= a.Id;
        teamMember.UserId= u1.Id;
        INSERT teamMember;
        
        List<Invoiced_Sales__c> invoiceSale= [SELECT Id FROM Invoiced_Sales__c WHERE key__c='100123-AA-10511-1'];
        
        /*AccountTeamMember teamMember1= new AccountTeamMember();
        teamMember1.AccountId= a.Id;
        teamMember1.UserId= u1.Id;
        INSERT teamMember1;*/
        
        PageReference pageRef = new PageReference('/' + a.Id);
        system.debug('User Edit Page' + pageRef);
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('id', a.Id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(a);
        account_Page_Helper aph = new account_Page_Helper(stdController);
        
        aph.getTop10();
        aph.getTop10byBU();
        aph.getSalesSummaryByBU();
        aph.getGraph();
        aph.getAllProducts();
        aph.getAllProductsbyBU();
        aph.getATMlist();
        aph.getmyBU();
        aph.getMyContacts();
        aph.getContacts();
        aph.shareAccount();
        string thisYear = aph.thisYear;
        string lastYear = aph.lastYear;
        
        Test.stopTest();  
    }
    @istest static void testAccountPage2(){
        
        Account a = [SELECT Id FROM Account WHERE SAP_Sold_To__c = '100123'];
        //Invoiced_Sales__c
        
        Invoiced_Sales__c invoiceSale= [SELECT Id FROM Invoiced_Sales__c WHERE key__c='100123-AA-10511-1' LIMIT 1];
        
        //PageReference pageRef = new PageReference('/apex/account?id=' + a.Id);
        PageReference pageRef = new PageReference('/' + a.Id);
        system.debug('User Edit Page' + pageRef);
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('id', a.Id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(a);
        account_Page_Helper aph = new account_Page_Helper(stdController);
        aph.getAllProducts();
        /*aph.getATMlist();
        aph.getmyBU();
        aph.getMyContacts();
        aph.getContacts();
        string thisYear = aph.thisYear;
        string lastYear = aph.lastYear;*/
    }
    @istest static void testSalesCockpit(){
        
        // Start Test Sales Cockpit
        Test.startTest();
        PageReference pageSCP = new PageReference('/apex/sales_Cockpit?id=700123');
        system.debug('Price Quote Page' + pageSCP);
        Test.setCurrentPage(pageSCP);
        
        sales_Cockpit scp = new sales_Cockpit();
        
        decimal ytdTotal = scp.ytdTotal;
        decimal pytdTotal = scp.pytdTotal;
        decimal quotaytdTotal = scp.quotaytdTotal;
        decimal ytdTotalPercent = scp.ytdTotalPercent; 
        decimal annualizedTotal = scp.annualizedTotal;
        decimal annualizedPercent = scp.annualizedPercent;
        
        decimal thisYearTotal = scp.thisYearTotal;
        decimal lastYearTotal = scp.lastYearTotal;
        
        string tid = scp.tid;
        string thisYear2 = scp.thisYear; 
        string thisMonth = scp.thisMonth;
        integer monthsLeft = scp.monthsLeft;
        string thisMonthName = scp.thisMonthName;
        string lastYear2 = scp.lastYear;
        string ytdGraph = scp.ytdGraph;
        string cumulativeGraph = scp.cumulativeGraph;
        
        scp.getOppsThisMonth();
        scp.getPiplineThisYear();
        Test.stopTest();
        // END Sales Cockpit
        // 
        // Start Sales Cockpit Account Test
        PageReference pageSCPA = new PageReference('/apex/sales_Cockpit_Account?id=700123&sap=100123');
        system.debug('Price Quote Page' + pageSCPA);
        Test.setCurrentPage(pageSCPA);
        
        sales_Cockpit_Account scpa = new sales_Cockpit_Account();
        
        decimal ytdTotal2 = scpa.ytdTotal;
        decimal pytdTotal2 = scpa.pytdTotal;
        decimal quotaytdTotal2 = scpa.quotaytdTotal;
        decimal ytdTotalPercent2 = scpa.ytdTotalPercent;
        decimal annualizedTotal2 = scpa.annualizedTotal;
        decimal annualizedPercent2 = scpa.annualizedPercent;
        decimal thisYearTotal2 = scpa.thisYearTotal;
        decimal lastYearTotal2 = scpa.lastYearTotal;
        
        string tid2 = scpa.tid;
        string sap2 = scpa.sap;
        string thisYear3 = scpa.thisYear;
        string thisMonth2 = scpa.thisMonth;
        integer monthsLeft2 = scpa.monthsLeft;
        string thisMonthName2 = scpa.thisMonthName;
        string lastYear3 = scpa.lastYear;
        string ytdGraph2 = scpa.ytdGraph;
        string cumulativeGraph2 = scpa.cumulativeGraph;
        // END Sales Cockpit Account Test
        
        
        
        
        // Start Product Tracking Testing
        Product_Tracking__c ptrec = new Product_Tracking__c(
            SAP_Code__c = '100123'
        );
        //insert ptrec;
        
        
        
    }
    @istest static void testLeadAssignment(){
        Quick_Disable__c qd = new Quick_Disable__c(
            Name = 'territory_User_Assignment',
            Enable__c = TRUE
        );
        System.debug('insert qd-->' + qd);
        insert qd;
        
        Test.startTest();
        // Start testing for territory_User_Assignment.assignUser
        // Mar 24 2016 - ESC
        
        // Added Record Type Testing - 22May2016 - ESC
        // Updated for GPL Changes - 07Jul2017 - ESC
        String stdLeadRecordTypeId = [SELECT Id 
                                      FROM RecordType 
                                      WHERE SobjectType = 'Lead' 
                                      AND Name = 'Teleflex Standard Lead'].Id;
        
        /*String surgLeadRecordTypeId = [SELECT Id 
                                       FROM RecordType 
                                       WHERE SobjectType = 'Lead' 
                                       AND Name = 'Surgical Lead'].Id;
        
        Lead_Settings__c lset = new Lead_Settings__c(
            Name = 'Surgical',
            Record_Type__c = 'Surgical Lead',
            Record_Type_ID__c = surgLeadRecordTypeId
        );
        insert lset;*/
        
        Lead l = new lead(
            lastname = 'test',
            company = 'test',
            Status = 'Open',
            PostalCode = '27614',
            State = 'NC',
            Country = 'US',
            Business_Unit__c = 'SurgicalX',
            RecordTypeId = stdLeadRecordTypeId
        );
        insert l;
        
        
        // Create the Lead
        Lead l2 = new lead(
            lastname = 'test799791',
            company = 'test992921',
            Status = 'Open',
            email = '123321@1232222.com',
            Country = 'US',
            PostalCode = '27614',
            Business_Unit__c = 'SurgicalX',
            Lab_Unique_ID__c = '123123',
            Zip_Code_Auto_Route__c = FALSE
        );
        insert l2;
        system.debug('Lead' + l2);
        
        Lab__c lab = new Lab__c(
            Name = 'UNC Lab',
            Lab_Key__c = 'UNC Lab'
        );
        master_TriggerHelperClass.runOnce('resetOnceSet');
        insert lab;
        system.debug('lab: ' + lab);
        
        Lab_Participant__c lp = new Lab_Participant__c(
            Name = 'test',
            Lead__c = l2.id,
            Lab__c = lab.Id,
            Lab_Time__c = '7pm',
            Email__c = '123321@1232222.com',
            Mailing_Zip_Code__c = '27614',
            Mailing_State__c = 'NC',
            Address__c = '123 Mainstreet Raleigh, NC 27614 US',
            Affiliation__c = 'Surgical',
            Lab_Unique_ID__c = '123123'
        );
        master_TriggerHelperClass.runOnce('resetOnceSet');
        insert lp;
        update lp;
        
        master_TriggerHelperClass.runOnce('resetOnceSet');
        l.Force_Territory_Assigment_Check__c = TRUE;
        l.Business_Unit__c = 'SurgicalX';
        update l;
        
        
        Test.stopTest();
    }
    
    @istest static void testVPS(){
        
        Test.startTest();
        account_Build_Sales abs = new account_Build_Sales();
        Database.executeBatch(abs);
        
        account_Active_Sales_Batch aas = new account_Active_Sales_Batch();
        Database.executeBatch(aas);
        
        // VPS Tracking
        Build_VPS_Consumable_Sales_Batch buildBatch = new Build_VPS_Consumable_Sales_Batch();
        Database.executeBatch(buildBatch);
        
        // VPS Tracking Scheduling
        String CRON_EXP = '0 0 0 15 3 ?';
        String jobId;
        
        jobId = System.schedule('Build_VPS_Consumable_Sales_Scheduler', CRON_EXP, new Build_VPS_Consumable_Sales_Scheduler());
        
        Test.stopTest();
        
    }
    @istest static void testBusinessMetrics(){
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/Business_Metrics');
        Test.setCurrentPage(pageRef);
        
        Business_Metrics_Page_Class bh2 = new Business_Metrics_Page_Class();
        Test.stopTest();
    }
    
    @istest static void testSurveyRedirect(){
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/survey_Redirect');
        Test.setCurrentPage(pageRef);
        
        survey_Helper_Class shc = new survey_Helper_Class();
        shc.redirect();
        Test.stopTest();
        
    }
    
}