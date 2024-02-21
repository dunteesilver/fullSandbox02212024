global class Build_Sales_Last_Ordered_Batch Implements Database.Batchable<sObject> {
    // Step 1. Invoiced_Sales_Maintenance_Batch - Purges old out of date 'Invoice Sales' files
    // Step 2. Invoiced_Sales_Detail_Maintenance_Batch - Purges Invoiced Sales Detail Records not updated today
    // Step 3. Open_Orders_Maintenance_Batch - Purges Open Orders records not updated today
    // Step 4. account_Active_Sales - Associates the BU and Territory number to the account that drives 'Territory Key', 'Active Sales', and 'Active Sales My BU'
    // Step 5. Build_Sales_Accounts_Batch - Builds the 'Sales Account' records relating the Account and Territory.
    // Step 6. Build_Sales_Last_Ordered_Batch - Build's the 'Last Ordered' on Sales Accounts

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        
        query = 'SELECT Id, Name, SAP_Code__c FROM Account WHERE Active_Sales__c = TRUE ';
        
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        // Last Ordered Date
        // Create List
        // Check Open Orders
        // Check Order Details
        // Check Invoiced Orders
        // Write: # of open orders / open orders by Territory
        
        list<Account> aList = (list<Account>)scope;
        set<Id> aSet = new set<Id>();
        set<String> asKey = new set<String>();
        
        map<String, Id> asMap = new map<String, Id>();
        map<String, Decimal> lastyearSales = new map<String, Decimal>();
        map<String, Decimal> thisyearSales = new map<String, Decimal>();
        list<Sales_Accounts__c> saList = new list<Sales_Accounts__c>();
        
        decimal sales; // Sales
        string yearCurrent; 
        string account;
        string territory;
        
        string thisYear = String.valueOf(System.Today().year());
        string lastYear = String.valueOf(System.Today().year()-1);
        
        for(Account a : aList){
            aSet.add(a.Id);
        }
        
        for(Sales_Accounts__c sa : [SELECT Id, Key__c 
                                    FROM Sales_Accounts__c 
                                    WHERE Account__c =:aSet])
        {
            asMap.put(sa.Key__c, sa.Id);
        }
        
        for(AggregateResult ar : [SELECT Territory__c territory, Account__c account, CALENDAR_YEAR(Date__c) Year, SUM(Sales__c) Sales 
                                  FROM Invoiced_Sales__c 
                                  WHERE Account__c = :aSet 
                                  AND YOY_Flag__c = TRUE 
                                  GROUP BY Territory__c, Account__c, CALENDAR_YEAR(Date__c)])
        {
            sales = (decimal) ar.get('Sales');
            account = (string) ar.get('account');
            territory = (string) ar.get('territory');
            yearCurrent = String.valueOf(ar.get('Year'));
            
            if(yearCurrent == thisYear){
                thisyearSales.put(account + '-' + territory, sales);
            }
            else if(yearCurrent == lastYear){
                lastyearSales.put(account + '-' + territory, sales);
            }
            asKey.add(account + '-' + territory);
        }
        list<String> asSplit = new list<String>();
        integer sloop;
        
        for(string asales : asKey){
            sloop = 1;
            asSplit = asales.split('-', -2);

            for(string split : asSplit){
                if(sloop == 1){
                    account = split;
                    ++sloop;
                }
                else if(sloop == 2){
                    territory = split;
                    ++sloop;
                }
            }
            
            if(thisyearSales.get(asales) != NULL || lastyearSales.get(asales) != NULL){
                Sales_Accounts__c newSA = new Sales_Accounts__c(
                    Account__c = account,
                    Territory__c = territory,
                    Key__c = asales,
                    Sales_YTD__c = 0,
                    Sales_PYTD__c = 0
                );
                if(thisyearSales.get(asales) != NULL){
                    newSA.Sales_YTD__c = thisyearSales.get(asales);
                }
                if(lastyearSales.get(asales) != NULL){
                    newSA.Sales_PYTD__c = lastyearSales.get(asales);
                }
                if(asMap.get(asales) != NULL){
                    newSA.Id = asMap.get(asales);
                }                
                saList.add(newSA);
            }
        }

        if(saList.size() > 0){
            upsert saList;
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