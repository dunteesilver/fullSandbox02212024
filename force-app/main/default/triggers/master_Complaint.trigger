trigger master_Complaint on Complaint__c (before insert, before update, after insert, after update, after delete) {

    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('Complaint-INSERT-BEFORE')){
        System.debug('INSERT and BEFORE trigger -------');
    }

    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('Complaint-INSERT-AFTER')){
        System.debug('INSERT and AFTER trigger -------');
        autoSubmitRecords submitComplaint = new autoSubmitRecords();
        submitComplaint.autoSubmit(Trigger.new,Trigger.oldMap,'isInsert');
    }

    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('Complaint-UPDATE-BEFORE')){
        System.debug('UPDATE and BEFORE trigger -------');
        for(Complaint__c com: trigger.new){
            if(com.Status__c != trigger.oldMap.get(com.Id).Status__c && com.Status__c == 'Rejected'){
                com.LastRejectedBy__c = UserInfo.getUserId();
                com.RejectedDateTime__c = system.now();
            }
        }
    }

    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('Complaint-UPDATE-AFTER')){
        System.debug('UPDATE and AFTER trigger -------');
        //Pass complaint records to class to auto-submit for approval
        autoSubmitRecords submitComplaint = new autoSubmitRecords();
        submitComplaint.autoSubmit(Trigger.new,Trigger.oldMap,'isUpdate');

        //Pass Complaint records to ComplaintIntegrationExtension for SAP Integration
        ComplaintIntegrationExtension sapInsert = new ComplaintIntegrationExtension();
        sapInsert.createSapComplaint(Trigger.new);
    }

    if(Trigger.isDelete && Trigger.isAfter && master_TriggerHelperClass.runOnce('Complaint-DELETE')){
        System.debug('DELETE and AFTER trigger -------');

    }
}//end of trigger