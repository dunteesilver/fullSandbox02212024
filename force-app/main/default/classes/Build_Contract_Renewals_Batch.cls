/*********************************************************************
* Description      : Batch Class for building contract renewal records.
* Test Class       : Contract_Renewal_Test
* Author(s)        : Eric Clay
**********************************************************************/
global class Build_Contract_Renewals_Batch Implements Database.Batchable<sObject> {
    //Test Class: Invoiced_Global_Test_Class

    global Database.QueryLocator start(Database.BatchableContext BC){
        //integer isrowcount = [SELECT count() FROM Invoiced_Sales__c WHERE LastModifiedDate != TODAY];
        String query;

        query = 'SELECT Id, Agreement_Number__c, Description__c, GPO_Contract_Ref__c, Valid_From__c,';
        query += ' Valid_To__c, Objective__c, Objective_Name__c, Owner__c, Owner_Name__c,';
        query += 'Material_Count__c, Account_Count__c, Distribution_Channel__c, Group__c, Sales_Org__c, Sub_Group__c ';
        //query += 'FROM Contract_Header__c WHERE Valid_To__c = NEXT_N_MONTHS:2 AND Valid_To__c != NEXT_MONTH ';
        query += 'FROM Contract_Header__c WHERE Valid_To__c = NEXT_90_DAYS ';
        query += 'AND Contract_Renewal_Eligible__c = TRUE ';
        //query += 'AND Active__c = TRUE AND Agreement_Number__c NOT IN (SELECT Agreement_Number__c FROM Contract_Renewal__c)'; // + keySet;
        query += ' ORDER BY Agreement_Number__c';

        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){

        decimal sales;
        string sd;
        string sap;
        string tnum;
        string tnumber;
        string prod;
        string rsmTnum;


        set<Id> chId = new set<Id>();
        set<String> rsmSet = new set<String>();

        map<String, Decimal> crsalesMap = new map<String, Decimal>();
        map<String, String> terNumMap = new map<String, String>();
        map<String, Territory_User__c> terLookupMap = new map<String, Territory_User__c>();
        map<String, Id> crIdMap = new map<String, Id>();
        map<Id, Id> crMap = new map<Id, Id>();

        list<Contract_Renewal__c> crList = new list<Contract_Renewal__c>();
        list<Contract_Renewal_Item__c> criList = new list<Contract_Renewal_Item__c>();
        List<Contract_Header__c> ccList = (List<Contract_Header__c>)scope;

        Id contractsGroupId = [SELECT QueueId FROM QueueSobject WHERE queue.Name = 'Contracts Team' and SobjectType = 'Contract_Renewal__c' LIMIT 1].QueueId;

        // Add Id for creating an Id Map for capturing changes and Upserting
        // Add Contract Header ID to a Set that will be used to pull Invoiced Sales records
        for(Contract_Header__c ch : ccList){
            chId.add(ch.Id);
        }
        for(Contract_Renewal__c cr : [SELECT Id, Agreement_Number__c
                                      FROM Contract_Renewal__c
                                      WHERE Contract_Header__c =:chId])
        {
            crIdMap.put(cr.Agreement_Number__c, cr.Id);
        }

        // Ok enough prep work - Let's get to work...

        for(Contract_Header__c ch : ccList)
        {
            Contract_Renewal__c	crNew = new Contract_Renewal__c(
                Contract_Header__c = ch.Id,
                Status__c = 'New',
                Agreement_Number__c = ch.Agreement_Number__c,
                Contract_Description__c = ch.Description__c,
                Distribution_Channel__c = ch.Distribution_Channel__c,
                GPO_Contract_Ref__c = ch.GPO_Contract_Ref__c,
                Group__c = ch.Group__c,
                Material_Count__c = ch.Material_Count__c,
                Account_Count__c = ch.Account_Count__c,
                Objective__c = ch.Objective__c,
                Owner__c = ch.Owner__c,
                Owner_Name__c = ch.Owner_Name__c,
                Sales__c = 0,
                Sales_Org__c = ch.Sales_Org__c,
                Sub_Group__c = ch.Sub_Group__c,
                Valid_From__c = ch.Valid_From__c,
                Valid_To__c = ch.Valid_To__c
            );
            if(crIdMap.containsKey(ch.Agreement_Number__c)){
                crNew.Id = crIdMap.get(ch.Agreement_Number__c);
            }
            crList.add(crNew); // Write the Records! - If the ID exists update the records else insert the records
        }

        if(chId.size() > 0){
            // Create the Sales Map

            for(AggregateResult ar : [SELECT Territory_Number__c, Sales_Deal__c, SUM(Sales__c) Sales
                                      FROM Invoiced_Sales__c
                                      WHERE Contract_Header__c = :chId
                                      AND Date__c = LAST_N_MONTHS:12
                                      GROUP BY Territory_Number__c, Sales_Deal__c])
            {
                sales = (decimal) ar.get('Sales');
                sd = (string) ar.get('Sales_Deal__c');
                tnum = (string) ar.get('Territory_Number__c');

                crsalesMap.put(sd, sales);
                if(tnum != '#'){
                    terNumMap.put(sd, tnum);
                }
                else{
                    terNumMap.put(sd, '#');
                }
            }

            // We are going to try and guess the Territory this Contract is related to.
            for(Territory_User__c tu : [SELECT ID, Business_Unit__c, User__c, Territory_Number__c, Territory_Master__r.Region_Number__c
                                        FROM Territory_User__c
                                        WHERE Territory_Number__c =:terNumMap.values()
                                        AND User_Active__c = TRUE])
            {
                if(tu.Business_Unit__c != NULL){
                    terLookupMap.put(tu.Territory_Number__c , tu);
                }
                rsmSet.add(tu.Territory_Master__r.Region_Number__c);

            }
            system.debug('rsmSet: ' + rsmSet);

            // Let's get the RSM while we're at it!
            for(Territory_User__c tu : [SELECT ID, Business_Unit__c, User__c, Territory_Number__c
                                        FROM Territory_User__c
                                        WHERE Territory_Number__c =:rsmSet
                                        AND User_Active__c = TRUE])
            {
                terLookupMap.put('RSM'+tu.Territory_Number__c , tu);
                system.debug('Adding RSM: ' + tu.Territory_Number__c);
            }

            for(Contract_Renewal__c cr : crList){
                // Pull in Sales from the Sales Map
                if(crsalesMap.get(cr.Agreement_Number__c) != NULL){
                    cr.Sales__c = crsalesMap.get(cr.Agreement_Number__c);
                }
                if(contractsGroupId != NULL){
                    cr.OwnerId = contractsGroupId;
                    //cr.Contracts_Rep__c = contractsGroupId;
                }

                // Pull in the Business Unit, Territory Number, and the Sales Rep from the Territory
                // We get the Territory Number from the Invoiced Sales data
                if(terNumMap.get(cr.Agreement_Number__c) != NULL){
                    tnumber = terNumMap.get(cr.Agreement_Number__c); // Set it to a variable
                    cr.Territory_Number__c = tnumber; // Set the Territory Number
                    // Check to make sure there's data - Crazy right? All Territory Users should have a Business Unit
                    if(terLookupMap.get(tnumber) != NULL){
                        cr.Business_Unit__c = terLookupMap.get(tnumber).Business_Unit__c;
                        cr.Sales_Rep__c = terLookupMap.get(tnumber).User__c; // RSM at this point...
                        cr.OwnerId = terLookupMap.get(tnumber).User__c;
                        rsmTnum = terLookupMap.get(tnumber).Territory_Master__r.Region_Number__c;
                        if(terLookupMap.get('RSM'+rsmTnum) != NULL){
                            cr.Sales_Manager__c = terLookupMap.get('RSM'+rsmTnum).User__c;
                            cr.OwnerId = terLookupMap.get('RSM'+rsmTnum).User__c;
                        }
                    }


                }
            }

        }

        // DML Time! / Write out to the Dababase
        if(crList.size() > 0){
            UPSERT crList;
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
        mail.setSubject('Build [1] Contract Renewals Finished: ' + a.Status + '(' + a.JobItemsProcessed + '/' + a.NumberOfErrors + ')');
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        //Build_Contract_Renewal_Items_Scheduler
        //Build_Contract_Renewal_Items_Batch

        Integer jobs = [Select count() From AsyncApexJob Where JobType = 'BatchApex' and ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )];
        if( jobs > 4 )
        {

            Datetime sysTime = System.now().addSeconds( 60 );
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();

            Build_Contract_Renewal_Items_Scheduler bcris = new Build_Contract_Renewal_Items_Scheduler();
            System.schedule( 'Build_Contract_Renewal_Items' + sysTime, chronExpression, bcris );
        }
        else
        {
            Build_Contract_Renewal_Items_Batch bcri = new Build_Contract_Renewal_Items_Batch();
            Database.executeBatch(bcri);
        }
    }

}