public class territory_User_Assignment {
    public class ValidationException extends Exception{}
    
    public static void setBusinessUnit(List<Territory_Alignment__c> newTrigger){
        // This 'before' trigger/class pulls the Business Unit from the Territory Master
        // using the 'Territory 1' number. Territory 2-4 are only used for inside sales.
        // This allows us to query the rules based on Business Unit. - ESC 08Mar2016
        
        list<Territory_Alignment__c> taList = new list<Territory_Alignment__c>();
        list<String> tnumList = new list<String>();
        for(Territory_Alignment__c ta : newTrigger){
            if(ta.Business_Unit__c == NULL || ta.Territory_Master__c == NULL){
                taList.add(ta);
                tnumList.add(ta.Territory__c);
            }
        }    
        if(talist.size() > 0){
            map<string, Territory_Master__c> tmMap = new map<string, Territory_Master__c>();
            for(Territory_Master__c tm : [Select Id, Business_Unit__c, Territory_Number__c 
                                          FROM Territory_Master__c
                                          WHERE Territory_Number__c = :tnumList])
            {
                //tmMap.put(tm.Territory_Number__c, tm.Business_Unit__c);
                tmMap.put(tm.Territory_Number__c, tm);
            }
            for(Territory_Alignment__c ta : taList){
                if(tmMap.get(ta.Territory__c) != NULL){
                    ta.Business_Unit__c = tmMap.get(ta.Territory__c).Business_Unit__c;
                    ta.Territory_Master__c = tmMap.get(ta.Territory__c).Id;
                }
            }
        }
    }
    
