/*********************************************************************
* Description      : Controller Class for Pricing Portal Contract Process.
* Test Class       : PP_Build_Contract_Divisions_Test
* Author(s)        : Eric Clay
**********************************************************************/
global class PP_Contract_Header_Build_Divisions_Batch Implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;

        query = 'SELECT Id, Agreement_Number__c, Division_10__c, Division_20__c, Division_30__c, Division_40__c, ';
        query += 'Division_50__c, Division_60__c FROM Contract_Header__c';

        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){

        // Setup

        string div;
        string anum;
        boolean updateCH;

        list<Contract_Header__c> chList = (list<Contract_Header__c>)scope;
        list<Contract_Header__c> chUpdate = new list<Contract_Header__c>();

        set<String> chSet = new set<String>();

        map<String, Boolean> divMap = new map<String, Boolean>();

        // Start Work

        // Create a set of Agreement Numbers to use to filter our Contract Material aggregate
        for(Contract_Header__c ch : chList){
            chSet.add(ch.Agreement_Number__c);
            divMap.put(ch.Agreement_Number__c + '10', FALSE);
            divMap.put(ch.Agreement_Number__c + '20', FALSE);
            divMap.put(ch.Agreement_Number__c + '30', FALSE);
            divMap.put(ch.Agreement_Number__c + '40', FALSE);
            divMap.put(ch.Agreement_Number__c + '50', FALSE);
            divMap.put(ch.Agreement_Number__c + '60', FALSE);
        }

        // Aggregate Product Division in to a map
        for(AggregateResult ar : [SELECT Product__r.Division__c prod, Agreement_Number_Text__c
                                  FROM Contract_Material__c
                                  WHERE Agreement_Number_Text__c =:chSet
                                  GROUP BY Product__r.Division__c, Agreement_Number_Text__c])
        {
            div = (string) ar.get('prod');
            anum = (string) ar.get('Agreement_Number_Text__c');
            divMap.put(anum + div, TRUE);
        }
        system.debug('divMap: ' + divMap);

        // Finish up...
        for(Contract_Header__c ch : chList){
            updateCH = FALSE;
            Contract_Header__c newCH = new Contract_Header__c(
                Id = ch.Id
            );
            if(divMap.get(ch.Agreement_Number__c + '10') != ch.Division_10__c){
                newCH.Division_10__c = divMap.get(ch.Agreement_Number__c + '10');
                updateCH = TRUE;
            }
            if(divMap.get(ch.Agreement_Number__c + '20') != ch.Division_20__c){
                newCH.Division_20__c = divMap.get(ch.Agreement_Number__c + '20');
                updateCH = TRUE;
            }
            if(divMap.get(ch.Agreement_Number__c + '30') != ch.Division_30__c){
                newCH.Division_30__c = divMap.get(ch.Agreement_Number__c + '30');
                updateCH = TRUE;
            }
            if(divMap.get(ch.Agreement_Number__c + '40') != ch.Division_40__c){
                newCH.Division_40__c = divMap.get(ch.Agreement_Number__c + '40');
                updateCH = TRUE;
            }
            if(divMap.get(ch.Agreement_Number__c + '50') != ch.Division_50__c){
                newCH.Division_50__c = divMap.get(ch.Agreement_Number__c + '50');
                updateCH = TRUE;
            }
            if(divMap.get(ch.Agreement_Number__c + '60') != ch.Division_60__c){
                newCH.Division_60__c = divMap.get(ch.Agreement_Number__c + '60');
                updateCH = TRUE;
            }

            if(updateCH){
                chUpdate.add(newCH);
            }
        }
        if(chUpdate.size() > 0){
            system.debug('-- Updating CH with CM Divisions --' + chUpdate);
            update chUpdate;
        }


    }


    global void finish(Database.BatchableContext BC){
        //UserInfo.getUserEmail();
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Build Contracts Headers Finished: ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}