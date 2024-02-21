trigger master_Business_Metrics on Business_Metrics__c (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('ib--BMX')){
        System.debug('[1]-[INSERT and BEFORE]: Business Metrics trigger -------');
        Business_Metrics_Helper_Class.setBUKey(trigger.new);
        Business_Metrics_Helper_Class.setReportURL(trigger.new);
    }
    
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('ia--BMX')){
        System.debug('[2]-[INSERT and AFTER]: Business Metrics trigger -------');
        
    }     
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('ub--BMX')){
        System.debug('[3]-[UPDATE and BEFORE]: Business Metrics trigger -------');
        Business_Metrics_Helper_Class.setBUKey(trigger.new);
        Business_Metrics_Helper_Class.setReportURL(trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('ua--BMX')){
        System.debug('[4]-[UPDATE and AFTER]: Business Metrics trigger -------');
        
    }    

}