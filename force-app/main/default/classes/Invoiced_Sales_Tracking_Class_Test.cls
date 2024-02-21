/*********************************************************************
* Description     : Main test class for Invoiced_Sales_Tracking_Class
* Covered Classes : Invoiced_Sales_Tracking_Class, Sample_Request_Line_Item_Class
* Author(s)       : Dunte'e Silver
**********************************************************************/
@isTest
public class Invoiced_Sales_Tracking_Class_Test {

    @testSetup static void dataSetup(){
        Test.startTest();
        //Create user data
        //Create Test manager user for approval process testing
        //public static User createUser(String firstName, String lastName, String approvalRole, String bu)
        User usUser1 = testDataFactoryPP.createUser('USman1', 'User1', 'Sales Manager', 'Commercial Operations');
        insert usUser1;
        
        //Create US user
		User usUser2 = testDataFactoryPP.createUserMan('USman2', 'User2', 'Sales Rep', 'Commercial Operations', usUser1.Id);
        insert usUser2;
        
        //Create Invoiced_Sales_Tracking_Class_CS__c custom setting
        //Invoiced_Sales_Tracking_Class_CS__c csTest1 = testDataFactoryPP.createCsClass('addShipping', true);
        //insert csTest1;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        /*
        Quote_Logos__c quotelogo = new Quote_Logos__c(
            Name = 'Surgical Instruments',
            Quote_Page__c = 'PP_Print_Quote',
            URL__c = 'test',
            Footer__c = 'test'
        );
        insert quotelogo;
		*/
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
       Test.stopTest();
    }//end @testSetup static void dataSetup
    
