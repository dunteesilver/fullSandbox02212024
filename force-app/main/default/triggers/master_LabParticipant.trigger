trigger master_LabParticipant on Lab_Participant__c (before insert, before update, after insert, after update) {
    System.debug('Running Master Trigger -------');
    
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('ib_Lab_Participant__c')){
        System.debug('INSERT and BEFORE trigger -------');
        //formStack.cloneUser(Trigger.new);
        //formStack.zipLookup_Before(Trigger.new);
        formStack.lpAddressFix(Trigger.new,Trigger.oldmap,'insert');
        formStack.assignLabUser(Trigger.new,Trigger.oldmap,'insert');
        //formStack.beforealtassignApprover(Trigger.new);
        //formStack.assignApprover_Before(Trigger.new);        
        //formStack.Mega3Class(Trigger.new);

    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('ia_Lab_Participant__c')){
        System.debug('INSERT and AFTER trigger -------');
        //formStack.assignApprover(Trigger.new);
        //formStack.altassignApprover(Trigger.new);
        //formStack.approval(Trigger.new);
    }     
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('ub_Lab_Participant__c')){
        System.debug('UPDATE and BEFORE trigger -------');
        //formStack.zipLookup_Before(Trigger.new);
        formStack.lpAddressFix(Trigger.new,Trigger.oldmap,'update');
        formStack.assignLabUser(Trigger.new,Trigger.oldmap,'update');
        //formStack.beforealtassignApprover(Trigger.new);
        //formStack.updateApprover(Trigger.new); 
        //formStack.Mega3Class(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('ua_Lab_Participant__c')){
        System.debug('UPDATE and AFTER trigger -------');
        //formStack.assignApprover(Trigger.new);
        //formStack.altassignApprover(Trigger.new);
        //formStack.approval(Trigger.new);
    }
}