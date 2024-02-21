/*********************************************************************
* Description      : Test Class for Pricing Portal Material Details.
* Coverage         : Class(PP_Material_info)
* Author(s)        : Dun Silver
**********************************************************************/
@isTest          
public class PP_Material_info_Test {
    
    static testmethod void PP_Material_info_UnitTest(){
        //String body = '{"id":24849,"product_code":"353535","name":"DEBAKEY PERIPHERAL VASCULAR CLAMP",'+ '"product-description":"ANGLED, 3 3/4\\" (9.4cm) tip length, 2.8mm tip width, Curved shaft, 7 1/8\\" (18cm)",'+ '"images":[{"format":"details","urls":["https://www.teleflexarcatalog.com/images/products/pilling/details/SR_353535.jpg",'+ '"https://www.teleflexarcatalog.com/images/products/pilling/details/SR_353535_CU.jpg"]},'+ '{"format":"hi-res","urls":["https://www.teleflexarcatalog.com/images/products/pilling/hi-res/SR_353535.jpg",'+ '"https://www.teleflexarcatalog.com/images/products/pilling/hi-res/SR_353535_CU.jpg"]},'+ '{"format":"listing","urls":["https://www.teleflexarcatalog.com/images/products/pilling/listing/SR_353535.jpg",'+ '"https://www.teleflexarcatalog.com/images/products/pilling/listing/SR_353535_CU.jpg"]},'+ '{"format":"thumb","urls":["https://www.teleflexarcatalog.com/images/products/pilling/thumb/SR_353535.jpg",'+ '"https://www.teleflexarcatalog.com/images/products/pilling/thumb/SR_353535_CU.jpg"]}],'+ '"url":"https://www.teleflexarcatalog.com/anesthesia-respiratory/pain/products/24849"}';
        //SingleRequestMock fakeResponse = new SingleRequestMock(200,'OK',body,null);
        //Test.setMock(httpCalloutMock.class, fakeResponse);
        
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
            Business_Unit__c = 'Vascular'
        );
        insert u;
        
