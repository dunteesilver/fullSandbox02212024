public class PP_Build_User_Security {
    
    public static void Create_Group_Membership(List<Contract_User__c> newTrigger){
        
        list<id> newIds = new list<Id>();
        for(Contract_User__c cu : newTrigger){
            if(cu.Update_Type__c != 'updateSO'){
                newIds.add(cu.Id);                
            }
        }
        if(newIds.size() > 0){
            if(system.isBatch() || system.isFuture()){
                system.debug('Running in the Future!');
                //PP_Build_Group_Future.Update_Group_Membership(newIds);
                PP_Build_Public_Group_Contract.Update_Groups_Membership(newIds);
                
            }
            else{
                system.debug('Calling the Future Class!');
                // PP_Build_Group_Future.Update_Group_Membership_Future(newIds);
                PP_Build_Public_Group_Contract.Update_Group_Membership_Future(newIds);
            }
        }
        
        
        system.debug('newIds List: ' + newIds);
    }
}