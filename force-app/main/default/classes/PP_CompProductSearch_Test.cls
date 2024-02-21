/*********************************************************************
* Description      : Test coverage for Competitor Product Search in Pricing Portal.
* Coverage         : Classes(PP_CompProductSearch)
* Author(s)        : Dun Silver
**********************************************************************/
@isTest
public class PP_CompProductSearch_Test {
    
    static testmethod void PP_CompProductSearch_UnitTest(){
        
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
        
        Test.startTest();
            System.runAs(u){
                Account accTest = new Account(
                    Name = 'TestAccount',
                    Account_Group__c = '17',
                    ERP_Active__c = true,
                    SAP_Sold_To__c = '110068');
                insert accTest;
                
                Contact conTest = new Contact(
                    FirstName ='Test',
                    email = 'abc@123.com',  
                    LastName = 'TestContact',
                    Position_Job_Title__c='Administrator',
                    Credentials__c='RN',
                    Preferred_language__c='English (American)',
                    AccountId = accTest.Id);
                insert conTest;
                
                Price_Quote__c PQTest = new Price_Quote__c(
                    Account_Name__c = accTest.Id,
                    Contact_Name__c = conTest.Id,
                    Status__c = 'In Progress',
                    Expiration_Date__c = Date.Today() + 90);
                insert PQTest;
                
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
                insert cu;
                
                Contract_User__c cu2 = new Contract_User__c(
                    Name = 'TestAdam Franks',
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
                insert cu2;
                
                Product2 prodTest = new Product2(
                    Name = 'AA-10511-1',ProductCode= 'AA-10511-1',UOM__c='CS',
                    Each_per_Case__c=5,Material_Status__c='MTS',
                    Material_Status_Numeric__c='30',Family = 'Hardware',
                    Material__c='AA-10511-1',Brand_Name__c='Arrow',
                    Buom__c='EA',Class__c='Cardiac Care Specialty',
                    Cost__c=11587.40,Cost_Price_Unit__c=1000,Division__c='60',
                    Description='TRANSRADIAL ACCESS TRAY',Group__c='Interventional',
                    SubGroup__c = 'TransRadial Access',Qty_Sales_Unit__c=5,
                    Sales_Unit__c='CS',List_Price__c=380.00,
                    Rep_Price__c=350.00,RSM_Price__c=330.00,
                    Distribution_Channel__c='10',Sales_Org_Key__c='US6010');
                insert prodTest;
                
                Product2 prodTest2 = new Product2(
                    Name = 'AA-10511-1',ProductCode= 'AA-10511-1',UOM__c='CS',
                    Each_per_Case__c=5,Material_Status__c='MTS',
                    Material_Status_Numeric__c='30',Family = 'Hardware',
                    Material__c='AA-10511-1',Brand_Name__c='Arrow',
                    Buom__c='EA',Class__c='Cardiac Care Specialty',
                    Cost__c=11587.40,Cost_Price_Unit__c=1000,Division__c='60',
                    Description='TRANSRADIAL ACCESS TRAY',Group__c='Interventional',
                    SubGroup__c = 'TransRadial Access',Qty_Sales_Unit__c=5,
                    Sales_Unit__c='CS',List_Price__c=380.00,
                    Rep_Price__c=350.00,RSM_Price__c=330.00,
                    Distribution_Channel__c='10',Sales_Org_Key__c='US103010');
                insert prodTest2;
                
                Cross_Reference__c CRTest = new Cross_Reference__c(
                    Competitor_Product_Code__c = '320250',
                    Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                    Competitor_Name__c ='Jarit/Integra',
                    Percent_Match__c=100,
                    Product__c = prodTest.Id);
                insert CRTest;
                
                Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
                    Price_Quote__c = PQTest.Id,
                    Material_Name__c = prodTest.Id,
                    Sales_Price__c = 230.00,
                    Quantity__c=1,
                    Extended_Price__c = 230.00,
                    Competetive_Product__c = CRTest.Id);
                insert PQLineItem;
                
                PRF__c prfTest = new PRF__c(
                    Account__c = accTest.Id,
                    Contact__c = conTest.Id,
                    Status__c = 'New',
                    Requisition_Date__c = Date.valueOf('2015-03-11'),
                    Sales_Org_Key__c = 'US6010',
                    Price_Quote__c = PQTest.Id,
                    GPO_Affiliation__c = ''
                );
                insert prfTest;
                
                PRF__c prfTest2 = new PRF__c(
                    Account__c = accTest.Id,
                    Contact__c = conTest.Id,
                    Status__c = 'New',
                    Requisition_Date__c = Date.valueOf('2015-03-11'),
                    Sales_Org_Key__c = 'US103010',
                    Price_Quote__c = PQTest.Id,
                    GPO_Affiliation__c = ''
                );
                insert prfTest2;
                
                PRF_Line_Item__c prfliTest = new PRF_Line_Item__c(
                    PRF__c = prfTest.Id,
                    Material_Name__c = prodTest.Id,
                    Eligible_Price__c = 230.00,
                    Rep_Price__c = 350.00,
                    RSM_Price__c = 330.00,
                    List_Price__c = 380.00,
                    Requested_Price__c = 230.00
                );
                insert prfliTest;
                
                //Start of testing for pqId
                PageReference pageRef = new PageReference('/apex/PP_CompProductSearch?compsrch=320250&gs=off&pqid=' + PQTest.Id);
                system.debug('User Edit Page' + pageRef);
                Test.setCurrentPage(pageRef);
                
                
                PP_CompProductSearch cpsController = new PP_CompProductSearch();
                cpsController.activeQuoteIdStr = PQTest.Id;
                System.assertNotEquals(PQTest.Id,cpsController.activeQuoteIdStr);
                cpsController.tempQuote = PQTest;
                //System.assertNotEquals(NULL,cpsController.tempQuote);
                cpsController.getURL();
                cpsController.getActiveQuoteIdStr();
                cpsController.getActiveQuoteName();
                cpsController.getCompProduct();
                cpsController.sapPrice();
                cpsController.refreshPageSize();
                DELETE PQTest;
                System.assertEquals(NULL,cpsController.tempQuote);
                //End of testing for pqId
                
                //Start of testing for prfId
                pageRef = new PageReference('/apex/PP_CompProductSearch?compsrch=320250&gs=off&prfid=' + prfTest.Id);
                system.debug('User Edit Page' + pageRef);
                Test.setCurrentPage(pageRef);
                
                cpsController = new PP_CompProductSearch();
                cpsController.getURL();
                cpsController.getActiveQuoteIdStr();
                cpsController.getActiveQuoteName();
                cpsController.getCompProduct();
                cpsController.refreshPageSize();
            }
        Test.stopTest();
            
        //End of testing for prfId
    }//end getURL test method
    
}//end of test class