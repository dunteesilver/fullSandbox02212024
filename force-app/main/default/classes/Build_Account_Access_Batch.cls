global class Build_Account_Access_Batch Implements Database.Batchable<sObject> {
    public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC){

        if(test.isRunningTest()){
            query = 'SELECT Id, SAP_Sold_to__c, BillingState, BillingPostalCode, Customer_Group__c, Territory_Key__c FROM Account ORDER BY BillingState, BillingPostalCode';            
        }
        else if(query == NULL){
            query = 'SELECT Id, SAP_Sold_to__c, BillingState, BillingPostalCode, Customer_Group__c, Territory_Key__c FROM Account WHERE Territory_Alignment_Skip__c = FALSE ORDER BY BillingState, BillingPostalCode';            
        }

        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        
        list<Account> newTrigger = (list<Account>)scope;
        
        territory_Account_Alignment newTAA = new territory_Account_Alignment();
        newTAA.startAlignAccounts(newTrigger);
        
        territory_Account_Shares newTAS = new territory_Account_Shares();
        newTAS.startAddAccountShares(newTrigger);
        
    } 
    
    global void finish(Database.BatchableContext BC){
        //UserInfo.getUserEmail();
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob 
                          WHERE Id = :BC.getJobId()];
        
        string emailSubj = 'Maintenance [ZPSA Account Alignment Completed]: ' + a.Status + ' (' + a.JobItemsProcessed + '/' + a.NumberOfErrors + ')';
        string emailBody = 'The batch Apex job processed ' + a.JobItemsProcessed + ' batches with '+ a.NumberOfErrors + ' failures.';
        
        String obj = 'Account__c';
        Global_Maintenance check = new Global_Maintenance();
        list<String> emailList = check.getEmailList(obj);
        if(emailList.size() > 0){
            system.debug('Sending Email Now!');
            check.sendEmailHelper(emailSubj,emailBody,emailList);
        }
        
        /*
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('ZPSA Account Alignment Completed: ' + a.Status + ' (' + a.JobItemsProcessed + '/' + a.NumberOfErrors + ')');
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
    }
    
}