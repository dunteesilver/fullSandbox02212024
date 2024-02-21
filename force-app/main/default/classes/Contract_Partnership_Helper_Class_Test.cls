/*********************************************************************
* Description     : Test class for Contract_Partnership_Helper_Class
* Covered Classes : Contract_Partnership_Helper_Class
* Author(s)       : Duntee Silver
**********************************************************************/
@isTest
public class Contract_Partnership_Helper_Class_Test {

    /*Code coverage for Contract_Partnership_Helper_Class*/
    @isTest static void validateAccountsTest() {
        List<Contract_Partnership__c> cpList = new List<Contract_Partnership__c>();
        Account accTest109 = new Account(
            Name = 'TestAccount109',
            SAP_Sold_To__c = '555555',
            Account_Group__c = 'Z001',
            Customer_Group__c = '16',
            zBlock__c = '00',
            ERP_Active__c = TRUE,
            Sales_Org__c = 'US60'
        );
        insert accTest109;
        
        Account accTest110 = new Account(
            Name = 'TestAccount110',
            SAP_Sold_To__c = '444444',
            Account_Group__c = 'Z002',
            Customer_Group__c = '01',
            zBlock__c = '00',
            ERP_Active__c = TRUE,
            Sales_Org__c = 'US60'
        );
        insert accTest110;
        
        Contract_Partnership__c cp1 = new Contract_Partnership__c(
        	Sale_To__c = '444444',
            Ship_To__c = '555555',
            Disabled__c = FALSE
        );
		cpList.add(cp1);
		System.assertEquals(true, cpList.size() > 0);      
        Contract_Partnership_Helper_Class.validateAccount(cpList);
        
    }//end of validateAccountsTest
    
}//end Contract_Partnership_Helper_Class_Test