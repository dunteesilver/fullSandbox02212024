@isTest
private class PP_Create_Quote_Test {
    
    static testMethod void PP_Create_Quote_UnitTest() {
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
            
            Territory_Master__c tm = new Territory_Master__c(
                Name = '800123',
                Territory_Number__c = '800123',
                Business_Unit__c = 'EMS'
            );
            insert tm;
            System.debug('Insert Territory Master-->' + tm);
            
            Territory_User__c tu = new Territory_User__c(
                Territory_Master__c = tm.Id,
                User__c = u.id
            );
            insert tu;
            System.debug('Insert Territory User-->' + tu);
            
            
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
                Active_Sales_Org_Key__c = 'US103010',
                Active_Currency__c = 'USD'
            );
            //Test.startTest();
            insert cu;
            //Test.stopTest();
            system.debug('CU:' + cu);
            
            Account accTest = new Account(
                Name = 'TestAccount',
                SAP_Sold_To__c = 'SAPcode101',
                Account_Group__c = 'Z002'
            );
            insert accTest;
            Contact conTest = new Contact(FirstName='Test', LastName = 'Contact', Email='test@123.com',Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)',AccountId = accTest.Id);
            insert conTest;
            
            //List<String> prodList = new List<String>();
            Product2 prodTest = new Product2(
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
                Group__c='Interventional',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,
                Sales_Unit__c='CS',
                List_Price__c=380.00,
                Rep_Price__c=350.00,
                Sales_Org__c = 'US10',
                Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US103010',
                RSM_Price__c=330.00);
            //prodList.add(prodTest.Name);
            insert prodTest;
            system.debug('prodTest: ' + prodTest);
            
            Cross_Reference__c CRTest = new Cross_Reference__c(
                Competitor_Product_Code__c = '320250',
                Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                Competitor_Name__c ='Jarit/Integra',
                Percent_Match__c=100,
                Product__c = prodTest.Id);
            insert CRTest;
            
            Contract_Header__c chTest = new Contract_Header__c(
                Name = '50000000',
                Agreement_Number__c = '50000000',
                Description__c = 'Test Description',
                Owner__c = 'SAPcode101',
                GPO_Contract_Ref__c = 'MEDANRET',
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
            
            Contract_Material__c cmTest = new Contract_Material__c(
                Name = '50000000',
                Agreement__c = chTest.Id,
                Material_Name__c = 'AA-10511-1',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '10',
                Price__c = 380.00);
            insert cmTest;
            system.debug('cmtest: ' + cmTest);
            
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
                system.debug('Pulled SAP! --- ' + SAP);
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
            //End SAP Stuff
            
            Price_Quote__c PQTest = new Price_Quote__c(
                Account_Name__c = accTest.Id,
                Contact_Name__c = conTest.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.valueOf('2015-03-11'),
                Sales_Org_Key__c = 'US103010');
            insert PQTest;
            
            Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
                Price_Quote__c = PQTest.Id,
                Material_Name__c = prodTest.Id,
                Sales_Price__c = 230.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 330.00,
                List_Price__c = 380.00,
                Quantity__c = 1,
                Extended_Price__c = 230.00,
                Competetive_Product__c = CRTest.Id
            );
            insert PQLineItem;
            
            PRF__c prfTest = new PRF__c(
                Account__c = accTest.Id,
                Contact__c = conTest.Id,
                Status__c = 'New',
                Requisition_Date__c = Date.valueOf('2015-03-11'),
                Sales_Org_Key__c = 'US103010',
                Price_Quote__c = PQTest.Id
            );
            insert prfTest;
            
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
            
            // End Test Data Creation
            //
            // Start Testing
            Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.PP_Price_Quote'));
            System.currentPageReference().getParameters().put('pqid', PQTest.Id);
            System.currentPageReference().getParameters().put('cloneType', 'Revise Customer');
            System.currentPageReference().getParameters().put('prdsrch', 'AA-10511-1');
            System.currentPageReference().getParameters().put('rowIndex', '1');
            System.currentPageReference().getParameters().put('rowNo', '0');
            System.currentPageReference().getParameters().put('flagVal', 'True');
            System.currentPageReference().getParameters().put('index', '1');
            System.currentPageReference().getParameters().put('rsmPrice', '100');
            System.currentPageReference().getParameters().put('repPrice', '100');
            System.currentPageReference().getParameters().put('listPrice', '100');
            System.currentPageReference().getParameters().put('eligiblePrice', '100');
            
