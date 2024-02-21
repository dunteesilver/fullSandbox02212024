public class territory_master_maintenance {
    
    public static void changeOppOwner(list<Territory_Master__c> newTrigger){
        map<Id, Id> tMap = new map<Id, Id>();
        list<Opportunity> updateOpps = new list<Opportunity>();
        for(Territory_Master__c tm : newTrigger){
            if(tm.Update_Open_Opportunity_Owner__c){
                if(tm.Primary_Sales_Rep_Flip__c && tm.Primary_Territory_User__c != NULL){
                    tMap.put(tm.Id, tm.Primary_Territory_User__c);
                }
                else if(tm.Sales_Rep__c != NULL){
                    tMap.put(tm.Id, tm.Sales_Rep__c);
                }
                else if(tm.Primary_Territory_User__c != NULL){
                    tMap.put(tm.Id, tm.Primary_Territory_User__c);
                }
                tm.Update_Open_Opportunity_Owner__c = FALSE;
            }
        }
        if(tMap.size() > 0){
            for(Opportunity o : [SELECT Id, Territory__c, OwnerId 
                                 FROM Opportunity 
                                 WHERE Territory__c = :tMap.keySet()
                                 AND IsClosed = FALSE])
            {
                if(tMap.containsKey(o.Territory__c) && tMap.get(o.Territory__c) != o.OwnerId){
                    Opportunity newOpp = new Opportunity(
                        Id = o.Id,
                        OwnerId = tMap.get(o.Territory__c)
                    );
                    updateOpps.add(newOpp);
                }
            }
            if(updateOpps.size() > 0){
                Database.update(updateOpps,false) ;
            }
        }
    }
    
    public static void updateLookups(list<Territory_Master__c> newTrigger){
        // This class looks at the email fields populated from the Comp Tool ICM and looks up the related Sales User and Manager
        // So that there's only one Rep per territory/quota
        // Sales_Rep__c == Invoiced Sales Record Owner
        // ESC - 14Jan2017
        // Test Class: territory_user_security_test
        
        set<String> emailSet = new set<String>();
        map<String, Id> userMap = new map<String, Id>();
        // Parent Territory - 09Aug2017 - ESC
        set<String> tSet = new set<String>();
        map<String, Territory_Master__c> tMap = new map<String, Territory_Master__c>();
        list<Territory_Master__c> tList = new list<Territory_Master__c>();
        // END
        // Payee ID - 15Aug2017 - ESC
        // set<String> qtSet = new set<String>();
        // map<String, String> qpiMap = new map<String, String>();
        // END

        for(Territory_Master__c tm : newTrigger){
            // Check to see if the Parent Territory has been set - 09Aug2017 - ESC
            if(
                (
                    tm.Parent_Territory__c == NULL && 
                    tm.Region_Number__c != NULL && 
                    tm.Territory_Number__c != tm.Region_Number__c
                ) ||
                (
                    tm.Region_Number__c != NULL && 
                    tm.Region_Name__c == NULL
                )
            )
            {
                tSet.add(tm.Region_Number__c);
                tlist.add(tm);
            }
                // END
            
            if(tm.Sales_Rep_Email__c != NULL){
                emailSet.add(tm.Sales_Rep_Email__c);
            }
            else if(tm.Sales_Rep__c != NULL){
                tm.Sales_Rep__c = NULL;
            }
            if(tm.Manager_Email__c != NULL){
                emailSet.add(tm.Manager_Email__c);
            }
            else if(tm.Manager__c != NULL){
                tm.Manager__c = NULL;
            }
            if(tm.Primary_Territory_User_Email__c != NULL){
                emailSet.add(tm.Primary_Territory_User_Email__c);
            }
            else if(tm.Primary_Territory_User__c != NULL){
                tm.Primary_Territory_User__c = NULL;
            }
            
            // Doublecheck the Payee ID
            // qtSet.add(tm.Territory_Number__c);
        }
        // Check to see if the Parent Territory has been set - 09Aug2017 - ESC
        if(tSet.size() > 0){
            // Build out the Territory Number to Territory Map
            for(Territory_Master__c tm : [SELECT Id, Territory_Number__c, Territory_Name__c   
                                          FROM Territory_Master__c 
                                          WHERE Territory_Number__c = :tSet])
            {
                tMap.put(tm.Territory_Number__c, tm);
            }
            
            // Parse the list and add in the data
            for(Territory_Master__c tm : tList){
                if(tMap.containsKey(tm.Region_Number__c)){
                    if(tm.Parent_Territory__c == NULL && tm.Territory_Number__c != tm.Region_Number__c){
                        tm.Parent_Territory__c = tMap.get(tm.Region_Number__c).Id;
                    }
                    if(tm.Region_Name__c == NULL){
                        tm.Region_Name__c = tMap.get(tm.Region_Number__c).Territory_Name__c;
                    }
                }
            }
            
        }
        // END
        // Check to see if the Payee Id needs to be updated - 15Aug2017 - ESC
        /*
        for(Territory_Quota__c tq : [SELECT Payee_ID__c, Territory_Number__c  
                                     FROM Territory_Quota__c 
                                     WHERE Payee_ID__c != 'ALL'
                                     AND Payee_ID__c != 'UNASSIGNED'
                                     AND Date__c = THIS_MONTH 
                                     AND Compensation_Type__c = 'ALL'])
        {
            qpiMap.put(tq.Territory_Number__c, tq.Payee_ID__c);
        }
        */
        // END
        if(emailSet.size() > 0){

            for(user u : [SELECT Id, Email  
                          FROM User 
                          WHERE Email =:emailSet 
                          ORDER BY IsActive])
            {
                userMap.put(u.Email, u.Id);
            }
            for(Territory_Master__c tm : newTrigger){
                if(userMap.containsKey(tm.Sales_Rep_Email__c)){
                    if(tm.Sales_Rep__c == NULL || tm.Sales_Rep__c != userMap.get(tm.Sales_Rep_Email__c)){
                       tm.Sales_Rep__c = userMap.get(tm.Sales_Rep_Email__c);
                    }
                }
                else{
                    tm.Sales_Rep__c = NULL;
                }
                if(userMap.containsKey(tm.Manager_Email__c)){
                    if(tm.Manager__c == NULL || tm.Manager__c != userMap.get(tm.Manager_Email__c)){
                        tm.Manager__c = userMap.get(tm.Manager_Email__c);
                    }
                }
                else{
                    tm.Manager__c = NULL;
                }
                // Not Needed - was dev code that didn't get used. - ESC 05Mar2017
                
                if(userMap.containsKey(tm.Primary_Territory_User_Email__c)){
                    if(tm.Primary_Territory_User__c != userMap.get(tm.Primary_Territory_User_Email__c)){
                        tm.Primary_Territory_User__c = userMap.get(tm.Primary_Territory_User_Email__c);
                    }
                }
                else{
                    tm.Primary_Territory_User__c = NULL;
                }
                
                // Check to see if the Payee Id needs to be updated - 15Aug2017 - ESC
                /*
                if(qpiMap.containsKey(tm.Territory_Number__c)){
                    tm.Payee_Id__c = qpiMap.get(tm.Territory_Number__c);
                    tm.Payee_Id_Last_Updated__c = datetime.now();
                }*/

            }
        }
    }
    
    public static void emptyQuotas(list<Territory_Master__c> newTrigger){
        // As part of VSI integration we needed a way to quickly generate zero dollar territory quota files and then remove them.
        // ESC - 22Apr2017
        // Test Class: territory_user_security_test
        set<Id> tid = new set<Id>();
        list<Territory_Quota__c> tqList = new list<Territory_Quota__c>();
        Date startDate = Date.newInstance(System.Today().year(), 1, 1);
        string payeeId;

        // New Stuff 30Aug2017
        list<Territory_Master__c> tmList = new list<Territory_Master__c>();
        //map<String, list<String>> compTypeMap = new map<String, list<String>>();
        string compType;
        //string compProfile;

        for(Territory_Master__c tm : newTrigger)
        {
            if(tm.Remove_Empty_Quotas__c){
                tid.add(tm.Id);
                tm.Remove_Empty_Quotas__c = FALSE;
            }
            else if(tm.Build_Empty_Quotas__c && tm.Territory_Number__c != NULL && tm.Compensation_Profile__c != NULL){
                tmList.add(tm);
            }
        }
        system.debug('tmList: ' + tmList);
        
        if(tmList.size() > 0){
            
            /* -- Not Needed, going to use a field instead of guessing --
            // Prep the Map
            for(AggregateResult ar : [SELECT Compensation_Type_Query__c, Territory_Master__r.Compensation_Profile__c 
                                      FROM Territory_Quota__c 
                                      WHERE Territory_Master__c = :tmList 
                                      AND Date__c = THIS_YEAR 
                                      AND Compensation_Type__c != 'ALL' 
                                      Group By Territory_Master__r.Compensation_Profile__c, Compensation_Type_Query__c])
            {

                compProfile = (String) ar.get('Territory_Master__r.Compensation_Profile__c');
                compType = (String) ar.get('Compensation_Type_Query__c');
                if(compTypeMap.containsKey(compProfile)) {
                    compTypeMap.get(compProfile).add(compType);
                } else {
                    compTypeMap.put(compProfile, new String[]{compType});
                }
            }
            system.debug('compTypeMap: ' + compTypeMap);*/
            
            // Do Work
            for(Territory_Master__c tm : tmList)
            {
                if(tm.Payee_Id__c == NULL){
                    tm.Payee_Id__c = tm.Territory_Number__c;
                }
                payeeId = tm.Payee_Id__c;
                
                compType = tm.Quota_Compensation_Type__c ;
                List<String> ctList = compType.split(',');

                Date myDate = startDate;
                for (Integer i = 0; i < 12; i++) {
                    // Key = Payee_ID-Territory Number-Comp Plan-Comp Type-Date
                    // 800158 Example: 705255-800158-SURD-USREP2-FOCUS-2017-01-01
                    // Territory Quota
                    for(String ct : ctList){
                        Territory_Quota__c newTQ = new Territory_Quota__c(
                            PAYEE_ID__C = 'ALL',
                            TERRITORY_NUMBER__C = tm.Territory_Number__c,
                            COMP_PLAN__C = 'Teleflex',
                            COMPENSATION_TYPE__C = ct,
                            DATE__C = myDate,
                            QUOTA__C = 0,
                            KEY__C = 'ALL-' + tm.Territory_Number__c + '-TELEFLEX-' + ct + '-' + myDate,
                            Empty_Quota__c = TRUE
                        );
                        tqList.add(newTQ);

                        // Individual Quota
                        newTQ = new Territory_Quota__c(
                            PAYEE_ID__C = payeeId,
                            TERRITORY_NUMBER__C = tm.Territory_Number__c,
                            COMP_PLAN__C = 'Teleflex',
                            COMPENSATION_TYPE__C = ct,
                            DATE__C = myDate,
                            QUOTA__C = 0,
                            KEY__C = payeeId + '-' + tm.Territory_Number__c + '-TELEFLEX-' + ct + '-' + myDate,
                            Empty_Quota__c = TRUE
                        );
                        //Key: 721427-800553-INTV-USREP1-ALL-2017-06-01
                        tqList.add(newTQ);
                    }
                    
                    // Create the Default Territory Quota's
                    Territory_Quota__c newTQ = new Territory_Quota__c(
                        PAYEE_ID__C = 'ALL',
                        TERRITORY_NUMBER__C = tm.Territory_Number__c,
                        COMP_PLAN__C = 'Teleflex',
                        COMPENSATION_TYPE__C = 'ALL',
                        DATE__C = myDate,
                        QUOTA__C = 0,
                        KEY__C = 'ALL-' + tm.Territory_Number__c + '-TELEFLEX-ALL-' + myDate,
                        Empty_Quota__c = TRUE
                    );
                    tqList.add(newTQ);
                    
                    // Individual Quota
                    newTQ = new Territory_Quota__c(
                        PAYEE_ID__C = payeeId,
                        TERRITORY_NUMBER__C = tm.Territory_Number__c,
                        COMP_PLAN__C = 'Teleflex',
                        COMPENSATION_TYPE__C = 'ALL',
                        DATE__C = myDate,
                        QUOTA__C = 0,
                        KEY__C = payeeId + '-' + tm.Territory_Number__c + '-TELEFLEX-ALL-' + myDate,
                        Empty_Quota__c = TRUE
                    );
                    //Key: 721427-800553-INTV-USREP1-ALL-2017-06-01
                    tqList.add(newTQ);
                    
                    myDate = myDate.addMonths(1);
                }

                // House Keeping
                tm.Build_Empty_Quotas__c = FALSE;
                if(tm.Payee_Id__c == NULL){
                    tm.Payee_Id__c = tm.Territory_Number__c;
                }
            }
        }
        
        if(tqList.size() > 0){
            insert tqList;
        }
        if(tid.size() > 0){
            list<Territory_Quota__c> removeList = new list<Territory_Quota__c>();
            for(Territory_Quota__c tq : [SELECT Id 
                                         FROM Territory_Quota__c
                                         WHERE Territory_Master__c =:tid 
                                         AND Empty_Quota__c = TRUE])
            {
                removeList.add(tq);
            }
            if(removeList.size() > 0){
                delete removeList;
            }
        }
    }
    
    public static void Build_Territory_Alignments(list<Territory_Master__c> tmlist){
        
        system.debug('Starting Build_Territory_Alignments Class');
        // This class is intentionally not bulked - not a real need to bulk and the level of effort
        // is time prohibitive. - ESC 18Feb2016
        
        string tm;
        string tmid;
        
        for(Territory_Master__c t : tmlist){
            if(t.Update_Territory_Alignments__c == TRUE){
                tm = t.name;
                tmid = t.id; 
            }
            
        }
        
        string query = 'SELECT Id, SAP_Sold_to__c, BillingState, BillingPostalCode, Customer_Group__c ' + 
            'FROM Account ' +                                                  
            'WHERE Territory_Alignment_Skip__c = FALSE';
        system.debug('query: ' + query);
        
        if(tm != NULL){
            territory_master_build_security tBuild = new territory_master_build_security(query);
            tBuild.query = query;
            tBuild.territory = tm;
            ID batchprocessid = Database.executeBatch(tBuild); 
            
            Territory_Master__c tmupdate = new Territory_Master__c(
                id = tmid,
                Update_Territory_Alignments__c = FALSE
            );
            update tmupdate;
        } // If Statement
    } // End of Class

    public static void tickleQuotas(list<Territory_Master__c> newTrigger){
        // 25July2017 - ESC
        // This class is to make it easier to switch ownership of Quota's
        // Test Class: territory_user_security_test
        set<Id> tIds = new set<Id>();
        set<Id> tqIds = new set<Id>();
        for(Territory_Master__c t : newTrigger){
            if(t.Tickle_Quota_s__c){
                tIds.add(t.Id);
                t.Tickle_Quota_s__c = FALSE;
            }
        }
        if(tIds.size() > 0){
            list<Territory_Quota__c> updateTQ = new list<Territory_Quota__c>();
            for(Territory_Quota__c tq : [SELECT Id 
                                        FROM Territory_Quota__c 
                                        WHERE Territory_Master__c = :tIds])
            {
                Territory_Quota__c newTQ = new Territory_Quota__c(
                    Id = tq.Id
                );
                updateTQ.add(newTQ);
            }
            if(updateTQ.size() > 0){
                update updateTQ;
            }
        }
    }    
}