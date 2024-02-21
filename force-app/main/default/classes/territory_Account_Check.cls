public class territory_Account_Check {
    
    // Test Class: territory_Account_Shares_TEST
    // v2 14Jun2017 - ESC
    public map<String, Territory_Master__c> tlookup {get; set;} // Access to the related Territory Master fields
    public map<String, String> tSalesRepmap {get; set;}
    public map<String, Territory_Assignment__c> taamap {get; set;}
    public map<String, Boolean> tSales {get; set;} // Looks at the Territory Key on the Account to flag which Territories have sales on that account
    public list<String> tlist {get; set;}
    public list<String> tsort {get; set;}
    
    public territory_Account_Check(){
                
        //New Stuff
        tSales = new map<String, Boolean>();
        tSalesRepmap = new map<String, String>();
        tlist = new list<String>();
        tsort = new list<String>();
        taamap = new map<String, Territory_Assignment__c>();
        tlookup = new map<String, Territory_Master__c>();
        Id aid = ApexPages.currentPage().getParameters().get('id');
        
        // ZPSA Keys
        set<String> sapFilterKey = new set<String>();
        set<String> regionFilterKey = new set<String>();
        set<String> zipFilterKey = new set<String>();
        set<String> zipcusFilterKey = new set<String>();
        
        map<String, String> emptyTerritory = new map<String, String>();
        
        string bu;
        string trole;
        string recordKey;
        string poiList;
        string poi;
        string sapCode;
        string MSRname;
        
        // End New
        
        // Starting New v2 Territory Account Check Code - 15Jun2017
        
        for(Territory_Master__c tm : [Select Id, Territory_Number__c, Business_Unit__c, Role__c, User_Count__c,
                                      Territory_Name__c, Sales_Rep__c, Sales_Rep__r.Name, Primary_Territory_User__r.Name, Territory_Name_2__c   
                                      FROM Territory_Master__c 
                                      ORDER BY Business_Unit__c, Role__c DESC])
        {
            tlookup.put(tm.Territory_Number__c, tm);
            if(tm.Sales_Rep__c != NULL){
                MSRname = tm.Sales_Rep__r.Name;
            }
            else if(tm.Primary_Territory_User__c != NULL){
                MSRname = tm.Primary_Territory_User__r.Name;
            }
            else if(tm.Territory_Name_2__c != NULL){
                MSRname = tm.Territory_Name_2__c;
            }            
            else{
                MSRname = 'Blank';
            }
            tSalesRepmap.put(tm.Territory_Number__c, MSRname);
        }
        
        // This Loops through the Accounts to create the keys used to query the ZPSA Rules
        for(Account a : [SELECT Id, SAP_Sold_to__c, BillingState, BillingPostalCode, 
                         Customer_Group__c, Territory_Key__c  
                         FROM Account 
                         WHERE Id =:ApexPages.currentPage().getParameters().get('id') LIMIT 1])
        {
            // Let's Alphabitize
            if(a.Territory_Key__c != NULL){
                poiList = a.Territory_Key__c;
                List<String> sortedvalue = poiList.split(';');
                sortedvalue.sort();
                for(string s : sortedvalue){
                    tSales.put(s, TRUE);
                } 
            }
            
            
            sapCode = a.SAP_Sold_to__c; // Used below;
            
            if(a.SAP_Sold_to__c != NULL){
                //SAPmap.put(a.SAP_Sold_to__c, a.Id);
                
                // ZPSA Query Keys
                sapFilterKey.add(a.SAP_Sold_to__c + '-A681');
                sapFilterKey.add(a.SAP_Sold_to__c + '-A680');
                sapFilterKey.add(a.SAP_Sold_to__c + '-A654');
                sapFilterKey.add(a.SAP_Sold_to__c + '-A679');
                //system.debug('sapFilterKey: ' + sapFilterKey);
            }
            if(a.BillingState != NULL){

                // ZPSA Query Keys
                regionFilterKey.add(a.BillingState + '-A659');
                regionFilterKey.add(a.BillingState + '-A688');
                regionFilterKey.add(a.BillingState + '-A689');
                //system.debug('regionFilterKey: ' + regionFilterKey);
            }
            if(a.BillingPostalCode != NULL){

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
        }
        
        // Check to see what rules already exist
        for( Territory_Assignment__c taa : [SELECT Id, Territory_Number__c, Matching_Logic__c, ZPSA_Table__c, Territory_Alignment__r.id,
                                            Territory__r.Business_Unit__c, Territory__r.Role__c
                                            FROM Territory_Assignment__c 
                                            WHERE Account__c =:ApexPages.currentPage().getParameters().get('id')])
        {
            taamap.put(taa.Territory_Number__c, taa);
        }
        
        // Time to build out the ZPSA! - SAP - ZIP/CG - ZIP - State/Region
        
        // Match SAP Code (Level 1)
        if(sapFilterKey.size() > 0){
            for(Territory_Alignment__c ta : [SELECT SAP_Code__c, Territory__c, Territory_Name__c, ZPSA_Table__c, 
                                             Territory2__c, Territory3__c, Territory4__c, Matching_Logic__c 
                                             FROM Territory_Alignment__c 
                                             WHERE Filter_Key__c IN :sapFilterKey 
                                             AND Active__c = TRUE])
            {
                // Determine if there are additional Territories other than the primary and iterate through those
                set<String> tlist = new set<String>();
                tlist.add(ta.Territory__c);
                if(ta.Territory2__c != NULL) tlist.add(ta.Territory2__c); 
                if(ta.Territory3__c != NULL) tlist.add(ta.Territory3__c);
                if(ta.Territory4__c != NULL) tlist.add(ta.Territory4__c);
                
                // Cycle through the accounts to create territory assignment matches
                for(String ts : tlist){
                    if(tlookup.containsKey(ts)){ // Make sure the Territory Exists - Could have ZPSA rules that look at territory records that don't exist
                        if(taamap.containsKey(ts)){
                            //skip! - Need Boolean here
                        }
                        else{
                            if(emptyTerritory.containskey(ts)){
                                // Empty!
                            }
                            else{
                                Territory_Assignment__c newTA = new Territory_Assignment__c(
                                    Name = ta.SAP_Code__c + '-' + ts + ' ' + ta.Territory_Name__c, 
                                    Territory_Alignment__c = ta.Id,
                                    Territory__c = tlookup.get(ts).Id,
                                    Territory_Number__c = ts,
                                    Account__c = aid,
                                    ZPSA_Table__c = ta.ZPSA_Table__c,
                                    Matching_Logic__c = 'SAP Code',
                                    Assignment_Reason__c = 'The SAP Code on this named account was matched to a territory in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                                );
                                system.debug('Adding (New Record - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                taamap.put(ts, newTA);    
                            }
                        }
                    }
                    else{
                        system.debug('No Territory Master for: ' + ts);
                    }
                }
            }
        }

        // Match Zipcode + Customer Group (Level 2)        
        if(zipcusFilterKey.size() > 0){
            for(Territory_Alignment__c ta : [SELECT Id, Customer_Group__c, Zipcode__c, Territory__c, Territory_Name__c, 
                                             ZPSA_Table__c, Territory2__c, Territory3__c, Territory4__c, Matching_Logic__c 
                                             FROM Territory_Alignment__c 
                                             WHERE Filter_Key__c IN :zipcusFilterKey 
                                             AND Active__c = TRUE])
            {                
                // Determine if there are additional Territories other than the primary and iterate through those
                set<String> tlist = new set<String>();
                tlist.add(ta.Territory__c);
                if(ta.Territory2__c != NULL) tlist.add(ta.Territory2__c); 
                if(ta.Territory3__c != NULL) tlist.add(ta.Territory3__c);
                if(ta.Territory4__c != NULL) tlist.add(ta.Territory4__c);
                
                // Cycle through the accounts to create territory assignment matches
                for(String ts : tlist){
                    if(tlookup.containsKey(ts)){ // Make sure the Territory Exists - Could have ZPSA rules that look at territory records that don't exist
                        if(taamap.containsKey(ts)){
                            //skip! - Need Boolean here
                        }
                        else{
                            if(emptyTerritory.containskey(ts)){
                                // Empty!
                            }
                            else{
                                Territory_Assignment__c newTA = new Territory_Assignment__c(
                                    Name = sapCode + '-' + ta.Zipcode__c + '-' + ta.Customer_Group__c + '-' + ts + ' ' + ta.Territory_Name__c, 
                                    Territory_Alignment__c = ta.Id,
                                    Territory__c = tlookup.get(ts).Id,
                                    Territory_Number__c = ts,
                                    Account__c = aid,
                                    ZPSA_Table__c = ta.ZPSA_Table__c,
                                    Matching_Logic__c = 'Zip+Customer Group',
                                    Assignment_Reason__c = 'The Zip/Postage Code and Customer Group on this account was a match in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                                );
                                system.debug('Adding (New Record - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                taamap.put(ts, newTA);    
                            }
                        }
                    }
                    else{
                        system.debug('No Territory Master for: ' + ts);
                    }
                }
            }
        }
        
        // Match Zipcode (Level 3)        
        if(zipFilterKey.size() > 0){
            for(Territory_Alignment__c ta : [SELECT Id, Zipcode__c, Territory__c, Territory_Name__c, 
                                             ZPSA_Table__c, Territory2__c, Territory3__c, Territory4__c, Matching_Logic__c 
                                             FROM Territory_Alignment__c 
                                             WHERE Filter_Key__c IN :zipFilterKey 
                                             AND Active__c = TRUE])
            {                
                // Determine if there are additional Territories other than the primary and iterate through those
                set<String> tlist = new set<String>();
                tlist.add(ta.Territory__c);
                if(ta.Territory2__c != NULL) tlist.add(ta.Territory2__c); 
                if(ta.Territory3__c != NULL) tlist.add(ta.Territory3__c);
                if(ta.Territory4__c != NULL) tlist.add(ta.Territory4__c);
                
                // Cycle through the accounts to create territory assignment matches
                for(String ts : tlist){
                    if(tlookup.containsKey(ts)){ // Make sure the Territory Exists - Could have ZPSA rules that look at territory records that don't exist
                        if(taamap.containsKey(ts)){
                            //skip! - Need Boolean here
                        }
                        else{
                            if(emptyTerritory.containskey(ts)){
                                // Empty!
                            }
                            else{
                                Territory_Assignment__c newTA = new Territory_Assignment__c(
                                    Name = sapCode + '-' + ta.Zipcode__c + '-' + ts + ' ' + ta.Territory_Name__c, 
                                    Territory_Alignment__c = ta.Id,
                                    Territory__c = tlookup.get(ts).Id,
                                    Territory_Number__c = ts,
                                    Account__c = aid,
                                    ZPSA_Table__c = ta.ZPSA_Table__c,
                                    Matching_Logic__c = 'Zip/Postal Code',
                                    Assignment_Reason__c = 'The Zip/Postage Code on this account was a match in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                                );
                                system.debug('Adding (New Record - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                taamap.put(ts, newTA);    
                            }
                        }
                    }
                    else{
                        system.debug('No Territory Master for: ' + ts);
                    }
                }
            }
        }
        
        // Match State/Region (Level 4)        
        if(regionFilterKey.size() > 0){
            for(Territory_Alignment__c ta : [SELECT Region__c, Territory__c, Territory_Name__c, ZPSA_Table__c, 
                                             Territory2__c, Territory3__c, Territory4__c, Matching_Logic__c 
                                             FROM Territory_Alignment__c 
                                             WHERE Filter_Key__c IN :regionFilterKey 
                                             AND Active__c = TRUE])
            {            
                // Determine if there are additional Territories other than the primary and iterate through those
                set<String> tlist = new set<String>();
                tlist.add(ta.Territory__c);
                if(ta.Territory2__c != NULL) tlist.add(ta.Territory2__c); 
                if(ta.Territory3__c != NULL) tlist.add(ta.Territory3__c);
                if(ta.Territory4__c != NULL) tlist.add(ta.Territory4__c);
                
                // Cycle through the accounts to create territory assignment matches
                for(String ts : tlist){
                    if(tlookup.containsKey(ts)){ // Make sure the Territory Exists - Could have ZPSA rules that look at territory records that don't exist
                        if(taamap.containsKey(ts)){
                            //skip! - Need Boolean here
                        }
                        else{
                            if(emptyTerritory.containskey(ts)){
                                // Empty!
                            }
                            else{
                                Territory_Assignment__c newTA = new Territory_Assignment__c(
                                    Name = sapCode + '-' + ta.Region__c + '-' + ts + ' ' + ta.Territory_Name__c, 
                                    Territory_Alignment__c = ta.Id,
                                    Territory__c = tlookup.get(ts).Id,
                                    Territory_Number__c = ts,
                                    Account__c = aid,
                                    ZPSA_Table__c = ta.ZPSA_Table__c,
                                    Matching_Logic__c = 'Region/State and Territory Number',
                                    Assignment_Reason__c = 'The Region/State on this account was matched to a state and territory in the ' + ta.ZPSA_Table__c + ' ZPSA Table'
                                );
                                system.debug('Adding (New Record - ' + ta.Matching_Logic__c + '): ' + recordKey);
                                taamap.put(ts, newTA);    
                            }
                        }
                    }
                    else{
                        system.debug('No Territory Master for: ' + ts);
                    }
                }
            }
        }
        
        
        /*for(String s : taamap.keySet()){
            tlist.add(s);
            if(!tSales.containsKey(s)){
                tSales.put(s, FALSE);
            }
        }*/
        //tlist.sort();
        //
        for(Territory_Master__c tm :[SELECT Territory_Number__c
                                     FROM Territory_Master__c 
                                     WHERE Territory_Number__c =:taamap.keySet()
                                     ORDER BY Business_Unit__c, Role__c DESC])
        {
            tsort.add(tm.Territory_Number__c);
            if(!tSales.containsKey(tm.Territory_Number__c)){
                tSales.put(tm.Territory_Number__c, FALSE);
            }
        }
        
    }

    public account getAccount(){
        return [SELECT Id, Name FROM Account Where Id =:ApexPages.currentPage().getParameters().get('id') LIMIT 1];
    }
}