/*********************************************************************
* Description      : Test coverage for Pricing Portal PP_Active_Customer.
* Coverage         : Classes(PP_Active_Customer)
* Author(s)        : Eric Clay
**********************************************************************/
@isTest
private class PP_Active_Customer_Test {
    static testMethod void unitTest1() {
        PageReference p = Page.PP_Active_Customer;
        Account a = TestDataFactory.createAccount('test account1');
        Contract_Header__c header = TestDataFactory.createContractHeader('test header');
        insert header;
        Contract_Customer__c con_customer = TestDataFactory.createContractCustomer(a.Id,header.Id);
        insert con_customer;
        p.getParameters().put('aid','TestId');
        Test.setCurrentPageReference(p);
        PP_Active_Customer obj = new PP_Active_Customer();
        obj.getActiveCustomers();
        obj.getCH();
        obj.getfilename();
    }
}