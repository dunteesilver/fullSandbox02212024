trigger master_Invoiced_Sales_Tracking on Invoiced_Sales_Tracking__c(before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('--- INSERT and BEFORE trigger (master_Invoiced_Sales_Tracking) ----');
        //Invoiced_Sales_Tracking_Class.addShipping(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('---- INSERT and AFTER trigger (master_Invoiced_Sales_Tracking) ----');
        Invoiced_Sales_Tracking_Class.addShipping(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('---- UPDATE and BEFORE trigger (master_Invoiced_Sales_Tracking) ----');
        //Invoiced_Sales_Tracking_Class.addShipping(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('--- UPDATE and AFTER trigger (master_Invoiced_Sales_Tracking) ----');
        Invoiced_Sales_Tracking_Class.addShipping(Trigger.new);
    }
}