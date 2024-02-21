trigger master_Sample_Request_Line_Item on Sample_Request_Line_Item__c(before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('--- INSERT and BEFORE trigger (master_Sample_Request_Line_Item) ----');
    }
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('---- INSERT and AFTER trigger (master_Sample_Request_Line_Item) ----');
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('---- UPDATE and BEFORE trigger (master_Sample_Request_Line_Item) ----');
        Sample_Request_Line_Item_Class.manuallyLockSampleRequestLineItems(Trigger.new, Trigger.old);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('--- UPDATE and AFTER trigger (master_Sample_Request_Line_Item) ----');
        Sample_Request_Line_Item_Class.manuallyLockSampleRequestLineItems(Trigger.new, Trigger.old);
    }
}