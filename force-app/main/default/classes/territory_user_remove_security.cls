global class territory_user_remove_security implements Database.Batchable<sObject> {
    public String query;
    public String usrId;
    public String uname;
    
    global territory_user_remove_security(String q) {
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        String oid;
        String uid = usrId;
        uid = uid.left(15);
        
        system.debug('Starting Execute - Type: Delete');
        system.debug('User Id: ' + usrId);
        
        set<Id> acctIds = new set<id>();
        
        for(sObject ta : scope)
        {
            oid = String.valueOf(ta.get('Account_Owner_Id__c'));
            
            if(uid != oid){
                acctIds.add(String.valueOf(ta.get('Account__c')));      
            }
        }
        
        if(acctIds.size() > 0){
            list<AccountTeamMember> delAccountTeamMember = [SELECT Id, AccountId, UserId  
                                                            FROM AccountTeamMember 
                                                            WHERE AccountId IN :acctIds
                                                            AND UserId = :usrId];
            if(delAccountTeamMember.size() > 0){
                system.debug('delAccountTeamMember: ' + delAccountTeamMember);
                delete delAccountTeamMember;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        //UserInfo.getUserEmail();
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Removing ' + uname + ' from Accounts: ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}