global class findDuplicateContactsBatch implements Database.Batchable<sObject> ,Database.Stateful {
    Set<String> isContactProcessed = new Set<String>{}; 
    
    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, FirstName, LastName, AccountId, OwnerId FROM Contact');
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        List<Duplicate_Contact__c> duplicateContactList = new List<Duplicate_Contact__c>();
        for(Contact c : scope){
            string setKey = c.FirstName+'-'+c.LastName+'-'+c.AccountId;
            if(!isContactProcessed.contains(setKey)){
                List<Contact> con = [Select Id, OwnerId, AccountId from Contact where FirstName =: c.FirstName and LastName =: c.LastName and AccountId =: c.AccountId];
                if(con.size()>1){ 
                    isContactProcessed.add(setKey);
                    for(Contact c1:con){
                        Duplicate_Contact__c dupCon = new Duplicate_Contact__c();
                        dupCon.Account__c = c1.AccountId;
                        dupCon.Contact__c = c1.Id;
                        dupCon.Contact_Owner__c   = c1.OwnerId;
                        duplicateContactList.add(dupCon); 
                    }
                }   
            }
        }
        if(!duplicateContactList.isEmpty()){
                Database.SaveResult[] srList = Database.insert(duplicateContactList, true);//failing for inactive users added allornone as false    
                // check the failed record and try again with cleaned data
                List<Duplicate_Contact__c> lstDupContactsToBeTriedAgain = new List<Duplicate_Contact__c>();
                for (integer i=0; i< srList.size(); i++){
                    Database.SaveResult sr = srList[i];
                    if (sr.isSuccess() == false){
                        // Operation failed, so get all errors  
                        boolean tryAgain = false;              
                        for(Database.Error err : sr.getErrors()) {
                            if(err.getMessage().contains('INACTIVE_OWNER_OR_USER')){
                                tryAgain = true;
                            }
                            
                        }
                        if(tryAgain == true){
                            Duplicate_Contact__c dc = duplicateContactList[i];
                            dc.Contact_Owner__c = null;
                            lstDupContactsToBeTriedAgain.add(dc);
                        }
                        tryAgain = false;
                    }
                }
                if(lstDupContactsToBeTriedAgain.isEmpty() == false){
                    insert lstDupContactsToBeTriedAgain;
                }
        }
        
    }
    global void finish(Database.BatchableContext BC){
            
    }


}