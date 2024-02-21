trigger master_Product2 on Product2 (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('master_Product2_ib')){
        System.debug('INSERT and BEFORE trigger -------');
        //PP_ProductSearch.updateProductFields(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('master_Product2_ia')){
        System.debug('INSERT and AFTER trigger -------');
        price_Book_Sync.insertProducts(Trigger.new);
        //price_Book_Sync.checkProducts(Trigger.new);
    }     
    
    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('master_Product2_ub')){
        System.debug('UPDATE and BEFORE trigger -------');
        //PP_ProductSearch.updateProductFields(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('master_Product2_ua')){
        System.debug('UPDATE and AFTER trigger -------');
        price_Book_Sync.insertProducts(Trigger.new);
        //price_Book_Sync.checkProducts(Trigger.new);
    }            

}