global class BatchQuotaShare implements Database.Batchable<sObject> {

List<Quota__Share> quotaShares = new List<Quota__Share>();

global Database.querylocator start(Database.BatchableContext BC){
    String query = 'SELECT Id, User__c, Territory_Master__c FROM Territory_User__c';
    return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){

    for(sObject s : scope){
        Territory_User__c tu = (Territory_User__c) s;
    
        for(Quota__c terrList : [SELECT Id FROM Quota__c WHERE Territory_Master__c = :tu.territory_master__c]){
            
            Quota__Share userShare = new Quota__Share();
            
            userShare.ParentId = terrList.Id;
            userShare.UserorGroupId = tu.User__c;
            userShare.AccessLevel = 'read';
            userShare.RowCause = Schema.Quota__Share.RowCause.Sales_View__c;
            quotaShares.add(userShare);
        }
        Database.SaveResult[] quotaShareInsertResult = Database.insert(quotaShares,false);

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