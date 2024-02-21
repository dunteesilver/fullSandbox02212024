trigger master_Account on Account (before insert, before update, after insert, after update) {
    System.debug('Running Master Account Trigger -------');
    
    //Start of isBefore logic
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            account_Helper_Class.updateAccountFields(Trigger.new);
        }

        if(Trigger.isUpdate){
            account_Helper_Class.updateAccountFields(Trigger.new);
        }
        
        if(Trigger.isInsert && master_TriggerHelperClass.runOnce('account-ib') ){
            System.debug('INSERT and BEFORE trigger -------');
            account_Helper_Class.updateAccountType(Trigger.new);
            account_Helper_Class.accRecordTypeCheck(Trigger.new);
            account_Helper_Class.addIDNs(Trigger.new);
            account_Helper_Class.addIdnCustomSetting(Trigger.new);
            
        }//end of isInsert
        if(Trigger.isUpdate && master_TriggerHelperClass.runOnce('account-ub') ){
            System.debug('UPDATE and BEFORE trigger -------');
            if(master_TriggerHelperClass.superRunOnce(trigger.newmap.keyset(),'before')){
                account_Helper_Class.updateAccountType(Trigger.new);
                account_Helper_Class.accRecordTypeCheck(Trigger.new);
                account_Helper_Class.addIDNs(Trigger.new);
                account_Helper_Class.addIdnCustomSetting(Trigger.new);
                
            }//end if
        }//end of isUpdate
        if(Trigger.isDelete){
            
        }//end of isDelete
    }
    //end of isBefore
    
    //Start of isAfter Logic
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('INSERT and AFTER trigger -------');
            if(master_TriggerHelperClass.qd('Territory_Automation_Before')){
                territory_Account_Alignment.alignAccounts(Trigger.new);
                territory_Account_Shares.addAccountShares(Trigger.new);
                //territory_Account_Shares.addAccountShares_legacy(Trigger.new);
            }//end if    
        }//end of isInsert
        if(Trigger.isUpdate){
            System.debug('UPDATE and AFTER trigger -------');
            if(master_TriggerHelperClass.superRunOnce(trigger.newmap.keyset(),'after')){
                if(master_TriggerHelperClass.qd('Territory_Automation_After')){
                    territory_Account_Alignment.alignAccounts(Trigger.new);
                    territory_Account_Shares.addAccountShares(Trigger.new);
                    //territory_Account_Shares.addAccountShares_legacy(Trigger.new);
                }
            }//end if
        }//end of isUpdate
        if(Trigger.isDelete){
            
        }//end of isDelete
    }
    //end of isAfter
    
}//end of Account Trigger