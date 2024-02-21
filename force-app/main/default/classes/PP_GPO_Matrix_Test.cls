/*********************************************************************
* Description      : Test Class for Pricing Portal GPO Matrix.
* Coverage         : Class(PP_GPO_Matrix)
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
@isTest
private class PP_GPO_Matrix_Test {
    static testMethod void PP_GPO_Matrix_UnitTest() {
      //String ownerId = UserInfo.getUserId();
      //PageReference gpo = Page.PP_GPO_Matrix;
      //Test.setCurrentPage(gpo);
      //gpo.getParameters().put('oid','GPO-008');

      //Created the contract user to fix the test failure issue
      //User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
      //Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
      //Insert cUser;
      
      //////////////////
      //createUser(String firstName, String lastName, String approvalRole, String bu)
      User u = testDataFactoryPP.createUser('Adam','Franks','Sales VP','Anesthesia');
      insert u;

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
            SA_Material__c = TRUE,
            Update_Type__c = NULL
            //Division_10__c = TRUE
        );
        insert cu;
        system.debug('CU:' + cu);
      
        Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
        insert ch1;
        
        Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US60');
        insert ch2;
        
        Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US60');
        insert ch3;
        
        Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US60');
        insert ch4;

        Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009067', 'GPO-255','D','US60');
        insert ch5;

        ch1 = new Contract_Header__c(Id = ch1.Id, Contract_Detail__c = NULL);
        update ch1;
        //createProduct2(String prodName, String salesOrg, String distChan, String matStatus)
        Product2 p1 = testDataFactoryPP.createProduct2('000-11', 'US60','10','40');
        insert p1;
        
        Product2 p2 = testDataFactoryPP.createProduct2('353535', 'US60','10','40');
        insert p2;
        
        //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
        Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Name, p2.Name, p2.Id, 'US60','10','10');
        insert cm1;
        
        Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Name, p1.Name, p1.Id, 'US60','10','10');
        insert cm2;

        PageReference pageRefpre = new PageReference('/apex/PP_GPO_Matrix?oid=' + ch5.Owner__c);
        system.debug('Price Quote Page' + pageRefpre);
        Test.setCurrentPage(pageRefpre);

        System.currentPageReference().getParameters().put('oid', ch5.Owner__c);

        PP_GPO_Matrix PPGPOMatrix = new PP_GPO_Matrix();
        String ownerIds=PPGPOMatrix.ownerID;
        String ownerNames=PPGPOMatrix.ownerName;
        PPGPOMatrix.oid();
        PPGPOMatrix.getItems();
        PPGPOMatrix.getEmeaGpos();
        PPGPOMatrix.getCheckChEmea();
        PPGPOMatrix.getTiers();
        PPGPOMatrix.getTiersEmea();
        PPGPOMatrix.getCheckCH();
        PPGPOMatrix.backToGpoMatrix();
        PPGPOMatrix.refreshPageSize();

        PPGPOMatrix.td3 = 'Testing td3';
        PPGPOMatrix.cd = 'Testing cd';
        Map<String, String> sampleMap = new Map<String, String>();
        sampleMap.put(ch1.GPO_Contract_Ref__c, PPGPOMatrix.td3);

        String td3 = PPGPOMatrix.td3;
        String cd = PPGPOMatrix.cd;
        PPGPOMatrix.htmlMap = sampleMap;
        Map<String, String> testmap = PPGPOMatrix.htmlMap;
        System.assertEquals(sampleMap, testMap);
        //test NULL Contract_Detail__c
        //chRec.Contract_Detail__c = NULL;
        //UPDATE chRec;
        PageReference gpo1 = Page.PP_GPO_Matrix;
        gpo1.getParameters().put('oid','GPO-008');
        Test.setCurrentPage(gpo1);
        PP_GPO_Matrix PPGPOMatrix1 = new PP_GPO_Matrix();
        ownerIds = PPGPOMatrix1.ownerID;
        ownerNames = PPGPOMatrix1.ownerName;
        PPGPOMatrix1.oid();
        PPGPOMatrix1.getItems();
        PPGPOMatrix1.getTiers();
        PPGPOMatrix1.getCheckCH();
        PPGPOMatrix1.getTiers();

        //test with NULL oid
        PageReference gpo2 = Page.PP_GPO_Matrix;
        gpo2.getParameters().put('oid', NULL);
        Test.setCurrentPage(gpo2);
        PP_GPO_Matrix PPGPOMatrix2 = new PP_GPO_Matrix();
        ownerIds = PPGPOMatrix2.ownerID;
        ownerNames = PPGPOMatrix2.ownerName;
        PPGPOMatrix2.oid();
        PPGPOMatrix2.getItems();
        PPGPOMatrix2.getTiers();
        PPGPOMatrix2.getCheckCH();
        PPGPOMatrix2.getTiers();
      }//end system.runas

    }// end of PP_GPO_Matrix_UnitTest

    //Start Testing EMEA User
    static testMethod void PP_GPO_Matrix_UnitTestEmea() {
      //String ownerId = UserInfo.getUserId();
      //PageReference gpo = Page.PP_GPO_Matrix;
      //Test.setCurrentPage(gpo);
      //gpo.getParameters().put('oid','GPO-008');

      //Created the contract user to fix the test failure issue
      //User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
      //Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
      //Insert cUser;
      
      //////////////////
      //createUser(String firstName, String lastName, String approvalRole, String bu)
      User u = testDataFactoryPP.createUser('Adam','Franks','Sales VP','EMEA');
      insert u;

      User u1 = testDataFactoryPP.createUser('Testfn1','Testln1','Sales Rep','EMEA');
      insert u1;
      
      User u2 = testDataFactoryPP.createUser('Testfn2','Testln2','Sales Manager','EMEA');
      insert u2;
      
      User u3 = testDataFactoryPP.createUser('Testfn3','Testln3','Sales Director','EMEA');
      insert u3;
      
      User u4 = testDataFactoryPP.createUser('Testfn4','Testln4','Sales VP','EMEA');
      insert u4;
        
      System.runAs(u){
        Contract_User__c cu = new Contract_User__c(
            Name = 'Adam Franks',
            User__c = u.id,
            Active_Region__c = 'DE - Germany',
            DE_Material__c = TRUE,
            Update_Type__c = NULL
            //Division_10__c = TRUE
        );
        insert cu;
        system.debug('CU:' + cu);
      
        Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','DE10');
        insert ch1;
        
        Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','DE10');
        insert ch2;
        
        Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','DE10');
        insert ch3;
        
        Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','DE10');
        insert ch4;

        //createProduct2(String prodName, String salesOrg, String distChan, String matStatus)
        Product2 p1 = testDataFactoryPP.createProduct2('000-11', 'DE10','10','40');
        insert p1;
        
        Product2 p2 = testDataFactoryPP.createProduct2('353535', 'DE10','10','40');
        insert p2;
        
        //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
        Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Name, p2.Name, p2.Id, 'DE10','10','10');
        insert cm1;
        
        Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Name, p1.Name, p1.Id, 'DE10','10','10');
        insert cm2;

        //Contract_Header__c chRec = TestDataFactory.createContractHeader('50010878');
        //insert chRec;
        //System.debug('-------chRec-----'+chRec.Active__c);
        PP_GPO_Matrix PPGPOMatrix = new PP_GPO_Matrix();
        String ownerIds=PPGPOMatrix.ownerID;
        String ownerNames=PPGPOMatrix.ownerName;
        PPGPOMatrix.oid();
        PPGPOMatrix.getItems();
        PPGPOMatrix.getEmeaGpos();
        PPGPOMatrix.getCheckChEmea();
        PPGPOMatrix.getTiers();
        PPGPOMatrix.getTiersEmea();
        PPGPOMatrix.getCheckCH();
        PPGPOMatrix.backToGpoMatrix();
        PPGPOMatrix.refreshPageSize();

        //test NULL Contract_Detail__c
        //chRec.Contract_Detail__c = NULL;
        //UPDATE chRec;
        PageReference gpo1 = Page.PP_GPO_Matrix;
        gpo1.getParameters().put('oid','DE-11111');
        Test.setCurrentPage(gpo1);
        PP_GPO_Matrix PPGPOMatrix1 = new PP_GPO_Matrix();
        ownerIds = PPGPOMatrix1.ownerID;
        ownerNames = PPGPOMatrix1.ownerName;
        PPGPOMatrix1.oid();
        PPGPOMatrix1.getItems();
        PPGPOMatrix1.getTiers();
        PPGPOMatrix1.getCheckCH();
        PPGPOMatrix1.getTiers();

        //test with NULL oid
        PageReference gpo2 = Page.PP_GPO_Matrix;
        gpo2.getParameters().put('oid', NULL);
        Test.setCurrentPage(gpo2);
        PP_GPO_Matrix PPGPOMatrix2 = new PP_GPO_Matrix();
        ownerIds = PPGPOMatrix2.ownerID;
        ownerNames = PPGPOMatrix2.ownerName;
        PPGPOMatrix2.oid();
        PPGPOMatrix2.getItems();
        PPGPOMatrix2.getTiers();
        PPGPOMatrix2.getCheckCH();
        PPGPOMatrix2.getTiers();
      }//end system.runas

    }// end of PP_GPO_Matrix_UnitTest
    //End Testing for EMEA User
}//end of PP_GPO_Matrix_Test