/*********************************************************************
* Description      : Batch to build detail items for Contract Renewals.
* Test Class       : Contract_Renewal_Test
* Author(s)        : Eric Clay
**********************************************************************/
global class Build_Contract_Renewal_Items_Batch Implements Database.Batchable<sObject> {
    //Test Class: Invoiced_Global_Test_Class

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;

        query = 'SELECT Id, Agreement__c, Price__c, Valid_To__c, Valid_From__c, ';
        query += 'Product__c, Agreement__r.Agreement_Number__c, Product__r.Material_Status_Check__c ';
        query += 'FROM Contract_Material__c ';
//        query += 'WHERE Valid_To__c = NEXT_N_MONTHS:2 AND Valid_To__c != NEXT_MONTH ';
        query += 'WHERE Valid_To__c = NEXT_90_DAYS ';
        query += 'AND Agreement__r.Contract_Renewal_Eligible__c = TRUE ';
        //query += 'AND Id NOT IN (SELECT Contract_Material__c FROM Contract_Renewal_Item__c )';
        //query += ' LIMIT 10';
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){

        // Variables Declared
        string sd;
        string prod;
        string crecommendations = '';
        decimal sales;
        decimal drate = 0.00;
        date compareDate;

        List<Contract_Material__c> cmList = (List<Contract_Material__c>)scope;
        list<Contract_Renewal_Item__c> criList = new list<Contract_Renewal_Item__c>();

        set<Id> chId = new set<Id>(); // Set of Contract Header ID's for Creating the Sales Map
        set<Id> pId = new set<Id>();
        set<Id> cmId = new set<Id>();

        map<String, Decimal> crsalesMap = new map<String, Decimal>();
        map<Id, Id> crMap = new map<Id, Id>();
        map<Id, Id> cmIdMap = new map<Id, Id>();
        map<Id, Decimal> renewalMap = new map<Id, Decimal>();

        // Let's get to work...

        // First we'll need a set of Contract Header ID's
        for(Contract_Material__c cm : cmList){
            chId.add(cm.Agreement__c);
            pId.add(cm.Product__c);
            cmId.add(cm.Id);
            system.debug('Debug Set: ' + cm.Id);
        }

        for(Contract_Renewal_Item__c cri : [SELECT Id, Contract_Material__c
                                           FROM Contract_Renewal_Item__c
                                           WHERE Contract_Material__c =:cmId])
        {
            system.debug('Debug Set: ' + cri.Contract_Material__c);
            cmIdMap.put(cri.Contract_Material__c, cri.Id);
        }

        // Now let's build out the Sales Map
        for(AggregateResult ar : [SELECT Product__c, Sales_Deal__c, SUM(Sales__c) Sales
                                  FROM Invoiced_Sales__c
                                  WHERE Contract_Header__c = :chId
                                  AND Product__c = :pId
                                  AND Date__c = LAST_N_MONTHS:12
                                  GROUP BY Product__c, Sales_Deal__c])
        {
            sales = (decimal) ar.get('Sales');
            sd = (string) ar.get('Sales_Deal__c');
            prod = (string) ar.get('Product__c');

            crsalesMap.put(prod+sd, sales);
        }

        // Let's get the renewal Rate:
        for(Product2 p : [SELECT Id, Standard_Renewal_Rate__c
                          FROM Product2
                          WHERE Id =:pId])
        {
            renewalMap.put(p.Id, p.Standard_Renewal_Rate__c);
        }

        // We will also need a map from Contract Header to Contract Renewal
        for(Contract_Renewal__c cr : [SELECT Id, Contract_Header__c
                                     FROM Contract_Renewal__c
                                     WHERE Contract_Header__c =:chId]){
            crMap.put(cr.Contract_Header__c, cr.Id);
        }

        // Now Let's Finish it Up
        for(Contract_Material__c cm : cmList){
            crecommendations = ''; // Just in case it is still set from the previous loop.

            // Determine if the contract material has been added within the last 6 months to determine whether it is not eligible for an increase.
            compareDate = cm.Valid_To__c;
            compareDate = compareDate.addMonths(-6);

            // Map the Sales Data if it exists otherwise zero
            if(crsalesMap.get(cm.Product__c+cm.Agreement__r.Agreement_Number__c) != NULL){
                sales = crsalesMap.get(cm.Product__c+cm.Agreement__r.Agreement_Number__c);
            }
            else{
                sales = 0;
            }

            // Set the renewal rate if the rate is in the renewal matrix
            if(renewalMap.get(cm.Product__c) != NULL){
                drate = renewalMap.get(cm.Product__c);
            }
            // if the Contract Material has been on the contract less than 6 months renew with no increase
            else if(cm.Valid_From__c > compareDate){
                drate = 0.00;
                crecommendations = 'Renew, Recent Addition - No Increase';
            }
            // Default it to 0.00
            else{
                drate = 0.00;
            }

            // If the product is not active we do not want to renew it.
            if(cm.Product__r.Material_Status_Check__c == FALSE){
                drate = 0.00;
                crecommendations = 'Do Not Renew, Discontinued';
            }
            // Build the Contract Renewal Item Record
            if(crMap.get(cm.Agreement__c) != NULL){
                Contract_Renewal_Item__c newCRI = new Contract_Renewal_Item__c(
                    Contract_Renewal__c = crMap.get(cm.Agreement__c),
                    Current_Price__c = cm.Price__c,
                    Product__c = cm.Product__c,
                    Sales__c = sales,
                    Valid_From__c = cm.Valid_From__c,
                    Valid_To__c = cm.Valid_To__c,
                    Default_Per_Increase__c = drate*100,
                    Default_Renewal_Price__c = (drate*cm.Price__c)+cm.Price__c,
                    Requested_Increase__c = drate*100,
                    Requested_Renewal_Price__c = (drate*cm.Price__c)+cm.Price__c,
                    Material_Line_Note__c  = crecommendations,
                    Contract_Material__c = cm.Id
                );
                system.debug('Debug Check: ' + cm.Id);
                if(cmIdMap.containsKey(cm.Id)){
                    newCRI.Id = cmIdMap.get(cm.Id);
                    system.debug('Upsert!');
                }
                criList.add(newCRI); // Add the Record to the Create List
            }
        }

        // Write the Records! - If the ID exists update the records else insert the records
        if(criList.size() > 0){
            UPSERT criList;
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
        mail.setSubject('Build [2] Contract Renewal Items Finished: ' + a.Status + '(' + a.JobItemsProcessed + '/' + a.NumberOfErrors + ')');
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        //Build_Contract_Customer_Sales_Batch
        //Build_Contract_Customer_Sales_Scheduler

        Integer jobs = [Select count() From AsyncApexJob Where JobType = 'BatchApex' and ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )];
        if( jobs > 4 )
        {

            Datetime sysTime = System.now().addSeconds( 60 );
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();

            Build_Contract_Customer_Sales_Scheduler bccss = new Build_Contract_Customer_Sales_Scheduler();
            System.schedule( 'Build_Contract_Renewal_Items' + sysTime, chronExpression, bccss );
        }
        else
        {
            Build_Contract_Customer_Sales_Batch bccsb = new Build_Contract_Customer_Sales_Batch();
            Database.executeBatch(bccsb);
        }
    }

}