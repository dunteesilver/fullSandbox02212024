global class Build_Contract_Renewal_Items_Scheduler Implements Schedulable{
    
    global void execute(SchedulableContext sc){
        Build_Contract_Renewal_Items_Batch bas = new Build_Contract_Renewal_Items_Batch();
        Database.executeBatch(bas);
    }
}