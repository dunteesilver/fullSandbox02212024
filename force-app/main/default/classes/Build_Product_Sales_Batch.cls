global class Build_Product_Sales_Batch Implements Database.Batchable<sObject> {

    Datetime sysTime = System.now().addSeconds( 60 );
    public String Key = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
    
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
        
        query = 'SELECT Product__c, Product__r.Sales_Build_Key__c, Product__r.Sales__c, Sales__c '; 
        query += ' FROM Invoiced_Sales__c WHERE Date__c = LAST_N_MONTHS:12 ORDER BY Product__c';
        //AND Product__c = \'01tE0000007suJA\'
        
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        list<Invoiced_Sales__c> isList = (list<Invoiced_Sales__c>)scope;
        system.debug('isList Size: ' + isList.size());
        
        list<Product2> pList = new list<Product2>();
        map<String, Decimal> salesMap = new map<String, Decimal>();
        
        decimal sales;
        
        for(Invoiced_Sales__c i : isList){
            if(i.Product__r.Sales__c == NULL){
                sales = 0;
            }
            else{
                sales = i.Product__r.Sales__c;
            }
            if(salesMap.get(i.Product__c) == NULL){
                if(i.Product__r.Sales_Build_Key__c != Key){
                    salesMap.put(i.Product__c, i.Sales__c);
                }
                else{
                    sales = i.Product__r.Sales__c + i.Sales__c;
                    salesMap.put(i.Product__c, sales); 
                }
            }
            else{
                sales = salesMap.get(i.Product__c) + i.Sales__c;
                salesMap.put(i.Product__c, sales); 
            }
        }
        
        for(Id p : salesMap.keySet()){
            Product2 upP = new Product2(
                Id = p,
                Sales_Build_Key__c = Key,
                Sales__c = salesMap.get(p)
            );
            pList.add(upP);
        }
        
        if(pList.size() > 0){
            system.debug('pList: ' + pList);
            update pList;
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
        mail.setSubject('Build Products Sales Finished: ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}