global class Build_VPS_Consumable_Sales_Scheduler Implements Schedulable{
    
    global void execute(SchedulableContext sc){
        Build_VPS_Consumable_Sales_Batch bvcsb = new Build_VPS_Consumable_Sales_Batch();
        Database.executeBatch(bvcsb,25);
    }
}