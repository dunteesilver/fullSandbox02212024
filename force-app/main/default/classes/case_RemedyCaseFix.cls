public class case_RemedyCaseFix {

    
    private static boolean process = false;

    public static void fixEmail(List<Case> newTrigger, Map<Id,Case> oldTrigger, String Type){
        // Changes the account and related contact to the 'Teleflex Case Support Users' Account if the account is different.
        // Test Class: case_RemedyCaseFix_TestClass
        system.debug('Starting (fixEmail): Checking the Case Contact Account');
        if(master_TriggerHelperClass.qd('fixEmail')){
            Id tcsuAcct;
            
            try{
                tcsuAcct = [SELECT Id FROM Account WHERE Name = 'Teleflex Case Support Users' LIMIT 1].Id;   
            }
            catch(Exception e) {
            }
            system.debug('tcsuAcct: ' + tcsuAcct);
            
            // No reason to do any work if there's not a Teleflex Case Support Users Account
            if(tcsuAcct != NULL){
                
                String ConEmailStr;
                
                set<Id> cnSet = new set<Id>(); // Contact ID's
                set<String> cnEmails = new set<String>(); // Contact Email Addresses
                
                list<Case> updateCases = new list<Case>(); // List of Cases where the Account ID is different from the TFX Support Account ID
                
                map<String, Contact> ConEmailMap = new map<String, Contact>(); // Map that 'fixes' the Case Data to a new ContactID, AccountID, and BU
                
                // Phase 1 - Determine if we need to do work
                for (Case c : newTrigger){
                    system.debug('AccountID / tcsuAcct: ' + c.AccountId + '/' + tcsuAcct);
                    if(c.AccountId != tcsuAcct){
                        cnSet.add(c.ContactId);
                        updateCases.add(c); 
                    }    
                }
                
                system.debug('List of Contact IDs - cnSet: ' + cnSet);
                if(cnSet.size() > 0){ // Phase 2 - Check set size and do work
                    
                    // Create a list of emails to check
                    for(Contact con : [SELECT Email     
                                       FROM Contact 
                                       WHERE Id =:cnSet])
                    {
                        if(con.Email != NULL){
                            cnEmails.add(con.Email);                        
                        }
                    }
                    
                    // Create Map of Contacts for Fixing Data
                    for(Contact con : [SELECT Id, Email, Eloqua_Business_Unit__c, AccountId   
                                       FROM Contact 
                                       WHERE Email =:cnEmails 
                                       AND AccountId =:tcsuAcct])
                    {
                        if(con.Email != NULL){
                            ConEmailMap.put(con.Email, con);                        
                        }
                    }
                    
                    system.debug('Map of Contact Email Address to Contact - ConEmailMap: ' + ConEmailMap);
                    
                    // Final Loop
                    for(Case c : updateCases){
                        ConEmailStr = c.Contact_Email__c;
                        system.debug('c.Contact_Email__c: ' + c.Contact_Email__c);
                        if(ConEmailMap.get(ConEmailStr) != NULL){
                            system.debug('Updating Case/Contact: ' + c.CaseNumber + ' / ' + c.ContactId);
                            c.ContactId = ConEmailMap.get(ConEmailStr).Id;
                            c.AccountId = ConEmailMap.get(ConEmailStr).AccountId;
                            c.Requesting_Business__c = ConEmailMap.get(ConEmailStr).Eloqua_Business_Unit__c;
                            /*if(Type == 'update'){
                                if(oldTrigger.get(c.Id).Requesting_Business__c == c.Reason){
                                    c.Reason = c.Requesting_Business__c;
                                }                            
                            }*/
                        }
                    }
                }
            }  
        }
        
        system.debug('Finished (fixEmail): Checking the Case Contact Account');
        
    }

    public static void fixBUinsert(List<Case> newTrigger){
        system.debug('Starting (fixBUinsert): Checking the Case Business Unit (Insert/After)');
        if(master_TriggerHelperClass.qd('fixBUinsert')){
            list<Case> updateCases = new list<Case>();
            
            for (Case c : newTrigger){
                system.debug('Business_Unit__c: ' + c.Business_Unit__c + ' -- Requesting_Business__c:' + c.Requesting_Business__c);
                
                if(c.Business_Unit__c != NULL){
                    Case newCase = new Case(
                        Id = c.Id,
                        Requesting_Business__c = c.Business_Unit__c
                        //Reason = c.Business_Unit__c
                    );
                    updateCases.add(newCase);
                }
            }
            if(updateCases.size() > 0){
                update updateCases;
            }
        }
        
        system.debug('Finished (fixBUinsert): Checking the Case Business Unit (Insert/After)');
    }
    
    public static void fixBU(List<Case> newTrigger, Map<Id,Case> oldTrigger){
        system.debug('Starting (fixBU): Checking the Case Business Unit (Update/Before)');
        if(master_TriggerHelperClass.qd('fixBU')){
            for (Case c : newTrigger){
                system.debug('Business_Unit__c: ' + c.Business_Unit__c + ' -- Requesting_Business__c:' + c.Requesting_Business__c);
                if(c.Business_Unit__c != NULL){
                    if(c.Requesting_Business__c == NULL){
                        c.Requesting_Business__c = c.Business_Unit__c;
                    }
                    else if(oldTrigger.get(c.Id).ContactId != c.ContactId){
                        c.Requesting_Business__c = c.Business_Unit__c;
                        /*if(oldTrigger.get(c.Id).Requesting_Business__c == c.Reason){
                            c.Reason = c.Business_Unit__c;
                        }*/
                    }
                }
                system.debug('Reason: ' + c.Reason);
                /*if(c.Reason == NULL){
                    c.Reason = c.Requesting_Business__c;
                }*/
            }
            system.debug('Finished (fixBU): Checking the Case Business Unit (Update/Before)');
        }
        
    }
    
    public static void addToCaseTeam(List<Case> newTrigger, Map<Id,Case> oldTrigger, String Type){
        system.debug('Starting (addToCaseTeam): Checking the Case Business Unit (Insert & Update/After)');
        if(master_TriggerHelperClass.qd('addToCaseTeam')){
            Id teamRoleId;
            
            set<String> emails = new set<String>();
            set<String> usrSearch = new set<String>();
            
            map<string, boolean> crollcheckMap = new map<string, boolean>();
            map<Id, Id> crollMap = new map<Id, Id>();
            map<string, Id> removeCTM = new map<string, Id>();
            map<String, Id> usrMap = new map<String, Id>();
            
            // Create User Map - Just In Case we need to do work
            for(Case c : newTrigger){
                if(!c.Case_Created_By_Flow__c){ // Check to make sure the case was not created through the 'Submit a Question' Flow
                    if(c.User_Key__c != NULL){
                        usrSearch.add(c.User_Key__c);
                    }
                    if(Type == 'update'){ // Check to see whether to add the previous user to the User Map
                        if(oldTrigger.get(c.Id).User_Key__c != c.User_Key__c){
                            usrSearch.add(oldTrigger.get(c.Id).User_Key__c);
                        }
                    }
                }
            }
            if(usrSearch.size() > 0){
                for(User u : [SELECT Id,User_Key__c 
                              FROM User 
                              WHERE User_Key__c =:usrSearch 
                              AND IsActive = TRUE])
                {
                    usrMap.put(u.User_Key__c, u.Id);
                }
            }
            
            // Check to see if there's work to be done.
            for(Case c : newTrigger){
                if(!c.Case_Created_By_Flow__c){ // Ensure the Flow doesn't create a 'Contact' Case Team Member
                    if(Type == 'update'){
                        if(c.ContactId != oldTrigger.get(c.Id).ContactId && c.ContactId != NULL){
                            
                            // Try and Match the Contact to the User
                            if(usrMap.get(c.User_Key__c) != NULL){
                                crollMap.put(c.Id, usrMap.get(c.User_Key__c));
                            }
                            else{
                                crollMap.put(c.Id, c.ContactId);                    
                            }
                            
                            if(oldTrigger.get(c.Id).ContactId != NULL){
                                if(usrMap.get(oldTrigger.get(c.Id).User_Key__c) != NULL){
                                    removeCTM.put(c.Id, usrMap.get(oldTrigger.get(c.Id).User_Key__c));
                                }
                                else{
                                    removeCTM.put(c.Id, oldTrigger.get(c.Id).ContactId);
                                }
                            }
                        }
                        else if(oldTrigger.get(c.Id).ContactId != NULL && c.ContactId == NULL){
                            removeCTM.put(c.Id, oldTrigger.get(c.Id).ContactId);
                        }
                    }
                    else if(c.ContactId != NULL && Type == 'insert'){ 
                        // Try and Match the Contact to the User
                        if(usrMap.get(c.User_Key__c) != NULL){
                            crollMap.put(c.Id, usrMap.get(c.User_Key__c));
                        }
                        else{
                            crollMap.put(c.Id, c.ContactId);                    
                        }
                    }
                }
            }
            
            // Remove Old Case Team Members
            if(removeCTM.size() > 0){
                
                if(teamRoleId == NULL){
                    teamRoleId = [SELECT Id 
                                  FROM CaseTeamRole 
                                  WHERE Name = 'Contact' limit 1].Id;
                }
                
                list<CaseTeamMember> removeCTMlist = new list<CaseTeamMember>();
                
                for(CaseTeamMember ctm : [SELECT Id, MemberId, ParentId   
                                          FROM CaseTeamMember 
                                          WHERE MemberId =:removeCTM.values() 
                                          AND ParentId =:removeCTM.keySet()])
                {
                    if(removeCTM.get(ctm.ParentId) == ctm.MemberId){
                        CaseTeamMember newCTM = new CaseTeamMember(
                            Id = ctm.Id,
                            ParentId = ctm.ParentId, 
                            MemberId = ctm.MemberId
                        );
                        removeCTMlist.add(newCTM);
                    }
                }
                if(removeCTMlist.size() > 0){
                    system.debug('removeCTMlist: ' + removeCTMlist);
                    DELETE removeCTMlist;
                }
            }
            
            // Add New Case Team Members
            if(crollMap.size() > 0){
                
                if(teamRoleId == NULL){
                    teamRoleId = [SELECT Id 
                                  FROM CaseTeamRole 
                                  WHERE Name = 'Contact' limit 1].Id;
                }
                
                list<CaseTeamMember> createCTMlist = new list<CaseTeamMember>();
                
                //system.debug('crollMap: ' + crollMap);
                for(CaseTeamMember ctm : [SELECT Id, MemberId, ParentId   
                                          FROM CaseTeamMember 
                                          WHERE MemberId =:crollMap.values() 
                                          AND ParentId =:crollMap.keySet()])
                {
                    crollcheckMap.put(ctm.ParentId + '-' + ctm.MemberId, TRUE);
                }
                
                //system.debug('crollcheckMap: ' + crollcheckMap);
                for(String s : crollMap.keySet()){
                    if(crollcheckMap.get(s + '-' + crollMap.get(s)) == NULL){
                        CaseTeamMember newCTM = new CaseTeamMember(
                            ParentId = s, 
                            MemberId = crollMap.get(s), // Contact or User
                            TeamRoleId = teamRoleId
                        );
                        createCTMlist.add(newCTM);
                    }
                }
                if(createCTMlist.size() > 0){
                    system.debug('createCTMlist: ' + createCTMlist);
                    INSERT createCTMlist;
                }
            } 
        }
        
        system.debug('Finished (addToCaseTeam): Checking the Case Business Unit (Insert & Update/After)');
    }
    
    public static void stripDesc(List<Case> newTrigger){
        system.debug('Starting (stripDesc): Checking the Case Business Unit (Insert/Before)');
        if(master_TriggerHelperClass.qd('case_RemedyCaseFix')){
            Set<String> userLookup = new Set<String>(); 
            
            for (Case c : newTrigger){
                // Check to make sure that there is a subject, description, and the 'RunOnce' checkbox is not checked
                if(c.Subject != NULL && c.Description != NULL && c.RunOnce__c == FALSE){
                    
                    // These lists chop up the subject and description in to lists that are then statically iterated below
                    List<String> newSubject = c.Subject.split('Description:', -2);
                    List<String> newDesc = c.Description.split(':', -2);
                    List<String> newDesc2 = c.Description.split('Notes:', -2);
                    c.RunOnce__c = TRUE;
                    
                    if(newSubject.size() > 1 && newDesc2.size() > 1){
                        
                        // Capture the original Subject and Description for debug/history
                        c.Original_Subject__c = c.Subject;
                        c.Original_Description__c = c.Description;
                        
                        c.Subject = newSubject[1];
                        c.Description = newDesc2[1];
                        string Remedy_Incident = newDesc2[0];
                        c.Remedy_Incident__c = Remedy_Incident.substring(9,25);
                        
                        c.Type = newDesc[2].removeEnd('Priority');
                        c.Priority = newDesc[3].remove('Summary');
                        
                        // Captures the user name, flips it to first name last stripping out the extra spaces, and puts it in a temp field for processing below
                        string tempuserLookup = newDesc[1].removeEnd('Service Type');
                        string userFirstName = tempuserLookup.substringafter(',');
                        userFirstName = userFirstName.trim();
                        string userLastName = tempuserLookup.substringbefore(',');
                        userLastName = userLastname.trim();
                        tempuserLookup = userFirstName+' '+userLastName;
                        userLookup.add(tempuserLookup);
                        c.Username_Temp__c = tempuserLookup;
                    }
                }
            }
            
            // Create a list of users from the list created from the above loop to iterate through the cases
            List<User> userList = [Select Id, Name from User Where Name in : userLookup];
            
            // Iterate through the cases and associate the user
            if(!userList.isEmpty()){    
                for (Case c : newTrigger){
                    for (User u : userList){
                        
                        // Check the temp user field and match it to the appropriate user record ID
                        if(c.Username_Temp__c == u.Name){
                            c.User_Deactivated__c = u.Id;
                        }
                    }
                }
            } 
        }
        system.debug('Finished (stripDesc): Checking the Case Business Unit (Insert/Before)');
    }
}