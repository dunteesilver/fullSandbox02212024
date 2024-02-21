public class Focus_Profile_Apxt_Helper {
    
    public static void addLookupsOnFOCUSObject(list<Focus_Profile__c> newTrigger){
        
        Map<String, Id> accMap = new Map<String, Id>();
        Map<String, Focus_Profile__c> fpMap = new Map<String, Focus_Profile__c>();
        Set<String> custNumSet = new Set<String>();
        
        for(Focus_Profile__c focusObj : newTrigger){
            if(focusObj.End_Customer__c != null){
                custNumSet.add(focusObj.End_Customer__c);
                fpMap.put(focusObj.End_Customer__c, focusObj); 
            }
        }
        
        if(!custNumSet.isEmpty()){
            
            List<Account> accLst = [select Id, SAP_Sold_To__c from Account where SAP_Sold_To__c in : custNumSet and SAP_Sold_To__c != null];
            
            for(Account accObj : accLst){
                accMap.put(accObj.SAP_Sold_To__c, accObj.Id);
            }
            
            for(String endCustNum : custNumSet){
                if(accMap.containsKey(endCustNum)){
                    Focus_Profile__c focusProfileObj = fpMap.get(endCustNum);
                    focusProfileObj.Account__c = accMap.get(endCustNum);
                }
            }
            
        }
    }

}