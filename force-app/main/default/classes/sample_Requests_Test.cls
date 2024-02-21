/*********************************************************************
* Description      : Test coverage for Sample Request process.
* Coverage         : Classes(sample_Requests)
* Author(s)        : Eric Clay, Dun Silver
**********************************************************************/

@istest
public class sample_Requests_Test {
    
    @testSetup
    static void sample_Requests_Test() {
        // Starts Sample Request Test
        
        Profile p = [select id from profile where name='System Administrator'];
        String userRoleLatin = [SELECT Id, Name FROM UserRole WHERE Name LIKE '%Latin%' LIMIT 1].Id;
        String userRole = [SELECT Id, Name FROM UserRole WHERE Name LIKE '%Teleflex Global%' LIMIT 1].Id;
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
            Business_Unit__c = 'Anesthesia',
            UserRoleId = userRole
        );
        insert u;
        
        User u2 = new User(
            alias = 'latam76',
            email='latam.test@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Latam',
            lastname='Franks',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p.Id,
            timezonesidkey='Europe/London',
            username='latam.test@unit.teleflex.com',
            Business_Unit__c = 'Latin America',
            UserRoleId = userRoleLatin
        );
        insert u2;
        
            System.runAs(u){
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
                //master_TriggerHelperClass.runOnce('resetOnceSet');
                //alist.add(a);
                insert a;
                
                Contact c = new Contact(
                    FirstName = 'Test',
                    LastName = 'Contact',
                    Email = 'TestContact@email.com',
                    Position_Job_Title__c='Administrator',
                    Credentials__c='RN',
                    Preferred_language__c='English (American)',
                    AccountId = a.Id
                );
                insert c;
                
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
                
                Territory_Master__c tm2 = new Territory_Master__c(
                    Name = '900123',
                    Territory_Number__c = '900123',
                    Business_Unit__c = 'EMS',
                    Shipping_Street__c = '321 Main St',
                    Shipping_City__c = 'Durham',
                    Shipping_State__c = 'NC',
                    Shipping_Postal_Code__c = '27701',
                    Shipping_Country__c = 'US'
                );
                insert tm2;
                System.debug('Insert Territory Master 2-->' + tm2);
                
                Territory_User__c tu = new Territory_User__c(
                    Territory_Master__c = tm.Id,
                    Territory_Number__c = '700123',
                    User__c = u.id,
                    Primary__c = TRUE
                );
                insert tu;
                System.debug('Insert Territory User-->' + tu);
                
                Territory_User__c tu2 = new Territory_User__c(
                    Territory_Master__c = tm2.Id,
                    Territory_Number__c = '900123',
                    User__c = u.id,
                    Primary__c = TRUE
                );
                insert tu2;
                System.debug('Insert Territory User 2-->' + tu2);
                
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
                    Material_Key__c = 'AA-10511-1-US60-10',
                    Sales_Org_Key__c = 'US6010',
                    Sales_Org__c = 'US60',
                    Distribution_Channel__c = '10'
                );
                insert prod;
                
                Product2 prod2 = new Product2(
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
                    Material_Key__c = 'AA-10511-1-US60-20',
                    Sales_Org_Key__c = 'US6020',
                    Sales_Org__c = 'US60',
                    Distribution_Channel__c = '20'
                );
                insert prod2;
                
                Sample_Request__c srec = new Sample_Request__c(
                    Account__c = a.Id,
                    Contact__c = c.Id,
                    Default_Quantity__c = 1,
                    Default_Unit_of_Measure__c = 'EACH',
                    Shipping_Method__c = 'Standard',
                    Status__c = 'New',
                    Territory__c = tm.Id,
                    Shipping_Address_1__c = '3015 Carrington Mill Blvd',
                    Shipping_City__c = 'Morrisville',
                    Shipping_State__c = 'NC',
                    Shipping_Zipcode__c = '27560',
                    Shipping_Country__c = 'US',
                    Type__c = 'Sample',
                    Sales_Org_Key__c = 'US6010'
                );
                insert srec;
                system.debug('srec: ' + srec);
                
