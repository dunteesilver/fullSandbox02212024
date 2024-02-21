global class InvoicedSalesAccountShareBatch implements database.Batchable<sObject>,database.stateful, Schedulable
{
    global integer  totalTuSuccessess =0;
    global integer  totalTuFailures   =0;
    global integer  totalUsSuccessess  =0;
    global integer  totalUsFailures   =0;
    global integer  totalAtmSuccessess =0;
    global integer  totalAtmFailures  =0;
    public string   query ='SELECT id,Account__c,territory__c from Invoiced_Sales__c WHERE CreatedDate=THIS_MONTH';
    
    //start method of the batch
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        
      // String query = 'SELECT id,Account__c,territory__c from Invoiced_Sales__c WHERE CreatedDate=THIS_MONTH';
        return Database.getQueryLocator(query);}
    
    global void execute(Database.BatchableContext BC, List<Invoiced_Sales__c> scope){ 
        
        System.debug('*** Starting shareAccountAndAddToAccountTeam in Invoiced_Sales_Helper_Class ***');
        
        Set<Id> territoryMasterIds = new Set<Id>();
        for(Invoiced_Sales__c sale: scope){
            
            //Insert case
            if(string.isNotEmpty(sale.Territory__c)){
                territoryMasterIds.add(sale.Territory__c);
            }
        }
        
        Map<Id, Territory_Master__c> territoryMap = new Map<Id, Territory_Master__c>([SELECT Id, Sales_Rep__c , Primary_Territory_User__c, Business_Unit__c, 
                                                                                      (SELECT Id, User__c From Territory_Users__r)
                                                                                      FROM Territory_Master__c
                                                                                      WHERE Id IN:territoryMasterIds]);
        
        Map<String, Territory_User__c> territoryUsersToInsert = new Map<String, Territory_User__c>();
        Map<String, AccountShare> shareRecsToInsert = new Map<String, AccountShare>();
        Map<String, AccountTeamMember> accTeamMemRecs = new Map<String, AccountTeamMember>();
        
        for(Invoiced_Sales__c sale: scope){
            if(string.isNotEmpty(sale.Account__c) && string.isNotEmpty(sale.Territory__c) && territoryMap.containsKey(sale.Territory__c)){
                Territory_Master__c tm = territoryMap.get(sale.Territory__c);
                system.debug('tm'+tm);
                if(string.isNotEmpty(tm.Sales_Rep__c) || string.isNotEmpty(tm.Primary_Territory_User__c))
                {
                    Id repId = string.isNotEmpty(tm.Sales_Rep__c) ? tm.Sales_Rep__c : tm.Primary_Territory_User__c;
                    Boolean territoryUserForRepExists = false;
                    for(Territory_User__c territoryUser: tm.Territory_Users__r){
                        if(territoryUser.User__c == repId){
                            territoryUserForRepExists = true;
                        }
                    }
                    String userkey = repId+'|'+tm.Id;
                    if(!territoryUserForRepExists && !territoryUsersToInsert.containsKey(userkey)){
                        Territory_User__c addTU = new Territory_User__c(
                            User__c = repId,
                            Business_Unit__c = tm.Business_Unit__c,
                            Role__c = 'Sales Rep',
                            Territory_Master__c = tm.Id,
                            Primary__c = true
                        );
                        territoryUsersToInsert.put(userkey, addTU);
                    }
                    String tmkey = repId+'|'+sale.Account__c;
                    if(!accTeamMemRecs.containsKey(tmkey)){
                        AccountTeamMember addATM = new AccountTeamMember(
                            AccountId = sale.Account__c,
                            TeamMemberRole = 'Sales Rep',
                            UserId = repId,
                            Access_Granted_Type__c='Automation'
                        );
                        accTeamMemRecs.put(tmkey,addATM);
                    }
                    String askey = repId+'|'+sale.Account__c;
                    if(!shareRecsToInsert.containsKey(askey)){
                        AccountShare addAS = new AccountShare(
                            AccountId = sale.Account__c,
                            OpportunityAccessLevel = 'None',
                            CaseAccessLevel = 'None',
                            AccountAccessLevel = 'Edit',
                            UserOrGroupId = repId
                        );
                        shareRecsToInsert.put(askey,addAS);
                    }
                }
            }
        }
        
        if(territoryUsersToInsert.values() != null && territoryUsersToInsert.values().size()>0){
            system.debug('territoryUsersToInsert:'+territoryUsersToInsert.values());
            database.SaveResult[] myResult=database.insert(territoryUsersToInsert.values(),false);
            for(database.SaveResult s:myResult){
                if(s.isSuccess()){
                    totalTuSuccessess++;
                }
                else{
                    totalTuFailures++;  
                }
            }
        }
        
        if(shareRecsToInsert.values() != null && shareRecsToInsert.values().size()>0){
            system.debug('shareRecsToInsert:'+shareRecsToInsert.values());
            database.SaveResult[] myResult=database.insert(shareRecsToInsert.values(),false);
            for(database.SaveResult s:myResult){
                if(s.isSuccess()){
                    totalUsSuccessess++;
                }
                else{
                    totalUsFailures++;  
                }
            }
        }
        
        if(accTeamMemRecs.values() != null && accTeamMemRecs.values().size()>0){
            system.debug('accTeamMemRecs:'+accTeamMemRecs.values());
            database.SaveResult[] myResult=database.insert(accTeamMemRecs.values(),false);
            for(database.SaveResult s:myResult){
                if(s.isSuccess()){
                    totalAtmSuccessess++;
                }
                else{
                    totalAtmFailures++;  
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        
        AsyncApexJob a = [Select Id,CreatedBy.Email    from AsyncApexJob where Id =:BC.getJobId()];
        system.debug('InvoicedSalesAccountShareBatch Completed! Sending Email to '+a.CreatedBy.Email);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('InvoicedSalesAccountShareBatch Completed!');
        mail.setPlainTextBody('TerritoryUsers Successess: ' + totalTuSuccessess +   ' Failures: '+ totalTuFailures + ' AccountShare Successess: ' + totalUsSuccessess +   ' Failures: '+ totalUsFailures + ' AccountTeamMember Successess: ' + totalAtmSuccessess +   ' Failures: '+ totalAtmFailures  );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    global void execute(SchedulableContext sc)
    {
        InvoicedSalesAccountShareBatch b = new  InvoicedSalesAccountShareBatch ();
        
        database.executebatch(b,200);
    }
}