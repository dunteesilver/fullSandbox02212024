/*********************************************************************
* Description     : This class is used by master_Task trigger
* Test Class      : task_Helper_Class_Test
* VisualForce     : N/A
* Author(s)       : Dun Silver
**********************************************************************/

public class task_Helper_Class {
    
    public static void addLookups(List<Task> newTrigger){
        
        set<Id> accIds = new set<Id>();
        set<Id> conIds = new set<Id>();
        set<Id> eduIds = new set<Id>();
        list<Task> tList = new list<Task>();
        map<Id, Task> conIdTaskMap = new map<Id, Task>();
        Contact tskConObj;
        
        Set<String> contactIdSet = new Set<String>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        for(Task t : newTrigger)
        {
            String whoIdStr = (String)t.WhoId;
            if(!String.isBlank(whoIdStr) && whoIdStr.startsWith('003'))
            {
                contactIdSet.add(whoIdStr);
            }   
        }
        if(!contactIdSet.isEmpty())
        {
            contactMap = new Map<Id,Contact>([SELECT Id,AccountId,FirstName FROM Contact WHERE Id IN: contactIdSet]);
        }
        
        
        for(Task t : newTrigger){
            String whoIdStr = (String)t.WhoId;
            String whatIdStr = (String)t.WhatId;
            if(t.WhatId != NULL && t.SAP_Code__c == NULL && t.IsRecurrence == FALSE && whatIdStr.startsWith('001')){		//surya.arvan@teleflex.com - change AccountId to WhatId as AccountId is null at this point. 
                accIds.add(t.WhatId);
                tList.add(t);
                conIdTaskMap.put(whoIdStr, t);
            }
            else if(!String.isBlank(whoIdStr) && whoIdStr.startsWith('003')){
                //tskConObj = [SELECT Id, AccountId, FirstName FROM Contact WHERE Id =: t.WhoId ];
                //accIds.add(tskConObj.AccountId);
                if(contactMap.containsKey(whoIdStr))
                {
                    tskConObj = contactMap.get(whoIdStr);
                    accIds.add(contactMap.get(whoIdStr).AccountId);
                }
                tList.add(t);
            }   
        }
        
        if(accIds.size() > 0){
            map<Id, Account> sapMap = new map<Id, Account>();
            
            for(Account a : [SELECT Id, 
                             SAP_Sold_To__c,
                             Name,
                             AnnualRevenue,
                             Sales_Org__c,
                             Customer_Group__c,
                             Customer_Group_Name__c
                             FROM Account WHERE Id = :accIds])
            {
                if(a != NULL){sapMap.put(a.Id, a);}
                
            }
            
            for(Task t : tList){
                if(sapMap.containsKey(t.WhatId)){
                    if(!String.isBlank(sapMap.get(t.WhatId).Name)) t.Account_Name__c = sapMap.get(t.WhatId).Name;
                    if(!String.isBlank(sapMap.get(t.WhatId).SAP_Sold_To__c)) t.SAP_Code__c = sapMap.get(t.WhatId).SAP_Sold_To__c;
                    t.AnnualRevenue__c = sapMap.get(t.WhatId).AnnualRevenue != null ? sapMap.get(t.WhatId).AnnualRevenue : 0;
                    t.Account_Sales_Org__c = sapMap.get(t.WhatId).Sales_Org__c != null ? sapMap.get(t.WhatId).Sales_Org__c : 'N/A';
                    t.Customer_Group_Number__c = sapMap.get(t.WhatId).Customer_Group__c != null ? sapMap.get(t.WhatId).Customer_Group__c : 'N/A';
                    t.Customer_Group_Name__c = sapMap.get(t.WhatId).Customer_Group_Name__c != null ? sapMap.get(t.WhatId).Customer_Group_Name__c : 'N/A';
                    
                }
                else{
                    try{
                        t.Account_Name__c = sapMap.get(tskConObj.AccountId).Name;
                        t.SAP_Code__c = sapMap.get(tskConObj.AccountId).SAP_Sold_To__c;
                        t.AnnualRevenue__c = sapMap.get(tskConObj.AccountId).AnnualRevenue != null ? sapMap.get(tskConObj.AccountId).AnnualRevenue : 0;
                        t.Account_Sales_Org__c = sapMap.get(tskConObj.AccountId).Sales_Org__c != null ? sapMap.get(tskConObj.AccountId).Sales_Org__c : 'N/A';
                        t.Customer_Group_Number__c = sapMap.get(tskConObj.AccountId).Customer_Group__c != null ? sapMap.get(tskConObj.AccountId).Customer_Group__c : 'N/A';
                        t.Customer_Group_Name__c = sapMap.get(tskConObj.AccountId).Customer_Group_Name__c != null ? sapMap.get(tskConObj.AccountId).Customer_Group_Name__c : 'N/A';
                    }
                    catch(Exception ex){
                        t.Account_Name__c = '';
                        t.SAP_Code__c = '';
                        t.AnnualRevenue__c = 0;
                        t.Account_Sales_Org__c = 'N/A';
                        t.Customer_Group_Number__c = 'N/A';
                        t.Customer_Group_Name__c = 'N/A';
                    }
                }
            }
        }
        
        for(Task t : newTrigger){
            String whoIdStr = (String)t.WhoId;
            if(!String.isBlank(whoIdStr) && whoIdStr.startsWith('003')){
                //tskConObj = [SELECT Id, AccountId, FirstName FROM Contact WHERE Id =: t.WhoId ];
                conIds.add(whoIdStr);
                tList.add(t);
            }
        }
        if(conIds.size() > 0){
            
            map<Id, Contact> conMap = new map<Id, Contact>();
            
            for(Contact c : [SELECT Id, 
                             FirstName,
                             LastName,
                             Email,
                             Phone,
                             Preferred_language__c,
                             MailingCountry,
                             Position_Job_Title__c
                             FROM Contact WHERE Id = :conIds])
            {
                if(c != NULL){conMap.put(c.Id, c);}
                
            }
            if(conMap.size() > 0){
                for(Task t : tList){
                    if(conMap.containsKey(t.WhoId)){
                        t.Contact_First_Name__c = conMap.get(t.WhoId).FirstName != null ? conMap.get(t.WhoId).FirstName : 'N/A';
                        t.Contact_Last_Name__c  = conMap.get(t.WhoId).LastName;
                        t.Contact_Email__c = conMap.get(t.WhoId).Email != null ? conMap.get(t.WhoId).Email : 'N/A';
                        t.Contact_Phone__c = conMap.get(t.WhoId).Phone != null ? conMap.get(t.WhoId).Phone : 'N/A';
                        t.Contact_Preferred_language__c = conMap.get(t.WhoId).Preferred_language__c != null ? conMap.get(t.WhoId).Preferred_language__c : 'N/A';
                        t.Contact_Country__c = conMap.get(t.WhoId).MailingCountry != null ? conMap.get(t.WhoId).MailingCountry : 'N/A';
                        t.Contact_Position_Job_Title__c = conMap.get(t.WhoId).Position_Job_Title__c != null ? conMap.get(t.WhoId).Position_Job_Title__c : 'N/A';
                    }
                }
            }
        }
        
        
        /*for(Task t : newTrigger){
            String whatIdStr = (String)t.WhatId;
            if(!String.isBlank(whatIdStr)){
                List<Education_record__c> eduObjs = [SELECT Id FROM Education_record__c WHERE Id =:t.WhatId ];
                if(eduObjs != null && eduObjs.size()>0){
                    eduIds.add(eduObjs[0].Id);
                    tList.add(t);
                }
            }
        }*/
        
        Schema.DescribeSObjectResult eduRecSchema = Education_record__c.sObjectType.getDescribe();
        String eduObjKeyPrefix = eduRecSchema.getKeyPrefix();
        System.debug('eduObjKeyPrefix:'+eduObjKeyPrefix);
        
        for(Task t : newTrigger)
        {
            String whatIdStr = (String)t.WhatId;
            if(!String.isBlank(whatIdStr) && whatIdStr.substring(0,3) == eduObjKeyPrefix)
            {
                eduIds.add(whatIdStr);
                tList.add(t);
            }
        }
        if(eduIds.size() > 0){
            
            map<Id, Education_Record__c> eduMap = new map<Id, Education_Record__c>();
            
            for(Education_Record__c c : [SELECT Id, 
                                         RecordType.Name,
                                         Sales_Rep__r.Email,RSM__r.Email,CEM__r.Email,RCEM__r.Email
                                         FROM Education_Record__c WHERE Id = :eduIds])
            {
                if(c != NULL){eduMap.put(c.Id, c);}
                
            }
            if(eduMap.size() > 0){
                for(Task t : tList){
                    if(eduMap.containsKey(t.WhatId)){
                        t.EDU_Sales_Rep_Email__c  = eduMap.get(t.WhatId).Sales_Rep__r.Email;
                        t.EDU_RSM_Email__c = eduMap.get(t.WhatId).RSM__r.Email;
                        t.EDU_CEM_Email__c = eduMap.get(t.WhatId).CEM__r.Email;
                        t.EDU_RCEM_Email__c = eduMap.get(t.WhatId).RCEM__r.Email;
                        t.Related_To_CMA_EDU_Record__c = ((eduMap.get(t.WhatId).RecordType.Name != null) && (eduMap.get(t.WhatId).RecordType.Name == 'CMA Record' )) ? true : false;
                        t.Related_to_Clinical_Sales_Program__c = ((eduMap.get(t.WhatId).RecordType.Name != null) && (eduMap.get(t.WhatId).RecordType.Name == 'Clinical Sales Program' )) ? true : false;
                       
                    }
                }
            }
        }
    }
    
    
    public static void addNewProductTracking(List<Task> newTrigger){
        // Created to Support Surgical - 07March2018 - ESC
        // Added Surg Imperative Support - 05Jul2018 - ESC
        // Test Class: account_Page_Helper_Test
        
        set<String> nptSet = new set<String>();
        map<String, Id> nptMap = new map<String, Id>();
        list<Task> updateTask = new list<Task>();
        for(Task t : newTrigger){
            if(t.Surg_Imperative__c != NULL){
                nptSet.add(t.Surg_Imperative__c);
                updateTask.add(t);
            }
            else if(t.Type__c != NULL){
                nptSet.add(t.Type__c);
                updateTask.add(t);
            }
            
        }
        if(updateTask.size() > 0){
            for( New_Product_Tracking__c npt : [SELECT Id, Activity_Task_Type__c
                                                FROM New_Product_Tracking__c
                                                WHERE Activity_Task_Type__c = :nptSet])
            {
                if(npt.Activity_Task_Type__c != NULL){
                    nptMap.put(npt.Activity_Task_Type__c, npt.Id);
                }
            }
            
            if(nptMap.size() > 0){
                for(Task t : newTrigger){
                    if(t.Surg_Imperative__c != NULL && nptMap.containsKey(t.Surg_Imperative__c)){
                        t.New_Product_Tracking__c = nptMap.get(t.Surg_Imperative__c);
                    }
                    else if(t.Type__c != NULL && nptMap.containsKey(t.Type__c)){
                        t.New_Product_Tracking__c = nptMap.get(t.Type__c);
                    }
                }
            }
        }
    }//end of addNewProductTracking
    
