trigger master_Territory_Alignment_Rules on Territory_Alignment__c (before insert, before update, after insert, after update) {
    
    System.debug('Running Territory Alignment Rules Master Trigger -------');
    
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('ib_Territory_Rules')){
        System.debug('INSERT and BEFORE trigger -------');
        territory_User_Assignment.setBusinessUnit(Trigger.new);
        
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('ia_Territory_Rules')){
        System.debug('INSERT and AFTER trigger -------');
    }     
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('ub_Territory_Rules')){
        System.debug('UPDATE and BEFORE trigger -------');
        territory_User_Assignment.setBusinessUnit(Trigger.new);
        
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('ua_Territory_Rules')){
        System.debug('UPDATE and AFTER trigger -------');
    }
}