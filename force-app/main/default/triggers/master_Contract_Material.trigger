trigger master_Contract_Material on Contract_Material__c (before insert, before update, after insert, after update) {
    
    //if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('CM-INSERT-BEFORE')){
    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('INSERT and BEFORE trigger -------');

    }
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('INSERT and AFTER trigger -------');
        PP_Build_Contract_Divisions.buildDivisions_CM(Trigger.new);
    }     
    
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('UPDATE and BEFORE trigger -------');
        
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('UPDATE and AFTER trigger -------');
        PP_Build_Contract_Divisions.buildDivisions_CM(Trigger.new);
    }

}