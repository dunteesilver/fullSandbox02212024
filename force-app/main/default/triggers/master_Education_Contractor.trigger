trigger master_Education_Contractor on Education_Contractor__c (before insert, before update, after insert, after update)  {

    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('EDCON-INSERT-BEFORE')){
        System.debug('--- INSERT and BEFORE trigger (Education_Contractor__c) ----');
        Education_Helper_Class.ecCheck(Trigger.new);
        Education_Helper_Class.addLookups(Trigger.new);

    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('EDCON-INSERT-AFTER')){
        System.debug('---- INSERT and AFTER trigger (Education_Contractor__c) ----');
    }
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('EDCON-UPDATE-BEFORE')){
        System.debug('---- UPDATE and BEFORE trigger (Education_Contractor__c) ----');
        Education_Helper_Class.ecCheck(Trigger.new);
        Education_Helper_Class.addLookups(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('EDCON-UPDATE-AFTER')){
        System.debug('--- UPDATE and AFTER trigger (Education_Contractor__c) ----');
    }
}