trigger master_Territory_Quota on Territory_Quota__c (before insert, before update, after insert, after update)  {
    
    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('--- INSERT and BEFORE trigger (master_Territory_Quota) ----');
        territory_Quota_Helper_Class.tLookup(Trigger.new);
        Invoiced_Sales_Helper_Class.addOwnerAndSnaresRep2ISR(Trigger.new);
        //Invoiced_Sales_Helper_Class.addOwner(Trigger.new);
        Invoiced_Sales_Helper_Class.updateBusinessDay(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('---- INSERT and AFTER trigger (master_Territory_Quota) ----');
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('---- UPDATE and BEFORE trigger (master_Territory_Quota) ----');
        territory_Quota_Helper_Class.tLookup(Trigger.new);
        Invoiced_Sales_Helper_Class.addOwnerAndSnaresRep2ISR(Trigger.new);
        //Invoiced_Sales_Helper_Class.addOwner(Trigger.new);
        Invoiced_Sales_Helper_Class.updateBusinessDay(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('--- UPDATE and AFTER trigger (master_Territory_Quota) ----');
    }
       
}