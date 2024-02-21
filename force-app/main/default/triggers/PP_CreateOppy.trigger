trigger PP_CreateOppy on Price_Quote__c (after update) {

    /*
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('---- UPDATE and AFTER trigger (PP_CreateOppy) ----');
        PP_CreateRecord co = new PP_CreateRecord();
        co.CreateOppy(Trigger.new,Trigger.oldmap);
    }*/
    // Moved the above to the master trigger (master_Price_Quote) - ESC / 26Apr2016
    
    //Instantiate object of PP_CreateRecord class


    //Invoke CreateOppy method from list of records
    //List<Price_Quote__c> p = [SELECT id,Status__c,Price_Quote_Name__c,Contact_Name__c,Grand_Total__c,
    //                          Account_Name__c FROM Price_Quote__c WHERE Status__c = 'Approved' AND Id IN :Trigger.new for update];
    //if(checkRecursive.runOnce()){

    //}

}