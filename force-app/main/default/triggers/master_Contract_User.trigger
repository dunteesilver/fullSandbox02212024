trigger master_Contract_User on Contract_User__c (before insert, before update, after insert, after update) {
    if(system.isFuture()) return;
    
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('ib')){
        System.debug('INSERT and BEFORE trigger -------');
        //
    }
    
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('ia')){
        System.debug('INSERT and AFTER trigger -------');
        //if(trigger.size == 1) 
        PP_Build_User_Security.Create_Group_Membership(trigger.new);
    }     
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('ub')){
        System.debug('UPDATE and BEFORE trigger -------');
        //Contract_User_Helper_Class.createUserAuditPDF(Trigger.new,Trigger.newmap,Trigger.oldmap);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('ua')){
        System.debug('UPDATE and AFTER trigger -------');
//        if(trigger.size == 1) PP_Build_User_Security.Create_Group_Membership(trigger.new);
        PP_Build_User_Security.Create_Group_Membership(trigger.new);
       
    }            
}