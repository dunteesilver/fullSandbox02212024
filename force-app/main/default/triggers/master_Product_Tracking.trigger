trigger master_Product_Tracking on Product_Tracking__c (before insert, before update, after insert, after update)  {
    
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('PRODTRACKING-INSERT-BEFORE')){
        System.debug('--- INSERT and BEFORE trigger (master_Product_Tracking) ----');
        Product_Tracking_Helper_Class.addAccount(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('PRODTRACKING-INSERT-AFTER')){
        System.debug('---- INSERT and AFTER trigger (master_Product_Tracking) ----');
        Product_Tracking_Helper_Class.setProductOfInterest(Trigger.new,Trigger.oldmap,'insert');
    }

    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('PRODTRACKING-UPDATE-BEFORE')){
        System.debug('---- UPDATE and BEFORE trigger (master_Product_Tracking) ----');
        Product_Tracking_Helper_Class.addAccount(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('PRODTRACKING-UPDATE-AFTER')){
        System.debug('--- UPDATE and AFTER trigger (master_Product_Tracking) runOnce ----');
        Product_Tracking_Helper_Class.setProductOfInterest(Trigger.new,Trigger.oldmap,'Update');
    }
}