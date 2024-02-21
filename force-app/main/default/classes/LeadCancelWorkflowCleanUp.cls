//Created by Siva, Schedulable Batch class to cleanup Lead data for Cancel Workflow checkbox.
global class LeadCancelWorkflowCleanUp implements Database.Batchable<sObject>, Schedulable
{
    //Start method of the batch
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //Querying unconverted leads with cancel workflow checked
        String query = 'SELECT Id, cancel_workflow__c FROM Lead WHERE cancel_workflow__c = true AND isConverted = false AND status = \'Convert\'';
        return Database.getQueryLocator(query);
    }
 
    //Execute method of the batch
    global void execute(Database.BatchableContext BC, List<Lead> scope)
    {
         for(Lead l : scope)
         {
             //Setting Cancel Workflow to unchecked   
             l.Status ='New';
             l.cancel_workflow__c = false;         
         }
         update scope;
    }
    
    //Finish method of the batch
    global void finish(Database.BatchableContext BC)
    {
        system.debug('LeadCancelWorkflowCleanUp completed!');
    }
    
    //Execute method of the Schedulable class
    global void execute(SchedulableContext sc)
    {
        LeadCancelWorkflowCleanUp b = new LeadCancelWorkflowCleanUp ();
       
        database.executebatch(b,200);
    }
}