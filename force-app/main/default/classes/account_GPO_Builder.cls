global class account_GPO_Builder implements Database.Batchable<sObject> {
    
        public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(query == NULL){
            //query = 'SELECT Id, SAP_Sold_To__c FROM Account WHERE Id IN (SELECT Account__c FROM Contract_Customer__c)';
            query = 'SELECT Id, SAP_Sold_To__c FROM Account WHERE SAP_Sold_To__c != NULL';    
        }
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        //do stuff here
        
        system.debug('-- Starting Build GPO --');
        string sap_Code;
        string gpoStr;
        string condStr;
        
        map<string, string> priMap = new map<string, string>();
        map<string, string> secMap = new map<string, string>();
        set<string> sapset = new set<string>();
        
        List<Account> accs = (List<Account>)scope;
        system.debug('accs: ' + accs);
        
        for(AggregateResult ar : [SELECT SAP_Code__c, Condition__c, Owner_Name__c  
                                  FROM Contract_Customer__c     
                                  WHERE (Condition__c = 'XPRI' OR Condition__c = 'XSEC') 
                                  AND (NOT Agreement__r.Owner_Name__c LIKE '%Teleflex%') 
                                  AND Account__r.Id =:scope 
                                  GROUP BY ROLLUP(SAP_Code__c, Condition__c, Owner_Name__c)])
        {
            If(ar.get('SAP_Code__c') != NULL && (string) ar.get('Owner_Name__c') != NULL){
                gpoStr = (string) ar.get('Owner_Name__c');
                condStr = (string) ar.get('Condition__c');
                sap_Code = (string) ar.get('SAP_Code__c');
                
                //system.debug('sap_Code: ' + sap_Code);
                
                if(condStr == 'XPRI'){
                    priMap.put(sap_Code, gpoStr);
                }
                else if(condStr == 'XSEC'){
                    secMap.put(sap_Code, gpoStr);
                }
                sapset.add(sap_Code);
                system.debug('priMap' + priMap);
                system.debug('secMap' + secMap);
            }
            
        }
        
        list<Account> auplist = new list<Account>();
        for(Account a : [SELECT Id, Main_GPO__c, Secondary_GPO__c 
                         FROM Account 
                         WHERE Id = :accs 
                         //AND (NOT SAP_Sold_To__c IN :sapset) 
                         AND SAP_Sold_To__c != :sapset 
                         AND (Main_GPO__c != NULL OR Secondary_GPO__c != NULL)])
        {
            system.debug('Removing GPOs for Account:' + a.Id);
            Account newacct = new Account(
                Id = a.Id,
                Main_GPO__c = '',
                Secondary_GPO__c = ''
            );
            auplist.add(newacct);
        }
        
        if(sapset.size() > 0){

            boolean needsUpdate;
            for(Account a : [SELECT Id, SAP_Sold_To__c, Main_GPO__c, Secondary_GPO__c   
                             FROM Account 
                             WHERE SAP_Sold_To__c =:sapset])
            {
                needsUpdate = false;
                account aup = new account();
                
                if(priMap.get(a.SAP_Sold_To__c) != NULL){
                    if(priMap.get(a.SAP_Sold_To__c) != a.Main_GPO__c){
                        aup.Main_GPO__c = priMap.get(a.SAP_Sold_To__c);
                        needsUpdate = true;
                        system.debug('Add Primary: ' + priMap.get(a.SAP_Sold_To__c));
                    }
                }
                else if(a.Main_GPO__c != NULL){
                    aup.Main_GPO__c = '';
                    needsUpdate = true;
                    system.debug('Setting Primary to NULL');
                }

                if(secMap.get(a.SAP_Sold_To__c) != NULL){
                    if(secMap.get(a.SAP_Sold_To__c) != a.Secondary_GPO__c){
                        aup.Secondary_GPO__c = secMap.get(a.SAP_Sold_To__c);
                        needsUpdate = true;
                        system.debug('Add Secondary: ' + secMap.get(a.SAP_Sold_To__c));
                    }
                }
                else if(a.Secondary_GPO__c != NULL){
                    aup.Secondary_GPO__c = '';
                    needsUpdate = true;
                    system.debug('Setting Secondary to NULL');
                }

                if(needsUpdate){
                    aup.Id = a.Id;
                    auplist.add(aup);  
                }
            }

        }
        if(auplist.size() > 0){
            system.debug('Updating Accounts! ' + auplist);
            update auplist;
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
        
        string emailSubj = 'Maintenance [Build Account GPO Primary Secondary]: ' + a.Status;
        string emailBody = 'The batch Apex job processed ' + a.JobItemsProcessed + ' batches with '+ a.NumberOfErrors + ' failures.';
        
        String obj = 'Contract_Customer__c';
        Global_Maintenance gm = new Global_Maintenance();
        list<String> emailList = gm.getEmailList(obj);
        if(emailList.size() > 0){
            system.debug('Sending Email Now!');
            gm.sendEmailHelper(emailSubj,emailBody,emailList);
        }
        
        /*
        
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Build Account GPO Primary Secondary Job: ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); */
    }
}