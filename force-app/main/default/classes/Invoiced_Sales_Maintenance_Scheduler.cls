global class Invoiced_Sales_Maintenance_Scheduler Implements Schedulable{
    
    public Boolean singleRun = FALSE; // Set TRUE to only run Open Orders Maintenance
    
    global void execute(SchedulableContext sc){
        // New Class Logic 20Nov2017 - ESC
        Invoiced_Sales_Helper_Class check = new Invoiced_Sales_Helper_Class();
        string mKey = check.getMaintenanceKey('Invoiced_Sales__c');
        
        if(mKey != NULL){
            Invoiced_Sales_Maintenance_Batch isms = new Invoiced_Sales_Maintenance_Batch();
            isms.mKey = mKey;
            Database.executeBatch(isms);
        }
        
        /*
        // Used to manage the row counts of each object
        integer newRowCount = 0;
        integer oldRowCount = 0;
        boolean runTest = FALSE;
        
        // Open Orders - Should never have more than 15k orders to purge
        if(test.isRunningTest()){
            runTest = TRUE;
        }
        else{
            oldRowCount = [SELECT count() FROM Invoiced_Sales__c WHERE LastModifiedDate != TODAY LIMIT 50000];
            newRowCount = [SELECT count() FROM Invoiced_Sales__c WHERE CreatedDate = TODAY LIMIT 50000];
        }
        
        if(
            (newRowCount > 0 && oldRowCount != 50000)
            || runTest == TRUE
        ){
            Invoiced_Sales_Maintenance_Batch isms = new Invoiced_Sales_Maintenance_Batch();
            Database.executeBatch(isms);
        }
        
        // Old
        /*integer isrowcount;
        if(test.isRunningTest()){
            isrowcount = [SELECT count() FROM Invoiced_Sales__c LIMIT 50000];            
        }
        else{
            isrowcount = [SELECT count() FROM Invoiced_Sales__c WHERE LastModifiedDate != TODAY AND (Date__c = THIS_YEAR OR Date__c = LAST_YEAR) LIMIT 50000];
        }
        if(isrowcount > 0 && isrowcount != 50000){
            Invoiced_Sales_Maintenance_Batch purgeSales = new Invoiced_Sales_Maintenance_Batch();
            Database.executeBatch(purgeSales);        
        }
        else if(singleRun == FALSE){
            account_Active_Sales_Batch aas = new account_Active_Sales_Batch();
            Database.executeBatch(aas);
        }*/
    }
}