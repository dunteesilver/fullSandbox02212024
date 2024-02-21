trigger master_Open_Orders on Open_Orders__c (before insert, before update, after insert, after update)  {
    //if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('OPENORDERS-INSERT-BEFORE')){
    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('--- INSERT and BEFORE trigger (master_Price_Quote) ----');
        Invoiced_Sales_Helper_Class.currencyReset(Trigger.new);
        Invoiced_Sales_Helper_Class.fixOpenOrderKeys(Trigger.new);
        Invoiced_Sales_Helper_Class.addLookups(Trigger.new,'Open_Orders__c');
        Invoiced_Sales_Helper_Class.newProductTracking(Trigger.new);
        Invoiced_Sales_Helper_Class.addCompensatory(Trigger.new,'Open_Orders__c');
        Invoiced_Sales_Helper_Class.addOwnerAndSnaresRep2ISR(Trigger.new);
        //Invoiced_Sales_Helper_Class.addOwner(Trigger.new);
        Invoiced_Sales_Helper_Class.backupAlternatives(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('---- INSERT and AFTER trigger (master_Price_Quote) ----');
    }

    //if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('OPENORDERS-UPDATE-BEFORE')){
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('---- UPDATE and BEFORE trigger (master_Open_Orders) ----');
        Invoiced_Sales_Helper_Class.currencyReset(Trigger.new);
        Invoiced_Sales_Helper_Class.fixOpenOrderKeys(Trigger.new);      
        Invoiced_Sales_Helper_Class.addLookups(Trigger.new,'Open_Orders__c');
        Invoiced_Sales_Helper_Class.newProductTracking(Trigger.new);
        Invoiced_Sales_Helper_Class.addCompensatory(Trigger.new,'Open_Orders__c');
        Invoiced_Sales_Helper_Class.addOwnerAndSnaresRep2ISR(Trigger.new);
        //Invoiced_Sales_Helper_Class.addOwner(Trigger.new);
        Invoiced_Sales_Helper_Class.backupAlternatives(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('OPENORDERS-UPDATE-AFTER')){
        System.debug('--- UPDATE and AFTER trigger (master_Price_Quote) ----');
        Invoiced_Sales_Helper_Class.addAccountAfter(Trigger.new);
    }
}