public class TFX_MANTA_Utility_Handler {
    
     @AuraEnabled
    public static Map<String, List<SObject>> getAllPhysAndRgnByHospAccId(Id hospAccId) {
        Map<String, List<SObject>> phyAndRegionMap = new Map<String, List<SObject>>();
        List<sObject> northLst = new List<sObject>();
        List<sObject> southLst = new List<sObject>();
        List<sObject> westLst = new List<sObject>();
        Set<String> tset = new Set<String>();
        List<String> sortedvalue = new List<String>(); 
        List<SObject> sobjLst = new List<SObject>();
        
        List<MANTA_Master__c> proctsLst =  getAllProctorsInSF();
        phyAndRegionMap.put('proctors', proctsLst);
        
        List<Contact> pyhsLst =  [SELECT Id, Salutation, Name, Title, Position_Job_Title__c, email, phone 
                                  FROM Contact 
                                  WHERE AccountId =: hospAccId
                                  AND Salutation like 'Dr%'
                                  //AND (Contact.Business_Unit1__c = 'Interventional' OR Contact.Business_Unit1__c = 'Vascular')
                                  AND Name != null
                                  ORDER BY Name ASC];
        phyAndRegionMap.put('physicians', pyhsLst);
        
        //Get region starts here
        //Code to read regions from the custom setting buckets - Surya - W-025962
        List<sObject> rgnLst = [SELECT Name, Region_Zone__c FROM Account_Region__c WHERE Region_Zone__c != NULL];
        for(sObject rgnSObj : rgnLst){
            if(rgnSObj.get('Region_Zone__c') == 'North'){northLst.add(rgnSObj);}
            if(rgnSObj.get('Region_Zone__c') == 'South'){southLst.add(rgnSObj);}
            if(rgnSObj.get('Region_Zone__c') == 'West'){westLst.add(rgnSObj);}
        }
        
        Account accObj = [select Id, Territory_Key__c from Account where Id =: hospAccId];
        
        if(accObj.Territory_Key__c != NULL){
            string poiList = accObj.Territory_Key__c;
            sortedvalue = poiList.split(';');
            sortedvalue.sort();
            tset.addAll(sortedvalue);
        }
        
        /*check standard account team memebers 
* and add thier territories to tset
*/
        Set<Id> accountTeamUsersSet = new Set<Id>();
        for(AccountTeamMember atm: [SELECT UserId 
                                    FROM AccountTeamMember
                                    WHERE AccountId =: hospAccId])
        {
            accountTeamUsersSet.add(atm.UserId);
        }
        if(!accountTeamUsersSet.isEmpty()){
            for(Territory_Master__c tmByUser :[SELECT Id, Territory_Number__c
                                               FROM Territory_Master__c 
                                               WHERE Primary_Territory_User__c IN:accountTeamUsersSet OR Sales_Rep__c IN:accountTeamUsersSet])
            {
                tset.add(tmByUser.Territory_Number__c);
            }
        }
        
        System.debug('territory key vals splitted and added to tset==='+tset);
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get('User');
        Sobject genericObject = convertType.newSObject();  
        
        try{
            List<Territory_Master__c> tmLst = [SELECT Id, Name, Role__c, Business_Unit__c, Primary_Territory_User__c, Sales_Rep__c, Manager__c,
                                               Primary_Territory_User__r.Region__c, Sales_Rep__r.Region__c, Manager__r.Region__c,
                                               Territory_Number__c
                                               FROM Territory_Master__c 
                                               WHERE Territory_Number__c IN : tset
                                               AND Business_Unit__c = 'Interventional'
                                               AND Role__c = 'Sales Rep'
                                               ORDER BY LastModifiedDate DESC
                                               LIMIT 1
                                              ];
            
            if(tmLst.size() > 0 || !tmLst.isEmpty())
            {
                for(Territory_Master__c tm : tmLst){
                    System.debug('tmLst limit 1-->'+tm);
                    if(tset.contains(tm.Territory_Number__c)){
                        if(tm.Sales_Rep__c != NULL){
                            genericObject.put('Region__c', tm.Sales_Rep__r.Region__c);
                            sobjLst.add(genericObject);
                            System.debug('sales rep sobjLst-->'+sobjLst);
                        }
                        else if(tm.Primary_Territory_User__c != NULL){
                            genericObject.put('Region__c', tm.Primary_Territory_User__r.Region__c);
                            sobjLst.add(genericObject);
                            System.debug('primary usr sobjLst-->'+sobjLst);
                        }
                        else{
                            genericObject.put('Region__c', tm.Manager__r.Region__c);
                            sobjLst.add(genericObject);
                            System.debug('mgr sobjLst-->'+sobjLst);
                        }
                    }
                    
                }
            }
            else{
                Set<String> taSet = new Set<String>();
                List<Territory_Assignment__c> taLst = [SELECT Territory_Number__c 
                                                       FROM Territory_Assignment__c
                                                       WHERE Account__c =: hospAccId
                                                       AND Territory_Alignment__r.Active__c = TRUE 
                                                       AND Business_Unit__c = 'Interventional'
                                                       ORDER BY Business_Unit__c];
                for(Territory_Assignment__c ta : taLst){
                    taSet.add(ta.Territory_Number__c);
                }
                Territory_Master__c tm = [SELECT Id, Name, Role__c, Business_Unit__c, Primary_Territory_User__c, Sales_Rep__c, Manager__c,
                                          Primary_Territory_User__r.Region__c, Sales_Rep__r.Region__c, Manager__r.Region__c,
                                          Territory_Number__c
                                          FROM Territory_Master__c 
                                          WHERE Territory_Number__c IN : taSet
                                          AND Business_Unit__c = 'Interventional'
                                          ORDER BY LastModifiedDate DESC
                                          LIMIT 1
                                         ];
                String region = tm.Sales_Rep__r.Region__c != null ? tm.Sales_Rep__r.Region__c : 'Open';
                genericObject.put('Region__c', region);
                sobjLst.add(genericObject);
                System.debug('in else-->'+sobjLst);
            }
        }
        catch(Exception ex){
            genericObject.put('Region__c', 'Open');
            sobjLst.add(genericObject);
            System.debug('in catch-->'+sobjLst);
        }
        phyAndRegionMap.put('region', sobjLst);
        
        if(containsAnyInList(northLst, phyAndRegionMap.get('region'), 'Name', 'Region__c')){
            genericObject.put('Region__c', 'North');
            sobjLst.add(genericObject);
            phyAndRegionMap.put('region', sobjLst);
            System.debug('in north if');
        }
        if(containsAnyInList(southLst, phyAndRegionMap.get('region'), 'Name', 'Region__c')){
            genericObject.put('Region__c', 'South');
            sobjLst.add(genericObject);
            phyAndRegionMap.put('region', sobjLst);
            System.debug('in south if');
        }
        if(containsAnyInList(westLst, phyAndRegionMap.get('region'), 'Name', 'Region__c')){
            genericObject.put('Region__c', 'West');
            sobjLst.add(genericObject);
            phyAndRegionMap.put('region', sobjLst);
            System.debug('in north if');
        }  
        System.debug('in return-->'+phyAndRegionMap.get('region'));
        return phyAndRegionMap;
    }
    
