trigger master_CE_Reimbursement_Expense on CE_Reimbursement_Expense__c (before insert, before update, after insert, after update)  {

    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('EXP-INSERT-BEFORE')){
        System.debug('--- INSERT and BEFORE trigger (CE_Reimbursement_Expense__c) ----');
        CE_Reimbursement_Expense_Helper_Class.updateLookups(Trigger.new);
        Education_Helper_Class.cePayCheck(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('EXP-INSERT-AFTER')){
        System.debug('---- INSERT and AFTER trigger (CE_Reimbursement_Expense__c) ----');
        
    }
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('EXP-UPDATE-BEFORE')){
        System.debug('---- UPDATE and BEFORE trigger (CE_Reimbursement_Expense__c) ----');
        CE_Reimbursement_Expense_Helper_Class.updateLookups(Trigger.new);
        Education_Helper_Class.cePayCheck(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('EXP-UPDATE-AFTER')){
        System.debug('--- UPDATE and AFTER trigger (CE_Reimbursement_Expense__c) ----');
        CE_Reimbursement_Expense_Helper_Class.finalEmailtoAP(Trigger.new);
    }
}