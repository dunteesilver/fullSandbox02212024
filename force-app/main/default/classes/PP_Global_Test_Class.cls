/*********************************************************************
* Description     : Main test class for Pricing Portal Project
* Covered Classes : PP_Price_Quote, PP_SAP_Price, PP_Price_Lookup,
                    PP_PRF, PP_PRF_Export, PP_ImportCsv, PP_ImportCsvPrf,
                    PP_ImportCsvBatch
* Author(s)       : Dun Silver, Eric Clay
**********************************************************************/
@isTest
public class PP_Global_Test_Class {

    @testSetup public static void dataSetup(){
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

        list<Group> glist = new list<Group>();
        integer gnum;
        for(Integer x=0; x<6;x++){
            gnum = x + 1;
            group newGroup = new Group(
                Name = 'US Division ' + gnum + '0',
                DeveloperName = 'Division_' + gnum + '0'
            );
            system.debug('newGroup: ' + newGroup);
            glist.add(newGroup);
        }

        Group pp = new Group(
            Name = 'Pricing Portal',
            DeveloperName = 'Pricing_Portal'
        );
        glist.add(pp);

        Quote_Logos__c quotelogo = new Quote_Logos__c(
            Name = 'Surgical Instruments',
            Quote_Page__c = 'PP_Print_Quote',
            URL__c = 'test',
            Footer__c = 'test'
        );
        insert quotelogo;

        //insert glist;

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
            Key__c = 'ANES',
            Auto_Create_Opportunity__c = TRUE
        );
        buList.add(newBU);
        //insert bu2;                
        insert buList;
        
        //public static Sales_Orgs__c  createSalesOrg(String salesOrgKey, Boolean isActive, String pricingType, String salesOrg, String distrChannel)
        Set<Sales_Orgs__c> newSalesOrgsSet = new Set<Sales_Orgs__c>();
        Sales_Orgs__c salesOrgUs = testDataFactoryPP.createSalesOrg('US6010',true,'All','US60','10');
        newSalesOrgsSet.add(salesOrgUs);
        Sales_Orgs__c salesOrgCan = testDataFactoryPP.createSalesOrg('CA1010',true,'All','CA10','10');
        newSalesOrgsSet.add(salesOrgCan);
        Sales_Orgs__c salesOrgLatamExp = testDataFactoryPP.createSalesOrg('US6020',true,'Distributor List','US60','20');
        newSalesOrgsSet.add(salesOrgLatamExp);
        Sales_Orgs__c salesOrgMx = testDataFactoryPP.createSalesOrg('MX4010',true,'All','MX40','10');
        newSalesOrgsSet.add(salesOrgMx);
        Sales_Orgs__c salesOrgCl = testDataFactoryPP.createSalesOrg('CL1010',true,'All','CL10','10');
        newSalesOrgsSet.add(salesOrgCl);
        Sales_Orgs__c salesOrgCo = testDataFactoryPP.createSalesOrg('CO10',true,'All','CO10','10');
        newSalesOrgsSet.add(salesOrgCo);
        Sales_Orgs__c salesOrgUsOld = testDataFactoryPP.createSalesOrg('US103010',true,'All','US10','10');
        newSalesOrgsSet.add(salesOrgUsOld);
        Sales_Orgs__c salesOrgLaOld = testDataFactoryPP.createSalesOrg('US103020',true,'Distributor List','US10','20');
        newSalesOrgsSet.add(salesOrgLaOld);
        Sales_Orgs__c salesOrgBr = testDataFactoryPP.createSalesOrg('BR1010',true,'All','BR10','10');
        newSalesOrgsSet.add(salesOrgBr);
        Sales_Orgs__c salesOrgAu = testDataFactoryPP.createSalesOrg('AU1010',true,'All','AU10','10');
        newSalesOrgsSet.add(salesOrgAu);
        Sales_Orgs__c salesOrgNz = testDataFactoryPP.createSalesOrg('NZ1010',true,'All','NZ10','10');
        newSalesOrgsSet.add(salesOrgNz);
        List<Sales_Orgs__c> newSalesOrgs = new List<Sales_Orgs__c>(newSalesOrgsSet);
        insert newSalesOrgs;
        
        System.runAs(u){

            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Division_10__c = TRUE,
                Division_20__c = TRUE,
                Division_30__c = TRUE,
                Division_40__c = TRUE,
                Division_50__c = TRUE,
                Division_60__c = TRUE,
                Active_Sales_Org_Key__c = 'US6010',
                Active_Currency__c = 'USD',
                Pricing_Tier_Access__c = 1
            );
            
            Contract_User__c cu2 = new Contract_User__c(
                Name = 'Adam Franks1',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex/Arrow',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Division_10__c = TRUE,
                Division_20__c = TRUE,
                Division_30__c = TRUE,
                Division_40__c = TRUE,
                Division_50__c = TRUE,
                Division_60__c = TRUE,
                Active_Sales_Org_Key__c = 'US103010',
                Active_Currency__c = 'USD',
                Pricing_Tier_Access__c = 1
            );
            Test.startTest();
            insert cu;
            insert cu2;
            Test.stopTest();
            system.debug('CU:' + cu);

            /*
            Map<String,RecordType> recordTypeMap = new Map<String,RecordType>(); //holds map of recordtype name and object
            List<RecordType> recTypes = [Select Name, Id, SobjectType, DeveloperName From RecordType Where sObjectType='Account'];
            //loop to create map of account recordtypes
            for(RecordType curr : recTypes){
                recordTypeMap.put(curr.Name,curr);
            }
            */
            
            Account accTest = new Account(
                Name = 'TestAccount',
                SAP_Sold_To__c = '102059',
                Account_Group__c = 'Z002',
                Customer_Group__c = '16',
                zBlock__c = '00',
                ERP_Active__c = TRUE,
                Sales_Org__c = 'US60'
            );
            insert accTest;

            Account accTest2 = new Account(
                Name = 'TestAccount2',
                SAP_Sold_To__c = '110069',
                Account_Group__c = 'Z002',
                Customer_Group__c = '01',
                zBlock__c = '00',
                ERP_Active__c = FALSE
            );
            insert accTest2;

            Account accTest5 = new Account(
                Name = 'TestAccount5',
                zBlock__c = '00',
                ERP_Active__c = FALSE
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
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GPO Account').getRecordTypeId()
            );
            insert accTest8;
            
            Account accTest9 = new Account(
                Name = 'TestAccount9',
                SAP_Sold_To__c = '123456',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '01',
                Sales_Org__c = 'AU10',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ANZ Customer').getRecordTypeId()
            );
            insert accTest9;

            Account accTest10 = new Account(
                Name = 'TestAccount10',
                SAP_Sold_To__c = '123457',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '01',
                Sales_Org__c = 'CO10',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
            );
            insert accTest10;
            //System.assertEquals(accTest10.RecordTypeId, Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId());
            
            Contact conTest = new Contact(
                FirstName ='Test',
                email = 'abc@123.com',
                LastName = 'TestContact',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                AccountId = accTest.Id
            );
            insert conTest;

            Contact conTest5 = new Contact(
                FirstName ='Test',
                email = 'abc@12345.com', 
                LastName = 'TestContact',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                AccountId = accTest5.Id
            );
            insert conTest5;

            Pricebook2 pb = new pricebook2(
                Name='Pricing Portal US',
                IsActive = TRUE
            );
            insert pb;
            system.debug('pb: ' + pb);

            string pbid = pb.Id;
            pbid = pbid.left(15);

            insert new Price_Books__c(
                Name = 'US6010',
                Id__c = pbid,
                Price_Book_Name__c = 'Pricing Portal US'
            );

            
            //List<String> prodList = new List<String>();
            Product2 prodTest = new Product2(
                Name = '353535',
                ProductCode= '353535',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='30',
                Family = 'Hardware',
                Material__c='353535',
                Brand_Name__c='Arrow',
                Buom__c='EA',
                Class__c='Anesthesia',
                Cost__c=11587.40,
                Cost_Price_Unit__c=1000,
                Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Group__c='Interventional',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,
                Sales_Unit__c='CS',
                List_Price__c=380.00,
                Rep_Price__c=350.00,
                Transfer_Price__c = 1000.00,
                Sales_Org__c = 'US60',
                Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US6010',
                Material_Key__c = '353535-US60-10',
                RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            master_TriggerHelperClass.runOnce('resetOnceSet');
            insert prodTest;
            system.debug('prodTest: ' + prodTest);

            Product2 prodTest2 = new Product2(
                Name = '000-11',
                ProductCode= '000-11',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='30',
                Family = 'Hardware',
                Material__c='000-11',
                Brand_Name__c='Arrow',
                Buom__c='EA',
                Class__c='Cardiac Care Specialty',
                Cost__c=11587.40,
                Cost_Price_Unit__c=1000,
                Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Group__c='Interventional',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,
                Sales_Unit__c='CS',
                List_Price__c=380.00,
                Rep_Price__c=350.00,
                Transfer_Price__c = 1000.00,
                Sales_Org__c = 'US10',
                Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US103010',
                Material_Key__c = '00011-US30-10',
                RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            insert prodTest2;

            Product2 prodTest3 = new Product2(
                Name = '000-40',
                ProductCode= '000-40',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='30',
                Family = 'Hardware',
                Material__c='000-40',
                Brand_Name__c='Arrow',
                Buom__c='EA',
                Class__c='Respiratory',
                Cost__c=11587.40,
                Cost_Price_Unit__c=1000,
                Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Group__c='Interventional',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,
                Sales_Unit__c='CS',
                List_Price__c=380.00,
                Rep_Price__c=350.00,
                Transfer_Price__c = 1000.00,
                Sales_Org__c = 'US10',
                Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US103010',
                Material_Key__c = '00040-US30-10',
                RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            insert prodTest3;

            Cross_Reference__c CRTest = new Cross_Reference__c(
                Competitor_Product_Code__c = '320250',
                Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                Competitor_Name__c ='Jarit/Integra',
                Percent_Match__c=100,
                Product__c = prodTest.Id);
            insert CRTest;
            List<String> crossRef = new List<String>();
            crossRef.add(CRTest.Competitor_Product_Code__c);

            Contract_Partnership__c cp = new Contract_Partnership__c(
                Sale_to__c = '102059',
                Ship_to__c = '102059'
            );
            insert cp;

            Contract_Partnership__c cp1 = new Contract_Partnership__c(
                Sale_to__c = '150322',
                Ship_to__c = '110069'
            );
            insert cp1;

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

            GPO_PickList__c gpoPickList = new GPO_PickList__c(
                Name = 'Vizient Inc.',
                Sales_Org_Key__c = 'US',
                Active__c = TRUE,
                Key__c = 'GPO-008'
            );
            insert gpoPickList;

            list<Contract_Header__c> chList = new list<Contract_Header__c>();
            list<Contract_Material__c> cmList = new list<Contract_Material__c>();
            
            Contract_Header__c chTest2 = new Contract_Header__c(
                Name = '50010864',
                Agreement_Number__c = '50010864',
                Description__c = 'Test Description',
                Owner__c = 'GPO-008',
                GPO_Contract_Ref__c = 'MS0217B',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000
            );
            insert chTest2;
            
            // Tier 1
            Contract_Header__c chTier1 = new Contract_Header__c(
                Name = '50010001',
                Agreement_Number__c = '50010001',
                Description__c = 'Test Description',
                Owner__c = '123310',
                GPO_Contract_Ref__c = 'MS0217B-R',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Sub_Group__c = '8'
            );
            insert chTier1;
            
            Contract_Material__c cmTier1 = new Contract_Material__c(
                Name = '50010001',
                Agreement__c = chTier1.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US60',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '10',
                Price__c = 375.00,
                Maintenance_Key__c = '123'
            );
            insert cmTier1;
            
            Contract_Customer__c ccTier1 = new Contract_Customer__c(
                Name = '50010001',
                Agreement__c = chTier1.Id,
                Account__c = accTest.Id,
                SAP_Code__c = '102059',
                Sales_Org__c = 'US60',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10',
                Condition__c = 'XNAF',
                Maintenance_Key__c = '123'
            );
            insert ccTier1;

            // Tier 2
            Contract_Header__c chTier2 = new Contract_Header__c(
                Name = '50010002',
                Agreement_Number__c = '50010002',
                Description__c = 'Test Description',
                Owner__c = '123310',
                GPO_Contract_Ref__c = 'MS0217B-R',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Sub_Group__c = '8'
            );
            insert chTier2;
            
            Contract_Material__c cmTier2 = new Contract_Material__c(
                Name = '50010001',
                Agreement__c = chTier2.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '10',
                Price__c = 370.00,
                Maintenance_Key__c = '123'
            );
            insert cmTier2;
            
            Contract_Customer__c ccTier2 = new Contract_Customer__c(
                Name = '50010002',
                Agreement__c = chTier2.Id,
                Account__c = accTest.Id,
                SAP_Code__c = '102059',
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10',
                Condition__c = 'XNAF',
                Maintenance_Key__c = '123'
            );
            insert ccTier2;
            
            // Tier 3
            Contract_Header__c chTier3 = new Contract_Header__c(
                Name = '50010003',
                Agreement_Number__c = '50010003',
                Description__c = 'Test Description',
                Owner__c = '123310',
                GPO_Contract_Ref__c = 'MS0217B-R',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Sub_Group__c = '8'
            );
            insert chTier3;
            
            Contract_Material__c cmTier3 = new Contract_Material__c(
                Name = '50010001',
                Agreement__c = chTier3.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '10',
                Price__c = 365.00,
                Maintenance_Key__c = '123'
            );
            insert cmTier3;
            
            Contract_Customer__c ccTier3 = new Contract_Customer__c(
                Name = '50010003',
                Agreement__c = chTier3.Id,
                Account__c = accTest.Id,
                SAP_Code__c = '102059',
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10',
                Condition__c = 'XNAF',
                Maintenance_Key__c = '123'
            );
            insert ccTier3;

            Contract_Customer__c ccTest = new Contract_Customer__c(
                Name = '50009064',
                Agreement__c = chTest.Id,
                Account__c = accTest.Id,
                SAP_Code__c = '102059',
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10',
                Condition__c = 'XNAF',
                Maintenance_Key__c = '123'
            );
            insert ccTest;

            Contract_Customer__c ccTest2 = new Contract_Customer__c(
                Name = '50010864',
                Agreement__c = chTest2.Id,
                Account__c = accTest.Id,
                SAP_Code__c = '102059',
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10',
                Condition__c = 'XPRI'
            );
            insert ccTest2;

            Contract_Material__c cmTest = new Contract_Material__c(
                Name = '50009064',
                Agreement__c = chTest.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '10',
                Price__c = 380.00,
                Maintenance_Key__c = '123'
            );
            insert cmTest;

            Contract_Material__c cmTest2 = new Contract_Material__c(
                Name = '50010864',
                Agreement__c = chTest2.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '10',
                Price__c = 350.00
            );
            insert cmTest2;
            
            // Price Quotes
            Price_Quote__c PQTest = new Price_Quote__c(
                Account_Name__c = accTest.Id,
                Contact_Name__c = conTest.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US103010',
                One_Time_Purchase__c = TRUE,
                Type__c = 'ASK Agreement',
                Language__c = 'English'
            );
            insert PQTest;

            Price_Quote__c PQTest5 = new Price_Quote__c(
                Account_Name__c = accTest5.Id,
                Contact_Name__c = conTest5.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US103010',
                One_Time_Purchase__c = TRUE,
                Language__c = 'Spanish'
            );
            insert PQTest5;

            Price_Quote__c PQTest3 = new Price_Quote__c(
                Account_Name__c = accTest2.Id,
                Contact_Name__c = conTest.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US103010',
                One_Time_Purchase__c = TRUE,
                Language__c = 'French'
            );
            insert PQTest3;
            Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
                Price_Quote__c = PQTest.Id,
                Material_Name__c = prodTest.Id,
                Sales_Price__c = 1.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 330.00,
                List_Price__c = 380.00,
                Quantity__c = 1,
                Extended_Price__c = 230.00,
                Sales_Deal_Description__c = 'test',
                Sales_Number__c = '50009064',
                Competetive_Product__c = CRTest.Id,
                Product_Description__c='Test Description'
            );
            insert PQLineItem;

            Price_Quote_Line_Item__c PQLineItem5 = new Price_Quote_Line_Item__c(
                Price_Quote__c = PQTest5.Id,
                Material_Name__c = prodTest2.Id,
                Sales_Price__c = 1.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 330.00,
                List_Price__c = 380.00,
                Quantity__c = 1,
                Extended_Price__c = 230.00,
                Product_Description__c='Test Description'
            );
            insert PQLineItem5;

            New_Product_Tracking__c  newNPT = new New_Product_Tracking__c(
                Name = 'TruLite',
                Business_Unit__c = 'Anesthesia',
                Start_Date__c = Date.today() - 90,
                End_Date__c = Date.today() + 90,
                New_Product_Key__c = 'Anesthesia-TruLite'
            );
            insert newNPT;

            New_Product_Tracking_Rule__c newNPTR = new New_Product_Tracking_Rule__c(
                Product__c = 'TruLite',
                Business_Unit__c = 'Anesthesia',
                Key__c = 'Anesthesia-TruLite',
                New_Product_Tracking__c = newNPT.Id,
                IsProductSales__c = TRUE,
                IsProductOfInterest__c = TRUE
            );
            insert newNPTR;

            //list<Opportunity> newOpps = new list<Opportunity>();
            Opportunity newOpp = new Opportunity(
                Name = 'Test Opp',
                AccountId = AccTest.Id,
                CloseDate = Date.Today() + 90,
                Primary_Contact__c = ConTest.Id,
                StageName = 'Qualified Prospect',
                Amount = 1.00,
                Product_Family__c = 'Airway',
                Product_of_Interest__c = 'EFx Shield;T Shield',
                //RecordTypeId = '01244000000NNcz',
                Business_Unit_GPL__c='Anesthesia',
                Product_Family_GPL__c='Airway',
                Product_of_Interest_GPL__c='MADgic',
                Pricebook2 = pb,
                Owner_Territory_Number__c = '800123'
            );
            //newOpps.add(newOpp);
            insert newOpp;

            master_TriggerHelperClass.runOnce('resetOnceSet');
            newOpp.StageName = 'Financial Decision';
            newOpp.CloseDate = Date.Today() + 92;
            newOpp.Product_of_Interest_GPL__c = 'TruLite';
            update newOpp;

            system.debug('newOpp: ' + newOpp);
            /*
            newOpp = new Opportunity(
                Name = 'Test Opp2',
                Account = AccTest,
                CloseDate = Date.Today() + 90,
                Primary_Contact__c = ConTest.Id,
                StageName = 'Qualified Prospect',
                Amount = 1.00,
                Product_Family__c = 'Airway',
                Product_of_Interest__c = 'No Shield',
                Business_Unit__c = 'Surgical',
                New_Product_Tracking__c = newNPT.Id,
                Pricebook2 = pb
            );
            //master_TriggerHelperClass.runOnce('resetOnceSet');
            //insert newOpp2;
            //system.debug('newOpp: ' + newOpp2);
            newOpps.add(newOpp);
            insert newOpps;

            list<Lead> newLeads = new list<Lead>();
            Lead l = new lead(
                lastname = 'test',
                company = 'test',
                Status = 'Open',
                Product_of_Interest__c = 'EFx Shield;T Shield',
                Business_Unit__c = 'Surgical'
            );
            newLeads.add(l);

            l = new lead(
                lastname = 'test',
                company = 'test',
                Status = 'Open',
                Product_of_Interest__c = 'T Shield',
                New_Product_Tracking__c = newNPT.Id,
                Business_Unit__c = 'Surgical'
            );
            newLeads.add(l);
            insert newLeads;*/

            String pbEntryId = [SELECT Id
                                FROM PriceBookEntry
                                WHERE Product2Id =:prodTest.Id
                                AND Pricebook2Id =:pb.Id LIMIT 1].Id;

            OpportunityLineItem newOLI = new OpportunityLineItem(
                OpportunityId = newOpp.Id,
                PricebookEntryId = pbEntryId,
                Quantity = 1,
                UnitPrice = 1.00,
                Price_Quote_Line_Item_ID__c = PQLineItem.Id
            );
            insert newOLI;
            system.debug('newOLI: ' + newOLI);

            PQLineItem.Opportunity_Products_Line_ID__c = newOLI.Id;
            update PQLineItem;

            PRF__c prfTest = new PRF__c(
                Account__c = accTest.Id,
                Contact__c = conTest.Id,
                Status__c = 'New',
                Requisition_Date__c = Date.valueOf('2015-03-11'),
                Sales_Org_Key__c = 'US103010',
                Price_Quote__c = PQTest.Id,
                GPO_Affiliation__c = ''
            );
            insert prfTest;

            PRF__c prfTest5 = new PRF__c(
                Account__c = accTest5.Id,
                Contact__c = conTest5.Id,
                Status__c = 'Approved',
                Requisition_Date__c = Date.valueOf('2015-03-11'),
                Sales_Org_Key__c = 'US103020',
                Price_Quote__c = PQTest5.Id
            );
            insert prfTest5;

            PRF_Line_Item__c prfLineItem = new PRF_Line_Item__c(
                PRF__c = prfTest.Id,
                Material_Name__c = prodTest.Id,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 330.00,
                List_Price__c = 380.00,
                Requested_Price__c = 230.00
            );
            insert prfLineItem;
        }
    }//end @testSetup static void dataSetup()

