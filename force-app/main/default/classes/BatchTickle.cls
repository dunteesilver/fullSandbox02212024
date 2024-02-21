global class BatchTickle implements Database.Batchable<sObject> {
    public String query;

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
      update scope;
   }

   global void finish(Database.BatchableContext BC){
       // UserInfo.getUserEmail();
       // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
       // Query the AsyncApexJob object to retrieve the current job's information.
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                         TotalJobItems, CreatedBy.Email, CreatedBy.Admin_SMS_Notification__c 
                         FROM AsyncApexJob WHERE Id =
                         :BC.getJobId()];
       // Send an email to the Apex job's submitter notifying of job completion.
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

       list<string> emailList = new list<string>();
       emailList.add(a.CreatedBy.Email);

       if(a.CreatedBy.Admin_SMS_Notification__c != NULL){
           emailList.add(a.CreatedBy.Admin_SMS_Notification__c);
       }
       mail.setToAddresses(emailList);
       mail.setSubject('Batch Tickle Completed: ' + a.Status);
       mail.setPlainTextBody
           ('The batch Apex job processed ' + a.JobItemsProcessed +
            ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
}