trigger CRF_Send_FinalEmailtoAP on CE_Reimbursement_Expense__c (after update) {
    // Moved to CE_Reimbursement_Expense_Helper_Class.Education_Helper_Class to consolidate classes and cut down on confusion.
    // 18Oct2017 - ESC
    /*
    if(Trigger.isUpdate && Trigger.isAfter){
                system.debug('Starting Opp Approval Info Trigger - After Update');
        
        List<Id> CRFIds = new List<Id>();
        for (CE_Reimbursement_Expense__c crf: Trigger.new) {
            if(crf.Status__c == 'Approved for Payment'){
               CRFIds.add(CRF.Id); 
            } 
        }
        // Check the list size before calling the future call to reduce empty calls that are filling up the logs now. 12Sep2016 - ESC
        if(CRFIds.size() > 0){
            Education_Record_Update.SendEmail(CRFIds);   
        }
    }*/
}