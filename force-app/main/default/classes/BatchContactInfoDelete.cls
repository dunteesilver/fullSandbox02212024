/****************************************
Apex Class :  BatchContactInfoValidate
Description : Batch Class 
Author :  
****************************************/

global class BatchContactInfoDelete implements Database.Batchable<sObject>,Database.stateful{
    Set<String> checkEmailStrlst = new Set<String> ();
    global Database.QueryLocator start(Database.BatchableContext BC){    
        
        String query = 'SELECT Id, FirstName, LastName, AccountId,email, phone,owner.email, ownerId,owner.Name FROM Contact where AccountId = null and Email = null and Phone = null and MobilePhone = null';
        System.Debug('Main Query'+query);
        return Database.getQueryLocator(query);
     }

     global void execute(Database.BatchableContext BC, List<Sobject> scope){ 
        List<contact> lstContact = (List<contact>) scope;
        if(!lstContact.isEmpty())
            delete lstContact;
         
     }

     global void finish(Database.BatchableContext BC){
             
     }
     
     
}