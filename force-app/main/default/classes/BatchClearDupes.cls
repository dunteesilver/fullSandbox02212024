global class BatchClearDupes implements Database.Batchable<sObject> {

List<Dupe_Account__c> dupeAcct = new List<Dupe_Account__c>();
    
global Database.querylocator start(Database.BatchableContext BC){
    String query = 'SELECT Id, Name FROM Dupe_Account__c';
    return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){

    for(sObject s : scope){
        Dupe_Account__c temp = (Dupe_Account__c) s;
        List<Account> acct = [SELECT Id from Account WHERE SAP_Sold_To__c=:temp.name];
        
        if (acct.size() > 1){
            Integer count = 1;
            While(count < acct.size()){
                merge acct[0] acct[count];
                count += 1;
            }
        }
    }
    
}

global void finish(Database.BatchableContext BC){
  // Get the ID of the AsyncApexJob representing this batch job  
  // from Database.BatchableContext.    
  // Query the AsyncApexJob object to retrieve the current job's information.  

 AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
   TotalJobItems, CreatedBy.Email
   from AsyncApexJob where Id =:BC.getJobId()];

  // Send an email to the Apex job's submitter notifying of job completion.  
  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
  String[] toAddresses = new String[] {a.CreatedBy.Email};
  mail.setToAddresses(toAddresses);
  mail.setSubject('Apex Sharing Recalculation ' + a.Status);
  mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
    ' batches with '+ a.NumberOfErrors + ' failures. ');

  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}


}