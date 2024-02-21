trigger Master_Canada_Trigger on Canada_Profile__c (before insert,before update) {
if(trigger.isBefore) CanadaProfileSalesHandler.rollingInvSalesFrmCanTgr(trigger.new); 
}