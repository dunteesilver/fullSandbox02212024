global class account_Active_Sales_Scheduler Implements Schedulable{
    
    global void execute(SchedulableContext sc){

        // This Kicks off a Batch Job that buils the Sales_by_BU_Key__c and Territory_Key__c
        account_Active_Sales_Batch aas = new account_Active_Sales_Batch(); 
        ID batchprocessid = Database.executeBatch(aas);
    }
}