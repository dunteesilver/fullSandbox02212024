global class account_Build_Sales implements Database.Batchable<sObject> {
    // This creates the 'Sales by BU' from the 'Sales by Products' data.
    // 01Mar2016 - ESC
    // Test Class: account_Page_Helper_Test

    public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(query == NULL){
            query = 'SELECT Id, SAP_Sold_To__c FROM Account Where SAP_Sold_To__c != NULL';    
        }
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        system.debug('Starting account_Build_Sales!!!');
        
        string sap_Code;
        string bu;
        string aid;
        double CYTD;
        double PYTD;
        Id ssBUID;
        
        List<Account> accs = (List<Account>)scope;

        map<String, Id> ssBUMap = new map<String, Id>();
        for(Sales_by_BU__c ssBU : [SELECT Id, SAP_Code__c, Business_Unit__c 
                                           FROM Sales_by_BU__c 
                                           WHERE Account__r.Id =:accs])
        {
            ssBUMap.put(ssBU.SAP_Code__c + '-' + ssBU.Business_Unit__c, ssBU.Id);
        }
        
        map<String, Id> aidMap = new map<String, Id>();
        for(Account a : accs){
            aidMap.put(a.SAP_Sold_To__c, a.Id);
        }
        
        set<Id> compareSet = new set<Id>();
        list<Sales_by_BU__c> listSSBU = new list<Sales_by_BU__c>();
        for(AggregateResult ar : [SELECT SAP_Code__c, Sum(Sales_YTD__c) CYTD, Sum(Sales_Prior_Year__c) PYTD, Business_Unit__c 
                                  FROM Sales_by_Product__c     
                                  WHERE Account__r.Id =:accs 
                                  AND Business_Unit__c != NULL 
                                  GROUP BY ROLLUP(SAP_Code__c, Business_Unit__c)])
        {
            bu = (string) ar.get('Business_Unit__c');

            if(bu != NULL){

                sap_Code = (string) ar.get('SAP_Code__c');
                CYTD = (double) ar.get('CYTD');
                PYTD = (double) ar.get('PYTD');
                
                Sales_by_BU__c newSSBU = new Sales_by_BU__c(
                    Account__c = aidMap.get(sap_Code),
                    SAP_Code__c = sap_Code,
                    Current_YTD__c = CYTD,
                    Previous_YTD__c = PYTD,
                    Business_Unit__c = bu,
                    Key__c = sap_Code + '-' + bu
                );
                if(ssBUMap.get(sap_Code + '-' + bu) != NULL){
                    newSSBU.Id = ssBUMap.get(sap_Code + '-' + bu);
                }
                listSSBU.add(newSSBU);  
            }
            system.debug('SAP:' + sap_Code + ' / bu:' + bu + ' / CYTD:' + CYTD + ' / PYTD:' + PYTD);
            
        }
        
        //Add the Total
        for(AggregateResult ar : [SELECT SAP_Code__c, Sum(Sales_YTD__c) CYTD, Sum(Sales_Prior_Year__c) PYTD 
                                  FROM Sales_by_Product__c     
                                  WHERE Account__r.Id =:accs 
                                  AND Business_Unit__c != NULL 
                                  GROUP BY ROLLUP(SAP_Code__c)])
        {
            bu = 'Total';
            sap_Code = (string) ar.get('SAP_Code__c');
            CYTD = (double) ar.get('CYTD');
            PYTD = (double) ar.get('PYTD');

            if(sap_Code != NULL){
                Sales_by_BU__c newSSBU = new Sales_by_BU__c(
                    Account__c = aidMap.get(sap_Code),
                    SAP_Code__c = sap_Code,
                    Current_YTD__c = CYTD,
                    Previous_YTD__c = PYTD,
                    Business_Unit__c = bu,
                    Key__c = sap_Code + '-' + bu
                );
                if(ssBUMap.get(sap_Code + '-' + bu) != NULL){
                    newSSBU.Id = ssBUMap.get(sap_Code + '-' + bu);
                }
                compareSet.add(aidMap.get(sap_Code));
                listSSBU.add(newSSBU);  
            }
            system.debug('SAP:' + sap_Code + ' / bu:' + bu + ' / CYTD:' + CYTD + ' / PYTD:' + PYTD);
            
        }
                
        if(listSSBU.size() > 0){
            system.debug('Upsert listSSBU: ' + listSSBU);
            upsert listSSBU;
        }
        
        // END Build Sales Section
        
        // This section builds the BU key on the account that is used to determine whether the user
        // has sales on that account related to their BU.

        string mapUpdate;
        list<account> buinclude = new list<account>();
        Map<Id,String> sbuMap = new Map<Id,String>();
        
        Map<String, Business_Unit__c> buMap = Business_Unit__c.getAll();

        for(Sales_by_BU__c sbu : listSSBU){
            if(buMap.get(sbu.Business_Unit__c) != NULL){
                if(sbuMap.get(sbu.Account__c) != NULL){
                    mapUpdate = sbuMap.get(sbu.Account__c) + ';' + buMap.get(sbu.Business_Unit__c).Key__c;
                    sbuMap.put(sbu.Account__c, mapUpdate);
                }
                else{
                    sbuMap.put(sbu.Account__c, buMap.get(sbu.Business_Unit__c).Key__c);
                }
            }
        } 
        for(String s : sbuMap.keySet()){
            account acct = new account(
                Id = s,
                Sales_by_BU_Key__c = sbuMap.get(s)
            );
            buinclude.add(acct);
        }
        
        // END Sales_by_BU_Key__c Creation
        
        
        // This section checks to make sure we don't have any accounts that still have their BU Key on the Account Set
        set<Id> checkSet = new set<Id>();
        for(Account a : accs){
            if(!compareSet.contains(a.Id)){
                checkSet.add(a.Id);
            }
        }
        
        for(Account a : [SELECT ID 
                         FROM Account 
                         WHERE Id = :checkSet 
                         AND Sales_by_BU_Key__c != NULL])
        {
            account acct = new account(
                Id = a.Id,
                Sales_by_BU_Key__c = ''
            );
            buinclude.add(acct);
        }
        // END Checking whether Sales_by_BU_Key__c should be blank.
        
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