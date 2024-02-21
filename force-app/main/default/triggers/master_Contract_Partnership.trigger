trigger master_Contract_Partnership on Contract_Partnership__c (before insert, before update, after insert, after update)  {
    
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('CPARTNER-INSERT-BEFORE')){
        System.debug('--- INSERT and BEFORE trigger (master_Contract_Partnership) ----');
        Contract_Partnership_Helper_Class.validateAccount(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('CPARTNER-INSERT-AFTER')){
        System.debug('---- INSERT and AFTER trigger (master_Contract_Partnership) ----');
    }

    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('CPARTNER-UPDATE-BEFORE')){
        System.debug('---- UPDATE and BEFORE trigger (master_Contract_Partnership) ----');
        Contract_Partnership_Helper_Class.validateAccount(Trigger.new);

    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('CPARTNER-UPDATE-AFTER')){
        System.debug('--- UPDATE and AFTER trigger (master_Contract_Partnership) runOnce ----');
        //PP_Opportunity_Sync.updateOpp(Trigger.new,Trigger.oldmap,'update');
        //PP_Price_Quote_Helper_Class.setPQDefaults(Trigger.new,Trigger.oldmap,'update');
    }
}