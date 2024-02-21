/*********************************************************************
* Description      : This class is used for building contract customer sales
* Test Class       : Contract_Renewal_Test
* Author(s)        : Eric Clay
**********************************************************************/
global class Build_Contract_Customer_Sales_Batch Implements Database.Batchable<sObject> {
    //Test Class: Invoiced_Global_Test_Class

    Datetime sysTime = System.now();
    public String Key = '' + sysTime.second() + sysTime.minute() + sysTime.hour() + sysTime.day() + sysTime.month() + sysTime.year();

    // 06Nov2016 - ESC
    // This Class basically looks at VPS Contracts, the related Account and copies over related Invoiced Sales records with products that
    // have VPS_Consumable__c = TRUE and creates records on the 'VPS Consumables' object.
    // Test Class: account_Page_Helper_Test
    //
    // Step 1. Invoiced_Sales_Maintenance_Batch - Purges old out of date 'Invoice Sales' files
    // Step 2. account_Active_Sales - Associates the BU and Territory number to the account that drives 'Territory Key', 'Active Sales', and 'Active Sales My BU'
    // Step 3. Build_Sales_Accounts_Batch - Builds the 'Sales Account' records relating the Account and Territory.

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;

        query = 'SELECT Account__c, Contract_Header__c, Sales__c ';
        query += ' FROM Invoiced_Sales__c WHERE Date__c = LAST_N_MONTHS:12 AND Contract_Header__c != NULL ';
        query += ' ORDER BY Product__c ';
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){

        list<Invoiced_Sales__c> isList = (list<Invoiced_Sales__c>)scope;
        system.debug('isList Size: ' + isList.size());

        list<Contract_Customer__c> ccList = new list<Contract_Customer__c>();
        list<Invoiced_Sales__c> isList2 = new list<Invoiced_Sales__c>();
        list<Product2> pList = new list<Product2>();
        map<String, Decimal> salesMap = new map<String, Decimal>();
        map<String, Contract_Customer__c> ccMap = new map<String, Contract_Customer__c>();
        set<Id> aid = new set<Id>();
        set<Id> cid = new set<Id>();

        decimal sales;

        for(Invoiced_Sales__c i : isList){
            aid.add(i.Account__c);
            cid.add(i.Contract_Header__c);
        }
        for(Contract_Customer__c cc : [SELECT Id, Sales__c, Sales_Build_Key__c, Account__c, Agreement__c
                                      FROM Contract_Customer__c
                                      WHERE Account__c =:aid
                                      AND Agreement__c =:cid])
        {
            ccMap.put(cc.Account__c + '-' + cc.Agreement__c, cc);
        }
        //system.debug('ccMap Size: ' + ccMap.size());

        string mapKey;
        for(Invoiced_Sales__c i : isList){
            mapKey = i.Account__c + '-' + i.Contract_Header__c;
            //system.debug('mapKey' + mapKey);
            if(ccMap.containsKey(mapKey)){
                if(ccMap.get(mapKey).Sales__c == NULL){
                    sales = 0;
                }
                else{
                    sales = ccMap.get(mapKey).Sales__c;
                }
                if(salesMap.get(mapKey) == NULL){
                    if(ccMap.get(mapKey).Sales_Build_Key__c != Key){
                        salesMap.put(mapKey, i.Sales__c);
                    }
                    else{
                        sales = ccMap.get(mapKey).Sales__c + i.Sales__c;
                        salesMap.put(mapKey, sales);
                    }
                }
                else{
                    sales = salesMap.get(mapKey) + i.Sales__c;
                    salesMap.put(mapKey, sales);
                }
            }

        }

        list<String> asSplit = new list<String>();
        integer sloop;
        string acctId;
        string ccId;

        for(string asales : salesMap.keySet()){
            sloop = 1;
            asSplit = asales.split('-', -2);

            for(string split : asSplit){
                if(sloop == 1){
                    acctId = split;
                    ++sloop;
                }
                else if(sloop == 2){
                    ccId = split;
                    ++sloop;
                }
            }
            if(ccId != NULL && salesMap.get(asales) != NULL){
                Contract_Customer__c newCC = new Contract_Customer__c(
                    Id = ccMap.get(asales).Id,
                    Sales__c = salesMap.get(asales),
                    Sales_Build_Key__c = Key
                );
                ccList.add(newCC);
            }

        }
        if(ccList.size() > 0){
            update ccList;
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
        mail.setSubject('Build [3] Contract Customer Sales Finished: ' + a.Status + '(' + a.JobItemsProcessed + '/' + a.NumberOfErrors + ')');
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}