trigger Focus_Profile_Master_Trigger on FOCUS_Profile__c (before insert, before update, after insert, after update) {
    
     if(Trigger.isInsert && Trigger.isBefore){
        System.debug('--- INSERT and BEFORE trigger (master_Contact) ----');
         Focus_Profile_Apxt_Helper.addLookupsOnFOCUSObject(Trigger.New);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('---- UPDATE and BEFORE trigger (master_Contact) ----');
		Focus_Profile_Apxt_Helper.addLookupsOnFOCUSObject(Trigger.New);
    }
    
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('---- INSERT and AFTER trigger (master_Contact) ----');
    }

    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('--- UPDATE and AFTER trigger (master_Contact) runOnce ----');
    }

}