    public static void assignUser(List<Lead> newTrigger, Map<Id,Lead> oldTrigger,String type){
        // This 'before' trigger/class assigns a user ID to the 'Territory Based Owner'
        // field using State, Zip, and Business unit in confunction with the ZPSA rules
        // found in the 'Territory Alignment Rules' object in order to get away from using
        // a Zip Code database. ESC - 08Mar2016
        // 
        // Test Class: account_Page_Helper_Test (at the bottom)
        if(master_TriggerHelperClass.qd('territory_User_Assignment')){
            system.debug(' -- Starting Lead assignUser Class -- ');
            
            // Set are Variables
            
            string lrid;
            string olrid;
            string tfxstdId;
            boolean countryCheck;
            boolean buildKeys;
            string countryStr;
            
            list<Lead> workLeads = new list<Lead>();
            list<Lead> changedLeads = new list<Lead>();
            list<Lead> finalLeads = new list<Lead>();
            
            set<String> regionFilterKey = new set<String>();
            set<String> zipFilterKey = new set<String>();
            set<String> buList = new set<String>();
            
            map<string, string> lsMap = new map<string, string>();
            map<string, string> leadRecMap = new map<string, string>();
            map<string, boolean> leadAutoDisable = new map<string, boolean>();
            map<string, id> leadQueue = new map<string, id>();
            
            // Updated - 12Mar2018
            id recId_default;
            map<String, Lead_Settings__c> lsMap2 = Lead_Settings__c.getall();
            
            // Let's get to work ---
            
            // Load in the Customer Setting 'Lead Settings' and then load up 2 maps for ensuring
            // that Record Type and Business Unit are correctly populated
            list<Lead_Settings__c> lsList = Lead_Settings__c.getall().values();
            system.debug('Lead Settings: ' + lsList);
            
            // Standard Teleflex Lead Record Type ID
            for(RecordType rt : [SELECT Id 
                                 FROM RecordType 
                                 WHERE SobjectType = 'Lead' 
                                 AND DeveloperName = 'Teleflex_Standard_Lead' LIMIT 1])
            {
                recId_default = rt.id;
                tfxstdId = rt.Id;
                tfxstdId = tfxstdId.left(15);
                //012E0000000DDZGIA4
            }
            system.debug('tfxstdId: ' + tfxstdId);
            
            string gidId;
            for(User u : [SELECT Id  
                          FROM User 
                          WHERE Name = 'Global IT' 
                          LIMIT 1])
            {
                gidId = u.Id;
            }
            
            //Map<String,Customer_Setting_Name__c> buMap =Customer_Setting_Name__c.getAll();
            for(Lead_Settings__c ls : lsList){
                if(ls.Disable_Autorouting__c){
                    leadAutoDisable.put(ls.Record_Type_ID__c, TRUE);
                    //system.debug('Lead Routing Disabled: ' + ls.Name);
                }
                else{
                    lsMap.put(ls.Record_Type_ID__c, ls.Name);
                    leadRecMap.put(ls.Name, ls.Record_Type_ID__c);
                    leadQueue.put(ls.Name, ls.Lead_Owner_ID__c);
                }

            }
            system.debug('lsMap: ' + lsMap);
            
            //Let's check to see if anything changed and remove it from the list if it has.
            
            for(lead l : newTrigger){
                if(l.RecordTypeId == NULL){
                    l.RecordTypeId = tfxstdId;
                }
                else{
                    // Set Current Record Type ID            
                    lrid = l.RecordTypeId;
                    lrid = lrid.left(15);
                    system.debug('Lead Record Type ID: ' + lrid);
                    
                    // Step 1 - Set the BU and the Record Types
                    
                    // Going to backup the Record Type ID so we have an actionable record of what the Lead came in on.
                    if(l.Original_Record_Type_ID__c == NULL && type == 'insert'){
                        l.Original_Record_Type_ID__c = l.RecordTypeId;
                    }
                    
                    // Set the Business Unit from the Record Type if Business Unit is Blank
                    if(lsMap.containsKey(lrid) && l.Business_Unit__c == NULL){
                        system.debug('Business Unit was Blank - Setting the BU based on record type: ' + lsMap.get(lrid) + '(' + lrid + ')');
                        if(lsMap.get(lrid) != 'Default'){
                            l.Business_Unit__c = lsMap.get(lrid);                        
                        }
                        if(lsMap.get(lrid) == 'Default' && l.Original_Record_Type_ID__c != NULL){
                            // Second Bite of the Apple
                            olrid = l.Original_Record_Type_ID__c;
                            olrid = olrid.left(15);
                            if(lsMap.get(olrid) != 'Default'){
                                l.Business_Unit__c = lsMap.get(olrid);                        
                            }
                        }
                    }
                    // This Fixes the Lead Record Type if it needs it
                    if(tfxstdId != lrid){
                        system.debug('Record Type Did not match the Business Unit - Setting the Record Type based on the Business Unit: ' + lsMap.get(lrid) + ' (' + lrid + ')');
                        // Disabling this for new Global Pick List - 06Jun2017 ESC
                        //l.RecordTypeId = leadRecMap.get(l.Business_Unit__c);
                        
                        // This will set record type to the Teleflex Standard Lead record type
                        l.RecordTypeId = tfxstdId;
                    }
                } // Record Type ID Check
                                
                // Step 2 - Check to make sure leads are in the US or CA
                countryCheck = FALSE;
                if(l.Country != NULL){
                    countryStr = l.Country;
                    countryStr = countryStr.toUpperCase();
                    if(countryStr == 'US' || countryStr == 'CA' || countryStr == 'USA' ||countryStr == 'CAN' ||
                       countryStr == 'UNITED STATES' || countryStr == 'UNITED STATES OF AMERICA' ||
                       countryStr == 'CANADA'
                      ){
                          countryCheck = TRUE;
                      }
                }
                else if(l.OwnerId == gidId){
                    countryCheck = TRUE;
                }
                else{
                    system.debug('Country Code Not Set - Lead Routing Not');
                }
                
                // Stage 3 - Prep Leads for ZPSA matching
                if(countryCheck){
                    system.debug('Checking the Business Unit based on Record Type');
                    
                    // Convert the Record Type ID from 18 to 15 characters
                    buildKeys = FALSE;
                    if(!leadAutoDisable.containsKey(lrid)){
                        system.debug('Stage 1 - Determine whether to add the record');                        
                        // Main Logic Section
                        // 
                        // If BU, State or Zip are not NULL and the Force Check is TRUE add the lead to the list
                        if(
                            type == 'insert' && 
                            l.Business_Unit__c != NULL
                            // Disabling in order to route more new leads to the lead queue below - ESC - 10Jul2017
                            //&& (l.State != NULL ||
                            //l.PostalCode != NULL)
                        ){
                            system.debug('Insert!');
                            changedLeads.add(l);
                            buList.add(l.Business_Unit__c);
                            buildKeys = TRUE;
                        }
                        
                        // If BU is not NULL and the BU, Zip, State have changed add the lead to the list
                        else if(
                            type == 'update' && 
                            l.Business_Unit__c != NULL &&
                            (l.State != oldTrigger.get(l.Id).State ||
                             l.PostalCode != oldTrigger.get(l.Id).PostalCode ||
                             l.Business_Unit__c != oldTrigger.get(l.Id).Business_Unit__c 
                            )
                        ){
                            system.debug('BU is not NULL and the BU, Zip, State have changed add the lead to the list');
                            changedLeads.add(l);
                            buList.add(l.Business_Unit__c);
                            buildKeys = TRUE;
                        }
                        // If BU, State or Zip are not NULL and the Force Check is TRUE add the lead to the list
                        else if(
                            type == 'update' && 
                            l.Business_Unit__c != NULL &&
                            (l.State != NULL ||
                             l.PostalCode != NULL) &&
                            (l.Force_Territory_Assigment_Check__c == TRUE || 
                             l.Zip_Code_Auto_Route__c == FALSE ||  
                             l.Assign_Using_Territories__c == TRUE)
                        ){
                            system.debug('BU, State or Zip are not NULL and one of the checkboxes has been flipped');
                            changedLeads.add(l);
                            buList.add(l.Business_Unit__c);
                            buildKeys = TRUE;
                        }
                        if(buildKeys){
                            system.debug('Building the Database Keys');
                            if(l.State != NULL){
                                regionFilterKey.add(l.State + '-A659');
                                regionFilterKey.add(l.State + '-A688');
                                regionFilterKey.add(l.State + '-A689');
                                system.debug('regionFilterKey: ' + regionFilterKey);
                            }
                            if(l.PostalCode != NULL){
                                zipFilterKey.add(l.PostalCode + '-A626');
                                zipFilterKey.add(l.PostalCode.left(3) + '-A675');
                                zipFilterKey.add(l.PostalCode.left(5) + '-A667');
                                zipFilterKey.add(l.PostalCode.left(5) + '-A668');
                                // Non-Standard Zip Code ZPSA Tables - These are the Zip+Customer Group Tables
                                zipFilterKey.add(l.PostalCode.left(3) + '-A672');
                                zipFilterKey.add(l.PostalCode.left(3) + '-A671');
                                zipFilterKey.add(l.PostalCode.left(5) + '-A663');
                                zipFilterKey.add(l.PostalCode.left(5) + '-A664');
                                system.debug('zipFilterKey: ' + zipFilterKey);
                            }
                        }
                    } // END BU Autoroute Enabled Check
                } // End Country Check
                else{
                    if(l.OwnerId == gidId && leadQueue.containsKey(l.Business_Unit__c)){
                        l.OwnerId = leadQueue.get(l.Business_Unit__c);
                        l.Match_Reason__c = 'No Match - Setting Owner to Lead Queue';
                    }
                    
                    
                }
                if(l.OwnerId == gidId && leadQueue.containsKey(l.Business_Unit__c)){
                    l.OwnerId = leadQueue.get(l.Business_Unit__c);
                    l.Match_Reason__c = 'No Match - Setting Owner to Lead Queue';
                }
            } // End Lead FOR Loop
            
            
            
            system.debug('buList: ' + buList);
            
            if(changedLeads.size() > 0){
                system.debug('-- Starting Stage2 of User Assign --');
                map<string,Id> tuMap = new map<string,Id>();
                for(Territory_User__c tm : [Select User__c, Territory_Number__c 
                                            FROM Territory_User__c 
                                            WHERE Business_Unit__c  = :buList
                                            AND User_Active__c = TRUE 
                                            AND Role__c != 'Inside Sales' 
                                            AND Territory_Master__r.Disable_Lead_Routing__c = FALSE  
                                            ORDER BY Territory_Number__c, Is_Manager__c DESC, Primary__c, CreatedDate DESC])
                {
                    tuMap.put(tm.Territory_Number__c, tm.User__c);
                }
                system.debug('tuMap: ' + tuMap);
                
                map<string,string> stateMap = new map<string,string>();
                map<string,string> zipMap = new map<string,string>();
                // Match State/Region
                if(regionFilterKey.size() > 0){
                    for(Territory_Alignment__c ta : [SELECT Territory__c, Region__c, Business_Unit__c   
                                                     FROM Territory_Alignment__c 
                                                     WHERE Filter_Key__c IN :regionFilterKey 
                                                     AND Business_Unit__c IN :buList 
                                                     AND Expired__c = FALSE 
                                                     AND Territory_Master__r.Disable_Lead_Routing__c = FALSE 
                                                     AND Territory_Master__r.User_Count__c != 0 ])
                    {
                        stateMap.put(ta.Region__c+ta.Business_Unit__c, ta.Territory__c);
                        system.debug('Add State: ' + stateMap);
                    }
                } 
                
                // Match Zipcode
                if(zipFilterKey.size() > 0){
                    for(Territory_Alignment__c ta : [SELECT Territory__c, Zipcode__c, Business_Unit__c  
                                                     FROM Territory_Alignment__c 
                                                     WHERE Alt_Filter_Key__c IN :zipFilterKey 
                                                     AND Business_Unit__c IN :buList 
                                                     AND Expired__c = FALSE 
                                                     AND Territory_Master__r.Disable_Lead_Routing__c = FALSE 
                                                     AND Territory_Master__r.User_Count__c != 0 ])
                    {
                        zipMap.put(ta.Zipcode__c+ta.Business_Unit__c, ta.Territory__c);
                        system.debug('Add Zip: ' + zipMap);
                    }
                }

                                
                string tnumber;
                string tuserid;
                string mreason;
                for(lead l : changedLeads){
                    //finalLeads
                    tnumber = NULL;
                    tuserid = NULL;
                    mreason = NULL;
                    
                    system.debug('Match Zip and State: ' + l.PostalCode + '/' + l.State);
                    
                    if(l.PostalCode != NULL){
                        
                        if(zipMap.containsKey(l.PostalCode.left(3)+l.Business_Unit__c)){
                            tnumber = zipMap.get(l.PostalCode.left(3)+l.Business_Unit__c);
                            mreason = 'Matched on 3 Digit Zip: ' + l.PostalCode.left(3);
                            system.debug('Zip3 Match: ' + tnumber);
                        }
                        else if(zipMap.containsKey(l.PostalCode.left(5)+l.Business_Unit__c)){
                            tnumber = zipMap.get(l.PostalCode.left(5)+l.Business_Unit__c);
                            mreason = 'Matched on 5 Digit Zip: ' + l.PostalCode.left(5);
                            system.debug('Zip5 Match: ' + tnumber);
                        }
                        else if(zipMap.containsKey(l.PostalCode+l.Business_Unit__c)){
                            tnumber = zipMap.get(l.PostalCode+l.Business_Unit__c);
                            mreason = 'Matched on Full Zip10 Code: ' + l.PostalCode;
                            system.debug('Zip10 Match: ' + tnumber); // Zip10 == Wide Open
                        }
                        
                        if(tuMap.containsKey(tnumber)){
                            tuserid = tuMap.get(tnumber); 
                            system.debug('Adding Zip User Id - Approval: ' + tuserid);
                        }
                        else{
                            system.debug('Zip: No tuMap / tnumber Match!');
                        }

                    }
                    if(l.State != NULL && tuserid == NULL){
                        if(stateMap.containsKey(l.State+l.Business_Unit__c)){
                            tnumber = stateMap.get(l.State+l.Business_Unit__c);
                            mreason = 'Matched on State: ' + l.State;
                            system.debug('State Match: ' + tnumber);
                        }
                        
                        system.debug('State User Id: ' + tuMap.get(tnumber));
                        if(tuMap.containsKey(tnumber)){
                            tuserid = tuMap.get(tnumber); 
                            system.debug('Adding State User Id - Approval: ' + tuserid);
                        }
                        else{
                            system.debug('State: No tuMap / tnumber Match!');
                        }
                    }
                    
                    // Here is were the magic happens - If we have a Territory User ID set we are
                    // going to write it to the 'Territory Based Owner' field by default and if
                    // either the 'Do Not Assign Lead using Territory rules' is checked FALSE or
                    // the 'Assign Using Territories' checkbox are TRUE 
                    if(tuserid != NULL){
                        l.Territory_Based_Owner__c = tuserid;
                        if(l.Assign_Using_Territories__c == TRUE || l.Zip_Code_Auto_Route__c == FALSE){
                            l.OwnerId = tuserid;
                        }
                        if(mreason != NULL){
                            l.Match_Reason__c = mreason;
                        }
                    }
                    else if(leadQueue.containsKey(l.Business_Unit__c)){
                        // The Global IT user should not own any Leads
                        if(type == 'insert' && l.OwnerId == gidId){
                            l.OwnerId = leadQueue.get(l.Business_Unit__c);
                            l.Match_Reason__c = 'No Match - Setting Owner to Lead Queue';                            
                        }
                        // If you created it - you should know where it should go and/or change it to the lead queue
                        // For everyone else the automation will flip it to the lead queue related to their Business Unit
                        else if(l.OwnerId != l.CreatedById && (
                            l.Force_Territory_Assigment_Check__c == TRUE || 
                            l.Zip_Code_Auto_Route__c == FALSE || 
                            l.Assign_Using_Territories__c == TRUE)
                          )
                        {
                            l.OwnerId = leadQueue.get(l.Business_Unit__c);
                            l.Match_Reason__c = 'No Match - Setting Owner to Lead Queue';
                        }
                    }
                    
                    
                    else{
                        system.debug('UHOH! - Something went wrong - No Match for User OR Lead Queue!');                        
                    }
                    
                } // End Final Loop
            } // End stage2 IF/Then
            
            // House Keeping - Set all of the Checkboxes back to their defaults
            for(lead l : newTrigger){
                l.Force_Territory_Assigment_Check__c = FALSE;
                l.Assign_Using_Territories__c = FALSE;
                l.Zip_Code_Auto_Route__c = TRUE;
            }
        }
    } // End Class

