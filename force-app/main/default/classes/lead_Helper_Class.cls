public class lead_Helper_Class {

    public static void setProductOfInterestBefore(List<Lead> newTrigger){
        list<Lead> updateLeads = new list<Lead>();
        string poiList;
        string poi;
        boolean upd;

        for(Lead l : newTrigger){

            // Stage 1 - Determine if we need to do work
            if(l.Status == 'Qualified' && l.IsConverted == FALSE && Test.isRunningTest() == FALSE){
                l.addError('A qualified lead needs to be Converted. Please click “Cancel” then “Convert” to convert this lead to an Opportunity. Otherwise, choose a different status.');
            }//end if closedate check
            else{
                system.debug('Starting Product of Interest Class');
                if(l.Product_of_Interest__c != NULL || l.Product_of_Interest_GPL__c != NULL){
                    l.Product_of_Interest_Sort__c = l.Product_of_Interest_GPL__c;
                }
            }


        }//end of for loop
        system.debug('END Product of Interest Class');
    }

    public static void setProductOfInterest(List<Lead> newTrigger, Map<Id,Lead> oldTrigger,String type){
        list<Lead> updateLeads = new list<Lead>();
        string poiList;
        string poi;
        boolean upd;

        for(Lead l : newTrigger){

            if(l.Status == 'Qualified' && l.IsConverted == FALSE && Test.isRunningTest() == FALSE){
                l.addError('A qualified lead needs to be Converted. Please click “Cancel” then “Convert” to convert this lead to an Opportunity. Otherwise, choose a different status.');
            }//end if closedate check
            else{
                system.debug('Starting Product of Interest Class');
                upd = FALSE;
                if(type == 'insert' && (l.Product_of_Interest__c != NULL || l.Product_of_Interest_GPL__c != NULL)){
                    upd = TRUE;
                }
                // Check to see if the automation has never run or the values have changed.
                else if(
                    type == 'update' &&
                    l.Product_of_Interest_GPL__c != NULL &&
                    (oldTrigger.get(l.Id).Product_of_Interest_GPL__c != l.Product_of_Interest_GPL__c
                     || l.Product_of_Interest_Sort__c == NULL))
                {
                    upd = TRUE;
                    system.debug('Lets update!');
                }
                else if(
                    type == 'update' &&
                    l.Product_of_Interest__c != NULL &&
                    (oldTrigger.get(l.Id).Product_of_Interest__c != l.Product_of_Interest__c
                     || l.Product_of_Interest_Sort__c == NULL))
                {
                    upd = TRUE;
                    system.debug('Lets update!');
                }
                if(upd){
                    // Prioritize the New Field over the old
                    if(l.Product_of_Interest_GPL__c != NULL){
                        Lead uLead = new Lead(
                            Id = l.Id,
                            Product_of_Interest_Sort__c = l.Product_of_Interest_GPL__c
                        );
                        updateLeads.add(uLead);
                    }
                    else{
                        // Let's Alphabitize
                        poiList = l.Product_of_Interest__c;
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
                        Lead uLead = new Lead(
                            Id = l.Id,
                            Product_of_Interest_Sort__c = poi
                        );
                        updateLeads.add(uLead);
                    }

                }//end of if(upd)

                if(updateLeads.size() > 0){
                    system.debug('Updating Product of Interest Sort!');

                    try {
                        update updateLeads;
                    }
                    catch (Exception e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }

                }//end of if updateLeads.size
            }


        }//end of for loop
        system.debug('END Product of Interest Class');
    }//end of public static void setProductOfInterest

    public static void addZuantLead(list<Lead> newTrigger){
        list<CampaignMember> cmList = new list<CampaignMember>();
        set<Id> leadIds = new set<Id>();
        for(lead l : newTrigger){
            if(l.Campaign_External_Id__c != NULL){
                leadIds.add(l.Id);
            }
        }

        if(leadIds.size() > 0){
            map<Id,boolean> cmMap = new map<Id,boolean>();
            for(CampaignMember cm : [SELECT LeadId
                                    FROM CampaignMember
                                    WHERE LeadId =:leadIds])
            {
                cmMap.put(cm.LeadId, TRUE);
            }
            for(lead l : newTrigger){
                if(l.Campaign_External_Id__c != NULL && cmMap.get(l.Id) == NULL){
                    system.debug('-- We have Leads to add to a Zuant Campaign! --');
                    // Associate to the Campaign
                    CampaignMember cmAdd = new CampaignMember(
                        CampaignId = l.Campaign_External_Id__c,
                        LeadId = l.Id,
                        Status = 'Sent'
                    );
                    cmList.add(cmAdd);
                }
                if(cmList.size() > 0){
                    system.debug('-- Adding Leads to Zuant Campaign! --');
                    insert cmList;
                }
            }
        }

    } // End addZuantLead Class

    public static void leadCleanup(list<Lead> triggerNew){
        // All this class does is make sure that we delete leads that have URL's in the First Name -- Getting this about  10-30 times a day.
        // 10May2016 - ESC
        set<Id> fakeLeads = new set<Id>();
        //string fname;
        for(Lead l : triggerNew){
            if(l.SPAM_HTTP_Checker__c){
                fakeLeads.add(l.Id);
            }
            /*fname = l.FirstName;
            if(fname != NULL){
                fname = fname.left(4);
                if(fname == 'http'){

                }
            }*/
        }
        if(fakeLeads.size() > 0){
            delete [select Id from Lead where Id =:fakeLeads];
        }
    }//end of public static void leadCleanup

    public static void setNewProductTrackingBefore(List<Lead> newTrigger, Map<Id,Lead> oldTrigger,String type){
        // Test Class: lead_Helper_Class_Test
        list<String> poiList = new list<String>();
        list<Lead> updateList = new list<Lead>();

        set<Id> skipSet = new set<Id>();
        set<Id> addSet = new set<Id>();
        set<Lead> leadSet = new set<Lead>();
        set<String> nptFilter = new set<String>();

        map<Id, String> leadMap = new map<Id, String>();
        map<String, Id> nptMap = new map<String, Id>();

        string poiSting;
        string bu;
        string upperStr;
        string nptKey;

        for(Lead l : newTrigger){
            poiList.clear();
            poiSting = NULL;
            if(l.Product_of_Interest_GPL__c != NULL){
                poiSting = l.Product_of_Interest_GPL__c;
            }
            else if(l.Product_Family_LatAm__c != NULL){
                poiSting = l.Product_of_Interest_LatAm__c;
            }
            else if(l.Product_of_Interest__c != NULL){
                poiSting = l.Product_of_Interest__c;
            }
            if(poiSting != NULL && l.Business_Unit__c != NULL){ // Check to make sure Product of Interest and BU have values
                if(
                    type == 'insert' // Always fires for new records
                   || (type == 'update' && l.New_Product_Tracking__c == NULL) // Fires if it's an update without a related New Product Tracking Record
                   || (type == 'update' && oldTrigger.get(l.Id).Product_of_Interest_Reporting__c != l.Product_of_Interest_Reporting__c) // Fires if Product of Interest Changes
                   || (type == 'update' && oldTrigger.get(l.Id).Business_Unit__c != l.Business_Unit__c) // Fires if the BU Changes
                  ){
                      bu = l.Business_Unit__c;
                      if(bu.left(8) == 'Surgical'){ // Hack for the Surgical BU names
                          bu = 'Surgical';
                      }
                      bu = bu.toUpperCase();

                      if(poiSting.contains(';')){ // If multi-select break out the string in to a list
                          poiList = poiSting.split(';');
                      }
                      else{ // Else add the single value to the list
                          poiList.add(poiSting);
                      }

                      for(string s : poiList){
                          nptKey = s;
                          nptKey = nptKey.toUpperCase();
                          nptKey = bu + '-' + nptKey;
                          nptFilter.add(nptKey);
                          leadSet.add(l);
                      }
                }
            }
        }
        // Round 1 - Matches
        // Takes the first matching rule and adds it to the Lead. Also removes the lead from the map and adds
        // the id to a set so that the matching value gets written.
        if(nptFilter.size() > 0){
            for(New_Product_Tracking_Rule__c r : [SELECT New_Product_Tracking__c, Key__c
                                                  FROM New_Product_Tracking_Rule__c
                                                  WHERE Key__c =:nptFilter
                                                  AND IsProductOfInterest__c = TRUE])
            {
                nptKey = r.Key__c;
                nptKey = nptKey.toUpperCase();
                system.debug('nptKey: ' + nptKey);
                nptMap.put(nptKey, r.New_Product_Tracking__c);
            }
        }
        system.debug('nptMap: ' + nptMap);
        // Round 2 - Clean Up
        // If there's anything left in the map then the New Product Tracking field needs to be set to NULL so that
        // the current value is removed as there was no matching rule found for the new BU and Product Family Combo

        for(Lead l : leadSet){
            bu = l.Business_Unit__c;
            if(bu.left(8) == 'Surgical'){ // Hack for the Surgical BU names
                bu = 'Surgical';
            }
            bu = bu.toUpperCase();

            poiList.clear();
            poiSting = NULL;
            if(l.Product_of_Interest_GPL__c != NULL){
                poiSting = l.Product_of_Interest_GPL__c;
            }
            else if(l.Product_Family_LatAm__c != NULL){
                poiSting = l.Product_of_Interest_LatAm__c;
            }
            else if(l.Product_of_Interest__c != NULL){
                poiSting = l.Product_of_Interest__c;
            }

            if(poiSting.contains(';')){ // If multi-select break out the string in to a list
                poiList = poiSting.split(';');
            }
            else{ // Else add the single value to the list
                poiList.add(poiSting);
            }


            for(string s : poiList){
                nptKey = s;
                nptKey = nptKey.toUpperCase();
                nptKey = bu + '-' + nptKey;

                if(nptMap.containsKey(nptKey) && !addSet.contains(l.Id)){
                    l.New_Product_Tracking__c = nptMap.get(nptKey);

                    // This is a method to check whether to remove NPT from an opp due to data or rule changes.
                    // Because of multi-select we have to do a little more work.
                    addSet.add(l.Id);
                }
                else{
                    // Add to the remove set if the Opportunity is not already in the 'Add' Set and NPT is set
                    if(!addSet.contains(l.Id) && l.New_Product_Tracking__c != NULL){
                        l.New_Product_Tracking__c = NULL;
                    }
                }
            }
        }
    }// end of public static void setNewProductTrackingBefore

    //method updates an Eloqua Task owner to the owner of the lead
    public static void eloquaTaskUpdate(List<Lead> newTrigger, Map<Id,Lead> oldTrigger){
      System.debug('*** STARTING eloquaTaskUpdate ***');
      List<String> leadIds = new List<String>();
      Map<String,String> taskMap = new Map<String,String>();
      List<Task> taskList = new List<Task>();
      List<Task> taskToUpdate = new List<Task>();
      String elqSubject = NULL;
      String whoType = NULL;

      //loop to get Ids for leads
      for(Lead curr: newTrigger){
        //if(curr.ownerId != oldTrigger.get(curr.Id).ownerId){
          leadIds.add(curr.Id);
          taskMap.put(curr.Id,curr.OwnerId);
        //}
      }//end of for loop

      //get task based on lead ids
      taskList = [SELECT Id, Subject, Status, Who.Id, Who.Type FROM Task WHERE WhoId IN :leadIds];

      //loop to check subject for Eloqua tasks
      for(Task curr : taskList){
        //check subject for elq-sample prefix
        elqSubject = curr.Subject;
        whoType = curr.Who.Type;
        if(elqSubject != NULL){
            if(elqSubject.containsIgnoreCase('Elq-Sample') && whoType == 'Lead'){
              System.debug('*** elqSubject *** ' + elqSubject);
              System.debug('*** whoType *** ' + whoType);
              curr.OwnerId = taskMap.get(curr.Who.Id);
              taskToUpdate.add(curr);
            }//end of inner if statement
        }//end outter if 

      }//end of task Subject check

      System.debug('*** taskToUpdate.size() *** ' + taskToUpdate.size());
      System.debug('*** taskToUpdate *** ' + taskToUpdate);
      //update task to match lead owner change
      Database.update(taskToUpdate,false);
      System.debug('*** ENDING eloquaTaskUpdate ***');
    }//end of eloquaTaskUpdate

    public static void ezioWebRouting(List<Lead> triggerNew){
        String leadDesc = NULL; //string to hold description for comparison
        String campId = NULL;
        CampaignMember mem = new CampaignMember(); //campaign member record object
        List<CampaignMember> memList = new List<CampaignMember>();
        
        
        try{
            //SOQL to get campaignId
            campId = [SELECT Id FROM Campaign WHERE Name =: 'EZ-IO - Website request for information' LIMIT 1].Id;
            //loop thru list of records
            for(Lead curr : triggerNew){
                if(curr.Primary_Campaign__c==null || curr.Primary_Campaign__c!='EZ-IO - Website request for information'){
                    System.debug(' Printing Campaign Name for each lead '+curr.Primary_Campaign__c);
                    System.debug(' Printing Campaign Id for each lead '+curr.Campaign_Membership_ID__c);
                    continue;
                } else{
                leadDesc = curr.Description;
                //logic to assign campaign
                if(leadDesc != NULL){
                    if(leadDesc.containsIgnoreCase('EZ-IO Webpage Lead Inquiry')){
                        mem.campaignid = campId;
                        mem.leadid = curr.id;
                        memList.add(mem); //add member object to list
                        System.debug('*** Member Id *** '+mem.leadid);
                        System.debug('*** Campaign Id *** '+mem.campaignid);
                    }//end if
                }//end of outter if
                
                //check member list size for insert try
                if( memList.size() > 0 ){
                    System.debug('*** memList has record *** ');
                    System.debug('*** memList *** ' + memList);
                    database.insert(memList,false);
                }
            }//end of else condition
              //end of adding lead to campaign
            }//end of for loop
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }//end try/catch block
        
    }//end of ezioWebRouting
    
    /*
    Created to control routing of leads from On24 for TEM/EMS Teams.  Leads only created for customers who wish
    to be contacted.  Any other information should be created as Contacts.
    */
    public static void on24Routing(List<Lead> newTrigger){
        //get queueId for EMS ON24 Leads
        for(Lead lead:newTrigger){
            if(lead.LeadSource!=null){
            Lead_Settings__c lds=Lead_Settings__c.getValues(lead.LeadSource);
            System.debug('*** custom settings lds *** '  + lds);
             if(lds!=NULL){
                System.debug('*** going *** '  + lds);
                if(lead.LeadSource==lds.LeadSource__c && lead.Contact_Local_Teleflex_Rep__c=='No'){
                    System.debug('*** LeadSource is TEM/EMS On24/VasOn24 ***');
                    Lead_Settings__c ldsQId=Lead_Settings__c.getInstance(lead.LeadSource);
                        
                        lead.Status='Unqualified';
                        lead.Reason_Lead_is_Unqualified_Picklist__c = 'Other';
                        lead.Reason_lead_is_Unqualified__c = 'ON24 Attendee';
                        lead.OwnerId=ldsQId.LeadQuequeId__c;
                        System.debug('*** lead owner Id*** '  + lead.OwnerId);
                        lead.LeadSource=lds.LeadSource__c;
                        lead.Business_Unit__c=lds.Business_Unit__c;
                        lead.Zip_Code_Auto_Route__c=true;
                        //lead.Business_Unit_GPL__c=lds.Business_Unit__c;
                        System.debug('*** curr.LeadSource *** '  + lead.LeadSource);
                } 
            } 
        
        // String queueId = [SELECT Id, QueueId, Queue.Name FROM QueueSobject WHERE Queue.Name = 'TEM ON24 Leads'].QueueId;
        //        for(Lead curr : newTrigger){
		// 	//logic to check for EMS On24 information
        //     if(curr.LeadSource == 'EMS On24' || curr.LeadSource == 'TEM ON24'){
        //         System.debug('*** LeadSource is TEM/EMS On24 ***');
        //         System.debug('*** curr.LeadSource *** '  + curr.LeadSource);
        //         String leadSourceChange = 'TEM ON24';
                
        //         /*check field specific to EMS On24 setup
        //          * if NO create a contact and abort lead creation
        //          * if yes allow lead to be created */
        //         if(curr.Contact_Local_Teleflex_Rep__c == 'No'){
        //             //unqualify lead and assign to EMS ON24 Leads queue
        //             curr.Zip_Code_Auto_Route__c = TRUE;
        //             curr.Status = 'Unqualified';
        //             curr.Reason_Lead_is_Unqualified_Picklist__c = 'Other';
        //             curr.Reason_lead_is_Unqualified__c = 'ON24 Attendee';
        //             curr.OwnerId = queueId;
        //             curr.LeadSource = leadSourceChange;
        //             curr.Zip_Code_Auto_Route__c = true;
             // }//end if Contact Local
           }//end if TEM On24
        
         }//end of for loop
    
        }// End On24Routing
    
    /* Using the setNewProductTrackingBefore method now... 22Nov2017 - ESC
    public static void setNewProductTracking(List<Lead> newTrigger, Map<Id,Lead> oldTrigger,String type){
        // Test Class:
        list<String> poiList = new list<String>();
        list<Lead> updateList = new list<Lead>();

        set<Id> skipSet = new set<Id>();
        set<Id> addSet = new set<Id>();
        set<Lead> leadSet = new set<Lead>();
        set<String> nptFilter = new set<String>();

        map<Id, String> leadMap = new map<Id, String>();
        map<String, Id> nptMap = new map<String, Id>();

        string poiSting;
        string bu;
        string upperStr;
        string nptKey;

        for(Lead l : newTrigger){
            poiList.clear();
            poiSting = NULL;
            if(l.Product_of_Interest_GPL__c != NULL){
                poiSting = l.Product_of_Interest_GPL__c;
            }
            else if(l.Product_Family_LatAm__c != NULL){
                poiSting = l.Product_of_Interest_LatAm__c;
            }
            else if(l.Product_of_Interest__c != NULL){
                poiSting = l.Product_of_Interest__c;
            }
            if(poiSting != NULL && l.Business_Unit__c != NULL){ // Check to make sure Product of Interest and BU have values
                if(
                    type == 'insert' // Always fires for new records
                   || (type == 'update' && l.New_Product_Tracking__c == NULL) // Fires if it's an update without a related New Product Tracking Record
                   || (type == 'update' && oldTrigger.get(l.Id).Product_of_Interest_Reporting__c != l.Product_of_Interest_Reporting__c) // Fires if Product of Interest Changes
                   || (type == 'update' && oldTrigger.get(l.Id).Business_Unit__c != l.Business_Unit__c) // Fires if the BU Changes
                  ){
                      bu = l.Business_Unit__c;
                      if(bu.left(8) == 'Surgical'){ // Hack for the Surgical BU names
                          bu = 'Surgical';
                      }
                      bu = bu.toUpperCase();

                      if(poiSting.contains(';')){ // If multi-select break out the string in to a list
                          poiList = poiSting.split(';');
                      }
                      else{ // Else add the single value to the list
                          poiList.add(poiSting);
                      }

                      for(string s : poiList){
                          nptKey = s;
                          nptKey = nptKey.toUpperCase();
                          nptKey = bu + '-' + nptKey;
                          nptFilter.add(nptKey);
                          leadSet.add(l);
                      }
                }
            }
        }
        // Round 1 - Matches
        // Takes the first matching rule and adds it to the Lead. Also removes the lead from the map and adds
        // the id to a set so that the matching value gets written.
        if(nptFilter.size() > 0){
            for(New_Product_Tracking_Rule__c r : [SELECT New_Product_Tracking__c, Key__c
                                                  FROM New_Product_Tracking_Rule__c
                                                  WHERE Key__c =:nptFilter
                                                  AND IsProductOfInterest__c = TRUE])
            {
                nptKey = r.Key__c;
                nptKey = nptKey.toUpperCase();
                system.debug('nptKey: ' + nptKey);
                nptMap.put(nptKey, r.New_Product_Tracking__c);
            }
        }
        system.debug('nptMap: ' + nptMap);
        // Round 2 - Clean Up
        // If there's anything left in the map then the New Product Tracking field needs to be set to NULL so that
        // the current value is removed as there was no matching rule found for the new BU and Product Family Combo

        for(Lead l : leadSet){
            bu = l.Business_Unit__c;
            if(bu.left(8) == 'Surgical'){ // Hack for the Surgical BU names
                bu = 'Surgical';
            }
            bu = bu.toUpperCase();

            poiList.clear();
            poiSting = NULL;
            if(l.Product_of_Interest_GPL__c != NULL){
                poiSting = l.Product_of_Interest_GPL__c;
            }
            else if(l.Product_Family_LatAm__c != NULL){
                poiSting = l.Product_of_Interest_LatAm__c;
            }
            else if(l.Product_of_Interest__c != NULL){
                poiSting = l.Product_of_Interest__c;
            }

            if(poiSting.contains(';')){ // If multi-select break out the string in to a list
                poiList = poiSting.split(';');
            }
            else{ // Else add the single value to the list
                poiList.add(poiSting);
            }


            for(string s : poiList){
                nptKey = s;
                nptKey = nptKey.toUpperCase();
                nptKey = bu + '-' + nptKey;

//                if(nptMap.containsKey(nptKey) && !addSet.contains(l.Id)){
                if(nptMap.containsKey(nptKey) && !addSet.contains(l.Id)){
                    Lead newLead = new Lead(
                        Id = l.Id,
                        New_Product_Tracking__c = nptMap.get(nptKey)
                    );
                    updateList.add(newLead);

                    // This is a method to check whether to remove NPT from an opp due to data or rule changes.
                    // Because of multi-select we have to do a little more work.
                    addSet.add(l.Id);
                    if(skipSet.contains(l.Id)){
                        skipSet.remove(l.Id);
                        system.debug('Removing: ' + l.Id);
                    }
                }
                else{
                    // Add to the remove set if the Opportunity is not already in the 'Add' Set and NPT is set
                    if(!addSet.contains(l.Id) && l.New_Product_Tracking__c != NULL){
                        skipSet.add(l.Id);
                        system.debug('Adding: ' + l.Id);
                    }
                }
            }
        }

        for(Id l : skipSet){
            if(!addSet.contains(l)){
                Lead newLead = new Lead(
                    Id = l,
                    New_Product_Tracking__c = NULL
                );
                system.debug('Removing! ' + newLead);
                updateList.add(newLead);
            }
        }

        // Write the records!
        if(updateList.size() > 0){
            update updateList;
        }
    }*/
}