/*********************************************************************
* Description      : Test coverage for Pricing Portal PP_Price_QuoteRB.
* Coverage         : Classes(PP_Price_QuoteRB)
* Author(s)        : Dun Silver
**********************************************************************/
@isTest
public class PP_Price_QuoteRB_Test {
    
    @isTest static void test_method_validQuoteRB() {
        // Implement test code
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'uflex76',email='unit.test@unit.teleflex.com',
            emailencodingkey='UTF-8',firstname='Adam',
            lastname='Franks',languagelocalekey='en_US',
            localesidkey='en_GB',profileid = p.Id,
            timezonesidkey='Europe/London',
            username='unit.test@unit.teleflex.com'
        );
        INSERT u;
        
        Group d10 = new Group(
            Name = 'Division 10'
        );
        INSERT d10;
        
        Group d20 = new Group(
            Name = 'Division 20'
        );
        INSERT d20;
        
        Group d30 = new Group(
            Name = 'Division 30'
        );
        INSERT d30;
        
        Group d40 = new Group(
            Name = 'Division 40'
        );
        INSERT d40;
        
        Group d50 = new Group(
            Name = 'Division 50'
        );
        INSERT d50;
        
        Group d60 = new Group(
            Name = 'Division 60'
        );
        INSERT d60;
        
        Group pp = new Group(
            Name = 'Pricing Portal'
        );
        INSERT pp;
        
        //Create custom settings for all sales orgs
        List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
        insert newSalesOrgs;
        
        System.runAs(u){
            
            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Division_10__c = TRUE,Division_20__c = TRUE,
                Division_30__c = TRUE,Division_40__c = TRUE,
                Division_50__c = TRUE,Division_60__c = TRUE,
                Active_Sales_Org_Key__c = 'US6010',
                Active_Currency__c = 'USD'
            );
            //Test.startTest();
            INSERT cu;
            //Test.stopTest();
            system.debug('CU:' + cu);
            
            Account accTest = new Account(Name = 'TestAccount',SAP_Sold_To__c='SAPcode101',Account_Group__c='Z002');
            INSERT accTest;
            System.debug('*** accTest.Id *** ' + accTest.Id);
            
            Contact conTest = new Contact(FirstName ='Test',
            email = 'abc@123.com',LastName = 'TestContact',Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)',AccountId = accTest.Id);
            INSERT conTest;
            
            Price_Quote__c PQTest = new Price_Quote__c(Account_Name__c = accTest.Id,
                                                       Contact_Name__c = conTest.Id,
                                                       Status__c = 'In Progress',
                                                       Expiration_Date__c = Date.today() + 90,
                                                       Sales_Org_Key__c = 'US6010',
                                                       One_Time_Purchase__c = TRUE);
            INSERT PQTest;
            System.debug('*** PQTest.Account_Name__c *** ' + PQTest.Account_Name__c);
            System.debug('*** PQTest.Account_Name__r.SAP_Sold_To__c *** ' + PQTest.Account_Name__r.SAP_Sold_To__c);
            
            Price_Quote__c PQTest1 = new Price_Quote__c(Account_Name__c = accTest.Id,
                                                        Contact_Name__c = conTest.Id,
                                                        Status__c = 'In Progress',
                                                        Expiration_Date__c = Date.today() + 90,
                                                        Sales_Org_Key__c = 'US6010',
                                                        One_Time_Purchase__c = TRUE);
            INSERT PQTest1;
            
            Price_Quote__c PQTest2 = new Price_Quote__c(Account_Name__c = accTest.Id,
                                                        Contact_Name__c = conTest.Id,
                                                        Status__c = 'In Progress',
                                                        Expiration_Date__c = Date.today() + 90,
                                                        Sales_Org_Key__c = 'US6010',
                                                        One_Time_Purchase__c = TRUE);
            INSERT PQTest2;
            
            //List<String> prodList = new List<String>();
            Product2 prodTest = new Product2(Name = 'AA-10511-1',
                                             ProductCode= 'AA-10511-1',
                                             UOM__c='CS',Each_per_Case__c=5,
                                             Material_Status__c='MTS',Material_Status_Numeric__c='30',
                                             Family = 'Hardware',Material__c='AA-10511-1',
                                             Brand_Name__c='Arrow',Buom__c='EA',
                                             Class__c='Cardiac Care Specialty',Cost__c=11587.40,
                                             Cost_Price_Unit__c=1000,Division__c='60',
                                             Description='TRANSRADIAL ACCESS TRAY',
                                             Group__c='Interventional',
                                             SubGroup__c = 'TransRadial Access',
                                             Qty_Sales_Unit__c=5,Sales_Unit__c='CS',
                                             List_Price__c=380.00,Rep_Price__c=350.00,
                                             Sales_Org__c = 'US60',Distribution_Channel__c = '10',
                                             Sales_Org_Key__c = 'US6010',RSM_Price__c=330.00);
            //prodList.add(prodTest.Name);
            INSERT prodTest;
            Cross_Reference__c CRTest = new Cross_Reference__c(Competitor_Product_Code__c = '320250',
                                                               Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                                                               Competitor_Name__c ='Jarit/Integra',
                                                               Percent_Match__c=100,
                                                               Product__c = prodTest.Id);
            INSERT CRTest;
            Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(Price_Quote__c = PQTest.Id,
                                                                               Material_Name__c = prodTest.Id,
                                                                               Product_Description__c = 'TRANSRADIAL ACCESS TRAY',
                                                                               Sales_Price__c = 10.00,
                                                                               Eligible_Price__c = 230.00,
                                                                               Rep_Price__c = 350.00,
                                                                               RSM_Price__c = 330.00,
                                                                               List_Price__c = 380.00,
                                                                               Quantity__c = 1,
                                                                               Extended_Price__c = 230.00,
                                                                               Competetive_Product__c = CRTest.Id);
            INSERT PQLineItem;
            
