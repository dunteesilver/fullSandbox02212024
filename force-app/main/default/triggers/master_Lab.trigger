trigger master_Lab on Lab__c (before insert, before update, after insert, after update) {
    System.debug('Running Master Trigger -------');
    
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('ib')){
        System.debug('INSERT and BEFORE trigger -------');
        
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('ia')){
        System.debug('INSERT and AFTER trigger -------');
        //formStack.addCampaign(Trigger.new);
        
    }     
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('ub')){
        System.debug('UPDATE and BEFORE trigger -------');
        
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('ua')){
        System.debug('UPDATE and AFTER trigger -------');
        //formStack.addCampaign(Trigger.new);
        
    }
}