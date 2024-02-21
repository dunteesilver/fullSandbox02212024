trigger master_survey_education on Survey_Education__c (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('ib')){
        System.debug('--- INSERT and BEFORE trigger (master_survey_education) ----');
        survey_education_Helper_Class.fixMultiSelects(Trigger.new);
        //PP_Price_Quote.checkSalesOrg(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('ia')){
        System.debug('---- INSERT and AFTER trigger (master_survey_education) ----');
    }     
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('ub')){
        System.debug('---- UPDATE and BEFORE trigger (master_survey_education) ----');
        survey_education_Helper_Class.fixMultiSelects(Trigger.new);
        //PP_Price_Quote.checkSalesOrg(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('ua')){
        System.debug('--- UPDATE and AFTER trigger (master_survey_education) ----');
        //PP_Opportunity_Sync.updateSync(Trigger.new,Trigger.oldmap);
    }   
}