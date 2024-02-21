global class territory_user_build_security implements Database.Batchable<sObject> {
    public String query;
    public String usrId;
    public String uname;
    
    global territory_user_build_security(String q) {
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        String bu;
        String aid;
        String oid;
        String uid = usrId;
        uid = uid.left(15);
        
        system.debug('Starting Execute - Type: Build');
        system.debug('User Id: ' + usrId);
        
        list<AccountTeamMember> addAccountTeamMember = new list<AccountTeamMember>();
        list<AccountShare> addAccountShare = new list<AccountShare>();
        
        for(sObject ta : scope)
        {
            
            bu = String.valueOf(ta.get('Business_Unit__c'));
            aid = String.valueOf(ta.get('Account__c'));
            oid = String.valueOf(ta.get('Account_Owner_Id__c'));

            if(uid != oid){
                
                if(bu == NULL){
                    bu = 'Sales Rep';
                }
                
                AccountTeamMember addATM = new AccountTeamMember(
                    AccountId = aid,
                    TeamMemberRole = bu,
                    UserId = usrId
                );
                //system.debug('addATM: ' + addATM);
                addAccountTeamMember.add(addATM);
                
                
                AccountShare addAS = new AccountShare(
                    AccountId = aid,
                    //Changed from Read-Only to Private/None (04/Sept/2015 - ESC)
                    OpportunityAccessLevel = 'None',
                    CaseAccessLevel = 'None',
                    AccountAccessLevel = 'Edit',
                    UserOrGroupId = usrId
                );
                addAccountShare.add(addAS);
            }
        }
        
        // Adds all of the Account Team Members based off of the Territory Alignment records
        if(addAccountTeamMember.size() > 0){
            //System.debug('addAccountTeamMember-->' + addAccountTeamMember);
            insert addAccountTeamMember;
        }
        // Adds all of the Account Shares back based off the above logic
        if(addAccountShare.size() > 0){
            //System.debug('insert addAccountShare-->' + addAccountShare);
            insert addAccountShare;
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
        mail.setSubject('Adding ' + uname + ' to Accounts: ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}