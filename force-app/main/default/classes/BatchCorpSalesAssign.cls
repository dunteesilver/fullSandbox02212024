global class BatchCorpSalesAssign implements Database.Batchable<sObject> {

//list to hold new account teams
List<AccountTeamMember> acctMembers = new List<AccountTeamMember>();
List<AccountTeamMember> acctMembersRemove = new List<AccountTeamMember>();
    
//list to hold new account sharing rules
List<AccountShare> acctSharingRules = new List<AccountShare>();

List<OpportunityTeamMember> oppTeam = new List<OpportunityTeamMember>();
List<OpportunityTeamMember> oppTeamRemove = new List<OpportunityTeamMember>();
List<OpportunityShare> oppSharingRules = new List<OpportunityShare>();

Account idn;

global Database.querylocator start(Database.BatchableContext BC){
    String query = 'SELECT Id, IDN__C, OwnerId FROM Account';
    return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){

    for(sObject s : scope){
        Account a = (Account) s;
        
        if(a.IDN__C != null){
            idn = [SELECT Id, OwnerId FROM Account WHERE Id=:a.IDN__c LIMIT 1];
        }
        
        String bu;
        bu='Corporate Sales';
        
        
        For(AccountTeamMember AT : [SELECT UserId FROM AccountTeamMember WHERE AccountId = :a.Id AND TeamMemberRole='Corporate Sales']){
            if(AT != null){
                if(idn == null || AT.UserId != idn.OwnerId){
                    acctMembersRemove.Add(AT);
                }
            }
        }
        
        if(idn != null && idn.OwnerId != a.OwnerId){
            
            AccountTeamMember addRecord = new AccountTeamMember();
            addRecord.AccountId = a.Id;
            addRecord.TeamMemberRole = bu;
            addRecord.UserId = idn.ownerid;
            acctMembers.add(addRecord);
    
            acctSharingRules.add(new AccountShare(
                AccountId = a.Id,
                OpportunityAccessLevel = 'Edit',
                CaseAccessLevel = 'Read',
                AccountAccessLevel = 'Edit',
                UserOrGroupId = idn.ownerid)
            );
        }
        
        for(Opportunity opps : [SELECT Id, AccountId, OwnerId FROM Opportunity WHERE AccountId =:a.Id AND isclosed = FALSE]){

            List<OpportunityTeamMember> oppsToRemove = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId = :opps.Id AND TeamMemberRole = 'Corporate Sales (Auto Add)'];
            for(OpportunityTeamMember otm: oppsToRemove){
                oppTeamRemove.add(otm);
            }
        
            if(idn != null && opps.OwnerId != idn.Ownerid){            
                OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = opps.Id,
                    UserId = idn.ownerid,
                    TeamMemberRole = 'Corporate Sales (Auto Add)');
                    oppTeam.add(otm);
                    
                    oppSharingRules.add(new OpportunityShare(
                        OpportunityId = opps.Id,
                        OpportunityAccessLevel = 'Edit',
                        UserOrGroupId = idn.ownerid)
                    );
            }
        }
        
    }
    
    
    
    //DML
    if(acctMembersRemove.size() > 0){
        delete acctMembersRemove;
    }
    if(acctMembers.size() > 0){
        insert acctMembers;
    }
    if(acctSharingRules.size() > 0){
        insert acctSharingRules;
    }
    if(oppTeamRemove.size() > 0){
        delete oppTeamRemove;
    }
    if(oppTeam.size() > 0){
        insert oppTeam;
    }
    if(oppSharingRules.size() > 0){
        insert oppSharingRules;
    }
    
    
}

global void finish(Database.BatchableContext BC){

}


}