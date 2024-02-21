/*********************************************************************
* Description      : Test coverage for Pricing Portal PQ Opportunity Sync.
* Coverage         : Classes(PP_Opportunity_Sync)
* Author(s)        : Eric Clay, Dun Silver
**********************************************************************/
@isTest
public class PP_Opportunity_Sync_Test {

    public Price_Books__c pbinsert(string pbid){

        insert new Price_Books__c(
            Name = 'US6020',
            Id__c = pbid,
            Price_Book_Name__c = 'Pricing Portal LA'
        );

        return NULL;

    }

    static testMethod void syncTest() {
        //string spbId = Test.getStandardPricebookId();
        //system.debug('spbId: ' + spbId);

        //insert new PricebookEntry(pricebook2id = stdPb.id, product2id = p.id,unitprice=1.0, isActive=true);

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
            Business_Unit__c = 'Surgical Disposables'
        );
        insert u;

        System.runAs(u){
            Pricebook2 pb = new pricebook2(
                Name='Pricing Portal US',
                IsActive = TRUE
            );
            insert pb;
            system.debug('pb: ' + pb);

            string pbid = pb.Id;
            pbid = pbid.left(15);

            PP_Opportunity_Sync_Test newST = new PP_Opportunity_Sync_Test();
            newST.pbinsert(pbid);

            insert new Price_Books__c(
                Name = 'US6010',
                Id__c = pbid,
                Price_Book_Name__c = 'Pricing Portal US'
            );

            Product2 prodTest = new Product2(
                Name = 'AA-10511-1',
                Description='TRANSRADIAL ACCESS TRAY',
                List_Price__c=380.00,
                Material_Key__c = 'AA-10511-1-US60-10',
                Sales_Org_Key__c = 'US6010',
                IsActive = TRUE
            );
            insert prodTest;

            Product2 prodTest1 = new Product2(
                Name = '353535',
                Description='TRANSRADIAL TRAY',
                List_Price__c=400.00,
                Material_Key__c = '353535-US30-10',
                Sales_Org_Key__c = 'US103010',
                IsActive = TRUE
            );
            insert prodTest1;

            prodTest.List_Price__c = 400.00;
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update prodTest;

            Account accTest = new Account(
                Name = 'TestAccount',
                SAP_Sold_To__c = '102059',
                Account_Group__c = 'Z002'
            );
            insert accTest;
            Account accTest2 = new Account(Name = 'TestAccount2');
            insert accTest2;
            Contact conTest = new Contact(FirstName ='Test',
            email = 'abc@123.com',LastName = 'TestContact',Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)',AccountId = accTest.Id);
            insert conTest;

            // Test Opportunity Line Item Trigger

            String pbEntryId = [SELECT Id
                                FROM PriceBookEntry
                                WHERE Product2Id =:prodTest.Id
                                AND Pricebook2Id =:pb.Id LIMIT 1].Id;

            string oppRecType;
            //SELECT Id FROM RecordType WHERE DeveloperName = 'Teleflex_Standard_Opportunity'

            Price_Quote__c PQTest = new Price_Quote__c(
                Account_Name__c = accTest.Id,
                Contact_Name__c = conTest.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US6010'
            );
            insert PQTest;

            Opportunity newOpp = new Opportunity(
                Name = 'Test Opp',
                Account = AccTest,
                CloseDate = Date.Today() + 90,
                Primary_Contact__c = ConTest.Id,
                StageName = 'Qualified Prospect',
                Amount = 1.00,
                Product_Family__c = 'Airway',
                Business_Unit__c='Surgical Disposables',
                //RecordTypeId = '01244000000NNcz',
                Business_Unit_GPL__c='Anesthesia',
                Product_Family_GPL__c='Airway',
                Product_of_Interest_GPL__c='TruLite',
                Pricebook2 = pb,
                Price_Quote__c = PQTest.Id
            );
            insert newOpp;
            system.debug('newOpp: ' + newOpp);

            OpportunityLineItem newOLI = new OpportunityLineItem(
                OpportunityId = newOpp.Id,
                PricebookEntryId = pbEntryId,
                Quantity = 1,
                UnitPrice = 1.00
            );
            insert newOLI;
            system.debug('newOLI: ' + newOLI);
            //delete newOLI;

            Opportunity newOpp1 = new Opportunity(
                Name = 'Test Opp1',
                Account = AccTest,
                CloseDate = Date.Today() + 90,
                Primary_Contact__c = ConTest.Id,
                StageName = 'Qualified Prospect',
                Amount = 1.00,
                Product_Family__c = 'Airway',
                Business_Unit__c='Surgical Disposables',
                //RecordTypeId = '01244000000NNcz',
                Business_Unit_GPL__c='Anesthesia',
                Product_Family_GPL__c='Airway',
                Product_of_Interest_GPL__c='TruLite',
                Pricebook2 = pb,
                Price_Quote__c = PQTest.Id
            );
            insert newOpp1;

            OpportunityLineItem newOLI1 = new OpportunityLineItem(
                OpportunityId = newOpp1.Id,
                PricebookEntryId = pbEntryId,
                Quantity = 1,
                UnitPrice = 1.00
            );
            insert newOLI1;

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

            //PricebookEntry pbe = new PricebookEntry(pricebook2id=pb.id, product2id=p.id,unitprice=1.0, isActive=true);
            //insert pbe;
            Test.startTest();
            List<Price_Quote_Line_Item__c> li = new List<Price_Quote_Line_Item__c>();
            List<OpportunityLineItem> oppItems = new List<OpportunityLineItem>();
            List<OpportunityLineItem> oppItems1 = new List<OpportunityLineItem>();
            List<Opportunity> oppList = new List<Opportunity>();
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
            oppList.add(newOpp);
            oppMap.put(newOpp.Id,newOpp);
            List<Id> liId = new List<Id>();
            Set<Id> oppli = new Set<Id>();
            Set<Id> oppli1 = new Set<Id>();
            //li.add(PQLineItem);
            oppItems.add(newOLI);
            oppItems1.add(newOLI1);
            oppli.add(newOLI.Id);
            oppli1.add(newOLI1.Id);
            PP_Opportunity_Sync opp = new PP_Opportunity_Sync();
            //PP_Opportunity_Sync.addOLI(li);
            //PP_Opportunity_Sync.updatePQ(oppList,oppMap,'update');
            PQTest.Opportunity__c = newOpp.Id;
            UPDATE PQTest;
            //PP_Opportunity_Sync.addOLI(li);
            //PP_Opportunity_Sync.delOpportunityLines(oppli);
            //PP_Opportunity_Sync.delOpportunityLines_trigger(li);

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
                //Competetive_Product__c = CRTest.Id,
                Product_Description__c='Test Description'
            );
            insert PQLineItem;

            Price_Quote_Line_Item__c PQLineItem1 = new Price_Quote_Line_Item__c(
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
                //Competetive_Product__c = CRTest.Id,
                Product_Description__c='Test Description'
            );
            insert PQLineItem1;

            li.add(PQLineItem);
            li.add(PQLineItem1);
            liId.add(PQLineItem.Id);
            liId.add(PQLineItem1.Id);
            PP_Opportunity_Sync.addOLI(li);
            PP_Opportunity_Sync.remove_PQOLI_ID(oppItems);
            PP_Opportunity_Sync.delOpportunityLines(oppli);
            PP_Opportunity_Sync.delOpportunityLines_trigger(li);
            Test.stopTest();
        }




    }

}