global class Batch_IDN_Update implements Database.Batchable<sObject> {
    public String query;
    
    //constructor w/ option to pass query
    public Batch_IDN_Update(String q){
        query = q;
    }
    
    //constructor w/ option to pass query
    public Batch_IDN_Update(){
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        //check if query has value
        System.debug('*** query *** ' + query);
        if(query == ''){
            System.debug('*** query empty ***');
            query = 'SELECT Id, ParentId,Parent.IDN_Number__c, IDN_Number__c FROM Account WHERE Parent.IDN_Number__c != NULL';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        //Start New Stuff
        //System.debug('*** STARTING addIDNs METHOD IN account_Helper_Class ***');
        Map<String,String> idnMap = new Map<String,String>();
        List<Account> accsToUpdate = new List<Account>();
        List<Account> accList = [SELECT Id, IDN_Number__c FROM Account WHERE IDN_Number__c != NULL];
        System.debug('*** accList.size() *** ' + accList.size() );
        //for loop to create map of ID and IDN Number to Map
        for(Account curr : accList){
            idnMap.put(curr.Id,curr.Id);
        }//end of for accList
        
        //for loop to update IDN Lookup field on Accounts
        for(Account curr : scope){
            //check if ParentId of current Account matches any Id in Map
            if(curr.ParentId != NULL && idnMap.get(curr.ParentId) != NULL){
                curr.IDN__c = idnMap.get(curr.ParentId);
                accsToUpdate.add(curr);
            }//end if  
        }//end of for newTrigger
        
        //check list size before update
        if(accsToUpdate.size() > 0){
            Database.Update(accsToUpdate,false);
        }//end if
        //End New Stuff
    }//end void execute
    
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