trigger master_Opportunity_Line_Items on OpportunityLineItem (before insert, before update, after insert, after update, after delete) {
    
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('OLI-INSERT-BEFORE')){
        System.debug('INSERT and BEFORE trigger -------');

    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('OLI-INSERT-AFTER')){
        System.debug('INSERT and AFTER trigger -------');
        //PP_Opportunity_Sync.addOpportunityLines(Trigger.new);
    }     
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('OLI-UPDATE-BEFORE')){
        System.debug('UPDATE and BEFORE trigger -------');
        //territory_User_Assignment.assignUser(Trigger.new,Trigger.oldmap,'update');

    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('OLI-UPDATE-AFTER')){
        System.debug('UPDATE and AFTER trigger -------');
        //formStack.addMember(Trigger.new);
        //price_Book_Sync.checkProducts(Trigger.new);
    }
    if(Trigger.isDelete && Trigger.isAfter && master_TriggerHelperClass.runOnce('OLI-DELETE')){
        PP_Opportunity_Sync.remove_PQOLI_ID(Trigger.old);
    }

}