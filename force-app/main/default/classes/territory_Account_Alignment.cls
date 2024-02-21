public class territory_Account_Alignment {
    public void startAlignAccounts(List<Account> newTrigger){
        alignAccounts(newTrigger);
    }
    
    public static void alignAccounts(List<Account> newTrigger){
        // 
        // Test Class: territory_Account_Shares_TEST
        // 
        // *** WARNING *** Make BACKUPS of this class before you touch ANY of it. It does things for a reason...
        // 18Aug2017 ESC - Added extra checks to delete duplicate assignment records, ZPSA Priority ordering, Duplication now checks the ZPSA Priority and flips if higher, and added [1] type headers to the debug
        // qd stands for Quick Disable. Look in the Custom Settings, if set to false this
        // class will not fire. If the value doesn't exist it will default to true and the class will fire.
        if(master_TriggerHelperClass.qd('territory_Account_Alignment')){
            system.debug('Starting alignAccounts!!!');
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
            
            // END NEW
            
            // New Stuff - 18Aug2017
            map<String, Integer> dupCheckRank = new map<String, Integer>(); // Used to give the match a ranking that if lower than the match is replaced.
            map<String, Integer> ZPSArank = new map<String, Integer>(); // Used to map the ZPSA table to a ranking that can be compared
            map<String, Territory_Assignment__c> megaDMLmap = new map<String, Territory_Assignment__c>(); // Need an easy easy to switch around the records that need to be created without messing with list positions
            ZPSArank.put('A679', 1);
            ZPSArank.put('A680', 2);
            ZPSArank.put('A681', 3);
            ZPSArank.put('A654', 4);
            ZPSArank.put('A659', 5);
            ZPSArank.put('A622', 6);
            ZPSArank.put('A626', 7);
            ZPSArank.put('A664', 8);
            ZPSArank.put('A663', 9);
            ZPSArank.put('A668', 10);
            ZPSArank.put('A667', 11);
            ZPSArank.put('A672', 12);
            ZPSArank.put('A671', 13);
            ZPSArank.put('A675', 14);
            ZPSArank.put('A688', 15);
            ZPSArank.put('A689', 16);

            // END NEW
            // New Stuff - 01Mar2018
            map<String, String> astMap = new map<String, String>();
            map<String, Id> simpleRecordCheck = new map<String, Id>();
            string astList;
            // END NEW

            for(Territory_Master__c tm : [Select Id, Territory_Number__c, Business_Unit__c, Role__c, User_Count__c,
                                          Territory_Name__c 
                                          FROM Territory_Master__c])
            {
                tlookup.put(tm.Territory_Number__c, tm);
                if(tm.User_Count__c == 0){
                    emptyTerritory.put(tm.Territory_Number__c, 'Skip');
                }
            }
            list<Territory_Assignment__c> insTAlist = new list<Territory_Assignment__c>();
            system.debug('tlookup: ' + tlookup);

            // This Loops through the Accounts to create the keys used to query the ZPSA Rules
            for(Account a : newTrigger){

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
                if(a.Territory_Key__c != NULL){
                    astList = a.Territory_Key__c;
                    List<String> sortedvalue = astList.split(';');
                    for(string s : sortedvalue){
                        astMap.put(a.Id + '-' + s, s);
                    }
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
                                                WHERE Account__c IN :newTrigger])
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
                    if(recordCheck.containsKey(recordKey)){
                        ta_set_remove.add(taa.Id);
                    }
                    else{
                        recordCheck.put(recordKey, taa.Id); 
                        simpleRecordCheck.put(taa.Account__c + '-' + taa.Territory_Number__c, taa.Id);
                    }
                    
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
                                                 Territory2__c, Territory3__c, Territory4__c, Matching_Logic__c, ZPSA_Priority__c  
                                                 FROM Territory_Alignment__c 
                                                 WHERE Filter_Key__c IN :sapFilterKey 
                                                 AND Active__c = TRUE
                                                 ORDER BY ZPSA_Priority__c ASC])
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
                            
                            if(emptyTerritory.containskey(ts)){
                                if(recordCheck.containskey(recordKey)){
                                    system.debug('Empty Territory - ' + ta.Matching_Logic__c + ' - Adding this record for delete: ' + ta.Id);
                                    ta_set_remove.add(recordCheck.get(recordKey));
                                }
                                else{
                                    system.debug('[1] Empty Territory - ' + ta.Matching_Logic__c + ' - No Record to Delete - Skipping: ' + recordKey);
                                }
                            }
                            else if(dupCheck.containskey(dupKey)){
                                // If the Rank of the new record is higher, switch out the records (18Aug2017 - ESC)
                                if(ta.ZPSA_Priority__c < dupCheckRank.get(dupKey)){
                                    system.debug('[1] Switching! - '+dupKey);
                                    megaDMLmap.put(dupKey, newTA);
                                    if(recordCheck.containsKey(recordKey)){
                                        ta_set_remove.add(recordCheck.get(recordKey));
                                    }
                                } // END
                                else if(dupCheck.get(dupKey) != ts && recordCheck.containsKey(recordKey)){
                                    ta_set_remove.add(recordCheck.get(recordKey));
                                }
                                system.debug('[1] Duplicate Role - Skipping: ' + ts + ' - ' + ta.Matching_Logic__c + ' - Match: ' + bu + '/' + trole + '/' + dupCheck.get(dupKey) + ' CR1: ' + ta.ZPSA_Priority__c + ' PR:' + dupCheckRank.get(dupKey));
                            }
                            else{
                                if(recordCheck.containsKey(recordKey)){
                                    system.debug('[1] Adding (Record Exists - No DML - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                }
                                else{
                                    system.debug('Adding (New Record - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                    //insTAlist.add(newTA);
                                    megaDMLmap.put(dupKey, newTA);
                                }
                                dupCheck.put(dupKey, ts); // BU - Role - SAP = Territory Number
                                dupCheckRank.put(dupKey, ZPSArank.get(ta.Zpsa_Table__c)); // BU - Role - SAP = Territory Number
                            }
                        }
                        else{
                            system.debug('[1] No Territory Master for: ' + ts);
                        }
                    }
                }
            }

            if(Test.isRunningTest()) dupCheck.clear();
            // /apex/territory_Account_Check?id=001E000001BcrWf
            // Match Zipcode + Customer Group (Level 2)
            if(zipcusFilterKey.size() > 0){
                for(Territory_Alignment__c ta : [SELECT Id, Customer_Group__c, Zipcode__c, Territory__c, Territory_Name__c, 
                                                 ZPSA_Table__c, Territory2__c, Territory3__c, Territory4__c, Matching_Logic__c, ZPSA_Priority__c  
                                                 FROM Territory_Alignment__c 
                                                 WHERE Filter_Key__c IN :zipcusFilterKey 
                                                 AND Active__c = TRUE
                                                 ORDER BY ZPSA_Priority__c ASC])
                {
                    //system.debug('Match Zipcode + Customer Group Results: ' + ta);
                    
                    // Determine if there are additional Territories other than the primary and iterate through those
                    set<String> tlist = new set<String>();
                    tlist.add(ta.Territory__c);
                    if(ta.Territory2__c != NULL) tlist.add(ta.Territory2__c); 
                    if(ta.Territory3__c != NULL) tlist.add(ta.Territory3__c);
                    if(ta.Territory4__c != NULL) tlist.add(ta.Territory4__c);
                    
                    // Cycle through the accounts to create territory assignment matches
                    for(Account a : newTrigger){
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
                                        
                                        if(emptyTerritory.containskey(ts)){
                                            if(recordCheck.containskey(recordKey)){
                                                system.debug('[2] Empty Territory - ' + ta.Matching_Logic__c + ' - Adding this record for delete: ' + ta.Id);
                                                ta_set_remove.add(recordCheck.get(recordKey));
                                            }
                                            else{
                                                system.debug('[2] Empty Territory - ' + ta.Matching_Logic__c + ' - No Record to Delete - Skipping: ' + recordKey);
                                            }
                                        }
                                        else if(astMap.containsKey(a.Id + '-' + ts)){
                                            system.debug('Sales on the Account! - ' + ts);
                                            if(simpleRecordCheck.containsKey(a.Id + '-' + ts)){
                                                system.debug('[2] Record Already Exists - Skipping! - ' + ts);
                                            }
                                            else{
                                                megaDMLmap.put(dupKey, newTA);                                                
                                            }
                                        }
                                        else if(dupCheck.containskey(dupKey)){
                                            // If the Rank of the new record is higher, switch out the records (18Aug2017 - ESC)
                                            if(ta.ZPSA_Priority__c < dupCheckRank.get(dupKey)){
                                                system.debug('[2] Switching! - '+dupKey);
                                                megaDMLmap.put(dupKey, newTA);
                                                if(recordCheck.containsKey(recordKey)){
                                                    ta_set_remove.add(recordCheck.get(recordKey));
                                                }
                                            } // END
                                            else if(dupCheck.get(dupKey) != ts && recordCheck.containsKey(recordKey)){
                                                ta_set_remove.add(recordCheck.get(recordKey));
                                            }
                                            system.debug('[2] Duplicate Role - Skipping: ' + ts + ' - ' + ta.Matching_Logic__c + ' - Match: ' + bu + '/' + trole + '/' + dupCheck.get(dupKey) + ' CR1: ' + ta.ZPSA_Priority__c + ' PR:' + dupCheckRank.get(dupKey));
                                        }
                                        else{
                                            if(recordCheck.containsKey(recordKey)){
                                                system.debug('[2] Adding (Record Exists - No DML - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                            }
                                            else{
                                                system.debug('[2] Adding (New Record - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                                //insTAlist.add(newTA);
                                                megaDMLmap.put(dupKey, newTA);
                                            }
                                            dupCheck.put(dupKey, ts); // BU - Role - SAP = Territory Number
                                            dupCheckRank.put(dupKey, ZPSArank.get(ta.Zpsa_Table__c)); // BU - Role - SAP = Territory Number
                                        } // ELSE
                                    }
                                    else{
                                        system.debug('[2] No Territory Master for: ' + ts);
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
                                                 ZPSA_Table__c, Territory2__c, Territory3__c, Territory4__c, Matching_Logic__c, ZPSA_Priority__c  
                                                 FROM Territory_Alignment__c 
                                                 WHERE Filter_Key__c IN :zipFilterKey 
                                                 AND Active__c = TRUE
                                                 ORDER BY ZPSA_Priority__c ASC])
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
                                if(emptyTerritory.containskey(ts)){
                                    if(recordCheck.containskey(recordKey)){
                                        system.debug('[3] Empty Territory - ' + ta.Matching_Logic__c + ' - Adding this record for delete: ' + ta.Id);
                                        ta_set_remove.add(recordCheck.get(recordKey));
                                    }
                                    else{
                                        system.debug('[3] Empty Territory - ' + ta.Matching_Logic__c + ' - No Record to Delete - Skipping: ' + recordKey);
                                    }
                                }
                                else if(astMap.containsKey(a.Id + '-' + ts)){
                                    system.debug('Sales on the Account! - ' + ts);
                                    if(simpleRecordCheck.containsKey(a.Id + '-' + ts)){
                                        system.debug('[2] Record Already Exists - Skipping! - ' + ts);
                                    }
                                    else{
                                        megaDMLmap.put(dupKey, newTA);                                                
                                    }
                                }
                                else if(dupCheck.containskey(dupKey)){
                                    // If the Rank of the new record is higher, switch out the records (18Aug2017 - ESC)
                                    if(ta.ZPSA_Priority__c < dupCheckRank.get(dupKey)){
                                        system.debug('[3] Switching! - ' + dupKey + ' - ' + ts);
                                        megaDMLmap.put(dupKey, newTA);
                                        if(recordCheck.containsKey(dupCheck.get(dupKey))){
                                            ta_set_remove.add(recordCheck.get(dupCheck.get(dupKey)));
                                        }
                                    } // END
                                    else if(dupCheck.get(dupKey) != ts && recordCheck.containsKey(recordKey)){
                                        ta_set_remove.add(recordCheck.get(recordKey));
                                    }
                                    system.debug('[3] Duplicate Role - Skipping: ' + ts + ' - ' + ta.Matching_Logic__c + ' - Match: ' + bu + '/' + trole + '/' + dupCheck.get(dupKey) + ' CR1: ' + ta.ZPSA_Priority__c + ' PR:' + dupCheckRank.get(dupKey));
                                }
                                else{
                                    if(recordCheck.containsKey(recordKey)){
                                        system.debug('[3] Adding (Record Exists - No DML - ' + ta.Matching_Logic__c + '): ' + recordKey + ' CR1: ' + ta.ZPSA_Priority__c);
                                    }
                                    else{
                                        system.debug('[3] Adding (New Record - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                        //insTAlist.add(newTA);
                                        megaDMLmap.put(dupKey, newTA);
                                    }
                                    dupCheck.put(dupKey, ts); // BU - Role - SAP = Territory Number
                                    dupCheckRank.put(dupKey, ZPSArank.get(ta.Zpsa_Table__c)); // BU - Role - SAP = Territory Number
                                } // ELSE
                            }
                            else{
                                system.debug('[3] No Territory Master for: ' + ts);
                            }
                        } // For ts 
                    } // Account
                } // rule loop
            } // Size
            
            if(Test.isRunningTest()) dupCheck.clear();
            
            // Match State/Region (Level 4)        
            if(regionFilterKey.size() > 0){
                for(Territory_Alignment__c ta : [SELECT Region__c, Territory__c, Territory_Name__c, ZPSA_Table__c, 
                                                 Territory2__c, Territory3__c, Territory4__c, Matching_Logic__c, ZPSA_Priority__c  
                                                 FROM Territory_Alignment__c 
                                                 WHERE Filter_Key__c IN :regionFilterKey 
                                                 AND Active__c = TRUE
                                                 ORDER BY ZPSA_Priority__c ASC])
                {
                    system.debug('Match State/Region Results: ' + ta);
                    
                    // Determine if there are additional Territories other than the primary and iterate through those
                    set<String> tlist = new set<String>();
                    tlist.add(ta.Territory__c);
                    if(ta.Territory2__c != NULL) tlist.add(ta.Territory2__c); 
                    if(ta.Territory3__c != NULL) tlist.add(ta.Territory3__c);
                    if(ta.Territory4__c != NULL) tlist.add(ta.Territory4__c);
                    
                    system.debug('tlist: ' + tlist);
                    
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
                                system.debug('dupKey: ' + dupKey + ' - recordKey: ' + recordKey);
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
                                if(emptyTerritory.containskey(ts)){
                                    if(recordCheck.containskey(recordKey)){
                                        system.debug('[4] Empty Territory - ' + ta.Matching_Logic__c + ' - Adding this record for delete: ' + ta.Id);
                                        ta_set_remove.add(recordCheck.get(recordKey));
                                    }
                                    else{
                                        system.debug('[4] Empty Territory - ' + ta.Matching_Logic__c + ' - No Record to Delete - Skipping: ' + recordKey);
                                    }
                                }
                                else if(dupCheck.containskey(dupKey)){
                                    // If the Rank of the new record is higher, switch out the records (18Aug2017 - ESC)
                                    if(ta.ZPSA_Priority__c < dupCheckRank.get(dupKey)){
                                        system.debug('[4] Switching! - ' + dupKey + ' - ' + ts);
                                        megaDMLmap.put(dupKey, newTA);
                                        if(recordCheck.containsKey(dupCheck.get(dupKey))){
                                            ta_set_remove.add(recordCheck.get(dupCheck.get(dupKey)));
                                        }
                                    } // END
                                    else if(dupCheck.get(dupKey) != ts && recordCheck.containsKey(recordKey)){
                                        ta_set_remove.add(recordCheck.get(recordKey));
                                    }
                                    system.debug('[4] Duplicate Role - Skipping: ' + ts + ' - ' + ta.Matching_Logic__c + ' - Match: ' + bu + '/' + trole + '/' + dupCheck.get(dupKey) + ' CR1: ' + ta.ZPSA_Priority__c + ' PR:' + dupCheckRank.get(dupKey));
                                }
                                else{
                                    if(recordCheck.containsKey(recordKey)){
                                        system.debug('[4] Adding (Record Exists - No DML - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                    }
                                    else{
                                        system.debug('[4] Adding (New Record - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                        //insTAlist.add(newTA);
                                        megaDMLmap.put(dupKey, newTA);
                                    }
                                    dupCheck.put(dupKey, ts); // BU - Role - SAP = Territory Number
                                    dupCheckRank.put(dupKey, ZPSArank.get(ta.Zpsa_Table__c)); // BU - Role - SAP = Territory Number
                                } // ELSE
                            }
                            else{
                                system.debug('[4] No Territory Master for: ' + ts);
                            }
                        } // tlist
                    } // account
                }
            }
            if(megaDMLmap.size() > 0){
                insTAlist.addAll(megaDMLmap.values());
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
        } 
    }
    /*
    public static void alignAccounts(List<Account> newTrigger){
        // 
        // Test Class: territory_Account_Shares_TEST
        // 
        // qd stands for Quick Disable. Look in the Custom Settings, if set to false this
        // class will not fire. If the value doesn't exist it will default to true and the class will fire.
        if(master_TriggerHelperClass.qd('territory_Account_Alignment')){
            system.debug('Starting alignAccounts!!!');
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
            //map<String, String> tmap = new map<String, String>();
            map<String, String> emptyTmap = new map<String, String>();
            map<String, Id> tlookup = new map<String, Id>();
            map<String, boolean> tcheck = new map<String, boolean>();
            //set<Id> acctIds = new set<Id>();
            set<String> taaKeepers = new set<String>();
            string aId15;
            
            for(Territory_Master__c tm : [Select Id, Territory_Number__c, User_Count__c 
                                          FROM Territory_Master__c])
            {
                tlookup.put(tm.Territory_Number__c, tm.Id);
                if(tm.User_Count__c == 0){
                    emptyTmap.put(tm.Territory_Number__c, 'Skip');
                }
            }
            list<Territory_Assignment__c> insTAlist = new list<Territory_Assignment__c>();
            
            // This Loops through the Accounts to create the keys used to query the ZPSA Rules
            for(Account a : newTrigger){
                if(a.SAP_Sold_to__c != NULL){
                    sapFilterKey.add(a.SAP_Sold_to__c + '-A681');
                    sapFilterKey.add(a.SAP_Sold_to__c + '-A680');
                    sapFilterKey.add(a.SAP_Sold_to__c + '-A654');
                    sapFilterKey.add(a.SAP_Sold_to__c + '-A679');
                    system.debug('sapFilterKey: ' + sapFilterKey);
                }
                if(a.BillingState != NULL){
                    regionFilterKey.add(a.BillingState + '-A659');
                    regionFilterKey.add(a.BillingState + '-A688');
                    regionFilterKey.add(a.BillingState + '-A689');
                    system.debug('regionFilterKey: ' + regionFilterKey);
                }
                if(a.BillingPostalCode != NULL){
                    zipFilterKey.add(a.BillingPostalCode + '-A626');
                    zipFilterKey.add(a.BillingPostalCode.left(3) + '-A675');
                    zipFilterKey.add(a.BillingPostalCode.left(5) + '-A667');
                    zipFilterKey.add(a.BillingPostalCode.left(5) + '-A668');
                    system.debug('zipFilterKey: ' + zipFilterKey);
                }
                if(a.BillingPostalCode != NULL && a.Customer_Group__c != NULL){
                    zipcusFilterKey.add(a.BillingPostalCode.left(3) + a.Customer_Group__c + '-A672');
                    zipcusFilterKey.add(a.BillingPostalCode.left(3) + a.Customer_Group__c + '-A671');
                    zipcusFilterKey.add(a.BillingPostalCode.left(5) + a.Customer_Group__c + '-A663');
                    zipcusFilterKey.add(a.BillingPostalCode.left(5) + a.Customer_Group__c + '-A664');
                    
                    system.debug('zipcusFilterKey: ' + zipcusFilterKey);
                }
            }

            // Check to see if there's an Assignment already for this Account
            for( Territory_Assignment__c taa : [SELECT Territory_Number__c, Account__c
                                                FROM Territory_Assignment__c 
                                                WHERE Account__c IN :newTrigger])
            {
                tcheck.put(taa.Territory_Number__c + '-' + taa.Account__c, TRUE);
            }

            // This is where the work happens.
            // Class checks through the 4 levels of ZPSA and tries to match the account
            
            // Match SAP Code
            if(sapFilterKey.size() > 0){
                for(Territory_Alignment__c ta : [SELECT SAP_Code__c, Territory__c, Territory_Name__c, ZPSA_Table__c, 
                                                 Territory2__c, Territory3__c, Territory4__c 
                                                 FROM Territory_Alignment__c 
                                                 WHERE Filter_Key__c IN :sapFilterKey 
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
                    for(Account a : newTrigger){
                        if(a.SAP_Sold_to__c != NULL){
                            if(ta.SAP_Code__c == a.SAP_Sold_to__c){
                                for(String ts : tlist){
                                    //if(tmap.get(ts + '-' + a.Id) == NULL && emptyTmap.get(ts) == NULL){
                                    
                                    if(tcheck.get(ts + '-' + a.Id) == NULL && emptyTmap.get(ts) == NULL){
                                        //tmap.put(ts + '-' + a.Id, 'Yes');
                                        
                                        Territory_Assignment__c newTA = new Territory_Assignment__c(
                                            Name = a.SAP_Sold_To__c + '-' + ts + ' ' + ta.Territory_Name__c, 
                                            Territory_Alignment__c = ta.Id,
                                            Territory__c = tlookup.get(ts),
                                            Territory_Number__c = ts,
                                            Account__c = a.Id,
                                            ZPSA_Table__c = ta.ZPSA_Table__c,
                                            Matching_Logic__c = 'SAP Code and Territory Number',
                                            Assignment_Reason__c = 'The Region/State on this account was matched to a state and territory in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                                        );
                                        insTAlist.add(newTA);
                                    }
                                    else if(emptyTmap.get(ts) == NULL){
                                        system.debug('Skipping! ' + ts);
                                        aId15 = a.Id;
                                        taaKeepers.add(ts + '-' + aId15.left(15));
                                    }
                                }
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
                    for(Account a : newTrigger){
                        if(a.BillingState != NULL){
                            if(ta.Region__c == a.BillingState){
                                for(String ts : tlist){
                                    if(tcheck.get(ts + '-' + a.Id) == NULL && emptyTmap.get(ts) == NULL){
                                        //tmap.put(ts + '-' + a.Id, 'Yes');
                                        
                                        Territory_Assignment__c newTA = new Territory_Assignment__c(
                                            Name = a.SAP_Sold_To__c + '-' + ta.Region__c + '-' + ts + ' ' + ta.Territory_Name__c, 
                                            Territory_Alignment__c = ta.Id,
                                            Territory__c = tlookup.get(ts),
                                            Territory_Number__c = ts,
                                            Account__c = a.Id,
                                            ZPSA_Table__c = ta.ZPSA_Table__c,
                                            Matching_Logic__c = 'Region/State and Territory Number',
                                            Assignment_Reason__c = 'The Region/State on this account was matched to a state and territory in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                                        );
                                        insTAlist.add(newTA);
                                    }
                                    else if(emptyTmap.get(ts) == NULL){
                                        system.debug('Skipping! ' + ts);
                                        aId15 = a.Id;
                                        taaKeepers.add(ts + '-' + aId15.left(15));

                                    }
                                }
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
                                                 AND Active__c = TRUE])
                {
                    //system.debug('Match Zipcode Results: ' + ta);
                    
                    // Determine if there are additional Territories other than the primary and iterate through those
                    set<String> tlist = new set<String>();
                    tlist.add(ta.Territory__c);
                    if(ta.Territory2__c != NULL) tlist.add(ta.Territory2__c); 
                    if(ta.Territory3__c != NULL) tlist.add(ta.Territory3__c);
                    if(ta.Territory4__c != NULL) tlist.add(ta.Territory4__c);
                    
                    // Cycle through the accounts to create territory assignment matches
                    for(Account a : newTrigger){
                        if(a.BillingPostalCode != NULL){
                            if(
                                ta.Zipcode__c == a.BillingPostalCode || 
                                ta.Zipcode__c == a.BillingPostalCode.left(5) || 
                                ta.Zipcode__c == a.BillingPostalCode.left(3)
                            ){                                                            
                                for(String ts : tlist){
                                    if(tcheck.get(ts + '-' + a.Id) == NULL && emptyTmap.get(ts) == NULL){
                                        //tmap.put(ts + '-' + a.Id, 'Yes');
                                        
                                        Territory_Assignment__c newTA = new Territory_Assignment__c(
                                            Name = a.SAP_Sold_To__c + '-' + ta.Zipcode__c + '-' + ts + ' ' + ta.Territory_Name__c, 
                                            Territory_Alignment__c = ta.Id,
                                            Territory__c = tlookup.get(ts),
                                            Territory_Number__c = ts,
                                            Account__c = a.Id,
                                            ZPSA_Table__c = ta.ZPSA_Table__c,
                                            Matching_Logic__c = 'Zip/Postal Code and Territory Number',
                                            Assignment_Reason__c = 'The Zip/Postage Code on this account was a match in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                                        );
                                        insTAlist.add(newTA);
                                    }
                                    else if(emptyTmap.get(ts) == NULL){
                                        system.debug('Skipping! ' + ts);
                                        aId15 = a.Id;
                                        taaKeepers.add(ts + '-' + aId15.left(15));

                                    }
                                }
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
                    for(Account a : newTrigger){
                        if(a.BillingPostalCode != NULL && ta.Customer_Group__c != NULL){
                            if(
                                (
                                    ta.Zipcode__c == a.BillingPostalCode.left(5) || 
                                    ta.Zipcode__c == a.BillingPostalCode.left(3)
                                )
                                && ta.Customer_Group__c == a.Customer_Group__c 
                            ){
                                for(String ts : tlist){
                                    if(tcheck.get(ts + '-' + a.Id) == NULL && emptyTmap.get(ts) == NULL){
                                        //tmap.put(ts + '-' + a.Id, 'Yes');
                                        
                                        Territory_Assignment__c newTA = new Territory_Assignment__c(
                                            Name = a.SAP_Sold_To__c + '-' + ta.Zipcode__c + '-' + ta.Customer_Group__c + '-' + ts + ' ' + ta.Territory_Name__c, 
                                            Territory_Alignment__c = ta.Id,
                                            Territory__c = tlookup.get(ts),
                                            Territory_Number__c = ts,
                                            Account__c = a.Id,
                                            ZPSA_Table__c = ta.ZPSA_Table__c,
                                            Matching_Logic__c = 'Zip/Postal Code, Customer Group, and Territory Number',
                                            Assignment_Reason__c = 'The Zip/Postage Code and Customer Group on this account was a match in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                                        );
                                        insTAlist.add(newTA);   
                                    }
                                    else if(emptyTmap.get(ts) == NULL){
                                        system.debug('Skipping! ' + ts);
                                        aId15 = a.Id;
                                        taaKeepers.add(ts + '-' + aId15.left(15));

                                    }
                                }    
                            }
                        }
                    }
                }
            }
            //system.debug('tmap: ' + tmap);
            /*
            // Customer Group (cusFilterKey)
            // If you resurect this code...it needs to be deleted and refactored with all the changes made above.
            if(cusFilterKey.size() > 0){
                for(Territory_Alignment__c ta : [SELECT SAP_Code__c, Customer_Group__c, Territory__c, Zipcode__c, 
                                                 Territory_Name__c, ZPSA_Table__c  
                                                 FROM Territory_Alignment__c 
                                                 WHERE Filter_Key__c IN :cusFilterKey])
                {
                    system.debug('Match Zipcode + Customer Group Results: ' + ta);
                    for(Account a : newTrigger){
                        if(
                            ta.Customer_Group__c == a.Customer_Group__c 
                            && tmap.get(ta.Territory__c + a.Id) == NULL
                        ){
                            tmap.put(ta.Territory__c + a.Id, 'Yes');
                            Territory_Assignment__c newTA = new Territory_Assignment__c(
                                Name = a.SAP_Sold_To__c + '-' + ta.Customer_Group__c + '-' + ta.Territory__c + ' ' + ta.Territory_Name__c, 
                                Territory_Alignment__c = ta.Id,
                                Territory__c = tlookup.get(ta.Territory__c),
                                Territory_Number__c = ta.Territory__c,
                                Account__c = a.Id,
                                ZPSA_Table__c = ta.ZPSA_Table__c,
                                Matching_Logic__c = 'Customer Group and Territory Number',
                                Assignment_Reason__c = 'The Customer Group on this account was a match in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                            );
                            insTAlist.add(newTA);
                            //system.debug('InsTAlist: ' + insTAlist);
                        }
                    }
                }
}

            // Clean out the territories just to make sure
            system.debug('taaKeepers: ' + taaKeepers);
            list<Territory_Assignment__c> delTAlist = [SELECT id 
                                                       FROM Territory_Assignment__c 
                                                       WHERE Account__c IN :newTrigger
                                                       AND Key__c NOT IN :taaKeepers];
            if(delTAlist.size() > 0){
                system.debug('Deleting -- delTAlist: ' + delTAlist);
                //delete delTAlist;
            }
            else{
                system.debug('Nothing to DELETE!!!');
            }
            
            if(insTAlist.size() > 0){
                system.debug('Inserting -- insTAlist: ' + insTAlist);
                insert insTAlist;
            }
            else{
                system.debug('Nothing to INSERT!!!');
            }
            
            system.debug('-- Finished Territory Account Alignment --');
        }  
    }*/
}