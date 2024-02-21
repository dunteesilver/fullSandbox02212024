//Trigger created by Dunte'e Silver
trigger openDemoCheck on Demo__c (before insert, before update) {
   
    //list to hold Ids
    List<Id> vpsId = new List<Id>();
    
    for (Demo__c d : Trigger.new){
        //collect new rep Ids
        vpsId.add(d.VPS_Console__c);
    }    
          
    //list of VPS Units that are in progress
    List<Demo__c> inProg = [Select VPS_Console__c, Name From Demo__c Where VPS_Console__c  =:vpsId AND Status__c = 'In Progress'];
    
    for (Demo__c dem : Trigger.new){
        
        //check if any dupes in list
        if(inProg.size() > 0 && !Trigger.IsUpdate){
            String errorMessage = 'VPS Unit is already in use!';
            for(Demo__c demo : inProg){
                errorMessage += ' Please find record called ' + demo.Name + ' to be sure the demo status is complete before scheduling a new demo.';
                dem.addError(errorMessage);
            }
            
        }
        
    }

}