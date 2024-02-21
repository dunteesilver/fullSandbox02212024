global class Invoiced_Sales_Detail_Maintenance_Sch Implements Schedulable{
    
    public Boolean singleRun = FALSE; // Set TRUE to only run Open Orders Maintenance
    
    global void execute(SchedulableContext sc){
        // New Class Logic 20Nov2017 - ESC
        Invoiced_Sales_Helper_Class check = new Invoiced_Sales_Helper_Class();
        string mKey = check.getMaintenanceKey('Invoiced_Sales_Detail__c');
        
        if(mKey != NULL){
            Invoiced_Sales_Maintenance_Batch isms = new Invoiced_Sales_Maintenance_Batch();
            isms.mKey = mKey;
            Database.executeBatch(isms);
        }
        
        /*
        // October 2016 - ESC
        // This Purges Invoiced Sales records that were not updated.
        // New
        
        Invoiced_Sales_Helper_Class check = new Invoiced_Sales_Helper_Class();
        boolean checkID = check.checkInvoiceDetails();

        if(checkID){
            Invoiced_Sales_Detail_Maintenance_Batch isdm = new Invoiced_Sales_Detail_Maintenance_Batch();
            Database.executeBatch(isdm);
        }
        else{
            boolean checkIS = check.checkInvoicedSales();
            if(checkIS){
                Invoiced_Sales_Maintenance_Batch isms = new Invoiced_Sales_Maintenance_Batch();
                Database.executeBatch(isms);
            }
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
            oldRowCount = [SELECT count() FROM Invoiced_Sales_Detail__c WHERE LastModifiedDate != TODAY LIMIT 50000];
            newRowCount = [SELECT count() FROM Invoiced_Sales_Detail__c WHERE CreatedDate = TODAY LIMIT 50000];
        }
        
        if(
            (newRowCount > 0 && oldRowCount != 50000)
            || runTest == TRUE
        ){
            Invoiced_Sales_Detail_Maintenance_Batch isdm = new Invoiced_Sales_Detail_Maintenance_Batch();
            Database.executeBatch(isdm);
        }
        else{
                newRowCount = 0;
                oldRowCount = 0;
                runTest = FALSE;
                
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
            }
        
        
        // Old
        /*
        integer isrowcount;
        if(test.isRunningTest()){
            isrowcount = [SELECT count() FROM Invoiced_Sales_Detail__c LIMIT 50000];            
        }
        else{
            isrowcount = [SELECT count() FROM Invoiced_Sales_Detail__c WHERE LastModifiedDate != TODAY LIMIT 50000];
        }
        if(isrowcount > 0 && isrowcount != 50000){
            Invoiced_Sales_Detail_Maintenance_Batch purgeSalesDetails = new Invoiced_Sales_Detail_Maintenance_Batch();
            Database.executeBatch(purgeSalesDetails);        
        }
        else if(singleRun == FALSE){
            Invoiced_Sales_Maintenance_Batch isms = new Invoiced_Sales_Maintenance_Batch();
            Database.executeBatch(isms);
        }*/

    }
}