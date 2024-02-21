/*********************************************************************
* Description      : class with future method to add/remove contract users 
to/from public groups. *Replacement of PP_Build_Group_Future.apxc
* Test Class       : PP_Build_Public_Group_ContractTest.apxc
* Author(s)        : Saya Zhangabatyr - saya.zhangabatyr@teleflex.com
* Date         	   : 05/01/2023
* Work Item		   : W-
* Comments		   : Surya Arvan - surya.arvan@teleflex.com - Uses sObjectUtility class to get sObject field API names 
and auto map them with available public groups in salesforce 
if no group is found null pointer is handled using manual static code analysis 
and other hardcoded values plus number of apex voilations reduced by manual SCA.
**********************************************************************/

public class PP_Build_Public_Group_Contract {
    
    public static void Update_Groups_Membership(List<Id> newIds){
        system.debug('Welcome to the future! PP_Build_Public_Contract.Update_Group_Membership');
        
        //Collections to hold users to add/remove to/from Public Groups
        list<GroupMember> addUser = new list<GroupMember>();
        list<GroupMember> removeUser = new list<GroupMember>();
        
        map<String, Id> groupMap = new map<String, Id>();
        for(Group g : [SELECT Name, Id FROM GROUP
                       WHERE Name = 'Pricing Portal'
                       OR Name like '%Division%'
                       OR Name like 'Pricing Tier%'])
        {
            groupMap.put(g.Name, g.Id);
            // system.debug('g.name:' + g.name + ' g.Id ' + g.id);
        }
        map<String, String> finalgroupNameApiMap = new map<String, String>();
        // storing field api names and field labels pf the object in a map
        Map<String, String> apiLabelNameMap=SObjectUtility.getAllChkBoxFieldAPIAndLabelNames('Contract_User__c');
        
        
        for(String grpName : groupMap.keySet()){
            if(apiLabelNameMap.containsKey(grpName)){
                finalgroupNameApiMap.put(grpName, apiLabelNameMap.get(grpName));
            }
        }
        // System.debug(' Printing finalgroupNameApiMap: ' +  finalgroupNameApiMap);
        
        
        //get queried Contract User records
        List<Contract_User__c> listOfContUsers=SObjectUtility.getContractUserRecords(newIds);
        
        //loop thru Contract Users and to check checkbox fields values
        for(Contract_User__c contUser:listOfContUsers){
            String uId = contUser.User__r.id;
            
            System.debug(' Printing contract user and its Id: '+contUser.Name);
            
            // Pricing Tiers
            if(contUser.Pricing_Tier_Access__c >= 1){
                GroupMember addGroupMember = new GroupMember(GroupId = groupMap.get('Pricing Tier 1 - Rep'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = groupMap.get('Pricing Tier 1 - Rep'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            if(contUser.Pricing_Tier_Access__c >= 2){
                GroupMember addGroupMember = new GroupMember(GroupId = groupMap.get('Pricing Tier 2 - Manager'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = groupMap.get('Pricing Tier 2 - Manager'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            if(contUser.Pricing_Tier_Access__c >= 3){
                GroupMember addGroupMember = new GroupMember(GroupId = groupMap.get('Pricing Tier 3 - Director'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = groupMap.get('Pricing Tier 3 - Director'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            if(contUser.Pricing_Tier_Access__c >= 4){
                GroupMember addGroupMember = new GroupMember(GroupId = groupMap.get('Pricing Tier 4 - VP'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = groupMap.get('Pricing Tier 4 - VP'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // Pricing Portal
            if(contUser.Pricing_Portal_Access__c){
                GroupMember addGroupMember = new GroupMember(GroupId = groupMap.get('Pricing Portal'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = groupMap.get('Pricing Portal'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            
            //DIVISIONS
            Map<String, Boolean> trueValuesMap = new Map<String, Boolean>();
            Map<String, Boolean> falseValuesMap = new Map<String, Boolean>();
            System.debug('***  PP_Build_Build_Public_Contract FOR LOOP *** ' + contUser);
            for (String fieldLabel : finalgroupNameApiMap.keySet()) {
                Boolean value = (Boolean)contUser.get(finalgroupNameApiMap.get(fieldLabel));
                if (value == true) {
                    trueValuesMap.put(fieldLabel, value);
                } else {
                    falseValuesMap.put(fieldLabel, value);
                } 
            }
            System.debug('true values: ' + trueValuesMap);
            System.debug('false values: ' + falseValuesMap);
            
            if(!trueValuesMap.isEmpty()){
                for(String checkedField:trueValuesMap.keySet()){
                    GroupMember addGroupMember = new GroupMember(GroupId = groupMap.get(checkedField), UserOrGroupId = uId);
                    addUser.add(addGroupMember);
                }
            }
            if(!falseValuesMap.isEmpty()){
                for(String checkedField:falseValuesMap.keySet()){
                    GroupMember removeGroupMember = new GroupMember(GroupId = groupMap.get(checkedField), UserOrGroupId = uId);
                    removeUser.add(removeGroupMember);
                }
                
                
            } //end of if statement for falseValues
        } // end of for loop of contract users
        set<Id> filterUser = new set<Id>();
        for(GroupMember gmset : removeUser){
            filterUser.add(gmset.USERORGROUPID);
        }
        list<GroupMember> deleteGroupMember = new list<GroupMember>();        
        
        for(GroupMember gmout : [SELECT GroupId, USERORGROUPID FROM GroupMember WHERE USERORGROUPID IN :filterUser]){
            for(GroupMember gmin : removeUser){
                if(gmout.GroupId == gmin.GroupId && gmout.USERORGROUPID == gmin.USERORGROUPID){
                    GroupMember removeGroupMember = new GroupMember(
                        Id = gmout.id
                    );
                    system.debug('Immmmmm Here!!!!!!!!!');
                    deleteGroupMember.add(removeGroupMember);                    
                    system.debug('deleteGroupMember =============================== ' + deleteGroupMember);
                }
            }
        }
        
        if(addUser.size() > 0){
            insert addUser;
        }
        if(deleteGroupMember.size() > 0){
            delete deleteGroupMember;            
        }
        
        
    } //end of Update_Groups_Membership method
    
    
    @future
    public static void Update_Group_Membership_Future(List<Id> newIds){
        Update_Groups_Membership(newIds);
    }        
}