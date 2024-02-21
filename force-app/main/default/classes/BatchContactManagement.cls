/****************************************
Apex Class : BatchContactManagement
Description : Batch Class 
Author :  
****************************************/

global class BatchContactManagement implements Database.Batchable<sObject>, Database.stateful{
   
   
   Set<String> dupCheck = new Set<String>();
   Set<String> dupCheckwithoutAcc = new Set<String>();
   String outerfilterone= '001c000000i6zQs'; 
   global Database.QueryLocator start(Database.BatchableContext BC){    
        
        /*String query = 'SELECT Id,(Select id, firstname, lastname from contacts where owner.name LIKE '+ '\''+innerfilterOne + '\''+ 
                       ' or owner.name LIKE'+ '\'' + innerfilterTwo+ '\''+' ORDER BY LastModifiedDate Desc) FROM Account';
        */ 
        return Database.getQueryLocator('SELECT Id, FirstName, LastName, AccountId, OwnerId, owner.IsActive FROM Contact ORDER BY LastModifiedDate Desc');
   }

   global void execute(Database.BatchableContext BC, List<Sobject> scope){ 
        Map<id,contact> conLstdelete = new Map<id,contact>();
        
        
        for(sObject s : scope){
              Contact  c = (Contact)s;
              if(c.owner.IsActive == True){
                 if(c.AccountId != null){
                        string setKey = '';
                            if(c.FirstName != null)
                               setKey =  c.FirstName.toLowerCase() + '-'+ c.LastName.toLowerCase() +'-'+c.AccountId+ '-' + c.OwnerId;
                            else
                               setKey =  c.LastName.toLowerCase() +'-'+c.AccountId+ '-' + c.OwnerId;
                        if(dupCheck.contains(setKey)){
                            conLstdelete.put(c.Id, c);
                        }else{
                            dupCheck.add(setKey);
                        }
                 }else{
                        string setKey = '';
                        if(c.FirstName != null)
                           setKey = c.FirstName.toLowerCase() + '-'+ c.LastName.toLowerCase()+'-' + c.OwnerId;
                        else
                          setKey =  c.LastName.toLowerCase()+'-' + c.OwnerId;
                           
                        if(dupCheckwithoutAcc.contains(setKey)){
                            conLstdelete.put(c.Id, c);
                        }else{
                            dupCheckwithoutAcc.add(setKey);
                        }
                 }
              }else{
                   conLstdelete.put(c.Id,c);
              }
      }
        if(!conLstdelete.Isempty())
            delete conLstdelete.values();
    
   }

   global void finish(Database.BatchableContext BC){
             
   }

}