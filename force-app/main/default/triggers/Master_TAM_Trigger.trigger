/*********************************************************************
* Description      : Trigger for TAM to invoke TAMInvoicedSalesHandler class.
* Test Class       : Master_TAM_Trigger_Test
* VisualForce      : N/A
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
//surya for rolling TAM sales
//initial version work item: W-023184 sprint: 2020.04
**********************************************************************/
trigger Master_TAM_Trigger on TAM__c (before insert, before update) {
       if(trigger.isBefore) TAMInvoicedSalesHandler.rollingInvSalesFrmTAMTgr(trigger.new); 
}