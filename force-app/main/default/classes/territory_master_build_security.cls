global class territory_master_build_security implements Database.Batchable<sObject> {
    public String query;
    public String territory; 
    
    global territory_master_build_security(String q) {
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){

        system.debug('Starting territory_master_build_security');

        // If you are reading the logic please remember:
        // Double Ampersands && means AND
        // Double Pipes || means OR
        // 
        set<String> sapFilterKey = new set<String>();
        set<String> regionFilterKey = new set<String>();
        set<String> zipFilterKey = new set<String>();
        set<String> zipcusFilterKey = new set<String>();
        
        map<String, String> emptyTerritory = new map<String, String>();
        
        // New Stuff - 07Jun2017
        set<Id> ta_set_remove = new set<Id>(); // Used to capture Assignment Records that need to be removed
        list<Territory_Assignment__c> ta_list_remove = new list<Territory_Assignment__c>(); // The list used to remove Assignment Records
        
        map<String, Id> SAPmap = new map<String, Id>(); // Allows us to not have to loop through all the Accounts for SAP Assignments
        map<String, String> dupCheck = new map<String, String>(); // dupCheck is used to make sure that we do not align the same Role and Business Unit across multiple Sales Rep's
        map<String, String> recordCheck = new map<String, String>(); // recordCheck is used to make sure the record does not already exist
        map<String, Territory_Master__c> tlookup = new map<String, Territory_Master__c>(); // Access to the related Territory Master fields
        map<String, list<Account>> megaMap = new map<String, list<Account>>(); // An attempt to not have to loop through all the Account Records
        
        string dupKey;
        string recordKey;
        string bu;
        string trole;
        
        for(Territory_Master__c tm : [Select Id, Territory_Number__c, Business_Unit__c, Role__c, User_Count__c,
                                      Territory_Name__c 
                                      FROM Territory_Master__c 
                                      WHERE Territory_Number__c =:territory])
        {
            tlookup.put(tm.Territory_Number__c, tm);
            if(tm.User_Count__c == 0){
                emptyTerritory.put(tm.Territory_Number__c, 'Skip');
            }
        }
        list<Territory_Assignment__c> insTAlist = new list<Territory_Assignment__c>();
        
        // This Loops through the Accounts to create the keys used to query the ZPSA Rules
        list<Account> aList = (list<Account>)scope;
        
        for(Account a : aList){
            
            if(a.SAP_Sold_to__c != NULL){
                SAPmap.put(a.SAP_Sold_to__c, a.Id);
                
                // ZPSA Query Keys
                sapFilterKey.add(a.SAP_Sold_to__c + '-A681');
                sapFilterKey.add(a.SAP_Sold_to__c + '-A680');
                sapFilterKey.add(a.SAP_Sold_to__c + '-A654');
                sapFilterKey.add(a.SAP_Sold_to__c + '-A679');
                //system.debug('sapFilterKey: ' + sapFilterKey);
            }
            if(a.BillingState != NULL){
                
                // Super Map - State First
                if(megaMap.containsKey(a.BillingState)) {
                    megaMap.get(a.BillingState).add(a);
                } else {
                    megaMap.put(a.BillingState, new Account[]{a});
                }
                // ZPSA Query Keys
                regionFilterKey.add(a.BillingState + '-A659');
                regionFilterKey.add(a.BillingState + '-A688');
                regionFilterKey.add(a.BillingState + '-A689');
                //system.debug('regionFilterKey: ' + regionFilterKey);
            }
            if(a.BillingPostalCode != NULL){
                
                // Super Map - Zip Second
                if(megaMap.containsKey(a.BillingPostalCode)) {
                    megaMap.get(a.BillingPostalCode).add(a);
                } else {
                    megaMap.put(a.BillingPostalCode, new Account[]{a});
                }
                // Zip3
                if(megaMap.containsKey(a.BillingPostalCode.left(3))) {
                    megaMap.get(a.BillingPostalCode.left(3)).add(a);
                } else {
                    megaMap.put(a.BillingPostalCode.left(3), new Account[]{a});
                }
                // Zip5
                if(megaMap.containsKey(a.BillingPostalCode.left(5))) {
                    megaMap.get(a.BillingPostalCode.left(5)).add(a);
                } else {
                    megaMap.put(a.BillingPostalCode.left(5), new Account[]{a});
                }
                // ZPSA Query Keys
                zipFilterKey.add(a.BillingPostalCode + '-A626');
                zipFilterKey.add(a.BillingPostalCode.left(3) + '-A675');
                zipFilterKey.add(a.BillingPostalCode.left(5) + '-A667');
                zipFilterKey.add(a.BillingPostalCode.left(5) + '-A668');
                //system.debug('zipFilterKey: ' + zipFilterKey);
            }
            if(a.BillingPostalCode != NULL && a.Customer_Group__c != NULL){
                
                // ZPSA Query Keys
                zipcusFilterKey.add(a.BillingPostalCode.left(3) + a.Customer_Group__c + '-A672');
                zipcusFilterKey.add(a.BillingPostalCode.left(3) + a.Customer_Group__c + '-A671');
                zipcusFilterKey.add(a.BillingPostalCode.left(5) + a.Customer_Group__c + '-A663');
                zipcusFilterKey.add(a.BillingPostalCode.left(5) + a.Customer_Group__c + '-A664');
                
                //system.debug('zipcusFilterKey: ' + zipcusFilterKey);
            }
            // Build the Super Maps
            
            
            /* Not going to turn this on yet.
// Zip3 + Cust Group
if(superMap.containsKey(a.BillingPostalCode.left(3) + a.Customer_Group__c)) {
superMap.get(a.BillingPostalCode.left(3) + a.Customer_Group__c).add(a);
} else {
superMap.put(a.BillingPostalCode.left(3) + a.Customer_Group__c, new Account[]{a});
}
// Zip5 + Cust Group
if(superMap.containsKey(a.BillingPostalCode.left(5) + a.Customer_Group__c)) {
superMap.get(a.BillingPostalCode.left(5) + a.Customer_Group__c).add(a);
} else {
superMap.put(a.BillingPostalCode.left(5) + a.Customer_Group__c, new Account[]{a});
}*/
        }
        
        // Check to see if there's an Assignment already for this Account
        for( Territory_Assignment__c taa : [SELECT Territory_Number__c, Account__c, Territory_Alignment__r.Active__c, 
                                            Territory__r.Business_Unit__c, Territory__r.Role__c, Account__r.SAP_Sold_to__c, 
                                            Territory__r.Territory_Name__c 
                                            FROM Territory_Assignment__c 
                                            WHERE Account__c =:aList 
                                            AND Territory_Number__c =:territory])
        {
            //BU - Role - SAP - tnumber
            // This fixes Territories that have no BU or Role set.
            if(taa.Territory__r.Role__c == NULL){
                trole = 'REP';
            }
            else{
                trole = taa.Territory__r.Role__c;
            }
            
            if(taa.Territory__r.Business_Unit__c == NULL){
                bu = taa.Territory__r.Territory_Name__c;
            }
            else{
                bu = taa.Territory__r.Business_Unit__c;
            }
            recordKey = bu + '-' + trole + '-' + taa.Account__r.SAP_Sold_to__c + '-' + taa.Territory_Number__c;
            if(taa.Territory_Alignment__r.Active__c == TRUE){
                recordCheck.put(recordKey, taa.Id);                    
            }
            else{
                ta_set_remove.add(taa.Id); // Cleans out the Assignments related to non-active rules
            }
        }
        
        
        // This is where the work happens.
        // Class checks through the 4 levels of ZPSA and tries to match the account
        
        // Match SAP Code (Level 1)
        if(sapFilterKey.size() > 0){
            for(Territory_Alignment__c ta : [SELECT SAP_Code__c, Territory__c, Territory_Name__c, ZPSA_Table__c, 
                                             Territory2__c, Territory3__c, Territory4__c, Matching_Logic__c 
                                             FROM Territory_Alignment__c 
                                             WHERE Filter_Key__c IN :sapFilterKey 
                                             AND (Territory__c =:territory OR Territory2__c =:territory OR Territory3__c =:territory)
                                             AND Active__c = TRUE])
            {
                
                //system.debug('Match SAP Code Results: ' + ta);
                
                // Determine if there are additional Territories other than the primary and iterate through those
                set<String> tlist = new set<String>();
                tlist.add(ta.Territory__c);
                if(ta.Territory2__c != NULL) tlist.add(ta.Territory2__c); 
                if(ta.Territory3__c != NULL) tlist.add(ta.Territory3__c);
                if(ta.Territory4__c != NULL) tlist.add(ta.Territory4__c);
                
                // Cycle through the accounts to create territory assignment matches
                for(String ts : tlist){
                    if(tlookup.containsKey(ts)){
                        if(tlookup.get(ts).Role__c == NULL){
                            trole = 'REP';
                        }
                        else{
                            trole = tlookup.get(ts).Role__c;
                        }
                        
                        if(tlookup.get(ts).Business_Unit__c == NULL){
                            bu = tlookup.get(ts).Territory_Name__c; 
                        }
                        else{
                            bu = tlookup.get(ts).Business_Unit__c;
                        }
                        dupKey = bu + '-' + trole  + '-' + ta.SAP_Code__c;
                        recordKey = bu + '-' + trole  + '-' + ta.SAP_Code__c  + '-' + tlookup.get(ts).Territory_Number__c;
                        //system.debug('dupKey: ' + dupKey + ' - recordKey: ' + recordKey);
                        
                        if(emptyTerritory.containskey(ts)){
                            if(recordCheck.containskey(recordKey)){
                                system.debug('Empty Territory - ' + ta.Matching_Logic__c + ' - Adding this record for delete: ' + ta.Id);
                                ta_set_remove.add(recordCheck.get(recordKey));
                            }
                            else{
                                system.debug('Empty Territory - ' + ta.Matching_Logic__c + ' - No Record to Delete - Skipping: ' + recordKey);
                            }
                        }
                        else if(dupCheck.containskey(dupKey)){
                            system.debug('Duplicate Role - Skipping: ' + ts + ' - ' + ta.Matching_Logic__c + ' - Match: ' + bu + '/' + trole + '/' + dupCheck.get(dupKey));
                            if(dupCheck.get(dupKey) != ts && recordCheck.containsKey(recordKey)){
                                ta_set_remove.add(recordCheck.get(recordKey));
                            }
                        }
                        else{
                            Territory_Assignment__c newTA = new Territory_Assignment__c(
                                Name = ta.SAP_Code__c + '-' + ts + ' ' + ta.Territory_Name__c, 
                                Territory_Alignment__c = ta.Id,
                                Territory__c = tlookup.get(ts).Id,
                                Territory_Number__c = ts,
                                Account__c = SAPmap.get(ta.SAP_Code__c),
                                ZPSA_Table__c = ta.ZPSA_Table__c,
                                Matching_Logic__c = 'SAP Code',
                                Assignment_Reason__c = 'The SAP Code on this named account was matched to a territory in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                            );
                            if(recordCheck.containsKey(recordKey)){
                                system.debug('Adding (Record Exists - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                
                            }
                            else{
                                system.debug('Adding (New Record - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                insTAlist.add(newTA);
                            }
                            dupCheck.put(dupKey, ts); // BU - Role - SAP = Territory Number
                        }
                    }
                    else{
                        system.debug('No Territory Master for: ' + ts);
                    }
                }
            }
        }
        
        if(Test.isRunningTest()) dupCheck.clear();
        
        // Match Zipcode + Customer Group (Level 2)
        if(zipcusFilterKey.size() > 0){
            for(Territory_Alignment__c ta : [SELECT Id, Customer_Group__c, Zipcode__c, Territory__c, Territory_Name__c, 
                                             ZPSA_Table__c, Territory2__c, Territory3__c, Territory4__c, Matching_Logic__c 
                                             FROM Territory_Alignment__c 
                                             WHERE Filter_Key__c IN :zipcusFilterKey 
                                             AND (Territory__c =:territory OR Territory2__c =:territory OR Territory3__c =:territory)
                                             AND Active__c = TRUE])
            {
                //system.debug('Match Zipcode + Customer Group Results: ' + ta);
                
                // Determine if there are additional Territories other than the primary and iterate through those
                set<String> tlist = new set<String>();
                tlist.add(ta.Territory__c);
                if(ta.Territory2__c != NULL) tlist.add(ta.Territory2__c); 
                if(ta.Territory3__c != NULL) tlist.add(ta.Territory3__c);
                if(ta.Territory4__c != NULL) tlist.add(ta.Territory4__c);
                
                // Cycle through the accounts to create territory assignment matches
                for(Account a : aList){
                    if(a.BillingPostalCode != NULL && ta.Customer_Group__c != NULL){
                        if(
                            (
                                ta.Zipcode__c == a.BillingPostalCode.left(5) || 
                                ta.Zipcode__c == a.BillingPostalCode.left(3)
                            )
                            && ta.Customer_Group__c == a.Customer_Group__c 
                        ){
                            for(String ts : tlist){
                                if(tlookup.containsKey(ts)){
                                    if(tlookup.get(ts).Role__c == NULL){
                                        trole = 'REP';
                                    }
                                    else{
                                        trole = tlookup.get(ts).Role__c;
                                    }
                                    
                                    if(tlookup.get(ts).Business_Unit__c == NULL){
                                        bu = tlookup.get(ts).Territory_Name__c; 
                                    }
                                    else{
                                        bu = tlookup.get(ts).Business_Unit__c;
                                    }
                                    dupKey = bu + '-' + trole  + '-' + a.SAP_Sold_To__c;
                                    recordKey = bu + '-' + trole  + '-' + a.SAP_Sold_To__c  + '-' + tlookup.get(ts).Territory_Number__c;
                                    
                                    if(emptyTerritory.containskey(ts)){
                                        if(recordCheck.containskey(recordKey)){
                                            system.debug('Empty Territory - ' + ta.Matching_Logic__c + ' - Adding this record for delete: ' + ta.Id);
                                            ta_set_remove.add(recordCheck.get(recordKey));
                                        }
                                        else{
                                            system.debug('Empty Territory - ' + ta.Matching_Logic__c + ' - No Record to Delete - Skipping: ' + recordKey);
                                        }
                                    }
                                    else if(dupCheck.containskey(dupKey)){
                                        system.debug('Duplicate Role - Skipping: ' + ts + ' - ' + ta.Matching_Logic__c + ' - Match: ' + bu + '/' + trole + '/' + dupCheck.get(dupKey));
                                        if(dupCheck.get(dupKey) != ts && recordCheck.containsKey(recordKey)){
                                            ta_set_remove.add(recordCheck.get(recordKey));
                                        }
                                    }
                                    else{
                                        Territory_Assignment__c newTA = new Territory_Assignment__c(
                                            Name = a.SAP_Sold_To__c + '-' + ta.Zipcode__c + '-' + ta.Customer_Group__c + '-' + ts + ' ' + ta.Territory_Name__c, 
                                            Territory_Alignment__c = ta.Id,
                                            Territory__c = tlookup.get(ts).Id,
                                            Territory_Number__c = ts,
                                            Account__c = a.Id,
                                            ZPSA_Table__c = ta.ZPSA_Table__c,
                                            Matching_Logic__c = 'Zip+Customer Group',
                                            Assignment_Reason__c = 'The Zip/Postage Code and Customer Group on this account was a match in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                                        );
                                        if(recordCheck.containsKey(recordKey)){
                                            system.debug('Adding (Record Exists - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                            
                                        }
                                        else{
                                            system.debug('Adding (New Record - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                            insTAlist.add(newTA);
                                        }
                                        dupCheck.put(dupKey, ts); // BU - Role - SAP = Territory Number                              }
                                    } // Else                                    }
                                }
                                else{
                                    system.debug('No Territory Master for: ' + ts);
                                }
                            } // For TS 
                        }
                    }
                } // For Account
            } // For Loop
        } // Size
        
        if(Test.isRunningTest()) dupCheck.clear();
        
        // Match Zipcode (Level 3)
        if(zipFilterKey.size() > 0){
            for(Territory_Alignment__c ta : [SELECT Id, Zipcode__c, Territory__c, Territory_Name__c, 
                                             ZPSA_Table__c, Territory2__c, Territory3__c, Territory4__c, Matching_Logic__c 
                                             FROM Territory_Alignment__c 
                                             WHERE Filter_Key__c IN :zipFilterKey 
                                             AND (Territory__c =:territory OR Territory2__c =:territory OR Territory3__c =:territory)
                                             AND Active__c = TRUE])
            {
                //system.debug('Match Zipcode Results: ' + ta);
                
                // Determine if there are additional Territories other than the primary and iterate through those
                set<String> tlist = new set<String>();
                tlist.add(ta.Territory__c);
                if(ta.Territory2__c != NULL) tlist.add(ta.Territory2__c); 
                if(ta.Territory3__c != NULL) tlist.add(ta.Territory3__c);
                if(ta.Territory4__c != NULL) tlist.add(ta.Territory4__c);
                
                //Zipcode__c 
                for(Account a : megaMap.get(ta.Zipcode__c)){
                    for(String ts : tlist){
                        if(tlookup.containsKey(ts)){
                            if(tlookup.get(ts).Role__c == NULL){
                                trole = 'REP';
                            }
                            else{
                                trole = tlookup.get(ts).Role__c;
                            }
                            
                            if(tlookup.get(ts).Business_Unit__c == NULL){
                                bu = tlookup.get(ts).Territory_Name__c; 
                            }
                            else{
                                bu = tlookup.get(ts).Business_Unit__c;
                            }
                            dupKey = bu + '-' + trole  + '-' + a.SAP_Sold_To__c;
                            recordKey = bu + '-' + trole  + '-' + a.SAP_Sold_To__c  + '-' + tlookup.get(ts).Territory_Number__c;
                            //system.debug('dupKey: ' + dupKey + ' - recordKey: ' + recordKey);
                            
                            if(emptyTerritory.containskey(ts)){
                                if(recordCheck.containskey(recordKey)){
                                    system.debug('Empty Territory - ' + ta.Matching_Logic__c + ' - Adding this record for delete: ' + ta.Id);
                                    ta_set_remove.add(recordCheck.get(recordKey));
                                }
                                else{
                                    system.debug('Empty Territory - ' + ta.Matching_Logic__c + ' - No Record to Delete - Skipping: ' + recordKey);
                                }
                            }
                            else if(dupCheck.containskey(dupKey)){
                                system.debug('Duplicate Role - Skipping: ' + ts + ' - ' + ta.Matching_Logic__c + ' - Match: ' + bu + '/' + trole + '/' + dupCheck.get(dupKey));
                                if(dupCheck.get(dupKey) != ts && recordCheck.containsKey(recordKey)){
                                    ta_set_remove.add(recordCheck.get(recordKey));
                                }
                            }
                            else{
                                Territory_Assignment__c newTA = new Territory_Assignment__c(
                                    Name = a.SAP_Sold_To__c + '-' + ta.Zipcode__c + '-' + ts + ' ' + ta.Territory_Name__c, 
                                    Territory_Alignment__c = ta.Id,
                                    Territory__c = tlookup.get(ts).Id,
                                    Territory_Number__c = ts,
                                    Account__c = a.Id,
                                    ZPSA_Table__c = ta.ZPSA_Table__c,
                                    Matching_Logic__c = 'Zip/Postal Code',
                                    Assignment_Reason__c = 'The Zip/Postage Code on this account was a match in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                                );
                                if(recordCheck.containsKey(recordKey)){
                                    system.debug('Adding (Record Exists - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                    
                                }
                                else{
                                    system.debug('Adding (New Record - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                    insTAlist.add(newTA);
                                }
                                dupCheck.put(dupKey, ts); // BU - Role - SAP = Territory Number                              }
                            } // Else
                        }
                        else{
                            system.debug('No Territory Master for: ' + ts);
                        }
                    } // For ts 
                } // Account
            } // rule loop
        } // Size
        
        if(Test.isRunningTest()) dupCheck.clear();
        
        // Match State/Region (Level 4)        
        if(regionFilterKey.size() > 0){
            for(Territory_Alignment__c ta : [SELECT Region__c, Territory__c, Territory_Name__c, ZPSA_Table__c, 
                                             Territory2__c, Territory3__c, Territory4__c, Matching_Logic__c 
                                             FROM Territory_Alignment__c 
                                             WHERE Filter_Key__c IN :regionFilterKey 
                                             AND (Territory__c =:territory OR Territory2__c =:territory OR Territory3__c =:territory)
                                             AND Active__c = TRUE])
            {
                //system.debug('Match State/Region Results: ' + ta);
                
                // Determine if there are additional Territories other than the primary and iterate through those
                set<String> tlist = new set<String>();
                tlist.add(ta.Territory__c);
                if(ta.Territory2__c != NULL) tlist.add(ta.Territory2__c); 
                if(ta.Territory3__c != NULL) tlist.add(ta.Territory3__c);
                if(ta.Territory4__c != NULL) tlist.add(ta.Territory4__c);
                
                //system.debug('tlist: ' + tlist);
                
                // Cycle through the accounts to create territory assignment matches                    
                for(Account a : megaMap.get(ta.Region__c)){
                    for(String ts : tlist){
                        if(tlookup.containsKey(ts)){
                            if(tlookup.get(ts).Role__c == NULL){
                                trole = 'REP';
                            }
                            else{
                                trole = tlookup.get(ts).Role__c;
                            }
                            
                            if(tlookup.get(ts).Business_Unit__c == NULL){
                                bu = tlookup.get(ts).Territory_Name__c; 
                            }
                            else{
                                bu = tlookup.get(ts).Business_Unit__c;
                            }
                            dupKey = bu + '-' + trole  + '-' + a.SAP_Sold_To__c;
                            recordKey = bu + '-' + trole  + '-' + a.SAP_Sold_To__c  + '-' + tlookup.get(ts).Territory_Number__c;
                            //system.debug('dupKey: ' + dupKey + ' - recordKey: ' + recordKey);
                            
                            if(emptyTerritory.containskey(ts)){
                                if(recordCheck.containskey(recordKey)){
                                    system.debug('Empty Territory - ' + ta.Matching_Logic__c + ' - Adding this record for delete: ' + ta.Id);
                                    ta_set_remove.add(recordCheck.get(recordKey));
                                }
                                else{
                                    system.debug('Empty Territory - ' + ta.Matching_Logic__c + ' - No Record to Delete - Skipping: ' + recordKey);
                                }
                            }
                            else if(dupCheck.containskey(dupKey)){
                                system.debug('Duplicate Role - Skipping: ' + ts + ' - ' + ta.Matching_Logic__c + ' - Match: ' + bu + '/' + trole + '/' + dupCheck.get(dupKey));
                                if(dupCheck.get(dupKey) != ts && recordCheck.containsKey(recordKey)){
                                    ta_set_remove.add(recordCheck.get(recordKey));
                                }
                            }
                            else{
                                Territory_Assignment__c newTA = new Territory_Assignment__c(
                                    Name = a.SAP_Sold_To__c + '-' + ta.Region__c + '-' + ts + ' ' + ta.Territory_Name__c, 
                                    Territory_Alignment__c = ta.Id,
                                    Territory__c = tlookup.get(ts).Id,
                                    Territory_Number__c = ts,
                                    Account__c = a.Id,
                                    ZPSA_Table__c = ta.ZPSA_Table__c,
                                    Matching_Logic__c = 'Region/State and Territory Number',
                                    Assignment_Reason__c = 'The Region/State on this account was matched to a state and territory in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                                );
                                if(recordCheck.containsKey(recordKey)){
                                    system.debug('Adding (Record Exists - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                    
                                }
                                else{
                                    system.debug('Adding (New Record - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                    insTAlist.add(newTA);
                                }
                                dupCheck.put(dupKey, ts); // BU - Role - SAP = Territory Number
                            }
                        }
                        else{
                            system.debug('No Territory Master for: ' + ts);
                        }
                    } // tlist
                } // account
            }
        }
        
        if(insTAlist.size() > 0){
            system.debug('Inserting -- insTAlist: ' + insTAlist);
            insert insTAlist;
        }
        else{
            system.debug('Nothing to INSERT!!!');
        }
        if(ta_set_remove.size() > 0){
            system.debug('Deleting Assignments that are no longer valid');
            for(Id i : ta_set_remove){
                Territory_Assignment__c del_ta = new Territory_Assignment__c(
                    Id = i
                );
                ta_list_remove.add(del_ta);
            }
            delete ta_list_remove;
        }
        system.debug('-- Finished Territory Account Alignment --');

        
        
        /*
        // Old Code
        // If you are reading the logic please remember:
        // Double Ampersands && means AND
        // Double Pipes || means OR
        // 
        set<String> sapFilterKey = new set<String>();
        set<String> regionFilterKey = new set<String>();
        set<String> zipFilterKey = new set<String>();
        set<String> zipcusFilterKey = new set<String>();
        //set<String> cusFilterKey = new set<String>();
        
        // tmap is used to make sure that we do not create duplicate records when territory 
        // rules create multiple territory 'hits'. Shouild also get a pickup in performance 
        map<String, String> tmap = new map<String, String>();
        map<String, Id> tlookup = new map<String, Id>();
        for(Territory_Master__c tm : [Select Id, Territory_Number__c, User_Count__c 
                                      FROM Territory_Master__c
                                      WHERE Territory_Number__c =:territory])
        {
            tlookup.put(tm.Territory_Number__c, tm.Id);
        }
        list<Territory_Assignment__c> insTAlist = new list<Territory_Assignment__c>();
        
        string sap;
        string zip;
        string state;
        string cgroup;
        string aid;
        set<id> aset = new set<id>();
        list<Account> aList = (list<Account>)scope;
        
        for(Account a : aList){
            sap = a.SAP_Sold_to__c;
            state = a.BillingState;
            zip = a.BillingPostalCode;
            cgroup = a.Customer_Group__c;
            aid = a.Id;
            aset.add(aid);          
            
            if(sap != NULL){
                sapFilterKey.add(sap + '-A681');
                sapFilterKey.add(sap + '-A680');
                sapFilterKey.add(sap + '-A654');
                sapFilterKey.add(sap + '-A679');
                //system.debug('sapFilterKey: ' + sapFilterKey);
            }
            if(state != NULL){
                regionFilterKey.add(state + '-A659');
                regionFilterKey.add(state + '-A688');
                regionFilterKey.add(state + '-A689');
                //system.debug('regionFilterKey: ' + regionFilterKey);
            }
            if(zip != NULL){
                zipFilterKey.add(zip + '-A626');
                zipFilterKey.add(zip.left(3) + '-A675');
                zipFilterKey.add(zip.left(5) + '-A667');
                zipFilterKey.add(zip.left(5) + '-A668');
                //system.debug('zipFilterKey: ' + zipFilterKey);
            }
            if(zip != NULL && cgroup != NULL){
                zipcusFilterKey.add(zip.left(3) + cgroup + '-A672');
                zipcusFilterKey.add(zip.left(3) + cgroup + '-A671');
                zipcusFilterKey.add(zip.left(5) + cgroup + '-A663');
                zipcusFilterKey.add(zip.left(5) + cgroup + '-A664');
                
                //system.debug('zipcusFilterKey: ' + zipcusFilterKey);
            }
        }
        
        // Match SAP Code
        if(sapFilterKey.size() > 0){
            for(Territory_Alignment__c ta : [SELECT SAP_Code__c, Territory__c, Territory_Name__c, ZPSA_Table__c, 
                                             Territory2__c, Territory3__c, Territory4__c 
                                             FROM Territory_Alignment__c 
                                             WHERE Filter_Key__c IN :sapFilterKey
                                             AND (Territory__c =:territory OR Territory2__c =:territory)])
            {
                
                // Cycle through the accounts to create territory assignment matches
                for(sObject a : scope){
                    sap = String.valueOf(a.get('SAP_Sold_to__c'));
                    state = String.valueOf(a.get('BillingState'));
                    zip = String.valueOf(a.get('BillingPostalCode'));
                    cgroup = String.valueOf(a.get('Customer_Group__c'));
                    aid = String.valueOf(a.get('Id'));
                    
                    if(sap != NULL){
                        if(ta.SAP_Code__c == sap){
                            Territory_Assignment__c newTA = new Territory_Assignment__c(
                                Name = sap + '-' + territory + ' ' + ta.Territory_Name__c, 
                                Territory_Alignment__c = ta.Id,
                                Territory__c = tlookup.get(territory),
                                Territory_Number__c = territory,
                                Account__c = aid,
                                ZPSA_Table__c = ta.ZPSA_Table__c,
                                Matching_Logic__c = 'SAP Code and Territory Number',
                                Assignment_Reason__c = 'The Region/State on this account was matched to a state and territory in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                            );
                            insTAlist.add(newTA);
                        }
                    }
                }                                     
            }
        }
        
        
        // Match State/Region
        if(regionFilterKey.size() > 0){
            for(Territory_Alignment__c ta : [SELECT Region__c, Territory__c, Territory_Name__c, ZPSA_Table__c, 
                                             Territory2__c, Territory3__c, Territory4__c 
                                             FROM Territory_Alignment__c 
                                             WHERE Filter_Key__c IN :regionFilterKey 
                                             AND (Territory__c =:territory OR Territory2__c =:territory)])
            {
                //system.debug('Match State/Region Results: ' + ta);
                
                // Cycle through the accounts to create territory assignment matches                    
                for(sObject a : scope){
                    sap = String.valueOf(a.get('SAP_Sold_to__c'));
                    state = String.valueOf(a.get('BillingState'));
                    zip = String.valueOf(a.get('BillingPostalCode'));
                    cgroup = String.valueOf(a.get('Customer_Group__c'));
                    aid = String.valueOf(a.get('Id'));
                    
                    if(state != NULL){
                        if(ta.Region__c == state){
                            Territory_Assignment__c newTA = new Territory_Assignment__c(
                                Name = sap + '-' + ta.Region__c + '-' + territory + ' ' + ta.Territory_Name__c, 
                                Territory_Alignment__c = ta.Id,
                                Territory__c = tlookup.get(territory),
                                Territory_Number__c = territory,
                                Account__c = aid,
                                ZPSA_Table__c = ta.ZPSA_Table__c,
                                Matching_Logic__c = 'Region/State and Territory Number',
                                Assignment_Reason__c = 'The Region/State on this account was matched to a state and territory in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                            );
                            insTAlist.add(newTA);
                        } 
                    }
                    
                }
            } 
        }
        
        
        // Match Zipcode
        if(zipFilterKey.size() > 0){
            for(Territory_Alignment__c ta : [SELECT Id, Zipcode__c, Territory__c, Territory_Name__c, 
                                             ZPSA_Table__c, Territory2__c, Territory3__c, Territory4__c 
                                             FROM Territory_Alignment__c 
                                             WHERE Filter_Key__c IN :zipFilterKey 
                                             AND (Territory__c =:territory OR Territory2__c =:territory)])
            {
                //system.debug('Match Zipcode Results: ' + ta);
                
                // Cycle through the accounts to create territory assignment matches
                for(sObject a : scope){
                    sap = String.valueOf(a.get('SAP_Sold_to__c'));
                    state = String.valueOf(a.get('BillingState'));
                    zip = String.valueOf(a.get('BillingPostalCode'));
                    cgroup = String.valueOf(a.get('Customer_Group__c'));
                    aid = String.valueOf(a.get('Id'));
                    
                    if(zip != NULL){
                        if(
                            ta.Zipcode__c == zip || 
                            ta.Zipcode__c == zip.left(5) || 
                            ta.Zipcode__c == zip.left(3)
                        ){
                            Territory_Assignment__c newTA = new Territory_Assignment__c(
                                Name = sap + '-' + ta.Zipcode__c + '-' + territory + ' ' + ta.Territory_Name__c, 
                                Territory_Alignment__c = ta.Id,
                                Territory__c = tlookup.get(territory),
                                Territory_Number__c = territory,
                                Account__c = aid,
                                ZPSA_Table__c = ta.ZPSA_Table__c,
                                Matching_Logic__c = 'Zip/Postal Code and Territory Number',
                                Assignment_Reason__c = 'The Zip/Postage Code on this account was a match in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                            );
                            insTAlist.add(newTA);
                        }  
                    }
                    
                }
            } 
        }
        
        
        // Match Zipcode + Customer Group
        if(zipcusFilterKey.size() > 0){
            for(Territory_Alignment__c ta : [SELECT Id, Customer_Group__c, Zipcode__c, Territory__c, Territory_Name__c, 
                                             ZPSA_Table__c, Territory2__c, Territory3__c, Territory4__c 
                                             FROM Territory_Alignment__c 
                                             WHERE Filter_Key__c IN :zipcusFilterKey 
                                             AND (Territory__c =:territory OR Territory2__c =:territory)])
            {
                //system.debug('Match Zipcode + Customer Group Results: ' + ta);
                
                
                // Cycle through the accounts to create territory assignment matches
                for(sObject a : scope){
                    sap = String.valueOf(a.get('SAP_Sold_to__c'));
                    zip = String.valueOf(a.get('BillingPostalCode'));
                    cgroup = String.valueOf(a.get('Customer_Group__c'));
                    aid = String.valueOf(a.get('Id'));
                    
                    if(zip != NULL && cgroup != NULL){
                        if(
                            (
                                ta.Zipcode__c == zip.left(5) || 
                                ta.Zipcode__c == zip.left(3)
                            )
                            && ta.Customer_Group__c == cgroup 
                        ){
                            Territory_Assignment__c newTA = new Territory_Assignment__c(
                                Name = sap + '-' + ta.Zipcode__c + '-' + ta.Customer_Group__c + '-' + territory + ' ' + ta.Territory_Name__c, 
                                Territory_Alignment__c = ta.Id,
                                Territory__c = tlookup.get(territory),
                                Territory_Number__c = territory,
                                Account__c = aid,
                                ZPSA_Table__c = ta.ZPSA_Table__c,
                                Matching_Logic__c = 'Zip/Postal Code, Customer Group, and Territory Number',
                                Assignment_Reason__c = 'The Zip/Postage Code and Customer Group on this account was a match in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                            );
                            insTAlist.add(newTA); 
                        }
                    }
                }
            }
        }
        
        if(insTAlist.size() > 0){
            list<Territory_Assignment__c> delTAlist = [SELECT id 
                                                       FROM Territory_Assignment__c 
                                                       WHERE Account__r.Id in :aset
                                                       AND Territory_Number__c = :territory];
            if(delTAlist.size() > 0){
                delete delTAlist;
            }
            insert insTAlist;
        }    */
        
        
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
        mail.setSubject('Adding ' + territory + ' to Territory Alignments: ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}