/*********************************************************************
* Description      : Test Class for Pricing Portal IDN Matrix.
* Coverage         : Class(PP_IDN_Matrix)
* Author(s)        : Eric Clay
**********************************************************************/
@isTest
private class PP_IDN_Matrix_Test {
    static testMethod void PP_IDN_Matrix_UnitTest() {
    	System.currentPageReference().getParameters().put('pid', 'AA-10511-1');
    	System.currentPageReference().getParameters().put('oid', 'GPO-008');

    	Contract_Header__c chRec = TestDataFactory.createContractHeader('50010878');
    	insert chRec;
    	IDN_PickList__c IDNPickList = new IDN_PickList__c(Name= 'HPA HEALTH PURCH ALLIANCE ORLANDO',Active__c = true,Key__c = 'IDN-014');
    	insert IDNPickList;

        PP_IDN_Matrix PPIDNMatrix = new PP_IDN_Matrix();
        String ownerName = PPIDNMatrix.ownerName;
        String ownerId = PPIDNMatrix.ownerID;
        PPIDNMatrix.getIDNlist();
        PPIDNMatrix.getItems();
    }
}