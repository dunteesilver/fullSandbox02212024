/*********************************************************************
* Description      : This scheduler class for building contract renewals.
* Test Class       : Contract_Renewal_Test
* Author(s)        : Eric Clay
**********************************************************************/
global class Build_Contract_Renewals_Scheduler Implements Schedulable{

    global void execute(SchedulableContext sc){
        Build_Contract_Renewals_Batch bcrb = new Build_Contract_Renewals_Batch();
        Database.executeBatch(bcrb,50);
    }
}