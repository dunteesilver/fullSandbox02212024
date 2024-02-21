global class ZPSA_Maintenance_Batch Implements Database.Batchable<sObject> {
    // 21July2016 - ESC
    // Test Class: territory_Account_Shares_TEST
    public String query;
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //String query;

        //query = 'SELECT Id FROM Territory_Alignment__c WHERE LastModifiedDate != TODAY LIMIT 50000';
        
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        list<Territory_Alignment__c> tRules = (list<Territory_Alignment__c>)scope;
        list<Territory_Alignment__c> tUpdates = new list<Territory_Alignment__c>();
        
        for(Territory_Alignment__c ta : tRules){
            Territory_Alignment__c newTA = new Territory_Alignment__c(
                Id = ta.Id,
                Active__c = FALSE
            );
            tUpdates.add(newTA);
        }
        
        system.debug('tUpdates: ' + tUpdates);
        if(tUpdates.size() > 0){
            update tUpdates;
        }
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
        
        string emailSubj = 'Maintenance [Weekly ZPSA Maintenance]: ' + a.Status + ' (' + a.JobItemsProcessed + '/' + a.NumberOfErrors + ')';
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
        mail.setSubject('ZPSA Maintenance: ' + a.Status + ' (' + a.JobItemsProcessed + '/' + a.NumberOfErrors + ')');
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); */
        
    }
    
}