            Price_Quote_Line_Item__c PQLineItem1 = new Price_Quote_Line_Item__c(Price_Quote__c = PQTest1.Id,
                                                                                Material_Name__c = prodTest.Id,
                                                                                Product_Description__c = 'TRANSRADIAL ACCESS TRAY',
                                                                                Sales_Price__c = 10.00,
                                                                                Eligible_Price__c = 230.00,
                                                                                Rep_Price__c = 350.00,
                                                                                RSM_Price__c = 330.00,
                                                                                List_Price__c = 380.00,
                                                                                Quantity__c = 1,
                                                                                Extended_Price__c = 230.00,
                                                                                Competetive_Product__c = CRTest.Id);
            INSERT PQLineItem1;
            
            Contract_Header__c chTest = new Contract_Header__c(
                Name = '50000000',
                Agreement_Number__c = '50000000',
                Description__c = 'Test Description',
                Owner__c = 'SAPcode101',
                GPO_Contract_Ref__c = 'MEDANRET',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000
            );
            INSERT chTest;
            
            Contract_Customer__c ccTest = new Contract_Customer__c(
                Name = '50000000',
                Agreement__c = chTest.Id,
                Account__c = accTest.Id,
                SAP_Code__c = 'SAPcode101',
                Sales_Org__c = 'US60',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10'
            );
            INSERT ccTest;
            
            Contract_Material__c cmTest = new Contract_Material__c(Name = '50000000',
                                                                   Agreement__c = chTest.Id,
                                                                   Material_Name__c = 'AA-10511-1',
                                                                   Product__c = prodTest.Id,
                                                                   Sales_Org__c = 'US60',
                                                                   Valid_From__c = Date.Today(),
                                                                   Valid_To__c = Date.Today() + 1000,
                                                                   Material_Division__c = '10',
                                                                   Price__c = 380.00);
            INSERT cmTest;
            
            //Start SAP stuff
            SAPRealPriceSet__x newSAP = new SAPRealPriceSet__x();
            for(SAPRealPriceSet__x sap :[SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c, ValidFrom__c,
                                         ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                         OwnerName__c, Owner__c, AgrObjective__c, Customer__c
                                         FROM SAPRealPriceSet__x
                                         where SalesOrg__c = 'US60'
                                         and DistChnl__c = '10'
                                         and Agreement__c = '50010878'
                                         and Customer__c = '102059'
                                         and Material__c = 'AA-10511-1'
                                         and EffDate__c = :datetime.now()
                                         LIMIT 1])
            {
                String cnum;
                if(sap.Customer__c.left(4) == '0000'){
                    cnum = sap.Customer__c.removeStart('0000');
                }
                else{
                    cnum = sap.Customer__c.removeStart('000');
                }
                
                
                newSAP = new SAPRealPriceSet__x(
                    SalesDeal__c = sap.SalesDeal__c,
                    Price__c = sap.Price__c,
                    Material__c = sap.Material__c,
                    MtrlStatus__c = sap.MtrlStatus__c,
                    ValidFrom__c = sap.ValidFrom__c,
                    ValidTo__c = sap.ValidTo__c,
                    Agreement__c = sap.Agreement__c,
                    AgrDesc__c = sap.AgrDesc__c,
                    Condition__c = 'XIND',
                    OwnerName__c = sap.OwnerName__c,
                    Owner__c = sap.Owner__c,
                    AgrObjective__c = sap.AgrObjective__c,
                    Customer__c = cnum
                );
            }
            
            Test.startTest();
            PageReference pq = Page.PP_Price_QuoteRB;
            Test.setCurrentPage(pq);
            pq.getParameters().put('pqid',PQTest.Id);
            pq.getParameters().put('trId',PQLineItem.Id);
            pq.getParameters().put('itemId',prodTest.Id);
            pq.getParameters().put('trId',PQLineItem.Id);
            pq.getParameters().put('lineId',PQLineItem.Id);
            pq.getParameters().put('repPrice','1100');
            pq.getParameters().put('listPrice','1100');
            pq.getParameters().put('rsmPrice','1100');
            pq.getParameters().put('eligiblePrice','1000');
            pq.getParameters().put('delId','1000993ieifdikdajif');
            
            List<Price_Quote__c> listpq = new List<Price_Quote__c>();
            listpq.add(PQTest);
            PP_Price_QuoteRB pqController = new PP_Price_QuoteRB(new ApexPages.StandardController(PQTest));
            System.debug('*** PQTest.Name *** ' + PQTest.Name);
            System.debug('*** PQTest.Account_Name__c *** ' + PQTest.Account_Name__c);
            System.debug('*** PQLineItem.Sales_Price__c *** ' + PQLineItem.Sales_Price__c);
            
            System.debug('*** PQTest.Account_SAP_Code__c *** ' + PQTest.Account_SAP_Code__c);
            System.debug('*** PQTest.Account_Name__r.SAP_Sold_To__c *** ' + PQTest.Account_Name__r.SAP_Sold_To__c);
            System.debug('*** PQLineItem.RSM_Price__c *** ' + PQLineItem.RSM_Price__c);
            
