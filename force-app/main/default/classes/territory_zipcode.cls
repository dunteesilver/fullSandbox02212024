public class territory_zipcode {
    /*
    public static void zipLookup(String objName, List<sObject> newTrigger){
        System.debug('Starting --------- ZipLookup! -------');
        set<String> zips = new set<String>();
        for(sObject s : newTrigger){
            zips.add(String.valueOf(s.get('Zip_Code_Zip__c')));
            System.debug('Adding this ZIP to the list: ' + String.valueOf(s.get('Zip_Code_Zip__c')));
        }
        
        Map<String, Id> listZip = new Map<String, Id>();
        for(Zip_Code_Territories__c zcMap : [SELECT Zip_Code__c, Id FROM Zip_Code_Territories__c WHERE Zip_Code__c IN :zips]){
            listZip.put(zcMap.Zip_Code__c, zcMap.Id);
            System.debug('Zip Code Map:' + listZip); 
        }
        
        System.debug('listZip Size: ' + listZip.size());         
        list<sObject> updateZip = new list<sObject>();
        
        for(sObject s : newTrigger){
            if(String.valueOf(s.get('Zip_Code_Zip__c')) != NULL && (String.valueOf(s.get('Business_Unit__c')) != NULL || String.valueOf(s.get('Zip_Code_Business_Unit__c')) != NULL) && listZip.size() > 0){
                
                if(Trigger.isAfter){
                    // Gets the Object Type and creates the new record
                    sObject addObj = Schema.getGlobalDescribe().get(objName).newSObject();
                    
                    //addObj.put('Zip_Code_Auto_Route__c', TRUE);
                    addObj.put('id', s.get('id'));
                    addObj.put('Zip_Code_Territories__c', listZip.get(String.valueOf(s.get('Zip_Code_Zip__c'))));
                    
                    //if(String.valueOf(s.get('s.Business_Unit__c')) == NULL && objName == 'Lead'){
                    //    addObj.put('Business_Unit__c', String.valueOf(s.get('s.Zip_Code_Business_Unit__c')));                        
                    //}

                    system.debug('Adding Zip Code Record for Update: ' + addObj);
                    updateZip.add(addObj);

                }
                else{
                    System.debug('Zip Map Debug -------' + listZip.get(String.valueOf(s.get('Zip_Code_Zip__c'))));
                    System.debug('Zip Code -------' + String.valueOf(s.get('Zip_Code_Zip__c')));

                    s.put('Zip_Code_Territories__c', listZip.get(String.valueOf(s.get('Zip_Code_Zip__c'))));
                }
            }
        }
        if(updateZip.size() > 0){
            update updateZip;
            system.debug('System Update with:' + updateZip);
        }
        System.debug('--------- Finished with ZipLookup! -------');
    }

    public static void userAssign2(list<Lead> newTrigger){
        // Method looks at the related Zip Code Territory record and the business unit and
        // Assigns the related 'active' territory user.
        System.debug('--------- Starting UserAssign! -------');
        set<String> usrs = new set<String>();
        
        for(Lead lpu : newTrigger){
            usrs.add(lpu.Zip_Code_Territory_User__c);
        }
        Map<String, ID> listUsrs = new Map<String, ID>();
        
        for(Territory_User__c usrMap : [SELECT Territory_Master__r.name, User__c 
                                        FROM Territory_User__c 
                                        WHERE Territory_Master__r.name IN :usrs AND User__r.IsActive = TRUE])
        {
            listUsrs.put(usrMap.Territory_Master__r.name, usrMap.User__c);
            System.debug('Map List Debug:Name -------' + usrMap.Territory_Master__r.name);
            System.debug('Map List Debug:UserId -------' + usrMap.User__c);
        }
        
        list<sObject> updateObj = new list<sObject>();
        List<Lead_Settings__c> ldoList = new List<Lead_Settings__c>();
        ldoList.addAll(Lead_Settings__c.getAll().values());
        
        Map<String, Lead_Settings__c> lsMap = new Map<String, Lead_Settings__c>();
        Map<String, Id> qMap = new Map<String, Id>();
        Map<String, Id> rMap = new Map<String, Id>();
        for(Lead_Settings__c ls : ldoList){
            lsMap.put(ls.Name, ls);
            qMap.put(ls.Name, ls.Lead_Owner_ID__c);
            rMap.put(ls.Name, ls.Record_Type_ID__c);
        }
        system.debug('Lead Map: ' + qMap);
        
        
        

        list<lead> lUpdate = new list<lead>();
        for(lead l : newTrigger){
            if(l.Zip_Code_Auto_Route__c == FALSE && listUsrs.size() > 0 && listUsrs.get(l.Zip_Code_Territory_User__c) != NULL){

                string sbu = l.Zip_Code_Business_Unit__c;
                string ownerID = l.Zip_Code_Territory_User__c;
                string recordID = rMap.get(sbu);
                system.debug('List User (Check for NULL): ' + ownerID);

                lead ladd = new lead();
                ladd.Id = l.Id;
                ladd.Zip_Code_Auto_Route__c = TRUE;
                
                
                if(recordID != NULL){
                    ladd.RecordTypeId = rMap.get(sbu);
                }
                else{
                    ladd.RecordTypeId = rMap.get('Default');
                }
                if(ownerID != NULL){
                    if(qMap.get(sbu) == NULL){
                        ladd.ownerID = qMap.get(sbu);
                    }
                    else{
                        ladd.ownerID = qMap.get('Default');    
                    }
                }
                
                lUpdate.add(ladd);
            }
        }
        if(lUpdate.size() > 0){
            update lUpdate;
        }
    }

    
    public static void userAssign(String objName, List<sObject> newTrigger){
        if(master_TriggerHelperClass.qd('ZipCode_User_Assign')){
            System.debug('--------- Starting UserAssign! -------');
            set<String> usrs = new set<String>();
            string zipusradd;
            string altusradd;
            for(sObject s : newTrigger){
                zipusradd = String.valueOf(s.get('Zip_Code_Territory_User__c'));
                altusradd = String.valueOf(s.get('Territory_Based_Owner__c'));
                if(zipusradd != NULL){
                    usrs.add(zipusradd);
                }
                else if(zipusradd != NULL){
                    usrs.add(altusradd);
                }
                System.debug('zipusradd and altusradd: ' + zipusradd + ' and ' + altusradd);
                System.debug('User Set: ' + usrs);
            }
            Map<String, ID> listUsrs = new Map<String, ID>();
            
            for(Territory_User__c usrMap : [SELECT Territory_Master__r.name, User__c 
                                            FROM Territory_User__c 
                                            WHERE Territory_Master__r.name IN :usrs 
                                            AND User__r.IsActive = TRUE])
            {
                listUsrs.put(usrMap.Territory_Master__r.name, usrMap.User__c);
                System.debug('Map List Debug:Name -------' + usrMap.Territory_Master__r.name);
                System.debug('Map List Debug:UserId -------' + usrMap.User__c);
            }
            
            
            list<sObject> updateObj = new list<sObject>();
            List<Lead_Settings__c> ldoList = new List<Lead_Settings__c>();
            ldoList.addAll(Lead_Settings__c.getAll().values());
            
            Map<String, Lead_Settings__c> lsMap = new Map<String, Lead_Settings__c>();
            Map<String, Id> qMap = new Map<String, Id>();
            Map<String, Id> rMap = new Map<String, Id>();
            for(Lead_Settings__c ls : ldoList){
                lsMap.put(ls.Name, ls);
                qMap.put(ls.Name, ls.Lead_Owner_ID__c);
                rMap.put(ls.Name, ls.Record_Type_ID__c);
            }
            system.debug('Lead Map: ' + qMap);
            
            for(sObject s : newTrigger){
                if(!(Boolean.valueOf(s.get('Zip_Code_Auto_Route__c'))) && (String.valueOf(s.get('Business_Unit__c')) != NULL || String.valueOf(s.get('Zip_Code_Business_Unit__c')) != NULL)){
                    
                    string sbu = String.valueOf(s.get('Zip_Code_Business_Unit__c'));
                    string ownerID = listUsrs.get(String.valueOf(s.get('Zip_Code_Territory_User__c')));
                    string recordID = rMap.get(sbu);
                    //if(qMap.get(sbu).Record_Type_ID__c <> NULL){
                    if(recordID <> NULL){
                        recordID = '' + rMap.get(sbu);
                    }
                    else{
                        recordID = rMap.get('Default');
                    }
                    system.debug('List User (Check for NULL): ' + ownerID);
                    if(ownerID == NULL){
                        if(qMap.get(sbu) == NULL){
                            ownerID = qMap.get('Default');    
                        }
                        else{
                            ownerID = qMap.get(sbu);    
                        }
                    }
                    if(recordID == NULL){
                        recordID = rMap.get('Default');
                    }
                    if(ownerID != NULL){
                        if(Trigger.isAfter){
                            
                            // Gets the Object Type and creates the new record
                            sObject addObj = Schema.getGlobalDescribe().get(objName).newSObject();
                            
                            addObj.put('Zip_Code_Auto_Route__c', TRUE);
                            addObj.put('id', s.get('id'));
                            
                            
                            
                            if(objName == 'Lab_Participant__c'){
                                addObj.put('Approver__c', ownerID);
                            }
                            else{
                                addObj.put('OwnerId', ownerID);
                                addObj.put('RecordTypeId', recordID);
                            }                        
                            
                            System.debug('Update Owner Record: ' + addObj);
                            updateObj.add(addObj);
                        }
                        else{
                            system.debug('Insert Assign User Section');
                            s.put('Zip_Code_Auto_Route__c', TRUE);
                            if(objName == 'Lab_Participant__c'){
                                s.put('Approver__c', ownerID);	     
                            }
                            else{
                                s.put('OwnerId', ownerID);	     
                                s.put('RecordTypeId', recordID);
                            }
                            System.debug('User ID: ' + ownerID);     
                        }
                    }
                    else{
                        system.debug('Owner ID was NULL! - Probably because there was not a DEFAULT lead queue mapping in the Customer Setting for the BU specified');
                    }
                    
                    
                }
            }
            if(updateObj.size() > 0){
                update updateObj;
            }
            System.debug('Finished --------- userAssign! -------');
        }
        
    }*/
}