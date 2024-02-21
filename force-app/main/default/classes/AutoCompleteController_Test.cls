@isTest
private class AutoCompleteController_Test {
    static testMethod void AutoCompleteController_UnitTest() {
        PP_Menu pp = new PP_Menu();
        AutoCompleteController autoCtlr = new AutoCompleteController(pp);
        Account accRec = TestDataFactory.createAccount('AA-10511-1');
        Contract_Header__c chRec = TestDataFactory.createContractHeader('AA-10511-1');
        insert chRec;
        Product2 prd = TestDataFactory.createProduct('AA-10511-1');
        insert prd;
        Contract_Material__c cmRec = TestDataFactory.createContractMat(prd, chRec);
        insert cmRec;
        Contract_Customer__c conCusRec = TestDataFactory.createContractCustomer(accRec.Id, chRec.Id);
        insert conCusRec;
        AutoCompleteController.getMaterialRecords('AA-10511-1');
        Id [] fixedSearchResults= new Id[3];
            fixedSearchResults[0] = accRec.Id;
            fixedSearchResults[1] = prd.Id;
            fixedSearchResults[2] = chRec.Id;
            Test.setFixedSearchResults(fixedSearchResults);
        AutoCompleteController.getRecords('AA-10511-1');
    }
}