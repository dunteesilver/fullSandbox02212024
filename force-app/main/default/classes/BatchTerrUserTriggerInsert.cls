global class BatchTerrUserTriggerInsert implements Database.Batchable<sObject> {

public Id user;
public Id territory;


//list to hold new account teams
List<AccountTeamMember> acctMembers = new List<AccountTeamMember>();
    
//list to hold new account sharing rules
List<AccountShare> acctSharingRules = new List<AccountShare>();

global Database.querylocator start(Database.BatchableContext BC){
    String query = 'SELECT Id, Account__c FROM Territory_Account__c WHERE Territory_Master__c=:territory';
    return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){

    for(sObject s : scope){
        Territory_Account__c ta = (Territory_Account__c) s;
    
            User u = [SELECT Business_Unit__c, isActive FROM User WHERE Id=:user];
            String bu;

            if(u.isActive == true){
                if(u.Business_Unit__c != null){
                    bu=u.Business_Unit__c;
                } else {
                    bu='Sales Rep';
                }
            
            
                AccountTeamMember addRecord = new AccountTeamMember();
                addRecord.AccountId = ta.Account__c;
                addRecord.TeamMemberRole = bu;
                addRecord.UserId = user;
                acctMembers.add(addRecord);

                acctSharingRules.add(new AccountShare(
                    AccountId = ta.Account__c,
                    OpportunityAccessLevel = 'None',
                    CaseAccessLevel = 'Read',
                    AccountAccessLevel = 'Edit',
                    UserOrGroupId = user)
                );
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

  //BatchSalesShareInsert BSDTrig = new BatchSalesShareInsert();
  //BSDTrig.user = user;
  //BSDTrig.territory = territory;
  //ID batchprocessid2 = Database.executeBatch(BSDTrig);
  //System.debug('Returned batch process ID: ' + batchProcessId2);
}


}