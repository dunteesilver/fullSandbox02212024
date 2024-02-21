global class BatchTerrUserTriggerDelete implements Database.Batchable<sObject> {

public Id user;
public Id territory;
public Id oldUser;
public Id oldTerritory;

//lists to remove teams
List<AccountTeamMember> removeTeam = new List<AccountTeamMember>();
List<String> removeAcct = new List<String>();

global Database.querylocator start(Database.BatchableContext BC){
    String query = 'SELECT Id, Account__c FROM Territory_Account__c WHERE Territory_Master__c=:oldTerritory';
    return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){

    for(sObject s : scope){
        Territory_Account__c ta = (Territory_Account__c) s;
        removeAcct.add(ta.Account__c);
    }
    for(AccountTeamMember atm : [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE UserId = :oldUser AND AccountId IN :removeAcct])
    {
        removeTeam.add(atm);
    }
    
    
    
    //DML
    if(removeTeam.size() > 0){
        delete removeTeam;
    }
}

global void finish(Database.BatchableContext BC){
  
  //BatchSalesShareDelete BSDTrig = new BatchSalesShareDelete();
  //BSDTrig.oldUser = oldUser;
  //BSDTrig.oldTerritory = oldTerritory;
  //ID batchprocessid4 = Database.executeBatch(BSDTrig,100);
  //System.debug('Returned batch process ID: ' + batchProcessId4);
  
}


}