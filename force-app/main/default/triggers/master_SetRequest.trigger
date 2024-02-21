trigger master_SetRequest on Set_Request__c (before insert, before update, after insert, after update, after delete) {
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('SetRequest-INSERT-BEFORE')){
        System.debug('INSERT and BEFORE trigger -------');

    }

    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('SetRequest-INSERT-AFTER')){
        System.debug('INSERT and AFTER trigger -------');
        //Pass Set Request records to class to auto-submit for approval
        autoSubmitRecords submitSetRequest = new autoSubmitRecords();
        submitSetRequest.autoSubmit(Trigger.new,Trigger.oldMap,'isInsert');
    }

    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('SetRequest-UPDATE-BEFORE')){
        System.debug('UPDATE and BEFORE trigger -------');
    }

    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('SetRequest-UPDATE-AFTER')){
        System.debug('UPDATE and AFTER trigger -------');
        //Pass Set Request records to class to auto-submit for approval
        autoSubmitRecords submitSetRequest = new autoSubmitRecords();
        submitSetRequest.autoSubmit(Trigger.new,Trigger.oldMap,'isUpdate');
    }

    if(Trigger.isDelete && Trigger.isAfter && master_TriggerHelperClass.runOnce('SetRequest-DELETE')){
        System.debug('DELETE and AFTER trigger -------');
    }
}