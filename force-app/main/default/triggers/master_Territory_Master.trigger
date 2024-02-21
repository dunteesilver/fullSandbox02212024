trigger master_Territory_Master on Territory_Master__c (before insert, before update, before delete, after insert, after update, after delete) {
    if(system.isFuture()) return;
    
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('ib_territory_master')){
        System.debug('INSERT and BEFORE trigger -------');
        //territory_user_maintenance.checkSalesRegion(trigger.new);
        territory_master_maintenance.updateLookups(trigger.new); 
    }
    
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('ia_territory_master')){
        System.debug('INSERT and AFTER trigger -------');

    }     
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('ub_territory_master')){
        System.debug('UPDATE and BEFORE trigger -------');
        //
        //territory_user_maintenance.checkSalesRegion(trigger.new);
        territory_master_maintenance.updateLookups(trigger.new); 
        territory_master_maintenance.emptyQuotas(trigger.new); 
        territory_master_maintenance.tickleQuotas(trigger.new);
        territory_master_maintenance.changeOppOwner(trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('ua_territory_master')){
        System.debug('UPDATE and AFTER trigger -------');
        if(trigger.size == 1) {
            territory_master_maintenance.Build_Territory_Alignments(trigger.new);
            //territory_master_maintenance.changeOppOwner(trigger.new);
        }
    }
    if(Trigger.isDelete && Trigger.isAfter && master_TriggerHelperClass.runOnce('del_territory_master')){
        System.debug('DELETE trigger -------');
        if(trigger.size == 1) {
            //territory_master_maintenance.Build_Territory_Alignments(trigger.old);            
        }
    }
}