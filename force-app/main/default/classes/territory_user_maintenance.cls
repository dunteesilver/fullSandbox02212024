public class territory_user_maintenance {
    
    public static void Build_Account_Team(List<Territory_User__c> newTrigger,string bType){
        
        system.debug('Starting Build_Account_Team Class');

        if(master_TriggerHelperClass.qd('territory_user_maintenance')){
            string uid;
            string tid;
            string uname;
            
            for(Territory_User__c tu : newTrigger){
                uid = tu.User__c;
                tid = tu.Territory_Master__c;
                uname = tu.User_Full_Name__c;
            }
            system.debug('User ID: ' + uid);
            system.debug('Territory ID: ' + tid);
            
            string query = 'SELECT Account__c, Account_Owner_Id__c, Business_Unit__c ' + 
                'FROM Territory_Assignment__c ' +                                                  
                'WHERE Account__r.Territory_Alignment_Skip__c = FALSE AND Territory__r.Id = \'' + tid + '\'';
            system.debug('query: ' + query);
            
            if(tid != NULL && uid != NULL){
                try{
                if(bType == 'add'){
                    territory_user_build_security usrBuild = new territory_user_build_security(query);
                    usrBuild.query = query;
                    usrBuild.usrId = uid;
                    usrBuild.uname = uname;
                    ID batchprocessid = Database.executeBatch(usrBuild);                 
                }
                else{
                    territory_user_remove_security usrRemove = new territory_user_remove_security(query);
                    usrRemove.query = query;
                    usrRemove.usrId = uid;
                    usrRemove.uname = uname;
                    ID batchprocessid = Database.executeBatch(usrRemove);
                }
                }
                catch(Exception ex){
                    system.debug('could not start territory user add/remove security batch');
                }
                
            }  
            

        } // Quick Disable        
    }
    
    public static void checkPrimaryTerritory(List<Territory_User__c> newTrigger){
        // Test Class: territory_user_security_test

        // This Class looks to make sure that only one Territory User is active at one time.
        // If Created or Updated with Primary Checked/True - Will validate that no other Territory is set Primary and if so unset it.
        // If Created or Updated with Primary Unchecked/False - Will validate that if no other Territory is set Primary that the record is Checked/True.
        // ESC - 20Jul2016

      /*  set<Id> onlyOneActiveCheck;
       onlyOneActiveCheck = new set<Id>();
        set<Id> autoSetActiveCheck;
      autoSetActiveCheck  = new set<Id>();*/
        
        list<Territory_User__c> updateTU;
        Set<Id> TerritoryMasterIds =new Set<Id>();
        
        for(Territory_User__c tu : newTrigger) {
        TerritoryMasterIds.add(tu.Territory_Master__c); 
        }
        Map<Id,Territory_Master__c>TerritoryMasters =new Map<Id,Territory_Master__c>([SELECT Id,Sales_Rep__c,Primary_Territory_User__c From Territory_Master__c Where ID IN:TerritoryMasterIds]);
        
       // list<Territory_User__c> checkActiveTU;
       
        updateTU=new list<Territory_User__c>();
        for(Territory_User__c tu : newTrigger){
                
                     Territory_Master__c tm= TerritoryMasters.get(tu.Territory_Master__c);
                    Id repId = string.isNotEmpty(tm.Sales_Rep__c) ? tm.Sales_Rep__c : tm.Primary_Territory_User__c;                    
                    Territory_User__c newTU = new Territory_User__c(
                        Id = tu.Id,
                        Primary__c = (repId==tu.User__c)
                    );
                    updateTU.add(newTU);                    
                
            }
       /* checkActiveTU = new list<Territory_User__c>();
        
        for(Territory_User__c tu : newTrigger){
            if(tu.Role__c!='Clinical Specialists'){
            if(tu.Primary__c){
                onlyOneActiveCheck.add(tu.User__c);
            }
            else{
                autoSetActiveCheck.add(tu.User__c);
                checkActiveTU.add(tu);
            }
            }
        }
        if(onlyOneActiveCheck.size() > 0){
            for(Territory_User__c tu : [SELECT ID 
                                        FROM Territory_User__c 
                                        WHERE Id !=:newTrigger 
                                        AND User__c =:onlyOneActiveCheck 
                                        AND Primary__c = TRUE])
            {
                Territory_User__c newTU = new Territory_User__c(
                    Id = tu.Id,
                    Primary__c = FALSE
                );
                updateTU.add(newTU);
            }
        }
        if(autoSetActiveCheck.size() > 0){
            system.debug('checkActiveTU: ' + checkActiveTU);
            map<String, Boolean> tuCheck = new map<String, Boolean>();
            for(Territory_User__c tu : [SELECT User__c  
                                        FROM Territory_User__c 
                                        WHERE Id NOT IN:checkActiveTU 
                                        AND User__c =:autoSetActiveCheck 
                                        AND Primary__c = TRUE])
            {
                tuCheck.put(tu.User__c, TRUE);
                system.debug('Adding!');
            }
            for(Territory_User__c tu : checkActiveTU){
                if(tuCheck.get(tu.User__c) == TRUE){
                    system.debug(' AHA! ');
                }
                else{
                    system.debug(' Oh No...');
                    Territory_User__c newTU = new Territory_User__c(
                        Id = tu.Id,
                        Primary__c = TRUE
                    );
                    updateTU.add(newTU);                    
                }
            }
        }*/
        if(updateTU.size() > 0){
            update updateTU;
        }
    }
    
    public static void checkSalesRegion(List<Territory_Master__c> newTrigger){
        set<String> tnumSet = new set<String>();
        map<String, String> tnumMap = new map<String, String>();
        
        for(Territory_Master__c tm : newTrigger){
            if(tm.Region_Number__c != NULL && tm.Region_Name__c == NULL){
                tnumSet.add(tm.Region_Number__c);
            }
        }
        if(tnumSet.size() > 0){
            for(Territory_Master__c tm : [SELECT Territory_Number__c, Territory_Name__c  
                                          FROM Territory_Master__c 
                                          WHERE Territory_Number__c =:tnumSet])
            { 
                tnumMap.put(tm.Territory_Number__c, tm.Territory_Name__c);
            }
            for(Territory_Master__c tm : newTrigger){
                if(tm.Region_Number__c != NULL && tm.Region_Name__c == NULL && tnumMap.get(tm.Region_Number__c) != NULL){
                    tm.Region_Name__c = tnumMap.get(tm.Region_Number__c);
                }
            }
        }
    }
    
    /*
    @future
    public static void buildAccountTeam(set<Id> tmId,set<Id> uId){
        
        if(master_TriggerHelperClass.qd('buildAccountTeam')){
            system.debug('Starting the BuildAccountTeam Class');
            
            system.debug('Territory Master ID: ' + tmId);
            system.debug('User ID: ' + uId);
            // Start
            set<Id> talign = new set<Id>();
            set<Id> assignSet = new set<Id>();
            
            //tuId
            //Territory_Alignment__c 
            /*
            for(Territory_Alignment__c ta : [SELECT Id 
                                             FROM Territory_Alignment__c
                                             WHERE (Territory__c = :tuset 
                                                    OR Territory2__c = :tuset 
                                                    OR Territory3__c = :tuset) 
                                             AND ZPSA_Table__c = 'A689'])
            {
                talign.add(ta.Id);
            }
            system.debug('talign: ' + talign );
            
            
            for(Territory_Assignment__c ta : [SELECT Id 
                                              FROM Territory_Assignment__c
                                              WHERE Territory__r.Id = :tmId])
            {
                assignSet.add(ta.Id);
            }
            
            */
            
            // END PASTE
            // 
            
            /*    
            list<AccountTeamMember> addAccountTeamMember = new list<AccountTeamMember>();
            list<AccountShare> addAccountShare = new list<AccountShare>();
            String bu;
            string tmasterId;
            string usrId;
            
            if(tmId.size() == 1){
                
                for(Id u : tmId){
                    tmasterId = u;
                }
                
                for(Id u : uId){
                    usrId = u;
                }

                for(Territory_Assignment__c ta : [SELECT Account__c, Territory__c, Territory_Number__c, Territory__r.User_Count__c, 
                                                  Territory__r.Business_Unit__c 
                                                  FROM Territory_Assignment__c 
                                                  WHERE Territory__r.Id = :tmasterId])
                {
                    if(ta.Territory__r.Business_Unit__c == NULL){
                        bu = 'Sales Rep';
                    }
                    else{
                        bu = ta.Territory__r.Business_Unit__c;
                    }
                    AccountTeamMember addATM = new AccountTeamMember(
                        AccountId = ta.Account__c,
                        TeamMemberRole = bu,
                        UserId = usrId
                    );
                    system.debug('addATM: ' + addATM);
                    addAccountTeamMember.add(addATM);
                    
                    AccountShare addAS = new AccountShare(
                        AccountId = ta.Account__c,
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
                System.debug('insert addAccountTeamMember-->' + addAccountTeamMember);
                insert addAccountTeamMember;
            }
            // Adds all of the Account Shares back based off the above logic
            if(addAccountShare.size() > 0){
                System.debug('insert addAccountShare-->' + addAccountShare);
                insert addAccountShare;
            }
        }
        
    }
*/

}