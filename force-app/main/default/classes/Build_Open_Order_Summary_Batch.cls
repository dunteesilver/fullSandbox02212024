global class Build_Open_Order_Summary_Batch Implements Database.Batchable<sObject> {
    // 31May2018 - ESC
    // Test Class: Invoiced_Global_Test_Class.testScheduledClasses
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Back_Ordered__c, PO_Number__c, Open_Order_Qty__c, Open_Order_Total__c, Product__r.Name, Total_Qty_Back_Ordered__c, PO_Value__c FROM Open_Orders__c ORDER BY PO_Number__c';        
        //WHERE Back_Ordered__c = TRUE
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
                
        list<Open_Orders__c> oList = (list<Open_Orders__c>)scope;
        list<Open_Orders__c> ooUpdate = new list<Open_Orders__c>();
        list<String> plist = new list<String>();
        list<String> polist = new list<String>();
        map<String, Decimal> pMap = new map<String, Decimal>();
        map<String, Decimal> poMap = new map<String, Decimal>();
        
        decimal sales; // Sales
        decimal quantity; // Quantity
        string prod; // Product Name
        string po; // PO Number
        
        // List of PO's
        // List of Materials
        for(Open_Orders__c o : oList){
            if(o.Product__r.Name != NULL){
                plist.add(o.Product__r.Name);
            }
            if(o.PO_Number__c != NULL){
                polist.add(o.PO_Number__c);
            }
        }
        
        for(AggregateResult ar : [SELECT Product__r.Name Name, SUM(Open_Order_Qty__c) quantity 
                                  FROM Open_Orders__c 
                                  WHERE Product__r.Name = :plist 
                                  AND Back_Ordered__c = TRUE 
                                  AND Open_Order_Qty__c > 0 
                                  GROUP BY Product__r.Name])
        {
            quantity = (decimal) ar.get('quantity');
            prod = (string) ar.get('Name');
            pMap.put(prod, quantity);
        }
        
        for(AggregateResult ar : [SELECT PO_Number__c PO, SUM(Open_Order_Total__c) Sales 
                                  FROM Open_Orders__c 
                                  WHERE PO_Number__c = :polist 
                                  //AND Back_Ordered__c = TRUE 
                                  //AND Open_Order_Total__c > 0 
                                  GROUP BY PO_Number__c])
        {
            sales = (decimal) ar.get('Sales');
            po = (string) ar.get('PO');
            poMap.put(po, sales);
        }
        
        boolean updateRec;
        for(Open_Orders__c o : oList){
            updateRec = FALSE;
            Open_Orders__c newOO = new Open_Orders__c(
                id = o.Id
            );
            if(pMap.containsKey(o.Product__r.Name) && 
               pMap.get(o.Product__r.Name) != o.Total_Qty_Back_Ordered__c && 
               o.Back_Ordered__c == TRUE
              ){
                newOO.Total_Qty_Back_Ordered__c = pMap.get(o.Product__r.Name);
                updateRec = TRUE;
            } 
            if(poMap.containsKey(o.PO_Number__c) && poMap.get(o.PO_Number__c) != o.PO_Value__c){
                newOO.PO_Value__c = poMap.get(o.PO_Number__c);
                updateRec = TRUE;
            }
            if(updateRec){
                ooUpdate.add(newOO);
            }
        }
        
        if(ooUpdate.size() > 0){
            update ooUpdate;
        }
        
    }
    
    
    global void finish(Database.BatchableContext BC){
        //UserInfo.getUserEmail();
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob 
                          WHERE Id = :BC.getJobId()];
        
        string emailSubj = 'Maintenance [Open Order Build]: ' + a.Status + ' (' + a.JobItemsProcessed + '/' + a.NumberOfErrors + ')';
        string emailBody = 'The batch Apex job processed ' + a.JobItemsProcessed + ' batches with '+ a.NumberOfErrors + ' failures.';
        
        String obj = 'Open_Orders__c';
        Global_Maintenance check = new Global_Maintenance();
        list<String> emailList = check.getEmailList(obj);
        if(emailList.size() > 0){
            system.debug('Sending Email Now!');
            check.sendEmailHelper(emailSubj,emailBody,emailList);
        }
        
        /*
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Maintenance - Open Orders Summary: ' + a.Status + ' (' + a.JobItemsProcessed + '/' + a.NumberOfErrors + ')');
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
    }
    
}