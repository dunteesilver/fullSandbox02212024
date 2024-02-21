trigger master_Invoiced_Sales on Invoiced_Sales__c (before insert, before update, after insert, after update, after delete)  {

    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('--- INSERT and BEFORE trigger (master_Price_Quote) ----');
        Invoiced_Sales_Helper_Class.addLookups(Trigger.new,'Invoiced_Sales__c');
        Invoiced_Sales_Helper_Class.checkProduct(Trigger.new);
        Invoiced_Sales_Helper_Class.newProductTracking(Trigger.new);
        Invoiced_Sales_Helper_Class.currencyReset(Trigger.new);
        Invoiced_Sales_Helper_Class.addCompensatory(Trigger.new,'Invoiced_Sales__c');
        Invoiced_Sales_Helper_Class.addOwnerAndSnaresRep2ISR(Trigger.new);
        //Invoiced_Sales_Helper_Class.addOwner(Trigger.new);
        Invoiced_Sales_Helper_Class.updateBusinessDay(Trigger.new);
        Invoiced_Sales_Helper_Class.updateDayNumber(Trigger.new,'Invoiced_Sales__c');
    }
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('---- INSERT and AFTER trigger (master_Price_Quote) ----');
        
        //surya for rolling TAM sales
        //initial version work item: W-023184 sprint: 2020.04
        List<Id> AccountIds = new List<Id>();
        for(Invoiced_Sales__c invSalObj : Trigger.New) if(invSalObj.Account__c != null) AccountIds.add(invSalObj.Account__c);
        TAMInvoicedSalesHandler.rollingInvSalesFrmInvSalTgr(AccountIds);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('---- UPDATE and BEFORE trigger (master_Price_Quote) ----');
        Invoiced_Sales_Helper_Class.addLookups(Trigger.new,'Invoiced_Sales__c');
        Invoiced_Sales_Helper_Class.checkProduct(Trigger.new);
        Invoiced_Sales_Helper_Class.newProductTracking(Trigger.new);
        Invoiced_Sales_Helper_Class.currencyReset(Trigger.new);
        Invoiced_Sales_Helper_Class.addCompensatory(Trigger.new,'Invoiced_Sales__c');
        Invoiced_Sales_Helper_Class.addOwnerAndSnaresRep2ISR(Trigger.new);
        //Invoiced_Sales_Helper_Class.addOwner(Trigger.new);
        Invoiced_Sales_Helper_Class.updateBusinessDay(Trigger.new);
        Invoiced_Sales_Helper_Class.updateDayNumber(Trigger.new,'Invoiced_Sales__c');
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('--- UPDATE and AFTER trigger (master_Price_Quote) ----');
        Invoiced_Sales_Helper_Class.addAccountAfter(Trigger.new);
        
        //surya for rolling TAM sales
        //initial version work item: W-023184 sprint: 2020.04
        List<Id> AccountIds = new List<Id>();
        for(Invoiced_Sales__c invSalObj : Trigger.New) if(invSalObj.Account__c != null) AccountIds.add(invSalObj.Account__c);
        TAMInvoicedSalesHandler.rollingInvSalesFrmInvSalTgr(AccountIds);
    }
   
    if(trigger.isAfter && trigger.isdelete){
        list<Id> AccountIds = new List<Id>();
        for(Invoiced_Sales__c invSalObj : Trigger.old) if(invSalObj.Account__c != null) AccountIds.add(invSalObj.Account__c);
        TAMInvoicedSalesHandler.rollingInvSalesFrmInvSalTgr(AccountIds);
    }
}