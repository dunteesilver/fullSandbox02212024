public class user_Helper_Class {
    
    public static void beforeHelper(List<User> newTrigger,map<id,User> oldtrigger,string trigType){
        
        Map<String, Business_Unit__c> buMap = Business_Unit__c.getAll();
        for(User u : newTrigger){
            if(trigType == 'insert'){
                if(u.Business_Unit_Key__c == NULL && u.Business_Unit__c != NULL){
                    if(buMap.get(u.Business_Unit__c) != NULL){
                        u.Business_Unit_Key__c = buMap.get(u.Business_Unit__c).Key__c;                    
                    }
                }
            }
            else if(trigType == 'update'){
                if((u.Business_Unit_Key__c == NULL && u.Business_Unit__c != NULL) || 
                   (u.Business_Unit__c != NULL && oldtrigger.get(u.Id).Business_Unit__c != u.Business_Unit__c))
                {
                    if(buMap.get(u.Business_Unit__c) != NULL){
                        u.Business_Unit_Key__c = buMap.get(u.Business_Unit__c).Key__c;                    
                    }
                }
                else if(u.Business_Unit__c == NULL){
                    u.Business_Unit_Key__c = '';
                }
            }
        }
    }

}