        System.runAs(u){
            Test.startTest();
            IDN_PickList__c IDNPickList = new IDN_PickList__c(Name= 'HPA HEALTH PURCH ALLIANCE ORLANDO',Active__c = true,Key__c = 'IDN-014');
            insert IDNPickList;
            Contract_User__c cu = testDataFactoryPP.createPricingPortalUser(u.Name, u.Id,'US - Teleflex', 'US6010', 3);
           
            
            insert cu;
            system.debug('CU:' + cu);

            cu = new Contract_User__c(
                id = cu.Id,
                CA_Material__c = TRUE,
                CA_Division_10__c = TRUE,
                CA_Division_20__c = TRUE,
                CA_Division_30__c = TRUE,
                CA_Division_40__c = TRUE,
                CA_Division_50__c = TRUE,
                CA_Division_60__c = TRUE
            );
            update cu;

            Account accTest = new Account(Name = 'TestAccount', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId());
            //System.debug('*** accTest.RecordtypeId *** ' + accTest.RecordtypeId);
            //System.debug('*** accTest.RecordtypeId *** ' + accTest.Recordtype.Name);
            insert accTest;
            
            Contact conTest = new Contact(FirstName ='Test',
                                          email = 'abc@123.com',
                                          LastName = 'TestContact',
                                          Position_Job_Title__c='Administrator',
                                          Credentials__c='RN',
                                          Preferred_language__c='English (American)',
                                          AccountId = accTest.Id);
            insert conTest;
            /*
            Price_Quote__c PQTest = new Price_Quote__c(
                Account_Name__c = accTest.Id,
                Contact_Name__c = conTest.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90
            );
            insert PQTest;
            */
            Price_Quote__c PQTest = testDataFactoryPP.createPriceQuote(accTest.Id, conTest.Id, 'US6010', false, 'Vascular');
            insert PQTest;

            Product2 prodTest = testDataFactoryPP.createProduct('AA-10511-1', 'US60', '10', '40');
            /*
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
                DChain_Material_Status__c = '40',
                Sales_Org_Key__c = 'US6010',
                ASK_Custom_Kit__c = FALSE
            );
            */
            insert prodTest;
            
            Product2 prodTest1 = testDataFactoryPP.createProduct('AA-10511-1', 'CA10', '10', '40');
            insert prodTest1;

            //Contract Header Test Records
            Contract_Header__c conHead = new Contract_Header__c(
                Name = 'TestId',
                Description__c = 'AA-10511-1',
                Agreement_Number__c = 'TestId',
                GPO_Contract_Ref__c = 'TestRef',
                Valid_From__c = System.Today().addMonths(-1),
                Valid_To__c = System.Today().addMonths(1),
                Owner_Name__c = 'Novation',
                Owner__c = 'GPO-008'
            );
            insert conHead;
            
            //Contract Material Test Record
            Contract_Material__c cmObj = new Contract_Material__c(
                Name = 'AA-10511-1',
                Product__c = prodTest.id,
                Agreement__c = conHead.id,
                Sales_Org__c = 'US60',
                Valid_To__c = Date.today()
            );
            insert cmObj;
            
            //Novation
            //GPO_Picklist__c
            GPO_Picklist__c gpo = new GPO_Picklist__c(
                name = 'Novation',
                Active__c = TRUE,
                Key__c = 'GPO-008'
            );
            insert gpo;
            
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
            
            /*
            Product2 prodRec = [SELECT Id, Name FROM Product2 WHERE Name =:prodTest.Name AND Sales_Org_Key__c = 'US6010' LIMIT 1];
            if(prodRec == NULL){
                prodTest = testDataFactoryPP.createProduct('AA-10511-1', 'US60', '10', '40');
                insert prodTest;
            }
            */
            
            PageReference mi = Page.PP_Material_Info;
            Test.setCurrentPage(mi);
            System.currentPageReference().getParameters().put('pid',prodTest.Name);
            System.currentPageReference().getParameters().put('id',prodTest.Id);
            System.currentPageReference().getParameters().put('materialStr', prodTest.Name);
            System.currentPageReference().getParameters().put('gporef', 'Test');
            System.currentPageReference().getParameters().put('oid', 'Test');
            System.currentPageReference().getParameters().put('materialStr', prodTest.Name);
            System.currentPageReference().getParameters().put('gpoContractHeaderInfo', 'Testi');
            System.currentPageReference().getParameters().put('pqid', PQTest.Id);
            System.currentPageReference().getParameters().put('rs', 'xls');
            System.currentPageReference().getParameters().put('strMats', prodTest.Name);
            System.currentPageReference().getParameters().put('materialId', prodTest.Id);
            
            PP_Material_info miController = new PP_Material_info();
            miController.strMats = prodTest.Name;
            miController.pqId = PQTest.Name;
            miController.addQuoteLine();
            //miController.updateImageUrl();
            miController.getCM();
            miController.getURL();
            
            prodTest.DChain_Material_Status__c = '';
            prodTest.Material_Status_Numeric__c = 'Z1';
            update prodTest;
            
            //cu.Active_Sales_Org_Key__c = 'CA1010';
            //update cu;
            
            PageReference mi2 = Page.PP_Material_Info;
            Test.setCurrentPage(mi2);
            //mi2.getParameters().put('id',prodTest.Id);
            //mi2.getParameters().put('pqid',PQTest.Id);
            //mi2.getParameters().put('materialId',prodTest.Id);
            System.currentPageReference().getParameters().put('id', prodTest.Id); 
            System.currentPageReference().getParameters().put('pqid', PQTest.Id); 
            System.currentPageReference().getParameters().put('materialId', prodTest1.Id); 
            
            PP_Material_info mi2Controller1 = new PP_Material_info();
            //mi2Controller1.myActiveSalesOrg = 'US6020';
            mi2Controller1.getCM();
            String pqId = mi2Controller1.pqId;
            //mi2Controller1.updateImageUrl();
         
            PageReference mi5 = Page.PP_Material_Info;
            Test.setCurrentPage(mi5);
            System.currentPageReference().getParameters().put('id', prodTest.Id); 
            System.currentPageReference().getParameters().put('pqid', NULL); 
            System.currentPageReference().getParameters().put('materialId', prodTest.Id); 
            PP_Material_info mi2Controller4 = new PP_Material_info();
            String userLang = mi2Controller4.userLang;
            mi2Controller4.addQuoteLine();

            
            Test.stopTest();
            
        }        
    }
    
     
}