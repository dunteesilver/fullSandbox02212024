public class PP_Price_Quote_Helper_Class {
    // Classes related to the Price Quote Trigger: master_Price_Quote

    public static void autoCreateNewOpp(list<Price_Quote__c> newTrigger){

        Map<String, Business_Unit__c> buMap = Business_Unit__c.getAll();
        list<Price_Quote__c> pqList = new list<Price_Quote__c>();

        for(Price_Quote__c pq : newTrigger){
            if(buMap.get(pq.Owner_Business_Unit__c) != NULL){
                if(buMap.get(pq.Owner_Business_Unit__c).Auto_Create_Opportunity__c && pq.Opportunity__c == NULL){
                    pqList.add(pq);
                }
            }
        }
        if(pqList.size() > 0){
            PP_Price_Quote_Helper_Class.createOpp(pqList);
        }
    }
    /* This has been disabled in the trigger
    public static void fixSalesDealLookup(list<Price_Quote_Line_Item__c> newTrigger){

        set<String> chSet = new set<String>();
        map<String, Id> chMap = new map<String, Id>();

        for(Price_Quote_Line_Item__c pqli: newTrigger){
            if(pqli.Sales_Deal__c == NULL && pqli.Sales_Number__c != NULL){
                chSet.add(pqli.Sales_Number__c);
            }
        }
        //system.debug('chSet: ' + chSet);
        if(chSet.size() > 0){
            for(Contract_Header__c ch : [SELECT Id, Agreement_Number__c
                                         FROM Contract_Header__c
                                         WHERE Agreement_Number__c = :chSet])
            {
                chMap.put(ch.Agreement_Number__c, ch.Id);
            }
            //system.debug('chMap: ' + chMap);
            if(chMap.size() > 0){
                for(Price_Quote_Line_Item__c pqli: newTrigger){
                    if(pqli.Sales_Deal__c == NULL &&
                       pqli.Sales_Number__c != NULL &&
                       chMap.containsKey(pqli.Sales_Number__c)){
                        pqli.Sales_Deal__c = chMap.get(pqli.Sales_Number__c);
                    }
                }
            }
        }

    }*/

    public static void createOpp(List<Price_Quote__c> pqList){
        // Pulled this logic out of 'newCreateOpp' pagereference class so that i could call it from another class. - ESC - 23Jun2016
        Map<String, Business_Unit__c> buMap = Business_Unit__c.getAll();
        list<Opportunity> insOpp = new list<Opportunity>();
        list<Price_Quote__c> updatePQ = new list<Price_Quote__c>();
        string userbu;

        for(Price_Quote__c pq : pqList){
            if(pq.Opportunity__c == NULL){
                Opportunity newOpp = new Opportunity(
                    Name=pq.Price_Quote_Name__c,
                    CloseDate=pq.Expiration_Date__c,
                    AccountId=pq.Account_Name__c,
                    Primary_Contact__c=pq.Contact_Name__c,
                    Amount=pq.Grand_Total__c,
                    Product_Family__c='Please Update...',
                    Product_Family_LatAm__c='Please Update...',
                    Price_Quote__c=pq.Id,
                    One_Time_Sale__c = pq.One_Time_Purchase__c,
                    OwnerId=pq.Owner_Id__c,
                    CurrencyIsoCode =pq.CurrencyIsoCode
                );

                userbu = pq.Owner_Business_Unit__c;

                for(RecordType rt : [SELECT Id, DeveloperName
                                     FROM RecordType
                                     WHERE SobjectType = 'Opportunity'])
                {
                    if(pq.Owner_Business_Unit__c == 'Anesthesia' && rt.DeveloperName == 'Anesthesia_Opportunity'){
                        newOpp.RecordTypeId = rt.Id;
                    }
                    else if(pq.Owner_Business_Unit__c == 'EMS' && rt.DeveloperName == 'Anesthesia_Opportunity'){
                        newOpp.RecordTypeId = rt.Id;
                    }
                    else if(pq.Owner_Business_Unit__c != 'Vascular' && pq.Owner_Business_Unit__c != 'Anesthesia' && pq.Owner_Business_Unit__c != 'EMS' &&rt.DeveloperName == 'Teleflex_Standard_Opportunity'){
                        newOpp.RecordTypeId = rt.Id;
                    }
                    else if(pq.Owner_Business_Unit__c == 'Vascular' && rt.DeveloperName == 'Vascular_Sales_NA'){
                        newOpp.RecordTypeId = rt.Id;
                    }
                }
            
                if(buMap.containsKey(userbu)){
                    //newOpp.RecordTypeId = buMap.get(userbu).RecordType_Id__c;

                    if(buMap.get(userbu).Opportunity_Initial_Stage__c != NULL){
                        newOpp.StageName = buMap.get(userbu).Opportunity_Initial_Stage__c;
                    }
                    else{
                        newOpp.StageName = 'Qualified Prospect';
                    }
                }
                else{
                    newOpp.StageName = 'Qualified Prospect';
                }
                insOpp.add(newOpp);
            }

        }
        if(insOpp.size() > 0){
            insert insOpp;
        }

        for(Opportunity o : insOpp){
            Price_Quote__c pqUpdate = new Price_Quote__c(
                Id = o.Price_Quote__c,
                Opportunity__c = o.Id
            );
            updatePQ.add(pqUpdate);
        }

        if(updatePQ.size() > 0){
            update updatePQ;
        }

        /*if(newOpp != NULL){
            insert newOpp;

            pq.Opportunity__c = newOpp.Id;
            update pq;
        }*/
        //updatePQ
    }

    public static void setPQDefaults(list<Price_Quote__c> newTrigger, map<Id, Price_Quote__c> oldTrigger, string triggerType){

        // Test Class: PP_Global_Test_Class
        string ownerBU;

        Map<String, Quote_Logos__c> logoMap = Quote_Logos__c.getAll();
        Map<String, Business_Unit__c> buMap = Business_Unit__c.getAll();

        if(triggerType == 'insert'){
            for(Price_Quote__c pq : newTrigger){
                if(pq.Owner_Business_Unit__c != NULL){
                    ownerBU = pq.Owner_Business_Unit__c;

                    // Sets the Default Stationary based on the users business unit set at the user verifies that there
                    // is a template already set up for that BU using the 'Quote Logo' custom setting.
                    if(logoMap.containsKey(ownerBU)){
                        system.debug('Updating the Stationary: ' + pq.Stationary__c);
                        pq.Stationary__c = pq.Owner_Business_Unit__c;
                    }
                    else{
                        if(ownerBU == 'Interventional Capital'){
                            ownerBU = 'Cardiac';
                        }
                        else if(ownerBU == 'Surgical Disposables' || ownerBU == 'Surgical Instruments'){
                            ownerBU = 'Surgical';
                        }

                        // Second Bite at the Apple
                        if(logoMap.containsKey(ownerBU)){
                            system.debug('Updating the Stationary: ' + pq.Stationary__c);
                            pq.Stationary__c = ownerBU;
                        }
                        else{
                            system.debug('Setting the Stationary to Teleflex Standard');
                            pq.Stationary__c = 'Standard Teleflex';
                        }
                    }
                }

                // Sets the 'One Time Purchase' checkbox if set to TRUE
                boolean cloneQuote = FALSE;
                if(pq.How_Created__c != NULL && pq.How_Created__c.containsIgnoreCase('Quote Cloned') == TRUE){
                    cloneQuote = TRUE;
                }

                //if(buMap.get(pq.Owner_Business_Unit__c) != NULL && !pq.How_Created__c.containsIgnoreCase('Quote Cloned')){
                if(buMap.get(pq.Owner_Business_Unit__c) != NULL && !cloneQuote){
                    pq.One_Time_Purchase__c = buMap.get(pq.Owner_Business_Unit__c).Opportunity_One_Time_Purchase__c;
                }
            }
        }
        else{
            list<Price_Quote__c> pqUpdate = new list<Price_Quote__c>();
            list<Price_Quote_Line_Item__c> pqliUpdate = new list<Price_Quote_Line_Item__c>();
            List<Approval.ProcessSubmitRequest> requestList = new List<Approval.ProcessSubmitRequest> ();
            map<Id, Decimal> pqApprovalMap = new map<Id, Decimal>();
            for(Price_Quote__c pq : newTrigger){
                // Sets the default stationary based on Custom Setting on Owner Change
                Price_Quote__c pqRec = new Price_Quote__c();
                if(oldTrigger.get(pq.Id).OwnerId != pq.OwnerId){
                    pqRec.Id = pq.Id;
                    if(logoMap.get(pq.Owner_Business_Unit__c) != NULL){
                        pqRec.Stationary__c = pq.Owner_Business_Unit__c;
                    }
                    else{
                        pqRec.Stationary__c = 'Standard Teleflex';
                    }
                }
                // This Looks to Update the Related Price Quote Line Items if the Owner Level Changes
                if(pq.Workflow_Owner_Approval_Level__c != pq.Owner_Approval_Level__c){
                    pqRec.Id = pq.Id;
                    pqRec.Owner_Approval_Level__c = pq.Workflow_Owner_Approval_Level__c;
                    pqApprovalMap.put(pq.Id, pq.Workflow_Owner_Approval_Level__c);
                }
                if(pqRec.Id != NULL){
                    pqUpdate.add(pqRec);
                }

                // Submits PQ for Approval - Cardiac Support
                System.debug('Starting: Approval Call');
                if(pq.Status__c == 'Ready for Approval'){
                    //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ProcessSubmitRequest.htm#apex_ProcessSubmitRequest
                    Approval.ProcessSubmitRequest addRequest = new Approval.ProcessSubmitRequest();
                    addRequest.setObjectId(pq.id);
                    addRequest.setSubmitterId(pq.OwnerId);
                    requestList.add(addRequest);
                }
                // END Approval Sumit

            } // End of FOR Loop

            system.debug('pqApprovalMap: ' + pqApprovalMap);

            // Creates the Update for the Price Quote Line Items if there was a change of owner and level of approval.
            for(Price_Quote_Line_Item__c  pqli : [SELECT Id,Price_Quote__c FROM Price_Quote_Line_Item__c
                                                  WHERE Price_Quote__c =:pqApprovalMap.keySet()])
            {
                system.debug('Updating Lines!');
                if(pqApprovalMap.get(pqli.Price_Quote__c) != NULL){
                    Price_Quote_Line_Item__c pqliNew = new Price_Quote_Line_Item__c(
                        Id = pqli.Id,
                        Owner_Approval_Level__c = pqApprovalMap.get(pqli.Id)
                    );
                    pqliUpdate.add(pqliNew);
                }
            }

            if(pqUpdate.size() > 0){
                update pqUpdate;
            }

            if(pqliUpdate.size() > 0){
                system.debug('Updating Lines List!');
                update pqliUpdate;
            }

            if(requestList.size() > 0){
                Approval.ProcessResult[] processResults = NULL;
                processResults = Approval.process(requestList, TRUE);
            }
        }
    }

    public static void checkSalesOrg(list<Price_Quote__c> newTrigger){
        system.debug('-- Starting the Check Sales Org (checkSalesOrg) --');
        set<id> uid = new set<id>();
        list<Price_Quote__c> pqList = new list<Price_Quote__c>();

        for(Price_Quote__c pq : newTrigger){
            if(pq.Sales_Org_Key__c == NULL){
                if(pq.CreatedById != NULL){
                    uid.add(pq.CreatedById);
                }
                else{
                    uid.add(userinfo.getUserId());
                }
                pqList.add(pq);
                system.debug('Adding Key! ' + uid);
            }
        }

        if(pqList.size() > 0){
            map<id, string> soMap = new map<id, string>();
            Id userId;

            for(Contract_User__c cu : [SELECT User__r.Id, Active_Sales_Org_Key__c
                                       FROM Contract_User__c
                                       WHERE User__r.Id = :uid])
            {
                if(cu.Active_Sales_Org_Key__c != NULL){
                    soMap.put(cu.User__r.Id, cu.Active_Sales_Org_Key__c);
                }

            }

            for(Price_Quote__c pq : pqList){
                if(pq.CreatedById != NULL){
                    userId = pq.CreatedById;
                }
                else{
                    userId = userinfo.getUserId();
                }
                if(soMap.containsKey(userId)){
                    pq.Sales_Org_Key__c = soMap.get(userId);
                    system.debug('Fixed the Key! ' + soMap.get(userId));
                }
            }
        }
    }

/*
    public static void assignApprover(List<Price_Quote__c> newTrigger,Map<Id,Price_Quote__c> oldTrigger){
      system.debug('newTrigger[0].Status__c *** ' + newTrigger[0].Status__c);
      //logic to map bu name to queue Id
      List<Business_Unit__c> buList = Business_Unit__c.getall().values();
      Map<String, String> buSettings = new Map<String, String>();
      List<Price_Quote__c> updQuotes = new List<Price_Quote__c>();

      for(Business_Unit__c curr : buList){
        buSettings.put(curr.Name, curr.Queue_Id__c);
      }

      List<Id> ids = new List<Id>();
      List<Id> appIds = new List<Id>();
      List<Price_Quote__c> appQuotes = new List<Price_Quote__c>();
      List<ProcessInstanceWorkitem> updApprover = new List<ProcessInstanceWorkitem>();
      Map<Id,String> buMap = new Map<Id,String>();

      List<ProcessInstance> instanceCheck = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =:newTrigger[0].Id];
      List<ProcessInstanceStep> stepCheck = [SELECT Id FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId =:newTrigger[0].Id];
      List<ProcessInstanceWorkitem> itemCheck = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =:newTrigger[0].Id];
      system.debug('instanceCheck.size() *** ' + instanceCheck.size());
      system.debug('stepCheck.size() *** ' + stepCheck.size());
      system.debug('itemCheck.size() *** ' + itemCheck.size());

      for(Price_Quote__c curr : newTrigger){
        system.debug('oldTrigger.get(curr.Id).Status__c *** ' + oldTrigger.get(curr.Id).Status__c);
        system.debug('curr.Status__c *** ' + curr.Status__c);

        if(oldTrigger.get(curr.Id).Current_Approver__c != curr.Current_Approver__c && curr.Re_route__c == true){
            ids.add(curr.Id);
            buMap.put(curr.Id,buSettings.get(curr.Owner_Business_Unit__c));
        }
      }//end of for loop
      //update updQuotes;

      system.debug('*** ids *** ' + ids);

      for(ProcessInstanceWorkitem curr : [SELECT ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActorId, Id, ActorId
          FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :ids]){
        system.debug('buMap.get(curr.ProcessInstance.TargetObjectId) *** ' + buMap.get(curr.ProcessInstance.TargetObjectId));

        curr.OriginalActorId = buMap.get(curr.ProcessInstance.TargetObjectId);
        curr.ActorId = buMap.get(curr.ProcessInstance.TargetObjectId);
        updApprover.add(curr);

      }//end of for loop ProcessInstanceStep
      update updApprover;
    }//end of assignApprover method
*/
}