/*********************************************************************
* Description      : Test coverage for Pricing Portal PP_Sort_LineItemsCtrl Page.
* Coverage         : Classes(PP_Sort_LineItemsCtrl)
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
@isTest
private class PP_Sort_LineItemsCtrl_Test {

    static testMethod void PP_Sort_LineItemsCtrl_UnitTest() {
      	Account accRec = TestDataFactory.createAccount('TestAccount');
      	Contact conRec = TestDataFactory.createContact('TestContact', accRec.Id);
      	Price_Quote__c pcqRec = TestDataFactory.createPriceQuote(accRec.Id,conRec.Id);
      	Product2 proRec = TestDataFactory.createProduct('AA-10511-1');
      	INSERT proRec;
        Contract_Header__c cHead = TestDataFactory.createContractHeader('Test Head');
        INSERT cHead;
        Contract_Material__c conMat = TestDataFactory.createContractMat( proRec, cHead );
        INSERT conMat;
      	System.debug('----------pcqRec.Name------------'+pcqRec.Name);
      	Cross_Reference__c crfRec = TestDataFactory.createCrossRef(proRec.Id);
      	Price_Quote_Line_Item__c pqlItem = TestDataFactory.createPriceQLineItem(pcqRec.Id, proRec.Id, crfRec.Id);

      	Test.setCurrentPageReference(new PageReference('Page.PP_Price_Quote'));
        System.currentPageReference().getParameters().put('pqid', pcqRec.Id);
        PP_Sort_LineItemsCtrl sortLItem = new PP_Sort_LineItemsCtrl();
        PP_Sort_LineItemsCtrl.saveSortedRows(new List<String>{pqlItem.id});
        PP_Sort_LineItemsCtrl.saveSortedRows(new List<String>{'123456'});
    }
}