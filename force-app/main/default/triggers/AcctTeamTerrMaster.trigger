trigger AcctTeamTerrMaster on Territory_Master__c (before delete) {
	
	List<AccountTeamMember> removeTeam = new List<AccountTeamMember>();
    List<String> removeAcct = new List<String>();
    List<String> removeUser = new List<String>();
	
    Territory_Master__c[] oldRelationship=trigger.old;
	
	for(Territory_Account__c removeList : [SELECT Account__c FROM Territory_Account__c WHERE Territory_Master__c = :oldRelationship[0].Id]) {
    	removeAcct.add(removeList.Account__c);
    }
    for(Territory_User__c removeUserList : [SELECT User__c FROM Territory_User__c WHERE Territory_Master__c = :oldRelationship[0].Id]) {
    	removeUser.add(removeUserList.User__c);
    }
	for(AccountTeamMember atm : [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE UserId IN :removeUser AND AccountId IN :removeAcct])
	{
		removeTeam.add(atm);
	}	
	
	//DML
    if(removeTeam.size() > 0){
	 	delete removeTeam;
    }
}