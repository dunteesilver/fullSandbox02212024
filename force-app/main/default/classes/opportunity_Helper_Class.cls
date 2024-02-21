public class opportunity_Helper_Class {
    
    public static void stageStats(List<Opportunity> newTrigger){
        map<Id, list<OpportunityHistory>> ohMap = new map<Id, list<OpportunityHistory>>();
        map<Id, Integer> closeCountMap = new map<Id, Integer>();
        set<Decimal> stageCount = new set<Decimal>();
        boolean stageSkip;
        Decimal probCompare;
        
        for(OpportunityHistory oh : [SELECT Id, CreatedDate, OpportunityId, 
                                     Probability, StageName 
                                     FROM OpportunityHistory 
                                     WHERE OpportunityId = :newTrigger 
                                     AND Probability != 0 
                                     AND Probability != 100
                                     ORDER BY CreatedDate ASC])
        {
            if(ohMap.containsKey(oh.OpportunityId)){
                ohMap.get(oh.OpportunityId).add(oh);
            }
            else{
                ohMap.put(oh.OpportunityId, new list<OpportunityHistory>{oh});
            }
        }
        //
        for(AggregateResult ar : [SELECT OpportunityId oid, COUNT_DISTINCT(CloseDate) CloseCount 
                                     FROM OpportunityHistory 
                                     WHERE OpportunityId = :newTrigger 
                                     GROUP BY OpportunityId])
        {
            if((Integer) ar.get('CloseCount') > 0){
                closeCountMap.put((Id) ar.get('oid'), (Integer) ar.get('CloseCount'));
            }
            //(Id) ar.get('oid');
            ////(Date) ar.get('CloseCount');
        }
        
        for(Opportunity o : newTrigger){
            if(closeCountMap.containsKey(o.Id)){
                o.Close_Date_Count__c = closeCountMap.get(o.Id);
            }
            if(ohMap.containsKey(o.Id)){
                stageCount.clear();
                probCompare = NULL;
                for(OpportunityHistory oh : ohMap.get(o.Id)){
                    stageSkip = TRUE;
                    /*if(probCompare == NULL || probCompare != oh.Probability){
                        probCompare = oh.Probability;
                        
                    }*/
                    if(o.Territory_Business_Unit__c == 'Vascular' && oh.Probability == 10){
                        stageSkip = FALSE;
                    }
                    if(stageSkip){
                        if(o.First_Stage__c == NULL){
                            o.First_Stage__c = oh.StageName;
                            o.First_Stage_Date_Time__c = oh.CreatedDate;
                        }
                    }
                    if(o.Last_Stage__c != oh.StageName){
                        o.Last_Stage__c = oh.StageName;
                        o.Last_Stage_Date_Time__c = oh.CreatedDate;
                    }
                    stageCount.add(oh.Probability);
                    o.Opportunity_Last_Update_Date_Time__c = oh.CreatedDate; 
                } // Stage Loop
            } // Map Check
            o.Stage_Count__c = stageCount.size();
        } // Opportunity Loop
    }
    
    public static void createImpact(List<Opportunity> newTrigger){
        map<String, Boolean> simMap = new map<String, Boolean>();
        list<Sales_Impact__c> siList = new list<Sales_Impact__c>();
        for(Sales_Impact__c sim : [SELECT Opportunity__c, Key__c   
                                   FROM Sales_Impact__c 
                                   WHERE Opportunity__c = :newTrigger])
        {
            simMap.put(sim.Key__c, TRUE);
        }
        for(Opportunity o : newTrigger){
            for(Integer i = 1; i < 13; i++){
                if(!simMap.containsKey(i + '-' + o.Id)){
                    Sales_Impact__c newSI = new Sales_Impact__c(
                        Key__c = i + '-' + o.Id,
                        Month__c = i,
                        Opportunity__c = o.Id,
                        CurrencyIsoCode = o.CurrencyIsoCode
                    );
                    siList.add(newSI);
                } 
            }
        }
        if(siList.size() > 0){
            insert siList;
        }
        
        
    }
    
    public static void addTerritory(List<Opportunity> newTrigger){
        // Created to Support the new 'Leading Indicators 2018 Project'. - 24Jan2018 - ESC 
        // Test Class: territory_user_security_test
        
        set<Id> userIds = new set<Id>();
        set<String> tNumSet = new set<String>();
        list<Opportunity> updateOpps = new list<Opportunity>();
        
        for(Opportunity o : newTrigger){
            if(o.Territory__c == NULL || o.Territory_Update__c){
                userIds.add(o.OwnerId);
                updateOpps.add(o);
                system.debug('OwnerId: ' + o.OwnerId);
                if(o.Territory_Update__c){
                    o.Territory_Update__c = FALSE;
                }
                system.debug('Owner TerritorY Number: ' + o.Owner_Territory_Number__c);
                if(o.Owner_Territory_Number__c != NULL){
                    tNumSet.add(o.Owner_Territory_Number__c);
                }
            }
        }
        if(updateOpps.size() > 0){
            system.debug('Stage Two');
            map<Id, Id> tMap = new map<Id, Id>();
            map<String, Id> tNumMap = new map<String, Id>();
            for(Territory_Master__c tm : [SELECT Id, Sales_Rep__c, Primary_Territory_User__c, 
                                          Primary_Sales_Rep_Flip__c, Territory_Number__c  
                                          FROM Territory_Master__c 
                                          WHERE (Sales_Rep__c = :userIds OR Primary_Territory_User__c = :userIds)])
            {
                system.debug('Territory! - ' + tm.Territory_Number__c );
                system.debug('Flip! - ' + tm.Primary_Sales_Rep_Flip__c );
                system.debug('Primary_Territory_User__c! - ' + tm.Primary_Territory_User__c );
                system.debug('Sales_Rep__c! - ' + tm.Sales_Rep__c );
                if(tm.Primary_Sales_Rep_Flip__c && tm.Primary_Territory_User__c != NULL){
                    tMap.put(tm.Primary_Territory_User__c, tm.Id);
                }
                else if(tm.Sales_Rep__c != NULL){
                    tMap.put(tm.Sales_Rep__c, tm.Id);
                }
                else if(tm.Primary_Territory_User__c != NULL){
                    tMap.put(tm.Primary_Territory_User__c, tm.Id);
                }

            }
            
            for(Territory_Master__c tm : [SELECT Id, Territory_Number__c  
                                          FROM Territory_Master__c 
                                          WHERE Territory_Number__c = :tNumSet])
            {
                tNumMap.put(tm.Territory_Number__c, tm.Id);
            }
            system.debug('tNumMap: ' + tNumMap);

            system.debug('tMap: ' + tMap);
            for(Opportunity o : updateOpps){
                if(tMap.containsKey(o.OwnerId)){
                    o.Territory__c = tMap.get(o.OwnerId);                
                }
                else if(o.Owner_Territory_Number__c != NULL && tNumMap.containsKey(o.Owner_Territory_Number__c)){
                    //system.debug('tNum: ' + tNumMap.get(o.Owner_Territory_Number__c));
                    o.Territory__c = tNumMap.get(o.Owner_Territory_Number__c);
                }
            }
        }
    }
    
    public static void setProductOfInterest(List<Opportunity> newTrigger, Map<Id,Opportunity> oldTrigger,String type){
        // Added Support for Global Picklist - ESC 06Jun2017
        list<Opportunity> updateOpps = new list<Opportunity>();
        string poiList;
        string poi;
        boolean upd;
        
        for(Opportunity o : newTrigger){
            
            if(o.CloseDate < o.CreatedDate.date() && o.CloseDate.month() != o.CreatedDate.month()){
                if(master_TriggerHelperClass.qd('Opp_CloseDate_CreatedDate_Rule')){
                    o.addError('Your close date must be after the date your opportunity was created!');
                }
            }//end if closedate check
            else{
                system.debug('CloseDate is Greater or Equal to CreatedDate');
                upd = FALSE;
                if(type == 'insert' && (o.Product_of_Interest__c != NULL || o.Product_of_Interest_GPL__c != NULL)){
                    upd = TRUE;
                }
                // Check to see if the automation has never run or the values have changed.
                else if( 
                    type == 'update' &&
                    o.Product_of_Interest_GPL__c != NULL &&
                    (oldTrigger.get(o.Id).Product_of_Interest_GPL__c != o.Product_of_Interest_GPL__c
                     || o.Product_of_Interest_Sort__c == NULL))
                {
                    upd = TRUE;
                    system.debug('Lets update!');
                }
                else if(
                    type == 'update' &&
                    o.Product_of_Interest__c != NULL &&
                    (oldTrigger.get(o.Id).Product_of_Interest__c != o.Product_of_Interest__c
                     || o.Product_of_Interest_Sort__c == NULL))
                {
                    upd = TRUE;
                    system.debug('Lets update!');
                }
                if(upd){
                    // Prioritize the New Field over the old
                    if(o.Product_of_Interest_GPL__c != NULL){
                        Opportunity uOpp = new Opportunity(
                            Id = o.Id,
                            Product_of_Interest_Sort__c = o.Product_of_Interest_GPL__c
                        );
                        updateOpps.add(uOpp);
                    }
                    else{
                        // Let's Alphabitize
                        poiList = o.Product_of_Interest__c;
                        List<String> sortedvalue = poiList.split(';');
                        sortedvalue.sort();
                        
                        poi = '';
                        for(string s : sortedvalue){
                            if(poi == ''){
                                poi = s;
                            }
                            else{
                                poi = poi + ', ' + s;
                            }
                        }
                        // Make sure it will fit...
                        poi = poi.left(255);
                        
                        // DML
                        Opportunity uOpp = new Opportunity(
                            Id = o.Id,
                            Product_of_Interest_Sort__c = poi
                        );
                        updateOpps.add(uOpp);
                    }
                    
                }//end of if(upd)
                
                if(updateOpps.size() > 0){
                    system.debug('Updating Product of Interest Sort!');
                    
                    try {
                        update updateOpps;
                    }
                    catch (Exception e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
                    
                }//end of if updateOpps.size
            }
            
            
        }//end of for loop
        
        
    }//end of method setProductOfInterest
    
    public static void setNewProductTracking(List<Opportunity> newTrigger, Map<Id,Opportunity> oldTrigger,String type){
        // Test Class: PP_Global_Test_Class
        list<String> poiList = new list<String>();
        list<Opportunity> updateList = new list<Opportunity>();

        set<Opportunity> oppSet = new set<Opportunity>();
        set<String> nptFilter = new set<String>();
        set<Id> skipSet = new set<Id>();
        set<Id> addSet = new set<Id>();

        map<Id, String> oppMap = new map<Id, String>();
        map<String, New_Product_Tracking_Rule__c> nptMap = new map<String, New_Product_Tracking_Rule__c>();

        string poiSting;
        string bu;
        string upperStr;
        string nptKey;
        
        for(Opportunity o : newTrigger){
            system.debug('o.New_Product_Tracking__c: ' + o.New_Product_Tracking__c + ' - Type: ' + type);
            poiList.clear();
            poiSting = NULL;
            if(o.Product_of_Interest_GPL__c != NULL){
                poiSting = o.Product_of_Interest_GPL__c;
            }
            else if(o.Product_Family_LatAm__c != NULL){
                poiSting = o.Product_of_Interest_LatAm__c;
            }
            else if(o.Product_of_Interest__c != NULL){
                poiSting = o.Product_of_Interest__c;
            }
            if(poiSting != NULL && o.Business_Unit_GPL__c  != NULL){ // Check to make sure Product of Interest and BU have values
                // Disabling for Now
                /*if(
                    type == 'insert' // Always fires for new records
                   || (type == 'update' && o.New_Product_Tracking__c == NULL) // Fires if it's an update without a related New Product Tracking Record
                   || (type == 'update' && oldTrigger.get(o.Id).Product_of_Interest_Reporting__c != o.Product_of_Interest_Reporting__c) // Fires if Product of Interest Changes
                   || (type == 'update' && oldTrigger.get(o.Id).Business_Unit_GPL__c  != o.Business_Unit_GPL__c ) // Fires if the BU Changes
                  ){*/
                      system.debug('First Loop!');
                      bu = o.Business_Unit_GPL__c ;
                      if(bu.left(8) == 'Surgical'){ // Hack for the Surgical BU names
                          bu = 'Surgical';
                      }
                      bu = bu.toUpperCase();

                      poiSting = o.Product_of_Interest_Reporting__c;
                      if(poiSting.contains(';')){ // If multi-select break out the string in to a list
                          poiList = poiSting.split(';');
                      }
                      else{ // Else add the single value to the list
                          poiList.add(poiSting);                          
                      }

                      for(string s : poiList){
                          nptKey = s;
                          nptKey = bu + '-' + nptKey;
                          nptKey = nptKey.toUpperCase();
                          nptKey = nptKey.trim();
                          nptFilter.add(nptKey);
                          oppSet.add(o);
                      }
                  //}
            }
        }
        system.debug('nptFilter: ' + nptFilter);
        system.debug('oppSet: ' + oppSet);
        // Round 1 - Matches
        // Takes the first matching rule and adds it to the Lead. Also removes the lead from the map and adds
        // the id to a set so that the matching value gets written.
        if(nptFilter.size() > 0){
            for(New_Product_Tracking_Rule__c r : [SELECT Id, New_Product_Tracking__c, Key__c 
                                                  FROM New_Product_Tracking_Rule__c 
                                                  WHERE Key__c =:nptFilter 
                                                  AND New_Product_Tracking__r.Active__c = TRUE 
                                                  AND Active__c = TRUE 
                                                  AND IsProductOfInterest__c = TRUE])
            {
                nptKey = r.Key__c; 
                nptKey = nptKey.toUpperCase();
                system.debug('nptKey: ' + nptKey);
                nptMap.put(nptKey, r);
            }
        }
        system.debug('nptMap: ' + nptMap);
        // Round 2 - Clean Up
        // If there's anything left in the map then the New Product Tracking field needs to be set to NULL so that
        // the current value is removed as there was no matching rule found for the new BU and Product Family Combo

        for(Opportunity o : oppSet){
            bu = o.Business_Unit_GPL__c;
            if(bu.left(8) == 'Surgical'){ // Hack for the Surgical BU names
                bu = 'Surgical';
            }
            bu = bu.toUpperCase();
            
            poiSting = NULL;
            poiList.clear();
            if(o.Product_of_Interest_GPL__c != NULL){
                poiSting = o.Product_of_Interest_GPL__c;
            }
            else if(o.Product_Family_LatAm__c != NULL){
                poiSting = o.Product_of_Interest_LatAm__c;
            }
            else if(o.Product_of_Interest__c != NULL){
                poiSting = o.Product_of_Interest__c;
            }
            if(poiSting.contains(';')){ // If multi-select break out the string in to a list
                poiList = poiSting.split(';');
            }
            else{ // Else add the single value to the list
                poiList.add(poiSting);                          
            }
            
            
            for(string s : poiList){
                nptKey = s;
                nptKey = bu + '-' + nptKey;
                nptKey = nptKey.toUpperCase();
                
                if(nptMap.containsKey(nptKey) && !addSet.contains(o.Id)){
                    Opportunity newOpp = new Opportunity(
                        Id = o.Id,
                        New_Product_Tracking__c = nptMap.get(nptKey).New_Product_Tracking__c,
                        New_Product_Tracking_Rule__c = nptMap.get(nptKey).Id
                    );
                    updateList.add(newOpp);
                    
                    // This is a method to check whether to remove NPT from an opp due to data or rule changes.
                    // Because of multi-select we have to do a little more work.
                    addSet.add(o.Id); 
                    if(skipSet.contains(o.Id)){ 
                        skipSet.remove(o.Id);
                        system.debug('Removing: ' + o.Id);
                    }
                }
                
                else{
                    // Add to the remove set if the Opportunity is not already in the 'Add' Set and NPT is set
                    if(!addSet.contains(o.Id) && o.New_Product_Tracking__c != NULL){
                        skipSet.add(o.Id);
                        system.debug('Adding: ' + o.Id);
                    }
                }
            }

        }
        
        for(Id o : skipSet){
            if(!addSet.contains(o)){
                Opportunity newOpp = new Opportunity(
                    Id = o,
                    New_Product_Tracking__c = NULL,
                    New_Product_Tracking_Rule__c = NULL
                );
                system.debug('Removing! ' + newOpp);
                updateList.add(newOpp);
            }
        }

        // Write the records!
        if(updateList.size() > 0){
            update updateList;
        }
    }
    
    //Opportunity creation, create a new Opportunity contact role
    public static void createOppConRole(List<Opportunity> newTrigger){
        List<OpportunityContactRole> addConRole = new List<OpportunityContactRole>();
        for(Opportunity curr : newTrigger){
            if(curr.Primary_Contact__c != NULL){
                OpportunityContactRole ocr = new OpportunityContactRole();
                ocr.OpportunityId = curr.Id;
                if(curr.Primary_Contact_Id__c != NULL){
                    ocr.ContactId = curr.Primary_Contact_Id__c;
                }
                else{
                    ocr.ContactId = curr.Primary_Contact__c;    
                }
                
                ocr.Role = 'Decision Maker';
                addConRole.add(ocr);
            }
            
        }//end for loop
        
        if(addConRole.size()>0){
            //insert ocr;
            insert addConRole;
        }
    }
    
    //Opportunity updation, create a Opportunity contact role
    public static void updateOppConRole(List<Opportunity> newTrigger, Map<Id,Opportunity> oldTrigger){
        List<OpportunityContactRole> addConRole = new List<OpportunityContactRole>();
        map<id,boolean> ocrCheck = new map<id,boolean>();
        
        for(OpportunityContactRole ocr : [SELECT ContactId 
                                          FROM OpportunityContactRole 
                                          WHERE OpportunityId =:newTrigger])
        {
            ocrCheck.put(ocr.ContactId, TRUE);
        }
        
        for(Opportunity o : newTrigger){
            if(oldTrigger.get(o.Id).Primary_Contact__c != o.Primary_Contact__c){
                if(ocrCheck.get(o.Primary_Contact__c) == NULL){
                    OpportunityContactRole ocr = new OpportunityContactRole();
                    ocr.OpportunityId = o.Id;
                    ocr.ContactId = o.Primary_Contact__c;
                    ocr.Role = 'Decision Maker';
                    //insert ocr;
                    addConRole.add(ocr);
                }
                if(addConRole.size()>0){
                    insert addConRole;
                }
            }
        }

    }
    
}//end of class