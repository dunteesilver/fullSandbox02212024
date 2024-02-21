public class territory_Account_Shares {
    public void startAddAccountShares(List<Account> newTrigger){
        addAccountShares(newTrigger);
    }
    public static void addAccountShares(List<Account> newTrigger){
        
        System.debug('-- Starting territory_Account_Shares -- ');
        // 
        // Test Class: territory_Account_Shares_TEST
        // 

        // Quick Disabled is used to toggle this class on and off WITHOUT the need of code updates
        // This checks to make sure that under 'Custom Settings / Quick Disable' that 'AddAccountShares' is set to 'True'
        if(master_TriggerHelperClass.qd('addAccountShares')){
            
            String bu;
            list<AccountTeamMember> addAccountTeamMember = new list<AccountTeamMember>();
            list<AccountShare> addAccountShare = new list<AccountShare>();            
            
            // New User Map - This builds out the territory/user map
            String compareTerritory;
            String tUserId;
            integer tCount = 0;
            Map<String, Id> tuMap = new Map<String, Id>();
            for(Territory_User__c userMap : [SELECT User__c, Territory_Number__c  
                                             FROM Territory_User__c 
                                             WHERE User__r.isActive = TRUE 
                                             ORDER BY Territory_Number__c])
            {
                
                if(compareTerritory == userMap.Territory_Number__c){                    
                    tCount = tCount + 1;
                    tuMap.put(userMap.Territory_Number__c + '-' + tCount, userMap.User__c);
                }
                else{
                    tCount = 0;
                    tuMap.put(userMap.Territory_Number__c + '-' + tCount, userMap.User__c);
                }
                compareTerritory = userMap.Territory_Number__c;
            }

            map<String,Boolean> asCheck = new map<String,Boolean>();
            map<String,Boolean> atCheck = new map<String,Boolean>();
            string checkKey;

            for(AccountShare accts : [SELECT UserOrGroupId, AccountId 
                                      FROM AccountShare 
                                      WHERE RowCause = 'Team' 
                                      AND AccountId IN :newTrigger])
            {
                checkKey = accts.UserOrGroupId + '-' + accts.AccountId;
                if(checkKey.left(3) == '005'){
                    asCheck.put(checkKey,TRUE);                    
                }
            }
            
            for(AccountTeamMember at : [SELECT UserId, AccountId
                                        FROM AccountTeamMember 
                                        WHERE AccountId IN :newTrigger])
            {
                checkKey = at.UserId + '-' + at.AccountId;
                if(checkKey.left(3) == '005'){
                    atCheck.put(checkKey,TRUE);    
                }
            }            
            
            set<Id> usrIds = new set<Id>();
            // Main Logic for assigning Account Team and Shares
            for(Territory_Assignment__c ta : [SELECT Account__c, Account__r.OwnerId, Territory__c, Territory_Number__c, Territory__r.User_Count__c, 
                                              Territory__r.Business_Unit__c 
                                              FROM Territory_Assignment__c 
                                              WHERE Account__r.id IN :newTrigger 
                                              AND Territory__r.User_Count__c > 0])
            {
                
                for(Integer tuc = 0; tuc < ta.Territory__r.User_Count__c; tuc++){
                    //system.debug('Tuc + Territory: ' + tuc + ' + ' + ta.Territory_Number__c);
                    tUserId = tuMap.get(ta.Territory_Number__c + '-' + tuc);

                    // Check to make sure the territory and user exist/not inactive.
                    if(tUserId != NULL && tUserId != ta.Account__r.OwnerId){
                        //system.debug('tUserID and Account__r.OwnerId: ' + tUserId + ' - ' + ta.Account__r.OwnerId);
                        checkKey = tUserId + '-' + ta.Account__c;
                        // Check to make sure the Account Share and Account Team records don't already exist.
                        if(asCheck.get(checkKey) == NULL && atCheck.get(checkKey) == NULL){
                        //if(atCheck.get(checkKey) == NULL){
                            system.debug('Adding: ' + ta.Territory_Number__c + '-' + tuc);
                            if(ta.Territory__r.Business_Unit__c == NULL){
                                bu = 'Sales Rep';
                            }
                            else{
                                bu = ta.Territory__r.Business_Unit__c;
                            }
                            AccountTeamMember addATM = new AccountTeamMember(
                                AccountId = ta.Account__c,
                                TeamMemberRole = bu,
                                UserId = tuMap.get(ta.Territory_Number__c + '-' + tuc)
                            );
                            //system.debug('addATM: ' + addATM);
                            addAccountTeamMember.add(addATM);
                            
                            AccountShare addAS = new AccountShare(
                                AccountId = ta.Account__c,
                                //Changed from Read-Only to Private/None (04/Sept/2015 - ESC)
                                OpportunityAccessLevel = 'None',
                                CaseAccessLevel = 'None',
                                AccountAccessLevel = 'Edit',
                                UserOrGroupId = tuMap.get(ta.Territory_Number__c + '-' + tuc)
                            );
                            //system.debug('Add Account Share: ' + addAS);
                            addAccountShare.add(addAS);
                        }
                        ELSE{
                            usrIds.add(tUserId);
                            //system.debug('Skipping! ' + ta.Territory_Number__c + '-' + tuc);
                        }
                    }
                }
            }
            
            // Deletes all of the Account Team Members ** This will also pull the related Account Share Record **
            //This creates the list of existing Account Team Members that we reset to ensure data quality
            list<AccountTeamMember> removeAccountTeamMember = [SELECT Id  
                                                               FROM AccountTeamMember 
                                                               WHERE AccountId IN :newTrigger 
                                                               AND UserId NOT IN :usrIds];
            if(removeAccountTeamMember.size() > 0){
                system.debug('-- Removing Team Members: ' + removeAccountTeamMember);
                delete removeAccountTeamMember;
            }
            else{
                system.debug('-- Nothing to Delete! --');
            }
            
            list<AccountShare> removeAccountShares = [SELECT Id  
                                                       FROM AccountShare  
                                                       WHERE AccountId IN :newTrigger 
                                                       AND UserOrGroupId NOT IN :usrIds 
                                                     AND RowCause = 'Manual'];
            if(removeAccountShares.size() > 0){
                system.debug('-- Removing Shares: ' + removeAccountShares);
                delete removeAccountShares;
            }
            else{
                system.debug('-- Nothing to Delete! --');
            }
            
            // Adds all of the Account Team Members based off of the Territory Account record that ties the Territory Master and Account together
            if(addAccountTeamMember.size() > 0){
                System.debug('insert addAccountTeamMember-->' + addAccountTeamMember);
                //delete removeAccountTeamMember;
                insert addAccountTeamMember;
            }
            else{
                system.debug('-- Skipping Adding Account Team Members --');
            }
            // Adds all of the Account Shares back based off the above logic
            if(addAccountShare.size() > 0){
                //System.debug('insert addAccountShare-->' + addAccountShare);
                insert addAccountShare;
            }
            else{
                //system.debug('-- Skipping Adding Account Team Shares --');
            }

        }
        System.debug('-- Finished territory_Account_Shares -- ');
    }
    /*
    public static void addAccountShares_legacy(List<Account> newTrigger){
        
        // Quick Disabled is used to toggle this class on and off WITHOUT the need of code updates
        // This checks to make sure that under 'Custom Settings / Quick Disable' that 'AddAccountShares' is set to 'True'
        if(master_TriggerHelperClass.qd('addAccountShares_legacy')){
            
            System.debug('Starting territory_Account_Shares');
            
            String bu;
            list<AccountTeamMember> addAccountTeamMember = new list<AccountTeamMember>();
            list<AccountShare> addAccountShare = new list<AccountShare>();            
            
            //Create the list of Territories to use to filter our Territory Users
            list<String> terlist = new list<String>();
            for(Territory_Account__c t : [SELECT Territory_Master__r.Territory_Number__c 
                                          FROM Territory_Account__c 
                                          WHERE Account__c = :newTrigger])
            {
                terlist.add(t.Territory_Master__r.Territory_Number__c);
            }
            
            //List of users that we use to iteriate over when there is more than one Territory User assign to the Territory Master
            list<Territory_User__c> tuList = new list<Territory_User__c>();
            tuList = [SELECT User__r.id, Territory_Master__r.Business_Unit__c, Territory_Master__r.Territory_Name__c 
                      FROM Territory_User__c 
                      WHERE Territory_Master__r.name IN :terlist 
                      AND User__r.isActive = TRUE];
            
            //Efficient user map for when there is only one Territory User assigned to the Territory Master
            Map<Id, Id> uMap = new Map<Id, Id>();
            for(Territory_User__c userMap : [SELECT User__c, Territory_Master__c 
                                             FROM Territory_User__c 
                                             WHERE Territory_Master__r.name IN :terlist 
                                             AND User__r.isActive = TRUE])
            {
                uMap.put(userMap.Territory_Master__c, userMap.User__c);
            }
            System.debug('---------- uMap: ' + uMap);
            
            
            //This creates the list of existing Account Team Members that we reset to ensure data quality
            list<AccountTeamMember> removeAccountTeamMember = new list<AccountTeamMember>();
            removeAccountTeamMember = [SELECT AccountId, UserId 
                                       FROM AccountTeamMember 
                                       WHERE AccountId IN :trigger.newMap.keySet()];
            //System.debug('---------- removeAccountTeamMember: ' + removeAccountTeamMember);
            
            for(Territory_Account__c ta : [SELECT Territory_Master__c, Account__c, Territory_Master__r.Business_Unit__c, 
                                           Territory_Master__r.User_Count__c, Territory_Master__r.Territory_Name__c 
                                           FROM Territory_Account__c 
                                           WHERE Account__r.id IN :trigger.newMap.keySet()
                                           AND Territory_Master__r.User_Count__c > 0])
            {
                
                if(ta.Territory_Master__r.User_Count__c > 1){
                    for(Territory_User__c tu : tuList){
                        if(tu.Territory_Master__r.Territory_Name__c == ta.Territory_Master__r.Territory_Name__c){
                            
                            //Sometimes the BU is not set.
                            if(tu.Territory_Master__r.Business_Unit__c == NULL){
                                bu = 'Sales Rep';
                            }
                            else{
                                bu = tu.Territory_Master__r.Business_Unit__c;
                            }
                            AccountTeamMember addATM = new AccountTeamMember(
                                AccountId = ta.Account__c,
                                TeamMemberRole = bu,
                                UserId = tu.User__r.id
                            );
                            addAccountTeamMember.add(addATM);
                            
                            AccountShare addAS = new AccountShare(
                                AccountId = ta.Account__c,
                                //Changed from Read-Only to Private (04/Sept/2015 - ESC)
                                OpportunityAccessLevel = 'None',
                                CaseAccessLevel = 'None',
                                AccountAccessLevel = 'Edit',
                                UserOrGroupId = uMap.get(ta.Territory_Master__c)
                            );
                            addAccountShare.add(addAS);
                        }
                        
                    }
                }
                else{
                    if(uMap.get(ta.Territory_Master__c) != NULL){
                        
                        //Sometimes the BU is not set.
                        if(ta.Territory_Master__r.Business_Unit__c == NULL){
                            bu = 'Sales Rep';
                        }
                        else{
                            bu = ta.Territory_Master__r.Business_Unit__c;
                            //System.debug('bu = ta.Territory_Master__r.Business_Unit__c-->' + ta.Territory_Master__r.Business_Unit__c);
                        }
                        
                        // Creates the Account Team Member Record
                        AccountTeamMember addATM = new AccountTeamMember(
                            AccountId = ta.Account__c,
                            TeamMemberRole = bu,
                            UserId = uMap.get(ta.Territory_Master__c)
                        );
                        addAccountTeamMember.add(addATM);
                        
                        // Creates the Account Share Record
                        AccountShare addAS = new AccountShare(
                            AccountId = ta.Account__c,
                            //Changed from Read-Only to Private (04/Sept/2015 - ESC)
                            OpportunityAccessLevel = 'None',
                            CaseAccessLevel = 'None',
                            AccountAccessLevel = 'Edit',
                            UserOrGroupId = uMap.get(ta.Territory_Master__c)
                        );
                        addAccountShare.add(addAS);
                        System.debug('---------- uMap.put:Account__c' + ta.Account__c + 'UserID' + uMap.get(ta.Territory_Master__c));
                    }
                }
            }
            
            // Deletes all of the Account Team Members ** This will also pull the related Account Share Record **
            // Adds all of the Account Team Members based off of the Territory Account record that ties the Territory Master and Account together
            if(addAccountTeamMember.size() > 0){
                System.debug('insert addAccountTeamMember-->' + addAccountTeamMember);
                delete removeAccountTeamMember;
                insert addAccountTeamMember;
            }
            // Adds all of the Account Shares back based off the above logic
            if(addAccountShare.size() > 0){
                System.debug('insert addAccountShare-->' + addAccountShare);
                insert addAccountShare;
            }
        }
    }*/
}