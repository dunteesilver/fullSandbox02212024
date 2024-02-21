trigger oppContactRole on Opportunity (after insert, after update) {

    List<OpportunityContactRole> addConRole = new List<OpportunityContactRole>();
    
    // Inserts - Create the Contact Role
    if(Trigger.isInsert && Trigger.isAfter){
        for(Opportunity curr : Trigger.New){
            if(curr.Primary_Contact__c != NULL){
                OpportunityContactRole ocr = new OpportunityContactRole();
                ocr.OpportunityId = curr.Id;
                if(curr.Primary_Contact_Id__c != NULL){
                    ocr.ContactId = curr.Primary_Contact_Id__c;
                }
                else{
                    ocr.ContactId = curr.Primary_Contact__c;    
                }
                
                ocr.Role = 'Decision Maker';
                //insert ocr;
                addConRole.add(ocr);
            }
            
        }//end for loop
        
        if(addConRole.size()>0){
            insert addConRole;
        }
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        map<id,boolean> ocrCheck = new map<id,boolean>();
        
        for(OpportunityContactRole ocr : [SELECT ContactId 
                                          FROM OpportunityContactRole 
                                          WHERE OpportunityId =:Trigger.New])
        {
            ocrCheck.put(ocr.ContactId, TRUE);
        }
        
        for(Opportunity o : Trigger.New){
            if(Trigger.oldMap.get(o.Id).Primary_Contact__c != o.Primary_Contact__c){
                if(ocrCheck.get(o.Primary_Contact__c) == NULL){
                    OpportunityContactRole ocr = new OpportunityContactRole();
                    ocr.OpportunityId = o.Id;
                    ocr.ContactId = o.Primary_Contact__c;
                    ocr.Role = 'Decision Maker';
                    //insert ocr;
                    addConRole.add(ocr);
                }
                if(addConRole.size()>0){
                    insert addConRole;
                }
            }
        }
    }
    
//    
/*
  List<Id> oppIds = new List<Id>();
  Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
  Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();

  for(Opportunity o : Trigger.New){

    if(Trigger.isInsert){
      oppIds.add(o.Id);
      oppMap.put(o.Id,o);
    }//end of if isInsert

    if(Trigger.isUpdate &&
        [SELECT count() FROM OpportunityContactRole WHERE OpportunityId =:o.Id 
         AND ContactId =:o.Primary_Contact__c ] == 0){

      Opportunity oldOpp = Trigger.oldMap.get(o.Id);
      if(o.Primary_Contact__c != oldOpp.Primary_Contact__c){
        oppIds.add(o.Id);
        oppMap.put(o.Id,o);
      }
    }//end of if isUpdate

  }//end for loop

  List<Opportunity> newOpps = [SELECT Id, Primary_Contact__c FROM Opportunity WHERE Id IN :oppIds];
    
    
    
  if(Trigger.IsUpdate ){
    for(Opportunity curr : newOpps){
      OpportunityContactRole ocr = new OpportunityContactRole();
      ocr.OpportunityId = oppMap.get(curr.Id).Id;
      ocr.ContactId = oppMap.get(curr.Id).Primary_Contact__c;
      ocr.Role = 'Decision Maker';
      //insert ocr;
      addConRole.add(ocr);
    }//end for loop

    if(addConRole.size()>0){
      insert addConRole;
    }
  }
*/

}