                // Test the Silly Sales Org Key missing trigger/class - ESC 20180509
                Contract_User__c cu = new Contract_User__c(
                    Name = 'Adam Franks',
                    User__c = u.id,
                    Active_Region__c = 'US - Teleflex/Arrow',
                    US_Material__c = TRUE,
                    Pricing_Portal_Access__c = TRUE,
                    Active_Sales_Org_Key__c = 'US6010',
                    Division_10__c = TRUE,
                    Division_20__c = TRUE,
                    Division_30__c = TRUE,
                    Division_40__c = TRUE,
                    Division_50__c = TRUE,
                    Division_60__c = TRUE
                );
                insert cu;
                
                Contract_User__c cu2 = new Contract_User__c(
                    Name = 'Latam Franks',
                    User__c = u2.id,
                    Active_Region__c = 'LA - Latin America',
                    Pricing_Portal_Access__c = TRUE,
                    Active_Sales_Org_Key__c = 'US6020',
                    LA_Material__c = TRUE,
                    LA_Division_10__c = TRUE,
                    LA_Division_20__c = TRUE,
                    LA_Division_30__c = TRUE,
                    LA_Division_40__c = TRUE,
                    LA_Division_50__c = TRUE,
                    LA_Division_60__c = TRUE
                );
                insert cu2;
                
                Sample_Request__c srec2 = new Sample_Request__c(
                    Account__c = a.Id,
                    Contact__c = c.Id,
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
                    Type__c = 'Disposable/Single Use Demo Product (i.e., Not for Human Use)',
                    Sales_Org_Key__c = 'US6010'
                );
                insert srec2;
                system.debug('srec2: ' + srec2);
                
                // End Silly Test
                
                Lead l1 = new Lead(
                    FirstName = 'Test',
                    LastName = 'Lead1',
                    Company = 'Teleflex',
                    Street = '123 Test St',
                    City = 'Morrisville',
                    State = 'NC',
                    PostalCode = '27560',
                    Country = 'US'
                );
                insert l1;
                system.debug('l1: ' + l1);
                
                Lead l2 = new Lead(
                    FirstName = 'Test',
                    LastName = 'Lead2',
                    Company = 'Teleflex',
                    Street = '999 Test St',
                    City = 'Durham',
                    State = 'NC',
                    PostalCode = '27601',
                    Country = 'US'
                );
                insert l2;
                system.debug('l2: ' + l2);
                
                // Loaner Testing?
                Sample_Request__c srec3 = new Sample_Request__c(
                    Account__c = a.Id,
                    Contact__c = c.Id,
                    Lead__c = l1.Id,
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
                    Type__c = 'Loaner',
                    Sales_Org_Key__c = 'US6010'
                );
                insert srec3;
                system.debug('srec3: ' + srec3);
                
                // Loaner Testing?
                Sample_Request__c srec4 = new Sample_Request__c(
                    Account__c = a.Id,
                    Contact__c = c.Id,
                    Lead__c = l1.Id,
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
                    Type__c = 'Field Sales Stock',
                    Sales_Org_Key__c = 'US6010'
                );
                insert srec4;
                system.debug('srec4: ' + srec4);
                
                RecordType recType = [SELECT Id, Name From RecordType WHERE Name = 'Latam Sample Request' LIMIT 1];
                Sample_Request__c srec5 = new Sample_Request__c(
                    RecordTypeId = recType.Id,
                    Account__c = a.Id,
                    Contact__c = c.Id,
                    Lead__c = l1.Id,
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
                    Type__c = 'Disposable/Single Use Demo Product (i.e., Not for Human Use)',
                    Sales_Org_Key__c = 'US6020'
                );
                insert srec5;
                system.debug('srec5: ' + srec5);
                
