trigger master_User on User (before insert, before update, after insert, after update) {
    system.debug('-- Starting User Trigger -- ');
    
    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('-- Starting INSERT and BEFORE trigger -------');
        user_Helper_Class.beforeHelper(Trigger.new,Trigger.oldmap,'insert');
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('ia')){
        System.debug('-- Starting INSERT and AFTER trigger -------');
        
    }     
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('ub')){
        System.debug('-- Starting UPDATE and BEFORE trigger -------');
        user_Helper_Class.beforeHelper(Trigger.new,Trigger.oldmap,'update');
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('ua')){
        System.debug('-- Starting UPDATE and AFTER trigger -------');
    }   

}