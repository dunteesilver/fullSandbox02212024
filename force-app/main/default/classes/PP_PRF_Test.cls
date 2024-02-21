/*********************************************************************
* Description      : Test coverage for Pricing Portal PRF Process.
* Coverage         : Classes(PP_PRF) 
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
@istest
public class PP_PRF_Test {
    
    @istest static void Test_PRF(){
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
            Business_Unit__c = 'Respiratory' 
        );
        insert u;

        User u2 = new User(
            alias = 'uflex77',
            email='unit.test1@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Jack',
            lastname='Franks',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p.Id,
            timezonesidkey='Europe/London',
            username='unit.test1@unit.teleflex.com',
            Business_Unit__c = 'Respiratory',
            ManagerId = u.Id
        );
        insert u2;

        //Create custom settings for all sales orgs
        List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
        insert newSalesOrgs;
        
        System.runAs(u2){
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

            Account a = new Account(
                Name = 'Test PP Account',
                SAP_Sold_To__c ='100123',
                ShippingStreet='123 Main Street ',
                ShippingCity='Raleigh',
                ShippingState='NC',
                ShippingPostalCode='27614',
                Customer_Group__c = '19',
                Account_Group__c = 'Z002'
            );
            insert a;
            system.debug('a:' + a);

            Contact c = new Contact(
                FirstName ='Test',
                email = 'abc@123.com',
                lastname = 'Marcus',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                AccountId = a.id
            );
            insert c;
            system.debug('c:' + c);

            Price_Quote__c pq = new Price_Quote__c(
                Account_Name__c = a.id,
                Contact_Name__c = c.id,
                Ownerid = u.id,
                Expiration_Date__c = Date.today() + 90,
                Status__c = 'Approved'
            );
            insert pq;

            PRF__c prfTest = new PRF__c(
                Account__c = a.Id,
                Contact__c = c.Id,
                Status__c = 'New',
                Requisition_Date__c = Date.valueOf('2015-03-11'),
                Sales_Org_Key__c = 'US103010',
                Price_Quote__c = pq.Id,
                GPO_Affiliation__c = 'HEALTHPRO',
                Price_Tier_Status__c = 'Declined'
            );
            insert prfTest;

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
                Class__c='Anesthesia',
                Cost__c=11587.40,
                Cost_Price_Unit__c=1000,
                Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Group__c='Respiratory',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,
                Sales_Unit__c='CS',
                List_Price__c=380.00,
                Alt_Site_List__c=380.00,
                Distributor_List__c=380.00,
                Rep_Price__c=350.00,
                RSM_Price__c=340.00,
                Transfer_Price__c = 1000.00,
                Director_Price__c = 300.00,
                Floor_Price__c = 200.00,
                Sales_Org__c = 'US60',
                Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US6010',
                Material_Key__c = '353535-US60-10'
            );
            //prodList.add(prodTest.Name);
            //master_TriggerHelperClass.runOnce('resetOnceSet');
            insert prodTest;

            Prf_Line_Item__c prfLineItem = new Prf_Line_Item__c(
                Prf__c = prfTest.Id,
                Material_Name__c = prodTest.Id,
                Requested_Price__c = 230.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 340.00,
                List_Price__c = 380.00,
                Sales_Deal_Description__c = 'test',
                Product_Description__c='Test Description'
            );
            insert prfLineItem;

            Prf_Line_Item__c prfLineItem1 = new Prf_Line_Item__c(
                Prf__c = prfTest.Id,
                Material_Name__c = prodTest.Id,
                Requested_Price__c = 150.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 340.00,
                List_Price__c = 380.00,
                Sales_Deal_Description__c = 'test1',
                Product_Description__c='Test1 Description1'
            );
            insert prfLineItem1;

            Prf_Line_Item__c prfLineItem2 = new Prf_Line_Item__c(
                Prf__c = prfTest.Id,
                Material_Name__c = prodTest.Id,
                Requested_Price__c = 0.01,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 340.00,
                List_Price__c = 380.00,
                Sales_Deal_Description__c = 'test2',
                Product_Description__c='Test2 Description2'
            );
            insert prfLineItem2;

            Prf_Line_Item__c prfLineItem3 = new Prf_Line_Item__c(
                Prf__c = prfTest.Id,
                Material_Name__c = prodTest.Id,
                Requested_Price__c = 500.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 340.00,
                List_Price__c = 380.00,
                Sales_Deal_Description__c = 'test3',
                Product_Description__c='Test3 Description3'
            );
            insert prfLineItem3;

            Prf_Line_Item__c prfLineItem4 = new Prf_Line_Item__c(
                Prf__c = prfTest.Id,
                Material_Name__c = prodTest.Id,
                Requested_Price__c = 363.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 340.00,
                List_Price__c = 380.00,
                Sales_Deal_Description__c = 'test4',
                Product_Description__c='Test4 Description4'
            );
            insert prfLineItem4;

            Prf_Line_Item__c prfLineItem5 = new Prf_Line_Item__c(
                Prf__c = prfTest.Id,
                Material_Name__c = prodTest.Id,
                Requested_Price__c = 373.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 340.00,
                List_Price__c = 380.00,
                Sales_Deal_Description__c = 'test5',
                Product_Description__c='Test5 Description5'
            );
            insert prfLineItem5;

            Contract_Header__c chTest = new Contract_Header__c(
                Name = '50009064',
                Agreement_Number__c = '50009064',
                Description__c = 'Test Description',
                Owner__c = '123310',
                Owner_Name__c  = 'Teleflex',
                GPO_Contract_Ref__c = 'RESP-R',
                Sub_Group__c = '8',
                Group__c = '04',
                Objective__c = '01',
                Pricing_Tier_Access__c = 1.0,
                Sales_Org__c = 'US60', 
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000
            );
            insert chTest;

            Contract_Header__c chTest1 = new Contract_Header__c(
                Name = '50009065',
                Agreement_Number__c = '50009065',
                Description__c = 'Test1 Description1',
                Owner__c = '123310',
                Owner_Name__c  = 'Teleflex',
                GPO_Contract_Ref__c = 'RESP-R',
                Sub_Group__c = '8',
                Group__c = '04',
                Objective__c = '01',
                Pricing_Tier_Access__c = 1.0,
                Sales_Org__c = 'US60', 
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000
            );
            insert chTest1;

            Contract_Header__c chTest2 = new Contract_Header__c(
                Name = '50009066',
                Agreement_Number__c = '50009066',
                Description__c = 'Test2 Description2',
                Owner__c = '123310',
                Owner_Name__c  = 'Teleflex',
                GPO_Contract_Ref__c = 'RESP-M',
                Sub_Group__c = '8',
                Group__c = '04',
                Objective__c = '01',
                Pricing_Tier_Access__c = 1.0,
                Sales_Org__c = 'US60', 
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000
            );
            insert chTest2;

            GPO_PickList__c gpoPickList = new GPO_PickList__c(
                Name = 'Vizient Inc.',
                Sales_Org_Key__c = 'US',
                Active__c = TRUE,
                Key__c = 'GPO-008'
            );
            insert gpoPickList;

            Contract_Material__c cmTier = new Contract_Material__c(
                Name = '50009064',
                Agreement__c = chTest.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US60',
                Distribution_Channel__c = '10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '50',
                Price__c = 385.00,
                Rep_Price__c = 375.00,
                RSM_Price__c = 365.00,
                Director_Price__c = 355.00,
                VP_Price__c = 350.00,
                GPO_Contract_Ref__c = 'RESP-R',
                Maintenance_Key__c = '123'
            );
            insert cmTier;

            Contract_Material__c cmTier1 = new Contract_Material__c(
                Name = '50009065',
                Agreement__c = chTest.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US60',
                Distribution_Channel__c = '10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '50',
                Price__c = 375.00,
                Rep_Price__c = 375.00,
                RSM_Price__c = 365.00,
                Director_Price__c = 355.00,
                VP_Price__c = 350.00,
                GPO_Contract_Ref__c = 'RESP-R',
                Maintenance_Key__c = '123'
            );
            insert cmTier1;

            Contract_Material__c cmTier2 = new Contract_Material__c(
                Name = '50009066',
                Agreement__c = chTest.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US60',
                Distribution_Channel__c = '10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today(),
                Material_Division__c = '50',
                Price__c = 365.00,
                Rep_Price__c = 375.00,
                RSM_Price__c = 365.00,
                Director_Price__c = 355.00,
                VP_Price__c = 350.00,
                GPO_Contract_Ref__c = 'RESP-M',
                Maintenance_Key__c = '123'
            );
            insert cmTier2;
            
            /*
            Contract_Customer__c ccTier1 = new Contract_Customer__c(
                Name = '50010001',
                Agreement__c = chTest.Id,
                Account__c = a.Id,
                SAP_Code__c = '100123',
                Sales_Org__c = 'US60',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10',
                Condition__c = 'XNAF',
                Maintenance_Key__c = '123'
            );
            insert ccTier1;
            */
            Prf__c prf2 = [SELECT Id, Name, Data_Driven_Justification__c, Owner_Full_Name__c, Agreement_Type__c, Eligible_Distributor__c,GPO_Affiliation__c,
                        Current_Annual_Purchases__c, Estimated_Annual_Purchases__c, Preferred_Start_Date__c, Preferred_End_Date__c, Requisition_Date__c,
                        PRF_Name__c, Owner_Business_Unit__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,Sales_Deal__c,Valid_To__c,
                        Account__r.Id, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry,CurrencyIsoCode,Valid_From__c,
                        Account__r.SAP_Sold_To__c, Contact__r.Id, Contact__r.name, Contact__r.email, Territory__c, Territory__r.Territory_Number__c,
                        Territory__r.Territory_Name__c,Status__c, Additional_Accounts__c,Sales_Org_Key__c, LastModifiedById, LastModifiedDate, Owner_ID__c,
                        CreatedById, CreatedDate, Price_Quote__c, Price_Quote__r.Name, Price_Quote__r.Price_Quote_Name__c, Line_Count__c, Owner_Email__c,
                        Audit_Check__c, Owner_Approval_Role__c, Owner_Approval_Level__c, Approval_Level__c, Workflow_Owner_Approval_Level__c, Account__r.Account_Group__c,
                        Product_Class_Count__c, Account__r.Price_List_Type__c, Current_Approver__c, Total_Annual_Eaches__c, Approval_Flag_Rollup__c, RsmRepToggle__c,
                        OwnerId, Owner.Name, Business_Unit__c, InApproval__c, Category__c, PRF_Promotion_related__c
                        FROM PRF__c
                        WHERE id = :prfTest.Id];
                System.debug('*** prf2 PP_Prf_Test Test_Prf *** ' + prf2);
                //System.assertEquals(4.0, pqUs2.Line_count__c);
                
                List<Prf_Line_Item__c> lineItems = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Description, Eligible_Price__c, Material_Name_Text__c,
                                            Current_Price__c, Sales_Deal_Num__c, Sales_Deal_Description__c, Condition__c, Objective_Name__c, Material_Name__r.Distribution_Channel__c,
                                            List_Price__c, Rep_Price__c, RSM_Price__c, CurrencyIsoCode, Requested_Price__c, Material_Name__r.Sales_Org__c,Director_Price__c, Floor_Price__c,
                                            Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, Product_Description__c, Material_Name__r.Transfer_Price__c, Material_Name__r.Cost_Price_Unit__c,
                                            Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Material_Name__r.Director_Price__c, Material_Name__r.Cost__c, Cost__c,
                                            Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c,Material_Name__r.SubGroup__c,
                                            Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Floor_Price__c, Material_Name__r.Brand__c, Material_Status__c,Material_Name__r.Class__c,
                                            Material_Name__r.Cost_Formula__c, Material_Name__r.ASK_Custom_Kit__c, Material_Status_Description__c, Material_Name__r.SearchableProducts__c,
                                            Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Sales_Deal__r.Pricing_Tier__c, Sales_Deal__r.Agreement_Number__c,
                                            Requested_Pricing__r.Parent_Contract_Name__c, Requested_Pricing__r.Agreement_Number__c, Requested_Pricing__r.Description__c,
                                            Material_Name__r.VP_Price__c, PRF__r.Business_Unit__c
                                            FROM PRF_Line_Item__c
                                            WHERE PRF__c =:prf2.Id];
            System.debug('*** lineItems.size() PP_Prf_Test Test_Prf *** ' + lineItems.size() );
            PageReference pageRef2 = new PageReference('/apex/PP_PRF?id=' + prf2.Id);
            system.debug('PRF Page' + pageRef2);
            Test.setCurrentPage(pageRef2);
            
            //String tierPrice = Apexpages.currentpage().getParameters().get('tierPrice');
            //Id lineId = Apexpages.currentpage().getParameters().get('lineId');
            //String key =  Apexpages.currentpage().getParameters().get('key');
            
            //List<PRF_Line_Item__c> lineItems = new List<PRF_Line_Item__c>();
            //lineItems.add(prfLineItem);
            System.currentPageReference().getParameters().put('listPrice', '380.00');
            PP_PRF prfClass = new PP_PRF();
            
            PP_PRF.settu();
            prfClass.strProdSearch = '353535';
            prfClass.bulkMatStr = '353535';
            prfClass.isDirect = FALSE;
            prfClass.isAsk = FALSE;
            prfClass.needsApproval = FALSE;
            System.assertEquals(FALSE, prfClass.isDirect);
            System.assertEquals(TRUE, prfClass.needsApproval);
            System.assertEquals(FALSE, prfClass.isASK);
            prfClass.soldToAcct = '100123';
            prfClass.soldToAcctType = 'Z001';
            System.assertEquals('', prfClass.soldToAcct);
            System.assertEquals('', prfClass.soldToAcctType);
            prfClass.isApprover = FALSE;
            System.assertEquals(FALSE, prfClass.isApprover);        
            prfClass.wrkId = '';
            System.assertEquals('', prfClass.wrkId); 
            prfClass.requestedPrice = 375.00;
            prfClass.createPath = FALSE;
            System.assertEquals(FALSE,prfClass.createPath);
            prfClass.subButton = TRUE;
            System.assertEquals(TRUE,prfClass.subButton);
            //prfClass.mySalesOrg = 'US6010';
            //System.assertEquals('US6010',prfClass.mySalesOrg);
            prfClass.getPLI();
            prfClass.gettodaysdate();
            prfClass.getprf();
            prfClass.save();
            prfClass.cancel();
            prfClass.xls();
            Boolean approvalLevel = prfClass.userApprovalLevel;
            String userBuAsk = prfClass.userBuAsk;
            prfClass.setPriceToggle();
            prfClass.getCheckInit();
            prfClass.updateEligiblePrice();
            prfClass.doUpdateOwnerValue();
            prfClass.Approve();
            prfClass.Reject();
            prfClass.doCloning();
            prfClass.massUpdList();
            prfClass.massUpdRsm();
            prfClass.requestHigherTierAccess();
            prfClass.updateListprice();
            
            //parameters needed for updateTierPrice()
            //System.currentPageReference().getParameters().put('tierPrice', '385.00');
            //System.currentPageReference().getParameters().put('lineId', lineItems[0].Id);
            //System.currentPageReference().getParameters().put('key', 'REP1-353535');
            //prfClass.getCheckInit();
            //prfClass.updateTierPrice();
            
            /*
            PageReference pageRef3 = new PageReference('/apex/PP_PRF_EXPORT?id=' + prf2.Id);
            system.debug('PRF Page' + pageRef3);
            Test.setCurrentPage(pageRef3);
            
            PP_PRF pqtest2 = new PP_PRF();
            pqtest2.getPLI();
            pqtest2.getprf();
            */
            PageReference pageRefpreApp = new PageReference('/apex/PP_ApprovalLayoutPrf?id=' + prf2.Id);
            system.debug('Prf Page' + pageRefpreApp);
            Test.setCurrentPage(pageRefpreApp);
            PP_PRF prf = new PP_PRF();
            system.debug('lineItems.size() PP_Prf_Test before getMargins *** ' + lineItems.size() );
            prf.getMargins(lineItems);
            prf.getPriceCheck(lineItems);
            prf.getFormatEligiblePrices(lineItems);
            prf.getFormatListPrices(lineItems);
            prf.getFormatRepPrices(lineItems);
            prf.getFormatRequestedPrices(lineItems);
            prf.getFormatRsmPrices(lineItems);
            //prf.getPriceCheck(lineItems);
            prf.getMinContract(lineItems);
            prf.getMinContractAgree(lineItems);
            prf.getMinGpo(lineItems);
            prf.getMinGpoAgree(lineItems);
        }
    }//end of method Test_PRF
    
    
    //test method for one time purchase
    @isTest static void testPrf() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Interventional Capital');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Interventional Capital');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser){
            //Create custom settings for all sales orgs
            List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
            insert newSalesOrgs;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','03');
            insert usACC;
            
            Account usAcc1 = testDataFactoryPP.createAccount('TestAcount US1', 'US60','100002','03');
            insert usAcc1;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd04', 'US60', '10', '40');
            insert usProd;
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd05', 'US60', '10', '40');
            insert usProd1;
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd06', 'US60', '10', '40');
            insert usProd2;
                        
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100001','100002');
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
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
                       
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUS;
            
            //Setup PRF Data
            //createPrf(String accId, String conId, String salesOrgKey, String bu)
            Prf__c prfUs = testDataFactoryPP.createPrf(usAcc.Id, con1.Id, 'US6010', 'Anesthesia');
            insert prfUs;

            //Setup PQ Line Item data
            //createPrfLineItem(String prfId, String prodId)
            Prf_Line_Item__c prfliUs = testDataFactoryPP.createPrfLineItem(prfUs.Id, usProd.Id);
            insert prfliUs;
			
            Prf_Line_Item__c prfliUs1 = testDataFactoryPP.createPrfLineItem(prfUs.Id, usProd1.Id);
            insert prfliUs1;
            
            Prf_Line_Item__c prfliUs2 = testDataFactoryPP.createPrfLineItem(prfUs.Id, usProd2.Id);
            insert prfliUs2;
            
            prfliUs.Sales_Deal__c = ch1.Id;
            update prfliUs;
            
            prfliUs1.Sales_Deal__c = ch1.Id;
            update prfliUs1;
            
            prfliUs2.Sales_Deal__c = ch1.Id;
            update prfliUs2;
            
            PageReference pageRefpre = new PageReference('/apex/PP_PRF?id=' + prfUs.Id);
            system.debug('Prf Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            //System.currentPageReference().getParameters().put('refresh', 'Yes');
			List<PRF_Line_Item__c> lineItems = new List<PRF_Line_Item__c>();
        	lineItems.add(prfliUs);
            lineItems.add(prfliUs1);
            lineItems.add(prfliUs2);
            
            //System.currentPageReference().getParameters().put('key', 'REP1-353535');
            //ApexPages.StandardController ctlr = new ApexPages.StandardController(prfUs);
            System.currentPageReference().getParameters().put('strProdSearch', 'usProd');
            System.currentPageReference().getParameters().put('bulkMatStr', 'usProd');
            System.currentPageReference().getParameters().put('tierPrice', '100');
            System.currentPageReference().getParameters().put('lineId', prfliUs.id);
            System.currentPageReference().getParameters().put('key', 'List');
            System.currentPageReference().getParameters().put('rsmPrice', '330.00');
            System.currentPageReference().getParameters().put('repPrice', '350.00');
            System.currentPageReference().getParameters().put('eligiblePrice', '300.00');
            //System.currentPageReference().getParameters().put('pqid', pqUs.Id);
            PP_Prf prf = new PP_Prf();
    		//System.assertEquals('usProd', prf.strProdSearch);
            //System.assertEquals('usProd', prf.bulkMatStr);
            Test.startTest();
            prf.strProdSearch = 'usProd';
        	prf.bulkMatStr = 'usProd';
            System.assertEquals('usProd', prf.strProdSearch);
            System.assertEquals('usProd', prf.bulkMatStr);
            prf.mySalesOrg = 'US';
        	System.assertEquals('US',prf.mySalesOrg);
            prf.setPriceToggle();
            prf.priceToggle = false;
            prf.setPriceToggle();
            prf.getCheckInit();
            prf.initCube();
            prf.massUpdateTiers();
            //prf.updateTierPrice();
            prf.massUpdList();
            prf.massUpdRsm();
            prf.massUpdRep();
            prf.massUpdEligible();
			prf.updateListprice();
            prf.updateRSMprice();
            prf.updateRepPrice();
            prf.updateEligiblePrice();
            prf.doUpdateOwnerValue();
            prf.getprf();
            prf.save();
            prf.msearch();
            prf.edit();
            prf.xls();
            prf.cancel();
            prf.getPLI();
            prf.getPickListValuesIntoList();
            prf.setBu();
            prf.gettodaysdate();
            PP_PRF.settu();
            prf.getgpoOptions();
            prf.updateGPO();
            prf.sapPrice();
            prf.sapBulkInsert();
            prf.Approve();
            
            PageReference pageRefpreApp = new PageReference('/apex/PP_ApprovalLayoutPrf?id=' + prfUs.Id);
            system.debug('Prf Page' + pageRefpreApp);
            Test.setCurrentPage(pageRefpreApp);
            
            //prf.getMargins(lineItems);
            prf.getFormatEligiblePrices(lineItems);
            prf.getFormatListPrices(lineItems);
            prf.getFormatRepPrices(lineItems);
            prf.getFormatRequestedPrices(lineItems);
            prf.getFormatRsmPrices(lineItems);
            //prf.getPriceCheck(lineItems);
            prf.getMinContract(lineItems);
            prf.getMinContractAgree(lineItems);
            prf.getMinGpo(lineItems);
            prf.getMinGpoAgree(lineItems);
            Test.stopTest();
        }//end of system run

	}//end of testPrf test method
    
    //test method for one time purchase
    @isTest static void testPrfPq() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Interventional Capital');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Interventional Capital');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser){
            //Create custom settings for all sales orgs
            List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
            insert newSalesOrgs;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','03');
            insert usACC;
            
            Account usAcc1 = testDataFactoryPP.createAccount('TestAcount US1', 'US60','100002','03');
            insert usAcc1;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd00', 'US60', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd01', 'US60', '10', '40');
            insert usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd02', 'US60', '10', '40');
            insert usProd2;
            
            //Start of product pricing update
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            update usProd;
            
            usProd1.Alt_Site_List__c = 0.00;
            usProd1.Distributor_List__c = 0.00;
            update usProd1;
            
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 0.00;
            update usProd2;
            //End of product pricing update
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100001','100002');
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
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
                       
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUS;
            
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            //Setup PRF Data
            //createPrf(String accId, String conId, String salesOrgKey, String bu)
            Prf__c prfUs1 = testDataFactoryPP.createPrf(usAcc.Id, con1.Id, 'US6010', 'Anesthesia');
            insert prfUs1;

            //Setup PQ Line Item data
            //createPrfLineItem(String prfId, String prodId)
            Prf_Line_Item__c prfliUs = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd.Id);
            insert prfliUs;
			
            Prf_Line_Item__c prfliUs1 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd1.Id);
            insert prfliUs1;
            
            Prf_Line_Item__c prfliUs2 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd2.Id);
            insert prfliUs2;
            
            prfliUs.Sales_Deal__c = ch1.Id;
            update prfliUs;
            
            prfliUs1.Sales_Deal__c = ch1.Id;
            update prfliUs1;
            
            prfliUs2.Sales_Deal__c = ch1.Id;
            update prfliUs2;
            
            Prf__c prfUs = [SELECT Id, Name, Data_Driven_Justification__c, Owner_Full_Name__c, Agreement_Type__c, Eligible_Distributor__c,GPO_Affiliation__c,
                   Current_Annual_Purchases__c, Estimated_Annual_Purchases__c, Preferred_Start_Date__c, Preferred_End_Date__c, Requisition_Date__c,
                   PRF_Name__c, Owner_Business_Unit__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,Sales_Deal__c,Valid_To__c,
                   Account__r.Id, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry,CurrencyIsoCode,Valid_From__c,
                   Account__r.SAP_Sold_To__c, Contact__r.Id, Contact__r.name, Contact__r.email, Territory__c, Territory__r.Territory_Number__c,
                   Territory__r.Territory_Name__c,Status__c, Additional_Accounts__c,Sales_Org_Key__c, LastModifiedById, LastModifiedDate, Owner_ID__c,
                   CreatedById, CreatedDate, Price_Quote__c, Price_Quote__r.Name, Price_Quote__r.Price_Quote_Name__c, Line_Count__c, Owner_Email__c,
                   Audit_Check__c, Owner_Approval_Role__c, Owner_Approval_Level__c, Approval_Level__c, Workflow_Owner_Approval_Level__c, Account__r.Account_Group__c,
                   Product_Class_Count__c, Account__r.Price_List_Type__c, Current_Approver__c, Total_Annual_Eaches__c, Approval_Flag_Rollup__c, RsmRepToggle__c,
                   OwnerId, Owner.Name, Business_Unit__c, InApproval__c, Category__c, PRF_Promotion_related__c
                   FROM PRF__c
                   WHERE id = :prfUs1.Id];
            System.debug('*** prfUs PP_Prf_Test testPrfPq *** ' + prfUs);
            //System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Prf_Line_Item__c> lineItems = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Description, Eligible_Price__c, Material_Name_Text__c,
                                      Current_Price__c, Sales_Deal_Num__c, Sales_Deal_Description__c, Condition__c, Objective_Name__c, Material_Name__r.Distribution_Channel__c,
                                      List_Price__c, Rep_Price__c, RSM_Price__c, CurrencyIsoCode, Requested_Price__c, Material_Name__r.Sales_Org__c,Director_Price__c, Floor_Price__c,
                                      Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, Product_Description__c, Material_Name__r.Transfer_Price__c, Material_Name__r.Cost_Price_Unit__c,
                                      Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Material_Name__r.Director_Price__c, Material_Name__r.Cost__c, Cost__c,
                                      Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c,Material_Name__r.SubGroup__c,
                                      Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Floor_Price__c, Material_Name__r.Brand__c, Material_Status__c,Material_Name__r.Class__c,
                                      Material_Name__r.Cost_Formula__c, Material_Name__r.ASK_Custom_Kit__c, Material_Status_Description__c, Material_Name__r.SearchableProducts__c,
                                      Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Sales_Deal__r.Pricing_Tier__c, Sales_Deal__r.Agreement_Number__c,
                                      Requested_Pricing__r.Parent_Contract_Name__c, Requested_Pricing__r.Agreement_Number__c, Requested_Pricing__r.Description__c,
                                      Material_Name__r.VP_Price__c, PRF__r.Business_Unit__c
                                      FROM PRF_Line_Item__c
                                      WHERE PRF__c =:prfUs.Id];
            System.debug('*** lineItems.size() PP_Prf_Test testPrfPq *** ' + lineItems.size() );
            
            //Start PQ stuff
            PageReference pageRefpre1 = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre1);
            Test.setCurrentPage(pageRefpre1);
    
            sales_Cockpit scp = new sales_Cockpit();
            System.currentPageReference().getParameters().put('pqid', pqUs.Id);
    
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(pqUs.id);
            Approval.ProcessResult result = Approval.process(req1);
            //End PQ stuff
            
            PageReference pageRefpre = new PageReference('/apex/PP_PRF?id=' + prfUs.Id);
            system.debug('Prf Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            //System.currentPageReference().getParameters().put('refresh', 'Yes');
			//List<PRF_Line_Item__c> lineItems = new List<PRF_Line_Item__c>();
        	//lineItems.add(prfliUs);
            //lineItems.add(prfliUs1);
            //lineItems.add(prfliUs2);
            //System.currentPageReference().getParameters().put('key', 'REP1-353535');
            //ApexPages.StandardController ctlr = new ApexPages.StandardController(prfUs);
            System.currentPageReference().getParameters().put('strProdSearch', 'usProd');
            System.currentPageReference().getParameters().put('bulkMatStr', 'usProd');
            System.currentPageReference().getParameters().put('tierPrice', '100');
            System.currentPageReference().getParameters().put('lineId', prfliUs.id);
            System.currentPageReference().getParameters().put('key', 'VP1-usProd00');
            System.currentPageReference().getParameters().put('pqid', pqUs.Id);
            System.currentPageReference().getParameters().put('aid', usAcc.Id);
            PP_Prf prf = new PP_Prf();
    		//System.assertEquals('usProd', prf.strProdSearch);
            //System.assertEquals('usProd', prf.bulkMatStr);
            Test.startTest();
            prf.strProdSearch = 'usProd';
        	prf.bulkMatStr = 'usProd';
            System.assertEquals('usProd', prf.strProdSearch);
            System.assertEquals('usProd', prf.bulkMatStr);
            prf.setPriceToggle();
            prf.priceToggle = false;
            prf.setPriceToggle();
            prf.getCheckInit();
            prf.initCube();
            prf.massUpdateTiers();
            prf.updateTierPrice();
            prf.massUpdList();
            prf.massUpdRsm();
            prf.massUpdRep();
            prf.massUpdEligible();
			prf.updateListprice();
            prf.updateRSMprice();
            prf.updateRepPrice();
            prf.updateEligiblePrice();
            prf.doUpdateOwnerValue();
            prf.getprf();
            prf.save();
            prf.msearch();
            prf.edit();
            prf.xls();
            prf.cancel();
            prf.getPLI();
            prf.getPickListValuesIntoList();
            prf.setBu();
            prf.gettodaysdate();
            PP_PRF.settu();
            prf.getgpoOptions();
            prf.updateGPO();
            prf.sapPrice();
            prf.sapBulkInsert();
            
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
            req2.setComments('Submitting request for approval.');
            req2.setObjectId(prfUs.id);
            // Submit on behalf of a specific submitter
            req2.setSubmitterId(usUser.Id); 
            // Submit the record to specific process and skip the criteria evaluation
            //req2.setProcessDefinitionNameOrId('PRF_Approval_Anesthesia_v1_1');
            req2.setSkipEntryCriteria(true);
            // Submit the approval request for the record
            Approval.ProcessResult result1 = Approval.process(req2);
            
            prfUs.Price_Quote__c = pqUs.Id;
            update prfUS;
            prf.save();
            //Refresh
            System.currentPageReference().getParameters().put('itemId', usProd.Id);
            System.currentPageReference().getParameters().put('lineItemId', prfliUs.id);
            System.currentPageReference().getParameters().put('id', prfUs.Id);
            System.currentPageReference().getParameters().put('requestedPrice', '10.00');
            System.currentPageReference().getParameters().put('prfId', prfUs.id);
            prf.refresh();
            prf.removingRow();
            prf.updateType();
            prf.createQuote();
            prf.bulkrefresh();
            prf.createPDF();
            prf.createAuditPDF();
            
            PageReference pageRefpreApp = new PageReference('/apex/PP_ApprovalLayoutPrf?id=' + prfUs.Id);
            system.debug('Prf Page' + pageRefpreApp);
            Test.setCurrentPage(pageRefpreApp);
            
            //prf.getMargins(lineItems);
            prf.getFormatEligiblePrices(lineItems);
            prf.getFormatListPrices(lineItems);
            prf.getFormatRepPrices(lineItems);
            prf.getFormatRequestedPrices(lineItems);
            prf.getFormatRsmPrices(lineItems);
            //prf.getPriceCheck(lineItems);
            //prf.getMinContract(lineItems);
            //prf.getMinContractAgree(lineItems);
            //prf.getMinGpo(lineItems);
            //prf.getMinGpoAgree(lineItems);
            Test.stopTest();
        }//end of system run
	}//end of testPrfPq test method
    
    //test method for one time purchase
    @isTest static void testPrfNoSap() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Interventional Capital');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Interventional Capital');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser){
            //Create custom settings for all sales orgs
            List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
            insert newSalesOrgs;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '17',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
            );
            insert usAcc;            
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd0', 'US60', '10', '40');
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            
            //Start of updating product list pricing
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            update usProd;
            
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 0.00;
            update usProd2;
            
            
            usProd1.Alt_Site_List__c = 0.00;
            usProd1.Distributor_List__c = 0.00;
            update usProd1;
            //End of updating product list pricing
            
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
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
                       
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUS;
            
            
            //Setup PRF Data
            //createPrf(String accId, String conId, String salesOrgKey, String bu)
            Prf__c prfUs1 = testDataFactoryPP.createPrf(usAcc.Id, con1.Id, 'US6010', 'Anesthesia');
            insert prfUs1;

            //Setup PQ Line Item data
            //createPrfLineItem(String prfId, String prodId)
            Prf_Line_Item__c prfliUs = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd.Id);
            insert prfliUs;
			
            Prf_Line_Item__c prfliUs1 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd1.Id);
            insert prfliUs1;
            
            Prf_Line_Item__c prfliUs2 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd2.Id);
            insert prfliUs2;
            
            prfliUs.Sales_Deal__c = ch1.Id;
            update prfliUs;
            
            prfliUs1.Sales_Deal__c = ch1.Id;
            update prfliUs1;
            
            prfliUs2.Sales_Deal__c = ch1.Id;
            update prfliUs2;
            
            Prf__c prfUs = [SELECT Id, Name, Data_Driven_Justification__c, Owner_Full_Name__c, Agreement_Type__c, Eligible_Distributor__c,GPO_Affiliation__c,
                   Current_Annual_Purchases__c, Estimated_Annual_Purchases__c, Preferred_Start_Date__c, Preferred_End_Date__c, Requisition_Date__c,
                   PRF_Name__c, Owner_Business_Unit__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,Sales_Deal__c,Valid_To__c,
                   Account__r.Id, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry,CurrencyIsoCode,Valid_From__c,
                   Account__r.SAP_Sold_To__c, Contact__r.Id, Contact__r.name, Contact__r.email, Territory__c, Territory__r.Territory_Number__c,
                   Territory__r.Territory_Name__c,Status__c, Additional_Accounts__c,Sales_Org_Key__c, LastModifiedById, LastModifiedDate, Owner_ID__c,
                   CreatedById, CreatedDate, Price_Quote__c, Price_Quote__r.Name, Price_Quote__r.Price_Quote_Name__c, Line_Count__c, Owner_Email__c,
                   Audit_Check__c, Owner_Approval_Role__c, Owner_Approval_Level__c, Approval_Level__c, Workflow_Owner_Approval_Level__c, Account__r.Account_Group__c,
                   Product_Class_Count__c, Account__r.Price_List_Type__c, Current_Approver__c, Total_Annual_Eaches__c, Approval_Flag_Rollup__c, RsmRepToggle__c,
                   OwnerId, Owner.Name, Business_Unit__c, InApproval__c, Category__c, PRF_Promotion_related__c
                   FROM PRF__c
                   WHERE id = :prfUs1.Id];
            System.debug('*** prfUs PP_Prf_Test testPrfNoSap *** ' + prfUs);
            //System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Prf_Line_Item__c> lineItems = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Description, Eligible_Price__c, Material_Name_Text__c,
                                      Current_Price__c, Sales_Deal_Num__c, Sales_Deal_Description__c, Condition__c, Objective_Name__c, Material_Name__r.Distribution_Channel__c,
                                      List_Price__c, Rep_Price__c, RSM_Price__c, CurrencyIsoCode, Requested_Price__c, Material_Name__r.Sales_Org__c,Director_Price__c, Floor_Price__c,
                                      Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, Product_Description__c, Material_Name__r.Transfer_Price__c, Material_Name__r.Cost_Price_Unit__c,
                                      Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Material_Name__r.Director_Price__c, Material_Name__r.Cost__c, Cost__c,
                                      Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c,Material_Name__r.SubGroup__c,
                                      Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Floor_Price__c, Material_Name__r.Brand__c, Material_Status__c,Material_Name__r.Class__c,
                                      Material_Name__r.Cost_Formula__c, Material_Name__r.ASK_Custom_Kit__c, Material_Status_Description__c, Material_Name__r.SearchableProducts__c,
                                      Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Sales_Deal__r.Pricing_Tier__c, Sales_Deal__r.Agreement_Number__c,
                                      Requested_Pricing__r.Parent_Contract_Name__c, Requested_Pricing__r.Agreement_Number__c, Requested_Pricing__r.Description__c,
                                      Material_Name__r.VP_Price__c, PRF__r.Business_Unit__c
                                      FROM PRF_Line_Item__c
                                      WHERE PRF__c =:prfUs.Id];
            System.debug('*** lineItems.size() PP_Prf_Test testPrfNoSap *** ' + lineItems.size() );
            PageReference pageRefpre = new PageReference('/apex/PP_PRF?id=' + prfUs.Id);
            system.debug('Prf Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            //System.currentPageReference().getParameters().put('refresh', 'Yes');
			//List<PRF_Line_Item__c> lineItems = new List<PRF_Line_Item__c>();
        	//lineItems.add(prfliUs);
            //lineItems.add(prfliUs1);
            //lineItems.add(prfliUs2);
            
            //System.currentPageReference().getParameters().put('key', 'REP1-353535');
            //ApexPages.StandardController ctlr = new ApexPages.StandardController(prfUs);
            System.currentPageReference().getParameters().put('strProdSearch', 'usProd');
            System.currentPageReference().getParameters().put('bulkMatStr', 'usProd');
            System.currentPageReference().getParameters().put('tierPrice', '100');
            System.currentPageReference().getParameters().put('lineId', prfliUs.id);
            System.currentPageReference().getParameters().put('key', 'List');
            System.currentPageReference().getParameters().put('key', 'List');
            
            //System.currentPageReference().getParameters().put('pqid', pqUs.Id);
            PP_Prf prf = new PP_Prf();
    		//System.assertEquals('usProd', prf.strProdSearch);
            //System.assertEquals('usProd', prf.bulkMatStr);
            Test.startTest();
            prf.strProdSearch = 'usProd';
        	prf.bulkMatStr = 'usProd';
            System.assertEquals('usProd', prf.strProdSearch);
            System.assertEquals('usProd', prf.bulkMatStr);
            List<String> materialStr = new List<String>();
            materialStr.add(usProd.Name);
            prf.getSAPprice(materialStr, NULL, prfliUs.Id, prfUs.Id);
            //prf.updateTierPrice();
            prf.massUpdList();
            prf.massUpdRsm();
            prf.massUpdRep();
            prf.massUpdEligible();
			prf.updateListprice();
            prf.updateRSMprice();
            prf.updateRepPrice();
            prf.updateEligiblePrice();
            prf.doUpdateOwnerValue();
            prf.getprf();
            prf.save();
            prf.sapPrice();
            prf.sapBulkInsert();
            
            //Refresh
            System.currentPageReference().getParameters().put('itemId', usProd.Id);
            System.currentPageReference().getParameters().put('lineItemId', prfliUs.id);
            System.currentPageReference().getParameters().put('id', prfUs.Id);
            System.currentPageReference().getParameters().put('requestedPrice', '10.00');
            System.currentPageReference().getParameters().put('prfId', prfUs.id);
            prf.refresh();
            prf.removingRow();
            prf.updateType();
            prf.createQuote();
            prf.bulkrefresh();
            prf.createPDF();
            prf.createAuditPDF();
            
            PageReference pageRefpreApp = new PageReference('/apex/PP_ApprovalLayoutPrf?id=' + prfUs.Id);
            system.debug('Prf Page' + pageRefpreApp);
            Test.setCurrentPage(pageRefpreApp);
            
            //(lineItems);
            prf.getFormatEligiblePrices(lineItems);
            prf.getFormatListPrices(lineItems);
            prf.getFormatRepPrices(lineItems);
            prf.getFormatRequestedPrices(lineItems);
            prf.getFormatRsmPrices(lineItems);
            //prf.getPriceCheck(lineItems);
            prf.getMinContract(lineItems);
            prf.getMinContractAgree(lineItems);
            prf.getMinGpo(lineItems);
            prf.getMinGpoAgree(lineItems);
            Test.stopTest();
        }//end of system run

	}//end of testPrfNoSap test method
    
    @isTest static void testPrfNoSapZa() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Interventional Capital');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Interventional Capital');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser){
            //Create custom settings for all sales orgs
            List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
            insert newSalesOrgs;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '03',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
            );
            insert usAcc;            
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US01', 'Contact01', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd07', 'US60', '10', '40');
            insert usProd;
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd08', 'US60', '10', '40');
            insert usProd1;
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd09', 'US60', '10', '40');
            insert usProd2;
            
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
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
                       
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUs;
            //pqUs.Status__c = 'Approved';
            //update pqUs;
            
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            //Setup PRF Data
            //createPrf(String accId, String conId, String salesOrgKey, String bu)
            Prf__c prfUs1 = testDataFactoryPP.createPrf(usAcc.Id, con1.Id, 'US6010', 'Anesthesia');
            insert prfUs1;

            //Setup PQ Line Item data
            //createPrfLineItem(String prfId, String prodId)
            Prf_Line_Item__c prfliUs = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd.Id);
            insert prfliUs;
			
            Prf_Line_Item__c prfliUs1 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd1.Id);
            insert prfliUs1;
            
            Prf_Line_Item__c prfliUs2 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd2.Id);
            insert prfliUs2;
            
            prfliUs.Sales_Deal__c = ch1.Id;
            update prfliUs;
            
            prfliUs1.Sales_Deal__c = ch1.Id;
            update prfliUs1;
            
            prfliUs2.Sales_Deal__c = ch1.Id;
            update prfliUs2;
            
            Prf__c prfUs = [SELECT Id, Name, Data_Driven_Justification__c, Owner_Full_Name__c, Agreement_Type__c, Eligible_Distributor__c,GPO_Affiliation__c,
                   Current_Annual_Purchases__c, Estimated_Annual_Purchases__c, Preferred_Start_Date__c, Preferred_End_Date__c, Requisition_Date__c,
                   PRF_Name__c, Owner_Business_Unit__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,Sales_Deal__c,Valid_To__c,
                   Account__r.Id, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry,CurrencyIsoCode,Valid_From__c,
                   Account__r.SAP_Sold_To__c, Contact__r.Id, Contact__r.name, Contact__r.email, Territory__c, Territory__r.Territory_Number__c,
                   Territory__r.Territory_Name__c,Status__c, Additional_Accounts__c,Sales_Org_Key__c, LastModifiedById, LastModifiedDate, Owner_ID__c,
                   CreatedById, CreatedDate, Price_Quote__c, Price_Quote__r.Name, Price_Quote__r.Price_Quote_Name__c, Line_Count__c, Owner_Email__c,
                   Audit_Check__c, Owner_Approval_Role__c, Owner_Approval_Level__c, Approval_Level__c, Workflow_Owner_Approval_Level__c, Account__r.Account_Group__c,
                   Product_Class_Count__c, Account__r.Price_List_Type__c, Current_Approver__c, Total_Annual_Eaches__c, Approval_Flag_Rollup__c, RsmRepToggle__c,
                   OwnerId, Owner.Name, Business_Unit__c, InApproval__c, Category__c, PRF_Promotion_related__c
                   FROM PRF__c
                   WHERE id = :prfUs1.Id];
            System.debug('*** prfUs PP_Prf_Test testPrfNoSapZa *** ' + prfUs);
            //System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Prf_Line_Item__c> lineItems = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Description, Eligible_Price__c, Material_Name_Text__c,
                                      Current_Price__c, Sales_Deal_Num__c, Sales_Deal_Description__c, Condition__c, Objective_Name__c, Material_Name__r.Distribution_Channel__c,
                                      List_Price__c, Rep_Price__c, RSM_Price__c, CurrencyIsoCode, Requested_Price__c, Material_Name__r.Sales_Org__c,Director_Price__c, Floor_Price__c,
                                      Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, Product_Description__c, Material_Name__r.Transfer_Price__c, Material_Name__r.Cost_Price_Unit__c,
                                      Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Material_Name__r.Director_Price__c, Material_Name__r.Cost__c, Cost__c,
                                      Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c,Material_Name__r.SubGroup__c,
                                      Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Floor_Price__c, Material_Name__r.Brand__c, Material_Status__c,Material_Name__r.Class__c,
                                      Material_Name__r.Cost_Formula__c, Material_Name__r.ASK_Custom_Kit__c, Material_Status_Description__c, Material_Name__r.SearchableProducts__c,
                                      Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Sales_Deal__r.Pricing_Tier__c, Sales_Deal__r.Agreement_Number__c,
                                      Requested_Pricing__r.Parent_Contract_Name__c, Requested_Pricing__r.Agreement_Number__c, Requested_Pricing__r.Description__c,
                                      Material_Name__r.VP_Price__c, PRF__r.Business_Unit__c
                                      FROM PRF_Line_Item__c
                                      WHERE PRF__c =:prfUs.Id];
            System.debug('*** lineItems.size() PP_Prf_Test testPrfNoSapZa *** ' + lineItems.size() );
            
            //Start PQ stuff
            PageReference pageRefpre1 = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre1);
            Test.setCurrentPage(pageRefpre1);
    
            sales_Cockpit scp = new sales_Cockpit();
            System.currentPageReference().getParameters().put('pqid', pqUs.Id);
    
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(pqUs.id);
            Approval.ProcessResult result = Approval.process(req1);
            //End PQ stuff
            
            PageReference pageRefpre = new PageReference('/apex/PP_PRF?id=' + prfUs.Id);
            system.debug('Prf Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            //System.currentPageReference().getParameters().put('refresh', 'Yes');
			//List<PRF_Line_Item__c> lineItems = new List<PRF_Line_Item__c>();
        	//lineItems.add(prfliUs);
            //lineItems.add(prfliUs1);
            //lineItems.add(prfliUs2);
            //System.currentPageReference().getParameters().put('key', 'REP1-353535');
            //ApexPages.StandardController ctlr = new ApexPages.StandardController(prfUs);
            System.currentPageReference().getParameters().put('strProdSearch', 'usProd');
            System.currentPageReference().getParameters().put('bulkMatStr', 'usProd');
            System.currentPageReference().getParameters().put('tierPrice', '100');
            System.currentPageReference().getParameters().put('lineId', prfliUs.id);
            System.currentPageReference().getParameters().put('key', 'List');
            
            //System.currentPageReference().getParameters().put('pqid', pqUs.Id);
            PP_Prf prf = new PP_Prf();
    		//System.assertEquals('usProd', prf.strProdSearch);
            //System.assertEquals('usProd', prf.bulkMatStr);
            Test.startTest();
            prf.strProdSearch = 'usProd';
        	prf.bulkMatStr = 'usProd';
            System.assertEquals('usProd', prf.strProdSearch);
            System.assertEquals('usProd', prf.bulkMatStr);
            List<String> materialStr = new List<String>();
            materialStr.add(usProd.Name);
            prf.getSAPprice(materialStr, NULL, prfliUs.Id, prfUs.Id);
            //prf.updateTierPrice();
            prf.massUpdList();
            prf.massUpdRsm();
            prf.massUpdRep();
            prf.massUpdEligible();
			prf.updateListprice();
            prf.updateRSMprice();
            prf.updateRepPrice();
            prf.updateEligiblePrice();
            prf.doUpdateOwnerValue();
            prf.getprf();
            prf.save();
            prf.sapPrice();
            prf.sapBulkInsert();

            prfUs.Price_Quote__c = pqUs.Id;
            update prfUS;
            prf.save();
            //Refresh
            System.currentPageReference().getParameters().put('itemId', usProd.Id);
            System.currentPageReference().getParameters().put('lineItemId', prfliUs.id);
            System.currentPageReference().getParameters().put('id', prfUs.Id);
            System.currentPageReference().getParameters().put('requestedPrice', '10.00');
            System.currentPageReference().getParameters().put('prfId', prfUs.id);
            prf.refresh();
            prf.removingRow();
            prf.updateType();
            prf.createQuote();
            prf.bulkrefresh();
            prf.createPDF();
            prf.createAuditPDF();
            
            
            PageReference pageRefpreApp = new PageReference('/apex/PP_ApprovalLayoutPrf?id=' + prfUs.Id);
            system.debug('Prf Page' + pageRefpreApp);
            Test.setCurrentPage(pageRefpreApp);
            
            //prf.getMargins(lineItems);
            prf.getFormatEligiblePrices(lineItems);
            prf.getFormatListPrices(lineItems);
            prf.getFormatRepPrices(lineItems);
            prf.getFormatRequestedPrices(lineItems);
            prf.getFormatRsmPrices(lineItems);
            //prf.getPriceCheck(lineItems);
            prf.getMinContract(lineItems);
            prf.getMinContractAgree(lineItems);
            prf.getMinGpo(lineItems);
            prf.getMinGpoAgree(lineItems);
            Test.stopTest();
        }//end of system run

	}//end of testPrfNoSapZa test method
    
    @isTest static void testPrfNoSapZd() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Interventional Capital');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Interventional Capital');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser){
            //Create custom settings for all sales orgs
            List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
            insert newSalesOrgs;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'LA - Latin America', 'US6020', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '11',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
            );
            insert usAcc;            
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct2('usProd10', 'US60', '20', '40');
            insert usProd;
            Product2 usProd1 = testDataFactoryPP.createProduct2('usProd11', 'US60', '20', '40');
            insert usProd1;
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd12', 'US60', '20', '40');
            insert usProd2;
            
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
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
                       
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6020', false, 'Latin America');
            insert pqUs;
            //pqUs.Status__c = 'Approved';
            //update pqUs;
            
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            //Setup PRF Data
            //createPrf(String accId, String conId, String salesOrgKey, String bu)
            Prf__c prfUs1 = testDataFactoryPP.createPrf(usAcc.Id, con1.Id, 'US6020', 'Latin America');
            insert prfUs1;

            //Setup PQ Line Item data
            //createPrfLineItem(String prfId, String prodId)
            Prf_Line_Item__c prfliUs = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd.Id);
            insert prfliUs;
			
            Prf_Line_Item__c prfliUs1 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd1.Id);
            insert prfliUs1;
            
            Prf_Line_Item__c prfliUs2 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd2.Id);
            insert prfliUs2;
            
            prfliUs.Sales_Deal__c = ch1.Id;
            update prfliUs;
            
            prfliUs1.Sales_Deal__c = ch1.Id;
            update prfliUs1;
            
            prfliUs2.Sales_Deal__c = ch1.Id;
            update prfliUs2;
            
            Prf__c prfUs = [SELECT Id, Name, Data_Driven_Justification__c, Owner_Full_Name__c, Agreement_Type__c, Eligible_Distributor__c,GPO_Affiliation__c,
                   Current_Annual_Purchases__c, Estimated_Annual_Purchases__c, Preferred_Start_Date__c, Preferred_End_Date__c, Requisition_Date__c,
                   PRF_Name__c, Owner_Business_Unit__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,Sales_Deal__c,Valid_To__c,
                   Account__r.Id, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry,CurrencyIsoCode,Valid_From__c,
                   Account__r.SAP_Sold_To__c, Contact__r.Id, Contact__r.name, Contact__r.email, Territory__c, Territory__r.Territory_Number__c,
                   Territory__r.Territory_Name__c,Status__c, Additional_Accounts__c,Sales_Org_Key__c, LastModifiedById, LastModifiedDate, Owner_ID__c,
                   CreatedById, CreatedDate, Price_Quote__c, Price_Quote__r.Name, Price_Quote__r.Price_Quote_Name__c, Line_Count__c, Owner_Email__c,
                   Audit_Check__c, Owner_Approval_Role__c, Owner_Approval_Level__c, Approval_Level__c, Workflow_Owner_Approval_Level__c, Account__r.Account_Group__c,
                   Product_Class_Count__c, Account__r.Price_List_Type__c, Current_Approver__c, Total_Annual_Eaches__c, Approval_Flag_Rollup__c, RsmRepToggle__c,
                   OwnerId, Owner.Name, Business_Unit__c, InApproval__c, Category__c, PRF_Promotion_related__c
                   FROM PRF__c
                   WHERE id = :prfUs1.Id];
            System.debug('*** prfUs PP_Prf_Test testPrfNoSapZa *** ' + prfUs);
            //System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Prf_Line_Item__c> lineItems = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Description, Eligible_Price__c, Material_Name_Text__c,
                                      Current_Price__c, Sales_Deal_Num__c, Sales_Deal_Description__c, Condition__c, Objective_Name__c, Material_Name__r.Distribution_Channel__c,
                                      List_Price__c, Rep_Price__c, RSM_Price__c, CurrencyIsoCode, Requested_Price__c, Material_Name__r.Sales_Org__c,Director_Price__c, Floor_Price__c,
                                      Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, Product_Description__c, Material_Name__r.Transfer_Price__c, Material_Name__r.Cost_Price_Unit__c,
                                      Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Material_Name__r.Director_Price__c, Material_Name__r.Cost__c, Cost__c,
                                      Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c,Material_Name__r.SubGroup__c,
                                      Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Floor_Price__c, Material_Name__r.Brand__c, Material_Status__c,Material_Name__r.Class__c,
                                      Material_Name__r.Cost_Formula__c, Material_Name__r.ASK_Custom_Kit__c, Material_Status_Description__c, Material_Name__r.SearchableProducts__c,
                                      Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Sales_Deal__r.Pricing_Tier__c, Sales_Deal__r.Agreement_Number__c,
                                      Requested_Pricing__r.Parent_Contract_Name__c, Requested_Pricing__r.Agreement_Number__c, Requested_Pricing__r.Description__c,
                                      Material_Name__r.VP_Price__c, PRF__r.Business_Unit__c
                                      FROM PRF_Line_Item__c
                                      WHERE PRF__c =:prfUs.Id];
            System.debug('*** lineItems.size() PP_Prf_Test testPrfNoSapZa *** ' + lineItems.size() );
            
            //Start PQ stuff
            PageReference pageRefpre1 = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre1);
            Test.setCurrentPage(pageRefpre1);
    
            sales_Cockpit scp = new sales_Cockpit();
            System.currentPageReference().getParameters().put('pqid', pqUs.Id);
    
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(pqUs.id);
            Approval.ProcessResult result = Approval.process(req1);
            //End PQ stuff
            
            PageReference pageRefpre = new PageReference('/apex/PP_PRF?id=' + prfUs.Id);
            system.debug('Prf Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            //System.currentPageReference().getParameters().put('refresh', 'Yes');
			//List<PRF_Line_Item__c> lineItems = new List<PRF_Line_Item__c>();
        	//lineItems.add(prfliUs);
            //lineItems.add(prfliUs1);
            //lineItems.add(prfliUs2);
            //System.currentPageReference().getParameters().put('key', 'REP1-353535');
            //ApexPages.StandardController ctlr = new ApexPages.StandardController(prfUs);
            System.currentPageReference().getParameters().put('strProdSearch', 'usProd');
            System.currentPageReference().getParameters().put('bulkMatStr', 'usProd');
            System.currentPageReference().getParameters().put('tierPrice', '100');
            System.currentPageReference().getParameters().put('lineId', prfliUs.id);
            System.currentPageReference().getParameters().put('key', 'List');
            
            //System.currentPageReference().getParameters().put('pqid', pqUs.Id);
            PP_Prf prf = new PP_Prf();
    		//System.assertEquals('usProd', prf.strProdSearch);
            //System.assertEquals('usProd', prf.bulkMatStr);
            Test.startTest();
            List<String> materialStr = new List<String>();
            List<String> materialStr1 = new List<String>();
            List<String> materialStr2 = new List<String>();
            materialStr.add(usProd.Name);
            materialStr1.add(usProd1.Name);
            materialStr2.add(usProd2.Name);
            
            prf.getSAPprice(materialStr, NULL, prfliUs.Id, prfUs.Id);
            prf.getSAPprice(materialStr1, NULL, prfliUs1.Id, prfUs.Id);
            prf.getSAPprice(materialStr2, NULL, prfliUs2.Id, prfUs.Id);
            //prf.updateTierPrice();
            //prf.sapPrice();
            //prf.sapBulkInsert();
            Test.stopTest();
        }//end of system run

	}//end of testPrfNoSapZd test method
    
    @isTest static void testPrfNoSapElseZd() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Interventional Capital');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Interventional Capital');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser){
            //Create custom settings for all sales orgs
            List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
            insert newSalesOrgs;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'AU - Australia', 'AU1010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '11',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Customer').getRecordTypeId()
            );
            insert usAcc;            
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct2('usProd13', 'AU10', '10', '40');
            insert usProd;
            Product2 usProd1 = testDataFactoryPP.createProduct2('usProd14', 'AU10', '10', '40');
            insert usProd1;
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd15', 'AU10', '10', '40');
            insert usProd2;
            
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
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
                       
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'AU1010', false, 'Australia');
            insert pqUs;
            pqUs.Status__c = 'Approved';
            update pqUs;
            
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            //Setup PRF Data
            //createPrf(String accId, String conId, String salesOrgKey, String bu)
            Prf__c prfUs1 = testDataFactoryPP.createPrf(usAcc.Id, con1.Id, 'AU1010', 'Australia');
            insert prfUs1;

            //Setup PQ Line Item data
            //createPrfLineItem(String prfId, String prodId)
            Prf_Line_Item__c prfliUs = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd.Id);
            insert prfliUs;
			
            Prf_Line_Item__c prfliUs1 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd1.Id);
            insert prfliUs1;
            
            Prf_Line_Item__c prfliUs2 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd2.Id);
            insert prfliUs2;
            
            prfliUs.Sales_Deal__c = ch1.Id;
            update prfliUs;
            
            prfliUs1.Sales_Deal__c = ch1.Id;
            update prfliUs1;
            
            prfliUs2.Sales_Deal__c = ch1.Id;
            update prfliUs2;
            
            Prf__c prfUs = [SELECT Id, Name, Data_Driven_Justification__c, Owner_Full_Name__c, Agreement_Type__c, Eligible_Distributor__c,GPO_Affiliation__c,
                   Current_Annual_Purchases__c, Estimated_Annual_Purchases__c, Preferred_Start_Date__c, Preferred_End_Date__c, Requisition_Date__c,
                   PRF_Name__c, Owner_Business_Unit__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,Sales_Deal__c,Valid_To__c,
                   Account__r.Id, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry,CurrencyIsoCode,Valid_From__c,
                   Account__r.SAP_Sold_To__c, Contact__r.Id, Contact__r.name, Contact__r.email, Territory__c, Territory__r.Territory_Number__c,
                   Territory__r.Territory_Name__c,Status__c, Additional_Accounts__c,Sales_Org_Key__c, LastModifiedById, LastModifiedDate, Owner_ID__c,
                   CreatedById, CreatedDate, Price_Quote__c, Price_Quote__r.Name, Price_Quote__r.Price_Quote_Name__c, Line_Count__c, Owner_Email__c,
                   Audit_Check__c, Owner_Approval_Role__c, Owner_Approval_Level__c, Approval_Level__c, Workflow_Owner_Approval_Level__c, Account__r.Account_Group__c,
                   Product_Class_Count__c, Account__r.Price_List_Type__c, Current_Approver__c, Total_Annual_Eaches__c, Approval_Flag_Rollup__c, RsmRepToggle__c,
                   OwnerId, Owner.Name, Business_Unit__c, InApproval__c, Category__c, PRF_Promotion_related__c
                   FROM PRF__c
                   WHERE id = :prfUs1.Id];
            System.debug('*** prfUs PP_Prf_Test testPrfNoSapElseZd *** ' + prfUs);
            //System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Prf_Line_Item__c> lineItems = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Description, Eligible_Price__c, Material_Name_Text__c,
                                      Current_Price__c, Sales_Deal_Num__c, Sales_Deal_Description__c, Condition__c, Objective_Name__c, Material_Name__r.Distribution_Channel__c,
                                      List_Price__c, Rep_Price__c, RSM_Price__c, CurrencyIsoCode, Requested_Price__c, Material_Name__r.Sales_Org__c,Director_Price__c, Floor_Price__c,
                                      Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, Product_Description__c, Material_Name__r.Transfer_Price__c, Material_Name__r.Cost_Price_Unit__c,
                                      Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Material_Name__r.Director_Price__c, Material_Name__r.Cost__c, Cost__c,
                                      Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c,Material_Name__r.SubGroup__c,
                                      Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Floor_Price__c, Material_Name__r.Brand__c, Material_Status__c,Material_Name__r.Class__c,
                                      Material_Name__r.Cost_Formula__c, Material_Name__r.ASK_Custom_Kit__c, Material_Status_Description__c, Material_Name__r.SearchableProducts__c,
                                      Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Sales_Deal__r.Pricing_Tier__c, Sales_Deal__r.Agreement_Number__c,
                                      Requested_Pricing__r.Parent_Contract_Name__c, Requested_Pricing__r.Agreement_Number__c, Requested_Pricing__r.Description__c,
                                      Material_Name__r.VP_Price__c, PRF__r.Business_Unit__c
                                      FROM PRF_Line_Item__c
                                      WHERE PRF__c =:prfUs.Id];
            System.debug('*** lineItems.size() PP_Prf_Test testPrfNoSapElseZd *** ' + lineItems.size() );
            
            //Start PQ stuff
            PageReference pageRefpre1 = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre1);
            Test.setCurrentPage(pageRefpre1);
    
            sales_Cockpit scp = new sales_Cockpit();
            System.currentPageReference().getParameters().put('pqid', pqUs.Id);
    
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(pqUs.id);
            Approval.ProcessResult result = Approval.process(req1);
            //End PQ stuff
            
            PageReference pageRefpre = new PageReference('/apex/PP_PRF?id=' + prfUs.Id);
            system.debug('Prf Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            //System.currentPageReference().getParameters().put('refresh', 'Yes');
			//List<PRF_Line_Item__c> lineItems = new List<PRF_Line_Item__c>();
        	//lineItems.add(prfliUs);
            //lineItems.add(prfliUs1);
            //lineItems.add(prfliUs2);
            //System.currentPageReference().getParameters().put('key', 'REP1-353535');
            //ApexPages.StandardController ctlr = new ApexPages.StandardController(prfUs);
            System.currentPageReference().getParameters().put('strProdSearch', 'usProd');
            System.currentPageReference().getParameters().put('bulkMatStr', 'usProd');
            System.currentPageReference().getParameters().put('tierPrice', '100');
            System.currentPageReference().getParameters().put('lineId', prfliUs.id);
            System.currentPageReference().getParameters().put('key', 'List');
            
            //System.currentPageReference().getParameters().put('pqid', pqUs.Id);
            PP_Prf prf = new PP_Prf();
    		//System.assertEquals('usProd', prf.strProdSearch);
            //System.assertEquals('usProd', prf.bulkMatStr);
            Test.startTest();
            List<String> materialStr = new List<String>();
            List<String> materialStr1 = new List<String>();
            List<String> materialStr2 = new List<String>();
            materialStr.add(usProd.Name);
            materialStr1.add(usProd1.Name);
            materialStr2.add(usProd2.Name);
            
            prf.getSAPprice(materialStr, NULL, prfliUs.Id, prfUs.Id);
            prf.getSAPprice(materialStr1, NULL, prfliUs1.Id, prfUs.Id);
            prf.getSAPprice(materialStr2, NULL, prfliUs2.Id, prfUs.Id);
            //prf.updateTierPrice();
            //prf.sapPrice();
            //prf.sapBulkInsert();
            Test.stopTest();
        }//end of system run

	}//end of testPrfNoSapElseZd test method
    
    @isTest static void testPrfSapZd() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Interventional Capital');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Interventional Capital');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser){
            //Create custom settings for all sales orgs
            List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
            insert newSalesOrgs;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','03');
            insert usACC;            
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct2('usProd16', 'US60', '10', '40');
            insert usProd;
            Product2 usProd1 = testDataFactoryPP.createProduct2('usProd17', 'US60', '10', '40');
            insert usProd1;
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd18', 'US60', '10', '40');
            insert usProd2;
            
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
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
                       
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUs;
            //pqUs.Status__c = 'Approved';
            //update pqUs;
            
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            //Setup PRF Data
            //createPrf(String accId, String conId, String salesOrgKey, String bu)
            Prf__c prfUs1 = testDataFactoryPP.createPrf(usAcc.Id, con1.Id, 'US6010', 'Anesthesia');
            insert prfUs1;

            //Setup PQ Line Item data
            //createPrfLineItem(String prfId, String prodId)
            Prf_Line_Item__c prfliUs = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd.Id);
            insert prfliUs;
			
            Prf_Line_Item__c prfliUs1 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd1.Id);
            insert prfliUs1;
            
            Prf_Line_Item__c prfliUs2 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd2.Id);
            insert prfliUs2;
            
            prfliUs.Sales_Deal__c = ch1.Id;
            update prfliUs;
            
            prfliUs1.Sales_Deal__c = ch1.Id;
            update prfliUs1;
            
            prfliUs2.Sales_Deal__c = ch1.Id;
            update prfliUs2;
            
            Prf__c prfUs = [SELECT Id, Name, Data_Driven_Justification__c, Owner_Full_Name__c, Agreement_Type__c, Eligible_Distributor__c,GPO_Affiliation__c,
                   Current_Annual_Purchases__c, Estimated_Annual_Purchases__c, Preferred_Start_Date__c, Preferred_End_Date__c, Requisition_Date__c,
                   PRF_Name__c, Owner_Business_Unit__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,Sales_Deal__c,Valid_To__c,
                   Account__r.Id, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry,CurrencyIsoCode,Valid_From__c,
                   Account__r.SAP_Sold_To__c, Contact__r.Id, Contact__r.name, Contact__r.email, Territory__c, Territory__r.Territory_Number__c,
                   Territory__r.Territory_Name__c,Status__c, Additional_Accounts__c,Sales_Org_Key__c, LastModifiedById, LastModifiedDate, Owner_ID__c,
                   CreatedById, CreatedDate, Price_Quote__c, Price_Quote__r.Name, Price_Quote__r.Price_Quote_Name__c, Line_Count__c, Owner_Email__c,
                   Audit_Check__c, Owner_Approval_Role__c, Owner_Approval_Level__c, Approval_Level__c, Workflow_Owner_Approval_Level__c, Account__r.Account_Group__c,
                   Product_Class_Count__c, Account__r.Price_List_Type__c, Current_Approver__c, Total_Annual_Eaches__c, Approval_Flag_Rollup__c, RsmRepToggle__c,
                   OwnerId, Owner.Name, Business_Unit__c, InApproval__c, Category__c, PRF_Promotion_related__c
                   FROM PRF__c
                   WHERE id = :prfUs1.Id];
            System.debug('*** prfUs PP_Prf_Test testPrfSapZd *** ' + prfUs);
            //System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Prf_Line_Item__c> lineItems = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Description, Eligible_Price__c, Material_Name_Text__c,
                                      Current_Price__c, Sales_Deal_Num__c, Sales_Deal_Description__c, Condition__c, Objective_Name__c, Material_Name__r.Distribution_Channel__c,
                                      List_Price__c, Rep_Price__c, RSM_Price__c, CurrencyIsoCode, Requested_Price__c, Material_Name__r.Sales_Org__c,Director_Price__c, Floor_Price__c,
                                      Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, Product_Description__c, Material_Name__r.Transfer_Price__c, Material_Name__r.Cost_Price_Unit__c,
                                      Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Material_Name__r.Director_Price__c, Material_Name__r.Cost__c, Cost__c,
                                      Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c,Material_Name__r.SubGroup__c,
                                      Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Floor_Price__c, Material_Name__r.Brand__c, Material_Status__c,Material_Name__r.Class__c,
                                      Material_Name__r.Cost_Formula__c, Material_Name__r.ASK_Custom_Kit__c, Material_Status_Description__c, Material_Name__r.SearchableProducts__c,
                                      Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Sales_Deal__r.Pricing_Tier__c, Sales_Deal__r.Agreement_Number__c,
                                      Requested_Pricing__r.Parent_Contract_Name__c, Requested_Pricing__r.Agreement_Number__c, Requested_Pricing__r.Description__c,
                                      Material_Name__r.VP_Price__c, PRF__r.Business_Unit__c
                                      FROM PRF_Line_Item__c
                                      WHERE PRF__c =:prfUs.Id];
            System.debug('*** lineItems.size() PP_Prf_Test testPrfSapZd *** ' + lineItems.size() );
            
            //Start PQ stuff
            PageReference pageRefpre1 = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre1);
            Test.setCurrentPage(pageRefpre1);
    
            sales_Cockpit scp = new sales_Cockpit();
            System.currentPageReference().getParameters().put('pqid', pqUs.Id);
    
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(pqUs.id);
            Approval.ProcessResult result = Approval.process(req1);
            //End PQ stuff
            
            PageReference pageRefpre = new PageReference('/apex/PP_PRF?id=' + prfUs.Id);
            system.debug('Prf Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            //System.currentPageReference().getParameters().put('refresh', 'Yes');
			//List<PRF_Line_Item__c> lineItems = new List<PRF_Line_Item__c>();
        	//lineItems.add(prfliUs);
            //lineItems.add(prfliUs1);
            //lineItems.add(prfliUs2);
            //System.currentPageReference().getParameters().put('key', 'REP1-353535');
            //ApexPages.StandardController ctlr = new ApexPages.StandardController(prfUs);
            System.currentPageReference().getParameters().put('strProdSearch', 'usProd');
            System.currentPageReference().getParameters().put('bulkMatStr', 'usProd');
            System.currentPageReference().getParameters().put('tierPrice', '100');
            System.currentPageReference().getParameters().put('lineId', prfliUs.id);
            System.currentPageReference().getParameters().put('key', 'List');
            
            //System.currentPageReference().getParameters().put('pqid', pqUs.Id);
            PP_Prf prf = new PP_Prf();
    		//System.assertEquals('usProd', prf.strProdSearch);
            //System.assertEquals('usProd', prf.bulkMatStr);
            Test.startTest();
            List<String> materialStr = new List<String>();
            List<String> materialStr1 = new List<String>();
            List<String> materialStr2 = new List<String>();
            materialStr.add(usProd.Name);
            materialStr1.add(usProd1.Name);
            materialStr2.add(usProd2.Name);
            
            prf.getSAPprice(materialStr, NULL, prfliUs.Id, prfUs.Id);
            prf.getSAPprice(materialStr1, NULL, prfliUs1.Id, prfUs.Id);
            prf.getSAPprice(materialStr2, NULL, prfliUs2.Id, prfUs.Id);
            //prf.updateTierPrice();
            //prf.sapPrice();
            //prf.sapBulkInsert();
            Test.stopTest();
        }//end of system run

	}//end of testPrfSapZd test method
    
    @isTest static void testPrfSap00Zd() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Interventional Capital');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Interventional Capital');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser){
            //Create custom settings for all sales orgs
            List<Sales_Orgs__c> newSalesOrgs = testDataFactoryPP.createSalesOrgsAll();
            insert newSalesOrgs;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','999999','03');
            insert usACC;            
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct2('usProd19', 'US60', '10', '40');
            insert usProd;
            Product2 usProd1 = testDataFactoryPP.createProduct2('usProd20', 'US60', '10', '40');
            insert usProd1;
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd21', 'US60', '10', '40');
            insert usProd2;
            
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
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
                       
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUs;
            //pqUs.Status__c = 'Approved';
            //update pqUs;
            
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            insert pqliUs1;
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
            
            //Setup PRF Data
            //createPrf(String accId, String conId, String salesOrgKey, String bu)
            Prf__c prfUs1 = testDataFactoryPP.createPrf(usAcc.Id, con1.Id, 'US6010', 'Anesthesia');
            insert prfUs1;

            //Setup PQ Line Item data
            //createPrfLineItem(String prfId, String prodId)
            Prf_Line_Item__c prfliUs = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd.Id);
            insert prfliUs;
			
            Prf_Line_Item__c prfliUs1 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd1.Id);
            insert prfliUs1;
            
            Prf_Line_Item__c prfliUs2 = testDataFactoryPP.createPrfLineItem(prfUs1.Id, usProd2.Id);
            insert prfliUs2;
            
            prfliUs.Sales_Deal__c = ch1.Id;
            update prfliUs;
            
            prfliUs1.Sales_Deal__c = ch1.Id;
            update prfliUs1;
            
            prfliUs2.Sales_Deal__c = ch1.Id;
            update prfliUs2;
            
            Prf__c prfUs = [SELECT Id, Name, Data_Driven_Justification__c, Owner_Full_Name__c, Agreement_Type__c, Eligible_Distributor__c,GPO_Affiliation__c,
                   Current_Annual_Purchases__c, Estimated_Annual_Purchases__c, Preferred_Start_Date__c, Preferred_End_Date__c, Requisition_Date__c,
                   PRF_Name__c, Owner_Business_Unit__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,Sales_Deal__c,Valid_To__c,
                   Account__r.Id, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry,CurrencyIsoCode,Valid_From__c,
                   Account__r.SAP_Sold_To__c, Contact__r.Id, Contact__r.name, Contact__r.email, Territory__c, Territory__r.Territory_Number__c,
                   Territory__r.Territory_Name__c,Status__c, Additional_Accounts__c,Sales_Org_Key__c, LastModifiedById, LastModifiedDate, Owner_ID__c,
                   CreatedById, CreatedDate, Price_Quote__c, Price_Quote__r.Name, Price_Quote__r.Price_Quote_Name__c, Line_Count__c, Owner_Email__c,
                   Audit_Check__c, Owner_Approval_Role__c, Owner_Approval_Level__c, Approval_Level__c, Workflow_Owner_Approval_Level__c, Account__r.Account_Group__c,
                   Product_Class_Count__c, Account__r.Price_List_Type__c, Current_Approver__c, Total_Annual_Eaches__c, Approval_Flag_Rollup__c, RsmRepToggle__c,
                   OwnerId, Owner.Name, Business_Unit__c, InApproval__c, Category__c, PRF_Promotion_related__c
                   FROM PRF__c
                   WHERE id = :prfUs1.Id];
            System.debug('*** prfUs PP_Prf_Test testPrfSapZd *** ' + prfUs);
            //System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Prf_Line_Item__c> lineItems = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Description, Eligible_Price__c, Material_Name_Text__c,
                                      Current_Price__c, Sales_Deal_Num__c, Sales_Deal_Description__c, Condition__c, Objective_Name__c, Material_Name__r.Distribution_Channel__c,
                                      List_Price__c, Rep_Price__c, RSM_Price__c, CurrencyIsoCode, Requested_Price__c, Material_Name__r.Sales_Org__c,Director_Price__c, Floor_Price__c,
                                      Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, Product_Description__c, Material_Name__r.Transfer_Price__c, Material_Name__r.Cost_Price_Unit__c,
                                      Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Material_Name__r.Director_Price__c, Material_Name__r.Cost__c, Cost__c,
                                      Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c,Material_Name__r.SubGroup__c,
                                      Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Floor_Price__c, Material_Name__r.Brand__c, Material_Status__c,Material_Name__r.Class__c,
                                      Material_Name__r.Cost_Formula__c, Material_Name__r.ASK_Custom_Kit__c, Material_Status_Description__c, Material_Name__r.SearchableProducts__c,
                                      Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Sales_Deal__r.Pricing_Tier__c, Sales_Deal__r.Agreement_Number__c,
                                      Requested_Pricing__r.Parent_Contract_Name__c, Requested_Pricing__r.Agreement_Number__c, Requested_Pricing__r.Description__c,
                                      Material_Name__r.VP_Price__c, PRF__r.Business_Unit__c
                                      FROM PRF_Line_Item__c
                                      WHERE PRF__c =:prfUs.Id];
            System.debug('*** lineItems.size() PP_Prf_Test testPrfSapZd *** ' + lineItems.size() );
            
            //Start PQ stuff
            PageReference pageRefpre1 = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre1);
            Test.setCurrentPage(pageRefpre1);
    
            sales_Cockpit scp = new sales_Cockpit();
            System.currentPageReference().getParameters().put('pqid', pqUs.Id);
    
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(pqUs.id);
            Approval.ProcessResult result = Approval.process(req1);
            //End PQ stuff
            
            PageReference pageRefpre = new PageReference('/apex/PP_PRF?id=' + prfUs.Id);
            system.debug('Prf Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            //System.currentPageReference().getParameters().put('refresh', 'Yes');
			//List<PRF_Line_Item__c> lineItems = new List<PRF_Line_Item__c>();
        	//lineItems.add(prfliUs);
            //lineItems.add(prfliUs1);
            //lineItems.add(prfliUs2);
            //System.currentPageReference().getParameters().put('key', 'REP1-353535');
            //ApexPages.StandardController ctlr = new ApexPages.StandardController(prfUs);
            System.currentPageReference().getParameters().put('strProdSearch', 'usProd');
            System.currentPageReference().getParameters().put('bulkMatStr', 'usProd');
            System.currentPageReference().getParameters().put('tierPrice', '100');
            System.currentPageReference().getParameters().put('lineId', prfliUs.id);
            System.currentPageReference().getParameters().put('key', 'List');
            
            //System.currentPageReference().getParameters().put('pqid', pqUs.Id);
            PP_Prf prf = new PP_Prf();
    		//System.assertEquals('usProd', prf.strProdSearch);
            //System.assertEquals('usProd', prf.bulkMatStr);
            Test.startTest();
            List<String> materialStr = new List<String>();
            List<String> materialStr1 = new List<String>();
            List<String> materialStr2 = new List<String>();
            materialStr.add(usProd.Name);
            materialStr1.add(usProd1.Name);
            materialStr2.add(usProd2.Name);
            
            prf.getSAPprice(materialStr, NULL, prfliUs.Id, prfUs.Id);
            prf.getSAPprice(materialStr1, NULL, prfliUs1.Id, prfUs.Id);
            prf.getSAPprice(materialStr2, NULL, prfliUs2.Id, prfUs.Id);
            //prf.updateTierPrice();
            //prf.sapPrice();
            //prf.sapBulkInsert();
            Test.stopTest();
        }//end of system run

	}//end of testPrfSap00Zd test method
    
}//end of class