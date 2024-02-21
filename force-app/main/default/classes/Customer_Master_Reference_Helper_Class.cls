public class Customer_Master_Reference_Helper_Class {
    public static void checkZblock(List<Customer_Master_Reference__c> newTrigger){
        // Ensures that the Account Table is in sync with the Customer Master Reference
        // 27Sept2017 - ESC
        // Test Class: account_Page_Helper_Test (94%)
        map<String, String> zFix = new map<String, String>();
        list<Account> aList = new list<Account>();
        
        for(Customer_Master_Reference__c cmr : newTrigger){
            zFix.put(cmr.SAP_Code__c, cmr.zBlock__c);
        }
        
        for(Account a : [SELECT Id, SAP_Sold_To__c, zBlock__c
                         FROM Account 
                         WHERE SAP_Sold_To__c = :zFix.keySet()])
        {
            if(zFix.containsKey(a.SAP_Sold_To__c) && a.zBlock__c != zFix.get(a.SAP_Sold_To__c)){
                Account updateAcct = new Account(
                    Id = a.Id,
                    zBlock__c = zFix.get(a.SAP_Sold_To__c),
                    Last_SAP_Update__c = datetime.now()
                );
                // Making sure that the account is properly flagged active or not.
                if(zFix.get(a.SAP_Sold_To__c) == '00'){
                    updateAcct.ERP_Active__c = TRUE;
                }
                else{
                    updateAcct.ERP_Active__c = FALSE;
                }
                aList.add(updateAcct);
            }
        }
        if(aList.size() > 0){
            update aList;
        }
    }
}