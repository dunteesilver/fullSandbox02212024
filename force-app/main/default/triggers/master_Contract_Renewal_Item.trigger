trigger master_Contract_Renewal_Item on Contract_Renewal_Item__c (before insert, before update, after insert, after update) {
  if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('CRI-INSERT-BEFORE')){
      System.debug('--- INSERT and BEFORE trigger runOnce (master_Contract_Renewal_Item) ----');
      //call apex classes
  }

  if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('CRI-INSERT-AFTER')){
      //if(Trigger.isInsert && Trigger.isAfter){
      System.debug('---- INSERT and AFTER trigger runOnce (master_Price_Quote) ----');
      //call apex classes
      //PP_Opportunity_Sync.updateOpp(Trigger.new,Trigger.oldmap,'insert');
      //PP_Price_Quote_Helper_Class.autoCreateNewOpp(Trigger.new);
      Contract_Renewal_Item_Helper_Class.pricingLogicCheck(Trigger.new);
  }

  if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('CRI-UPDATE-BEFORE')){
      System.debug('---- Update and Before trigger (master_Contract_Renewal_Item) ----');
      //Call Apex Classes
  }

  if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('CRI-UPDATE-AFTER')){
      System.debug('---- Update and After trigger runOnce (master_Contract_Renewal_Item) ----');
      //Call Apex Classes
  }

  if(Trigger.isUpdate && Trigger.isAfter){
      System.debug('---- Update and After trigger (master_Contract_Renewal_Item) ----');
      //Call Apex Classes
  }
}