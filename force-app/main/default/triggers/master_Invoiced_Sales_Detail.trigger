trigger master_Invoiced_Sales_Detail on Invoiced_Sales_Detail__c (before insert, before update, after insert, after update)  {

    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('--- INSERT and BEFORE trigger (master_Price_Quote) ----');
        Invoiced_Sales_Helper_Class.addLookups(Trigger.new,'Invoiced_Sales_Detail__c');
        Invoiced_Sales_Helper_Class.checkProduct(Trigger.new);
        Invoiced_Sales_Helper_Class.newProductTracking(Trigger.new);
        Invoiced_Sales_Helper_Class.currencyReset(Trigger.new);
        Invoiced_Sales_Helper_Class.addCompensatory(Trigger.new,'Invoiced_Sales_Detail__c');
        Invoiced_Sales_Helper_Class.addOwnerAndSnaresRep2ISR(Trigger.new);
        //Invoiced_Sales_Helper_Class.addOwner(Trigger.new);
        Invoiced_Sales_Helper_Class.updateBusinessDay(Trigger.new);
        Invoiced_Sales_Helper_Class.addShipping(Trigger.new);
        Invoiced_Sales_Helper_Class.updateDayNumber(Trigger.new,'Invoiced_Sales_Detail__c');
    }
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('---- INSERT and AFTER trigger (master_Price_Quote) ----');
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('---- UPDATE and BEFORE trigger (master_Price_Quote) ----');
        Invoiced_Sales_Helper_Class.addLookups(Trigger.new,'Invoiced_Sales_Detail__c');
        Invoiced_Sales_Helper_Class.checkProduct(Trigger.new);
        Invoiced_Sales_Helper_Class.newProductTracking(Trigger.new);
        Invoiced_Sales_Helper_Class.currencyReset(Trigger.new);
        Invoiced_Sales_Helper_Class.addCompensatory(Trigger.new,'Invoiced_Sales_Detail__c');
        Invoiced_Sales_Helper_Class.addOwnerAndSnaresRep2ISR(Trigger.new);
        //Invoiced_Sales_Helper_Class.addOwner(Trigger.new);
        Invoiced_Sales_Helper_Class.updateBusinessDay(Trigger.new);
        Invoiced_Sales_Helper_Class.addShipping(Trigger.new);   
        Invoiced_Sales_Helper_Class.updateDayNumber(Trigger.new,'Invoiced_Sales_Detail__c');
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('--- UPDATE and AFTER trigger (master_Price_Quote) ----');
        Invoiced_Sales_Helper_Class.addAccountAfter(Trigger.new);
    }
}