    //method to check if value in first list is present in second list. we can pass field names dynamically to search.
    //params: first list, second list, field one, field two.
    public static Boolean containsAnyInList(List<sObject> toSearch, List<sObject> values, String toSrchField, String valField)
    {
        if (toSearch.size() == 0)
        {
            return false;
        }
        Set<String> fieldList = toSearch[0].getSObjectType().getDescribe().fields.getMap().keySet();
        for (sObject i : values)
        {
            for (sObject j : toSearch)
            {
                for (String k : fieldList)
                {
                    if (String.valueOf(i.get(valField)) == String.valueOf(j.get(toSrchField)))
                    {
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
     @AuraEnabled
    public static List<MANTA_Master__c> getAllProctorsInSF(){
        
        List<MANTA_Master__c> proctorsFrmMantaMstrLst = [select Id, 
                                                         Trainer__c, 
                                                         Trainer__r.Name,
                                                         Trainer__r.Email,
                                                         Trainer__r.Region__c,
                                                         isAdminAccess__c,
                                                         isActive__c
                                                         from MANTA_Master__c
                                                         where Type__c = 'proctor'
                                                         and isActive__c = true
                                                         order by Trainer__r.Name ASC
                                                        ]; 
        
        return proctorsFrmMantaMstrLst;
    }

}