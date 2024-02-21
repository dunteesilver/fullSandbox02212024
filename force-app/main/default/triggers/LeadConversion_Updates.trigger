/*
Created by: Dun Silver
Purpose:  Trigger maps the converted lead description and Primary Contact to the Opportunity.
          Trigger also updates the Opportunity field on the child object
          called Product Tracking that has an Opportunity lookup.

*/

trigger LeadConversion_Updates on Lead (before insert, before update, after insert, after update) {
    /*
    if((Trigger.isInsert && Trigger.isBefore) || (Trigger.isUpdate && Trigger.isBefore)){
        for(Lead l : trigger.new){
            if(l.Contact_ID__c == NULL && l.Contact__c != NULL){
                l.Contact_ID__c = l.Contact__c;
            }
        }
    }*/
    
    /*
    if((Trigger.isInsert && Trigger.isAfter) || (Trigger.isUpdate && Trigger.isAfter)){
        List<Opportunity> oUpdList = new List<Opportunity> ();
        Product_Tracking__c trackList = new Product_Tracking__c();
        list<Lead> leadList = new list<Lead>();
        for (Lead l : Trigger.new){
            if(
                (l.IsConverted && String.isNotBlank(l.Existing_Opportunity__c))
                ||
                (l.IsConverted && l.convertedOpportunityId != null)
                )
            {
                leadList.add(l);                
            }
        }
        if(leadList.size() > 0){
            // New - 07Jul2017 - ESC
            list<Product_Tracking__c> updatePT = new list<Product_Tracking__c>();
            map<Id, Product_Tracking__c> ptMap = new map<Id, Product_Tracking__c>();
            for(Product_Tracking__c pt : [Select Id, Lead__r.Id, Opportunity__c
                                          From Product_Tracking__c Where Lead__r.Id IN: Trigger.New])
            {
                ptMap.put(pt.Lead__r.Id, pt);
            }
            // END
            
            
            
            //loop through leads to check if it is converted and then copies over info
            for (Lead l : Trigger.new){
                if(l.IsConverted && String.isNotBlank(l.Existing_Opportunity__c)){
                    system.debug('***** Made it inside of 1st If(l.IsConverted) *****');
                    oUpdList.add(new Opportunity(id = l.Existing_Opportunity__c,Amount=l.Amount__c,
                                                 description = l.Existing_Opportunity__r.Description + '\n' + l.description));
                }else{
                    system.debug('***** Made it inside of 1st Esle after (l.IsConverted) *****');
                    if (l.IsConverted && l.convertedOpportunityId != null){
                        oUpdList.add(new Opportunity(id = l.convertedOpportunityId,StageName='Qualified Prospect',
                                                     description = l.description,Amount=l.Amount__c,
                                                     primary_contact__c = l.convertedContactId));
                        try{
                            if(ptMap.containsKey(l.Id)){
                                Product_Tracking__c newPT = new Product_Tracking__c(
                                    Id = ptMap.get(l.Id).Id,
                                    Opportunity__c = l.ConvertedOpportunityId
                                );
                                updatePT.add(newPT);
                            }
                            
                        }
                        catch(Exception e){
                            System.debug('An unexpected error has occurred: ' + e.getMessage());
                        }
                    }//END IF
                }//END ELSE
                
            }//END FOR LOOP
            
            system.debug('=========== oUpdList: ' + oUpdList);
            system.debug('***** oUpdList.size() ***** ' + oUpdList.size());
            if(oUpdList.size()>0){
                update oUpdList;  // for bulk loads Database.update(oUpdList,false) if you want partial successes
            }
            if(updatePT.size() > 0){
                update updatePT;
            }
        }
        
    }
    */
}