trigger master_PRF on PRF__c (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('ib')){
        System.debug('--- INSERT and BEFORE trigger (master_PRF) ----');
        PP_PRF.checkSalesOrg(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('ia')){
    //if(Trigger.isInsert && Trigger.isAfter){
        System.debug('---- INSERT and AFTER trigger (master_PRF) ----');
    }     
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('ub')){
        System.debug('---- UPDATE and BEFORE trigger (master_PRF) ----');
        PP_PRF.checkSalesOrg(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('ua')){
        System.debug('--- UPDATE and AFTER trigger (master_PRF) ----');
    }     
}