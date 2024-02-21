global class CrossReferenceFix implements Database.Batchable<sObject> {
    public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Product2> scope){
        Map<String,String> usSixtyProds = new Map<String,String>();
        List<Cross_Reference__c> crossRefToUpdate = new List<Cross_Reference__c>();
        List<Cross_Reference__c> crossRef = new List<Cross_Reference__c>();
        //List<Product2> sixtyList = [SELECT Id, Name FROM Product2 WHERE Sales_Org_Key__c = 'US6010' AND Class__c LIKE '%Anesthesia%'];
        List<String> sixtyListNames = new List<String>();
        Cross_Reference__c crossObj;
        for(Product2 curr : scope){
            sixtyListNames.add(curr.Name);
            usSixtyProds.put(curr.Name,curr.Id);
        }
        
        crossRef = [SELECT Competitor_Product_Code__c, Competitor_Product_Description__c, Id, Product__c, TFX_Product_Description__c, TFX_Product__c, Product__r.Sales_Org__c
                    FROM Cross_Reference__c
                    Where (Product__r.Sales_Org__c = 'US10' 
                           OR Product__r.Sales_Org__c = 'US30')
                    AND TFX_Product__c IN :sixtyListNames];
        
        for(Cross_Reference__c curr : crossRef){
            if(usSixtyProds.get(curr.TFX_Product__c) != NULL ){
                curr.Product__c = usSixtyProds.get(curr.TFX_Product__c);
                crossRefToUpdate.add(curr);	
            }
        }
        
        if(crossRefToUpdate.size() > 0 ){
            Database.update(crossRefToUpdate,false);
        }
        
        //update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        // UserInfo.getUserEmail();
        // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, CreatedBy.Admin_SMS_Notification__c 
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        list<string> emailList = new list<string>();
        emailList.add(a.CreatedBy.Email);
        
        if(a.CreatedBy.Admin_SMS_Notification__c != NULL){
            emailList.add(a.CreatedBy.Admin_SMS_Notification__c);
        }
        mail.setToAddresses(emailList);
        mail.setSubject('Batch Tickle Completed: ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}