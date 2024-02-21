global class Build_Sales_Last_Ordered_Scheduler Implements Schedulable{
    
    global void execute(SchedulableContext sc){

        Build_Sales_Last_Ordered_Batch bslo = new Build_Sales_Last_Ordered_Batch();
        Database.executeBatch(bslo);        

    }
}