    @isTest static void istTest1(){
        User usUser1 = [SELECT Id, Name, Business_Unit__c FROM User WHERE Name = 'USman1 User1' LIMIT 1];
		Test.startTest();
		//Create Invoiced_Sales_Tracking_Class_CS__c custom setting
        Invoiced_Sales_Tracking_Class_CS__c csTest1 = testDataFactoryPP.createCsClass('addShipping', true);
        insert csTest1;
        
        //Create Sample_Request_Line_Item_Class_CS__c custom setting
        Sample_Request_Line_Item_Class_CS__c csTest2 = testDataFactoryPP.createCsClass1('manuallyLockSampleRequestLineItems', true);
        insert csTest2;
        
        //Create Invoiced_Sales_Tracking_Class_CS__c custom setting
        //Invoiced_Sales_Tracking_Class_CS__c csTest2 = [SELECT Name FROM Invoiced_Sales_Tracking_Class_CS__c WHERE Name = 'addShipping' LIMIT 1];
        
        System.runAs(usUser1){
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser1.Name, usUser1.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            //Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','999999','03');
            //insert usACC;            
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
            Product2 usProd3 = testDataFactoryPP.createProduct2('usProd3', 'US60', '10', '40');
            insert usProd3;
            Product2 usProd4 = testDataFactoryPP.createProduct2('usProd4', 'US60', '10', '40');
            insert usProd4;
            Product2 usProd5 = testDataFactoryPP.createProduct2('usProd5', 'US60', '10', '40');
            insert usProd5;
            Product2 usProd6 = testDataFactoryPP.createProduct2('usProd6', 'US60', '10', '40');
            insert usProd6;
            Product2 usProd7 = testDataFactoryPP.createProduct2('usProd7', 'US60', '10', '40');
            insert usProd7;
            Product2 usProd8 = testDataFactoryPP.createProduct2('usProd8', 'US60', '10', '40');
            insert usProd8;
            Product2 usProd9 = testDataFactoryPP.createProduct2('usProd9', 'US60', '10', '40');
            insert usProd9;
            
            Product2 usProd10 = testDataFactoryPP.createProduct2('usProd10', 'US60', '10', '40');
            insert usProd10;
            
            //public static Territory_Master__c createTerritoryMaster(String territoryNumber, String bu )
            Territory_Master__c tm = testDataFactoryPP.createTerritoryMaster('999999', 'Vascular');
            insert tm;
            
            //public static Territory_User__c createTerritoryUser(String tmId, String tmNumber, String userId )
            Territory_User__c tu = testDataFactoryPP.createTerritoryUser(tm.Id, tm.Territory_Number__c, usUser1.id);
            insert tu;
            
            //public static Sample_Request__c createSampleRequest(String accId,String conId,String salesOrgKey, String territoryId, String sampleType)
            Sample_Request__c sr = testDataFactoryPP.createSampleRequest(usAcc.Id, con1.Id ,'US6010', tm.Id, 'Field Sales Stock', 'New');
            insert sr;
            
            Sample_Request__c sr1 = [SELECT Id, Name, Status__c, Medical_License__c 
                                     FROM Sample_Request__c WHERE Medical_License__c  = 'Unit Testing' AND CreatedDate = Today ORDER BY CreatedDate DESC LIMIT 1];
            system.debug('*** sr testing *** ' + sr);
            system.debug('*** sr testing *** ' + sr.Id);
            system.debug('*** sr1 testing *** ' + sr1.id);
            system.debug('*** sr1 testing *** ' + sr1.Status__c);
            
            //public static Sample_Request_Line_Item__c createSampleRequestLineItem(String sampleId,String prodId)
            Sample_Request_Line_Item__c srli = testDataFactoryPP.createSampleRequestLineItem(sr1.Id,usProd.Id);
            insert srli;
            
            Sample_Request_Line_Item__c srli1 = testDataFactoryPP.createSampleRequestLineItem(sr1.Id,usProd1.Id);
            insert srli1;
            
            Sample_Request_Line_Item__c srli2 = testDataFactoryPP.createSampleRequestLineItem(sr1.Id,usProd2.Id);
            insert srli2;
            
            Sample_Request_Line_Item__c srli3 = testDataFactoryPP.createSampleRequestLineItem(sr1.Id,usProd3.Id);
            insert srli3;
            
            Sample_Request_Line_Item__c srli4 = testDataFactoryPP.createSampleRequestLineItem(sr1.Id,usProd4.Id);
            insert srli4;
            
            Sample_Request_Line_Item__c srli5 = testDataFactoryPP.createSampleRequestLineItem(sr1.Id,usProd5.Id);
            insert srli5;
            
            Sample_Request_Line_Item__c srli6 = testDataFactoryPP.createSampleRequestLineItem(sr1.Id,usProd6.Id);
            insert srli6;
            
            Sample_Request_Line_Item__c srli7 = testDataFactoryPP.createSampleRequestLineItem(sr1.Id,usProd7.Id);
            insert srli7;
            
            Sample_Request_Line_Item__c srli8 = testDataFactoryPP.createSampleRequestLineItem(sr1.Id,usProd8.Id);
            insert srli8;
            
            Sample_Request_Line_Item__c srli9 = testDataFactoryPP.createSampleRequestLineItem(sr1.Id,usProd9.Id);
            insert srli9;
            
            Sample_Request_Line_Item__c srli10 = testDataFactoryPP.createSampleRequestLineItem(sr1.Id,usProd10.Id);
            insert srli10;
            
            //update Sample Request to "Ready" status to complete test coverage
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
            app.setObjectId(sr1.Id);
            Approval.ProcessResult result = Approval.process(app);
            System.debug('*** sr1 *** ' + sr1.Status__c);
            //sr1 = new Sample_Request__c(Id = sr1.Id, Status__c = 'Ready');
            //update sr1;
            
            //public static Invoiced_Sales_Tracking__c createInvoicedSalesTracking(String materialName,String sampleNumber, String deliveryPriority, String trackingNumber) {
            //Test.startTest();
            system.debug('*** usProd.Name testing *** ' + usProd.Name);
            system.debug('*** sr1.Name testing *** ' + sr1.Name);
            system.debug('*** srli.Sample_Request__r.Name testing *** ' + srli.Sample_Request__r.Name);
            
            List<Invoiced_Sales_Tracking__c> istList = new List<Invoiced_Sales_Tracking__c>();
            
            Invoiced_Sales_Tracking__c ist = testDataFactoryPP.createInvoicedSalesTracking(usProd.Name, sr1.Name, 'UPS Ground','1Z6069230376727116');
            insert ist;
            istList.add(ist);
            
            Invoiced_Sales_Tracking__c ist1 = testDataFactoryPP.createInvoicedSalesTracking(usProd1.Name, sr1.Name, 'Fed','1Z6069230376727116');
            insert ist1;
            istList.add(ist1);
            
            Invoiced_Sales_Tracking__c ist2 = testDataFactoryPP.createInvoicedSalesTracking(usProd2.Name, sr1.Name, 'Pur','1Z6069230376727116');
            insert ist2;
            istList.add(ist2);
            
            Invoiced_Sales_Tracking__c ist3 = testDataFactoryPP.createInvoicedSalesTracking(usProd3.Name, sr1.Name, 'YRC','1Z6069230376727116');
            insert ist3;
            istList.add(ist3);
            
            Invoiced_Sales_Tracking__c ist4 = testDataFactoryPP.createInvoicedSalesTracking(usProd4.Name, sr1.Name, 'AAA','1Z6069230376727116');
            insert ist4;
            istList.add(ist4);
            
            Invoiced_Sales_Tracking__c ist5 = testDataFactoryPP.createInvoicedSalesTracking(usProd5.Name, sr1.Name, 'Air','1Z6069230376727116');
            insert ist5;
            istList.add(ist5);
            
            Invoiced_Sales_Tracking__c ist6 = testDataFactoryPP.createInvoicedSalesTracking(usProd6.Name, sr1.Name, 'Roa','1Z6069230376727116');
            insert ist6;
            istList.add(ist6);
            
            Invoiced_Sales_Tracking__c ist7 = testDataFactoryPP.createInvoicedSalesTracking(usProd7.Name, sr1.Name, 'Sea','1Z6069230376727116');
            insert ist7;
            istList.add(ist7);
            
            Invoiced_Sales_Tracking__c ist8 = testDataFactoryPP.createInvoicedSalesTracking(usProd8.Name, sr1.Name, 'Old','1Z6069230376727116');
            insert ist8;
            istList.add(ist8);
            
            Invoiced_Sales_Tracking__c ist9 = testDataFactoryPP.createInvoicedSalesTracking(usProd9.Name, sr1.Name, 'Hol','1Z6069230376727116');
            insert ist9;
            istList.add(ist9);
            
            Invoiced_Sales_Tracking__c ist10 = testDataFactoryPP.createInvoicedSalesTracking(usProd10.Name, sr1.Name, 'UPS','');
            insert ist10;
            istList.add(ist10);
            Invoiced_Sales_Tracking_Class.addShipping(istList);
            //Test.stopTest();
            //end of Sample Request data setup
            
        }//end System.runAs(usUser1)
        Test.stopTest();
    }//end istTest1
}