    public static void addTerritory(List<Task> newTrigger){
        // Created to Support the new 'Leading Indicators 2018 Project'. - 09Feb2018 - ESC
        // Test Class: territory_user_security_test
        // Test Class: account_Page_Helper_Test.account_Page_Helper_Test
        
        set<Id> userIds = new set<Id>();
        list<Task> updateTasks = new list<Task>();
        
        for(Task t : newTrigger){
            userIds.add(t.OwnerId);
            updateTasks.add(t);
            system.debug('OwnerId: ' + t.OwnerId);
        }
        if(updateTasks.size() > 0){
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
                
            }//end of for loop
            
            system.debug('tMap: ' + tMap);
            for(Task t : updateTasks){
                if(tMap.containsKey(t.OwnerId)){
                    t.Territory__c = tMap.get(t.OwnerId);
                }
            }
        }//end of if(updateTasks.size() > 0)
    }//end of addTerritory
    
    //method updates an Eloqua Task owner to the owner of the lead
    public static void eloquaTaskUpdate(List<Task> newTrigger){
        System.debug('*** STARTING eloquaTaskUpdate Method In task_Helper_Class ***');
        String elqSubject = NULL;
        String whoType = NULL;
        List<String> leadIds = new List<String>(); //list to get lead ids to query leads from Eloqua Task
        List<Task> taskList = new List<Task>(); //list to hold leads with an Eloqua task
        List<Lead> leadChild = new List<Lead>();
        //loop to get Lead Ids in a list
        for(Task curr : newTrigger){
            System.debug('*** Loop thru new tasks ***');
            leadIds.add(curr.WhoId);
        }
        
        leadChild = [SELECT Id, Name, OwnerId, Owner.Name,
                     (SELECT Id, Subject, OwnerId, Owner.Name, Who.Type, Status FROM Tasks)
                     FROM Lead
                     WHERE Id IN  :leadIds];
        
        //leadList = [SELECT Id, Name, OwnerId FROM Lead WHERE Id IN :leadIds];
        System.debug('*** leadChild.size() *** ' + leadChild.size());
        if(leadChild.size()>0){
            for(Lead l : leadChild){
                System.debug('*** l.OwnerId *** ' + l.OwnerId);
                for(Task t : l.Tasks){
                    elqSubject = t.Subject;
                    whoType = t.Who.Type;
                    if(l.OwnerId != t.OwnerId && elqSubject.containsIgnoreCase('Elq-Sample') && whoType == 'Lead' && t.Status != 'Completed'){
                        System.debug('*** Lead Owner does not Match Task Owner *** ');
                        t.OwnerId = l.OwnerId;
                        System.debug('*** Task Owner Id after Change *** ' + t.OwnerId);
                        taskList.add(t);
                    }//end of if
                }//end nested for loop
            }//end for loop
            update taskList;
        }//end of if
        
    }//end of eloquaTaskUpdate
    
    public static void oppPrimaryCampaignAdd(List<Task> newTrigger){
        System.debug('*** STARTING oppPrimaryCampaignAdd Method In task_Helper_Class ***');
        String whatType = NULL;
        String whatId = NULL;
        List<String> taskIds = new List<String>(); //list to get task ids to query task w/ related Opportunities
        List<String> oppIds = new List<String>(); //list to get opportunity ids
        List<Task> taskList = new List<Task>(); //list to hold task with associated Opportunity
        List<Task> taskUpd = new List<Task>(); //list to hold task to update
        List<Opportunity> oppList = new List<Opportunity>(); //list to hold opps with Primary Campaign Source
        Map<String,Task> taskMap = new Map<String,Task>(); //map to match WhatId to Task
        Map<String,Opportunity> oppMap = new Map<String,Opportunity>(); //map Opp Id with Campaign Id
        
        //get list task Ids for next query
        for(Task curr : newTrigger){
            whatId = curr.WhatId;
            if(whatId != NULL && whatId.left(3) == '006'){ //006 is Opportunity prefix
                System.debug('*** Related Object is an Opportunity ***');
                taskIds.add(curr.Id);
                taskMap.put(curr.WhatId,curr);
                oppIds.add(curr.WhatId);
            }
        }//taskIds
        
        //check if taskIds list has values
        System.debug('*** taskIds.size() *** ' + taskIds.size() );
        if( taskIds.size()>0 ){
            System.debug('*** In taskIds.size If *** ');
            taskList = [SELECT Id, Subject, Status, WhatId, What.Type, PrimaryOpportunityCampaign__c 
                        FROM Task 
                        WHERE Id IN :taskIds];
        }//end of if for list check
        
        //check if oppIds list has values
        System.debug('*** oppIds.size() *** ' + oppIds.size() );
        if( oppIds.size()>0 ){
            System.debug('*** In oppIds.size If *** ');
            //build Opportunity map
            for(Opportunity curr : [SELECT Id, Name, CampaignId, Campaign.Name
                                    FROM Opportunity
                                    WHERE Id IN :oppIds AND CampaignId != NULL]){
                                        System.debug('*** In oppList for loop *** ');
                                        oppMap.put(curr.Id, curr);
                                    }//end of for loop
        }//end of if
        
        //loop thru taskList to get Primary Opp Campaign using Opp Map
        System.debug('*** taskList.size() *** ' + taskList.size() );
        if( taskList.size() > 0 ){
            for(Task curr : taskList){
                System.debug('*** In taskList for loop *** ');
                if(oppMap.containsKey(curr.WhatId) && oppMap.get(curr.WhatId).CampaignId != NULL){
                    curr.PrimaryOpportunityCampaign__c = oppMap.get(curr.WhatId).CampaignId;
                    taskUpd.add(curr);
                } 
            }//end of for loop taskList
        }//end of if for taskList size
        
        
        //check if task List has values to update
        System.debug('*** taskUpd.size() *** ' + taskUpd.size() );
        if( taskUpd.size() > 0 ){
            System.debug('*** Updating task with Primary Opp Campaign *** ');
            Database.update(taskUpd,false);//update task with Primary Opportunity Value
        }//end if for size check
    }//end of oppPrimaryCampaignAdd
    
}//end of class