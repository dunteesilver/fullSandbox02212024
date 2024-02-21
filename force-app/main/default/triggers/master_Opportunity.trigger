trigger master_Opportunity on Opportunity (before insert, before update, after insert, after update, after delete) {
    
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('OPP-INSERT-BEFORE')){
        System.debug('INSERT and BEFORE trigger -------');
        opportunity_Helper_Class.addTerritory(Trigger.new);
        opportunity_Helper_Class.stageStats(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('OPP-INSERT-AFTER')){
        System.debug('INSERT and AFTER trigger -------');
        PP_Opportunity_Sync.updatePQ(Trigger.new,Trigger.oldmap,'insert');
        territory_User_Assignment.setTerritoryNumberOpp(Trigger.new,Trigger.oldmap,'insert');
        opportunity_Helper_Class.setNewProductTracking(Trigger.new,Trigger.oldmap,'insert');
        opportunity_Helper_Class.createImpact(Trigger.new);
        opportunity_Helper_Class.createOppConRole(Trigger.new);
    }     
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('OPP-UPDATE-BEFORE')){
        System.debug('UPDATE and BEFORE trigger -------');
        opportunity_Helper_Class.addTerritory(Trigger.new);
        opportunity_Helper_Class.stageStats(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('OPP-UPDATE-AFTER')){
        System.debug('UPDATE and AFTER trigger -------');
        PP_Opportunity_Sync.updatePQ(Trigger.new,Trigger.oldmap,'update');
        territory_User_Assignment.setTerritoryNumberOpp(Trigger.new,Trigger.oldmap,'update');
        opportunity_Helper_Class.setProductOfInterest(Trigger.new,Trigger.oldmap,'update');
        opportunity_Helper_Class.setNewProductTracking(Trigger.new,Trigger.oldmap,'update');
        opportunity_Helper_Class.createImpact(Trigger.new);
        opportunity_Helper_Class.updateOppConRole(Trigger.new,Trigger.oldmap);
    }
    if(Trigger.isDelete && Trigger.isAfter && master_TriggerHelperClass.runOnce('del')){
        
    }

}