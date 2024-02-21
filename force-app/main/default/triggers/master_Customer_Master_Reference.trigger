trigger master_Customer_Master_Reference on Customer_Master_Reference__c (before insert, before update, after insert, after update)  {

    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('--- INSERT and BEFORE trigger (Customer_Master_Reference) ----');
    }
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('---- INSERT and AFTER trigger (Customer_Master_Reference) ----');
        Customer_Master_Reference_Helper_Class.checkZblock(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('---- UPDATE and BEFORE trigger (Customer_Master_Reference) ----');
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('--- UPDATE and AFTER trigger (Customer_Master_Reference) ----');
        Customer_Master_Reference_Helper_Class.checkZblock(Trigger.new);
    }
}