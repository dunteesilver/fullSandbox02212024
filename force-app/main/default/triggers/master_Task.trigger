trigger master_Task on Task (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('TASK-INSERT-BEFORE')){
        System.debug('TASK [1]-INSERT and BEFORE trigger -------');
        task_Helper_Class.addTerritory(Trigger.new);
        task_Helper_Class.addNewProductTracking(Trigger.new);
        task_Helper_Class.addLookups(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('TASK-INSERT-AFTER')){
        System.debug('TASK [2]-INSERT and AFTER trigger -------');
        task_Helper_Class.eloquaTaskUpdate(Trigger.new);
        task_Helper_Class.oppPrimaryCampaignAdd(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('TASK-UPDATE-BEFORE')){
        System.debug('TASK [3]-UPDATE and BEFORE trigger -------');
        task_Helper_Class.addTerritory(Trigger.new);
        task_Helper_Class.addNewProductTracking(Trigger.new);
        task_Helper_Class.addLookups(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('TASK-UPDATE-AFTER')){
        System.debug('TASK [4]-UPDATE and AFTER trigger -------');
        //PP_Opportunity_Sync.updatePQ(Trigger.new,Trigger.oldmap,'update');
        task_Helper_Class.eloquaTaskUpdate(Trigger.new);
        task_Helper_Class.oppPrimaryCampaignAdd(Trigger.new);
    }
}