global class account_GPO_Builder_Scheduler Implements Schedulable{
    
    global void execute(SchedulableContext sc){
        account_GPO_Builder buildGPO = new account_GPO_Builder();
        //ID batchprocessid = Database.executeBatch(buildGPO);
        Database.executeBatch(buildGPO);
    }

}