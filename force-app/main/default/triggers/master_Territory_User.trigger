trigger master_Territory_User on Territory_User__c (before insert, before update, before delete, after insert, after update, after delete) {
  if(system.isFuture()) return;
    
   if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('ib_territory_user')){
        System.debug('INSERT and BEFORE trigger -------');
        //
    }
    
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('ia_territory_user')){
        System.debug('INSERT and AFTER trigger -------');
      // territory_user_maintenance.checkPrimaryTerritory(trigger.new);
        if(trigger.size == 1) {
            string btype = 'add';
            territory_user_maintenance.Build_Account_Team(trigger.new,btype);            
        }
    }     
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('ub_territory_user')){
        System.debug('UPDATE and BEFORE trigger -------');
        //
    }
    
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('ua_territory_user')){
        System.debug('UPDATE and AFTER trigger -------');
              // territory_user_maintenance.checkPrimaryTerritory(trigger.new);
        if(trigger.size == 1) {
            boolean fire = FALSE;
            id tuId;
            for(Territory_User__c tu : trigger.new){
                if(tu.Rebuild_Territory_Alignments__c == TRUE){
                    fire = TRUE;
                    tuId = tu.Id;
                }
            }
            if(fire){
                string btype = 'add';
                territory_user_maintenance.Build_Account_Team(trigger.new,btype);            
                Territory_User__c tuUpdate = new Territory_User__c(
                    Rebuild_Territory_Alignments__c = FALSE,
                    Id = tuId
                );
                update tuUpdate;
            }
        }

    }
    if(Trigger.isDelete && Trigger.isAfter && master_TriggerHelperClass.runOnce('del')){
        System.debug('DELETE trigger -------');
        if(trigger.size == 1) {
            string btype = 'del';
            territory_user_maintenance.Build_Account_Team(trigger.old,btype);            
        }
    } 

}