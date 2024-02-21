/*********************************************************************
* Description      : This class is used for Testing the Contract Renewal Process
* Coverted Classes : Contract_Renewal_Item_Helper_Class, Contract_Renwal_Rep, Contract_Renwal_Controller, Contract_Renewal_Accounts
                                         Build_Contract_Renewals_Batch, Build_Contract_Renewal_Items_Batch, contract_Renewal_Material_Analysis
                                         Build_Contract_Customer_Sales_Batch
* Author(s)        : Dun Silver
**********************************************************************/
@isTest
public class Contract_Renewal_Test {

    @testSetup
    static void createData() {
        //create a user
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
                timezonesidkey='America/New_York',
                username='unit.test@unit.teleflex.com',
                Business_Unit__c = 'Vascular'
        );
        //insert user
        try{
            insert u;
        }
        catch(Exception e){
            System.debug('An error happened when inserting test user: ' + e.getMessage() );
        }
        //end of User

        //start of create Contracts Team custom setting
        Contracts_Team__c settings = Contracts_Team__c.getOrgDefaults();
        settings.Id__c = u.Id;
        settings.Name = 'Adam Franks';
        insert settings;
        //end of create Contracts Team custom setting

          BaseQuotaException__c bqe = new BaseQuotaException__c(
              Name = 'territory_user_maintenance',
              IsException__c = TRUE
          );
          insert bqe;
        
