/*********************************************************************
* Description      : Test coverage for Pricing Portal Contract Details.
* Coverage         : Classes(PP_Contract_Detail)
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/

@isTest
private class PP_Contract_Detail_Test {
    static testMethod void unitTest1() {

        Product2 prodObj = TestDataFactory.createProduct('AA-10511-1');
        insert prodObj;

        Contract_Header__c conHeaderObj = TestDataFactory.createContractHeader('Test Agg');
        conHeaderObj.GPO_Contract_Ref__c = 'Test';
        conHeaderObj.Owner__c = 'Test';
        conHeaderObj.Owner_Name__c = 'Test';
        conHeaderObj.Agreement_Number__c = 'Testi';
        conHeaderObj.Alt_UI__c = True;
        insert conHeaderObj;

        Contract_Material__c contractMat = TestDataFactory.createContractMat(prodObj,conHeaderObj);
        insert contractMat;

        Account accObj = TestDataFactory.createAccount('Test Account');
        Contact conObj = TestDataFactory.createContact( 'Test Contact',accObj.id);
        

        Price_Quote__c  quoteObj = TestDataFactory.createPriceQuote(accObj.id, conObj.id);


        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.PP_Contract_Detail'));
        System.currentPageReference().getParameters().put('gporef', 'Test');
        System.currentPageReference().getParameters().put('oid', 'Test');
        System.currentPageReference().getParameters().put('materialStr', 'AA-10511-1');
        System.currentPageReference().getParameters().put('gpoContractHeaderInfo', 'Testi');
        System.currentPageReference().getParameters().put('pqId', quoteObj.id);
        System.currentPageReference().getParameters().put('rs', 'xls');

        PP_Contract_Detail obj = new PP_Contract_Detail();
        obj.addQuoteLine();
        obj.gethtmlMap();
        obj.getplist();
        obj.getaltui();
        obj.getcontractHeaders();
        obj.getbigreport();
        obj.pqid = quoteObj.Id;
        System.assertEquals(obj.pqid,quoteObj.Id);
        string todaysdate = obj.todaysdate;

        obj.oid = 'Test';
        String s = obj.oid ;

        obj.oidname = 'Test';
        String s1 = obj.oidname;

        obj.gporef = 'Test';
        String s2 = obj.gporef;

        obj.rxls = 'xls';
        String s3 = obj.rxls;

        System.currentPageReference().getParameters().put('rs', 'pdf');
        obj.rpdf = 'pdf';
        String s4 = obj.rpdf;

        PP_Contract_Detail.htmlList('Test','Test');

        Test.setCurrentPageReference(new PageReference('Page.PP_Contract_Detail'));
        System.currentPageReference().getParameters().put('pqId', NULL);
        System.currentPageReference().getParameters().put('oid', NULL);
        System.currentPageReference().getParameters().put('gporef', NULL);
        PP_Contract_Detail obj1 = new PP_Contract_Detail();
        //obj1.addQuoteLine();
        DELETE conHeaderObj;
        DELETE quoteObj;
        DELETE prodObj;
        obj1.pqId = NULL;
        obj1.oid = NULL;
        obj1.oidname = NULL;
        obj1.gporef = NULL;
        System.assertEquals(NULL,obj1.pqId);
        System.assertEquals(NULL,obj1.oid);
        System.assertEquals(NULL,obj1.oidname);
        System.assertEquals(NULL,obj1.gporef);
        obj1.getaltui();
        Test.stopTest();
    }


}