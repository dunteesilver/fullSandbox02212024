/*********************************************************************
* Description     : Test class for PP_SAP_Price
* Covered Classes : PP_SAP_Price
* Author(s)       : Dun Silver
**********************************************************************/
@isTest /* (SeeAllData = true) */
public class PP_SAP_Price_Test {
    /*************** START OF NEW TESTING METHODS *************************/
    
      
    @testSetup static void setUpData() {
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
    }
    
    @isTest static void testSapPrice() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;

        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser1){
        
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(accName, salesOrg, sapCode, custGrp)
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','17');
            insert usACC;
            usACC.Account_Group__c = 'z002';
            update usACC;
            
            Account usAcc1 = testDataFactoryPP.createAccount('TestAcount US1', 'US60','100002','17');
            insert usAcc1;
            
            //create Account with no SAP Code
            /*
            Account noSap = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '17',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            */
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            insert con2;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            insert usProd3;
            update usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
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
            pqUs.Businessunit__c = 'EMEA';
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            //PQ after line item insert
            Price_Quote__c pqUs2 = [Select Id FROM Price_Quote__c WHERE id = :pqUs.Id];
        
          
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs2.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);
            Test.startTest();            
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs2.Id);
            //sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs2.Id);
            //sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs2.Id);
            //sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs2.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs2.Id);
            String status = sapPrice.status;
            //Boolean userRoleBoolean = sapPrice.userRoleBoolean;
            sapPrice.lineClassCheck(pqUs2.Id);
            sapPrice.lineProdCheckAnes(pqUs2.Id);
            sapPrice.lineProdCheckIcap(pqUs2.Id);
            
            sapPrice.getContractCustomer(new List<String>{'50009064', '50009065', '50009066'}, new List<String>{'100001', '100002'});
            //sapPrice.getSAPprice(new List<String>{usProd.Id, usProd1.id, usProd2.Id, usProd3.Id}, '', '', pqUs2.Id);
           
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs2.Id);
            Test.stopTest();
        }//end of system run

    }//end of validQuote test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testSapPriceZD() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;

        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser1){
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(accName, salesOrg, sapCode, custGrp)
            Account usAcc = new Account(Name = 'Has Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '11', SAP_Sold_To__c = '100001',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            //Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','03');
            insert usACC;
            //usAcc.Customer_Group__c = '11';
            //usACC.Account_Group__c = 'z001';
            //update usACC;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            insert usProd3;
            update usProd3;
                               
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);
            Test.startTest();            
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            String status = sapPrice.status;
            //Boolean userRoleBoolean = sapPrice.userRoleBoolean;
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testSapPriceZD test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/

    @isTest static void testSapPriceZdNot06() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;

        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;

        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser1){
           
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(accName, salesOrg, sapCode, custGrp)
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','17');
            insert usACC;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            insert usProd3;
            update usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            //Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            //insert cp;
            
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
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            //materialStrId1.add(usProd1.Id);
            //materialStrId2.add(usProd2.Id);
            //materialStrId3.add(usProd3.Id);
            Test.startTest();            
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Teleflex Global IT', sapPrice.userRole);
            System.assertEquals(FALSE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            String status = sapPrice.status;
            //Boolean userRoleBoolean = sapPrice.userRoleBoolean;
            //sapPrice.lineClassCheck(pqUs.Id);
            //sapPrice.lineProdCheckAnes(pqUs.Id);
            //sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testSapPriceZdNot06 test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/

    @isTest static void testSapPriceZH() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;

        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser1){
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(accName, salesOrg, sapCode, custGrp)
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','17');
            insert usACC;
            //usAcc.Customer_Group__c = '17';
            //usACC.Account_Group__c = 'Z001';
            //update usACC;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            insert usProd3;
            
            //Start of product pricing update
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            update usProd;
            
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            update usProd3;
            //End of product pricing update
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            //Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            //insert cp;
            
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
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch2.Id, ch2.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
                       
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            //System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);
            Test.startTest();            
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            String status = sapPrice.status;
            //Boolean userRoleBoolean = sapPrice.userRoleBoolean;
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testSapPriceZH test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/

    @isTest static void testSapPriceNoSapZh() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser1){
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            
            //create Account with no SAP Code
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '17',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
            );
            insert usAcc;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US99', 'Contact99', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
               
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd99', 'US60', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd98', 'US60', '10', '40');
            insert usProd1;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd97', 'US60', '10', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            insert usProd3;
            usProd3.List_Price__c = 0.00;
            update usProd3;
            
            //create cross reference products
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
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
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Surgical Disposables');
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            Test.startTest();
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);          
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            System.debug('*** crossList *** ' + crossList);
            sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testSapPriceNoSap test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/

    @isTest static void testSapPriceNoSapZA() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

        System.runAs(usUser1){
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            
            //create Account with no SAP Code
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '03',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
            );
            insert usAcc;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US96', 'Contact96', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd96', 'US60', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd95', 'US60', '10', '40');
            insert usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd94', 'US60', '10', '40');
            insert usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd93', 'US60', '10', '40');
            insert usProd3;
            
            //Start of product pricing update
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            //End of product pricing update
            
            //create cross reference products
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
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
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            Test.startTest();
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);          
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testSapPriceNoSapZA test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/

    @isTest static void testSapPriceNoSapInvalidSalesOrg() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser1){
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex/Arrow', 'US103010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            
            //create Account with no SAP Code
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '11',
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
            Product2 usProd = testDataFactoryPP.createProduct('usProd92', 'US10', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd91', 'US10', '10', '40');
            insert usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd90', 'US10', '10', '40');
            insert usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd89', 'US10', '10', '40');
            insert usProd3;
            
            //Start of product pricing update
            usProd.Alt_Site_List__c = 380.00;
            update usProd;
            
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            usProd1.Description = 'LMA Atomizers';
            usProd1.Product_Description_Custom__c = 'THIS IS A TEST';
            update usProd1;
            
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            usProd2.Product_Description_Custom__c = 'ISO-GARD';
            update usProd2;
            //End of product pricing update
            
            //create cross reference products
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            //Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            //insert cp;
            
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US10');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US10');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US10');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US10');
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
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US103010', false, 'Anesthesia');
            insert pqUS;
            System.debug('*** pqUs.List_Price_Type__c testSapPriceNoSapInvalidSalesOrg 1 *** ' + pqUs.List_Price_Type__c);
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;

            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            Test.startTest();
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);          
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);

            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testSapPriceNoSapInvalidSalesOrg test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testSapPriceNoSapLatam() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        //createUser(String firstName, String lastName, String approvalRole, String bu)
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser1){
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'LA - Latin America', 'US6020', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            
            //create Account with no SAP Code
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '17',
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
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '20', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '20', '40');
            insert usProd1;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '20', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '20', '40');
            insert usProd3;
            update usProd3;
            
            //create cross reference products
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
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
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6020', false, 'Anesthesia');
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            Test.startTest();
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);           
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testSapPriceNoSapLatam test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testSapPriceSapLatam() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman66', 'User66', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US67', 'User67', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser1){
           
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'LA - Latin America', 'US6020', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            
            //create Account with no SAP Code
            Account usAcc = new Account(Name = 'Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '11', SAP_Sold_To__c = '100001',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
            );
            insert usAcc;
            
            Account usAcc1 = new Account(Name = 'No Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '11', SAP_Sold_To__c = '100002',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
            );
            insert usAcc1;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            insert con2;
           
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '20', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '20', '40');
            insert usProd1;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '20', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '20', '40');
            insert usProd3;
            update usProd3;
            
            //create cross reference products
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
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
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6020', false, 'Anesthesia');
            insert pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            Test.startTest();
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);          
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            //sapPrice.lineClassCheck(pqUs.Id);
            //sapPrice.lineProdCheckAnes(pqUs.Id);
            //sapPrice.lineProdCheckIcap(pqUs.Id);
            
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            //List<String> crossList = new List<String>();
            //crossList.add(usCrossProd.Competitor_Product_Code__c);
            //crossList.add(usCrossProd1.Competitor_Product_Code__c);
            //crossList.add(usCrossProd2.Competitor_Product_Code__c);
            //crossList.add(usCrossProd3.Competitor_Product_Code__c);
            //sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testSapPriceSapLatam test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testObjective06() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        //createUser(firstName, lastName, approvalRole, bu)
        User usUserMan = testDataFactoryPP.createUser('USman101', 'User101', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        //User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        //insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        //usUser.ManagerId = usUserMan.Id;
        //update usUser;
        //String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        //usUser.UserRoleId = roleId;
        //update usUser;
        
        Profile p = [select id from profile where name='System Administrator'];
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name LIKE 'Customer Service Rep'].Id;
        //String fn = firstname.left(2);
        //string ln = lastname.left(2);
        User usUser = new User(
            alias = 'testU',email= 'UnitTest@unittest.teleflex.com',
            emailencodingkey = 'UTF-8',firstname = 'Unit',
            lastname = 'Test', languagelocalekey='en_US',
            localesidkey='en_US',profileid = p.Id,
            timezonesidkey='America/New_York',
            username = 'UnitTest@unittest.teleflex.com',
            Business_Unit__c = 'Vascular',
            Approval_Role__c = 'Sales Rep',
            UserRoleId = roleId,
            ManagerId = usUserMan.Id
        );
        insert usUser;
        
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
            
            //create Account with no SAP Code
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','141877','03');
            insert usACC;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('28022', 'US60', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            insert usProd3;
            update usProd3;
            
            //create cross reference products
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
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
            insert pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;

            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);           
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            Test.startTest();
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testObjective06 test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testObjective06Sap999999() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        //createUser(firstName, lastName, approvalRole, bu)
        User usUserMan = testDataFactoryPP.createUser('USman101', 'User101', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        //User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        //insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        //usUser.ManagerId = usUserMan.Id;
        //update usUser;
        //String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        //usUser.UserRoleId = roleId;
        //update usUser;
        
        Profile p = [select id from profile where name='System Administrator'];
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name LIKE 'Customer Service Rep'].Id;
        //String fn = firstname.left(2);
        //string ln = lastname.left(2);
        User usUser = new User(
            alias = 'testU',email= 'UnitTest@unittest.teleflex.com',
            emailencodingkey = 'UTF-8',firstname = 'Unit',
            lastname = 'Test', languagelocalekey='en_US',
            localesidkey='en_US',profileid = p.Id,
            timezonesidkey='America/New_York',
            username = 'UnitTest@unittest.teleflex.com',
            Business_Unit__c = 'Vascular',
            Approval_Role__c = 'Sales Rep',
            UserRoleId = roleId,
            ManagerId = usUserMan.Id
        );
        insert usUser;
        
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
            
            //createAccount(accName, salesOrg, sapCode, custGrp)
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','999999','11');
            insert usACC;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('28022', 'US60', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            insert usProd3;
            update usProd3;
            
            //create cross reference products
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
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
            insert pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;

            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            Test.startTest();
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);           
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testObjective06Sap999999 test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testObjective06Sap111111() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        //createUser(firstName, lastName, approvalRole, bu)
        User usUserMan = testDataFactoryPP.createUser('USman101', 'User101', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        //User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        //insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        //usUser.ManagerId = usUserMan.Id;
        //update usUser;
        //String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        //usUser.UserRoleId = roleId;
        //update usUser;
        
        Profile p = [select id from profile where name='System Administrator'];
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name LIKE 'Customer Service Rep'].Id;
        //String fn = firstname.left(2);
        //string ln = lastname.left(2);
        User usUser = new User(
            alias = 'testU',email= 'UnitTest@unittest.teleflex.com',
            emailencodingkey = 'UTF-8',firstname = 'Unit',
            lastname = 'Test', languagelocalekey='en_US',
            localesidkey='en_US',profileid = p.Id,
            timezonesidkey='America/New_York',
            username = 'UnitTest@unittest.teleflex.com',
            Business_Unit__c = 'Vascular',
            Approval_Role__c = 'Sales Rep',
            UserRoleId = roleId,
            ManagerId = usUserMan.Id
        );
        insert usUser;
        
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
            
            //createAccount(accName, salesOrg, sapCode)
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','111111','17');
            insert usACC;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('28022', 'US60', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            insert usProd3;
            update usProd3;
            
            //create cross reference products
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            //Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','111111');
            //insert cp;
            
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
            insert pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;

            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            Test.startTest();
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);           
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            //sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testObjective06Sap111111 test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testObjective06NoSap() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser.UserRoleId = roleId;
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
            
            //create Account with no SAP Code
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
            Product2 usProd = testDataFactoryPP.createProduct('28022', 'US60', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            insert usProd3;
            update usProd3;
            
            //create cross reference products
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
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
            insert pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;

            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            Test.startTest();
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);           
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testObjective06NoSap test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testObjective06LatamSap() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser.UserRoleId = roleId;
        update usUser;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser){
           
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'LA - Latin America', 'US6020', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            
            //create Account with no SAP Code
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','141877','03');
            insert usACC;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('28022', 'US60', '20', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '20', '40');
            insert usProd1;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '20', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '20', '40');
            insert usProd3;
            update usProd3;
            
            //create cross reference products
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
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
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'AU1010', false, 'Australia');
            insert pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            //System.currentPageReference().getParameters().put('refresh', 'yes'); 

            Test.startTest();
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);           
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Customer Service Rep', sapPrice.userRole);
            System.assertEquals(TRUE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testObjective06LatamSap test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testNoSapPriceOtherSalesOrg() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('AUman', 'User', 'Sales Manager', 'Australia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('AU', 'User', 'Sales Rep', 'Australia');
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
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, '', 'AU1010', 4);
            ppUsers.add(cuUs);
            insert ppUsers;
            
            //createAccount(accName, salesOrg, sapCode, custGrp)
            //create Account with no SAP Code
            Account usAcc = new Account(Name = 'No Sap Code AU',Account_Group__c = 'Z002',Customer_Group__c = '11',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
            );
            insert usAcc;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('AU', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'AU10', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'AU10', '10', '40');
            insert usProd1;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'AU10', '10', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'AU10', '10', '40');
            insert usProd3;
            usProd3.List_Price__c = 0.00;
            update usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            //Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            //insert cp;
            
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','AU10');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','AU10');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','AU10');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','AU10');
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
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'AU1010', false, 'Anesthesia');
            insert pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            //System.currentPageReference().getParameters().put('refresh', 'yes'); 
                   
            Test.startTest();
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);           
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Teleflex Global IT', sapPrice.userRole);
            System.assertEquals(FALSE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);

            Test.stopTest();
        }//end of system run

    }//end of testNoSapPriceOtherSalesOrg test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testPrf() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman56', 'User56', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US57', 'User57', 'Sales Rep', 'Anesthesia');
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
            //createAccount(accName, salesOrg, sapCode, custGrp)
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','03');
            insert usACC;
            
            Account usAcc1 = testDataFactoryPP.createAccount('TestAcount US1', 'US60','100002','11');
            insert usAcc1;
            
            //create Account with no SAP Code
            Account noSap = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '17',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            insert usProd;
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
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
                       
            //create PRF data
            //createPrf(String accId, String conId, String salesOrgKey, String pqId)
            PRF__c prfUs = testDataFactoryPP.createPrf(usAcc.Id, con1.Id,'US6010','Anesthesia');   
            insert prfUs;

            //createPrfLineItem(String prfId, String prodId)            
            PRF_Line_Item__c prfliUs = testDataFactoryPP.createPrfLineItem(prfUs.Id, usProd.Id);
            insert prfliUs;
            
            //PQ after line item insert
            PRF__c prf = [SELECT Id  FROM PRF__c WHERE id =:prfUs.Id LIMIT 1];
            
            
            List<String> materialStr = new List<String>();
            materialStr.add(usProd.Name);
            Test.startTest();            
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //Boolean userRoleBoolean = sapPrice.userRoleBoolean;
            sapPrice.lineClassCheck(prf.Id);
            sapPrice.lineProdCheckAnes(prf.Id);
            sapPrice.lineProdCheckIcap(prf.Id);
            sapPrice.lineClassCheck(prf.Id);
            sapPrice.lineProdCheckAnes(prf.Id);
            sapPrice.lineProdCheckIcap(prf.Id);
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, prf.Id);
            Test.stopTest();
        }//end of system run

    }//end of testPrf test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testSapPriceOtherSalesOrg() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Australia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Australia');
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
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, '', 'AU1010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //createAccount(accName, salesOrg, sapCode, custGrp)
            //create Account with no SAP Code
            Account usAcc = testDataFactoryPP.createAccount('TestAcount AU', 'AU10','111111','17');
            insert usACC;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('AU', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'AU10', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'AU10', '10', '40');
            insert usProd1;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'AU10', '10', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'AU10', '10', '40');
            insert usProd3;
            usProd3.List_Price__c = 0.00;
            update usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            //Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            //insert cp;
            
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','AU10');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','AU10');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','AU10');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','AU10');
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
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'AU1010', false, 'Anesthesia');
            insert pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
                   
            Test.startTest();
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            //materialStrId1.add(usProd1.Id);
            //materialStrId2.add(usProd2.Id);
            //materialStrId3.add(usProd3.Id);           
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Teleflex Global IT', sapPrice.userRole);
            System.assertEquals(FALSE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            //sapPrice.lineClassCheck(pqUs.Id);
            //sapPrice.lineProdCheckAnes(pqUs.Id);
            //sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);

            Test.stopTest();
        }//end of system run

    }//end of testSapPriceOtherSalesOrg test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testSapPriceOtherSalesOrg999999() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Australia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Australia');
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
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, '', 'AU1010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //createAccount(accName, salesOrg, sapCode, custGrp)
            //create Account with no SAP Code
            Account usAcc = testDataFactoryPP.createAccount('TestAcount AU', 'AU10','999999','03');
            insert usACC;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('AU', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'AU10', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'AU10', '10', '40');
            insert usProd1;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'AU10', '10', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'AU10', '10', '40');
            insert usProd3;
            usProd3.List_Price__c = 0.00;
            update usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            //Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            //insert cp;
            
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','AU10');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','AU10');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','AU10');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','AU10');
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
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'AU1010', false, 'Anesthesia');
            insert pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
                   
            Test.startTest();
            List<String> materialStrId = new List<String>();
            List<String> materialStrId1 = new List<String>();
            List<String> materialStrId2 = new List<String>();
            List<String> materialStrId3 = new List<String>();
            List<String> materialStrName = new List<String>();
            materialStrId.add(usProd.Id);
            materialStrId1.add(usProd1.Id);
            materialStrId2.add(usProd2.Id);
            materialStrId3.add(usProd3.Id);           
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            //System.assertEquals('Teleflex Global IT', sapPrice.userRole);
            System.assertEquals(FALSE, sapPrice.userRoleBoolean);
            sapPrice.getSAPprice(materialStrId,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId1,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId2,NULL,NULL,pqUs.Id);
            //sapPrice.getSAPprice(materialStrId3,NULL,NULL,pqUs.Id);
            materialStrName.add(usProd.Name);
            materialStrName.add(usProd1.Name);
            materialStrName.add(usProd2.Name);
            materialStrName.add(usProd3.Name);
            sapPrice.getSAPpriceBulk(materialStrName, pqUs.Id);
            sapPrice.lineClassCheck(pqUs.Id);
            sapPrice.lineProdCheckAnes(pqUs.Id);
            sapPrice.lineProdCheckIcap(pqUs.Id);
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);

            Test.stopTest();
        }//end of system run

    }//end of testSapPriceOtherSalesOrg999999 test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    ///////////////////////////////////////////////////////////////////////////
    @isTest static void testSapPriceSapLatamZD() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman66', 'User66', 'Sales Manager', 'Latin America');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US67', 'User67', 'Sales Rep', 'Latin America');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Latin America');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser1){
           
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'LA - Latin America', 'US6020', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            
            //create Account with no SAP Code
            Account usAcc = new Account(Name = 'Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '11', SAP_Sold_To__c = '100001',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
            );
            insert usAcc;
            
            Account usAcc1 = new Account(Name = 'No Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '11', SAP_Sold_To__c = '100002',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
            );
            insert usAcc1;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            insert con2;
           
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '20', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '20', '40');
            insert usProd1;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '20', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '20', '40');
            insert usProd3;
            update usProd3;
            
            //create cross reference products
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
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
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6020', false, 'Anesthesia');
            insert pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            Test.startTest();   
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testSapPriceSapLatam test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    ///////////////////////////////////////////////////////////////////////////
    
    ///////////////////////////////////////////////////////////////////////////
    @isTest static void testSapPriceSapSurgInstr() {
        /*
         * Implement test code
         * create test users
         * createUser(String firstName, String lastName, String approvalRole, String bu)
         * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
         * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
         * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
        */
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman66', 'User66', 'Sales Manager', 'Surgical Instruments');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US67', 'User67', 'Sales Rep', 'Surgical Instruments');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Surgical Instruments');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser1){
           
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            
            //create Account with no SAP Code
            Account usAcc = new Account(Name = 'Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '11', SAP_Sold_To__c = '100001',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            insert usAcc;
            
            Account usAcc1 = new Account(Name = 'No Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '11', SAP_Sold_To__c = '100002',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            insert usAcc1;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            insert con2;
           
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Distributor_List__c = 380.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            insert usProd3;
            update usProd3;
            
            //create cross reference products
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
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
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Surgical Instruments');
            insert pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            Test.startTest();   
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            
            List<String> crossList = new List<String>();
            crossList.add(usCrossProd.Competitor_Product_Code__c);
            crossList.add(usCrossProd1.Competitor_Product_Code__c);
            crossList.add(usCrossProd2.Competitor_Product_Code__c);
            crossList.add(usCrossProd3.Competitor_Product_Code__c);
            sapPrice.getCrossBulk(crossList, pqUs.Id);
            Test.stopTest();
        }//end of system run

    }//end of testSapPriceSapLatam test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void testSAPpriceOld() {
        /*
* Implement test code
* create test users
* createUser(String firstName, String lastName, String approvalRole, String bu)
* Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
* bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
* Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser1){
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(accName, salesOrg, sapCode, custGrp)
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','17');
            usAcc.SAP_Sold_To__c = '';
            usAcc.Customer_Group__c = '03';
            insert usACC;
            
            Account usAcc1 = testDataFactoryPP.createAccount('TestAcount US1', 'US60','100002','17');
            usAcc1.SAP_Sold_To__c = '';
            insert usAcc1;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            insert con2;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            usProd.Duplicate__c = FALSE;
            usProd.ASK_Custom_Kit__c = TRUE;
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            insert usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
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
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'EMEA');
            pqUs.BusinessUnit__c = 'EMEA';
            pqUs.OwnerId = usUser1.Id;
            pqUs.Type__c = 'ASK Agreement';
            pqUs.Language__c = 'English';
            pqUs.Sales_Org_Key__c = '';
            insert pqUS;
            
            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            insert pqliUs3;
            
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            Test.startTest();            
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            
            //sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, NULL, NULL, pqUs.Id);
            
            usProd.Alt_Site_List__c = 380.00;
            update usProd;
            //sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, NULL, NULL, pqUs.Id);
            
            usAcc.Customer_Group__c = '01';
            update usAcc;
            //sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, NULL, NULL, pqUs.Id);
            
            usProd.Distributor_List__c = 380.00;
            update usProd;
            //sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, NULL, NULL, pqUs.Id);
            
            usAcc.Customer_Group__c = '14';
            update usAcc;
           // sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, NULL, NULL, pqUs.Id);
            
            usProd.List_Price__c = 0.00;
            update usProd;
            //sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, NULL, NULL, pqUs.Id);
            
            usAcc.SAP_Sold_To__c = '100001';
            usAcc.Account_Group__c = 'Z002';
            update usAcc;
            sapPrice.userRoleBoolean = TRUE;
            //sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, NULL, NULL, pqUs.Id);
            
            usAcc.Customer_Group__c = '03';
            update usAcc;
            sapPrice.userRoleBoolean = TRUE;
            //sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, NULL, NULL, pqUs.Id);
            
            usAcc.Customer_Group__c = '04';
            update usAcc;
            sapPrice.userRoleBoolean = TRUE;
            //sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, NULL, NULL, pqUs.Id);
            
            usAcc.Customer_Group__c = '14';
            update usAcc;
            sapPrice.userRoleBoolean = TRUE;
            //sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, NULL, NULL, pqUs.Id);
            
            //pqUs.BusinessUnit__c = 'EMEA';
            //update pqUs;
            sapPrice.getSAPprice(new List<String>{usProd.Name}, NULL, NULL, pqUs.Id);
            
            Test.stopTest();
        }
        
    }
    
    
    @isTest static void testSAPprice2() {
        /*
* Implement test code
* create test users
* createUser(String firstName, String lastName, String approvalRole, String bu)
* Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
* bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
* Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name LIKE '%EMEA%' LIMIT 1].Id;
        User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
        usUser1.ManagerId = usUserMan.Id;
        usUser1.UserRoleId = roleId;
        insert usUser1;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
        System.runAs(usUser1){
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(accName, salesOrg, sapCode, custGrp)
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','17');
            usAcc.SAP_Sold_To__c = '';
            usAcc.Customer_Group__c = '03';
            insert usACC;
            
            Account usAcc1 = testDataFactoryPP.createAccount('TestAcount US1', 'US60','100002','17');
            usAcc1.SAP_Sold_To__c = '';
            insert usAcc1;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            insert con2;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            usProd.Duplicate__c = FALSE;
            usProd.ASK_Custom_Kit__c = TRUE;
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            insert usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
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
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'EMEA');
            pqUs.BusinessUnit__c = 'EMEA';
            pqUs.OwnerId = usUser1.Id;
            pqUs.Type__c = 'ASK Agreement';
            pqUs.Language__c = 'English';
            pqUs.Sales_Org_Key__c = '';
            insert pqUS;
            
            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            System.currentPageReference().getParameters().put('refresh', 'yes'); 
            
            Test.startTest();            
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPprice(new List<String>{usProd.Name}, NULL, NULL, pqUs.Id);
            
            Test.stopTest();
        }
        
    }
    
    @isTest static void testLineClassCheckIfPart() {
        
        Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','17');
        usAcc.SAP_Sold_To__c = '';
        usAcc.Customer_Group__c = '03';
        insert usACC;
        
        Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
        insert con1;
        
        Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
        usProd.Alt_Site_List__c = 0.00;
        usProd.Distributor_List__c = 0.00;
        usProd.Duplicate__c = FALSE;
        usProd.ASK_Custom_Kit__c = TRUE;
        usProd.Class__c = 'Anesthesia';
        usProd.Product_Class__c = '0025';
        insert usProd;
        
        Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
        usProd1.List_Price__c = 0.00;
        usProd1.Alt_Site_List__c = 380.00;
        usProd1.SubGroup__c = 'LMA Atomizers';
        usProd1.Class__c = 'Respiratory';
        usProd1.Product_Class__c = '0026';
        insert usProd1;
        
        
        Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'EMEA');
        pqUs.BusinessUnit__c = 'EMEA';
        pqUs.OwnerId = UserInfo.getUserId();
        pqUs.Type__c = 'ASK Agreement';
        pqUs.Language__c = 'English';
        pqUs.Sales_Org_Key__c = '';
        insert pqUS;
        
        Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
        insert pqliUs;
        
        Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
        insert pqliUs2;
        
        Test.startTest();   
        
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        sapPrice.lineClassCheck(pqUS.Id);
        sapPrice.lineProdCheckIcap(pqUS.Id);
        
        usProd1.Class__c = 'Cardiac Care Specialty';
        update usProd1;
        sapPrice.lineClassCheck(pqUS.Id);
        
        usProd1.Class__c = 'Cardiac Care Specialty';
        update usProd1;
        sapPrice.lineClassCheck(pqUS.Id);
        
        usProd.Class__c = 'Respiratory';
        update usProd;
        sapPrice.lineClassCheck(pqUS.Id);

        usProd.Class__c = 'Chest Drainage';
        update usProd;
        sapPrice.lineClassCheck(pqUS.Id);
        
        usProd.Class__c = 'Cardiac Care Specialty';
        usProd.Product_Class__c = '0024';
        update usProd;
        sapPrice.lineClassCheck(pqUS.Id);
        sapPrice.lineProdCheckIcap(pqUS.Id);
        
        usProd1.Product_Class__c = '0024';
        update usProd1;
        sapPrice.lineClassCheck(pqUS.Id);
        sapPrice.lineProdCheckIcap(pqUS.Id);

        Test.stopTest();
        
    }
    
    @isTest static void testLineClassCheckElsePart() {
        
        Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','17');
        usAcc.SAP_Sold_To__c = '';
        usAcc.Customer_Group__c = '03';
        insert usACC;
        
        Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
        insert con1;
        
        Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
        usProd.Alt_Site_List__c = 0.00;
        usProd.Distributor_List__c = 0.00;
        usProd.Duplicate__c = FALSE;
        usProd.ASK_Custom_Kit__c = TRUE;
        usProd.Class__c = 'Anesthesia';
        insert usProd;
        
        Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
        usProd1.List_Price__c = 0.00;
        usProd1.Alt_Site_List__c = 380.00;
        usProd1.SubGroup__c = 'LMA Atomizers';
        usProd1.Class__c = 'Respiratory';
        insert usProd1;
        
        PRF__c prfUs = testDataFactoryPP.createPrf(usAcc.Id, con1.Id,'US6010','Anesthesia');   
        insert prfUs;
        
        PRF_Line_Item__c prfliUs = testDataFactoryPP.createPrfLineItem(prfUs.Id, usProd.Id);
        insert prfliUs;
        
        PRF_Line_Item__c prfliUs2 = testDataFactoryPP.createPrfLineItem(prfUs.Id, usProd1.Id);
        insert prfliUs2;
        
        Test.startTest(); 
        
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        sapPrice.lineClassCheck(prfUs.Id);
        
        usProd1.Class__c = 'Cardiac Care Specialty';
        update usProd1;
        sapPrice.lineClassCheck(prfUs.Id);
        
        usProd1.Class__c = 'Cardiac Care Specialty';
        update usProd1;
        sapPrice.lineClassCheck(prfUs.Id);
        
        usProd.Class__c = 'Respiratory';
        update usProd;
        sapPrice.lineClassCheck(prfUs.Id);
        
        usProd.Class__c = 'Chest Drainage';
        update usProd;
        sapPrice.lineClassCheck(prfUs.Id);
        
        usProd.Class__c = 'Cardiac Care Specialty';
        update usProd;
        sapPrice.lineClassCheck(prfUs.Id);
        
        Test.stopTest();
        
    }
    
     @isTest static void testSAPpriceBulk2() {
         
         String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
         User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
         usUser1.UserRoleId = roleId;
         insert usUser1;
         
         System.runAs(usUser1){
             
             Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','17');
             usAcc.SAP_Sold_To__c = '999999';
             usAcc.Customer_Group__c = '03';
             insert usAcc;
             
             Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
             insert con1;
             
             Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
             usProd.Alt_Site_List__c = 0.00;
             usProd.Distributor_List__c = 0.00;
             usProd.Duplicate__c = FALSE;
             usProd.ASK_Custom_Kit__c = TRUE;
             usProd.Class__c = 'Anesthesia';
             usProd.Product_Class__c = '0025';
             usProd.Duplicate__c = FALSE;
             usProd.ASK_Custom_Kit__c = TRUE;
             usProd.Sales_Org_Key__c = 'US6010';
             usProd.Distribution_Channel__c = 'DC';
             insert usProd;
             
             Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
             usProd1.List_Price__c = 0.00;
             usProd1.Alt_Site_List__c = 380.00;
             usProd1.SubGroup__c = 'LMA Atomizers';
             usProd1.Class__c = 'Respiratory';
             usProd1.Product_Class__c = '0026';
             insert usProd1;
             
             
             Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'EMEA');
             pqUs.BusinessUnit__c = 'EMEA';
             pqUs.OwnerId = UserInfo.getUserId();
             pqUs.Type__c = 'ASK Agreement';
             pqUs.Language__c = 'English';
             pqUs.Sales_Org_Key__c = 'US6010';
             insert pqUS;
             
             Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
             insert pqliUs;
             
             Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
             insert pqliUs2;
             
             /*SAPRealPriceSet__x rps = new SAPRealPriceSet__x();
             rps.SalesOrg__c = usProd.Sales_Org__c;
             rps.DistChnl__c = usProd.Distribution_Channel__c ;
             rps.Customer__c = usAcc.SAP_Sold_To__c;
             rps.ShipTo__c = usAcc.SAP_Sold_To__c;
             rps.Material__c = usProd.Name ;
             rps.EffDate__c = datetime.now();
             insert rps;*/
             
             Test.startTest();   
             
             PP_SAP_Price sapPrice = new PP_SAP_Price();
             sapPrice.userRoleBoolean = TRUE;
             sapPrice.getSAPpriceBulk(new List<String>{'usProd'}, pqUS.Id);
             
             usProd.Alt_Site_List__c = 100.00;
             update usProd;
             sapPrice.getSAPpriceBulk(new List<String>{'usProd'}, pqUS.Id);

             //ZD
             usAcc.Customer_Group__c = '01';
             update usAcc;
             sapPrice.getSAPpriceBulk(new List<String>{'usProd'}, pqUS.Id);
             
             //ZD
             usProd.Distributor_List__c = 100.00;
             usProd.List_Price__c = 0.00;
             update usProd;
             sapPrice.getSAPpriceBulk(new List<String>{'usProd'}, pqUS.Id);
             
             //ZH
             usAcc.Customer_Group__c = '16';
             update usAcc;
             sapPrice.getSAPpriceBulk(new List<String>{'usProd'}, pqUS.Id);
             
             //ZH
             usProd.List_Price__c = 100.00;
             update usProd;
             sapPrice.getSAPpriceBulk(new List<String>{'usProd'}, pqUS.Id);
             
             Test.stopTest();
             
         }
     }
    
       @isTest static void getSAPprice3() {
         
         String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
         User usUser1 = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
         usUser1.UserRoleId = roleId;
         insert usUser1;
         
         System.runAs(usUser1){
             
             Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','17');
             usAcc.SAP_Sold_To__c = '999999';
             usAcc.Customer_Group__c = '03';
             insert usAcc;
             
             Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
             insert con1;
             
             Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
             usProd.Alt_Site_List__c = 0.00;
             usProd.Distributor_List__c = 0.00;
             usProd.Duplicate__c = FALSE;
             usProd.ASK_Custom_Kit__c = TRUE;
             usProd.Class__c = 'Anesthesia';
             usProd.Product_Class__c = '0025';
             usProd.Duplicate__c = FALSE;
             usProd.ASK_Custom_Kit__c = TRUE;
             usProd.Sales_Org_Key__c = 'US6010';
             usProd.Distribution_Channel__c = 'DC';
             insert usProd;
             
             Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
             usProd1.List_Price__c = 0.00;
             usProd1.Alt_Site_List__c = 380.00;
             usProd1.SubGroup__c = 'LMA Atomizers';
             usProd1.Class__c = 'Respiratory';
             usProd1.Product_Class__c = '0026';
             insert usProd1;
             
             
             Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'EMEA');
             pqUs.BusinessUnit__c = 'EMEA';
             pqUs.OwnerId = UserInfo.getUserId();
             pqUs.Type__c = 'ASK Agreement';
             pqUs.Language__c = 'English';
             pqUs.Sales_Org_Key__c = 'US6010';
             insert pqUS;
             
             Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
             insert pqliUs;
             
             Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
             insert pqliUs2;
             
             /*SAPRealPriceSet__x rps = new SAPRealPriceSet__x();
             rps.SalesOrg__c = usProd.Sales_Org__c;
             rps.DistChnl__c = usProd.Distribution_Channel__c ;
             rps.Customer__c = usAcc.SAP_Sold_To__c;
             rps.ShipTo__c = usAcc.SAP_Sold_To__c;
             rps.Material__c = usProd.Name ;
             rps.EffDate__c = datetime.now();
             insert rps;*/
             
             Test.startTest();   
             
             PP_SAP_Price sapPrice = new PP_SAP_Price();
             sapPrice.userRoleBoolean = TRUE;
             sapPrice.getSAPprice(new List<String>{usProd.Name}, 'refresh', NULL, pqUS.Id);
             //sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, 'refresh', NULL, pqUS.Id);

             //ZD
             usAcc.Customer_Group__c = '01';
             update usAcc;
             sapPrice.getSAPprice(new List<String>{usProd.Name}, 'refresh', NULL, pqUS.Id);
             //sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, 'refresh', NULL, pqUS.Id);
      
             //ZH
             usAcc.Customer_Group__c = '16';
             update usAcc;
             sapPrice.getSAPprice(new List<String>{usProd.Name}, 'refresh', NULL, pqUS.Id);
             //sapPrice.getSAPpriceOld(new List<String>{usProd.Id}, 'refresh', NULL, pqUS.Id);
           
             Test.stopTest();
             
         }
     }
  
    
    
}//end of test class