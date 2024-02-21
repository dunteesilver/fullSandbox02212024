trigger master_LeadTrigger on Lead (before insert, before update, after insert, after update) {

    //if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('ib')){
    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('INSERT and BEFORE trigger -------');
        lead_SAP_Helper.insertSAP(Trigger.new,NULL,'insert');
        territory_User_Assignment.assignUser(Trigger.new,Trigger.oldmap,'insert'); // Assigns the Lead Owner Based on ZPSA Rules
        lead_Helper_Class.setProductOfInterestBefore(Trigger.new);
        lead_Helper_Class.setNewProductTrackingBefore(Trigger.new,Trigger.oldmap,'insert');
        territory_User_Assignment.setTerritoryNumber(Trigger.new,Trigger.oldmap,'insert');
        lead_Helper_Class.On24Routing(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('lead-ia')){
        System.debug('INSERT and AFTER trigger -------');
        lead_Helper_Class.addZuantLead(Trigger.new);
        lead_Helper_Class.leadCleanup(Trigger.new);
        lead_Helper_Class.eloquaTaskUpdate(Trigger.new,Trigger.oldmap);
        lead_Helper_Class.ezioWebRouting(Trigger.new);
        //territory_User_Assignment.setTerritoryNumber(Trigger.new,Trigger.oldmap,'insert');
    }

    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('lead-ub')){
        System.debug('UPDATE and BEFORE trigger -------');
        lead_SAP_Helper.insertSAP(Trigger.new,Trigger.oldmap,'update');
        territory_User_Assignment.assignUser(Trigger.new,Trigger.oldmap,'update'); // Assigns the Lead Owner Based on ZPSA Rules
        lead_Helper_Class.setNewProductTrackingBefore(Trigger.new,Trigger.oldmap,'update');
        territory_User_Assignment.setTerritoryNumber(Trigger.new,Trigger.oldmap,'update');
        lead_Helper_Class.On24Routing(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('lead-ua')){
        System.debug('UPDATE and AFTER trigger -------');
        lead_Helper_Class.leadCleanup(Trigger.new);
        lead_Helper_Class.addZuantLead(Trigger.new);
        lead_Helper_Class.setProductOfInterest(Trigger.new,Trigger.oldmap,'update');
        lead_Helper_Class.eloquaTaskUpdate(Trigger.new,Trigger.oldmap);
    }
}