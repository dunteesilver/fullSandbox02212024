global class CanadaProfilesBatch implements database.Batchable<sObject>, Schedulable
{
    //start method of the batch
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //List<Pain_Profile__c> painLst  = new List<pain_profile__c>();
    
    String query = 'SELECT id,Account__c from Canada_Profile__c';
        return Database.getQueryLocator(query);}
    
    global void execute(Database.BatchableContext BC, List<Canada_Profile__c> scope){
  
    
    for(Canada_Profile__c CanObj : scope)
    {
       /*Dummy Update*/
    }
    system.debug('Canada Profiles list ' + scope.size()); 
    update scope;
    }
    global void finish(Database.BatchableContext BC)
    {
        system.debug('CanadaProfilesUpdate completed!');
    }
    global void execute(SchedulableContext sc)
    {
        CanadaProfilesBatch b = new  CanadaProfilesBatch ();
        
        database.executebatch(b,200);
    }
}