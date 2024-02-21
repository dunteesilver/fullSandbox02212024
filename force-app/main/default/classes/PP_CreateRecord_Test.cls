/*********************************************************************
* Description      : Test coverage for Pricing Portal Auto Create Opportunity Class.
* Coverage         : Classes(PP_CreateRecord)
* Author(s)        : Dun Silver
**********************************************************************/
@isTest
public class PP_CreateRecord_Test {
    
    static testmethod void CreateRecord_Test(){
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
        
        Group d10 = new Group(
            Name = 'Division 10'
        );
        insert d10;
        
        Group d20 = new Group(
            Name = 'Division 20'
        );
        insert d20;
        
        Group d30 = new Group(
            Name = 'Division 30'
        );
        insert d30;
        
        Group d40 = new Group(
            Name = 'Division 40'
        );
        insert d40;
        
        Group d50 = new Group(
            Name = 'Division 50'
        );
        insert d50;
        
        Group d60 = new Group(
            Name = 'Division 60'
        );
        insert d60;
        
        Group pp = new Group(
            Name = 'Pricing Portal'
        );
        insert pp;
        
        
        System.runAs(u){
            
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
                Active_Sales_Org_Key__c = 'US6020',
                Active_Currency__c = 'USD'
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
                Active_Sales_Org_Key__c = 'US103020',
                Active_Currency__c = 'USD'
            );
            Test.startTest();
            insert cu;
            insert cu2;
            Test.stopTest();
            
            Account accTest = new Account(
                Name = 'TestAccount',
                SAP_Sold_To__c = '102059',
                Account_Group__c = 'Z002'
            );
            insert accTest;
            
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
                Sales_Org__c = 'US60',
                Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US6010',
                RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            insert prodTest;
            
            Product2 prodTest2 = new Product2(
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
                Sales_Org__c = 'US10',
                Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US103010',
                RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            insert prodTest2;
            
            Price_Quote__c PQTest = new Price_Quote__c(
                Account_Name__c = accTest.Id,
                Contact_Name__c = conTest.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US6010',
                No_Opp__c = true,
                OwnerId = u.Id
            );
            insert PQTest;
            
            Price_Quote__c PQTest2 = new Price_Quote__c(
                Account_Name__c = accTest.Id,
                Contact_Name__c = conTest.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US103010',
                No_Opp__c = true,
                OwnerId = u.Id
            );
            insert PQTest2;
            
            Price_Quote__c PQTest1 = new Price_Quote__c(
                Account_Name__c = accTest.Id,
                Contact_Name__c = conTest.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US103010',
                No_Opp__c = false,
                OwnerId = u.Id
            );
            insert PQTest1;
            system.debug('PQTest1: ' + PQTest1);
            
            Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
                Price_Quote__c = PQTest.Id,
                Material_Name__c = prodTest.Id,
                Sales_Price__c = 125.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 330.00,
                List_Price__c = 380.00,
                Quantity__c = 1,
                Extended_Price__c = 230.00
            );
            insert PQLineItem;
            system.debug('PQLineItem: ' + PQLineItem);
            
            Price_Quote_Line_Item__c PQLineItem1 = new Price_Quote_Line_Item__c(
                Price_Quote__c = PQTest1.Id,
                Material_Name__c = prodTest.Id,
                Sales_Price__c = 125.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 330.00,
                List_Price__c = 380.00,
                Quantity__c = 1,
                Extended_Price__c = 230.00
            );
            insert PQLineItem1;
            system.debug('PQLineItem1: ' + PQLineItem1);
            
            Opportunity newOpp = new Opportunity(
                Name = 'Test Opp',
                Account = AccTest,
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
                Price_Quote__c = PQTest.Id
            );
            //newOpps.add(newOpp);
            insert newOpp;
            
            PQTest.Status__c = 'Approved';
            PQTest.Opportunity__c = newOpp.Id;
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update PQTest;
            
            PQTest1.Status__c = 'Approved';
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update PQTest1;
            
            PRF__c prfTest = new PRF__c(
                Account__c = accTest.Id,
                Contact__c = conTest.Id,
                Status__c = 'New',
                Requisition_Date__c = Date.valueOf('2015-03-11'),
                Sales_Org_Key__c = 'US6010',
                //Price_Quote__c = PQTest.Id
                Price_Quote__c= PQTest1.Id
            );
            insert prfTest;
            
            PRF__c prfTest3 = new PRF__c(
                Account__c = accTest.Id,
                Contact__c = conTest.Id,
                Status__c = 'New',
                Requisition_Date__c = Date.valueOf('2015-03-11'),
                Sales_Org_Key__c = 'US103010',
                Price_Quote__c = PQTest2.Id
            );
            insert prfTest3;
            
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
            system.debug('prfLineItem: ' + prfLineItem);
            
            prfTest.Status__c = 'Approved';
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update prfTest;
            
            PRF__c prfTest2 = new PRF__c(
                Account__c = accTest.Id,
                Contact__c = conTest.Id,
                Status__c = 'New',
                Requisition_Date__c = Date.valueOf('2015-03-11'),
                Sales_Org_Key__c = 'US103010',
                Price_Quote__c = PQTest.Id
            );
            insert prfTest2;
            
            master_TriggerHelperClass.runOnce('resetOnceSet');
            system.debug('prfTest2: ' + prfTest2);
            
            PRF_Line_Item__c prfLineItem2 = new PRF_Line_Item__c(
                PRF__c = prfTest2.Id,
                PQLI_ID__c = PQLineItem.Id,
                Material_Name__c = prodTest.Id,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 330.00,
                List_Price__c = 380.00,
                Requested_Price__c = 230.00
            );
            insert prfLineItem2;
            
            
            master_TriggerHelperClass.runOnce('resetOnceSet');
            system.debug('prfLineItem2: ' + prfLineItem2);
            
            PQTest.Status__c = 'Rejected';
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update PQTest;
            
            PQTest.Status__c = 'Approved';
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update PQTest;
            
            prfTest2.Status__c = 'Rejected';
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update prfTest2;
            
            prfTest2.Status__c = 'Approved';
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update prfTest2;
            
            List<Price_Quote__c> listQuotesNoOpp = new List<Price_Quote__c>();
            listQuotesNoOpp.add(PQTest);
            
            List<Price_Quote__c> listQuotesOpp = new List<Price_Quote__c>();
            listQuotesOpp.add(PQTest1);
            //master_TriggerHelperClass.runOnce('resetOnceSet');
            PP_CreateRecord obj = new PP_CreateRecord();
            obj.createOppy(listQuotesNoOpp);
            obj.createOppy(listQuotesOpp);
            
            List<String> prfIds= new List<String>();
            prfIds.add(prfTest.Id);
            obj.updatePQ(prfIds);
        }
    }
}