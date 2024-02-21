global class PainProfilesBatch implements database.Batchable<sObject>, Schedulable
{
    //start method of the batch
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //List<Pain_Profile__c> painLst  = new List<pain_profile__c>();
        
        String query = 'SELECT id,Account__c from Pain_Profile__c';
        return Database.getQueryLocator(query);}
    
    global void execute(Database.BatchableContext BC, List<pain_Profile__c> scope){ 
        
        update scope;
        system.debug('Pain Profiles list ' + scope.size()); 
    }
    global void finish(Database.BatchableContext BC)
    {
        system.debug('PainProfilesUpdate completed!');
        
    }
    global void execute(SchedulableContext sc)
    {
        PainProfilesBatch b = new  PainProfilesBatch ();
        
        database.executebatch(b,100);
    }
}