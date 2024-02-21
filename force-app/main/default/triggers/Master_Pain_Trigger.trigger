trigger Master_Pain_Trigger on Pain_Profile__c (before insert,before update) {
 if(trigger.isBefore) PainProfileSalesHandler.rollingInvSalesFrmPainTgr(trigger.new); 
}