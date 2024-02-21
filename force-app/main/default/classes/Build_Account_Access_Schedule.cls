global class Build_Account_Access_Schedule Implements Schedulable{
    
    global void execute(SchedulableContext sc){
        Build_Account_Access_Batch accRefresh = new Build_Account_Access_Batch();
        Database.executeBatch(accRefresh);
    }
}