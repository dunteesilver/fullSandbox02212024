global class BatchAcctTeamAssignment implements Database.Batchable<sObject> {

//list to hold new account teams
List<AccountTeamMember> acctMembers = new List<AccountTeamMember>();

//list to hold new account sharing rules
List<AccountShare> acctSharingRules = new List<AccountShare>();

// list to hold user roles
list<UserRole> userRoles = new list<UserRole>();

// set to hold role Ids
set<Id> roleIds = new set<Id>();

// variable to store opportunity access level
string oppAccessLevel;

global Database.querylocator start(Database.BatchableContext BC){
    String query = 'SELECT Id, Account__c, Account__r.ERP_Active__c, Territory_Master__c FROM Territory_Account__c';
    return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){

    for(sObject s : scope){
        Territory_Account__c ta = (Territory_Account__c) s;

        List<Territory_User__c> userList = [SELECT User__c FROM Territory_User__c WHERE Territory_Master__c = :ta.territory_master__c];
        system.debug(userList.size());
        if (userList.size() > 0 && ta.Account__c != null){
            // added
            string roleName = label.UserRoleForOpp;
            if(string.isNotBlank(roleName))
                userRoles = [SELECT Id,Name FROM UserRole where name =:roleName ];
            if(userRoles.size()>0){
                for(UserRole urole: userRoles){
                    roleIds.add(urole.Id);
                }
            }

            for(Territory_User__c uu : userList){
                User u = [SELECT Business_Unit__c, isActive,UserRoleId FROM User WHERE Id=:uu.User__c];
                String bu;

                oppAccessLevel = 'None';

                if(u.isActive == true){
                    if(u.Business_Unit__c != null){
                        bu=u.Business_Unit__c;
                    } else {
                        bu='Sales Rep';
                    }

                    // if the user role is 'AR Inside Sales Rep', set 'Read' access to opportunity
                    if(roleIds.contains(u.UserRoleId)){
                        oppAccessLevel = 'Read';
                    }

                    //if((u.Business_Unit__c == 'Interventional' && ta.Account__r.ERP_Active__c == true) || u.Business_Unit__c != 'Interventional'){
                    if(ta.Account__r.ERP_Active__c == true){
                        AccountTeamMember addRecord = new AccountTeamMember();
                        addRecord.AccountId = ta.Account__c;
                        addRecord.TeamMemberRole = bu;
                        addRecord.UserId = uu.User__c;
                        acctMembers.add(addRecord);

                        acctSharingRules.add(new AccountShare(
                            AccountId = ta.Account__c,
                            OpportunityAccessLevel = oppAccessLevel,
                            CaseAccessLevel = 'None',
                            AccountAccessLevel = 'Edit',
                            UserOrGroupId = uu.User__c)
                        );
                    }

                }
            }
        }
    }

    //DML
    if(acctMembers.size() > 0){
        insert acctMembers;
    }
    if(acctSharingRules.size() > 0){
        insert acctSharingRules;
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