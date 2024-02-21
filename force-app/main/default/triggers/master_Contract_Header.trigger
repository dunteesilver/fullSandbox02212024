trigger master_Contract_Header on Contract_Header__c (before insert, before update, after insert, after update) {

//    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('ib_ch')){
    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('INSERT and BEFORE trigger -------');
        PP_General_Helper_Class.checkGPO(trigger.new);
        PP_Build_Contract_Divisions.checkDivisions(trigger.new);
        PP_General_Helper_Class.fixCurrency(trigger.new);
        PP_General_Helper_Class.updateContractHeaderFields(Trigger.new);
        //code added to fix issues caused by SAP/Vistex update on 11/19/2023... change 11/21/2023
        PP_Build_Contract_Divisions.removeZeros(trigger.new); 
    }
    
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('INSERT and AFTER trigger -------');
        //
    }     
    
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('UPDATE and BEFORE trigger -------');
        PP_General_Helper_Class.checkGPO(trigger.new);
        PP_Build_Contract_Divisions.checkDivisions(trigger.new);
        PP_General_Helper_Class.fixCurrency(trigger.new);
        PP_General_Helper_Class.updateContractHeaderFields(Trigger.new);
        //code added to fix issues caused by SAP/Vistex update on 11/19/2023... change 11/21/2023
        PP_Build_Contract_Divisions.removeZeros(trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('UPDATE and AFTER trigger -------');
        //
    }      
}