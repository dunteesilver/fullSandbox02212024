/*********************************************************************
* Description     : This class is used by master_CaseTrigger
* Test Class      : case_Helper_Class_Test
* VisualForce     : N/A
* Author(s)       : Dun Silver
**********************************************************************/

public class case_Helper_Class {
    @AuraEnabled
    public static Case getCase(Id caseId) {
        Case c = [SELECT Id, Subject, Description, Status, OwnerId, Type, agf__ADM_Work__c  
                  FROM Case 
                  WHERE Id =:caseId];

        System.debug('*** case *** ' + c);
        return c;
    }
    
    @AuraEnabled //this is used for the Lightning Component Button
    public static Map<String,String> createWorkObject(agf__ADM_Work__c newWork,  Case caseObj){
        System.debug('*** IN createWorkObject method in case_Helper_Class ***');
        System.debug('*** newWork *** ' + newWork);
        System.debug('*** case in createWorkObject *** ' + caseObj);
        
        User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
        QueueSobject que = [SELECT Id, QueueId, SobjectType, Queue.Name FROM QueueSobject WHERE Queue.Name = 'SFDC Backlog'];
        agf__ADM_Scrum_Team__c scrumTeam = [SELECT Id FROM agf__ADM_Scrum_Team__c WHERE Name = 'Salesforce.com Team'];
        agf__ADM_Product_Tag__c prodTag = [SELECT Id FROM agf__ADM_Product_Tag__c WHERE Name = 'Salesforce.com'];
        System.debug('*** que *** ' + que);
        System.debug('*** scrumTeam *** ' + scrumTeam);
        System.debug('*** prodTag *** ' + prodTag);
        Map<String,String> resultMap = new Map<String,String>();
        System.debug('*** Creating Work ***');
        if(caseObj.agf__ADM_Work__c != NULL){
            System.debug('*** In if condition createWorkLightning ***');
            resultMap.put('status','error');
            resultMap.put('message','Case already has Work associated...');
        }
        else{
            try{
                System.debug('*** In try block of createWorkLightning ***');
                //agf__ADM_Work__c  newWork = new agf__ADM_Work__c();
                Case updCase = new Case();
                //newWork.agf__Subject__c = caseObj.Subject;
                //newWork.agf__Details__c = caseObj.Description;
                //newWork.agf__Assignee__c = caseObj.OwnerId;
                //newWork.OwnerId = caseObj.OwnerId;
                //newWork.agf__Type__c = caseObj.Type;
                newWork.agf__Assignee__c = u.Id; //set owner to current user
                newWork.agf__Scrum_Team__c = scrumTeam.Id; //Salesforce.com Team
                newWork.agf__Product_Tag__c = prodTag.Id;
                insert newWork;//insert work
                
                //update Case with work ID
                updCase.Id = caseObj.Id;
                updCase.OwnerId = que.QueueId;
                updCase.agf__ADM_Work__c = newWork.Id;
                update updCase;
                
                resultMap.put('status','success');
                resultMap.put('message','Work Successfully Created!');
            }catch(Exception e){
                System.debug('*** In catch block of createWorkLightning ***');
                resultMap.put('status','error');
                resultMap.put('message','Work was NOT Created!' );
            }
        }//end else
        return resultMap;
    }//end of createWorkObject
    
