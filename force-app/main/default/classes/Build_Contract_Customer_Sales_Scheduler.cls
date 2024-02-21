global class Build_Contract_Customer_Sales_Scheduler Implements Schedulable{
    
    global void execute(SchedulableContext sc){
        Build_Contract_Customer_Sales_Batch bccsb = new Build_Contract_Customer_Sales_Batch();
        Database.executeBatch(bccsb);
    }

}