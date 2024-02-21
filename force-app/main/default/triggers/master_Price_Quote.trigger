trigger master_Price_Quote on Price_Quote__c (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('PQ-INSERT-BEFORE')){
        System.debug('--- INSERT and BEFORE trigger (master_Price_Quote) ----');
        PP_Price_Quote_Helper_Class.setPQDefaults(Trigger.new,Trigger.oldmap,'insert');
        PP_Price_Quote_Helper_Class.checkSalesOrg(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('PQ-INSERT-AFTER')){
    //if(Trigger.isInsert && Trigger.isAfter){
        System.debug('---- INSERT and AFTER trigger (master_Price_Quote) ----');
        PP_Opportunity_Sync.updateOpp(Trigger.new,Trigger.oldmap,'insert');
        PP_Price_Quote_Helper_Class.autoCreateNewOpp(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('PQ-UPDATE-BEFORE')){
        System.debug('---- UPDATE and BEFORE trigger (master_Price_Quote) ----');
        PP_Price_Quote_Helper_Class.checkSalesOrg(Trigger.new);

    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('PQ-UPDATE-AFTER')){
        System.debug('--- UPDATE and AFTER trigger (master_Price_Quote) runOnce ----');
        PP_Opportunity_Sync.updateOpp(Trigger.new,Trigger.oldmap,'update');
        PP_Price_Quote_Helper_Class.setPQDefaults(Trigger.new,Trigger.oldmap,'update');
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('--- UPDATE and AFTER trigger (master_Price_Quote) ----');
        //PP_Price_Quote_Helper_Class.assignApprover(Trigger.new,Trigger.oldmap);
    }
}