    public static void setTerritoryNumber(List<Lead> newTrigger, Map<Id,Lead> oldTrigger,String type){
        //Test Class: territory_user_security_test
        
        set<Id> lid = new set<Id>();
        list<Lead> workList = new list<Lead>();
        string oid;

        for(Lead l : newTrigger){
            if(
                type == 'insert' 
                && l.Owner_Territory_Number__c == NULL // Empty Field
                && oid != '00G' // Filter out the Queues
            ){
                lid.add(l.OwnerId);
                workList.add(l);
            }
            else if(
                type == 'update' 
                /*&& l.OwnerId != NULL 
                && oldTrigger.get(l.Id).OwnerId != NULL*/
                && (oldTrigger.get(l.Id).OwnerId != l.OwnerId || l.Owner_Territory_Number__c == NULL) // Changed Owner or Empty Field
                && oid != '00G' // Filter out the Queues
            )
            {
                lid.add(l.OwnerId);
                workList.add(l);
            }
        }
        if(workList.size() > 0){
            map<Id, Territory_Master__c> tMap = new map<Id, Territory_Master__c>();
            for(Territory_Master__c tm : [SELECT Primary_Sales_Rep_Flip__c, Primary_Territory_User__c, Role_Toggle__c, Sales_Rep__c, 
                                          Territory_Name__c, Territory_Short_Name__c, Territory_Number__c, Parent_Territory__r.Territory_Name__c,
                                          Parent_Territory__r.Territory_Short_Name__c, Parent_Territory__r.Territory_Number__c 
                                          FROM Territory_Master__c 
                                          WHERE Role_Toggle__c = 'REP' 
                                          AND (Primary_Territory_User__c = :lid OR Sales_Rep__c = :lid)])
            {
                if(tm.Sales_Rep__c != NULL && tm.Primary_Sales_Rep_Flip__c == FALSE){
                    tMap.put(tm.Sales_Rep__c, tm);                    
                }
                else if(tm.Primary_Territory_User__c != NULL){
                    tMap.put(tm.Primary_Territory_User__c, tm); 
                }
            }
            
            for(Lead l : workList){
                if(tMap.containsKey(l.OwnerId)){
                    // Territory - REP
                    l.Owner_Territory_Number__c = tMap.get(l.OwnerId).Territory_Number__c;
                    if(tMap.get(l.OwnerId).Territory_Short_Name__c != NULL){
                        l.Owner_Territory_Name__c = tMap.get(l.OwnerId).Territory_Short_Name__c;
                    }
                    else{
                        l.Owner_Territory_Name__c = tMap.get(l.OwnerId).Territory_Name__c;
                    }
                    l.Owner_Region_Number__c = tMap.get(l.OwnerId).Parent_Territory__r.Territory_Number__c;
                    // Region - Manager
                    if(tMap.get(l.OwnerId).Parent_Territory__r.Territory_Short_Name__c != NULL){
                        l.Owner_Region_Name__c = tMap.get(l.OwnerId).Parent_Territory__r.Territory_Short_Name__c;
                    }
                    else{
                        l.Owner_Region_Name__c = tMap.get(l.OwnerId).Parent_Territory__r.Territory_Name__c;
                    }
                }
                
            }
        }
        
        /*
        for(Lead l : newTrigger){
            oid = l.OwnerId;
            oid = oid.left(3);
            
            if(
                type == 'insert' 
                && l.Owner_Territory_Number__c == NULL // Empty Field
                && oid != '00G' // Filter out the Queues
            )
            {
                leadid.add(l.OwnerId);
                firstPass.add(l);
            }
            else if(
                type == 'update' 
                && (oldTrigger.get(l.Id).OwnerId != l.OwnerId || l.Owner_Territory_Number__c == NULL) // Changed Owner or Empty Field
                && oid != '00G' // Filter out the Queues
            )
            {
                leadid.add(l.OwnerId);
                firstPass.add(l);
            }
            
        }
        if(firstPass.size() > 0){
            map<string, Territory_User__c> singleMap = new map<string, Territory_User__c>();
            
            list<Lead> updateLeads = new list<Lead>(); // Update List
            
            for(Territory_User__c tu : [SELECT User__c, Territory_Number__c, Territory_Master__r.Territory_Name__c, 
                                        Territory_Master__r.Region_Name__c, Territory_Master__r.Region_Number__c 
                                        FROM Territory_User__c 
                                        WHERE User__c = :leadid 
                                        AND Primary__c = TRUE])
            {
                singleMap.put(tu.User__c, tu);
            }
            string rnum;
            string tnum;
            for(Lead l : firstPass){
                if(singleMap.get(l.OwnerId) != NULL){
                    rnum = '';
                    tnum = '';
                    if(singleMap.get(l.OwnerId).Territory_Master__r.Region_Number__c != NULL){
                        rnum = singleMap.get(l.OwnerId).Territory_Master__r.Region_Number__c;
                        rnum = rnum.left(6);
                    }
                    else{
                        rnum = '';
                    }
                    if(singleMap.get(l.OwnerId).Territory_Number__c != NULL){
                        tnum = singleMap.get(l.OwnerId).Territory_Number__c;
                        tnum = tnum.left(6);
                    }
                    else{
                        tnum = '';
                    }
                    
                    Lead newLead = new Lead(
                        Id = l.Id,
                        Owner_Territory_Number__c = tnum,
                        Owner_Territory_Name__c = singleMap.get(l.OwnerId).Territory_Master__r.Territory_Name__c,
                        Owner_Region_Number__c  = rnum,
                        Owner_Region_Name__c  = singleMap.get(l.OwnerId).Territory_Master__r.Region_Name__c
                    );
                    updateLeads.add(newLead);
                    system.debug('Match: ' + l.Name);
                }
                else{
                    if(l.Owner_Territory_Number__c != NULL){
                        Lead newLead = new Lead(
                            Id = l.Id,
                            Owner_Territory_Number__c = '',
                            Owner_Territory_Name__c = '',
                            Owner_Region_Number__c = '',
                            Owner_Region_Name__c = ''
                        );
                        updateLeads.add(newLead);
                        system.debug('Removing Owner Territory Number: ' + l.Name);
                    }
                }
            }
            if(updateLeads.size() > 0){ update updateLeads; } 
        } */
        
        
    }
/*
    public static void setTerritoryNumber(List<Lead> newTrigger, Map<Id,Lead> oldTrigger,String type){
        system.debug('-- Starting setTerritoryNumber --');
        set<Id> tuidSet = new set<Id>();
        list<Lead> newLeads = new list<Lead>(); // First Round - Catches the Single Territory Users
        list<Lead> complexLeads = new list<Lead>(); // Second Round - Runs the remaining Leads through territory alignment
        list<Lead> updateLeads = new list<Lead>(); // Update List
        string oid;
        for(Lead l : newTrigger){
            oid = l.OwnerId;
            oid = oid.left(3);
            if(
                type == 'insert' 
                && l.Owner_Territory_Number__c == NULL // Empty Field
                && oid != '00G' // Filter out the Queues
                && l.Business_Unit__c != NULL // Need the BU
                && (l.State != NULL || l.PostalCode != NULL) // Need the address
            ){
                tuidSet.add(l.OwnerId);
                newLeads.add(l);
            }
            else if(
                type == 'update' 
                && (oldTrigger.get(l.Id).OwnerId != l.OwnerId || l.Owner_Territory_Number__c == NULL) // Changed Owner or Empty Field
                && oid != '00G' // Filter out the Queues
                && l.Business_Unit__c != NULL // Need the BU
                && (l.State != NULL || l.PostalCode != NULL) // Need the address
            ){
                tuidSet.add(l.OwnerId);
                newLeads.add(l);
            }
        }
        
        if(tuidSet.size() > 0){
            map<string, Territory_User__c> singleMap = new map<string, Territory_User__c>();
            map<string, Territory_User__c> multiMap = new map<string, Territory_User__c>();

            set<String> buList = new set<String>();
            set<Id> complexuidSet = new set<Id>();
            //User__c 
            for(Territory_User__c tu : [SELECT User__c, Territory_Number__c, Territory_Master__r.Territory_Name__c, 
                                        Territory_Master__r.Region_Name__c, Territory_Master__r.Region_Number__c 
                                        FROM Territory_User__c 
                                        WHERE User__c = :tuidSet])
            {
                if(singleMap.get(tu.User__c) == NULL){
                    singleMap.put(tu.User__c, tu);
                    system.debug('Adding User to Single Map: ' + tu);
                }
                else{
                    singleMap.remove(tu.User__c);
                    multiMap.put(tu.User__c, tu);
                    system.debug('Adding User to Multi Map: ' + tu);
                }
            }
            if(newLeads.size() > 0){
                for(Lead l : newLeads){
                    if(singleMap.get(l.OwnerId) != NULL){
                        lead ul = new lead(
                            Id = l.Id,
                            Owner_Territory_Number__c = singleMap.get(l.OwnerId).Territory_Number__c
                            //singleMap.get(l.OwnerId).Territory_Master__r.Territory_Name__c
                            //singleMap.get(l.OwnerId).Territory_Master__r.Region_Name__c
                            //singleMap.get(l.OwnerId).Territory_Master__r.Region_Number__c
                        );
                        updateLeads.add(ul);
                    }
                    else{
                        complexLeads.add(l);
                        complexuidSet.add(l.OwnerId);
                        buList.add(l.Business_Unit__c);
                    }
                }
                if(updateLeads.size() > 0){ update updateLeads; } 
            }
            if(complexLeads.size() > 0){
                
                // This is going to get crazy...
                // 
                list<Lead> finalLeads = new list<Lead>();
                updateLeads.clear();
                
                set<String> regionFilterKey = new set<String>();
                set<String> zipFilterKey = new set<String>();
                
                boolean stage2 = FALSE; // Used to validate that there are any records to process.
                
                // First thing we have to do is create the keys.
                for(lead l : complexLeads){
                    
                    if(l.State != NULL){
                        regionFilterKey.add(l.State + '-A659');
                        regionFilterKey.add(l.State + '-A688');
                        regionFilterKey.add(l.State + '-A689');
                        system.debug('regionFilterKey: ' + regionFilterKey);
                        stage2 = TRUE;
                    }
                    if(l.PostalCode != NULL){
                        zipFilterKey.add(l.PostalCode + '-A626');
                        zipFilterKey.add(l.PostalCode.left(3) + '-A675');
                        zipFilterKey.add(l.PostalCode.left(5) + '-A667');
                        zipFilterKey.add(l.PostalCode.left(5) + '-A668');
                        // Non-Standard Zip Code ZPSA Tables - These are the Zip+Customer Group Tables
                        zipFilterKey.add(l.PostalCode.left(3) + '-A672');
                        zipFilterKey.add(l.PostalCode.left(3) + '-A671');
                        zipFilterKey.add(l.PostalCode.left(5) + '-A663');
                        zipFilterKey.add(l.PostalCode.left(5) + '-A664');
                        system.debug('zipFilterKey: ' + zipFilterKey);
                        stage2 = TRUE;
                    }
                    if(stage2){
                        finalLeads.add(l);
                    }
                }
                system.debug('buList: ' + buList);
                
                if(stage2){
                    system.debug('-- Starting Stage2 of User Assign --');
                    map<string,Id> tuMap = new map<string,Id>();
                    for(Territory_User__c tm : [Select User__c, Territory_Number__c 
                                                FROM Territory_User__c 
                                                WHERE User__c  = :complexuidSet
                                                AND User_Active__c = TRUE 
                                                ORDER BY Territory_Number__c])
                    {
                        tuMap.put(tm.Territory_Number__c, tm.User__c);
                    }
                    system.debug('tuMap: ' + tuMap);
                    
                    map<string,string> stateMap = new map<string,string>();
                    map<string,string> zipMap = new map<string,string>();
                    // Match State/Region
                    if(regionFilterKey.size() > 0){
                        for(Territory_Alignment__c ta : [SELECT Territory__c, Region__c  
                                                         FROM Territory_Alignment__c 
                                                         WHERE Filter_Key__c IN :regionFilterKey 
                                                         AND Business_Unit__c IN :buList 
                                                         AND Expired__c = FALSE])
                        {
                            stateMap.put(ta.Region__c, ta.Territory__c);
                            system.debug('Add State: ' + stateMap);
                        }
                    } 
                    
                    // Match Zipcode
                    if(zipFilterKey.size() > 0){
                        for(Territory_Alignment__c ta : [SELECT Territory__c, Zipcode__c  
                                                         FROM Territory_Alignment__c 
                                                         WHERE Alt_Filter_Key__c IN :zipFilterKey 
                                                         AND Business_Unit__c IN :buList 
                                                         AND Expired__c = FALSE])
                        {
                            zipMap.put(ta.Zipcode__c, ta.Territory__c);
                            system.debug('Add Zip: ' + zipMap);
                        }
                    }
                    
                    string tnumber;
                    string tuserid;
                    for(lead l : finalLeads){
                        if(l.PostalCode != NULL){
                            
                            if(zipMap.get(l.PostalCode.left(3)) != NULL){
                                tnumber = zipMap.get(l.PostalCode.left(3));
                            }
                            else if(zipMap.get(l.PostalCode.left(5)) != NULL){
                                tnumber = zipMap.get(l.PostalCode.left(5));
                            }
                            else if(zipMap.get(l.PostalCode) != NULL){
                                tnumber = zipMap.get(l.PostalCode);
                            }
                            
                            if(tuMap.get(tnumber) != NULL){
                                tuserid = tuMap.get(tnumber); 
                                system.debug('Adding Zip User Id - Approval: ' + tuserid);
                            }
                        }
                        if(l.State != NULL && tuserid == NULL){
                            if(stateMap.get(l.State) != NULL){
                                //system.debug('State Map Lookup: ' + stateMap.get(l.State));
                                tnumber = stateMap.get(l.State);
                            }
                            
                            system.debug('State User Id: ' + tuMap.get(tnumber));
                            if(tuMap.get(tnumber) != NULL){
                                tuserid = tuMap.get(tnumber); 
                                system.debug('Adding State User Id - Approval: ' + tuserid);
                            }
                        }
                        
                        // Here is were the magic happens - If we have a Territory User ID set we are
                        // going to write it to the 'Territory Based Owner' field by default and if
                        // either the 'Do Not Assign Lead using Territory rules' is checked FALSE or
                        // the 'Assign Using Territories' checkbox are TRUE 
                        if(tuserid != NULL && tuserid == l.OwnerId){
                            system.debug('Winner!');
                            lead ul = new lead(
                                Id = l.Id,
                                Owner_Territory_Number__c = tnumber
                                //singleMap.get(l.OwnerId).Territory_Master__r.Territory_Name__c
                                //singleMap.get(l.OwnerId).Territory_Master__r.Region_Name__c
                                //singleMap.get(l.OwnerId).Territory_Master__r.Region_Number__c
                            );
                            updateLeads.add(ul);
                        }
                        
                    } // End Final Loop
                    
                    if(updateLeads.size() > 0){ update updateLeads; } 
                    
                } // End stage2 IF/Then
                //END END
                
            }
        }
        system.debug('-- Ending setTerritoryNumber --');
    }
*/
    public static void setTerritoryNumberOpp(List<Opportunity> newTrigger, Map<Id,Opportunity> oldTrigger,String type){
        
        if(master_TriggerHelperClass.qd('setTerritoryNumberOpp')){
            set<Id> oid = new set<Id>();
            list<Opportunity> simpleOpp = new list<Opportunity>();
            for(Opportunity o : newTrigger){
                if(type == 'insert'){
                    oid.add(o.OwnerId);
                    simpleOpp.add(o);                    
                }
                else if(oldTrigger.get(o.Id).OwnerId != o.OwnerId || o.Owner_Territory_Number__c == NULL){
                    oid.add(o.OwnerId);
                    simpleOpp.add(o);
                }
            }
            if(simpleOpp.size() > 0){
                map<string, Territory_User__c> singleMap = new map<string, Territory_User__c>();
                
                set<Id> acctIdSet = new set<Id>();
                
                list<Opportunity> updateOpps = new list<Opportunity>(); // Update List
                
                for(Territory_User__c tu : [SELECT User__c, Territory_Number__c, Territory_Master__r.Territory_Name__c, 
                                            Territory_Master__r.Region_Name__c, Territory_Master__r.Region_Number__c 
                                            FROM Territory_User__c 
                                            WHERE User__c = :oid 
                                            AND Primary__c = TRUE])
                {
                    singleMap.put(tu.User__c, tu);
                }

                string rnum;
                string tnum;                
                for(Opportunity o : simpleOpp){
                    if(singleMap.get(o.OwnerId) != NULL){
                        rnum = '';
                        tnum = '';
                        if(singleMap.get(O.OwnerId).Territory_Master__r.Region_Number__c != NULL){
                            rnum = singleMap.get(o.OwnerId).Territory_Master__r.Region_Number__c;
                            rnum = rnum.left(6);
                        }
                        else{
                            rnum = '';
                        }
                        if(singleMap.get(o.OwnerId).Territory_Number__c != NULL){
                            tnum = singleMap.get(o.OwnerId).Territory_Number__c;
                            tnum = tnum.left(6);
                        }
                        else{
                            tnum = '';
                        }
                        
                        Opportunity uOpp = new Opportunity(
                            Id = o.Id,
                            Owner_Territory_Number__c = tnum,
                            Owner_Territory_Name__c = singleMap.get(o.OwnerId).Territory_Master__r.Territory_Name__c,
                            Owner_Region_Number__c  = rnum,
                            Owner_Region_Name__c  = singleMap.get(o.OwnerId).Territory_Master__r.Region_Name__c
                        );
                        updateOpps.add(uOpp);
                        system.debug('Match: ' + o.Name);
                    }
                    else{
                        if(o.Owner_Territory_Number__c != NULL){
                            Opportunity uOpp = new Opportunity(
                                Id = o.Id,
                                Owner_Territory_Number__c = '',
                                Owner_Territory_Name__c = '',
                                Owner_Region_Number__c = '',
                                Owner_Region_Name__c = ''
                            );
                            updateOpps.add(uOpp);
                            system.debug('Removing Owner Territory Number: ' + o.Name);
                        }
                    }
                }
                if(updateOpps.size() > 0)
                { 
                    //update updateOpps;
                    if(updateOpps.size() == 1 && newTrigger.size() == 1){
                        try{
                            update updateOpps;
                        }catch(DmlException e){
                            newTrigger[0].adderror(e.getDmlMessage(0));  // This will display validation rule error message    
                        }
                    }
                    else{
                        update updateOpps;
                    }
                } 
          
                
            }
        }
        
    }
}