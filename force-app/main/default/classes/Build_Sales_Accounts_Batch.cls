global class Build_Sales_Accounts_Batch Implements Database.Batchable<sObject> {
    // 06Nov2016 - ESC
    // This Class basically looks at VPS Contracts, the related Account and copies over related Invoiced Sales records with products that
    // have VPS_Consumable__c = TRUE and creates records on the 'VPS Consumables' object.
    // Test Class: account_Page_Helper_Test   
    // 
    // Step 1. Invoiced_Sales_Maintenance_Batch - Purges old out of date 'Invoice Sales' files
    // Step 2. Invoiced_Sales_Detail_Maintenance_Batch - Purges Invoiced Sales Detail Records not updated today
    // Step 3. Open_Orders_Maintenance_Batch - Purges Open Orders records not updated today
    // Step 4. account_Active_Sales - Associates the BU and Territory number to the account that drives 'Territory Key', 'Active Sales', and 'Active Sales My BU'
    // Step 5. Build_Sales_Accounts_Batch - Builds the 'Sales Account' records relating the Account and Territory.

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        
        query = 'SELECT Id, Name, SAP_Code__c FROM Account WHERE Active_Sales__c = TRUE';
//        query = 'SELECT Id, Name, SAP_Code__c FROM Account WHERE Active_Sales__c = TRUE AND Id = \'001E000000ZCLvK\'';
        
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        // Create set of Account ID's
        // Create Aggregate Map of Sales
        // Iterate over the Map to create the list of records
        // 
        // Validate record doesn't already exist
        // Clean up Old Months
        
        list<Account> aList = (list<Account>)scope;
        set<Id> aSet = new set<Id>();
        set<String> asKey = new set<String>();
        
        map<String, Sales_Accounts__c> asMap = new map<String, Sales_Accounts__c>();
        map<String, Decimal> lastyearTotalSales = new map<String, Decimal>();
        map<String, Decimal> lastyearSales = new map<String, Decimal>();
        map<String, Decimal> thisyearSales = new map<String, Decimal>();
        map<String, Date> lastOrderMap = new map<String, Date>();
        map<String, Date> saDateMap = new map<String, Date>();
        list<Sales_Accounts__c> saList = new list<Sales_Accounts__c>();
        
        decimal sales; // Sales
        string yearCurrent; 
        string account;
        string territory;
        date lastOrder;
        
        string thisYear = String.valueOf(System.Today().year());
        string lastYear = String.valueOf(System.Today().year()-1);
        
        for(Account a : aList){
            aSet.add(a.Id);
        }
        system.debug('aSet: ' + aSet);
        
        for(Sales_Accounts__c sa : [SELECT Id, Key__c, Last_Order_Date__c, Territory__c, 
                                    Account__c 
                                    FROM Sales_Accounts__c 
                                    WHERE Account__c =:aSet 
                                    AND Territory__c != NULL])
        {
            asKey.add(sa.Key__c);
            asMap.put(sa.Key__c, sa);
            lastOrderMap.put(sa.Key__c, sa.Last_Order_Date__c);
            lastyearTotalSales.put(sa.Key__c, 0);
            thisyearSales.put(sa.Key__c, 0);
            lastyearSales.put(sa.Key__c, 0);
        }
        
        for(AggregateResult ar : [SELECT Territory__c territory, Account__c account, CALENDAR_YEAR(Date__c) Year, SUM(Sales__c) Sales 
                                  FROM Invoiced_Sales__c 
                                  WHERE Account__c = :aSet 
                                  //AND YOY_Flag__c = TRUE 
                                  AND Date__c = THIS_YEAR
                                  AND Exception__c = FALSE 
                                  AND Compensatory__c = TRUE 
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
        
        // Last Year Totals
        for(AggregateResult ar : [SELECT Territory__c territory, Account__c account, SUM(Sales__c) Sales 
                                  FROM Invoiced_Sales__c 
                                  WHERE Account__c = :aSet 
                                  AND Date__c = LAST_YEAR
                                  AND Exception__c = FALSE 
                                  AND Compensatory__c = TRUE 
                                  GROUP BY Territory__c, Account__c])
        {
            sales = (decimal) ar.get('Sales');
            account = (string) ar.get('account');
            territory = (string) ar.get('territory');

            lastyearTotalSales.put(account + '-' + territory, sales);
            asKey.add(account + '-' + territory);
        }
        list<String> asSplit = new list<String>();
        integer sloop;
        
        //Select Name, MAX(createddate) From Invoiced_Sales__c WHERE SAP_Code__c = '110069' OR SAP_Code__c = '102059'
        for(AggregateResult ar : [SELECT Territory__c territory, Account__c account, MAX(Order_Date__c) lastDate 
                                  FROM Invoiced_Sales_Detail__c  
                                  WHERE Account__c = :aSet 
                                  AND Compensatory__c = TRUE 
                                  GROUP BY Territory__c, Account__c])
        {
            //
            lastOrder = (date) ar.get('lastDate');
            account = (string) ar.get('account');
            territory = (string) ar.get('territory');
            system.debug('Compare lastOrder: ' + lastOrder + ' with ' + saDateMap.get(account + '-' + territory));
            // Check to make sure that the existing value is not older than the current data
            if(lastOrderMap.get(account + '-' + territory) != NULL && lastOrder != NULL){
                if(lastOrder > lastOrderMap.get(account + '-' + territory)){
                    lastOrderMap.put(account + '-' + territory, lastOrder);
                }
            }
            // This assumes that there is not an existing value on the record and sets it to the Invoiced Detail Sales value
            // New Value Set
            else if(lastOrder != NULL){
                lastOrderMap.put(account + '-' + territory, lastOrder);
            }
        }
        
        //Select Name, MAX(createddate) From Invoiced_Sales__c WHERE SAP_Code__c = '110069' OR SAP_Code__c = '102059'
        for(AggregateResult ar : [SELECT Territory__c territory, Account__c account, MAX(Date__c) lastDate 
                                  FROM Invoiced_Sales__c  
                                  WHERE Account__c = :aSet 
                                  AND Compensatory__c = TRUE 
                                  GROUP BY Territory__c, Account__c])
        {
            //
            lastOrder = (date) ar.get('lastDate');
            account = (string) ar.get('account');
            territory = (string) ar.get('territory');
            
            // Make sure the existing date is not newer than this date.
            if(lastOrderMap.get(account + '-' + territory) != NULL && lastOrder != NULL){
                if(lastOrder > lastOrderMap.get(account + '-' + territory)){
                    lastOrderMap.put(account + '-' + territory, lastOrder);
                }
            }
            // New Value Set to the Map
            else if(lastOrder != NULL){
                lastOrderMap.put(account + '-' + territory, lastOrder);
            }
        }
        
        system.debug('asKey Size: ' + asKey.size());
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
            
            
            system.debug('lastOrderMap: ' + lastOrderMap);
            if(thisyearSales.get(asales) != NULL || lastyearSales.get(asales) != NULL){
                Sales_Accounts__c newSA = new Sales_Accounts__c(
                    Account__c = account,
                    Territory__c = territory,
                    Key__c = asales,
                    Sales_YTD__c = 0,
                    Sales_PYTD__c = 0
                );
                if(lastOrderMap.containsKey(asales)){
                    newSA.Last_Order_Date__c = lastOrderMap.get(asales);
                }
                if(thisyearSales.containsKey(asales)){
                    newSA.Sales_YTD__c = thisyearSales.get(asales);
                }
                if(lastyearSales.containsKey(asales)){
                    newSA.Sales_PYTD__c = lastyearSales.get(asales);
                }
                if(lastyearTotalSales.containsKey(asales)){
                    newSA.Sales_PY__c = lastyearTotalSales.get(asales);
                }
                if(asMap.containsKey(asales)){
                    newSA.Id = asMap.get(asales).Id;
                }
                system.debug('newSA: ' + newSA);
                saList.add(newSA);
            }
        }
        system.debug('saList: ' + saList);
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
        mail.setSubject('Maintenance [5] Build Sales Accounts: ' + a.Status + ' (' + a.JobItemsProcessed + '/' + a.NumberOfErrors + ')');
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        /*
        Integer jobs = [Select count() From AsyncApexJob Where JobType = 'BatchApex' and ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )];
        if( jobs > 4 )
        {

            Datetime sysTime = System.now().addSeconds( 60 );
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();

            Build_Sales_Last_Ordered_Scheduler bslo = new Build_Sales_Last_Ordered_Scheduler();
            System.schedule( 'Build_Sales_Last_Ordered' + sysTime, chronExpression, bslo );                
        }
        else
        {
            Build_Sales_Last_Ordered_Batch bslob = new Build_Sales_Last_Ordered_Batch();
            Database.executeBatch(bslob,50);
        }*/
    }
    
}