trigger master_CaseTrigger on Case (before insert, before update, after insert, after update) {
    
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('InsBefore-Case')){
        System.debug('INSERT and BEFORE trigger -------');
        case_RemedyCaseFix.stripDesc(Trigger.new);
        case_RemedyCaseFix.fixEmail(Trigger.new,Trigger.oldmap,'insert');
        //case_Helper_Class.reassignCases(Trigger.new,Trigger.oldmap,'insert');
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('InsAfter-Case')){
        System.debug('INSERT and BEFORE trigger -------');
        case_RemedyCaseFix.addToCaseTeam(Trigger.new,Trigger.oldmap,'insert');
        case_RemedyCaseFix.fixBUinsert(Trigger.new);
        
    }    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('UpdBefore-Case')){
        System.debug('UPDATE and BEFORE trigger -------');
        case_RemedyCaseFix.fixBU(Trigger.new,Trigger.oldmap);
        case_RemedyCaseFix.fixEmail(Trigger.new,Trigger.oldmap,'update');

    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('UpdAfter-Case')){
        System.debug('UPDATE and AFTER trigger -------');
        case_RemedyCaseFix.addToCaseTeam(Trigger.new,Trigger.oldmap,'update');
    }
    
}