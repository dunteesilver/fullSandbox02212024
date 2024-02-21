trigger master_Sample_Request on Sample_Request__c (before insert, before update, after insert, after update)  {

    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('[INSERT] [BEFORE] trigger (master_Sample_Request) ----');
        sample_Requests_Helper_Class.fixSalesOrg(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('[INSERT] [AFTER] trigger (master_Sample_Request) ----');
    }

    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('[INSERT] [BEFORE] trigger (master_Sample_Request) ----');
        sample_Requests_Helper_Class.fixSalesOrg(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('SR-UPDATE-AFTER') ){
      // && master_TriggerHelperClass.runOnce('SR-UPDATE-AFTER')
        System.debug('[UPDATE] [AFTER] trigger (master_Sample_Request) ----');
        //sample_Requests_Helper_Class.assignToTerritoryManager(Trigger.new, Trigger.newMap);
        for(Sample_Request__c curr : Trigger.New){
          //if Check
          if(curr.Status__c == 'Waiting for Approval'){
            sample_Requests_Helper_Class.assignToTerritoryManager(curr);
          }//end if

          if(curr.Status__c == 'Rejected' || curr.Status__c == 'Ready'){
            sample_Requests_Helper_Class.removeTerritoryManager(curr);
          }

        }//end for loop
        //sample_Requests_Helper_Class.assignToTerritoryManager(Trigger.new, Trigger.newMap);
    }

}