    @isTest static void priceQuoteTest() {
        //Created the contract user to fix the test failure issue
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;

            /*string pbid = pb.Id; // Used to create the Price Book through method
            pbid = pbid.left(15);

            PP_Opportunity_Sync_Test newST = new PP_Opportunity_Sync_Test();
            newST.pbinsert(pbid);*/

        system.debug('-- Starting priceQuoteTest --');

        //List<Sales_Orgs__c> newSalesOrgs = new List<Sales_Orgs__c>();
        //Sales_Orgs__c salesOrgUs = testDataFactoryPP.createSalesOrg('US6010',true,'All','US60','10');
        //newSalesOrgs.add(salesOrgUs);
        //insert salesOrgUs;
        
        Price_Quote__c pqid = [SELECT Id, Language__c, BusinessUnit__c
                               FROM Price_Quote__c
                               WHERE Line_Count__c > 0
                               LIMIT 1];
        system.debug('pqid: ' + pqid);

        string pqstrID = pqid.Id;
        pqstrID = pqstrID.left(15);

        string pqliID = [SELECT ID FROM Price_Quote_Line_Item__c LIMIT 1].Id;
        list<Price_Quote_Line_Item__c> pqliList = [SELECT Id, Material_Name__c, Sales_Price__c, Price_Quote__r.BusinessUnit__c,
                                                   Eligible_Price__c, Sales_Deal_Description__c, Material_Name__r.Name,
                                                   Material_Name__r.Cost__c, Material_Name__r.Transfer_Price__c,
                                                   Material_Name__r.Floor_Price__c, Material_Name__r.Director_Price__c,
                                                   RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Distributor_List__c,
                                                   Material_Name__r.Qty_Sales_Unit__c, Opportunity_Products_Line_ID__c
                                                   FROM Price_Quote_Line_Item__c WHERE Price_Quote__c =: pqstrID];
        system.debug('pqliList: ' + pqliList);

        User u = [SELECT Id, Name, Business_Unit__c FROM User WHERE Name = 'Adam Franks' LIMIT 1];

        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqstrID);
        system.debug('Price Quote Page' + pageRefpre);
        Test.setCurrentPage(pageRefpre);

