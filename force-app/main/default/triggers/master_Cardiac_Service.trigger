trigger master_Cardiac_Service on Survey_Cardiac_Service__c (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('SCS-INSERT-BEFORE')){
        System.debug('SCS [1]-INSERT and BEFORE trigger -------');
        cardiac_Survey_Helper_Class.fixMultiSelects(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('SCS-INSERT-AFTER')){
        System.debug('SCS [2]-INSERT and AFTER trigger -------');
    }
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('SCS-UPDATE-BEFORE')){
        System.debug('SCS [3]-UPDATE and BEFORE trigger -------');
        cardiac_Survey_Helper_Class.fixMultiSelects(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('SCS-UPDATE-AFTER')){
        System.debug('SCS [4]-UPDATE and AFTER trigger -------');
    }
}