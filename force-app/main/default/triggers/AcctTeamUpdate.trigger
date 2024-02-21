trigger AcctTeamUpdate on Territory_User__c (after insert, after update, after delete) {
    
    //This trigger handles inserts, updates and delets from the Territory_User__c object    
    
    //list to hold new account teams
    List<AccountTeamMember> acctMembers = new List<AccountTeamMember>();
    
    //list to hold new account sharing rules
    List<AccountShare> acctSharingRules = new List<AccountShare>();
    
    //lists to remove teams
    List<AccountTeamMember> removeTeam = new List<AccountTeamMember>();
    List<String> removeAcct = new List<String>();
    
    //Initialize trigger
    Territory_User__c[] newRelationship=trigger.new;
    Territory_User__c[] oldRelationship=trigger.old;
    
    


    
    //Assign new account team members
    if(Trigger.isInsert && Territory_User__c.Territory_Master__c != null){
        //Determining User's BU
        User u = [SELECT Business_Unit__c FROM User WHERE Id=:newRelationship[0].User__c];
    
        String bu;
    
        if(u.Business_Unit__c != null){
            bu=u.Business_Unit__c;
        } else {
            bu='Sales Rep';
        }
        

        Integer size1 = [SELECT Count() FROM Territory_Account__c WHERE Territory_Master__c= :newRelationship[0].Territory_Master__c LIMIT 2000];
        
        if(size1 < 200){

            for (Territory_Account__c accts: [SELECT Account__c FROM Territory_Account__c WHERE Territory_Master__c= :newRelationship[0].Territory_Master__c]){
                AccountTeamMember addRecord = new AccountTeamMember();
                addRecord.AccountId = accts.Account__c;
                addRecord.TeamMemberRole = bu;
                addRecord.UserId = newRelationship[0].User__c;
                acctMembers.add(addRecord);
                
    //            AccountShare addSharing = new AccountShare();
    //          addSharing.AccountId = accts.Account__c;
    //          addSharing.OpportunityAccessLevel = 'None';
    //          addSharing.CaseAccessLevel = 'Read';
    //          addSharing.AccountAccessLevel = 'Edit';
    //          addSharing.UserOrGroupId = newRelationship[0].User__c;
    //          acctSharingRules.add(addSharing);
                
                acctSharingRules.add(new AccountShare(
                        AccountId = accts.Account__c,
                        OpportunityAccessLevel = 'None',
                        CaseAccessLevel = 'Read',
                        AccountAccessLevel = 'Edit',
                        UserOrGroupId = newRelationship[0].User__c)
                );
            }
        
        }else{
            BatchTerrUserTriggerInsert BTrig = new BatchTerrUserTriggerInsert();
            BTrig.user = newRelationship[0].User__c;
            BTrig.territory = newRelationship[0].Territory_Master__c;
            ID batchprocessid = Database.executeBatch(BTrig);
            System.debug('Returned batch process ID: ' + batchProcessId);
        }
    }else if(Trigger.isUpdate){

        //Determining User's BU
        User u = [SELECT Business_Unit__c FROM User WHERE Id=:newRelationship[0].User__c];
    
        String bu;
    
        if(u.Business_Unit__c != null){
            bu=u.Business_Unit__c;
        } else {
            bu='Sales Rep';
        }
    
        if(newRelationship[0].User__c != null && newRelationship[0].Territory_Master__c != null){
            
            Integer size2 = [SELECT count() FROM Territory_Account__c WHERE Territory_Master__c= :oldRelationship[0].Territory_Master__c LIMIT 2000];
        
            if(size2 < 200){
                for(Territory_Account__c removeList : [SELECT Account__c FROM Territory_Account__c WHERE Territory_Master__c= :oldRelationship[0].Territory_Master__c]) {
                removeAcct.add(removeList.Account__c);
                }
                for(AccountTeamMember atm : [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE UserId = :oldRelationship[0].User__c AND AccountId IN :removeAcct])
                {
                    removeTeam.add(atm);
                }
            }else{
                BatchTerrUserTriggerDelete BTrig = new BatchTerrUserTriggerDelete();
                BTrig.oldUser = oldRelationship[0].User__c;
                BTrig.oldTerritory = oldRelationship[0].Territory_Master__c;
                ID batchprocessid = Database.executeBatch(BTrig,100);
                System.debug('Returned batch process ID: ' + batchProcessId);
            }
            
            Integer size3 = [SELECT count() FROM Territory_Account__c WHERE Territory_Master__c= :newRelationship[0].Territory_Master__c LIMIT 2000];
            
            if(size3 < 200){
                for (Territory_Account__c accts: [SELECT Account__c FROM Territory_Account__c WHERE Territory_Master__c= :newRelationship[0].Territory_Master__c]){
                    AccountTeamMember addRecord = new AccountTeamMember();
                    addRecord.AccountId = accts.Account__c;
                    addRecord.TeamMemberRole = bu;
                    addRecord.UserId = newRelationship[0].User__c;
                    acctMembers.add(addRecord);
                
                    AccountShare addSharing = new AccountShare();
                    addSharing.AccountId = accts.Account__c;
                    addSharing.OpportunityAccessLevel = 'None';
                    addSharing.CaseAccessLevel = 'Read';
                    addSharing.AccountAccessLevel = 'Edit';
                    addSharing.UserOrGroupId = newRelationship[0].User__c;
                    acctSharingRules.add(addSharing);
                }
            }else{
                BatchTerrUserTriggerInsert BDTrig = new BatchTerrUserTriggerInsert();
                BDTrig.user = newRelationship[0].User__c;
                BDTrig.territory = newRelationship[0].Territory_Master__c;
                ID batchprocessid1 = Database.executeBatch(BDTrig);
                System.debug('Returned batch process ID: ' + batchProcessId1);
            }
            
        }
    } else if(Trigger.isDelete && Territory_User__c.Territory_Master__c != null){   
        Integer size4 = [SELECT count() FROM Territory_Account__c WHERE Territory_Master__c= :oldRelationship[0].Territory_Master__c LIMIT 2000];
        
        if(size4 < 200){
            for(Territory_Account__c removeList : [SELECT Account__c FROM Territory_Account__c WHERE Territory_Master__c= :oldRelationship[0].Territory_Master__c]) {
                removeAcct.add(removeList.Account__c);
            }
            for(AccountTeamMember atm : [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE UserId = :oldRelationship[0].User__c AND AccountId IN :removeAcct])
            {
                removeTeam.add(atm);
            }
        }else{
            BatchTerrUserTriggerDelete BDTrig = new BatchTerrUserTriggerDelete();
            BDTrig.oldUser = oldRelationship[0].User__c;
            BDTrig.oldTerritory = oldRelationship[0].Territory_Master__c;
            ID batchprocessid = Database.executeBatch(BDTrig,100);
            System.debug('Returned batch process ID: ' + batchProcessId);
        }
    }
    
    //DML
    if(acctMembers.size() > 0){
        insert acctMembers;
    }
    if(acctSharingRules.size() > 0){
        insert acctSharingRules;
    }
    if(removeTeam.size() > 0){
        delete removeTeam;
    }
}