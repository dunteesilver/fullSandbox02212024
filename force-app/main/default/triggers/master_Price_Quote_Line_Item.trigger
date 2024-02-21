trigger master_Price_Quote_Line_Item on Price_Quote_Line_Item__c (before insert, before update, after insert, after update, after delete) {
    
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('PQLI-INSERT-BEFORE')){
        System.debug('INSERT and BEFORE trigger -------');
        //PP_Price_Quote_Helper_Class.fixSalesDealLookup(Trigger.new);
        PP_General_Helper_Class.addContractLookup(Trigger.new,'PQ');
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('PQLI-INSERT-AFTER')){
        System.debug('INSERT and AFTER trigger -------');
        PP_Opportunity_Sync.addOLI(Trigger.new);
    }     
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('PQLI-UPDATE-BEFORE')){
        System.debug('UPDATE and BEFORE trigger -------');
        PP_General_Helper_Class.addContractLookup(Trigger.new,'PQ');
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('PQLI-UPDATE-AFTER')){
        System.debug('UPDATE and AFTER trigger -------');
        PP_Opportunity_Sync.updateOLI(Trigger.new);
    }
    if(Trigger.isDelete && Trigger.isAfter && master_TriggerHelperClass.runOnce('PQLI-DELETE')){
        System.debug('DELETE and AFTER trigger -------');
        PP_Opportunity_Sync.delOpportunityLines_trigger(Trigger.old);
    }

}