        System.currentPageReference().getParameters().put('strProdSearch', pqliList[0].Material_Name__r.Name);
        System.currentPageReference().getParameters().put('strMats', pqliList[0].Material_Name__r.Name);
        System.currentPageReference().getParameters().put('rsmPrice', '100');
        System.currentPageReference().getParameters().put('pqid', pqstrID);
        System.currentPageReference().getParameters().put('repPrice', '100');
        System.currentPageReference().getParameters().put('listPrice', '100');
        System.currentPageReference().getParameters().put('eligiblePrice', '100');
        System.currentPageReference().getParameters().put('lineId', pqliID);
        System.currentPageReference().getParameters().put('trId', pqliID);
        System.currentPageReference().getParameters().put('sdnum', '50009064');
        System.currentPageReference().getParameters().put('tierPrice', '70');
        System.currentPageReference().getParameters().put('key', 'REP1-353535');

        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqid);
        PP_Price_Quote pqt = new PP_Price_Quote(ctlr);

        Test.startTest();
        pqt.strQtyChange = '1';
        pqt.pqlid = pqstrID;
        pqt.strMats = '353535';
        pqt.strProdSearch = '353535';
        pqt.userId = u.Id;
        pqt.userBU = u.Business_Unit__c;
        System.assertEquals(pqt.userId, u.Id);
        
        pqt.soldToAcct = '102059';
        System.assertEquals(pqt.soldToAcct, '102059');

        pqt.soldToAcctType = 'ZH';
        System.assertEquals(pqt.soldToAcctType, 'ZH');

        //pqt.userBu = 'Anesthesia';
        //System.debug(pqt.userBu);
        //System.assertEquals(pqt.userBu, 'Anesthesia');
        /*
        pqt.lang = '&lang=es';
        System.assertEquals(pqt.lang, '&lang=es');
        
        pqt.lang = '&lang=fr';
        System.assertEquals(pqt.lang, '&lang=fr');
        
        pqt.lang = '&lang=en';
        System.assertEquals(pqt.lang, '&lang=en');
        */
        pqt.strQuoteId = pqstrID;
        pqt.sendReport();
        pqt.cancel();
        pqt.createPRF();
        pqt.cpProcess();
        pqt.getcpDropDown();
        pqt.helperMethod();
        pqt.getPickListValuesIntoList();

        pqt.buValue = 'Anesthesia';
        pqt.setBu();
        //pqt.cardiacFavorites();
        pqt.bulkInsert2();
        pqt.bulkrefresh();
        pqt.updateOwner();
        pqt.doUpdateAccountValue();
        pqt.getpq();
        pqt.getLineItems();

        /* Adding stuff for new pricing strategy */
        pqt.setPriceToggle();
        pqt.priceToggle = true;
        pqt.setPriceToggle();
        pqt.requestHigherTierAccess();
        pqt.getCheckInit();
        pqt.initCube();
        pqt.massUpdateTiers();
        pqt.updateTierPrice();
        PP_Price_Quote.updateBlank(pqliID,'Test');
        /*****************************************/

        pqt.massQtyChange();
        pqt.Reject();
        pqt.Approve();
        pqt.removingRow();
        pqt.massDelItems();
        Test.stopTest();
    }//end of priceQuoteTest

    @isTest static void priceQuoteTest4() {
        //Created the contract user to fix the test failure issue
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        
        system.debug('-- Starting priceQuoteTest4 --');
        
        //List<Sales_Orgs__c> newSalesOrgs = new List<Sales_Orgs__c>();
        Sales_Orgs__c salesOrgUs = testDataFactoryPP.createSalesOrg('US6010',true,'All','US60','10');
        //newSalesOrgs.add(salesOrgUs);
        insert salesOrgUs;
        
        Price_Quote__c pqid = [SELECT Id, Language__c
                               FROM Price_Quote__c
                               WHERE Line_Count__c > 0
                               LIMIT 1];
        system.debug('pqid: ' + pqid);

        string pqstrID = pqid.Id;
        pqstrID = pqstrID.left(15);
        Price_Quote__c pqAppRec = new Price_Quote__c(Id = pqstrId, BusinessUnit__c = 'Anesthesia');
        update pqAppRec;

        string pqliID = [SELECT ID FROM Price_Quote_Line_Item__c LIMIT 1].Id;
        list<Price_Quote_Line_Item__c> pqliList = [SELECT Id, Material_Name__c, Sales_Price__c, Price_Quote__r.OwnerId,
                                                   Eligible_Price__c, Sales_Deal_Description__c, Price_Quote__r.Owner_Full_Name__c,
                                                   Material_Name__r.Cost__c, Material_Name__r.Transfer_Price__c, Price_Quote__r.BusinessUnit__c,
                                                   Material_Name__r.Floor_Price__c, Material_Name__r.Director_Price__c,
                                                   RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Distributor_List__c,
                                                   Material_Name__r.Qty_Sales_Unit__c, Opportunity_Products_Line_ID__c
                                                   FROM Price_Quote_Line_Item__c WHERE Price_Quote__c =: pqstrID];
        //system.debug('*** pqliList' + pqliList);
        //system.debug('pqliList: ' + pqliList);
        for(Price_Quote_Line_Item__c curr: pqliList){
            system.debug('*** pqliList OwnerId *** ' + curr.Price_Quote__r.OwnerId + ' *** pqliList Owner Name *** ' + curr.Price_Quote__r.Owner_Full_Name__c);
            system.debug('*** pqliList Sales Price *** ' + curr.Sales_Price__c);
            system.debug('*** pqliList Owner Business Unit *** ' + curr.Price_Quote__r.BusinessUnit__c);
        }
        system.debug('pqliList: ' + pqliList);

        User u = [SELECT Id, Name FROM User WHERE Name = 'Adam Franks' LIMIT 1];

        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqstrID);
        system.debug('Price Quote Page' + pageRefpre);
        Test.setCurrentPage(pageRefpre);

        System.currentPageReference().getParameters().put('rsmPrice', '100');
        System.currentPageReference().getParameters().put('pqid', pqstrID);
        System.currentPageReference().getParameters().put('repPrice', '100');
        System.currentPageReference().getParameters().put('listPrice', '100');
        System.currentPageReference().getParameters().put('eligiblePrice', '100');
        System.currentPageReference().getParameters().put('lineId', pqliID);
        System.currentPageReference().getParameters().put('trId', pqliID);
        System.currentPageReference().getParameters().put('sdnum', '50009064');

        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqid);
        PP_Price_Quote pqt = new PP_Price_Quote(ctlr);

        Test.startTest();
        pqt.massUpdList();
        pqt.saveRecord();

        pqt.fixString();
        pqt.editpq();
        //pqt.Approve();
        //pqt.AutoApprove();
        //pqt.Reject();
        pqt.printpq();
        pqt.cardiacFavorites();
        pqt.cardiacFavorites700();
        //pqt.vascularBundlesWithUltra();
        //pqt.vascularBundlesWithoutUltra();
        //pqt.vascularBundlesRhythm();
        //pqt.vascularBundlesRhythmRefurb();
        //pqt.vascularBundlesProbe();
        //pqt.vascularBundlesG4();
        //pqt.vascularBundlesG4refurb();
        pqt.blankRow();
        //PP_Price_Quote.recall(pqstrID);
        pqt.recall2();
        //Price_Quote__c pqApp = [SELECT Id, Name, OwnerId, Status__c FROM Price_Quote__c WHERE Id =:pqstrID ORDER BY CreatedDate ASC LIMIT 1];

        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(pqAppRec.Id);
        Approval.ProcessResult result = Approval.process(app);
        System.debug('*** pqAppRec *** ' + pqAppRec);

        List<ProcessInstanceWorkitem> appName = [SELECT ActorId,Actor.Name,Id,OriginalActor.Name,OriginalActorId,ProcessInstanceId
                                                FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =:pqAppRec.Id LIMIT 1];

        //String appOwnerName = appName[0].Actor.Name;
        //String uName = 'Dun Silver';
        //System.assertEquals(uName, appOwnerName);
        Boolean isApprover = pqt.isApprover;
        Boolean userApprovalLevel = pqt.userApprovalLevel;
        String approval_reasons = pqt.approval_reasons;
        PP_Price_Quote.recall(pqAppRec.Id);
        //pqt.wrkId = appName[0].ActorId;
        Test.stopTest();
    }

    @isTest static void priceQuoteTest3() {
        //Created the contract user to fix the test failure issue
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        
            /*string pbid = pb.Id; // Used to create the Price Book through method
            pbid = pbid.left(15);

            PP_Opportunity_Sync_Test newST = new PP_Opportunity_Sync_Test();
            newST.pbinsert(pbid);*/

        system.debug('-- Starting priceQuoteTest3 --');
        
        //List<Sales_Orgs__c> newSalesOrgs = new List<Sales_Orgs__c>();
        Sales_Orgs__c salesOrgUs = testDataFactoryPP.createSalesOrg('US6010',true,'All','US60','10');
        //newSalesOrgs.add(salesOrgUs);
        insert salesOrgUs;
        
        Price_Quote__c pqid = [SELECT Id
                               FROM Price_Quote__c
                               WHERE Line_Count__c > 0
                               LIMIT 1];
        system.debug('pqid: ' + pqid);

        string pqstrID = pqid.Id;
        pqstrID = pqstrID.left(15);

        string pqliID = [SELECT ID FROM Price_Quote_Line_Item__c LIMIT 1].Id;
        list<Price_Quote_Line_Item__c> pqliList = [SELECT Id, Material_Name__c, Sales_Price__c,
                                                   Eligible_Price__c, Sales_Deal_Description__c,
                                                   Material_Name__r.Cost__c, Material_Name__r.Transfer_Price__c,
                                                   Material_Name__r.Floor_Price__c, Material_Name__r.Director_Price__c,
                                                   RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Distributor_List__c,
                                                   Material_Name__r.Qty_Sales_Unit__c, Opportunity_Products_Line_ID__c
                                                   FROM Price_Quote_Line_Item__c WHERE Price_Quote__c =: pqstrID];
        system.debug('pqliList: ' + pqliList);

        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqstrID);
        system.debug('Price Quote Page' + pageRefpre);
        Test.setCurrentPage(pageRefpre);

        System.currentPageReference().getParameters().put('rsmPrice', '100');
        System.currentPageReference().getParameters().put('pqid', pqstrID);
        System.currentPageReference().getParameters().put('repPrice', '100');
        System.currentPageReference().getParameters().put('listPrice', '100');
        System.currentPageReference().getParameters().put('eligiblePrice', '100');
        System.currentPageReference().getParameters().put('lineId', pqliID);
        System.currentPageReference().getParameters().put('trId', pqliID);
        System.currentPageReference().getParameters().put('sdnum', '50009064');

        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqid);
        PP_Price_Quote pqt = new PP_Price_Quote(ctlr);

        // New
        Test.startTest();
        boolean reviseButton = pqt.reviseButton;
        boolean comButton = pqt.comButton;
        boolean prfButton = pqt.prfButton;
        boolean subButton = pqt.subButton;
        decimal grandTotal = pqt.grandTotal;
        boolean hasCrossRef = pqt.hasCrossRef;
        boolean needsApproval = pqt.needsApproval;
        string exclusionType = pqt.exclusionType;
        string wrkId = pqt.wrkId;
        List<SelectOption> pickListValuesList = pqt.pickListValuesList;
        //boolean needapproval = pqt.needsApproval;
        Price_Quote__c newPQ = pqt.pq2;
        pqt.getActiveQuoteIdStr();
        pqt.strProdSearch = '353535';

        // New with Opportunity Line Sync
        pqt.newCreateOpp();
        pqt.makeActivePQ();

        pqt.doCloning();
        pqt.updateFlag();
        pqt.updateRSMprice();
        pqt.updateRepPrice();
        pqt.updateListPrice();
        pqt.updateEligiblePrice();
        pqt.massUpdList();
        pqt.massUpdRSM();
        pqt.massUpdRep();
        pqt.massUpdEligible();
        pqt.sapPrice();
        pqt.Refresh();
        pqt.saveOneTime();
        pqt.AutoApprove();
        //updateQuantity
        PP_Price_Quote.updateQuantity(pqliID, 2);
        PP_Price_Quote.updatePrice(pqliID, 123.00);
        PP_Price_Quote.updateOrder(pqliID, 1);

        pageRefpre = new PageReference('/apex/PP_ApprovalLayout?pqid=' + pqstrID);
        system.debug('Approval Page' + pageRefpre);
        Test.setCurrentPage(pageRefpre);

        System.currentPageReference().getParameters().put('appComments', 'Test');

        pqt = new PP_Price_Quote(ctlr);
        Test.stopTest();
    }

    @isTest static void priceQuoteTest2() {
        //Created the contract user to fix the test failure issue
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;

            /*string pbid = pb.Id; // Used to create the Price Book through method
            pbid = pbid.left(15);

            PP_Opportunity_Sync_Test newST = new PP_Opportunity_Sync_Test();
            newST.pbinsert(pbid);*/

        system.debug('-- Starting priceQuoteTest2 --');
        
        //List<Sales_Orgs__c> newSalesOrgs = new List<Sales_Orgs__c>();
        Sales_Orgs__c salesOrgUs = testDataFactoryPP.createSalesOrg('US6010',true,'All','US60','10');
        //newSalesOrgs.add(salesOrgUs);
        insert salesOrgUs;

        Price_Quote__c pqid = [SELECT Id, BusinessUnit__c 
                               FROM Price_Quote__c
                               WHERE Line_Count__c > 0
                               LIMIT 1];
        system.debug('pqid: ' + pqid);

        string pqstrID = pqid.Id;
        pqstrID = pqstrID.left(15);

        string pqliID = [SELECT ID FROM Price_Quote_Line_Item__c LIMIT 1].Id;
        list<Price_Quote_Line_Item__c> pqliList = [SELECT Id, Material_Name__c, Sales_Price__c,
                                                   Eligible_Price__c, Sales_Deal_Description__c,
                                                   Material_Name__r.Cost__c, Material_Name__r.Transfer_Price__c,
                                                   Material_Name__r.Floor_Price__c, Material_Name__r.Director_Price__c,
                                                   RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Distributor_List__c,
                                                   Material_Name__r.Qty_Sales_Unit__c, Opportunity_Products_Line_ID__c, Material_Name__r.Cost_Formula__c
                                                   FROM Price_Quote_Line_Item__c WHERE Price_Quote__c =: pqstrID];
        system.debug('pqliList: ' + pqliList);

        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqstrID);
        system.debug('Price Quote Page' + pageRefpre);
        Test.setCurrentPage(pageRefpre);

        sales_Cockpit scp = new sales_Cockpit();

        System.currentPageReference().getParameters().put('rsmPrice', '100');
        System.currentPageReference().getParameters().put('pqid', pqstrID);
        System.currentPageReference().getParameters().put('repPrice', '100');
        System.currentPageReference().getParameters().put('listPrice', '100');
        System.currentPageReference().getParameters().put('eligiblePrice', '100');
        System.currentPageReference().getParameters().put('lineId', pqliID);
        System.currentPageReference().getParameters().put('trId', pqliID);
        System.currentPageReference().getParameters().put('sdnum', '50009064');

        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqid);
        PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
        Test.startTest();
        
        // New with Opportunity Line Sync
        pqt.newCreateOpp();
        pqt.makeActivePQ();

        pqt.doCloning();
        pqt.updateFlag();
        pqt.Refresh();
        pqt.saveOneTime();
        pqt.doUpdateOwnerValue();
        pqt.setBuHeader(pqid.BusinessUnit__c);
        
        //updateQuantity
        PP_Price_Quote.updateQuantity(pqliID, 2);
        PP_Price_Quote.updatePrice(pqliID, 99.00);
        PP_Price_Quote.updateOrder(pqliID, 1);

        pageRefpre = new PageReference('/apex/PP_ApprovalLayout?pqid=' + pqstrID);
        system.debug('Approval Page' + pageRefpre);
        Test.setCurrentPage(pageRefpre);

        System.currentPageReference().getParameters().put('appComments', 'Test');

        pqt = new PP_Price_Quote(ctlr);

        pqt.getPriceCheck(pqliList);
        pqt.getMargins(pqliList);
        pqt.getMinContract(pqliList);
        pqt.getMinContractAgree(pqliList);
        pqt.getMinGpo(pqliList);
        pqt.getMinGpoAgree(pqliList);

        Test.stopTest();

        // Opportunity Line Sync
        string prodId = [SELECT ID FROM Product2 LIMIT 1].Id;
        string newnewpqid = [SELECT ID FROM Price_Quote__c WHERE IsActive__c = TRUE LIMIT 1].Id;

        Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
            Price_Quote__c = newnewpqid,
            Material_Name__c = prodId,
            Sales_Price__c = 125.00,
            Eligible_Price__c = 230.00,
            Rep_Price__c = 350.00,
            RSM_Price__c = 330.00,
            List_Price__c = 380.00,
            Quantity__c = 1,
            Extended_Price__c = 230.00,
            Sales_Deal_Description__c = 'test',
            Product_Description__c='Test Description'
        );
        master_TriggerHelperClass.runOnce('resetOnceSet');
        insert PQLineItem;


        system.debug('-- Finished priceQuoteTest --');

    }//end of priceQuoteTest2

    @isTest static void oppSync() {
        // Add Price Quote to an Opportunity
        // Change the Price Quote
        string pqID1;
        string pqID2;
        integer pqloop = 1;

        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        for(Price_Quote__c pq : [SELECT ID FROM Price_Quote__c])
        {
            if(pqloop == 1){
                pqID1 = pq.Id;
                ++pqloop;
            }
            else{
                pqID2 = pq.Id;
            }

        }
        system.debug('pqID1: ' + pqID1 + ' pqID2: ' + pqID2);
        Opportunity opp1 = new Opportunity(
            Id = opp.Id,
            Price_Quote__c = pqID1
        );
        update opp1;

        opp1.Price_Quote__c = pqID2;
        master_TriggerHelperClass.runOnce('resetOnceSet');
        update opp1;

        // Set of ID's of OLI
        set<Id> testOLI = new set<Id>();
        for(OpportunityLineItem oli : [SELECT ID FROM OpportunityLineItem])
        {
            testOLI.add(oli.Id);
        }
        //PP_Opportunity_Sync newSync = new PP_Opportunity_Sync();
        PP_Opportunity_Sync.delOpportunityLines(testOLI);

        // List of PQOLI
        list<Price_Quote_Line_Item__c> testPQLI = [SELECT ID, Opportunity_Products_Line_ID__c FROM Price_Quote_Line_Item__c];
        PP_Opportunity_Sync.delOpportunityLines_trigger(testPQLI);

        string newnewpqid = [SELECT ID FROM Price_Quote__c WHERE IsActive__c = TRUE LIMIT 1].Id;

        string oid;
        string updatePQid;
        for(Opportunity o : [SELECT Id, Price_Quote__c FROM Opportunity WHERE Price_Quote__c != NULL LIMIT 1])
        {
            updatePQid = o.Price_Quote__c;
            oid = o.Id;
        }

        string newpqid = [SELECT Id FROM Price_Quote__c WHERE Id !=:newnewpqid LIMIT 1].Id;
        Opportunity updateOpp = new Opportunity(
            Id = oid,
            Price_Quote__c = newpqid
        );
        update updateOpp;

        list<OpportunityLineItem> oliList = [SELECT ID FROM OpportunityLineItem LIMIT 1];
        //PP_Opportunity_Sync newOppSync = new PP_Opportunity_Sync();
        //newOppSync.delOpportunityLines(oliList);
        //newOppSync.delOpportunityLines_trigger(oliList);
        if(oliList.size() > 0){
            delete oliList;
        }


    }//end of oppSync

    @isTest static void sapPriceTest() {

        list<String> materialStr2 = new list<String>();
        for(Product2 p : [SELECT Id FROM Product2 WHERE Name = '353535' LIMIT 1]){
            materialStr2.add(p.Id);
        }

        Account AccTest = [SELECT Id FROM Account LIMIT 1];
        Contact ConTest = [SELECT Id FROM Contact LIMIT 1];

        Price_Quote__c PQTest = [SELECT Id FROM Price_Quote__c WHERE Account_SAP_Code__c != NULL LIMIT 1];
        Price_Quote__c PQTest2 = [SELECT Id FROM Price_Quote__c WHERE Account_SAP_Code__c = NULL LIMIT 1];

        PP_SAP_Price sapPrice = new PP_SAP_Price();
        Test.startTest();
        sapPrice.getSAPprice(materialStr2, NULL,NULL,PQTest.Id);
        sapPrice.getSAPprice(materialStr2, NULL,NULL,PQTest2.Id);
        sapPrice.getSAPprice(materialStr2, 'refresh',NULL,PQTest2.Id);
        sapPrice.getSAPpriceBulk(materialStr2, PQTest.Id);
        sapPrice.getSAPpriceBulk(materialStr2, PQTest2.Id);
        sapPrice.lineClassCheck(PQTest.Id);
        sapPrice.lineClassCheck(PQTest2.Id);
        sapPrice.lineProdCheckAnes(PQTest.Id);
        sapPrice.lineProdCheckAnes(PQTest2.Id);
        sapPrice.lineProdCheckIcap(PQTest.Id);
        sapPrice.lineProdCheckIcap(PQTest2.Id);
        Test.stopTest();
    }

    @isTest static void noSapPriceTestLatam() {
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        Test.startTest();
        system.debug('-- Starting noSapPriceTestLatam --');
        
        //List<Sales_Orgs__c> newSalesOrgs = new List<Sales_Orgs__c>();
        //Sales_Orgs__c salesOrgLatam = testDataFactoryPP.createSalesOrg('US6020',true,'All','US60','20');
        //newSalesOrgs.add(salesOrgUs);
        //insert salesOrgLatam;
        
        //start creating Pricing Portal data records
        Account laAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '11',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
        Product2 laProd = testDataFactoryPP.createProduct2('laProd', 'US60', '20', '40');
        insert laProd;
        
        Price_Quote__c pqla = testDataFactoryPP.createPriceQuote(laAcc.Id, con1.Id, 'US6020', false, 'Latin America');
        insert pqLa;

        Price_Quote_Line_Item__c pqliLa = testDataFactoryPP.createPriceQLineItem(pqLa.Id, laProd.Id);
        insert pqliLa;
        
        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqla.Id);
        system.debug('*** Price Quote Page noSapPriceTestLatam *** ' + pageRefpre);
        Test.setCurrentPage(pageRefpre);
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
        PP_Price_Quote bulkPrice = new PP_Price_Quote(ctlr);
        System.currentPageReference().getParameters().put('pqid', pqla.Id);
        bulkPrice.bulkRefresh();
        Test.stopTest();
    }
    
    @isTest static void sapPriceTestLatam() {
        //Created the contract user to fix the test failure issue
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        
        Test.startTest();
        //start creating Pricing Portal data records
        system.debug('-- Starting sapPriceTestLatam --');
        
        //List<Sales_Orgs__c> newSalesOrgs = new List<Sales_Orgs__c>();
        //Sales_Orgs__c salesOrgLatam = testDataFactoryPP.createSalesOrg('US6020',true,'All','US60','20');
        //newSalesOrgs.add(salesOrgUs);
        //insert salesOrgLatam;
        
        //Account laAcc = testDataFactoryPP.createAccount('TestAcount LA', 'US60','999999','03');
        //insert laAcc; 
        
        Account laAcc = new Account(Name = 'latamSap',Account_Group__c = 'Z002',Customer_Group__c = '11', SAP_Sold_To__c = '999999', Sales_Org__c = 'US60',
                                    Distribution_Channel__c = '20',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
        Product2 laProd = testDataFactoryPP.createProduct2('laProd', 'US60', '20', '40');
        insert laProd;
        
        Price_Quote__c pqla = testDataFactoryPP.createPriceQuote(laAcc.Id, con1.Id, 'US6020', false, 'Latin America');
        insert pqLa;

        Price_Quote_Line_Item__c pqliLa = testDataFactoryPP.createPriceQLineItem(pqLa.Id, laProd.Id);
        insert pqliLa;
        
        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqla.Id);
        system.debug('*** Price Quote Page noSapPriceTestLatam *** ' + pageRefpre);
        Test.setCurrentPage(pageRefpre);
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
        PP_Price_Quote bulkPrice = new PP_Price_Quote(ctlr);
        System.currentPageReference().getParameters().put('pqid', pqla.Id);
        bulkPrice.bulkRefresh();
        Test.stopTest();
    }
    
    @isTest static void prfTest() {
        system.debug('-- Starting prfTest --');
        
        //List<Sales_Orgs__c> newSalesOrgs = new List<Sales_Orgs__c>();
        //Sales_Orgs__c salesOrgUs = testDataFactoryPP.createSalesOrg('US6010',true,'All','US60','10');
        //newSalesOrgs.add(salesOrgUs);
        //insert salesOrgUs;
        
        Quick_Disable__c qd = new Quick_Disable__c(
            Name = 'setTerritoryNumberOpp',
            Enable__c = TRUE
        );
        System.debug('insert qd-->' + qd);
        insert qd;
        
        user u = [SELECT ID, Business_Unit__c FROM USER WHERE email = 'unit.test@unit.teleflex.com' LIMIT 1];
        System.runAs(u){
        //SAP_Sold_To__c = '102059'
        list<String> materialStr2 = new list<String>();
        for(Product2 p : [SELECT Id FROM Product2 WHERE Name = '353535' LIMIT 1]){
            materialStr2.add(p.Id);
        }

        Account AccTest = [SELECT Id, Price_List_Type__c FROM Account WHERE SAP_Sold_To__c = '102059' LIMIT 1];
        Contact ConTest = [SELECT Id FROM Contact WHERE AccountID = :AccTest.Id LIMIT 1];

        Price_Quote__c PQTest = [SELECT Id FROM Price_Quote__c WHERE Account_SAP_Code__c = '102059' LIMIT 1];

        PRF__c prfTest = [SELECT Id FROM PRF__c WHERE Status__c = 'New' LIMIT 1];
        PRF__c prfTest5 = [SELECT Id FROM PRF__c WHERE Status__c = 'Approved' LIMIT 1];

        PRF_Line_Item__c prfLineItem = [SELECT Id FROM PRF_Line_Item__c LIMIT 1];

        // Testing PP_PRF Apex


        PageReference pageRefPRF = new PageReference('/apex/PP_PRF?id=' + prfTest.Id);
        system.debug('PRF Page' + pageRefPRF);
        Test.setCurrentPage(pageRefPRF);

        System.currentPageReference().getParameters().put('strProdSearch', '353535');
        System.currentPageReference().getParameters().put('bulkMatStr', '353535');
        System.currentPageReference().getParameters().put('id', prfTest.Id);
        System.currentPageReference().getParameters().put('aid', AccTest.Id);
        //System.currentPageReference().getParameters().put('pqid', prfTest.Id);
        System.currentPageReference().getParameters().put('step', '1');
        System.currentPageReference().getParameters().put('rsmPrice', '100');
        System.currentPageReference().getParameters().put('repPrice', '100');
        //System.currentPageReference().getParameters().put('listPrice', '100');
        System.currentPageReference().getParameters().put('eligiblePrice', '100');


        PP_PRF prfRec = new PP_PRF();

        Test.startTest();
        prfRec.strProdSearch = '353535';
        prfRec.bulkMatStr = '353535';
        prfRec.requestedPrice = 123.00;
        prfRec.prfid = prfTest.Id;
        prfRec.salesCurrency = 'USD';
        prfRec.salesOrgKey = 'US103010';
        prfRec.createPath = TRUE;
        //boolean needapproval = prfRec.needsApproval;
        prfRec.soldToAcctType = AccTest.Price_List_Type__c;
        prfRec.userBuAsk = u.Business_Unit__c;

        prfRec.soldToAcct = '102059';
        System.assertEquals(prfRec.soldToAcct, '102059');

        prfRec.soldToAcctType = 'ZH';
        System.assertEquals(prfRec.soldToAcctType, 'ZH');

        prfRec.getprf();
        prfRec.getPickListValuesIntoList();
        prfRec.createPDF();
        prfRec.save();
        prfRec.setBu();
        prfRec.msearch();
        prfRec.edit();
        prfRec.xls();
        prfRec.cancel();
        prfRec.gettodaysdate();
        PP_PRF.settu();
        prfRec.getPLI();
        prfRec.sapPrice();
        prfRec.sapBulkInsert();
        PP_PRF.updatePrice(prfLineItem.Id, 230.00);
        prfRec.Refresh();
        prfRec.removingRow();
        prfRec.createAuditPDF();
        //prfRec.createQuote();
        //prfRec.createQuote();
        //prfRec.getSAPprice(materialStr, requestedPrice, lineItemId, quoteId)
        prfRec.bulkrefresh();
        prfRec.updateType();
        //prfRec.Approve();
        //prfRec.Reject();
            
            prfRec.updateRepPrice();
            prfRec.updateRSMprice();
            prfRec.updateListprice();
            prfRec.massUpdEligible();
            prfRec.massUpdRep();
            prfRec.massUpdRsm();
            prfRec.massUpdList();
            //prfRec.updateTierPrice();
            prfRec.massUpdateTiers();
            prfRec.initCube();
            prfRec.requestHigherTierAccess();
            prfRec.setPriceToggle();
            prfRec.bulkrefresh();

        // New Stuff

        // get/set's
        boolean isApprover = prfRec.isApprover;
        boolean isDirect = prfRec.isDirect;
        boolean createPath = prfRec.createPath;
        boolean subButton = prfRec.subButton;
        List<SelectOption> options = prfRec.options;
        string mySalesOrg = prfRec.mySalesOrg;
        string appComments = prfRec.appComments;
        String userBu = prfRec.userBu;
        String buValue = prfRec.buValue;
        String userId = prfRec.userId;
        String currentBu = prfRec.currentBu;
        String wrkId = prfRec.wrkId;
        PRF__c prf2 = prfRec.prf2;
        prfRec.getgpoOptions();
        prfRec.updateGPO();
        prfRec.createQuote();

        Test.stopTest();
        // HERE

        PP_PRF sapPricePRF = new PP_PRF();
        sapPricePRF.getSAPprice(materialStr2, NULL, NULL, prfTest.Id);
        sapPricePRF.getSAPprice(materialStr2, NULL, NULL, prfTest5.Id);
        sapPricePRF.gettodaysdate();

        PageReference pageRefPRFEdit = new PageReference('/apex/PP_PRF_Edit');
        System.currentPageReference().getParameters().put('aid', AccTest.Id);
        System.currentPageReference().getParameters().put('cid', ConTest.Id);
        System.currentPageReference().getParameters().put('id', prfTest.Id);

        system.debug('PRF Page' + pageRefPRFEdit);
        Test.setCurrentPage(pageRefPRFEdit);

        PP_PRF prfEdit = new PP_PRF();
        }

    }//end of prfTest
    
    @isTest static void prfTest1() {
        Quick_Disable__c qd = new Quick_Disable__c(
            Name = 'setTerritoryNumberOpp',
            Enable__c = TRUE
        );
        System.debug('insert qd-->' + qd);
        insert qd;
        
        user u = [SELECT ID, Business_Unit__c FROM USER WHERE email = 'unit.test@unit.teleflex.com' LIMIT 1];
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
                    Territory_User__c tu = new Territory_User__c(
                    Territory_Master__c = tm.Id,
                    User__c = u.id
                );
                insert tu;
                System.debug('Insert Territory User-->' + tu);
            
        //SAP_Sold_To__c = '102059'
        list<String> materialStr2 = new list<String>();
        for(Product2 p : [SELECT Id FROM Product2 WHERE Name = '353535' LIMIT 1]){
            materialStr2.add(p.Id);
        }

        Account AccTest = [SELECT Id, Price_List_Type__c FROM Account WHERE SAP_Sold_To__c = '102059' LIMIT 1];
        Contact ConTest = [SELECT Id FROM Contact WHERE AccountID = :AccTest.Id LIMIT 1];

        Price_Quote__c PQTest = [SELECT Id FROM Price_Quote__c WHERE Account_SAP_Code__c = '102059' LIMIT 1];

        PRF__c prfTest = [SELECT Id FROM PRF__c WHERE Status__c = 'New' LIMIT 1];
        PRF__c prfTest5 = [SELECT Id FROM PRF__c WHERE Status__c = 'Approved' LIMIT 1];

        PRF_Line_Item__c prfLineItem = [SELECT Id FROM PRF_Line_Item__c LIMIT 1];

        // Testing PP_PRF Apex


        PageReference pageRefPRF = new PageReference('/apex/PP_PRF?id=' + prfTest.Id);
        system.debug('PRF Page' + pageRefPRF);
        Test.setCurrentPage(pageRefPRF);

        System.currentPageReference().getParameters().put('strProdSearch', '353535');
        System.currentPageReference().getParameters().put('bulkMatStr', '353535');
        System.currentPageReference().getParameters().put('id', prfTest.Id);
        System.currentPageReference().getParameters().put('aid', AccTest.Id);
        //System.currentPageReference().getParameters().put('pqid', prfTest.Id);
        System.currentPageReference().getParameters().put('step', '1');
        System.currentPageReference().getParameters().put('rsmPrice', '100');
        System.currentPageReference().getParameters().put('repPrice', '100');
        System.currentPageReference().getParameters().put('listPrice', '100');
        System.currentPageReference().getParameters().put('eligiblePrice', '100');


        PP_PRF prfRec = new PP_PRF();

        Test.startTest();
        prfRec.strProdSearch = '353535';
        prfRec.bulkMatStr = '353535';
        prfRec.requestedPrice = 123.00;
        prfRec.prfid = prfTest.Id;
        prfRec.salesCurrency = 'USD';
        prfRec.salesOrgKey = 'US103010';
        prfRec.createPath = TRUE;
        //boolean needapproval = prfRec.needsApproval;
        prfRec.soldToAcctType = AccTest.Price_List_Type__c;
        prfRec.userBuAsk = u.Business_Unit__c;

        prfRec.soldToAcct = '102059';
        System.assertEquals(prfRec.soldToAcct, '102059');

        prfRec.soldToAcctType = 'ZH';
        System.assertEquals(prfRec.soldToAcctType, 'ZH');

        prfRec.getprf();
        prfRec.getPickListValuesIntoList();
        prfRec.createPDF();
        prfRec.save();
        prfRec.setBu();
        prfRec.msearch();
        prfRec.edit();
        prfRec.xls();
        prfRec.cancel();
        prfRec.gettodaysdate();
        PP_PRF.settu();
        prfRec.getPLI();
        prfRec.sapPrice();
        prfRec.sapBulkInsert();
        PP_PRF.updatePrice(prfLineItem.Id, 230.00);
        prfRec.Refresh();
        prfRec.removingRow();
        prfRec.createAuditPDF();
        //prfRec.createQuote();
        //prfRec.createQuote();
        //prfRec.getSAPprice(materialStr, requestedPrice, lineItemId, quoteId)
        prfRec.bulkrefresh();
        prfRec.updateType();
        //prfRec.Approve();
        //prfRec.Reject();
            
            prfRec.updateRepPrice();
            prfRec.updateRSMprice();
            prfRec.updateListprice();
            prfRec.massUpdEligible();
            prfRec.massUpdRep();
            prfRec.massUpdRsm();
            prfRec.massUpdList();
            //prfRec.updateTierPrice();
            prfRec.massUpdateTiers();
            prfRec.initCube();
            prfRec.requestHigherTierAccess();
            prfRec.setPriceToggle();
            prfRec.bulkrefresh();

        // New Stuff

        // get/set's
        boolean isApprover = prfRec.isApprover;
        boolean isDirect = prfRec.isDirect;
        boolean createPath = prfRec.createPath;
        boolean subButton = prfRec.subButton;
        List<SelectOption> options = prfRec.options;
        string mySalesOrg = prfRec.mySalesOrg;
        string appComments = prfRec.appComments;
        String userBu = prfRec.userBu;
        String buValue = prfRec.buValue;
        String userId = prfRec.userId;
        String currentBu = prfRec.currentBu;
        String wrkId = prfRec.wrkId;
        PRF__c prf2 = prfRec.prf2;
        prfRec.getgpoOptions();
        prfRec.updateGPO();
        prfRec.createQuote();

        Test.stopTest();
// HERE

        PP_PRF sapPricePRF = new PP_PRF();
        sapPricePRF.getSAPprice(materialStr2, NULL, NULL, prfTest.Id);
        sapPricePRF.getSAPprice(materialStr2, NULL, NULL, prfTest5.Id);
        sapPricePRF.gettodaysdate();

        PageReference pageRefPRFEdit = new PageReference('/apex/PP_PRF_Edit');
        System.currentPageReference().getParameters().put('aid', AccTest.Id);
        System.currentPageReference().getParameters().put('cid', ConTest.Id);
        System.currentPageReference().getParameters().put('id', prfTest.Id);

        system.debug('PRF Page' + pageRefPRFEdit);
        Test.setCurrentPage(pageRefPRFEdit);

        PP_PRF prfEdit = new PP_PRF();


        }

    }

    @isTest static void prfTest2() {

        user u = [SELECT ID FROM USER WHERE email = 'unit.test@unit.teleflex.com' LIMIT 1];
        System.runAs(u){

            PRF__c prfTest = [SELECT Id FROM PRF__c WHERE Status__c = 'New' LIMIT 1];
            PRF__c prfTest5 = [SELECT Id FROM PRF__c WHERE Status__c = 'Approved' LIMIT 1];


        PageReference prExport = new PageReference('/apex/PP_PRF_Export?id=' + prfTest.Id);
        System.currentPageReference().getParameters().put('id', prfTest.Id);
        system.debug('PRF Page' + prExport);
        Test.setCurrentPage(prExport);

        PP_PRF_Export prfExport = new PP_PRF_Export();
        prfExport.getPLI();
        prfExport.getPRF();
        prfExport.getApprovalInfo();

        string rxls = prfExport.rxls;

        //Testing Approved
        prExport = new PageReference('/apex/PP_PRF_Export?id=' + prfTest5.Id);
        system.debug('PRF Page' + prExport);
        Test.setCurrentPage(prExport);

        prfExport = new PP_PRF_Export();
        prfExport.getPLI();
        prfExport.getPRF();
        System.currentPageReference().getParameters().put('id', prfTest5.Id);
        rxls = prfExport.rxls;

        PageReference pageRefPRF = new PageReference('/apex/PP_ApprovalLayoutPrf?id=' + prfTest.Id);
        system.debug('Approval Page' + pageRefPRF);
        Test.setCurrentPage(pageRefPRF);

        System.currentPageReference().getParameters().put('appComments', 'Test');

        }
    }

    @isTest static void prfAnalysisPage() {

        Account AccTest = [SELECT Id FROM Account LIMIT 1];

        PRF__c prfTest = [SELECT Id FROM PRF__c WHERE Status__c = 'New' LIMIT 1];

        // Testing PP_PRF Apex


        PageReference pageRefPRF = new PageReference('/apex/PP_PRF?id=' + prfTest.Id);
        system.debug('PRF Page' + pageRefPRF);
        Test.setCurrentPage(pageRefPRF);

        System.currentPageReference().getParameters().put('strProdSearch', '353535');
        System.currentPageReference().getParameters().put('bulkMatStr', '353535');
        System.currentPageReference().getParameters().put('id', prfTest.Id);
        System.currentPageReference().getParameters().put('aid', AccTest.Id);
        //System.currentPageReference().getParameters().put('pqid', prfTest.Id);
        System.currentPageReference().getParameters().put('step', '1');
        System.currentPageReference().getParameters().put('rsmPrice', '100');
        System.currentPageReference().getParameters().put('repPrice', '100');
        System.currentPageReference().getParameters().put('listPrice', '100');
        System.currentPageReference().getParameters().put('eligiblePrice', '100');


        PP_PRF prfRec = new PP_PRF();

        list<PRF_Line_Item__c > prfliList = [SELECT ID, Material_Name__c, Requested_Price__c,
                                                   Eligible_Price__c, Sales_Deal_Description__c,
                                                   Material_Name__r.Cost__c, Material_Name__r.Transfer_Price__c,
                                                   Material_Name__r.Floor_Price__c, Material_Name__r.Director_Price__c,
                                                   RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Distributor_List__c,
                                                   Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Cost_Formula__c
                                                   FROM PRF_Line_Item__c LIMIT 1];
        system.debug('prfliList: ' + prfliList);

        prfRec.getPriceCheck(prfliList);
        prfRec.getMargins(prfliList);
        prfRec.getMinContract(prfliList);
        prfRec.getMinContractAgree(prfliList);
        prfRec.getMinGpo(prfliList);
        prfRec.getMinGpoAgree(prfliList);

    }

    @isTest static void importCsvTest() {
        Test.startTest();
        //List<Sales_Orgs__c> newSalesOrgs = new List<Sales_Orgs__c>(newSalesOrgsSet);
        List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
        insert newSalesOrgs;
        
        //Create Pricing Portal Data Start
        //Ship-To Account
        Account accZ001 = testDataFactoryPP.createAccountZ002('TestAcount Z001', 'US60','999999','03');
        insert accZ001;            
        //Sold-To Account
        Account accZ002 = testDataFactoryPP.createAccount('TestAcount Z002', 'US60','999998','03');
        insert accZ002;
        //Distributor Account
        Account accDistr = testDataFactoryPP.createAccount('TestAcount Distr', 'US60','999997','11');
        insert accDistr;
        //Prospect Account ZH
        Account accPros = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '17', Sales_Org__c = 'US60', Distribution_Channel__c = '10',
                                      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                     );
        insert accPros;
        //Prospect Account ZD
        Account accProsZd = new Account(Name = 'No Sap Code ZD',Account_Group__c = 'Z002',Customer_Group__c = '11', Sales_Org__c = 'US60', Distribution_Channel__c = '10',
                                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                       );
        insert accProsZd;
        //Prospect Account ZA
        Account accProsZa = new Account(Name = 'No Sap Code ZA',Account_Group__c = 'Z002',Customer_Group__c = '03', Sales_Org__c = 'US60', Distribution_Channel__c = '10',
                                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                       );
        insert accProsZa;
        
        //Prospect Account Distributor List (LATAM Exports)
        Account accProsDistr = new Account(Name = 'No Sap Code Distr',Account_Group__c = 'Z001',Customer_Group__c = '11', Sales_Org__c = 'US60', Distribution_Channel__c = '20',
                                           RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                          );
        insert accProsDistr;
        //Distributor Account
        //public static Account createAccountNew(String accName, String salesOrg, String distChannel, String sapCode, String custGrp )
        Account accLaDistr = testDataFactoryPP.createAccountNew('TestAcount LaDistr', 'US60','20','999990','11');
        insert accLaDistr;
        
        //Links Ship-To to Sold-To Account for pricing
        Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('999998','999999');
        insert cp;
        
        //Ship-To Contact
        Contact conZ001 = testDataFactoryPP.createContact('ConZ001', 'Shipto', accZ001.Id);
        insert conZ001;
        //Sold-To Contact
        Contact conZ002 = testDataFactoryPP.createContact('ConZ002', 'Soldto', accZ002.Id);
        insert conZ002;
        //Distributor Contact
        Contact conDistr = testDataFactoryPP.createContact('ConDistr', 'Distr', accDistr.Id);
        insert conDistr;
        //Prospect Contact
        Contact conPros = testDataFactoryPP.createContact('ConPros', 'ContactPros', accPros.Id);
        insert conPros;
        //Prospect Contact ZD
        Contact conProsZd = testDataFactoryPP.createContact('ConProsZd', 'ContactProsZd', accProsZd.Id);
        insert conProsZd;
        //Prospect Contact ZA
        Contact conProsZa = testDataFactoryPP.createContact('ConProsZa', 'ContactProsZa', accProsZa.Id);
        insert conProsZa;
        //Prospect Contact Distributor List
        Contact conProsDistr = testDataFactoryPP.createContact('ConProsDistr', 'ContactProsDistr', accProsDistr.Id);
        insert conProsDistr;
        //Prospect Contact Distributor List
        Contact conLaDistr = testDataFactoryPP.createContact('ConLaDistr', 'ContactLaDistr', accLaDistr.Id);
        insert conLaDistr;
        
        //Products for PQ/PRFs
        Product2 usProd = testDataFactoryPP.createProduct2('usProd', 'US60', '10', '40');
        insert usProd;
        Product2 usProd1 = testDataFactoryPP.createProduct2('usProd1', 'US60', '10', '40');
        insert usProd1;
        Product2 laProd = testDataFactoryPP.createProduct2('laProd', 'US60', '20', '40');
        insert laProd;
        Product2 laProd1 = testDataFactoryPP.createProduct2('laProd1', 'US60', '20', '40');
        insert laProd1;
        
        //Contracts for Pricing Portal
        Contract_Header__c ch1 = testDataFactoryPP.createContractHeaderPt('50009064', '123310','D','US60');
        insert ch1;
        Contract_Header__c ch2 = testDataFactoryPP.createContractHeaderPt('50009065', '123310','D','US60');
        insert ch2;
        Contract_Header__c ch3 = testDataFactoryPP.createContractHeaderPt('50009066', '123310','D','US60');
        insert ch3;
        
        //Contract Materials for CHs
        Contract_Material__c cm1 = testDataFactoryPP.createContractMaterialPt(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c,
                                                                              'RESP-D',1,755.74,540,504,432,432);
        insert cm1; 
        Contract_Material__c cm2 = testDataFactoryPP.createContractMaterialPt(ch2.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c,
                                                                              'RESP-D',1,755.74,540,504,432,450);
        insert cm2;
        Contract_Material__c cm3 = testDataFactoryPP.createContractMaterialPt(ch3.Id, ch3.Agreement_Number__c, laProd.Name, laProd.Id, laProd.Sales_Org__c, '10', laProd.Distribution_Channel__c,
                                                                              'RESP-D',1,755.74,540,504,432,450);
        insert cm3;
        
        //PQ Ship-To Account
        Price_Quote__c pqZ001 = testDataFactoryPP.createPriceQuote(accZ001.Id, conZ001.Id, 'US6010', false, 'Respiratory');
        insert pqZ001;
        //PQ Sold-To Account
        Price_Quote__c pqZ002 = testDataFactoryPP.createPriceQuote(accZ002.Id, conZ002.Id, 'CA1010', false, 'Respiratory');
        insert pqZ002;
        //PQ Distributor Account
        Price_Quote__c pqDistr = testDataFactoryPP.createPriceQuote(accDistr.Id, conDistr.Id, 'US6010', false, 'Respiratory');
        insert pqDistr;
        //PQ Prospect Account ZH
        Price_Quote__c pqPros = testDataFactoryPP.createPriceQuote(accPros.Id, conPros.Id, 'US6010', false, 'Respiratory');
        insert pqPros;
        //PQ Prospect Account ZD
        Price_Quote__c pqProsZd = testDataFactoryPP.createPriceQuote(accProsZd.Id, conProsZd.Id, 'US6010', false, 'Respiratory');
        insert pqProsZd;
        //PQ Prospect Account ZA
        Price_Quote__c pqProsZa = testDataFactoryPP.createPriceQuote(accProsZa.Id, conProsZa.Id, 'US6010', false, 'Respiratory');
        insert pqProsZa;
        //PQ Prospect Account Distributor List (LATAM)
        Price_Quote__c pqProsDistr = testDataFactoryPP.createPriceQuote(accProsDistr.Id, conProsDistr.Id, 'US6020', false, 'Respiratory');
        insert pqProsDistr;
        //PQ Account Distributor List (LATAM)
        Price_Quote__c pqLaDistr = testDataFactoryPP.createPriceQuote(accLaDistr.Id, conLaDistr.Id, 'US6020', false, 'Respiratory');
        insert pqLaDistr;
        
        //PQ Line Item Ship-To Account
        Price_Quote_Line_Item__c pqliZ001 = testDataFactoryPP.createPqLineItemRefresh(pqZ001.Id, usProd.Id);
        insert pqliZ001;
        Price_Quote_Line_Item__c pqliZ0011 = testDataFactoryPP.createPqLineItemRefresh(pqZ001.Id, usProd1.Id);
        insert pqliZ0011;
        //PQ Line Item Sold-To Account
        Price_Quote_Line_Item__c pqliZ002 = testDataFactoryPP.createPqLineItemRefresh(pqZ002.Id, usProd.Id);
        insert pqliZ002;
        Price_Quote_Line_Item__c pqliZ0021 = testDataFactoryPP.createPqLineItemRefresh(pqZ002.Id, usProd1.Id);
        insert pqliZ0021;
        //PQ Line Item Distributor Account
        Price_Quote_Line_Item__c pqliDistr = testDataFactoryPP.createPqLineItemRefresh(pqDistr.Id, usProd.Id);
        insert pqliDistr;
        Price_Quote_Line_Item__c pqliDistr1 = testDataFactoryPP.createPqLineItemRefresh(pqDistr.Id, usProd1.Id);
        insert pqliDistr1;
        //PQ Line Item Prospect Account
        Price_Quote_Line_Item__c pqliPros = testDataFactoryPP.createPqLineItemRefresh(pqPros.Id, usProd.Id);
        insert pqliPros;
        Price_Quote_Line_Item__c pqliPros1 = testDataFactoryPP.createPqLineItemRefresh(pqPros.Id, usProd1.Id);
        insert pqliPros1;
        //PQ Line Item Prospect Account
        Price_Quote_Line_Item__c pqliProsDistr = testDataFactoryPP.createPqLineItemRefresh(pqProsDistr.Id, laProd.Id);
        insert pqliProsDistr;
        Price_Quote_Line_Item__c pqliProsDistr1 = testDataFactoryPP.createPqLineItemRefresh(pqProsDistr.Id, laProd1.Id);
        insert pqliProsDistr1;
        //PQ Line Item Prospect Account
        Price_Quote_Line_Item__c pqliLaDistr = testDataFactoryPP.createPqLineItemRefresh(pqLaDistr.Id, laProd.Id);
        insert pqliLaDistr;
        Price_Quote_Line_Item__c pqliLaDistr1 = testDataFactoryPP.createPqLineItemRefresh(pqLaDistr.Id, laProd1.Id);
        insert pqliLaDistr1;
        
        //PRF Ship-To Account
        Prf__c prfZ001 = testDataFactoryPP.createPrf(accZ001.Id, conZ001.Id, 'US6010', 'Anesthesia');
        insert prfZ001;
        //PRF Sold-To Account
        Prf__c prfZ002 = testDataFactoryPP.createPrf(accZ002.Id, conZ002.Id, 'US6010', 'Anesthesia');
        insert prfZ002;
        //PRF Distributor Account
        Prf__c prfDistr = testDataFactoryPP.createPrf(accDistr.Id, conDistr.Id, 'US6010', 'Anesthesia');
        insert prfDistr;
        //PRF Prospect Account
        Prf__c prfPros = testDataFactoryPP.createPrf(accPros.Id, conPros.Id, 'US6010', 'Anesthesia');
        insert prfPros;
        
        //PRF Line Items Ship-To Account
        Prf_Line_Item__c prfliZ001 = testDataFactoryPP.createPrfLineItem(prfZ001.Id, usProd.Id);
        insert prfliZ001;
        Prf_Line_Item__c prfliZ0011 = testDataFactoryPP.createPrfLineItem(prfZ001.Id, usProd1.Id);
        insert prfliZ0011;
        //PRF Line Items Sold-To Account
        Prf_Line_Item__c prfliZ002 = testDataFactoryPP.createPrfLineItem(prfZ002.Id, usProd.Id);
        insert prfliZ002;
        Prf_Line_Item__c prfliZ0021 = testDataFactoryPP.createPrfLineItem(prfZ002.Id, usProd1.Id);
        insert prfliZ0021;
        //PRF Line Items Distributor Account
        Prf_Line_Item__c prfliDistr = testDataFactoryPP.createPrfLineItem(prfDistr.Id, usProd.Id);
        insert prfliDistr;
        Prf_Line_Item__c prfliDistr1 = testDataFactoryPP.createPrfLineItem(prfDistr.Id, usProd1.Id);
        insert prfliDistr1;
        
        //PRF Line Items Prospect Account
        Prf_Line_Item__c prfliPros = testDataFactoryPP.createPrfLineItem(prfPros.Id, usProd.Id);
        insert prfliPros;
        Prf_Line_Item__c prfliPros1 = testDataFactoryPP.createPrfLineItem(prfPros.Id, usProd1.Id);
        insert prfliPros1;
        //Pricing Portal Data End
        
        //Static Resources for CSV Load
        StaticResource testdoc1 = [Select Id,Body,Name from StaticResource where name = 'importCsv1'];
        StaticResource testdoc2 = [Select Id,Body,Name from StaticResource where name = 'importCsv2'];
        StaticResource testdoc3 = [Select Id,Body,Name from StaticResource where name = 'importCsv3'];
        
        //handles import csv PQ for Sold-To ZA Account
        PageReference csvImportPageZa = new PageReference('/apex/PP_ImportCsv?pqId=' + pqZ001.Id);
        Test.setCurrentPage(csvImportPageZa);
        PP_ImportCsv csvImportZa = new PP_ImportCsv();
        System.currentPageReference().getParameters().put('pqId', pqZ001.Id);
        csvImportZa.csvFileBody = testdoc1.body;
        csvImportZa.importCSVFile();
        String query1 = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Sales_Price__c FROM Price_Quote_Line_Item__c WHERE refresh__c = true AND Price_Quote__c = \''+pqZ001.Id+'\'';
        PP_ImportCsvBatch batch1 = new PP_ImportCsvBatch(query1);
        Database.executeBatch(batch1);
        
        //handles import csv PQ for ZD Distributor Account
        PageReference csvImportPageDistr = new PageReference('/apex/PP_ImportCsv?pqId=' + pqDistr.Id);
        Test.setCurrentPage(csvImportPageDistr);
        PP_ImportCsv csvImportZd = new PP_ImportCsv();
        System.currentPageReference().getParameters().put('pqId', pqDistr.Id);
        csvImportZd.csvFileBody = testdoc1.body;
        csvImportZd.importCSVFile();
        String query2 = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Sales_Price__c FROM Price_Quote_Line_Item__c WHERE refresh__c = true AND Price_Quote__c = \''+pqDistr.Id+'\'';
        PP_ImportCsvBatch batch2 = new PP_ImportCsvBatch(query2);
        Database.executeBatch(batch2);
        
        //handles import csv PQ for ZH Prospect Account
        PageReference csvImportPagePros = new PageReference('/apex/PP_ImportCsv?pqId=' + pqPros.Id);
        Test.setCurrentPage(csvImportPagePros);
        PP_ImportCsv csvImportPros = new PP_ImportCsv();
        System.currentPageReference().getParameters().put('pqId', pqPros.Id);
        csvImportPros.csvFileBody = testdoc1.body;
        csvImportPros.importCSVFile();
        String query3 = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Sales_Price__c FROM Price_Quote_Line_Item__c WHERE refresh__c = true AND Price_Quote__c = \''+pqPros.Id+'\'';
        PP_ImportCsvBatch batch3 = new PP_ImportCsvBatch(query3);
        Database.executeBatch(batch3);
        
        //handles import csv PQ for ZD Prospect Account
        PageReference csvImportPageProsZd = new PageReference('/apex/PP_ImportCsv?pqId=' + pqProsZd.Id);
        Test.setCurrentPage(csvImportPageProsZd);
        PP_ImportCsv csvImportProsZd = new PP_ImportCsv();
        System.currentPageReference().getParameters().put('pqId', pqProsZd.Id);
        csvImportProsZd.csvFileBody = testdoc1.body;
        csvImportProsZd.importCSVFile();
        String query4 = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Sales_Price__c FROM Price_Quote_Line_Item__c WHERE refresh__c = true AND Price_Quote__c = \''+pqProsZd.Id+'\'';
        PP_ImportCsvBatch batch4 = new PP_ImportCsvBatch(query4);
        Database.executeBatch(batch4);
        
        //handles import csv PQ for ZA Prospect Account
        PageReference csvImportPageProsZa = new PageReference('/apex/PP_ImportCsv?pqId=' + pqProsZa.Id);
        Test.setCurrentPage(csvImportPageProsZa);
        PP_ImportCsv csvImportProsZa = new PP_ImportCsv();
        System.currentPageReference().getParameters().put('pqId', pqProsZa.Id);
        csvImportProsZa.csvFileBody = testdoc1.body;
        csvImportProsZa.importCSVFile();
        String query5 = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Sales_Price__c FROM Price_Quote_Line_Item__c WHERE refresh__c = true AND Price_Quote__c = \''+pqProsZa.Id+'\'';
        PP_ImportCsvBatch batch5 = new PP_ImportCsvBatch(query5);
        Database.executeBatch(batch5);
        
        //handles import csv PQ for Account Distributor List
        PageReference csvImportPageLaDistr = new PageReference('/apex/PP_ImportCsv?pqId=' + pqLaDistr.Id);
        Test.setCurrentPage(csvImportPageLaDistr);
        PP_ImportCsv csvImportLaDistr = new PP_ImportCsv();
        System.currentPageReference().getParameters().put('pqId', pqLaDistr.Id);
        csvImportLaDistr.csvFileBody = testdoc3.body;
        csvImportLaDistr.importCSVFile();
        String query6 = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Sales_Price__c FROM Price_Quote_Line_Item__c WHERE refresh__c = true AND Price_Quote__c = \''+pqLaDistr.Id+'\'';
        PP_ImportCsvBatch batch6 = new PP_ImportCsvBatch(query6);
        Database.executeBatch(batch6);
        
        //handles import csv PQ for Prospect Account Distributor List
        PageReference csvImportPageProsDistr = new PageReference('/apex/PP_ImportCsv?pqId=' + pqProsDistr.Id);
        Test.setCurrentPage(csvImportPageProsDistr);
        PP_ImportCsv csvImportProsDistr = new PP_ImportCsv();
        System.currentPageReference().getParameters().put('pqId', pqProsDistr.Id);
        csvImportProsDistr.csvFileBody = testdoc3.body;
        csvImportProsDistr.importCSVFile();
        String query7 = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Sales_Price__c FROM Price_Quote_Line_Item__c WHERE refresh__c = true AND Price_Quote__c = \''+pqProsDistr.Id+'\'';
        PP_ImportCsvBatch batch7 = new PP_ImportCsvBatch(query7);
        Database.executeBatch(batch7);
        
        //handles import csv PRF Ship-To
        PageReference csvImportPagePrfZ001 = new PageReference('/apex/PP_ImportCsvPrf?Id=' + prfZ001.Id);
        Test.setCurrentPage(csvImportPagePrfZ001);
        PP_ImportCsvPrf csvImportPrfZ001 = new PP_ImportCsvPrf();
        System.currentPageReference().getParameters().put('id', prfZ001.Id);
        String query8 = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Requested_Price__c FROM Prf_Line_Item__c WHERE refresh__c = true AND Prf__c = \''+prfZ001.Id+'\'';
        csvImportPrfZ001.csvFileBody = testdoc1.body;
        csvImportPrfZ001.importCSVFile();
        PP_ImportCsvBatch batch8 = new PP_ImportCsvBatch(query8);
        Database.executeBatch(batch8);
        
        //handles import csv PRF Distributor Account
        PageReference csvImportPagePrfDistr = new PageReference('/apex/PP_ImportCsvPrf?Id=' + prfDistr.Id);
        Test.setCurrentPage(csvImportPagePrfDistr);
        PP_ImportCsvPrf csvImportPrfDistr = new PP_ImportCsvPrf();
        System.currentPageReference().getParameters().put('id', prfDistr.Id);
        String query9 = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Requested_Price__c FROM Prf_Line_Item__c WHERE refresh__c = true AND Prf__c = \''+prfDistr.Id+'\'';
        csvImportPrfDistr.csvFileBody = testdoc1.body;
        csvImportPrfDistr.importCSVFile();
        PP_ImportCsvBatch batch9 = new PP_ImportCsvBatch(query9);
        Database.executeBatch(batch9);
        
        //handles import csv PRF Prospect Account
        PageReference csvImportPagePrfPros = new PageReference('/apex/PP_ImportCsvPrf?Id=' + prfPros.Id);
        Test.setCurrentPage(csvImportPagePrfPros);
        PP_ImportCsvPrf csvImportPrfPros = new PP_ImportCsvPrf();
        System.currentPageReference().getParameters().put('id', prfPros.Id);
        String query10 = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Requested_Price__c FROM Prf_Line_Item__c WHERE refresh__c = true AND Prf__c = \''+prfPros.Id+'\'';
        csvImportPrfPros.csvFileBody = testdoc1.body;
        csvImportPrfPros.importCSVFile();
        PP_ImportCsvBatch batch10 = new PP_ImportCsvBatch(query10);
        Database.executeBatch(batch10);
    }//end of importCsvTest

    @isTest static void importCsvTest2() {
        Test.startTest();
        //List<Sales_Orgs__c> newSalesOrgs = new List<Sales_Orgs__c>(newSalesOrgsSet);
        List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
        insert newSalesOrgs;
        
        //Create Pricing Portal Data Start
        //Prospect Account Distributor List (LATAM Exports)
        Account accProsDistr = new Account(Name = 'No Sap Code Distr',Account_Group__c = 'Z001',Customer_Group__c = '11', Sales_Org__c = 'US60', Distribution_Channel__c = '20',
                                           RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                          );
        insert accProsDistr;
        //Distributor Account

        //Prospect Contact Distributor List
        Contact conProsDistr = testDataFactoryPP.createContact('ConProsDistr', 'ContactProsDistr', accProsDistr.Id);
        insert conProsDistr;
        
        //Products for PQ/PRFs
        Product2 laProd = testDataFactoryPP.createProduct2('laProd', 'US60', '20', '40');
        insert laProd;
        Product2 laProd1 = testDataFactoryPP.createProduct2('laProd1', 'US60', '20', '40');
        insert laProd1;
        
        //Contracts for Pricing Portal
        Contract_Header__c ch3 = testDataFactoryPP.createContractHeaderPt('50009066', '123310','D','US60');
        insert ch3;
        
        //Contract Materials for CHs
        Contract_Material__c cm3 = testDataFactoryPP.createContractMaterialPt(ch3.Id, ch3.Agreement_Number__c, laProd.Name, laProd.Id, laProd.Sales_Org__c, '10', laProd.Distribution_Channel__c,
                                                                              'RESP-D',1,755.74,540,504,432,450);
        insert cm3;
        
        //PQ Prospect Account Distributor List (LATAM)
        Price_Quote__c pqProsDistr = testDataFactoryPP.createPriceQuote(accProsDistr.Id, conProsDistr.Id, 'US6020', false, 'Respiratory');
        insert pqProsDistr;
        system.debug('*** pqProsDistr.Id *** ' + pqProsDistr.Id );    
        
        //PQ Line Item Prospect Account
        Price_Quote_Line_Item__c pqliProsDistr = testDataFactoryPP.createPriceQLineItem(pqProsDistr.Id, laProd.Id);
        insert pqliProsDistr;
        Price_Quote_Line_Item__c pqliProsDistr1 = testDataFactoryPP.createPriceQLineItem(pqProsDistr.Id, laProd1.Id);
        insert pqliProsDistr1;
        //Pricing Portal Data End
        Price_Quote_Line_Item__c pqlisProsDistrU = new Price_Quote_Line_Item__c(Id=pqliProsDistr.Id,Refresh__c=true);
        update pqlisProsDistrU;
        
        Price_Quote_Line_Item__c pqlisProsDistrU1 = new Price_Quote_Line_Item__c(Id=pqliProsDistr1.Id,Refresh__c=true);
        update pqlisProsDistrU1;
        
        //Static Resources for CSV Load
        StaticResource testdoc1 = [Select Id,Body,Name from StaticResource where name = 'importCsv1'];
        StaticResource testdoc2 = [Select Id,Body,Name from StaticResource where name = 'importCsv2'];
        StaticResource testdoc3 = [Select Id,Body,Name from StaticResource where name = 'importCsv3'];
        
        //handles import csv PQ for Prospect Account Distributor List
        PageReference csvImportPageProsDistr = new PageReference('/apex/PP_ImportCsv?pqId=' + pqProsDistr.Id);
        Test.setCurrentPage(csvImportPageProsDistr);
        PP_ImportCsv csvImportProsDistr = new PP_ImportCsv();
        System.currentPageReference().getParameters().put('pqId', pqProsDistr.Id);
        csvImportProsDistr.csvFileBody = testdoc1.body;
        csvImportProsDistr.importCSVFile();
        String myId = pqProsDistr.Id;
        system.debug('*** pqProsDistr.Id *** ' + pqProsDistr.Id );
        String myId2 = myId.left(15);
        system.debug('*** myId2 *** ' + myId2 );
        String query7 = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Sales_Price__c FROM Price_Quote_Line_Item__c WHERE refresh__c = true AND Price_Quote__c = \''+pqProsDistr.Id+'\'';
        List<Price_Quote_Line_Item__c> queryList = [SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Sales_Price__c FROM Price_Quote_Line_Item__c WHERE refresh__c = true AND Price_Quote__c =:myId2];
        system.debug('*** queryList.size() PP_Global_Test_Class *** ' + queryList.size() );
        
        PP_ImportCsvBatch batch7 = new PP_ImportCsvBatch(query7);
        Database.executeBatch(batch7);

        Test.stopTest();
    }//end of importCsvTest2
    
    @isTest static void PriceLookupTest() {

        PP_Price_Lookup pl0 = new PP_Price_Lookup();
        pl0.getAccts();

        user u = [SELECT ID FROM USER WHERE email = 'unit.test@unit.teleflex.com' LIMIT 1];
        System.runAs(u){


            PageReference pager = page.PP_Price_Lookup;
            pager.getParameters().put('pid', '353535');
            pager.getParameters().put('cid', '102059');
            Test.setCurrentPage(pager);
            PP_Price_Lookup pl = new PP_Price_Lookup();
            System.assertNotEquals(NULL, pl.soldToAcct);
            pl.getAccts();
            pl.getPrice();
            string pid = pl.pid;
            string cid = pl.cid;
            pl.status = '40';
            pl.cnumber = '102059';
            pl.pnumber = '353535';
            pl.priceTable = TRUE;
            pl.errorTable = TRUE;
            pl.AcctProdTable = TRUE;
            pl.salesCurrency = 'USD';
            pl.salesOrgKey = 'US103010';
            pl.getSample();
            pl.getURL();
            pl.getAccts();
            pl.getp();
            List<Account> getAccts = pl.getAccts();

            //Test with Account Group Z001
            PageReference pager1 = page.PP_Price_Lookup;
            pager1.getParameters().put('pid', '353535');
            pager1.getParameters().put('cid', '150322');
            Test.setCurrentPage(pager1);
            //PP_Price_Lookup pl1 = new PP_Price_Lookup();
            System.assertEquals(NULL, pl.soldToAcct);

            //Test with blank material
            PageReference pager2 = page.PP_Price_Lookup;
            pager2.getParameters().put('pid', '');
            pager2.getParameters().put('cid', '150322');
            Test.setCurrentPage(pager2);
            //PP_Price_Lookup pl2 = new PP_Price_Lookup();

            //Test with blank customer
            PageReference pager3 = page.PP_Price_Lookup;
            pager3.getParameters().put('pid', '353535');
            pager3.getParameters().put('cid', '');
            Test.setCurrentPage(pager3);
            //PP_Price_Lookup pl3 = new PP_Price_Lookup();

            //Test with blank customer and material
            PageReference pager4 = page.PP_Price_Lookup;
            pager4.getParameters().put('pid', '');
            pager4.getParameters().put('cid', '');
            Test.setCurrentPage(pager4);
            //PP_Price_Lookup pl4 = new PP_Price_Lookup();
        }
    }

    public static String CRON_EXP = '0 0 0 15 3 ? 2030';

    @isTest static void Daily_Cleanup_Test() {
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP,
                                       new PP_Daily_Cleanup());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger
                          WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2030-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        // Verify the scheduled job hasn't run yet.
        // Merchandise__c[] ml = [SELECT Id FROM Merchandise__c WHERE Name = 'Scheduled Job Item'];
        // System.assertEquals(ml.size(),0);
        Test.stopTest();

        // Now that the scheduled job has executed after Test.stopTest(),
        // fetch the new merchandise that got added.
        // ml = [SELECT Id FROM Merchandise__c WHERE Name = 'Scheduled Job Item'];
        // System.assertEquals(ml.size(), 1);
    }
    
    @isTest static void testCreatePQ() {

        Id oid = [SELECT Id FROM Opportunity LIMIT 1].Id;

        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote_Redirect?oid=' + oid);
        Test.setCurrentPage(pageRefpre);

        PP_Price_Quote_Redirect pqr = new PP_Price_Quote_Redirect();
        pqr.redirect();

    }
    
    @isTest static void acctRecTypes() {
       
          Account accTest100 = new Account(
                Name = 'TestAccount100',
                SAP_Sold_To__c = '123458',
                Account_Group__c = 'Z002',
                Customer_Group__c = '16',
                zBlock__c = '00',
                ERP_Active__c = TRUE,
                Sales_Org__c = 'US60'
            );
            insert accTest100;

            Account accTest108 = new Account(
                Name = 'TestAccount108',
                SAP_Sold_To__c = '123459',
                Account_Group__c = 'Z002',
                Customer_Group__c = '01',
                zBlock__c = '00',
                ERP_Active__c = FALSE,
                Sales_Org__c = 'CO10',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
            );
            insert accTest108;
        System.assertEquals(accTest108.RecordTypeId, Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId());

            Account accTest109 = new Account(
                Name = 'TestAccount109',
                zBlock__c = '00',
                ERP_Active__c = FALSE
            );
            insert accTest109;
        
     }//end of acctRecTypes
    
    @isTest static void testPrfSap00Zd() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUserAu('USman1', 'User1', 'Sales Manager', 'Interventional Capital');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUserAu('US101', 'User101', 'Sales Rep', 'Interventional Capital');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

        System.runAs(usUser){
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
             
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            //Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','999999','03');
            //insert usACC;            
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '11',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
            );
            insert usAcc;
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct2('usProd', 'US60', '10', '40');
            insert usProd;
            Product2 usProd1 = testDataFactoryPP.createProduct2('usProd1', 'US60', '10', '40');
            insert usProd1;
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US60');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US60');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US60');
            insert ch4;
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
                       
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUs;
            pqUs.Status__c = 'Approved';
            update pqUs;
            
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
        
            //Start PQ stuff
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
    
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            Test.startTest();
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            
            
            List<String> materialStr = new List<String>();
            List<String> materialStr1 = new List<String>();
            List<String> materialStr2 = new List<String>();
            materialStr.add(usProd.Name);
            materialStr1.add(usProd1.Name);
            materialStr2.add(usProd2.Name);
            pqt.bulkrefresh();
            //pq.getSAPprice(materialStr, NULL, prfliUs.Id, prfUs.Id);
            //pq.getSAPprice(materialStr1, NULL, prfliUs1.Id, prfUs.Id);
            //pq.getSAPprice(materialStr2, NULL, prfliUs2.Id, prfUs.Id);
            //prf.updateTierPrice();
            //prf.sapPrice();
            //prf.sapBulkInsert();
            Test.stopTest();
        }//end of system run

    }//end of testPrfSap00Zd test method
    
    /********************************** NEW TESTING METHODS 09092021 **********************************/
    @isTest static void contractTesting() {

        system.debug('-- Starting contractTesting --');

        //createUserGb(String firstName, String lastName, String approvalRole, String bu)
        User uUs = new User();
        User uAu = new User();
        uUs = testDataFactoryPP.createUser('Firstus', 'Lastus', 'Sales Manager', 'Respiratory');
        uAU = testDataFactoryPP.createUserGb('Firstau', 'LastAu', 'Sales Rep', 'Alternate Care');
        
        //START SETUP PRICING PORTAL RECORDS
        //Setup Pricing Portal Account records
        System.runAs(uAU){
            //Created contract user to resolve the test class errors
            Contract_User__c cuAu = testDataFactoryPP.createPricingPortalUser(uAU.Name, uAU.Id, 'US - Teleflex', 'US6010', 4);
            Insert cuAu;
            
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','999999','03');
            insert usACC;            
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct2('usProd', 'US60', '10', '40');
            insert usProd;
            Product2 usProd1 = testDataFactoryPP.createProduct2('usProd1', 'US60', '10', '40');
            insert usProd1;
            Product2 usProd2 = testDataFactoryPP.createProduct2('usProd2', 'US60', '10', '40');
            insert usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '10');
            insert usProd3;
            
            List<Product2> plist = new List<Product2>();
            plist.add(usProd);
            plist.add(usProd1);
            plist.add(usProd2);
            plist.add(usProd3);
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeaderPt('50009064', '123310','D','US60');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeaderPt('50009065', '123310','D','US60');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeaderPt('50009066', '123310','M','US60');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeaderPt('50009067', '123310','R','US60');
            insert ch4;
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeaderPt('50009067', '123310','R','US60');
            insert ch5;
            
            Contract_Header__c ch6 = testDataFactoryPP.createContractHeaderPt('50009067', '123310','R','US60');
            insert ch6;
            
            //Setup Contract Materials
            /*
            createContractMaterialPt(String agreeHeaderId, String agreeNum, String prodName, String prodId,
            String salesOrg, String div, String distChannel, String gpoRef, Integer levelFix,
            Decimal listPrice, Decimal repPrice, Decimal rsmPrice, Decimal dirPrice, Decimal conPrice) 
            */
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterialPt(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c,
                                                                                  'RESP-D',1,755.74,540,504,432,432);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterialPt(ch2.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c,
                                                                                  'RESP-D',1,755.74,540,504,432,450);
            insert cm2;
            
            Contract_Material__c cm3 = testDataFactoryPP.createContractMaterialPt(ch3.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c,
                                                                                  'RESP-M',1,755.74,540,504,432,522);
            insert cm3;
            
            Contract_Material__c cm4 = testDataFactoryPP.createContractMaterialPt(ch4.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c,
                                                                                  'RESP-R',1,755.74,540,504,432,576);
            insert cm4;
            
            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterialPt(ch5.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c,
                                                                                  'RESP-R',1,755.74,540,504,432,594);
            insert cm5;
            
            Contract_Material__c cm6 = testDataFactoryPP.createContractMaterialPt(ch6.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c,
                                                                                  'RESP-R',1,755.74,540,504,432,625);
            insert cm6;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            //Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            //insert cc1;
            
            //Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            //insert cc2;
            
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Respiratory');
            insert pqUs;
            pqUs = new Price_Quote__c(id=pqUs.Id, Type__c = 'ASK Agreement');            
            update pqUs;
            //pqUs.Status__c = 'Approved';
            //update pqUs;
            
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            //END SETUP PRICING PORTAL RECORDS
            
            System.debug('*** pqliUs *** ' + pqliUs);
            System.debug('*** pqliUs1 *** ' + pqliUs1);
            System.debug('*** pqliUs2 *** ' + pqliUs2);
            
            Test.startTest();
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);            
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);           

            System.currentPageReference().getParameters().put('strProdSearch', 'usProd3');
            System.currentPageReference().getParameters().put('refresh', 'yes');
            System.currentPageReference().getParameters().put('key', 'List');
            System.currentPageReference().getParameters().put('rsmPrice', '400');
            System.currentPageReference().getParameters().put('repPrice', '420');
            System.currentPageReference().getParameters().put('listPrice', '600');
            System.currentPageReference().getParameters().put('eligiblePrice', '375');
            System.currentPageReference().getParameters().put('lineId', pqliUs.Id);
            System.currentPageReference().getParameters().put('lineQty', '5');
                        
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            pqt.Refresh();
            pqt.sapPrice();
            pqt.updateRSMprice();
            pqt.updateRepPrice();
            pqt.updateListPrice();
            pqt.updateEligiblePrice();
            
            pqUs = new Price_Quote__c(id=pqUs.Id, Type__c = 'ASK Agreement');
            update pqUs;
            System.currentPageReference().getParameters().put('strProdSearch', 'usProd2');
            pqt.sapPrice();
            Test.stopTest();
            
            system.debug('-- Finished contractTesting --');
        }
    }//end of contractTesting
    /********************************** NEW TESTING METHODS 09092021 **********************************/
    @isTest static void getSalesOrgMapTesting() {
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        
        List<Sales_Orgs__c> soList = testDataFactoryPP.createSalesOrgsAll();
        
        Test.startTest();
        system.debug('-- Starting getSalesOrgMapTesting --');
                
        Account laAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '11',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
        Product2 laProd = testDataFactoryPP.createProduct2('laProd', 'US60', '20', '40');
        insert laProd;
        
        Price_Quote__c pqla = testDataFactoryPP.createPriceQuote(laAcc.Id, con1.Id, 'US6020', false, 'Latin America');
        insert pqLa;

        Price_Quote_Line_Item__c pqliLa = testDataFactoryPP.createPriceQLineItem(pqLa.Id, laProd.Id);
        insert pqliLa;
        
        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqla.Id);        
        Test.setCurrentPage(pageRefpre);
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
        PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
        System.currentPageReference().getParameters().put('pqid', pqla.Id);
        //Map<String,String> salesOrgMap = priceQuote.getSalesOrgMap();
        Test.stopTest();
    }
    
    
    //added on 31st May 2023
     @isTest static void getSalesOrgMapTesting2() {
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        
        List<Sales_Orgs__c> soList = [SELECT Id FROM Sales_Orgs__c];
        for(Sales_Orgs__c so: soList){
            so.Active__c = false;
        }
        update soList;
        
        Test.startTest();
        system.debug('-- Starting getSalesOrgMapTesting --');
                
        Account laAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '11',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
        Product2 laProd = testDataFactoryPP.createProduct2('laProd', 'US60', '20', '40');
        insert laProd;
        
        Price_Quote__c pqla = testDataFactoryPP.createPriceQuote(laAcc.Id, con1.Id, 'US6020', false, 'Latin America');
        pqla.Language__c = 'French';
        insert pqLa;

        Price_Quote_Line_Item__c pqliLa = testDataFactoryPP.createPriceQLineItem(pqLa.Id, laProd.Id);
        insert pqliLa;
       
        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqla.Id);        
        Test.setCurrentPage(pageRefpre);
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
        PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
        System.currentPageReference().getParameters().put('pqid', pqla.Id);
      //  Map<String,String> salesOrgMap = priceQuote.getSalesOrgMap();
        Test.stopTest();
    }
    
     @isTest static void getFormatRepPricesTest() {
         
         delete [select id from Account];
         delete [select id from Price_Quote__c];
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        
        List<Sales_Orgs__c> soList = [SELECT Id FROM Sales_Orgs__c];
        for(Sales_Orgs__c so: soList){
            so.Active__c = false;
        }
        update soList;
         
        Test.startTest();
        system.debug('-- Starting getSalesOrgMapTesting --');
                
        Account laAcc = new Account(Name = 'John Doe',Account_Group__c = 'Z002',Customer_Group__c = '11',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
        Product2 laProd = testDataFactoryPP.createProduct2('laProd', 'US60', '20', '40');
        insert laProd;
        
        Price_Quote__c pqla = testDataFactoryPP.createPriceQuote(laAcc.Id, con1.Id, 'US6020', false, 'Latin America');
        pqla.Language__c = 'French';
         pqla.Account_Name__c = laAcc.Id;
        insert pqLa;

        Price_Quote_Line_Item__c pqliLa = testDataFactoryPP.createPriceQLineItem(pqLa.Id, laProd.Id);
        insert pqliLa;
       
        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqla.Id);        
        Test.setCurrentPage(pageRefpre);
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
         
        PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
        System.currentPageReference().getParameters().put('pqid', pqla.Id);
         
         Map<Id,String> mp = priceQuote.getFormatRepPrices(new List<Price_Quote_Line_Item__c>{pqliLa});
        Test.stopTest();
    }
    
    @isTest static void getFormatEligiblePricesTest() {
         
         delete [select id from Account];
         delete [select id from Price_Quote__c];
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        
        List<Sales_Orgs__c> soList = [SELECT Id FROM Sales_Orgs__c];
        for(Sales_Orgs__c so: soList){
            so.Active__c = false;
        }
        update soList;
         
        Test.startTest();
        system.debug('-- Starting getSalesOrgMapTesting --');
                
        Account laAcc = new Account(Name = 'John Doe',Account_Group__c = 'Z002',Customer_Group__c = '11',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
        Product2 laProd = testDataFactoryPP.createProduct2('laProd', 'US60', '20', '40');
        insert laProd;
        
        Price_Quote__c pqla = testDataFactoryPP.createPriceQuote(laAcc.Id, con1.Id, 'US6020', false, 'Latin America');
        pqla.Language__c = 'French';
         pqla.Account_Name__c = laAcc.Id;
        insert pqLa;

        Price_Quote_Line_Item__c pqliLa = testDataFactoryPP.createPriceQLineItem(pqLa.Id, laProd.Id);
        insert pqliLa;
       
        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqla.Id);        
        Test.setCurrentPage(pageRefpre);
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
         
        PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
        System.currentPageReference().getParameters().put('pqid', pqla.Id);
         
         Map<Id,String> mp = priceQuote.getFormatEligiblePrices(new List<Price_Quote_Line_Item__c>{pqliLa});
        Test.stopTest();
    }
    
    @isTest static void getFormatRsmPricesTest() {
         
         delete [select id from Account];
         delete [select id from Price_Quote__c];
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        
        List<Sales_Orgs__c> soList = [SELECT Id FROM Sales_Orgs__c];
        for(Sales_Orgs__c so: soList){
            so.Active__c = false;
        }
        update soList;
         
        Test.startTest();
        system.debug('-- Starting getSalesOrgMapTesting --');
                
        Account laAcc = new Account(Name = 'John Doe',Account_Group__c = 'Z002',Customer_Group__c = '11',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
        Product2 laProd = testDataFactoryPP.createProduct2('laProd', 'US60', '20', '40');
        insert laProd;
        
        Price_Quote__c pqla = testDataFactoryPP.createPriceQuote(laAcc.Id, con1.Id, 'US6020', false, 'Latin America');
        pqla.Language__c = 'French';
         pqla.Account_Name__c = laAcc.Id;
        insert pqLa;

        Price_Quote_Line_Item__c pqliLa = testDataFactoryPP.createPriceQLineItem(pqLa.Id, laProd.Id);
        insert pqliLa;
       
        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqla.Id);        
        Test.setCurrentPage(pageRefpre);
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
         
        PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
        System.currentPageReference().getParameters().put('pqid', pqla.Id);
         
         Map<Id,String> mp = priceQuote.getFormatRsmPrices(new List<Price_Quote_Line_Item__c>{pqliLa});
        Test.stopTest();
    }
    
     @isTest static void getFormatListPricesTest() {
         
         delete [select id from Account];
         delete [select id from Price_Quote__c];
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        
        List<Sales_Orgs__c> soList = [SELECT Id FROM Sales_Orgs__c];
        for(Sales_Orgs__c so: soList){
            so.Active__c = false;
        }
        update soList;
         
        Test.startTest();
        system.debug('-- Starting getSalesOrgMapTesting --');
                
        Account laAcc = new Account(Name = 'John Doe',Account_Group__c = 'Z002',Customer_Group__c = '11',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
        Product2 laProd = testDataFactoryPP.createProduct2('laProd', 'US60', '20', '40');
        insert laProd;
        
        Price_Quote__c pqla = testDataFactoryPP.createPriceQuote(laAcc.Id, con1.Id, 'US6020', false, 'Latin America');
        pqla.Language__c = 'French';
         pqla.Account_Name__c = laAcc.Id;
        insert pqLa;

        Price_Quote_Line_Item__c pqliLa = testDataFactoryPP.createPriceQLineItem(pqLa.Id, laProd.Id);
        insert pqliLa;
       
        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqla.Id);        
        Test.setCurrentPage(pageRefpre);
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
         
        PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
        System.currentPageReference().getParameters().put('pqid', pqla.Id);
         
         Map<Id,String> mp = priceQuote.getFormatListPrices(new List<Price_Quote_Line_Item__c>{pqliLa});
        Test.stopTest();
    }
    
    @isTest static void updatePriceTest() {
         
         delete [select id from Account];
         delete [select id from Price_Quote__c];
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        
        List<Sales_Orgs__c> soList = [SELECT Id FROM Sales_Orgs__c];
        for(Sales_Orgs__c so: soList){
            so.Active__c = false;
        }
        update soList;
         
        Test.startTest();
        system.debug('-- Starting getSalesOrgMapTesting --');
                
        Account laAcc = new Account(Name = 'John Doe',Account_Group__c = 'Z002',Customer_Group__c = '11',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
        Product2 laProd = testDataFactoryPP.createProduct2('laProd', 'US60', '20', '40');
        insert laProd;
        
        Price_Quote__c pqLa = testDataFactoryPP.createPriceQuote(laAcc.Id, con1.Id, 'US6020', false, 'Latin America');
        insert pqLa;
        
        Price_Quote__c pqLa2 = testDataFactoryPP.createPriceQuote(laAcc.Id, con1.Id, 'US6020', false, 'Latin America');
        insert pqLa2;

        Price_Quote_Line_Item__c pqliLa = testDataFactoryPP.createPriceQLineItem(pqLa.Id, laProd.Id);
        pqliLa.Price_Quote__c = pqLa.Id;
        insert pqliLa;
            
        Price_Quote_Line_Item__c pqliLa2 = testDataFactoryPP.createPriceQLineItem(pqLa2.Id, laProd.Id);
        insert pqliLa2;
        
        Price_Quote_Line_Item__c pqliLa3 = testDataFactoryPP.createPriceQLineItem(pqLa2.Id, laProd.Id);
        insert pqliLa3;
       
        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
        Test.setCurrentPage(pageRefpre);
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
         
        PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
        System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
         Price_Quote_Line_Item__c pqLineItem = PP_Price_Quote.updatePrice(pqliLa3.Id, 375.00);
        Test.stopTest();
    }
    
      @isTest static void vascularBundlesWithUltra4yrTest() {
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        
        Test.startTest();
                
         Product2 laProd = [select id, name, Sales_Org_Key__c from Product2 where Sales_Org_Key__c != null limit 1];
         laProd.VPS_Rhythm_DLX_with_Ultrasound__c = true;
         laProd.X4_year__c = true;
         update laProd;
         
         Price_Quote__c pqLa = [select id from Price_Quote__c limit 1];
         pqLa.Sales_Org_Key__c = laProd.Sales_Org_Key__c;
         update pqLa;
          
          PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
          Test.setCurrentPage(pageRefpre);
          ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
          PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
          priceQuote.pq = pqLa;
          System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
        priceQuote.vascularBundlesWithUltra4yr();
        Test.stopTest();
    }
    
     @isTest static void vascularBundlesWithUltra2yrTest() {
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
         
        Test.startTest();
        system.debug('-- Starting getSalesOrgMapTesting --');
                
        Account laAcc = new Account(Name = 'John Doe',Account_Group__c = 'Z002',Customer_Group__c = '11',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
         Product2 laProd = [select id, name, Sales_Org_Key__c from Product2 where Sales_Org_Key__c != null limit 1];
         laProd.VPS_Rhythm_DLX_with_Ultrasound__c = true;
         laProd.X2_year__c = true;
         update laProd;
         
         Price_Quote__c pqLa = [select id from Price_Quote__c limit 1];
         pqLa.Sales_Org_Key__c = laProd.Sales_Org_Key__c;
         update pqLa;
          
          PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
          Test.setCurrentPage(pageRefpre);
          ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
          PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
          priceQuote.pq = pqLa;
          System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
        priceQuote.vascularBundlesWithUltra2yr();
        Test.stopTest();
    }
    
    
     @isTest static void vascularBundlesWithoutUltra4yrTest() {
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
         
        Test.startTest();
        system.debug('-- Starting getSalesOrgMapTesting --');
                
        Account laAcc = new Account(Name = 'John Doe',Account_Group__c = 'Z002',Customer_Group__c = '11',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
         Product2 laProd = [select id, name, Sales_Org_Key__c from Product2 where Sales_Org_Key__c != null limit 1];
         laProd.VPS_Rhythm_DLX_without_Ultrasound__c = true;
         laProd.X4_year__c = true;
         update laProd;
         
         Price_Quote__c pqLa = [select id from Price_Quote__c limit 1];
         pqLa.Sales_Org_Key__c = laProd.Sales_Org_Key__c;
         update pqLa;
          
          PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
          Test.setCurrentPage(pageRefpre);
          ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
          PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
          priceQuote.pq = pqLa;
          System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
        priceQuote.vascularBundlesWithoutUltra4yr();
        Test.stopTest();
    }
    
     @isTest static void vascularBundlesWithoutUltra2yrTest() {
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
         
        Test.startTest();
        system.debug('-- Starting getSalesOrgMapTesting --');
                
        Account laAcc = new Account(Name = 'John Doe',Account_Group__c = 'Z002',Customer_Group__c = '11',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
         Product2 laProd = [select id, name, Sales_Org_Key__c from Product2 where Sales_Org_Key__c != null limit 1];
         laProd.VPS_Rhythm_DLX_without_Ultrasound__c = true;
         laProd.X2_year__c = true;
         update laProd;
         
         Price_Quote__c pqLa = [select id from Price_Quote__c limit 1];
         pqLa.Sales_Org_Key__c = laProd.Sales_Org_Key__c;
         update pqLa;
          
          PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
          Test.setCurrentPage(pageRefpre);
          ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
          PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
          priceQuote.pq = pqLa;
          System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
        priceQuote.vascularBundlesWithoutUltra2yr();
        Test.stopTest();
    }
    
    @isTest static void vascularBundlesDlxProbe4yrTest() {
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
         
        Test.startTest();
        system.debug('-- Starting getSalesOrgMapTesting --');     
        
         Product2 laProd = [select id, name, Sales_Org_Key__c from Product2 where Sales_Org_Key__c != null limit 1];
         laProd.DLX_Ultrasound_Probe_Only__c = true;
         laProd.X4_year__c = true;
         update laProd;
         
         Price_Quote__c pqLa = [select id from Price_Quote__c limit 1];
         pqLa.Sales_Org_Key__c = laProd.Sales_Org_Key__c;
         update pqLa;
          
          PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
          Test.setCurrentPage(pageRefpre);
          ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
          PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
          priceQuote.pq = pqLa;
          System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
        priceQuote.vascularBundlesDlxProbe4yr();
        Test.stopTest();
    }
    
    @isTest static void vascularBundlesDlxProbe2yrTest() {
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
         
        Test.startTest();
        
         Product2 laProd = [select id, name, Sales_Org_Key__c from Product2 where Sales_Org_Key__c != null limit 1];
         laProd.DLX_Ultrasound_Probe_Only__c = true;
         laProd.X2_year__c = true;
         update laProd;
         
         Price_Quote__c pqLa = [select id from Price_Quote__c limit 1];
         pqLa.Sales_Org_Key__c = laProd.Sales_Org_Key__c;
         update pqLa;
          
          PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
          Test.setCurrentPage(pageRefpre);
          ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
          PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
          priceQuote.pq = pqLa;
          System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
        priceQuote.vascularBundlesDlxProbe2yr();
        Test.stopTest();
    }
    
    @isTest static void vascularBundlesRhythm3yrTest() {
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
         
        Test.startTest();
        
         Product2 laProd = [select id, name, Sales_Org_Key__c from Product2 where Sales_Org_Key__c != null limit 1];
         laProd.VPS_Rhythm__c = true;
         laProd.X3_year__c = true;
         update laProd;
         
         Price_Quote__c pqLa = [select id from Price_Quote__c limit 1];
         pqLa.Sales_Org_Key__c = laProd.Sales_Org_Key__c;
         update pqLa;
          
          PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
          Test.setCurrentPage(pageRefpre);
          ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
          PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
          priceQuote.pq = pqLa;
          System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
        priceQuote.vascularBundlesRhythm3yr();
        Test.stopTest();
    }
    
     @isTest static void vascularBundlesRhythm1yrTest() {
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
         
        Test.startTest();
        
         Product2 laProd = [select id, name, Sales_Org_Key__c from Product2 where Sales_Org_Key__c != null limit 1];
         laProd.VPS_Rhythm__c = true;
         laProd.X1_year__c = true;
         update laProd;
         
         Price_Quote__c pqLa = [select id from Price_Quote__c limit 1];
         pqLa.Sales_Org_Key__c = laProd.Sales_Org_Key__c;
         update pqLa;
          
          PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
          Test.setCurrentPage(pageRefpre);
          ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
          PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
          priceQuote.pq = pqLa;
          System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
        priceQuote.vascularBundlesRhythm1yr();
        Test.stopTest();
    }
    
    @isTest static void vascularBundlesRhythmRefurb3yrTest() {
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
         
        Test.startTest();
        
         Product2 laProd = [select id, name, Sales_Org_Key__c from Product2 where Sales_Org_Key__c != null limit 1];
         laProd.VPS_Rhythm_Refurb__c = true;
         laProd.X3_year__c = true;
         update laProd;
         
         Price_Quote__c pqLa = [select id from Price_Quote__c limit 1];
         pqLa.Sales_Org_Key__c = laProd.Sales_Org_Key__c;
         update pqLa;
          
          PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
          Test.setCurrentPage(pageRefpre);
          ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
          PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
          priceQuote.pq = pqLa;
          System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
        priceQuote.vascularBundlesRhythmRefurb3yr();
        Test.stopTest();
    }
    
    @isTest static void vascularBundlesRhythmRefurb1yrTest() {
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
         
        Test.startTest();
        
         Product2 laProd = [select id, name, Sales_Org_Key__c from Product2 where Sales_Org_Key__c != null limit 1];
         laProd.VPS_Rhythm_Refurb__c = true;
         laProd.X1_year__c = true;
         update laProd;
         
         Price_Quote__c pqLa = [select id from Price_Quote__c limit 1];
         pqLa.Sales_Org_Key__c = laProd.Sales_Org_Key__c;
         update pqLa;
          
          PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
          Test.setCurrentPage(pageRefpre);
          ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
          PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
          priceQuote.pq = pqLa;
          System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
        priceQuote.vascularBundlesRhythmRefurb1yr();
        Test.stopTest();
    }
    
    @isTest static void vascularBundlesG42yrTest() {
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
         
        Test.startTest();
        
         Product2 laProd = [select id, name, Sales_Org_Key__c from Product2 where Sales_Org_Key__c != null limit 1];
         laProd.G4__c = true;
         laProd.X2_year__c = true;
         update laProd;
         
         Price_Quote__c pqLa = [select id from Price_Quote__c limit 1];
         pqLa.Sales_Org_Key__c = laProd.Sales_Org_Key__c;
         update pqLa;
          
          PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
          Test.setCurrentPage(pageRefpre);
          ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
          PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
          priceQuote.pq = pqLa;
          System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
        priceQuote.vascularBundlesG42yr();
        Test.stopTest();
    }
    
    @isTest static void vascularBundlesG4refurb2yrTest() {
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
         
        Test.startTest();
        
         Product2 laProd = [select id, name, Sales_Org_Key__c from Product2 where Sales_Org_Key__c != null limit 1];
         laProd.G4_Refurb__c = true;
         laProd.X2_year__c = true;
         update laProd;
         
         Price_Quote__c pqLa = [select id from Price_Quote__c limit 1];
         pqLa.Sales_Org_Key__c = laProd.Sales_Org_Key__c;
         update pqLa;
          
          PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqLa.Id);        
          Test.setCurrentPage(pageRefpre);
          ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
          PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
          priceQuote.pq = pqLa;
          System.currentPageReference().getParameters().put('pqid', pqLa.Id);
         
        priceQuote.vascularBundlesG4refurb2yr();
        Test.stopTest();
    }
    
    @isTest static void vascularTradeInTest() {
         
         delete [select id from Account];
         delete [select id from Price_Quote__c];
         
        User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
        Insert cUser;
        
        List<Sales_Orgs__c> soList = [SELECT Id FROM Sales_Orgs__c];
        for(Sales_Orgs__c so: soList){
            so.Active__c = false;
        }
        update soList;
         
        Test.startTest();
        system.debug('-- Starting getSalesOrgMapTesting --');
                
        Account laAcc = new Account(Name = 'John Doe',Account_Group__c = 'Z002',Customer_Group__c = '11',
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
                                   );
        insert laAcc;
        
        Contact con1 = testDataFactoryPP.createContact('LA', 'Contact', laAcc.Id);
        insert con1;
        
        Product2 laProd = testDataFactoryPP.createProduct2('laProd', 'US60', '20', '40');
        insert laProd;
        
        Price_Quote__c pqla = testDataFactoryPP.createPriceQuote(laAcc.Id, con1.Id, 'US6020', false, 'Latin America');
        pqla.Language__c = 'French';
         pqla.Account_Name__c = laAcc.Id;
        insert pqLa;

        Price_Quote_Line_Item__c pqliLa = testDataFactoryPP.createPriceQLineItem(pqLa.Id, laProd.Id);
        pqliLa.Product_Description__c = 'Trade-in Discount';
        insert pqliLa;
       
        PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqla.Id);        
        Test.setCurrentPage(pageRefpre);
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        ApexPages.StandardController ctlr = new ApexPages.StandardController(pqLa);
         
        PP_Price_Quote priceQuote = new PP_Price_Quote(ctlr);
        System.currentPageReference().getParameters().put('pqid', pqla.Id);
         
        priceQuote.vascularTradeIn();
        Test.stopTest();
    }
    
}//end of PP_Global_Test_Class