        //start run as user
        System.runAs(u){
            List<Product2> prods = new List<Product2>();
            List<Account> accts = new List<Account>();
            List<Contract_Header__c> heads = new List<Contract_Header__c>();
            List<Contract_Renewal__c> renews = new List<Contract_Renewal__c>();
            List<Contract_Renewal_Item__c> items = new List<Contract_Renewal_Item__c>();
            List<Contract_Material__c> mats = new List<Contract_Material__c>();
            List<Contract_Customer__c> custs = new List<Contract_Customer__c>();
            //loop to create Accounts
            for(Integer i=0;i<10;i++){
                Account a = new Account(
                    Name = 'TestAccount'+i,
                    SAP_Sold_To__c = '10205'+i,
                    Account_Group__c = 'Z002',
                    zBlock__c = '00'
                );
                accts.add(a);
            }

            try{
                insert accts;
            }
            catch(Exception e){
                System.debug('An error happened when inserting test accounts: ' + e.getMessage() );
            }

            System.debug('*** accts.size() *** ' + accts.size() );
            //end of loop to create Accounts

            //loop to create Contract_Header__c
            for(Integer i=0;i<10;i++){
                system.debug('Creating Contract Headers');
                Contract_Header__c ch = new Contract_Header__c(
                    Name = '5000906'+i,
                    Agreement_Number__c = '5000906'+i,
                    Description__c = 'Test Description',
                    Owner__c = '12331'+i,
                    GPO_Contract_Ref__c = '',
                    Valid_From__c = Date.Today(),
                    Valid_To__c = Date.Today() + 30
                );
                heads.add(ch);
            }

            try{
                insert heads;
            }
            catch(Exception e){
                System.debug('An error happened when inserting test Contract Headers: ' + e.getMessage() );
            }
            //end of loop to create Contract_Header__c

            //loop to create Contract_Customer__c
            for(Integer i=0;i<10;i++){
                system.debug('Creating Contract Customers');
                Contract_Customer__c cc = new Contract_Customer__c(
                    Name = '50009064',
                    Agreement__c = heads[0].Id,
                    Account__c = accts[0].Id,
                    SAP_Code__c = '102059',
                    Sales_Org__c = 'US10',
                    Valid_From__c = Date.Today(),
                    Valid_To__c = Date.Today() + 30,
                    Distribution_Channel__c = '10',
                    Condition__c = 'XNAF'
                );
                custs.add(cc);
            }

            try{
                insert custs;
            }
            catch(Exception e){
                System.debug('An error happened when inserting test Contract Customers: ' + e.getMessage() );
            }
            //end of loop to create Contract_Customer__c

            //loop to create Contract_Renewal__c
            for(Integer i=0;i<10;i++){
                system.debug('Creating Contract Renewals');
                Contract_Renewal__c cr = new Contract_Renewal__c(
                    OwnerId = u.Id,
                    Agreement_Number__c = '5555555'+i,
                    Business_Unit__c = u.Business_Unit__c,
                    Contract_Description__c = 'This is a test Contract ' + i,
                    Contract_Header__c = heads[0].Id,
                    Contracts_Rep__c = u.Id,
                    Distribution_Channel__c = '10',
                    Account__c = accts[0].Id,
                    SAP_Code__c = accts[0].SAP_Code__c,
                    Sales_Rep__c = u.Id,
                    Sales_Org__c = 'US10',
                    Valid_From__c = Date.Today(),
                    Valid_To__c = Date.Today() + 1000
                );
                renews.add(cr);
            }

            try{
                Test.startTest();
                insert renews;
                Test.stopTest();
            }
            catch(Exception e){
                System.debug('An error happened when inserting test Contract Renewals: ' + e.getMessage() );
            }
            System.debug('*** renews.size() *** ' + renews.size() );

            List<Contract_Renewal__c> conList = [SELECT Id FROM Contract_Renewal__c];
            System.assertEquals(10, conList.size());
            //end of loop to create Contract_Renewal__c

            //loop to create Product2
            for(Integer i=0;i<10;i++){
                system.debug('Creating Products');
                Product2 prod = new Product2(
                    Name = '35353'+i,
                    ProductCode= '35353'+i,
                    UOM__c='CS',
                    Each_per_Case__c=5,
                    Material_Status__c='MTS',
                    Material_Status_Numeric__c='30',
                    Family = 'Hardware',
                    Material__c='35353'+i,
                    Brand_Name__c='LMA',
                    Buom__c='EA',
                    Class__c='Anesthesia',
                    Cost__c=11587.40,
                    Cost_Price_Unit__c=1000,
                    Division__c='60',
                    Description='TRANSRADIAL ACCESS TRAY',
                    Group__c='Interventional',
                    SubGroup__c = 'TransRadial Access',
                    Qty_Sales_Unit__c=5,
                    Sales_Unit__c='CS',
                    List_Price__c=24.00,
                    Rep_Price__c=350.00,
                    Floor_Price__c=25.00,
                    Transfer_Price__c = 1000.00,
                    Sales_Org__c = 'US10',
                    Distribution_Channel__c = '10',
                    Sales_Org_Key__c = 'US103010',
                    Material_Key__c = '35353'+i+'-US30-10',
                    RSM_Price__c=330.00
                );
                prods.add(prod);
            }

            try{
                insert prods;
            }
            catch(Exception e){
                System.debug('An error happened when inserting test Products: ' + e.getMessage() );
            }
            System.debug('*** prods.size() *** ' + prods.size() );
            //end of loop to create Product2

            //prods[0].Group__c = 'Airway';
            //prods[1].Group__c = 'Regional Anesthesia';
            //prods[2].Brand_Name__c = 'LMA';
            //prods[3].Name = 'MAD3000';
            //prods[4].Group__c = '01';
            //prods[5].Name = 'MAD3000';
            //prods[6].Class__c = 'Interventional';
            //prods[7].Class__c = 'Cardiac';
            //prods[8].Class__c = 'Access';
            //prods[8].Group__c = 'Closure';
            //prods[9].Group__c = 'Polymer';
            //prods[9].SubGroup__c = 'Auto';

            //update prods;

            //loop to create Contract_Material__c
            for(Integer i=0;i<10;i++){
                system.debug('Creating Contract Materials');
                Contract_Material__c cm = new Contract_Material__c(
                        Name = '5000906'+i,
                        Agreement__c = heads[0].Id,
                        Material_Name__c = '35353'+i,
                        Product__c = prods[i].Id,
                        Sales_Org__c = 'US10',
                        Valid_From__c = Date.Today(),
                        //Valid_To__c = Date.Today() + 1000,
                        Valid_To__c = Date.Today() + 30,
                        Material_Division__c = '10',
                        Price__c = 380.00
                );
                mats.add(cm);
            }

            try{
                insert mats;
            }
            catch(Exception e){
                System.debug('An error happened when inserting test Contract Materials: ' + e.getMessage() );
            }
            //end of loop to create Contract_Material__c


            //loop to create Contract_Renewal_Item__c
            for(Integer i=0;i<10;i++){
                system.debug('Creating Contract Renewal Items');
                Contract_Renewal_Item__c cri = new Contract_Renewal_Item__c(
                    Contract_Material__c = mats[i].Id,
                    Contract_Renewal__c = renews[0].Id,
                    Current_Price__c = prods[i].List_Price__c,
                    Default_Per_Increase__c = 0.04,
                    Default_Renewal_Price__c = prods[i].List_Price__c,
                    Product__c = prods[i].Id,
                    Product_Floor_Price__c = prods[i].Floor_Price__c,
                    Product_List_Price__c = prods[i].List_Price__c,
                    Valid_From__c = Date.Today(),
                    Valid_To__c = Date.Today() + 1000
                );
                items.add(cri);
            }

            try{
                insert items;
            }
            catch(Exception e){
                System.debug('An error happened when inserting test Contract Renewal Items: ' + e.getMessage() );
            }
            //end of loop to create Contract_Renewal_Item__c

            // Start the Contract Renewal Batch and Schedule Additions - ESC - 08Jan2017
            //account acct = [SELECT Id, SAP_Sold_To__c FROM Account LIMIT 1];
            //product2 prod = [SELECT Id, Material_Key__c FROM Product2 LIMIT 1];
            Contract_Header__c chTest = [SELECT Id, Name FROM Contract_Header__c LIMIT 1];

            Invoiced_Sales__c is1 = new Invoiced_Sales__c(
                Account__c = accts[0].id,
                Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Product__c = prods[0].Id,
                Sales_Deal__c = chTest.Name,
                Contract_Header__c = chTest.Id,
                Sales_Org__c = 'US10',
                Sales__c = 321.00,
                Date__c = Date.Today() - 45,
                SAP_Code__c = accts[0].SAP_Sold_To__c,
//                Territory__c = tm.Id,
                Territory_Number__c = '700123'
            );
            insert is1;

            // End ESC Edits

        }
        //end of system run
    }//end of createData

    //start testing Contract_Renewal_Home
    @isTest
    static void renewalHomeTest() {

            system.debug('*** Starting renewalHomeTest ***');

            List<Contract_Renewal__c> crTest = [SELECT Id, Agreement_Number__c FROM Contract_Renewal__c];
            System.debug('*** crTest.size() *** ' + crTest.size() );

            List<Contracts_Team__c> cTeam = [SELECT Id__c, Name FROM Contracts_Team__c];
            System.debug('*** cTeam.size() *** ' + cTeam.size() );

            Test.startTest();
            PageReference pageRefpre = new PageReference('/apex/Contract_Renewal_Home');
            System.debug('*** Contract_Renewal_Home VFpage ***' + pageRefpre);
            Test.setCurrentPage(pageRefpre);

            //System.currentPageReference().getParameters().put('contractId', crTest.Id);

            ApexPages.StandardController ctlr = new ApexPages.StandardController(crTest[0]);
            Contract_Renewal_Controller crc = new Contract_Renewal_Controller(ctlr);

            boolean fetchMoreRecords = crc.fetchMoreRecords;
            crc.fname = crTest[0].Agreement_Number__c;

            Contract_Renewal_Controller.getCanView();
            Contract_Renewal_Controller.getDirectorView();
            //Contract_Renewal_Controller.getContract();
            //Contract_Renewal_Controller.getMaterials();
            //Contract_Renewal_Controller.getMoreMaterials();
            Contract_Renewal_Controller.getContractsTeam();
            Contract_Renewal_Controller.getContractList();
            Contract_Renewal_Controller.getContractListRep();

            //handle Remote Actions
            Contract_Renewal_Controller.getContractByStatus('Do Not Renew');
            Contract_Renewal_Controller.viewByContractsRep(cTeam[0].Id__c);
            Contract_Renewal_Controller.updateContractsRep(crTest[0].Id,cTeam[0].Id__c);
            Contract_Renewal_Controller.updateContractStatus(crTest[0].Id,'Do Not Renew');
            Test.stopTest();
    }
    //end of testing Contract_Renewal_Home


    //start testing Contract_Renewal_Materials
    @isTest
    static void renewalMaterialsTest() {
            system.debug('*** Starting renewalMaterialsTest ***');

            Contract_Renewal__c crTest = [SELECT Id, Agreement_Number__c
                                                                        FROM Contract_Renewal__c
                                                                        ORDER BY Agreement_Number__c ASC LIMIT 1];
            System.debug('*** crTest *** ' + crTest );
            //String renewId = crTest.Id;
            List<Contract_Renewal_Item__c> criTest = [SELECT Id, Contract_Renewal__c, Requested_Increase__c, Requested_Renewal_Price__c,
                                                                                                Material_Line_Note__c, Default_Renewal_Price__c
                                                                                                FROM Contract_Renewal_Item__c];
            System.debug('*** criTest.size() *** ' + criTest.size() );

            List<Id> criIds = new List<Id>();
            for(Contract_Renewal_Item__c curr : criTest){
                criIds.add(curr.Id);
            }

            Test.startTest();
            PageReference pageRefpre = new PageReference('/apex/Contract_Renewal_Materials?contractId='+crTest.Id);
            System.debug('*** Contract_Renewal_Materials VFpage ***' + pageRefpre);
            Test.setCurrentPage(pageRefpre);

            System.currentPageReference().getParameters().put('contractId', crTest.Id);

            ApexPages.StandardController ctlr = new ApexPages.StandardController(crTest);
            Contract_Renewal_Controller crc = new Contract_Renewal_Controller(ctlr);

            Contract_Renewal_Controller.getContract();
            crc.getMaterials();
            Contract_Renewal_Controller.getMoreMaterials(crTest.Id, criIds);
            Contract_Renewal_Controller.setContractStatus(crTest.Id,'Sales Review');
            Contract_Renewal_Controller.updateNewNumber(crTest.Id,'57777777');
            Contract_Renewal_Controller.materialLineNote(criTest[0].Id,'Do Not Renew');
            Contract_Renewal_Controller.updatePricePercent(criTest[0].Id,criTest[0].Requested_Increase__c,criTest[0].Requested_Renewal_Price__c);
            Contract_Renewal_Controller.updateNotes(crTest.Id,'This is a test note.');
            Contract_Renewal_Controller.updateDetails(criTest[0].Id,'This is a test note.');
            Contract_Renewal_Controller.updateDefaultPricePercent(criTest[0].Id,100.00,5.0);
            Contract_Renewal_Controller.updateContractRecom(criTest[0].Id,'Renew');
            Contract_Renewal_Controller.submitApproval(crTest.Id);
            Test.stopTest();
    }
    //end of testing Contract_Renewal_Materials

    //start testing Contract_Renewal_Rep
    @isTest
    static void renewalRepTest() {
            system.debug('*** Starting renewalRepTest ***');

            Contract_Renewal__c crTest = [SELECT Id, Agreement_Number__c FROM Contract_Renewal__c LIMIT 1];

            User oUser = [SELECT Id FROM User WHERE alias = 'uflex76' LIMIT 1];

            Test.startTest();
            PageReference pageRefpre = new PageReference('/apex/Contract_Renewal_Rep?contractId='+crTest.Id);
            System.debug('*** Contract_Renewal_Rep VFpage ***' + pageRefpre);
            Test.setCurrentPage(pageRefpre);

            System.currentPageReference().getParameters().put('uId', oUser.Id);

            ApexPages.StandardController ctlr = new ApexPages.StandardController(crTest);
            Contract_Renewal_Rep crr = new Contract_Renewal_Rep(ctlr);

            crr.getUserList();
            crr.setNewOwner();
            Test.stopTest();
    }
    //end of testing Contract_Renewal_Rep

    // Start Contract Renewal Build batch and scheduler classes
    @isTest static void testScheduleClasses() {

        Test.startTest();
        String CRON_EXP = '0 0 0 15 3 ?';
        String jobId;

        jobId = System.schedule('Build_Contract_Renewals_Scheduler', CRON_EXP, new Build_Contract_Renewals_Scheduler());

        //Build_Product_Sales_Batch bpsb = new Build_Product_Sales_Batch();
        //Database.executeBatch(bpsb);

        Test.stopTest();
    }

    @isTest static void testVFPages() {

        Contract_Renewal__c cr = [SELECT Id, Agreement_Number__c
                                  FROM Contract_Renewal__c
                                  LIMIT 1];
        Id acctId = [SELECT Id FROM Account WHERE SAP_Sold_To__c = '102059'].Id;

        PageReference pageRef = new PageReference('/apex/Contract_Renewal_Accounts?id=' + cr.id);
        Test.setCurrentPage(pageRef);

        Contract_Renewal_Accounts cra = new Contract_Renewal_Accounts();
        string fname = cra.fname;
        string cid = cra.cid;

        pageRef = new PageReference('/apex/contract_Renewal_Material_Analysis?id=' + cr.id + '&aid=' + acctId);
        Test.setCurrentPage(pageRef);

        contract_Renewal_Material_Analysis crma = new contract_Renewal_Material_Analysis();


    }


        //start testing Contract_Renewal_Items_Helper_Class
        @isTest
        static void renewalHelperTest() {
                system.debug('*** Starting renewalMaterialsTest ***');

                Contract_Renewal__c crTest = [SELECT Id, Agreement_Number__c FROM Contract_Renewal__c LIMIT 1];

                List<Contract_Renewal_Item__c> criTest = [SELECT Id, Contract_Renewal__c, Requested_Increase__c, Requested_Renewal_Price__c,
                                                                                                    Material_Line_Note__c, Default_Renewal_Price__c
                                                                                                    FROM Contract_Renewal_Item__c
                                                                                                    WHERE Contract_Renewal__c =:crTest.Id];
                System.debug('*** criTest.size() *** ' + criTest.size() );

                List<Id> criIds = new List<Id>();
                for(Contract_Renewal_Item__c curr : criTest){
                    criIds.add(curr.Id);
                }

                Test.startTest();
                PageReference pageRefpre = new PageReference('/apex/Contract_Renewal_Materials?contractId='+crTest.Id);
                System.debug('*** Contract_Renewal_Materials VFpage ***' + pageRefpre);
                Test.setCurrentPage(pageRefpre);

                System.currentPageReference().getParameters().put('contractId', crTest.Id);

                ApexPages.StandardController ctlr = new ApexPages.StandardController(crTest);
                //Contract_Renewal_Item_Helper_Class crh = new Contract_Renewal_Item_Helper_Class();

                Contract_Renewal_Item_Helper_Class.pricingLogicCheck(criTest);
                Contract_Renewal_Item_Helper_Class.pricingLogic(50.00);
                Contract_Renewal_Item_Helper_Class.roundingToDot50(50.00);
                Contract_Renewal_Item_Helper_Class.roundingToDollar(50.00);
                Contract_Renewal_Item_Helper_Class.roundingTo2Dollar(50.00);
                Contract_Renewal_Item_Helper_Class.roundingTo3Dollar(50.00);
                Contract_Renewal_Item_Helper_Class.roundingTo4Dollar(50.00);
                Contract_Renewal_Item_Helper_Class.roundingTo5Dollar(50.00);
                Contract_Renewal_Item_Helper_Class.roundingTo10Dollar(50.00);
                Contract_Renewal_Item_Helper_Class.roundingTo12Dollar(50.00);
                Contract_Renewal_Item_Helper_Class.roundingTo18Dollar(50.00);
                Contract_Renewal_Item_Helper_Class.roundingTo25Dollar(50.00);
                Contract_Renewal_Item_Helper_Class.roundingTo35Dollar(50.00);
                Contract_Renewal_Item_Helper_Class.airwaysPricing(50.00);
                Contract_Renewal_Item_Helper_Class.regionalAnesPricing(50.00);
                Contract_Renewal_Item_Helper_Class.madLmaPricing(50.00);
                Contract_Renewal_Item_Helper_Class.accessClosure(50.00);
                Contract_Renewal_Item_Helper_Class.autoPolymer(50.00);
                Contract_Renewal_Item_Helper_Class.cholangiography(50.00);
                Contract_Renewal_Item_Helper_Class.conHarvesting(50.00);
                Contract_Renewal_Item_Helper_Class.metalClip105(50.00);
                Contract_Renewal_Item_Helper_Class.metalClip65(50.00);
                Contract_Renewal_Item_Helper_Class.miniLap(50.00);
                Contract_Renewal_Item_Helper_Class.percuvance(50.00);
                Contract_Renewal_Item_Helper_Class.skinStapling(50.00);
                Contract_Renewal_Item_Helper_Class.sterStorageTray(50.00);
                Contract_Renewal_Item_Helper_Class.memobag(50.00);
                Contract_Renewal_Item_Helper_Class.metalAppliers(50.00);
                Contract_Renewal_Item_Helper_Class.trocars(50.00);
                Contract_Renewal_Item_Helper_Class.vascularProds(50.00);
                Contract_Renewal_Item_Helper_Class.interventionalProds(50.00);
                Test.stopTest();
        }
        //end of testing Contract_Renewal_Items_Helper_Class

}//end of class