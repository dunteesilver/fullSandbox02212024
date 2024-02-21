global class BatchDelete implements Database.Batchable<sObject> {
    public String query;
    public String subject;
    public String obj;

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
      delete scope;
      DataBase.emptyRecycleBin(scope);
   }

   global void finish(Database.BatchableContext BC){

       // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
       // Query the AsyncApexJob object to retrieve the current job's information.

       // Send an email to the Apex job's submitter notifying of job completion.
       AsyncApexJob a = [SELECT Status, NumberOfErrors, JobItemsProcessed, CreatedBy.Email, CreatedBy.Admin_SMS_Notification__c 
                         FROM AsyncApexJob 
                         WHERE Id = :BC.getJobId()];

       
       string emailSubj;
       Global_Maintenance gm = new Global_Maintenance();
       list<String> emailList = new list<String>();
       // If a default subject was not passed create one
       if(Subject != NULL){
           emailSubj = Subject + a.Status;
       }
       else{
           // Default Subject
           emailSubj = 'Batch Delete Completed: ' + a.Status;
       }
       
       if(obj == NULL){
           emailList.add(a.CreatedBy.Email);
       }
       else{
           //if(gm.checkObj(type))
           emailList = gm.getEmailList(obj);
       }

       // Add the SMS Email Address if it is set on the user record
       if(a.CreatedBy.Admin_SMS_Notification__c != NULL){
           emailList.add(a.CreatedBy.Admin_SMS_Notification__c);
       }

       
       // If the class was not passed a set of email addresses we will use the email address of the person that submitted the job
       
       string emailBody = 'The batch Apex job processed ' + a.JobItemsProcessed + ' batches with '+ a.NumberOfErrors + ' failures.';
       
       if(!emailList.isEmpty()){
           gm.sendEmailHelper(emailSubj,emailBody,emailList);
       }
       
       
   }
}