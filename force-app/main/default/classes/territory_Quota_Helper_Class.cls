public class territory_Quota_Helper_Class {
    
    public static void tLookup(List<Territory_Quota__c> newTrigger){
        set<String> tnumSet = new set<String>();
        map<String, Id> tmMap = new map<String, Id>();
        map<String, Id> tuMap = new map<String, Id>();
        
        for(Territory_Quota__c tq : newTrigger){
            tnumSet.add(tq.Territory_Number__c);
        }
        
        if(tnumSet.size() > 0){
            for(Territory_Master__c tm : [SELECT Id, Sales_Rep__c, Territory_Number__c, Sales_Rep__r.IsActive 
                                          FROM Territory_Master__c  
                                          WHERE Territory_Number__c =:tnumSet])
            {
                if(tm.Sales_Rep__r.IsActive == TRUE){
                    tuMap.put(tm.Territory_Number__c, tm.Sales_Rep__c);    
                }
                tmMap.put(tm.Territory_Number__c, tm.Id);
            }
        }
        
        for(Territory_Quota__c tq : newTrigger){
            if(tmMap.containsKey(tq.Territory_Number__c)){
                tq.Territory_Master__c = tmMap.get(tq.Territory_Number__c);
            }
            if(tuMap.containsKey(tq.Territory_Number__c)){
                tq.User__c = tuMap.get(tq.Territory_Number__c);
            }
        }
    }
}