                Sample_Request__c srec6 = new Sample_Request__c(
                    //RecordTypeId = recType.Id,
                    Account__c = a.Id,
                    Contact__c = c.Id,
                    Lead__c = l1.Id,
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
                    Type__c = 'Loaner',
                    Sales_Org_Key__c = 'US6010'
                );
                insert srec6;
                system.debug('srec6: ' + srec6);
            }//end of System.RunAs(u) 
        
        }//end testdata setup method
    
    @isTest static void sampleRequestTest() {
        User u = [SELECT Id, Name, Email FROM User WHERE Email = 'unit.test@unit.teleflex.com' LIMIT 1];
        RecordType recTypeObj= [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'Latam Sample Request'];
        String recordTypeId = recTypeObj.Id;
        
        System.runAs(u){
            Territory_User__c tu = [SELECT Id, User__c, Territory_Master__c, Territory_Number__c,
                                    Territory_Master__r.Territory_Number__c, Territory_Master__r.Shipping_Street__c, 
                                    Territory_Master__r.Shipping_City__c,Territory_Master__r.Shipping_State__c, 
                                    Territory_Master__r.Shipping_Postal_Code__c, Territory_Master__r.Shipping_Country__c, 
                                    Territory_Master__r.Territory_Name_2__c, Territory_Master__r.Territory_Name__c, 
                                    Territory_Master__r.Manager__c
                                    FROM Territory_User__c
                                    WHERE User__c =: u.Id LIMIT 1];
            
            Sample_Request__c srec = [SELECT Id, Account__c, Contact__c, Lead__c, Shipping_City__c, Type__c,
                                        Shipping_State__c, Shipping_Country__c, Default_Quantity__c,
                                        Default_Unit_of_Measure__c, Status__c, Territory__c, Shipping_Zipcode__c, 
                                        Shipping_Address_1__c, Sales_Org_Key__c
                                        FROM Sample_Request__c
                                        WHERE Account__r.SAP_Sold_To__c ='100123'
                                        AND Type__c = 'Sample' LIMIT 1];
            
            List<Product2> products = [SELECT Id, Name, Brand_Name__c, Description, Class__c, Group__c, SubGroup__c, SBU__c,
                                           Sales_Unit__c, Qty_Sales_Unit__c, Image_URL__c, CurrencyIsoCode, Sales_Org__c,
                                           Distribution_Channel__c, List_Price__c, RSM_Price__c, Rep_Price__c, Material_Status__c,
                                           Distributor_List__c, Alt_Site_List__c, MRP_Group__c, ASK_Custom_Kit__c, SearchableProducts__c, Sales_Org_Key__c
                                           FROM Product2
                                           WHERE Name = 'AA-10511-1' AND Sales_Org_Key__c = 'US6010'];
            
            PageReference pageSR = new PageReference('/apex/sample_requests');
                system.debug('Price Quote Page' + pageSR);
                Test.setCurrentPage(pageSR);
                
                System.currentPageReference().getParameters().put('id', tu.Territory_Master__c);
                System.currentPageReference().getParameters().put('tid', tu.Territory_Master__c);
                System.currentPageReference().getParameters().put('s', '700123');
                System.currentPageReference().getParameters().put('RecordType', recordTypeId);
            
                ApexPages.StandardController ctlr = new ApexPages.StandardController(srec);
                sample_Requests sr = new sample_Requests(ctlr);
                String searchStr = sr.searchStr;
                Boolean isLoaner = sr.isLoaner;
                Boolean latamUser = sr.latamUser;
                String salesOrgKey = sr.salesOrgKey;
                latamUser = FALSE;
                Sample_Request__c newSample = sr.newSample;
                sr.newSample.Contact__c = srec.Contact__c;
                //newSample.Contact__c = srec.Contact__c;
               
                sample_Requests.lineItemAdd(products[0].Id, srec.Id);
                sample_Requests.lineItemBulk(products, srec.Id);
                
                //sr.latamUser = NULL;
                System.debug('*** latamUser Test *** ' + latamUser);
                sr.search();
                sr.save();
                
                //sample_Requests.lineItemAdd(products[0].Id, srec.Id);
                //sample_Requests.lineItemBulk(products, srec.Id);
                
                PageReference pageSR1 = new PageReference('/apex/sample_requests');
                system.debug('Price Quote Page' + pageSR1);
                Test.setCurrentPage(pageSR1);
                
                System.currentPageReference().getParameters().put('id', tu.Territory_Master__c);
                System.currentPageReference().getParameters().put('tid', srec.Account__c);
                System.currentPageReference().getParameters().put('s', '700123');
                
                ctlr = new ApexPages.StandardController(srec);
                sr = new sample_Requests(ctlr);
                searchStr = sr.searchStr;
                
                sr.tnId = tu.Territory_Master__c;
                //sr.latamUser = true;
                sr.search();
                System.debug('*** salesOrgKey *** ' + salesOrgKey);
                salesOrgKey = NULL;
                System.debug('*** salesOrgKey *** ' + salesOrgKey);
                sr.save();
                sample_Requests.lineItemAdd(products[0].Id, srec.Id);
                //sample_Requests.lineItemBulk(prod.Id, srec.Id);
                sr.updateType();
                //sr.updateAddress();
                sr.updateAddressToLead();
                sr.updateAddressToAccount();
                sr.updateAddressToTerritory();
                sr.updateAddressToContact();
                sr.updateShippingMethod();
        }//end of System.runAs(u)
    }//end of sampleRequestTest Method
    
    @isTest static void sampleRequestTest1() {
        User u1 = [SELECT Id, Name, Email FROM User WHERE Email = 'latam.test@unit.teleflex.com' LIMIT 1];
        RecordType recTypeObj= [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'Latam Sample Request'];
        String recordTypeId = recTypeObj.Id;
        
        System.runAs(u1){
            Account a = [SELECT Id, Name FROM Account WHERE Name = 'Test PP Account' LIMIT 1];
            
            Sample_Request__c srec = [SELECT Id, Account__c, Contact__c, Lead__c, Shipping_City__c, Type__c,
                                        Shipping_State__c, Shipping_Country__c, Default_Quantity__c,
                                        Default_Unit_of_Measure__c, Status__c, Territory__c, Shipping_Zipcode__c, 
                                        Shipping_Address_1__c, Sales_Org_Key__c
                                        FROM Sample_Request__c
                                        WHERE Account__r.SAP_Sold_To__c ='100123'
                                        AND Type__c = 'Sample' LIMIT 1];
            
            List<Product2> products = [SELECT Id, Name, Brand_Name__c, Description, Class__c, Group__c, SubGroup__c, SBU__c,
                                           Sales_Unit__c, Qty_Sales_Unit__c, Image_URL__c, CurrencyIsoCode, Sales_Org__c,
                                           Distribution_Channel__c, List_Price__c, RSM_Price__c, Rep_Price__c, Material_Status__c,
                                           Distributor_List__c, Alt_Site_List__c, MRP_Group__c, ASK_Custom_Kit__c, SearchableProducts__c, Sales_Org_Key__c
                                           FROM Product2
                                           WHERE Name = 'AA-10511-1' AND Sales_Org_Key__c = 'US6020'];
            
            PageReference pageSR = new PageReference('/apex/sample_requests');
                system.debug('Price Quote Page' + pageSR);
                Test.setCurrentPage(pageSR);
                
                //System.currentPageReference().getParameters().put('id', tu.Territory_Master__c);
                System.currentPageReference().getParameters().put('tid', a.Id);
                System.currentPageReference().getParameters().put('tnid', NULL);
                System.currentPageReference().getParameters().put('s', '900123');
                System.currentPageReference().getParameters().put('RecordType', recordTypeId);
            
                ApexPages.StandardController ctlr = new ApexPages.StandardController(srec);
                sample_Requests sr = new sample_Requests(ctlr);
                String searchStr = sr.searchStr;
                Boolean isLoaner = sr.isLoaner;
                Boolean latamUser = sr.latamUser;
                String salesOrgKey = sr.salesOrgKey;
                Sample_Request__c newSample = sr.newSample;
                
                sr.search();
                System.debug('*** salesOrgKey1 *** ' + salesOrgKey);
                salesOrgKey = 'US6020';
                System.debug('*** salesOrgKey1 *** ' + salesOrgKey);
                sr.save();
            
                //sample_Requests.lineItemAdd(products[0].Id, srec.Id);
                //sample_Requests.lineItemBulk(products, srec.Id);
                
                //sr.tnId = tu.Territory_Master__c;
                //sr.latamUser = true;
                sr.search();
                sr.save();
                //sample_Requests.lineItemAdd(products[0].Id, srec.Id);
                //sample_Requests.lineItemBulk(prod.Id, srec.Id);
                sr.updateType();
                //sr.updateAddress();
                sr.updateAddressToLead();
                sr.updateAddressToAccount();
                sr.updateAddressToTerritory();
                sr.updateAddressToContact();
                sr.updateShippingMethod();
        }//end of System.runAs(u1)
    }//end of sampleRequestTest1 Method
    
    @isTest static void sampleRequestTest2() {
        User u = [SELECT Id, Name, Email FROM User WHERE Email = 'unit.test@unit.teleflex.com' LIMIT 1];
        RecordType recTypeObj= [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'Latam Sample Request'];
        String recordTypeId = recTypeObj.Id;
        
        System.runAs(u){
            
            Territory_User__c tu = [SELECT Id, User__c, Territory_Master__c, Territory_Number__c,
                                    Territory_Master__r.Territory_Number__c, Territory_Master__r.Shipping_Street__c, 
                                    Territory_Master__r.Shipping_City__c,Territory_Master__r.Shipping_State__c, 
                                    Territory_Master__r.Shipping_Postal_Code__c, Territory_Master__r.Shipping_Country__c, 
                                    Territory_Master__r.Territory_Name_2__c, Territory_Master__r.Territory_Name__c, 
                                    Territory_Master__r.Manager__c
                                    FROM Territory_User__c
                                    WHERE User__c =: u.Id LIMIT 1];
            
            Sample_Request__c srec = [SELECT Id, Account__c, Contact__c, Lead__c, Shipping_City__c, Type__c,
                                        Shipping_State__c, Shipping_Country__c, Default_Quantity__c,
                                        Default_Unit_of_Measure__c, Status__c, Territory__c, Shipping_Zipcode__c, 
                                        Shipping_Address_1__c, Sales_Org_Key__c
                                        FROM Sample_Request__c
                                        WHERE Account__r.SAP_Sold_To__c ='100123'
                                        AND Type__c = 'Sample' LIMIT 1];
            
            List<Product2> products = [SELECT Id, Name, Brand_Name__c, Description, Class__c, Group__c, SubGroup__c, SBU__c,
                                           Sales_Unit__c, Qty_Sales_Unit__c, Image_URL__c, CurrencyIsoCode, Sales_Org__c,
                                           Distribution_Channel__c, List_Price__c, RSM_Price__c, Rep_Price__c, Material_Status__c,
                                           Distributor_List__c, Alt_Site_List__c, MRP_Group__c, ASK_Custom_Kit__c, SearchableProducts__c, Sales_Org_Key__c
                                           FROM Product2
                                           WHERE Name = 'AA-10511-1' AND Sales_Org_Key__c = 'US6010'];
            
            PageReference pageSR = new PageReference('/apex/sample_requests');
                system.debug('Price Quote Page' + pageSR);
                Test.setCurrentPage(pageSR);
                
                System.currentPageReference().getParameters().put('id', tu.Territory_Master__c);
                System.currentPageReference().getParameters().put('tid', tu.Territory_Master__c);
                System.currentPageReference().getParameters().put('s', '700123');
                System.currentPageReference().getParameters().put('RecordType', recordTypeId);
            
                ApexPages.StandardController ctlr = new ApexPages.StandardController(srec);
                sample_Requests sr = new sample_Requests(ctlr);
                String searchStr = sr.searchStr;
                Boolean isLoaner = sr.isLoaner;
                Boolean latamUser = sr.latamUser;
                String salesOrgKey = sr.salesOrgKey;
                latamUser = FALSE;
                Sample_Request__c newSample = sr.newSample;
                sr.newSample.Contact__c = srec.Contact__c;
                //newSample.Contact__c = srec.Contact__c;
                
                //sr.latamUser = NULL;
                System.debug('*** latamUser Test *** ' + latamUser);
                sr.search();
                sr.save();
                
                sample_Requests.lineItemAdd(products[0].Id, srec.Id);
                sample_Requests.lineItemBulk(products, srec.Id);
                
                PageReference pageSR1 = new PageReference('/apex/sample_requests');
                system.debug('Price Quote Page' + pageSR1);
                Test.setCurrentPage(pageSR1);
                
                System.currentPageReference().getParameters().put('id', tu.Territory_Master__c);
                System.currentPageReference().getParameters().put('tid', srec.Account__c);
                System.currentPageReference().getParameters().put('s', '700123');
                
                ctlr = new ApexPages.StandardController(srec);
                sr = new sample_Requests(ctlr);
                searchStr = sr.searchStr;
                
                sr.tnId = tu.Territory_Master__c;
                //sr.latamUser = true;
                sr.search();
                System.debug('*** salesOrgKey *** ' + salesOrgKey);
                salesOrgKey = NULL;
                System.debug('*** salesOrgKey *** ' + salesOrgKey);
                sr.save();
                sample_Requests.lineItemAdd(products[0].Id, srec.Id);
                //sample_Requests.lineItemBulk(prod.Id, srec.Id);
                sr.updateType();
                //sr.updateAddress();
                sr.updateAddressToLead();
                sr.updateAddressToAccount();
                sr.updateAddressToTerritory();
                sr.updateAddressToContact();
                sr.updateShippingMethod();
        }//end of System.runAs(u)
    }//end of sampleRequestTest2 Method

}//end of class