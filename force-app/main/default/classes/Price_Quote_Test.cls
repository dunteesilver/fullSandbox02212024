@isTest
public class Price_Quote_Test {

    @isTest static void test_method_validQuote() {
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
                        Division_10__c = TRUE,Division_20__c = TRUE,
                        Division_30__c = TRUE,Division_40__c = TRUE,
                        Division_50__c = TRUE,Division_60__c = TRUE,
                        Active_Sales_Org_Key__c = 'US103010',
                        Active_Currency__c = 'USD'
                );
                //Test.startTest();
                insert cu;
                //Test.stopTest();
                system.debug('CU:' + cu);

                Account accTest = new Account(Name = 'TestAccount',SAP_Sold_To__c='SAPcode101');
                insert accTest;

                Contact conTest = new Contact(FirstName ='Test',
            email = 'abc@123.com', LastName = 'TestContact',
                                              Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)',AccountId = accTest.Id);
                insert conTest;

                Price_Quote__c PQTest = new Price_Quote__c(Account_Name__c = accTest.Id,
                                                                                                     Contact_Name__c = conTest.Id,
                                                                                                     Status__c = 'In Progress',
                                                                                                     Expiration_Date__c = Date.today() + 90,
                                                                                                     Sales_Org_Key__c = 'US103010');
                insert PQTest;

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
                                                                                 Sales_Org__c = 'US10',Distribution_Channel__c = '10',
                                                                                 Sales_Org_Key__c = 'US103010',RSM_Price__c=330.00,
                                                                                 Transfer_Price__c = 1000.00);
                                                                                 //prodList.add(prodTest.Name);
                insert prodTest;

                Cross_Reference__c CRTest = new Cross_Reference__c(Competitor_Product_Code__c = '320250',
                                                                                                                     Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                                                                                                                     Competitor_Name__c ='Jarit/Integra',
                                                                                                                     Percent_Match__c=100,
                                                                                                                     Product__c = prodTest.Id);
                insert CRTest;

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
                insert PQLineItem;

                Price_Quote_Line_Item__c PQLineItem1 = new Price_Quote_Line_Item__c(Price_Quote__c = PQTest.Id,
                                                                                    Material_Name__c = prodTest.Id,
                                                                                    Sales_Price__c = 230.00,
                                                                                    Eligible_Price__c = 230.00,
                                                                                    Rep_Price__c = 350.00,
                                                                                    RSM_Price__c = 330.00,
                                                                                    List_Price__c = 380.00,
                                                                                    Quantity__c = 1,
                                                                                    Extended_Price__c = 230.00,
                                                                                    Competetive_Product__c = CRTest.Id);
                insert PQLineItem1;

                List<Price_Quote_Line_Item__c> lineItems = new List<Price_Quote_Line_Item__c>();
                lineItems.add(PQLineItem);
                lineItems.add(PQLineItem1);

                Contract_Header__c chTest = new Contract_Header__c(
                        Name = '50000000',
                        Agreement_Number__c = '50000000',
                        Description__c = 'Test Description',
                        //Owner__c = 'SAPcode101',
                    	Owner__c= '123310',
                    	Sub_Group__c = '8',
                        GPO_Contract_Ref__c = 'MEDANRE-R',
                        //GPO_Contract_Ref__c = 'MEDANRET',
                        Valid_From__c = Date.Today(),
                        Valid_To__c = Date.Today() + 1000
                );
                insert chTest;

                Contract_Customer__c ccTest = new Contract_Customer__c(
                        Name = '50000000',
                        Agreement__c = chTest.Id,
                        Account__c = accTest.Id,
                        SAP_Code__c = 'SAPcode101',
                        Sales_Org__c = 'US10',
                        Valid_From__c = Date.Today(),
                        Valid_To__c = Date.Today() + 1000,
                        Distribution_Channel__c = '10'
                );
                insert ccTest;

                Contract_Material__c cmTest = new Contract_Material__c(Name = '50000000',
                                                                       Agreement__c = chTest.Id,
                                                                       Material_Name__c = 'AA-10511-1',
                                                                       Product__c = prodTest.Id,
                                                                       Sales_Org__c = 'US10',
                                                                       Valid_From__c = Date.Today(),
                                                                       Valid_To__c = Date.Today() + 1000,
                                                                       Material_Division__c = '10',
                                                                       Price__c = 380.00);
                insert cmTest;
            
                //Start SAP stuff
                SAPRealPriceSet__x newSAP = new SAPRealPriceSet__x();
                for(SAPRealPriceSet__x sap :[SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c, ValidFrom__c,
                                                                         ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                                                         OwnerName__c, Owner__c, AgrObjective__c, Customer__c
                                                                         FROM SAPRealPriceSet__x
                                                                         where SalesOrg__c = 'US10'
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


                PageReference pq = Page.PP_Price_Quote;
                Test.setCurrentPage(pq);
                pq.getParameters().put('pqid',PQTest.Id);
                pq.getParameters().put('trId',PQLineItem.Id);
                pq.getParameters().put('itemId',prodTest.Id);
                pq.getParameters().put('trId',PQLineItem.Id);
               	pq.getParameters().put('lineItemId',PQLineItem.Id);
                
                PP_Price_Quote pqController = new PP_Price_Quote(new ApexPages.StandardController(PQTest));
                //pqController.convUnit = 1000;
                //pqController.newCost = 1;
                pqController.sapPrice();
                pqController.comButton = true;
                pqController.subButton = false;
                pqController.prfButton = false;
                pqController.updateOwner();
                pqController.doUpdateAccountValue();
                pqController.getpq();
                pqController.getLineItems();
                pqController.getActiveQuoteIdStr();
                pqController.strQtyChange = '5';
                pqController.massQtyChange();
                pqController.sort();
                pqController.helperMethod();
                pqController.editpq();
                pqController.printpq();
                pqController.saveOneTime();
                pqController.cpProcess();
                pqController.bulkrefresh();
                pqController.createPRF();
                pqController.fixString();
                pqController.saveRecord();
                pqController.updateRSMprice();
                pqController.updateRepPrice();
                pqController.updateListPrice();
                pqController.updateEligiblePrice();
                pqController.massUpdList();
                pqController.massUpdRSM();
                pqController.massUpdRep();
                pqController.massUpdEligible();
                pq.getParameters().put('pqid',PQTest.Id);
                pqController.doCloning();
                pqController.updateFlag();
                pqController.getcpDropDown();
                //pqController.makeActivePQ();
                pqController.newCreateOpp();
                //pqController.createOpp();
                //pqController.Approve();
                //pqController.Reject();
                pqController.sendReport();
                pqController.Refresh();
                //pqController.createPRF();
                Id lineId = PQLineItem.Id;
                Integer qty = 5;
                Decimal amount = 150.00;
                Integer row = 1;

                PP_Price_Quote.updateQuantity(lineId,qty);
                PP_Price_Quote.updatePrice(lineId,amount);
                PP_Price_Quote.updateOrder(lineId,row);
				pq.getParameters().put('lineItemId',PQLineItem.Id);
                pqController.Refresh();
                pqController.removingRow();
                pqController.massDelItems();
                pqController.cancel();
            }//end of system run



    }//end of validQuote test method


    @isTest static void test_method_approvedQuote() {
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
                        Division_10__c = TRUE,Division_20__c = TRUE,
                        Division_30__c = TRUE,Division_40__c = TRUE,
                        Division_50__c = TRUE,Division_60__c = TRUE,
                        Active_Sales_Org_Key__c = 'US103010',
                        Active_Currency__c = 'USD'
                );
                //Test.startTest();
                insert cu;
                //Test.stopTest();
                system.debug('CU:' + cu);

                Account accTest = new Account(Name = 'TestAccount',SAP_Sold_To__c='SAPcode101');
                insert accTest;

                Contact conTest = new Contact(FirstName ='Test',
            email = 'abc@123.com', LastName = 'TestContact', Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)',AccountId = accTest.Id);
                insert conTest;

                Price_Quote__c PQTest = new Price_Quote__c(Account_Name__c = accTest.Id,
                                                                                                     Contact_Name__c = conTest.Id,
                                                                                                     Status__c = 'Approved',
                                                                                                     Expiration_Date__c = Date.today() + 90,
                                                                                                     Sales_Org_Key__c = 'US103010');
                insert PQTest;

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
                                                                                 Sales_Org__c = 'US10',Distribution_Channel__c = '10',
                                                                                 Sales_Org_Key__c = 'US103010',RSM_Price__c=330.00,
                                                                                 Transfer_Price__c = 1000.00);
                                                                                 //prodList.add(prodTest.Name);
                insert prodTest;

                Cross_Reference__c CRTest = new Cross_Reference__c(Competitor_Product_Code__c = '320250',
                                                                                                                     Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                                                                                                                     Competitor_Name__c ='Jarit/Integra',
                                                                                                                     Percent_Match__c=100,
                                                                                                                     Product__c = prodTest.Id);
                insert CRTest;

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
                insert PQLineItem;

                Price_Quote_Line_Item__c PQLineItem1 = new Price_Quote_Line_Item__c(Price_Quote__c = PQTest.Id,
                                                                                                                                                     Material_Name__c = prodTest.Id,
                                                                                                                                                     Sales_Price__c = 230.00,
                                                                                                                                                     Eligible_Price__c = 230.00,
                                                                                                                                                     Rep_Price__c = 350.00,
                                                                                                                                                     RSM_Price__c = 330.00,
                                                                                                                                                     List_Price__c = 380.00,
                                                                                                                                                     Quantity__c = 1,
                                                                                                                                                     Extended_Price__c = 230.00,
                                                                                                                                                     Competetive_Product__c = CRTest.Id);
                insert PQLineItem1;

                List<Price_Quote_Line_Item__c> lineItems = new List<Price_Quote_Line_Item__c>();
                lineItems.add(PQLineItem);
                lineItems.add(PQLineItem1);

                Contract_Header__c chTest = new Contract_Header__c(
                        Name = '50000000',
                        Agreement_Number__c = '50000000',
                        Description__c = 'Test Description',
                        //Owner__c = 'SAPcode101',
                    	Owner__c= '123310',
                    	Sub_Group__c = '8',
                        GPO_Contract_Ref__c = 'MEDANRE-R',
                        Valid_From__c = Date.Today(),
                        Valid_To__c = Date.Today() + 1000                       
                );
                insert chTest;

                Contract_Customer__c ccTest = new Contract_Customer__c(
                        Name = '50000000',
                        Agreement__c = chTest.Id,
                        Account__c = accTest.Id,
                        SAP_Code__c = 'SAPcode101',
                        Sales_Org__c = 'US10',
                        Valid_From__c = Date.Today(),
                        Valid_To__c = Date.Today() + 1000,
                        Distribution_Channel__c = '10'
                );
                insert ccTest;

                Contract_Material__c cmTest = new Contract_Material__c(Name = '50000000',
                                                                         Agreement__c = chTest.Id,
                                                                         Material_Name__c = 'AA-10511-1',
                                                                         Product__c = prodTest.Id,
                                                                         Sales_Org__c = 'US10',
                                                                         Valid_From__c = Date.Today(),
                                                                         Valid_To__c = Date.Today() + 1000,
                                                                         Material_Division__c = '10',
                                                                         Price__c = 380.00
                                                                         );
                insert cmTest;

                //Start SAP stuff
                SAPRealPriceSet__x newSAP = new SAPRealPriceSet__x();
                for(SAPRealPriceSet__x sap :[SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c, ValidFrom__c,
                                                                         ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                                                         OwnerName__c, Owner__c, AgrObjective__c, Customer__c
                                                                         FROM SAPRealPriceSet__x
                                                                         where SalesOrg__c = 'US10'
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


                PageReference pq = Page.PP_Price_Quote;
                Test.setCurrentPage(pq);
                pq.getParameters().put('pqid',PQTest.Id);
                pq.getParameters().put('trId',PQLineItem.Id);
                pq.getParameters().put('itemId',prodTest.Id);
                pq.getParameters().put('trId',PQLineItem.Id);
				pq.getParameters().put('lineItemId',PQLineItem.Id);
            
                PP_Price_Quote pqController = new PP_Price_Quote(new ApexPages.StandardController(PQTest));
                //pqController.convUnit = 1000;
                //pqController.newCost = 1;
                pqController.sapPrice();
                pqController.comButton = true;
                Boolean testCom = pqController.comButton;
                pqController.subButton = false;
                Boolean testSub = pqController.subButton;
                pqController.reviseButton = true;
                Boolean testRev = pqController.reviseButton;
                pqController.prfButton = true;
                Boolean testPrf = pqController.prfButton;
                pqController.hasCrossRef = false;
                Boolean testCross = pqController.hasCrossRef;
                pqController.updateOwner();
                pqController.doUpdateAccountValue();
                pqController.getpq();
                pqController.getLineItems();
                pqController.getActiveQuoteIdStr();
                pqController.strQtyChange = '5';
                pqController.massQtyChange();
                pqController.sort();
                pqController.helperMethod();
                pqController.fixString();
                pqController.saveRecord();
                pqController.updateRSMprice();
                pqController.updateRepPrice();
                pqController.updateListPrice();
                pqController.updateEligiblePrice();
                pqController.massUpdList();
                pqController.massUpdRSM();
                pqController.massUpdRep();
                pqController.massUpdEligible();
                pqController.doCloning();
                pqController.updateFlag();
                pqController.getcpDropDown();
                //pqController.makeActivePQ();
                pqController.newCreateOpp();
                //pqController.createOpp();
                //pqController.Approve();
                //pqController.Reject();
                pqController.sendReport();
                pqController.Refresh();
                //pqController.createPRF();
                Id lineId = PQLineItem.Id;
                Integer qty = 5;
                Decimal amount = 150.00;
                Integer row = 1;
                PP_Price_Quote.updateQuantity(lineId,qty);
                PP_Price_Quote.updatePrice(lineId,amount);
                PP_Price_Quote.updateOrder(lineId,row);
            	pq.getParameters().put('lineItemId',PQLineItem.Id);
                pqController.Refresh();
                pqController.removingRow();
                pqController.massDelItems();
            }//end of system run



    }//end of approvedQuote test method

}//end of class