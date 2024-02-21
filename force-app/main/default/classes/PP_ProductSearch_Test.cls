/*********************************************************************
* Description      : Test coverage for Product Search in Pricing Portal.
* Coverage         : Classes(PP_ProductSearch)
* Author(s)        : Dun Silver
**********************************************************************/
@isTest
public class PP_ProductSearch_Test {

    static testmethod void PP_ProductSearch_UnitTest(){
        PP_ProductSearch psController = new PP_ProductSearch();

        PageReference pageRef = new PageReference('/apex/PP_ProductSearch');
        Test.setCurrentPage(pageRef);

        psController.getProduct2();
        psController.refreshPageSize();
        //psController.getFormatListPrices();   

        Profile p = [select id from profile where name='System Administrator'];
        UserRole ur = [SELECT Id,Name FROM UserRole WHERE Name = 'Commercial Operations'];
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
            UserRoleId = ur.Id
        );
        insert u;

        User u2 = new User(
            alias = 'uflex77',
            email='unit2.test@unit2.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Adam2',
            lastname='Franks2',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p.Id,
            timezonesidkey='Europe/London',
            username='unit2.test@unit2.teleflex.com',
            UserRoleId = ur.Id
        );
        insert u2;
        
        System.runAs(u){

            Account accTest = new Account(
                Name = 'TestAccount',
                Account_Group__c = '17',
                ERP_Active__c = true,
                SAP_Sold_To__c = '110068'
            );
            insert accTest;
            
            Account accTest2 = new Account(
                Name = 'TestAccount2',
                Account_Group__c = '17',
                ERP_Active__c = true,
                SAP_Sold_To__c = '110069'
            );
            insert accTest2;
            
            Account accTest3 = new Account(
                Name = 'TestAccount3',
                Account_Group__c = '17',
                ERP_Active__c = true,
                SAP_Sold_To__c = '110070'
            );
            insert accTest3;
            
            Contact conTest = new Contact(
                Email = 'TestContact@email.com',
                FirstName = 'Test',
                LastName = 'Contact',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                AccountId = accTest.Id
            );
            insert conTest;
            
            Contact conTest2 = new Contact(
                Email = 'Test1Contact1@email.com',
                FirstName = 'Test1',
                LastName = 'Contact1',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                AccountId = accTest2.Id
            );
            insert conTest2;
            
            Contact conTest3 = new Contact(
                Email = 'Test2Contact2@email.com',
                FirstName = 'Test2',
                LastName = 'Contact2',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                AccountId = accTest3.Id
            );
            insert conTest3;
            
            // PR XPRI Sales_Condition_Mapping__c Mapped_Value__c Name
            Sales_Condition_Mapping__c scm = new Sales_Condition_Mapping__c(
                Name = 'PR',
                Mapped_Value__c = 'XPRI'
            );
            insert scm;
            
            Price_Quote__c PQTest = new Price_Quote__c(
                Account_Name__c = accTest.Id,
                Contact_Name__c = conTest.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.Today() + 90
            );
            insert PQTest;
            
            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
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
                Active_Sales_Org_Key__c = 'US6010',
                Active_Currency__c = 'USD',
                Pricing_Tier_Access__c = 1
            );
            insert cu;
            
            Contract_User__c cu2 = new Contract_User__c(
                Name = 'Adam2 Franks2',
                User__c = u2.id,
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
            insert cu2;
            
            Product2 prodTest = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='40',
                Family = 'Hardware',
                Material__c='AA-10511-1',
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
                RSM_Price__c=330.00,
                Distribution_Channel__c='10',
                Sales_Org_Key__c='US6010',
                Single_Use_Demo__c = TRUE
            );
            insert prodTest;
            