    /*
    public static void reassignCases(List<Case> newTrigger, Map<Id,Case> oldTrigger, String Type){
        //get record types for routing
        String recordTypeName;
        String userBu;
        
        userBu = [SELECT Id, Name, Business_Unit__c FROM User where Id =:UserInfo.getUserId()].Business_Unit__c; 
        
        if(userBu == 'Commercial Operations' || userBu == 'Customer Advocacy' || userBu == 'Customer Service'
           || userBu == 'Latin America' || userBu == 'National Accounts' || userBu == 'Clinical Affairs'
           || userBu == 'Canada' || userBu == NULL){
           userBu = 'Vascular';
        }
        
        Map<Id,String> recMap = new Map<Id,String>();
        Map<String,SalesCompTeam__c> compMap = SalesCompTeam__c.getAll();
        List<SalesCompTeam__c> compList = SalesCompTeam__c.getAll().values();
        List<RecordType> recs = [SELECT Id, Name, IsActive, SobjectType, DeveloperName
                                 FROM RecordType 
                                 WHERE SobjectType = 'Case'
                                 ORDER BY SobjectType ASC];
        
        System.debug('*** userBu *** ' + userBu);
        System.debug('*** compMap *** ' + compMap);
        System.debug('*** compList *** ' + compList);
        System.debug('*** recs *** ' + recs);
        //Make map of rectype and Ids
        for(RecordType curr : recs){
            recMap.put(curr.Id,curr.Name);
        }
        //loop to check records for assignment
        for(Case curr : newTrigger){
            //check for General SFDC Case
           	recordTypeName = recMap.get(curr.RecordTypeId);
            if(recordTypeName == 'General Salesforce'){
                //SFDC New Case queue Id 
                curr.ownerId = '00GE0000000d4UOMAY';
            }
            else if(recordTypeName == 'Sales Comp ICM'){
                //Sales Comp queue Id 00GE00000036NUEMA2 
                curr.ownerId = '00GE00000036NUEMA2';
            }
            else if(recordTypeName == 'DMO Case'){
                //SFDC New Case queue Id 
                curr.ownerId = '00G440000045JjnEAE';
            }
            /*
            else if(recordTypeName == 'Sales Inquiry'){
                //logic to handle routing
                if(userBu.containsIgnoreCase('Surgical')){
                    curr.ownerId = compMap.get(userBu).Id__c;
                }
                else if(userBu.containsIgnoreCase('Interventional')){
                    curr.ownerId = compMap.get(userBu).Id__c;
                }
                else if(userBu.containsIgnoreCase('Vascular')){
                    curr.ownerId = compMap.get(userBu).Id__c;
                }
                else if(userBu.containsIgnoreCase('Anesthesia')){
                    curr.ownerId = compMap.get(userBu).Id__c;
                }
                else if(userBu.containsIgnoreCase('EMS')){
                    curr.ownerId = compMap.get(userBu).Id__c;
                }
                else if(userBu.containsIgnoreCase('Respiratory')){
                    curr.ownerId = compMap.get(userBu).Id__c;
                }
                else if(userBu.containsIgnoreCase('Urology')){
                    curr.ownerId = compMap.get(userBu).Id__c;
                }
                else{
                    //SFDC New Case queue Id 
                	curr.ownerId = '00GE0000000d4UOMAY';
                }

            }//end else if Sales Inquiry
			*/
    		/*
            else if(recordTypeName == 'VSS/VPS Case'){
                System.debug('*** curr.ownerId *** ' + curr.ownerId);
            }
            else{
                //SFDC New Case queue Id 
                //curr.ownerId = '00GE0000000d4UOMAY';
            }
    		
        }//end of for loop
    }
	*/
    /*
    @AuraEnabled //this is used for the Lightning Component Button
    public static Map<String,String> createWorkLightning(Id caseId){
        System.debug('*** IN createWorkLightning method in case_Helper_Class ***');
        System.debug('*** caseId *** ' + caseId);
        
        Case c = [SELECT Id, Subject, Description, Status, OwnerId, Type, agf__ADM_Work__c 
                  FROM Case 
                  WHERE Id =:caseId];
        
        System.debug('*** case in createWorkLightning *** ' + c);
        
        QueueSobject que = [SELECT Id, QueueId, SobjectType, Queue.Name FROM QueueSobject WHERE Queue.Name = 'SFDC Backlog'];
        agf__ADM_Scrum_Team__c scrumTeam = [SELECT Id FROM agf__ADM_Scrum_Team__c WHERE Name = 'Salesforce.com Team'];
        agf__ADM_Product_Tag__c prodTag = [SELECT Id FROM agf__ADM_Product_Tag__c WHERE Name = 'Salesforce.com'];
        
        System.debug('*** scrumTeam *** ' + scrumTeam);
        System.debug('*** prodTag *** ' + prodTag);
        Map<String,String> resultMap = new Map<String,String>();
        System.debug('*** Creating Work ***');
        
        try{
            System.debug('*** In try block of createWorkLightning ***');
            agf__ADM_Work__c  newWork = new agf__ADM_Work__c();
            Case updCase = new Case();
            newWork.agf__Subject__c = c.Subject;
            newWork.agf__Details__c = c.Description;
            newWork.agf__Assignee__c = c.OwnerId;
            newWork.OwnerId = c.OwnerId;
            newWork.agf__Type__c = c.Type;
            newWork.agf__Scrum_Team__c = scrumTeam.Id; //Salesforce.com Team
            newWork.agf__Product_Tag__c = prodTag.Id;
            insert newWork;//insert work
            
            //update Case with work ID
            updCase.Id = caseId;
            updCase.OwnerId = que.QueueId;
            updCase.agf__ADM_Work__c = newWork.Id;
            update updCase;
            
            resultMap.put('status','success');
            resultMap.put('message','Complaint Updated Successfully!');
        }catch(Exception e){
            System.debug('*** In catch block of createWorkLightning ***');
            resultMap.put('status','error');
            resultMap.put('message',e.getMessage() );
        }

        return resultMap;
    }//end of createWorkLightning
    */
}