            PP_Create_Quote PCQObj = new PP_Create_Quote();
            //PCQObj.strCrossReference = '320250';
            //PCQObj.updateOwner();
            //PCQObj.srchPass();
            //PCQObj.strMaterialnumber = 'AA-10511-1';
            //PCQObj.srchPass();
            //PCQObj.srchPass();
            PCQObj.Today = Datetime.now();
            PCQObj.counterwrap = '1';
            PCQObj.imageURL ='https://www.teleflexsurgical.com';
            PCQObj.populateMaterialName();
            PCQObj.editContactWithExpiration();
            PCQObj.globalQty ='1';
            PCQObj.quantityUpd();
            //PCQObj.updateContactWithExpiration();
            //PCQObj.updateContactWithExpiration();
            PCQObj.cancelEditContact();
            PCQObj.updateFlag();
            PCQObj.processUpdate();
            PCQObj.searchMethod();
            PCQObj.contextItem = '1';
            PCQObj.processCalculationMethod();
            PCQObj.doUpdateAccountValue();
            PCQObj.doCloning();
            PCQObj.strMats = '001111';
            PCQObj.bulkInsert();
            PCQObj.sortLineItems();
            
            PCQObj.strMats = 'AA-10511-1';
            //PCQObj.createSapMap(prodList);
            PCQObj.createPriceQuoteLineObj(prodTest,newSAP);
            PCQObj.bulkInsert();
            PCQObj.getActiveQuoteIdStr();
            //PCQObj.doUpdateNoOpp();
            PCQObj.gknBulkInsert();
            PCQObj.saveCheck();
            //PCQObj.counterwrap = '1';
            //PCQObj.priceQuoteLine.Sales_Price__c = 100.00;
            //PCQObj.updateRSMprice();
            //PCQObj.updateRepPrice();
            //PCQObj.updateListPrice();
            //PCQObj.updateEligiblePrice();
            PCQObj.massUpdList();
            PCQObj.massUpdEligible();
            PCQObj.massUpdRep();
            PCQObj.massUpdRSM();
            PCQObj.addOrUpdate();
            set<String> testStr = new set<String>();
            testStr.add('AA-10511-1');
            PCQObj.calSalesOrgStr('SAPcode101', testStr);
            PCQObj.createPriceQuoteLineObjSFDC(prodTest,cmTest);
            //PCQObj.createPriceQuoteLineObj();
            PCQObj.comButton = True;
            PCQObj.subButton = True;
            Boolean x = PCQObj.comButton;
            Boolean y = PCQObj.subButton;
            
            PCQObj.strMats = '';
            //PCQObj.createSapMap(prodList);
            PCQObj.createPriceQuoteLineObj(prodTest,newSAP);
            PCQObj.bulkInsert();
            PCQObj.getActiveQuoteIdStr();
            PCQObj.gknBulkInsert();
            PCQObj.saveCheck();
            PCQObj.removingRow();
            PP_Create_Quote.saveSortedRows(new List<String>{PQLineItem.id});
            
            Test.setCurrentPageReference(new PageReference('Page.PP_PRF'));
            
            System.currentPageReference().getParameters().put('strProdSearch', 'AA-10511-1');
            System.currentPageReference().getParameters().put('id', prfTest.Id);
            System.currentPageReference().getParameters().put('step', '1');
            System.currentPageReference().getParameters().put('rsmPrice', '100');
            System.currentPageReference().getParameters().put('repPrice', '100');
            System.currentPageReference().getParameters().put('listPrice', '100');
            System.currentPageReference().getParameters().put('eligiblePrice', '100');
            
            PP_PRF prfRec = new PP_PRF();
            
            prfRec.strProdSearch = 'AA-10511-1';
            prfRec.bulkMatStr = 'AA-10511-1';
            prfRec.requestedPrice = 123.00;
            prfRec.prfid = prfTest.Id;
            prfRec.salesCurrency = 'USD';
            prfRec.salesOrgKey = 'US103010';
            prfRec.createPath = TRUE;
            
            prfRec.getprf();
            //prfRec.save();
            prfRec.msearch();
            prfRec.edit();
            prfRec.xls();
            prfRec.cancel();
            prfRec.gettodaysdate();
            PP_PRF.settu();
            //prfRec.getPLI();
            prfRec.sapPrice();
            prfRec.sapBulkInsert();
            PP_PRF.updatePrice(prfLineItem.Id, 230.00);
            prfRec.Refresh();
            prfRec.removingRow();
            //prfRec.createQuote();
            prfRec.bulkrefresh();
            Test.stopTest();
        }
        
        
    }
}