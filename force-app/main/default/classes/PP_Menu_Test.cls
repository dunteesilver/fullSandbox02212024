/*********************************************************************
* Description      : Test coverage for Pricing Portal Header Menu.
* Coverage         : Classes(PP_Menu)
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
@isTest
public class PP_Menu_Test {
    @istest static void testMenu(){
        /*
        List<Contract_User__c> ppUsers = new List<Contract_User__c>();
        //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
        Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(UserInfo.getUserName(), UserInfo.getUserId(), 'US - Teleflex', 'US6010', 4);
       	insert cuUs;
        
        PageReference pageRef3 = new PageReference('/apex/PP_GPO_Matrix?oid=');
        system.debug('PageRef:' + pageRef3);
        
        Test.setCurrentPage(pageRef3);
        
        PP_Menu pp = new PP_Menu();
        pp.getgpodropdown();
        pp.getidndropdown();
        pp.getURL();
        pp.getQuoteList();
        pp.getActiveQuote();
        pp.getSOlist();
        //pp.reloadIframe();
        */
        
         String roleId = [SELECT Id,Name FROM UserRole WHERE Name LIKE '%EMEA%' LIMIT 1].Id;
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
            UserRoleId = roleId
        );
        insert u;

        //createUser(String firstName, String lastName, String approvalRole, String bu)
        User u1 = testDataFactoryPP.createUser('Testfn1','Testln1','Sales Rep','Anesthesia');
        insert u1;
        
        User u2 = testDataFactoryPP.createUser('Testfn2','Testln2','Sales Manager','Anesthesia');
        insert u2;
        
        User u3 = testDataFactoryPP.createUser('Testfn3','Testln3','Sales Director','Anesthesia');
        insert u3;
        
        User u4 = testDataFactoryPP.createUser('Testfn4','Testln4','Sales VP','Anesthesia');
        insert u4;
        
        System.runAs(u){
            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex',
                US_Material__c = TRUE,
                CA_Material__c = TRUE,
                MX_Material__c = TRUE,
                LA_Material__c = TRUE,
                CL_Material__c = TRUE,
                AU_Material__c = TRUE,
                NZ_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Pricing_Tier_Access__c = 1,
                CO_Material__c = TRUE,
                BR_Material__c = TRUE,
                DE_Material__c = TRUE,
                UK_Material__c = TRUE,
                AT_Material__c  = TRUE,
                BE_Material__c = TRUE,
                CH_Material__c = TRUE,
                CZ_Material__c = TRUE,
                ES_Material__c = TRUE,
                FR_Material__c = TRUE,
                GR_Material__c = TRUE,
                IT_Material__c = TRUE,
                NL_Material__c = TRUE,
                PL_Material__c = TRUE,
                SK_Material__c = TRUE,
                PT_Material__c = TRUE,
                IE_Material__c = TRUE,
                SA_Material__c = TRUE
                //Division_10__c = TRUE
            );
            insert cu;
            system.debug('CU:' + cu);
            
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
             /*
            Contract_User__c cu1 = testDataFactoryPP.createPricingPortalUser(u1.Name, u1.Id, 'US - Teleflex', 'US6010', 1);
            insert cu1;
            
            Contract_User__c cu2 = testDataFactoryPP.createPricingPortalUser(u2.Name, u2.Id, 'US - Teleflex', 'US6010', 2);
            insert cu2;
            
            Contract_User__c cu3 = testDataFactoryPP.createPricingPortalUser(u3.Name, u3.Id, 'US - Teleflex', 'US6010', 3);
            insert cu3;
            
            Contract_User__c cu4 = testDataFactoryPP.createPricingPortalUser(u4.Name, u4.Id, 'US - Teleflex', 'US6010', 4);
            insert cu4;
           
            Contract_User__c cu5 = testDataFactoryPP.createPricingPortalUser(u1.Name, u1.Id, 'CA - Canada', 'CA1010', 1);
            insert cu5;
            
            Contract_User__c cu6 = testDataFactoryPP.createPricingPortalUser(u2.Name, u2.Id, 'LA - Latin America', 'US6020', 2);
            insert cu6;
            
            Contract_User__c cu7 = testDataFactoryPP.createPricingPortalUser(u3.Name, u3.Id, 'MX - Mexico', 'MX4010', 3);
            insert cu7;
            
            Contract_User__c cu8 = testDataFactoryPP.createPricingPortalUser(u4.Name, u4.Id, 'AU - Australia', 'AU1010', 4);
            insert cu8;
            */
          
            //GPO_PickList__c
            GPO_PickList__c gpo = new GPO_PickList__c(
                Name = 'Amerinet',
                Active__c = TRUE,
                Key__c = 'GPO-001'
            );
            System.debug('insert cs-->' + gpo);
            insert gpo;
            
            IDN_PickList__c idn = new IDN_PickList__c(
                Name = 'Amerinet2',
                Active__c = TRUE,
                Key__c = 'GPO-001'
            );
            System.debug('insert cs-->' + idn);
            insert idn;
            
            Account a = new Account(
                Name = 'Test PP Account',
                SAP_Sold_To__c ='100123',
                ShippingStreet='123 Main Street ',
                ShippingCity='Raleigh',
                ShippingState='NC',
                ShippingPostalCode='27614',
                Customer_Group__c = '19'
            );
            insert a;
            
            Date ValidFromDate = Date.today();
            Date ValidToDate = ValidFromDate.addYears(2);
            
            Contract_Header__c ch = new Contract_Header__c(
                Name = '50001234',
                Owner__c = 'GPO-001',
                Owner_Name__c = 'Amerinet',
                Agreement_Number__c = '50001234',
                Description__c = 'PP Test Health Systems Tier 1',
                GPO_Contract_Ref__c  = 'VH11227',
                Valid_From__c = ValidFromDate,
                Valid_To__c = ValidToDate,
                Division_10__c = TRUE,
                Division_20__c = FALSE,
                Division_30__c = FALSE,
                Division_40__c = FALSE,
                Division_50__c = FALSE,
                Division_60__c = FALSE
            );
            insert ch;
            system.debug('ch:' + ch);
            
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US60');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US60');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US60');
            insert ch4;
            
            List<Contract_Header__c> chList = new List<Contract_Header__c>();
            chList.add(ch);
            chList.add(ch1);
            chList.add(ch2);
            chList.add(ch3);
            chList.add(ch4);
            
            Product2 p2 = new Product2(
                Name = '000-11',
                Division__c = '10'
            );
            insert p2;
            system.debug('p:' + p);
            
            //createProduct2(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 p1 = testDataFactoryPP.createProduct2('TestProd', 'US60','10','40');
            insert p1;
            
            List<Product2> pList = new List<Product2>();
            pList.add(p2);
            pList.add(p1);
            
            Contract_Material__c cm = new Contract_Material__c(
                Name = '000-11',
                Agreement__c = ch.id,
                Material_Division__c = '10',
                Product__c = p2.id
            );
            insert cm;
            system.debug('cm:' + cm);
            
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch.Id, ch.Name, p2.Name, p2.Id, 'US60','10','10');
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch.Id, ch.Name, p1.Name, p1.Id, 'US60','10','10');
            insert cm2;
            
            List<Contract_Material__c> cmList = new List<Contract_Material__c>();
            cmList.add(cm);
            cmList.add(cm1);
            cmList.add(cm2);
            
            Contract_Customer__c cc = new Contract_Customer__c(
                Name = '50001234',
                Agreement__c = ch.Id,
                Account__c = a.Id,
                Valid_From__c = ValidFromDate,
                Valid_To__c = ValidToDate,
                Condition__c = 'XPRI'
                
            );
            insert cc;
            system.debug('cc:' + cc);
            
            PageReference pageRef = new PageReference('/apex/PP_GPO_Matrix?gs=off&oid=' + ch.Owner__c );
            system.debug('PageRef:' + pageRef);
            pageRef.getParameters().put('salesOrgList', 'US - Teleflex/Arrow');
            pageRef.getParameters().put('gs', 'on');
            Test.setCurrentPage(pageRef);
            PP_Menu pp = new PP_Menu();
            pp = new PP_Menu();
            pp.getgpodropdown();
            pp.getidndropdown();
            pp.getURL();
            pp.getQuoteList();
            pp.getActiveQuote();
            pp.getSOlist();
            pp.salesOrgList = pp.getSOlist();
            pp.reloadIframe();
            pp.getPRFList();
            pp.getSampleRequestList();
            //pp.userLanguage();
            pp.getAvailableLanguages();
            boolean atrue = pp.gs;
            boolean checksrch = pp.checksrch;
            boolean gs = pp.gs;
            
            //PP_Build_Group_Future.Update_Group_Membership(userIds);
            PP_Build_Contract_Divisions.checkDivisions(chList);
            PP_Build_Contract_Divisions.buildDivisions_CM(cmList);
            
            PageReference menu = Page.PP_Menu;
            menu.getParameters().put('srch','Test PP Account');
            menu.getParameters().put('gs', 'off');
            Test.setCurrentPage(menu);
            PP_Menu menuController = new PP_Menu();
            menuController.srch = a.Name;
            System.assertEquals(a.Name, menuController.srch);
            checksrch = menuController.checksrch;
            gs = menuController.gs;
            //Test for salesPrefix in Constructor Canada
            
            cu.Active_Region__c = 'CA - Canada';
            UPDATE cu;
            PageReference menu1 = Page.PP_Menu;
            menu1.getParameters().put('srch','Test PP Account');
            Test.setCurrentPage(menu1);
            PP_Menu menuController1 = new PP_Menu();
            menuController1.reloadIframe();
            
            //Test for salesPrefix in Constructor Chile
            cu.Active_Region__c = 'CL - Chile';
            UPDATE cu;
            PageReference menu2 = Page.PP_Menu;
            menu2.getParameters().put('srch','Test PP Account');
            Test.setCurrentPage(menu2);
            PP_Menu menuController2 = new PP_Menu();
            menuController2.reloadIframe();
            
            //Test for salesPrefix in Constructor Latin America
            cu.Active_Region__c = 'LA - Latin America';
            UPDATE cu;
            PageReference menu3 = Page.PP_Menu;
            menu3.getParameters().put('srch','Test PP Account');
            Test.setCurrentPage(menu3);
            PP_Menu menuController3 = new PP_Menu();
            menuController3.reloadIframe();
            
            //Test for salesPrefix in Constructor Mexico
            cu.Active_Region__c = 'MX - Mexico';
            UPDATE cu;
            PageReference menu4 = Page.PP_Menu;
            menu4.getParameters().put('srch','Test PP Account');
            Test.setCurrentPage(menu4);
            PP_Menu menuController4 = new PP_Menu();
            menuController4.reloadIframe();
            
            //Test for salesPrefix in Constructor Australia
            cu.Active_Region__c = 'AU - Australia';
            UPDATE cu;
            PageReference menu5 = Page.PP_Menu;
            menu5.getParameters().put('srch','Test PP Account');
            Test.setCurrentPage(menu5);
            PP_Menu menuController5 = new PP_Menu();
            menuController5.reloadIframe();
            
            //Test for salesPrefix in Constructor New Zealand
            cu.Active_Region__c = 'NZ - New Zealand';
            UPDATE cu;
            PageReference menu6 = Page.PP_Menu;
            menu6.getParameters().put('srch','Test PP Account');
            Test.setCurrentPage(menu6);
            PP_Menu menuController6 = new PP_Menu();
            menuController6.reloadIframe();
            //https://teleflex--sandbox--c.cs14.visual.force.com/apex/PP_Membership_Export_XLS?oid=GPO-001
            
            //start of PP_Membership_Export_XLS test
            PageReference pageRef2 = new PageReference('/apex/PP_Membership_Export_XLS?oid=' + ch.Owner__c );
            system.debug('PageRef2:' + pageRef2);
            Test.setCurrentPage(pageRef2);
            
            PP_Membership_Export me = new PP_Membership_Export();
            
            //me.accList
            me.getAccounts();
            string filename = me.filename;
            
            PP_Menu.salesOrg = 'CA - Canada';
            pp.reloadIframe();
            
            PP_Menu.salesOrg = 'LA - Latin America';
            pp.reloadIframe();
            
            PP_Menu.salesOrg = 'MX - Mexico';
            pp.reloadIframe();
            
            PP_Menu.salesOrg = 'CL - Chile';
            pp.reloadIframe();
            
            PP_Menu.salesOrg = 'CZ - Czech';
            pp.reloadIframe();
            
            PP_Menu.salesOrg = 'ES - Spain';
            pp.reloadIframe();
            
            PP_Menu.salesOrg = 'NL - Netherlands';
            pp.reloadIframe();
            
            PP_Menu.salesOrg = 'PL - Poland';
            pp.reloadIframe();
            
            PP_Menu.salesOrg = 'SK - Slovakia';
            pp.reloadIframe();
            
            PP_Menu.salesOrg = 'PT - Portugal';
            pp.reloadIframe();
            
            PP_Menu.salesOrg = 'IE - Ireland';
            pp.reloadIframe();
      
            
            
            
            
        }//end of System.runAs
        
    }//end of static void testMenu()
    
}//end of class