            System.debug('*** PQTest.Approval_Flag_Rollup__c *** ' + PQTest.Approval_Flag_Rollup__c);
            System.debug('*** PQLineItem.Approval_Flag__c *** ' + PQLineItem.Approval_Flag__c);
            pqController.strProdSearch = 'AA-10511-1';
            pqController.strCrossSearch = '320250';
            pqController.strMats = 'AA-10511-1';
            pqController.lineItemId = PQLineItem.Id;
            pqController.matValue = 'AA-10511-1';
            pqController.rowId = PQLineItem.Id;
            pqController.sapPrice();
            pqController.grandTotal = PQTest.Grand_Total__c;
            pqController.bulkINSERT2();
            pqController.bulkINSERTCross();
            PP_Price_QuoteRB.checkSalesOrg(listpq);
            pqController.bulkrefresh();
            pqController.comButton = true;
            pqController.subButton = false;
            pqController.boolVal = 'true';
            pqController.getpq();
            pqController.getLineItems();
            pqController.getActiveQuoteIdStr();
            pqController.strQtyChange = '5';
            pqController.massQtyChange();
            pqController.sort();
            pqController.updateRSMprice();
            pqController.updateRepPrice();
            pqController.updateListPrice();
            pqController.updateEligiblePrice();
            pqController.massUpdList();
            pqController.massUpdRSM();
            pqController.massUpdRep();
            pqController.massUpdEligible();
            pq.getParameters().put('pqid',PQTest.Id);
            pqController.updateFlag();
            pqController.getRepBids();
            pqController.updateDeal();
            pqController.blankRow();
            pqController.addCrossBlank();
            pqController.addCross();
            pqController.selectedValue = '50000000';
            pqController.setMat();
            pqController.fixString();
            pqController.Refresh();
            pqController.grandTotal = PQTest.Grand_Total__c;
            pqController.strQtyChange = 'A';
            pqController.massQtyChange();
            System.assertEquals(NULL,pqController.massQtyChange() );
            pqController.massDelItems();
            //pqController.createPRF();
            System.debug('*** PQTest.Approval_Flag_Rollup__c 1 *** ' + PQTest.Approval_Flag_Rollup__c);
            System.debug('*** PQLineItem.Approval_Flag__c 1 *** ' + PQLineItem.Approval_Flag__c);
            Id lineId = PQLineItem.Id;
            Integer qty = 5;
            Decimal amount = 150.00;
            Integer row = 1;
            String blank = '';
            PP_Price_QuoteRB.updateQuantity(lineId,qty);
            PP_Price_QuoteRB.updatePrice(lineId,amount);
            PP_Price_QuoteRB.updateOrder(lineId,row);
            PP_Price_QuoteRB.updateBlank(lineId,blank);
            PP_Price_QuoteRB.updateContract(lineId,cmTest.Agreement_Number__c);
            PP_Price_QuoteRB.updateDesc(lineId,blank);
            PP_Price_QuoteRB.updateCompProd(lineId,CRTest.Competitor_Product_Code__c,PQTest.Sales_Org_Key__c);
            pqController.Refresh();
            Test.stopTest();
            //pqController.removingRow();
            // Disabled 13Jun2017 - ESC too many SOQL 101 errors in prod
            //pqController.massDelItems();
            
        }//end of system run
        
    }//end of validQuote test method
    
    
    @isTest static void test_method_approvedQuote() {
        // Implement test code
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'uflex99',email='unit99.test99@unit.teleflex.com',
            emailencodingkey='UTF-8',firstname='Adam',
            lastname='Franks',languagelocalekey='en_US',
            localesidkey='en_GB',profileid = p.Id,
            timezonesidkey='Europe/London',
            username='unit99.test99@unit.teleflex.com'
        );
        INSERT u;
        
        Group d10 = new Group(
            Name = 'Division 10'
        );
        INSERT d10;
        
        Group d20 = new Group(
            Name = 'Division 20'
        );
        INSERT d20;
        
        Group d30 = new Group(
            Name = 'Division 30'
        );
        INSERT d30;
        
        Group d40 = new Group(
            Name = 'Division 40'
        );
        INSERT d40;
        
        Group d50 = new Group(
            Name = 'Division 50'
        );
        INSERT d50;
        
        Group d60 = new Group(
            Name = 'Division 60'
        );
        INSERT d60;
        
        Group pp = new Group(
            Name = 'Pricing Portal'
        );
        INSERT pp;
        
        //Create custom settings for all sales orgs
        List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
        insert newSalesOrgs;
        
        System.runAs(u){
            
            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.Id,
                Active_Region__c = 'US - Teleflex',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Division_10__c = TRUE,Division_20__c = TRUE,
                Division_30__c = TRUE,Division_40__c = TRUE,
                Division_50__c = TRUE,Division_60__c = TRUE,
                Active_Sales_Org_Key__c = 'US6010',
                Active_Currency__c = 'USD'
            );
            //Test.startTest();
            INSERT cu;
            //Test.stopTest();
            system.debug('CU:' + cu);
            
            Account accTest = new Account(Name = 'TestAccount',SAP_Sold_To__c='');
            INSERT accTest;
            
            Contact conTest = new Contact(FirstName ='Test',
            email = 'abc@123.com',LastName = 'TestContact',Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)',AccountId = accTest.Id);
            INSERT conTest;
            
            Price_Quote__c PQTest = new Price_Quote__c(Account_Name__c = accTest.Id,
                                                       Contact_Name__c = conTest.Id,
                                                       Status__c = 'Approved',
                                                       Expiration_Date__c = Date.today() + 90,
                                                       Sales_Org_Key__c = 'US6010');
            INSERT PQTest;
            
            //List<String> prodList = new List<String>();
            Product2 prodTest = new Product2(Name = 'AA-10511-1',
                                             ProductCode= 'AA-10511-1',
                                             UOM__c='CS',Each_per_Case__c=5,
                                             Material_Status__c='MTS',Material_Status_Numeric__c='30',
                                             Family = 'Hardware',Material__c='AA-10511-1',
                                             Brand_Name__c='Arrow',Buom__c='EA',
                                             Class__c='Cardiac Care Specialty',Cost__c=11587.40,
                                             Cost_Price_Unit__c=1000,Division__c='60',
                                             Description='TRANSRADIAL ACCESS TRAY',
                                             Group__c='Interventional',
                                             SubGroup__c = 'TransRadial Access',
                                             Qty_Sales_Unit__c=5,Sales_Unit__c='CS',
                                             List_Price__c=380.00,Rep_Price__c=350.00,
                                             Sales_Org__c = 'US60',Distribution_Channel__c = '10',
                                             Sales_Org_Key__c = 'US6010',RSM_Price__c=330.00);
            //prodList.add(prodTest.Name);
            INSERT prodTest;
            
            Cross_Reference__c CRTest = new Cross_Reference__c(Competitor_Product_Code__c = '320250',
                                                               Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                                                               Competitor_Name__c ='Jarit/Integra',
                                                               Percent_Match__c=100,
                                                               Product__c = prodTest.Id);
            INSERT CRTest;
            
            Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(Price_Quote__c = PQTest.Id,
                                                                               Material_Name__c = prodTest.Id,
                                                                               Sales_Price__c = 230.00,
                                                                               Eligible_Price__c = 230.00,
                                                                               Rep_Price__c = 350.00,
                                                                               RSM_Price__c = 330.00,
                                                                               List_Price__c = 380.00,
                                                                               Quantity__c = 1,
                                                                               Extended_Price__c = 230.00,
                                                                               Competetive_Product__c = CRTest.Id);
            INSERT PQLineItem;
            
            Contract_Header__c chTest = new Contract_Header__c(
                Name = '50000000',
                Agreement_Number__c = '50000000',
                Description__c = 'Test Description',
                Owner__c = 'SAPcode101',
                GPO_Contract_Ref__c = 'MEDANRET',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000
            );
            INSERT chTest;
            
            Contract_Customer__c ccTest = new Contract_Customer__c(
                Name = '50000000',
                Agreement__c = chTest.Id,
                Account__c = accTest.Id,
                SAP_Code__c = 'SAPcode101',
                Sales_Org__c = 'US60',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10'
            );
            INSERT ccTest;
            
            Contract_Material__c cmTest = new Contract_Material__c(Name = '50000000',
                                                                   Agreement__c = chTest.Id,
                                                                   Material_Name__c = 'AA-10511-1',
                                                                   Product__c = prodTest.Id,
                                                                   Sales_Org__c = 'US60',
                                                                   Valid_From__c = Date.Today(),
                                                                   Valid_To__c = Date.Today() + 1000,
                                                                   Material_Division__c = '10',
                                                                   Price__c = 380.00);
            INSERT cmTest;
            
            //Start SAP stuff
            SAPRealPriceSet__x newSAP = new SAPRealPriceSet__x();
            for(SAPRealPriceSet__x sap :[SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c, ValidFrom__c,
                                         ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                         OwnerName__c, Owner__c, AgrObjective__c, Customer__c
                                         FROM SAPRealPriceSet__x
                                         where SalesOrg__c = 'US60'
                                         and DistChnl__c = '10'
                                         and Agreement__c = '50010878'
                                         and Customer__c = '102059'
                                         and Material__c = 'AA-10511-1'
                                         and EffDate__c = :datetime.now()
                                         LIMIT 1])
            {
                String cnum;
                if(sap.Customer__c.left(4) == '0000'){
                    cnum = sap.Customer__c.removeStart('0000');
                }
                else{
                    cnum = sap.Customer__c.removeStart('000');
                }
                
                
                newSAP = new SAPRealPriceSet__x(
                    SalesDeal__c = sap.SalesDeal__c,
                    Price__c = sap.Price__c,
                    Material__c = sap.Material__c,
                    MtrlStatus__c = sap.MtrlStatus__c,
                    ValidFrom__c = sap.ValidFrom__c,
                    ValidTo__c = sap.ValidTo__c,
                    Agreement__c = sap.Agreement__c,
                    AgrDesc__c = sap.AgrDesc__c,
                    Condition__c = 'XIND',
                    OwnerName__c = sap.OwnerName__c,
                    Owner__c = sap.Owner__c,
                    AgrObjective__c = sap.AgrObjective__c,
                    Customer__c = cnum
                );
            }
            
            Test.startTest();
            PageReference pq = Page.PP_Price_QuoteRB;
            Test.setCurrentPage(pq);
            pq.getParameters().put('pqid',PQTest.Id);
            pq.getParameters().put('trId',PQLineItem.Id);
            pq.getParameters().put('itemId',prodTest.Id);
            pq.getParameters().put('trId',PQLineItem.Id);
            
            List<Price_Quote__c> listpq = new List<Price_Quote__c>();
            PQTest.Sales_Org_Key__c = NULL;
            UPDATE PQTest;
            listpq.add(PQTest);
            PP_Price_QuoteRB pqController = new PP_Price_QuoteRB(new ApexPages.StandardController(PQTest));
            pqController.sapPrice();
            //pqController.bulkINSERT2();
            PP_Price_QuoteRB.checkSalesOrg(listpq);
            pqController.bulkrefresh();
            pqController.comButton = true;
            Boolean testCom = pqController.comButton;
            pqController.subButton = false;
            Boolean testSub = pqController.subButton;
            pqController.reviseButton = true;
            Boolean testRev = pqController.reviseButton;
            pqController.hasCrossRef = false;
            Boolean testCross = pqController.hasCrossRef;
            pqController.boolVal = 'true';
            pqController.getpq();
            pqController.getLineItems();
            pqController.getActiveQuoteIdStr();
            pqController.strQtyChange = '5';
            pqController.massQtyChange();
            pqController.sort();
            pqController.updateRSMprice();
            pqController.updateRepPrice();
            pqController.updateListPrice();
            pqController.updateEligiblePrice();
            pqController.massUpdList();
            pqController.massUpdRSM();
            pqController.massUpdRep();
            pqController.massUpdEligible();
            pqController.updateFlag();
            pqController.getRepBids();
            pqController.updateDeal();
            pqController.blankRow();
            pqController.addCrossBlank();
            pqController.addCross();
            pqController.selectedValue = '50000000';
            //pqController.setMat();
            //pqController.fixString();
            pqController.Refresh();
            //pqController.createPRF();
            Id lineId = PQLineItem.Id;
            Integer qty = 5;
            Decimal amount = 150.00;
            Integer row = 1;
            String blank = '';
            
            PP_Price_QuoteRB.updateQuantity(lineId,qty);
            PP_Price_QuoteRB.updatePrice(lineId,amount);
            PP_Price_QuoteRB.updateOrder(lineId,row);
            PP_Price_QuoteRB.updateBlank(lineId,blank);
            PP_Price_QuoteRB.updateContract(lineId,cmTest.Agreement_Number__c);
            PP_Price_QuoteRB.updateDesc(lineId,blank);
            PP_Price_QuoteRB.updateCompProd(lineId,CRTest.Competitor_Product_Code__c,PQTest.Sales_Org_Key__c);
            pqController.Refresh();
            pqController.removingRow();
            pqController.massDelItems();
            DELETE PQLineItem;
            Test.stopTest();
        }//end of system run
        
    }//end of approvedQuote test method
    
    /**************************** START NEW TEST ************************************/
    @isTest static void test_method_validQuote2() {
        // Implement test code
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'uflex76',email='unit.test@unit.teleflex.com',
            emailencodingkey='UTF-8',firstname='Adam',
            lastname='Franks',languagelocalekey='en_US',
            localesidkey='en_GB',profileid = p.Id,
            timezonesidkey='Europe/London',
            username='unit.test@unit.teleflex.com'
        );
        INSERT u;
        
        Group d10 = new Group(
            Name = 'Division 10'
        );
        INSERT d10;
        
        Group d20 = new Group(
            Name = 'Division 20'
        );
        INSERT d20;
        
        Group d30 = new Group(
            Name = 'Division 30'
        );
        INSERT d30;
        
        Group d40 = new Group(
            Name = 'Division 40'
        );
        INSERT d40;
        
        Group d50 = new Group(
            Name = 'Division 50'
        );
        INSERT d50;
        
        Group d60 = new Group(
            Name = 'Division 60'
        );
        INSERT d60;
        
        Group pp = new Group(
            Name = 'Pricing Portal'
        );
        INSERT pp;
        
        //Create custom settings for all sales orgs
        List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
        insert newSalesOrgs;
        
        System.runAs(u){
            
            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Division_10__c = TRUE,Division_20__c = TRUE,
                Division_30__c = TRUE,Division_40__c = TRUE,
                Division_50__c = TRUE,Division_60__c = TRUE,
                Active_Sales_Org_Key__c = 'US6010',
                Active_Currency__c = 'USD'
            );
            //Test.startTest();
            INSERT cu;
            //Test.stopTest();
            system.debug('CU:' + cu);
            
            Account accTest = new Account(Name = 'TestAccount',SAP_Sold_To__c='SAPcode101',Account_Group__c='Z002');
            INSERT accTest;
            System.debug('*** accTest.Id *** ' + accTest.Id);
            
            Account accTest1 = new Account(Name = 'TestAccount',SAP_Sold_To__c='SAPcode102',Account_Group__c='Z001');
            INSERT accTest1;
            
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('SAPcode102','SAPcode101');
            insert cp;
            
            Contact conTest = new Contact(FirstName ='Test',
            email = 'abc@123.com',LastName = 'TestContact',Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)',AccountId = accTest.Id);
            INSERT conTest;
            
            Price_Quote__c PQTest = testDataFactoryPP.createPriceQuote(accTest.Id, conTest.Id, 'US6010', false, 'Anesthesia');
            insert PQTest;
            
            Price_Quote__c PQTest1 = testDataFactoryPP.createPriceQuote(accTest.Id, conTest.Id, 'US103010', false, 'Anesthesia');
            insert PQTest1;
            
            Price_Quote__c PQTest2 = testDataFactoryPP.createPriceQuote(accTest.Id, conTest.Id, 'US6020', false, 'Latin America');
            insert PQTest2;
            
            /*
            Price_Quote__c PQTest = new Price_Quote__c(Account_Name__c = accTest.Id,
                                                       Contact_Name__c = conTest.Id,
                                                       Status__c = 'In Progress',
                                                       Expiration_Date__c = Date.today() + 90,
                                                       Sales_Org_Key__c = 'US6010',
                                                       One_Time_Purchase__c = TRUE);
            INSERT PQTest;
            System.debug('*** PQTest.Account_Name__c *** ' + PQTest.Account_Name__c);
            System.debug('*** PQTest.Account_Name__r.SAP_Sold_To__c *** ' + PQTest.Account_Name__r.SAP_Sold_To__c);
            
            Price_Quote__c PQTest1 = new Price_Quote__c(Account_Name__c = accTest.Id,
                                                        Contact_Name__c = conTest.Id,
                                                        Status__c = 'In Progress',
                                                        Expiration_Date__c = Date.today() + 90,
                                                        Sales_Org_Key__c = 'US6010',
                                                        One_Time_Purchase__c = TRUE);
            INSERT PQTest1;
            
            Price_Quote__c PQTest2 = new Price_Quote__c(Account_Name__c = accTest.Id,
                                                        Contact_Name__c = conTest.Id,
                                                        Status__c = 'In Progress',
                                                        Expiration_Date__c = Date.today() + 90,
                                                        Sales_Org_Key__c = 'US6010',
                                                        One_Time_Purchase__c = TRUE);
            INSERT PQTest2;
            */
            //List<String> prodList = new List<String>();
            Product2 prodTest = new Product2(Name = 'AA-10511-1',
                                             ProductCode= 'AA-10511-1',
                                             UOM__c='CS',Each_per_Case__c=5,
                                             Material_Status__c='MTS',Material_Status_Numeric__c='30',
                                             Family = 'Hardware',Material__c='AA-10511-1',
                                             Brand_Name__c='Arrow',Buom__c='EA',
                                             Class__c='Cardiac Care Specialty',Cost__c=11587.40,
                                             Cost_Price_Unit__c=1000,Division__c='60',
                                             Description='TRANSRADIAL ACCESS TRAY',
                                             Group__c='Interventional',
                                             SubGroup__c = 'TransRadial Access',
                                             Qty_Sales_Unit__c=5,Sales_Unit__c='CS',
                                             List_Price__c=380.00,Rep_Price__c=350.00,
                                             Sales_Org__c = 'US60',Distribution_Channel__c = '10',
                                             Sales_Org_Key__c = 'US6010',RSM_Price__c=330.00);
            //prodList.add(prodTest.Name);
            INSERT prodTest;
            Cross_Reference__c CRTest = new Cross_Reference__c(Competitor_Product_Code__c = '320250',
                                                               Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                                                               Competitor_Name__c ='Jarit/Integra',
                                                               Percent_Match__c=100,
                                                               Product__c = prodTest.Id);
            INSERT CRTest;
            Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(Price_Quote__c = PQTest.Id,
                                                                               Material_Name__c = prodTest.Id,
                                                                               Product_Description__c = 'TRANSRADIAL ACCESS TRAY',
                                                                               Sales_Price__c = 10.00,
                                                                               Eligible_Price__c = 230.00,
                                                                               Rep_Price__c = 350.00,
                                                                               RSM_Price__c = 330.00,
                                                                               List_Price__c = 380.00,
                                                                               Quantity__c = 1,
                                                                               Extended_Price__c = 230.00,
                                                                               Competetive_Product__c = CRTest.Id);
            INSERT PQLineItem;
            
            Price_Quote_Line_Item__c PQLineItem1 = new Price_Quote_Line_Item__c(Price_Quote__c = PQTest1.Id,
                                                                                Material_Name__c = prodTest.Id,
                                                                                Product_Description__c = 'TRANSRADIAL ACCESS TRAY',
                                                                                Sales_Price__c = 10.00,
                                                                                Eligible_Price__c = 230.00,
                                                                                Rep_Price__c = 350.00,
                                                                                RSM_Price__c = 330.00,
                                                                                List_Price__c = 380.00,
                                                                                Quantity__c = 1,
                                                                                Extended_Price__c = 230.00,
                                                                                Competetive_Product__c = CRTest.Id);
            INSERT PQLineItem1;
            
            Contract_Header__c chTest = new Contract_Header__c(
                Name = '50000000',
                Agreement_Number__c = '50000000',
                Description__c = 'Test Description',
                Owner__c = 'SAPcode101',
                GPO_Contract_Ref__c = 'MEDANRET',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000
            );
            INSERT chTest;
            
            Contract_Customer__c ccTest = new Contract_Customer__c(
                Name = '50000000',
                Agreement__c = chTest.Id,
                Account__c = accTest.Id,
                SAP_Code__c = 'SAPcode101',
                Sales_Org__c = 'US60',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10'
            );
            INSERT ccTest;
            
            Contract_Material__c cmTest = new Contract_Material__c(Name = '50000000',
                                                                   Agreement__c = chTest.Id,
                                                                   Material_Name__c = 'AA-10511-1',
                                                                   Product__c = prodTest.Id,
                                                                   Sales_Org__c = 'US60',
                                                                   Valid_From__c = Date.Today(),
                                                                   Valid_To__c = Date.Today() + 1000,
                                                                   Material_Division__c = '10',
                                                                   Price__c = 380.00);
            INSERT cmTest;
            
            //Start SAP stuff
            SAPRealPriceSet__x newSAP = new SAPRealPriceSet__x();
            for(SAPRealPriceSet__x sap :[SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c, ValidFrom__c,
                                         ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                         OwnerName__c, Owner__c, AgrObjective__c, Customer__c
                                         FROM SAPRealPriceSet__x
                                         where SalesOrg__c = 'US60'
                                         and DistChnl__c = '10'
                                         and Agreement__c = '50010878'
                                         and Customer__c = '102059'
                                         and Material__c = 'AA-10511-1'
                                         and EffDate__c = :datetime.now()
                                         LIMIT 1])
            {
                String cnum;
                if(sap.Customer__c.left(4) == '0000'){
                    cnum = sap.Customer__c.removeStart('0000');
                }
                else{
                    cnum = sap.Customer__c.removeStart('000');
                }
                
                
                newSAP = new SAPRealPriceSet__x(
                    SalesDeal__c = sap.SalesDeal__c,
                    Price__c = sap.Price__c,
                    Material__c = sap.Material__c,
                    MtrlStatus__c = sap.MtrlStatus__c,
                    ValidFrom__c = sap.ValidFrom__c,
                    ValidTo__c = sap.ValidTo__c,
                    Agreement__c = sap.Agreement__c,
                    AgrDesc__c = sap.AgrDesc__c,
                    Condition__c = 'XIND',
                    OwnerName__c = sap.OwnerName__c,
                    Owner__c = sap.Owner__c,
                    AgrObjective__c = sap.AgrObjective__c,
                    Customer__c = cnum
                );
            }
            
            Test.startTest();
            PageReference pq = Page.PP_Price_QuoteRB;
            Test.setCurrentPage(pq);
            pq.getParameters().put('pqid',PQTest.Id);
            pq.getParameters().put('trId',PQLineItem.Id);
            pq.getParameters().put('itemId',prodTest.Id);
            pq.getParameters().put('trId',PQLineItem.Id);
            pq.getParameters().put('lineId',PQLineItem.Id);
            pq.getParameters().put('repPrice','1100');
            pq.getParameters().put('listPrice','1100');
            pq.getParameters().put('rsmPrice','1100');
            pq.getParameters().put('eligiblePrice','1000');
            pq.getParameters().put('delId','1000993ieifdikdajif');
            
            List<Price_Quote__c> listpq = new List<Price_Quote__c>();
            listpq.add(PQTest);
            PP_Price_QuoteRB pqController = new PP_Price_QuoteRB(new ApexPages.StandardController(PQTest));
            System.debug('*** PQTest.Name *** ' + PQTest.Name);
            System.debug('*** PQTest.Account_Name__c *** ' + PQTest.Account_Name__c);
            System.debug('*** PQLineItem.Sales_Price__c *** ' + PQLineItem.Sales_Price__c);
            
            System.debug('*** PQTest.Account_SAP_Code__c *** ' + PQTest.Account_SAP_Code__c);
            System.debug('*** PQTest.Account_Name__r.SAP_Sold_To__c *** ' + PQTest.Account_Name__r.SAP_Sold_To__c);
            System.debug('*** PQLineItem.RSM_Price__c *** ' + PQLineItem.RSM_Price__c);
            
            System.debug('*** PQTest.Approval_Flag_Rollup__c *** ' + PQTest.Approval_Flag_Rollup__c);
            System.debug('*** PQLineItem.Approval_Flag__c *** ' + PQLineItem.Approval_Flag__c);
            pqController.strProdSearch = 'AA-10511-1';
            pqController.strCrossSearch = '320250';
            pqController.strMats = 'AA-10511-1';
            pqController.lineItemId = PQLineItem.Id;
            pqController.matValue = 'AA-10511-1';
            pqController.rowId = PQLineItem.Id;
            pqController.sapPrice();
            pqController.grandTotal = PQTest.Grand_Total__c;
            pqController.bulkINSERT2();
            pqController.bulkINSERTCross();
            PP_Price_QuoteRB.checkSalesOrg(listpq);
            pqController.bulkrefresh();
            pqController.comButton = true;
            pqController.subButton = false;
            pqController.boolVal = 'true';
            pqController.getpq();
            pqController.getLineItems();
            pqController.getActiveQuoteIdStr();
            pqController.strQtyChange = '5';
            pqController.massQtyChange();
            pqController.sort();
            pqController.updateRSMprice();
            pqController.updateRepPrice();
            pqController.updateListPrice();
            pqController.updateEligiblePrice();
            pqController.massUpdList();
            pqController.massUpdRSM();
            pqController.massUpdRep();
            pqController.massUpdEligible();
            pq.getParameters().put('pqid',PQTest.Id);
            pqController.updateFlag();
            pqController.getRepBids();
            pqController.updateDeal();
            pqController.blankRow();
            pqController.addCrossBlank();
            pqController.addCross();
            pqController.selectedValue = '50000000';
            pqController.setMat();
            pqController.fixString();
            pqController.Refresh();
            pqController.grandTotal = PQTest.Grand_Total__c;
            pqController.strQtyChange = 'A';
            pqController.massQtyChange();
            System.assertEquals(NULL,pqController.massQtyChange() );
            pqController.massDelItems();
            //pqController.createPRF();
            System.debug('*** PQTest.Approval_Flag_Rollup__c 1 *** ' + PQTest.Approval_Flag_Rollup__c);
            System.debug('*** PQLineItem.Approval_Flag__c 1 *** ' + PQLineItem.Approval_Flag__c);
            Id lineId = PQLineItem.Id;
            Integer qty = 5;
            Decimal amount = 150.00;
            Integer row = 1;
            String blank = '';
            PP_Price_QuoteRB.updateQuantity(lineId,qty);
            PP_Price_QuoteRB.updatePrice(lineId,amount);
            PP_Price_QuoteRB.updateOrder(lineId,row);
            PP_Price_QuoteRB.updateBlank(lineId,blank);
            PP_Price_QuoteRB.updateContract(lineId,cmTest.Agreement_Number__c);
            PP_Price_QuoteRB.updateDesc(lineId,blank);
            PP_Price_QuoteRB.updateCompProd(lineId,CRTest.Competitor_Product_Code__c,PQTest.Sales_Org_Key__c);
            pqController.Refresh();
            Test.stopTest();
            //pqController.removingRow();
            // Disabled 13Jun2017 - ESC too many SOQL 101 errors in prod
            //pqController.massDelItems();
            
        }//end of system run
        
    }//end of validQuote2 test method
    /**************************** END NEW TEST ************************************/
    
    @isTest static void priceQuoteTestNoSapZH() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman07', 'User07', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US07', 'User07', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US08', 'User08', 'Sales Rep', 'Anesthesia');
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
            Test.startTest();
            //Create custom settings for all sales orgs
            List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
            insert newSalesOrgs;
            
            Sales_Condition_Mapping__c conMap1 = new Sales_Condition_Mapping__c(
                name = 'ND', Mapped_Value__c = 'XNAF'
            );
            insert conMap1;
            
            Sales_Condition_Mapping__c conMap2 = new Sales_Condition_Mapping__c(
                name = 'PR', Mapped_Value__c = 'XPRI'
            );
            insert conMap2;
            
            Sales_Condition_Mapping__c conMap3 = new Sales_Condition_Mapping__c(
                name = 'SE', Mapped_Value__c = 'XSEC'
            );
            insert conMap3;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '17',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            insert usAcc;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc.Id);
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
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009068', 'GPO-999','D','US60');
            insert ch5;
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterial(ch5.Id, ch5.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm5;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
            
            Contract_Customer__c cc5 = testDataFactoryPP.createContractCustomer(ch5.Id, ch5.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc5;
            
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
            List<Price_Quote_Line_Item__c> pqliList = new List<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            pqliList.add(pqliUs);
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            pqliList.add(pqliUs1);
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            pqliList.add(pqliUs2);
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            pqliList.add(pqliUs3);
            
            Database.insert(pqliList,false);         

			PageReference pageRefpre = new PageReference('/apex/PP_Price_QuoteRB?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            PP_Price_QuoteRB pqt = new PP_Price_QuoteRB(ctlr);

            pqt.bulkrefresh();
            Test.stopTest();
        }//end of system run

	}//end of priceQuoteTestNoSapZH test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void priceQuoteTestNoSapZA() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman07', 'User07', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US07', 'User07', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US08', 'User08', 'Sales Rep', 'Anesthesia');
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
            Test.startTest();
            //Create custom settings for all sales orgs
            List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
            insert newSalesOrgs;
            
            Sales_Condition_Mapping__c conMap1 = new Sales_Condition_Mapping__c(
                name = 'ND', Mapped_Value__c = 'XNAF'
            );
            insert conMap1;
            
            Sales_Condition_Mapping__c conMap2 = new Sales_Condition_Mapping__c(
                name = 'PR', Mapped_Value__c = 'XPRI'
            );
            insert conMap2;
            
            Sales_Condition_Mapping__c conMap3 = new Sales_Condition_Mapping__c(
                name = 'SE', Mapped_Value__c = 'XSEC'
            );
            insert conMap3;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '03',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            insert usAcc;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc.Id);
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
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009068', 'GPO-999','D','US60');
            insert ch5;
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterial(ch5.Id, ch5.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm5;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
            
            Contract_Customer__c cc5 = testDataFactoryPP.createContractCustomer(ch5.Id, ch5.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc5;
            
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
            List<Price_Quote_Line_Item__c> pqliList = new List<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            pqliList.add(pqliUs);
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            pqliList.add(pqliUs1);
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            pqliList.add(pqliUs2);
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            pqliList.add(pqliUs3);
            
            Database.insert(pqliList,false);         

			PageReference pageRefpre = new PageReference('/apex/PP_Price_QuoteRB?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            PP_Price_QuoteRB pqt = new PP_Price_QuoteRB(ctlr);

            pqt.bulkrefresh();
            Test.stopTest();
        }//end of system run

	}//end of priceQuoteTestNoSapZA test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void priceQuoteTestNoSapZD() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman07', 'User07', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US07', 'User07', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US08', 'User08', 'Sales Rep', 'Anesthesia');
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
            Test.startTest();
            //Create custom settings for all sales orgs
            List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
            insert newSalesOrgs;
            
            Sales_Condition_Mapping__c conMap1 = new Sales_Condition_Mapping__c(
                name = 'ND', Mapped_Value__c = 'XNAF'
            );
            insert conMap1;
            
            Sales_Condition_Mapping__c conMap2 = new Sales_Condition_Mapping__c(
                name = 'PR', Mapped_Value__c = 'XPRI'
            );
            insert conMap2;
            
            Sales_Condition_Mapping__c conMap3 = new Sales_Condition_Mapping__c(
                name = 'SE', Mapped_Value__c = 'XSEC'
            );
            insert conMap3;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '11',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            insert usAcc;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc.Id);
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
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009068', 'GPO-999','D','US60');
            insert ch5;
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterial(ch5.Id, ch5.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm5;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
            
            Contract_Customer__c cc5 = testDataFactoryPP.createContractCustomer(ch5.Id, ch5.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc5;
            
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
            List<Price_Quote_Line_Item__c> pqliList = new List<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            pqliList.add(pqliUs);
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            pqliList.add(pqliUs1);
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            pqliList.add(pqliUs2);
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            pqliList.add(pqliUs3);
            
            Database.insert(pqliList,false);         

			PageReference pageRefpre = new PageReference('/apex/PP_Price_QuoteRB?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            PP_Price_QuoteRB pqt = new PP_Price_QuoteRB(ctlr);

            pqt.bulkrefresh();
            Test.stopTest();
        }//end of system run

	}//end of priceQuoteTestNoSapZD test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void priceQuoteTestSapZd() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman07', 'User07', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US07', 'User07', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US08', 'User08', 'Sales Rep', 'Anesthesia');
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
            Test.startTest();
            //Create custom settings for all sales orgs
            List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
            insert newSalesOrgs;
            
            Sales_Condition_Mapping__c conMap1 = new Sales_Condition_Mapping__c(
                name = 'ND', Mapped_Value__c = 'XNAF'
            );
            insert conMap1;
            
            Sales_Condition_Mapping__c conMap2 = new Sales_Condition_Mapping__c(
                name = 'PR', Mapped_Value__c = 'XPRI'
            );
            insert conMap2;
            
            Sales_Condition_Mapping__c conMap3 = new Sales_Condition_Mapping__c(
                name = 'SE', Mapped_Value__c = 'XSEC'
            );
            insert conMap3;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','999999','11');
            insert usAcc;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc.Id);
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
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009068', 'GPO-999','D','US60');
            insert ch5;
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterial(ch5.Id, ch5.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm5;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
            
            Contract_Customer__c cc5 = testDataFactoryPP.createContractCustomer(ch5.Id, ch5.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc5;
            
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
            List<Price_Quote_Line_Item__c> pqliList = new List<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            pqliList.add(pqliUs);
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            pqliList.add(pqliUs1);
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            pqliList.add(pqliUs2);
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            pqliList.add(pqliUs3);
            
            Database.insert(pqliList,false);         

			PageReference pageRefpre = new PageReference('/apex/PP_Price_QuoteRB?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            PP_Price_QuoteRB pqt = new PP_Price_QuoteRB(ctlr);

            pqt.bulkrefresh();
            Test.stopTest();
        }//end of system run

	}//end of priceQuoteTestSapZd test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
}//end of class