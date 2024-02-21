global class Build_Sales_Accounts_Scheduler Implements Schedulable{
    
    global void execute(SchedulableContext sc){
        // November 2016 - ESC
        // This builds out the 'Sales Account' records.

        Build_Sales_Accounts_Batch bas = new Build_Sales_Accounts_Batch();
        Database.executeBatch(bas);
    }
}