            Product2 prodTest2 = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='40',
                Family = 'Hardware',
                Material__c='AA-10511-1',
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
                RSM_Price__c=330.00,
                Distribution_Channel__c='10',
                Sales_Org_Key__c='US103010',
                Multi_Use_Demo__c = TRUE
            );
            insert prodTest2;
            
            Product2 prodTest3 = new Product2(
                Name = 'Applier101',
                ProductCode= 'Applier101',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='40',
                Family = 'Hardware',
                Material__c='Applier101',
                Brand_Name__c='Arrow',
                Buom__c='EA',
                Class__c='Cardiac Care Specialty',
                Cost__c=11587.40,
                Cost_Price_Unit__c=1000,
                Division__c='60',
                Description='APPLIER ACCESS TRAY',
                Group__c='Interventional',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,
                Sales_Unit__c='CS',
                List_Price__c=380.00,
                Rep_Price__c=350.00,
                RSM_Price__c=330.00,
                Distribution_Channel__c='10',
                Sales_Org_Key__c='US6010',
                Applier__c = TRUE
            );
            insert prodTest3;
            
            Cross_Reference__c CRTest = new Cross_Reference__c(
                Competitor_Product_Code__c = '320250',
                Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                Competitor_Name__c ='Jarit/Integra',
                Percent_Match__c=100,
                Product__c = prodTest.Id
            );
            insert CRTest;
            
            Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
                Price_Quote__c = PQTest.Id,
                Material_Name__c = prodTest.Id,
                Sales_Price__c = 230.00,
                Quantity__c=1,
                Extended_Price__c = 230.00,
                Competetive_Product__c = CRTest.Id
            );
            insert PQLineItem;
            
            PRF__c prfTest = new PRF__c(
                Account__c = accTest.Id,
                Contact__c = conTest.Id,
                Status__c = 'New',
                Requisition_Date__c = Date.valueOf('2015-03-11'),
                Sales_Org_Key__c = 'US6010',
                Price_Quote__c = PQTest.Id
            );
            insert prfTest;
            
            PRF__c prfTest2 = new PRF__c(
                Account__c = accTest.Id,
                Contact__c = conTest.Id,
                Status__c = 'New',
                Requisition_Date__c = Date.valueOf('2015-03-11'),
                Sales_Org_Key__c = 'US103010',
                Price_Quote__c = PQTest.Id
            );
            insert prfTest2;
            
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
            
            Territory_Master__c tm = new Territory_Master__c(
                Name = '700123',
                Territory_Number__c = '700123',
                Business_Unit__c = 'EMS',
                Shipping_Street__c = '123 Main St',
                Shipping_City__c = 'Raleigh',
                Shipping_State__c = 'NC',
                Shipping_Postal_Code__c = '27614',
                Shipping_Country__c = 'US'
            );
            insert tm;
            System.debug('Insert Territory Master-->' + tm);
            
            Territory_User__c tu = new Territory_User__c(
                Territory_Master__c = tm.Id,
                Territory_Number__c = '700123',
                User__c = u.id
            );
            insert tu;
            System.debug('Insert Territory User-->' + tu);
            
            Sample_Request__c srec = new Sample_Request__c(
                Account__c = accTest.Id,
                Contact__c = conTest.Id,
                Default_Quantity__c = 1,
                Default_Unit_of_Measure__c = 'Each',
                Shipping_Method__c = 'Standard',
                Status__c = 'New',
                Territory__c = tm.Id,
                Shipping_Address_1__c = '3015 Carrington Mill Blvd',
                Shipping_City__c = 'Morrisville',
                Shipping_State__c = 'NC',
                Shipping_Zipcode__c = '27560',
                Shipping_Country__c = 'US',
                Sales_Org_Key__c = 'NZ1010',
                Type__c = 'Field Sales Stock'
            );
            insert srec;
            system.debug('srec: ' + srec);
            
            Sample_Request__c srec1 = new Sample_Request__c(
                Account__c = accTest.Id,
                Contact__c = conTest.Id,
                Default_Quantity__c = 1,
                Default_Unit_of_Measure__c = 'Each',
                Shipping_Method__c = 'Standard',
                Status__c = 'New',
                Territory__c = tm.Id,
                Shipping_Address_1__c = '3015 Carrington Mill Blvd',
                Shipping_City__c = 'Morrisville',
                Shipping_State__c = 'NC',
                Shipping_Zipcode__c = '27560',
                Shipping_Country__c = 'US',
                Sales_Org_Key__c = 'NZ1010',
                Type__c = 'Disposable/Single Use Demo Product (i.e., Not for Human Use)'
            );
            insert srec1;
            system.debug('srec1: ' + srec1);
            
            Sample_Request__c srec2 = new Sample_Request__c(
                Account__c = accTest.Id,
                Contact__c = conTest.Id,
                Default_Quantity__c = 1,
                Default_Unit_of_Measure__c = 'Each',
                Shipping_Method__c = 'Standard',
                Status__c = 'New',
                Territory__c = tm.Id,
                Shipping_Address_1__c = '3015 Carrington Mill Blvd',
                Shipping_City__c = 'Morrisville',
                Shipping_State__c = 'NC',
                Shipping_Zipcode__c = '27560',
                Shipping_Country__c = 'US',
                Sales_Org_Key__c = 'NZ1010',
                Type__c = 'Multi-Use Product Demo (i.e., Surgical Instrumentation)'
            );
            insert srec2;
            system.debug('srec2: ' + srec2);
            
            Sample_Request__c srec3 = new Sample_Request__c(
                Account__c = accTest3.Id,
                Contact__c = conTest3.Id,
                Default_Quantity__c = 1,
                Default_Unit_of_Measure__c = 'Each',
                Shipping_Method__c = 'Standard',
                Status__c = 'New',
                Territory__c = tm.Id,
                Shipping_Address_1__c = '3015 Carrington Mill Blvd',
                Shipping_City__c = 'Morrisville',
                Shipping_State__c = 'NC',
                Shipping_Zipcode__c = '27560',
                Shipping_Country__c = 'US',
                Sales_Org_Key__c = 'US61010',
                Type__c = 'Loaner'
            );
            insert srec3;
            system.debug('srec3: ' + srec3);
            
            PageReference ps = Page.PP_ProductSearch;
            Test.setCurrentPage(ps);
            ps.getParameters().put('pqid',PQTest.Id);
            ps.getParameters().put('prdsrch','AA-10511-1');
            ps.getParameters().put('rowIndex','1');
            ps.getParameters().put('recSales_Org_Key','US6010');
            
            psController = new PP_ProductSearch();
            
            //code coverage for global activeQuoteIdStr variable
            //String aq = psController.activeQuoteIdStr;
            //psController.activeQuoteIdStr = PQTest.Id;
            
            psController.getURL();
            //psController.getActiveQuoteIdStr();
            //psController.getActiveQuoteName();
            psController.getProduct2();
            psController.sapPrice();
            psController.refreshPageSize();
            Boolean isMultiDemo = psController.isMultiDemo;
            Boolean isSingleDemo = psController.isSingleDemo; 
            Boolean isApplier = psController.isApplier;
            
            Test.setCurrentPage(ps);
            ps.getParameters().put('pqid',PQTest.Id);
            ps.getParameters().put('prdsrch','');
            ps.getParameters().put('rowIndex','1');
            psController.getURL();
            //psController.getActiveQuoteIdStr();
            //psController.getActiveQuoteName();
            psController.getProduct2();
            psController.sapPrice();
            psController.refreshPageSize();
            
            String prodEntry2 = psController.prodEntry2;
            String rowIndex = psController.rowIndex;
            String strQuoteId = psController.strQuoteId;
            
            Test.setCurrentPage(ps);
            ps.getParameters().put('pqid',PQTest.Id);
            ps.getParameters().put('prdsrch','  ');
            ps.getParameters().put('rowIndex','1');
            psController.getURL();
            //psController.getActiveQuoteIdStr();
            //psController.getActiveQuoteName();
            psController.getProduct2();
            psController.sapPrice();
            psController.refreshPageSize();
            
            pageRef = new PageReference('/apex/PP_ProductSearch?prfid=' + prfTest.Id);
            system.debug('PRF Page' + pageRef);
            Test.setCurrentPage(pageRef);
            
            psController = new PP_ProductSearch();
            pageRef.getParameters().put('prfid',prfTest.Id);
            pageRef.getParameters().put('prdsrch','AA-10511-1');
            psController.getURL();
            psController.sapPrice();
            
            pageRef = new PageReference('/apex/PP_ProductSearch?srId=' + srec.Id+'&prdsrch=AA-10511-1');
            system.debug('Sr Page' + pageRef);
            Test.setCurrentPage(pageRef);
            
            psController = new PP_ProductSearch();
            pageRef.getParameters().put('srId',srec.Id);
            pageRef.getParameters().put('prdsrch',prodTest.Id);
            pageRef.getParameters().put('prdsrchVal',prodTest.Id);
            psController.getURL();
            //psController.sapPrice();
            psController.strMats = 'AA-10511-1';
            psController.bulkInsert2();
            psController.clearSearch();
            
            /************** Start of further testing *****************/
            pageRef = new PageReference('/apex/PP_ProductSearch?srId=' + srec1.Id+'&prdsrch=AA-10511-1');
            system.debug('Sr Page' + pageRef);
            Test.setCurrentPage(pageRef);
            
            psController = new PP_ProductSearch();
            psController.size = NULL;
            psController.getProduct2();
            System.assertEquals(psController.refreshPageSize(),NULL);
            pageRef.getParameters().put('srId',srec1.Id);
            pageRef.getParameters().put('prdsrch',prodTest2.Id);
            pageRef.getParameters().put('prdsrchVal',prodTest2.Id);
            psController.getURL();
            //psController.sapPrice();
            psController.strMats = 'AA-10511-1';
            psController.bulkInsert2();
            psController.clearSearch();
            
            pageRef = new PageReference('/apex/PP_ProductSearch?srId=' + srec2.Id+'&prdsrch=AA-10511-1');
            system.debug('Sr Page' + pageRef);
            Test.setCurrentPage(pageRef);
            
            psController = new PP_ProductSearch();
            psController.size = 1;
            psController.getProduct2();
            pageRef.getParameters().put('srId',srec2.Id);
            pageRef.getParameters().put('prdsrch',prodTest2.Id);
            pageRef.getParameters().put('prdsrchVal',prodTest2.Id);
            psController.getURL();
            //psController.noOfRecords = psController.setCon.getResultSize();
            //psController.sapPrice();
            psController.strMats = 'AA-10511-1';
            psController.bulkInsert2();
            psController.clearSearch();
            
            pageRef = new PageReference('/apex/PP_ProductSearch?srId=' + srec3.Id+'&prdsrch=Applier101');
            system.debug('Sr Page' + pageRef);
            Test.setCurrentPage(pageRef);
            
            List<Product2> prodList = new List<Product2>();
            prodList.add(prodTest3);
            psController = new PP_ProductSearch();
            psController.size = 1;
            psController.getProduct2();
            pageRef.getParameters().put('srId',srec3.Id);
            pageRef.getParameters().put('prdsrch',prodTest3.Id);
            pageRef.getParameters().put('prdsrchVal',prodTest3.Id);
            psController.getURL();
            //psController.noOfRecords = psController.setCon.getResultSize();
            //psController.sapPrice();
            psController.strMats = 'Applier101';
            psController.getFormatListPrices(prodList);
            psController.getFormatDistributorPrices(prodList);
            psController.getFormatAltSitePrices(prodList);
            psController.getFormatRsmPrices(prodList);
            psController.getFormatRepPrices(prodList);
            psController.bulkInsert2();
            psController.clearSearch();
        }//end system run as
    }//end getURL test method

}//end of test class