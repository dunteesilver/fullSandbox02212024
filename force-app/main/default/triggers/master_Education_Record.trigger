trigger master_Education_Record on Education_Record__c (before insert, before update, after insert, after update)  {

    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('CE-INSERT-BEFORE')){
        System.debug('--- INSERT and BEFORE trigger (Education_Record__c) ----');
        Education_Helper_Class.addERLookups(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('CE-INSERT-AFTER')){
        System.debug('---- INSERT and AFTER trigger (Education_Record__c) ----');

    }
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('CE-UPDATE-BEFORE')){
        System.debug('---- UPDATE and BEFORE trigger (Education_Record__c) ----');
        Education_Helper_Class.addERLookups(Trigger.new);
        Education_Helper_Class.TrainingComplete(Trigger.new);
        Education_Helper_Class.LiveTrainingValidations(Trigger.new,Trigger.oldmap);
        Education_Helper_Class.createLegacyEducators(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('CE-UPDATE-AFTER')){
        System.debug('--- UPDATE and AFTER trigger (Education_Record__c) ----');
        Education_Helper_Class.updateCEApprovalStatus(Trigger.new,Trigger.oldmap);
        Education_Helper_Class.CreateCRFs(Trigger.new);
        Education_Helper_Class.flipCRFs(Trigger.new);
    }
}