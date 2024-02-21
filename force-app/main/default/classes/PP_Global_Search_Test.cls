/*********************************************************************
* Description      : Test Class for Pricing Portal Global Search.
* Coverage         : PP_Global_Search
* Author(s)        : Dun Silver
**********************************************************************/
@isTest
public class PP_Global_Search_Test {
    

    
    
    @isTest static void testGlobalSearchProd() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        //createUser(String firstName, String lastName, String approvalRole, String bu)
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US', 'User', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;

        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser){
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            cuUs.Active_Sales_Org_Key__c = '';
            cuUs.Pricing_Tier_Access__c = NULL;
            insert cuUs;
            
            Contract_User__c cuUs2 = testDataFactoryPP.createPricingPortalUser(usUserMan.Name, usUserMan.Id, 'US - Teleflex', 'US6010', NULL);
            cuUs2.Active_Sales_Org_Key__c = 'US6010';
            insert cuUs2;
            
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
            //ch1.Active_Future__c = true;
            ch1.Name = 'ASK-45703-PK';
            ch1.Valid_To__c = Date.today();
            ch1.Sales_Org__c = 'US60';
            ch1.Distribution_Channel__c = '10';
            insert ch1;
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            
            //create Account with no SAP Code
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','17');
            usAcc.Name = 'ASK-45703-PK';
            usAcc.Account_Group__c = 'Z001';
            usAcc.Sales_Org__c = 'US60';
            usAcc.Distribution_Channel__c = '10';
            //usAcc.Sales_Org_Key__c = 'US6010';
            usAcc.zBlock__c = '00';
            
            insert usAcc;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
                        
            PRF__c prfUs = testDataFactoryPP.createPrf(usAcc.Id, con1.Id,'US6010','Anesthesia'); 
            //prfUs.Name = 'ASK-45703-PK';
            prfUs.Sales_Org_Key__c = 'US6010';	
            insert prfUs;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            List<Product2> prodList = new List<Product2>();
            Product2 usProd = testDataFactoryPP.createProduct('ASK-45703-PK', 'US60', '10', '40');
            //usProd.SearchableProducts__c = true;
            usProd.ASK_Custom_Kit__c = false;
            usProd.Duplicate__c = false;
            usProd.Sales_Org__c = 'US60';
            usProd.Distribution_Channel__c = '10';
            insert usProd;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('ASK-42703-PK', 'US60', '10', '40');
            //usProd2.SearchableProducts__c = true;
            usProd2.Duplicate__c = false;
            usProd2.ASK_Custom_Kit__c = false;
            usProd2.Sales_Org__c = 'US60';
            usProd2.Distribution_Channel__c = '10';
            insert usProd2;

            prodList.add(usProd);
            prodList.add(usProd2);
            
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            //pqUs.Name = 'ASK-45703-PK';
            pqUs.Sales_Org_Key__c = 'US6010';
            insert pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            insert pqliUs;
			Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            insert pqliUs2;
                
            Test.startTest();
            
            
            PP_Global_Search gsController = new PP_Global_Search();
            //search with space
            PageReference gsSpace = New Pagereference('/apex/PP_Global_Search?srch= ');
            //gsSpace.getParameters().put('srch',' ');
            Test.setCurrentPage(gsSpace);
            gsController.searchStr = ' ';
            System.assertEquals(' ', gsController.searchStr, 'Please enter at least two characters...');
            List<String> tierHeaderL = gsController.tierHeaderList;
            List<String> tierHeaderLName = gsController.tierHeaderListName;
            Map<String, PP_Pricing_Tiers.tiers> tierM = gsController.tierMap;
            Map<String, list<PP_Pricing_Tiers.tiers>> newTMap = gsController.newTierMap;
            //gsController.conMatList = New List<Product2>();
            gsController.conMatList = prodList;
            
            //code coverage for Pricing Tier Level
            Integer pricingTier = Integer.valueOf(cuUs.Pricing_Tier_Access__c);
            System.debug('*** pricingTier *** ' + pricingTier);
            gsController.pricingTierAccessLevel = pricingTier;
            System.debug('*** gsController.pricingTierAccessLevel *** ' + gsController.pricingTierAccessLevel);
            //System.assertEquals(pricingTier,gsController.pricingTierAccessLevel);
            gsController.getActiveQuoteIdStr();
            
            //new test
            gsController.searchStr = 'pw';
            PageReference globalSearch = New Pagereference('/apex/PP_Global_Search?srch=pw');
            system.debug('*** globalSearch PageRef:' + globalSearch);
            //globalSearch.getParameters().put('salesOrgList', 'US - Teleflex/Arrow');
            //globalSearch.getParameters().put('gs', 'on');
            Test.setCurrentPage(globalSearch);
            System.assertEquals('pw', gsController.searchStr, 'Sorry, no results returned with matching string...');
            
            //search with Account Name
            PP_Global_Search gsControllerAcc = new PP_Global_Search();
            PageReference gsAcc = New Pagereference('/apex/PP_Global_Search?srch=' + usAcc.Name);
            gsAcc.getParameters().put('srch',usAcc.Name);
            gsControllerAcc.searchStr = usAcc.Name;
            Test.setCurrentPage(gsAcc);
            System.assertEquals(usAcc.Name, gsControllerAcc.searchStr);
            
            //search with Product Name
            PP_Global_Search gsControllerProd = new PP_Global_Search();
            PageReference gsProd = New Pagereference('/apex/PP_Global_Search?srch=' + usProd.Name);
            gsProd.getParameters().put('srch',usProd.Name);
            gsControllerProd.searchStr = usProd.Name;
            Test.setCurrentPage(gsProd);
            System.assertEquals(usProd.Name, gsControllerProd.searchStr);
            
            //search with space and valid
            PP_Global_Search gsControllerAcc2 = new PP_Global_Search();
            PageReference gsAcc2 = New Pagereference('/apex/PP_Global_Search?srch= ' + usAcc.Name);
            gsAcc2.getParameters().put('srch',' ' + usAcc.Name);
            gsControllerAcc2.searchStr = ' ' + usAcc.Name;
            Test.setCurrentPage(gsAcc2);
            System.assertEquals(' ' + usAcc.Name, gsControllerAcc2.searchStr);
            
            
            //added on 15th June 2023
            PageReference ppGlobalSearchPageRef = New Pagereference('/apex/PP_Global_Search?srch=ASK-45703-PK');
            Test.setCurrentPage(ppGlobalSearchPageRef);
            PP_Global_Search ppGlobalSearch = new PP_Global_Search();
            String userLang = ppGlobalSearch.userLang;

            Test.stopTest();
        }//end of system run
    }//end method
    
}//end class