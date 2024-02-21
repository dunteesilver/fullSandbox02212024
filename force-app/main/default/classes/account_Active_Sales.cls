global class account_Active_Sales implements Database.Batchable<sObject> {
    // This popules the 'Sales_by_BU_Key__c' and 'Territory_Key__c' fields on the account using 'Invoiced Sales' data.
    // 11OCT2016 - ESC
    // Test Class: account_Page_Helper_Test

    public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(query == NULL){
            query = 'SELECT Id, SAP_Sold_To__c, Sales_by_BU_Key__c, Territory_Key__c FROM Account Where SAP_Sold_To__c != NULL';    
        }
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        system.debug('Starting account_Active_Sales Batch');
        
        string sap_Code;
        string bu;
        string aid;
        string tnum;
       
        List<Account> accs = (List<Account>)scope;
        
        map<String, Account> acctMap = new map<String, Account>();
        for(Account a : accs){
            acctMap.put(a.Id, a);
        }
        
        set<Id> compareSet = new set<Id>();
        
        string mapUpdate;
        list<account> buinclude = new list<account>();
        Map<Id,String> sbuMap = new Map<Id,String>();
        Map<Id,String> tnumMap = new Map<Id,String>();
        
        Map<String, Business_Unit__c> buMap = Business_Unit__c.getAll();

        for(AggregateResult ar : [SELECT Account__c, Business_Unit__c, Territory_Number__c  
                                  FROM Invoiced_Sales__c      
                                  WHERE Account__r.Id =:accs 
                                  AND Business_Unit__c != NULL 
                                  GROUP BY Account__c, Business_Unit__c, Territory_Number__c
                                  ORDER BY Account__c, Business_Unit__c, Territory_Number__c])
        {
            bu = (string) ar.get('Business_Unit__c');
            aid = (string) ar.get('Account__c');
            tnum = (string) ar.get('Territory_Number__c');
            
            if(sbuMap.get(aid) != NULL){
                mapUpdate = sbuMap.get(aid) + ';' + buMap.get(bu).Key__c;
                sbuMap.put(aid, mapUpdate);
            }
            else{
                sbuMap.put(aid, buMap.get(bu).Key__c);
            }
            
            if(tnumMap.get(aid) != NULL){
                mapUpdate = tnumMap.get(aid) + ';' + tnum;
                tnumMap.put(aid, mapUpdate);
            }
            else{
                tnumMap.put(aid, tnum);
            }

            compareSet.add(aid);

            //system.debug('BU:' + bu + ' / aid:' + aid);
            
        }
        
        //system.debug('sbuMap: ' + sbuMap);
        
        // END Build Sales Section
        
        // This section builds the BU key on the account that is used to determine whether the user
        // has sales on that account related to their BU.

        string tkey;
        for(String s : sbuMap.keySet()){
            if(tnumMap.get(s) != acctMap.get(s).Territory_Key__c || sbuMap.get(s) != acctMap.get(s).Sales_by_BU_Key__c){
                if(tnumMap.get(s) != NULL){
                    tkey = tnumMap.get(s);
                    tkey = tkey.left(255);
                }
                account acct = new account(
                    Id = s,
                    Sales_by_BU_Key__c = sbuMap.get(s),
                    Territory_Key__c = tkey
                );
                buinclude.add(acct); 
            }
            else{
                system.debug('BU and Territory Keys Have not Changed - No DML Required');
            }
        }
        
        // END Sales_by_BU_Key__c Creation
        
        
        // This section checks to make sure we don't have any accounts that still have their BU Key on the Account Set

        for(Account a : accs){
            if(!compareSet.contains(a.Id) && a.Sales_by_BU_Key__c != NULL){
                account acct = new account(
                    Id = a.Id,
                    Sales_by_BU_Key__c = '',
                    Territory_Key__c = ''
                );
                buinclude.add(acct);
            }
        }
    
        // Update the Account - Sales_by_BU_Key__c
        if(buinclude.size() > 0){
            system.debug('buinclude: ' + buinclude);
            update buinclude;
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
        mail.setSubject('Finished Building Sales by BU: ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}