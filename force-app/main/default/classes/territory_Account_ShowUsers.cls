public class territory_Account_ShowUsers {
    
    public String accid {get; set;}
    public String accountName { 
        get { 
            String acct_name = '';
            if(ApexPages.currentPage().getParameters().get('id') != NULL){
                acct_name = [Select name FROM Account WHERE id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1].Name; 
            }
            return acct_name; 
        } 
        set; }
    
    public String accountId { 
        get { 
            String acct_id = '';
            if(ApexPages.currentPage().getParameters().get('id') != NULL){
                acct_id = ApexPages.currentPage().getParameters().get('id'); 
            }
            return acct_id; 
        } 
        set; }
    
    public list<Territory_User__c> getUsers(){
        accid = ApexPages.currentPage().getParameters().get('id');
        list<String> terlist = new list<String>();

        for(Territory_Account__c t : [SELECT Territory_Master__r.Territory_Number__c FROM Territory_Account__c WHERE Account__c = :accid]){
            terlist.add(t.Territory_Master__r.Territory_Number__c);
        }

        list<Territory_User__c> tuList = new list<Territory_User__c>([SELECT User__c, Regional_Manager__c, Territory_Master__r.Region_Name__c, Territory_Master__r.Region_Number__c, Territory_Master__r.Territory_Name__c, Territory_Master__c, Territory_Master__r.Business_Unit__c, Territory_Master__r.Name FROM Territory_User__c WHERE Territory_Master__r.name IN :terlist AND User__r.isActive = TRUE ORDER by Territory_Master__r.Business_Unit__c, User__r.name]);
        
        return tulist;
    }
    
    public list<Territory_Account__c> getTerritories(){
        
        list<Territory_Account__c> terlist = new list<Territory_Account__c>([SELECT Territory_Master__c, Territory_Master__r.Territory_Number__c, Territory_Master__r.Business_Unit__c, Territory_Master__r.Region_Name__c, Territory_Master__r.Region_Number__c, Territory_Master__r.Territory_Name__c FROM Territory_Account__c WHERE Account__c = :ApexPages.currentPage().getParameters().get('id') ORDER BY Territory_Master__r.Business_Unit__c]);
        
        return terlist;
    }
    
    
    
    public list<AccountTeamMember> getAccountTeamMembers(){
        list<AccountTeamMember> listATM = new list<AccountTeamMember>([SELECT AccountAccessLevel, AccountId, TeamMemberRole, UserId FROM AccountTeamMember WHERE AccountId = :ApexPages.currentPage().getParameters().get('id') ORDER BY TeamMemberRole, UserId]);
        
        return listATM;
    }
    
    public list<AccountShare> getAccountShares(){
        list<AccountShare> returnAS = new list<AccountShare>();
        list<AccountShare> listAS = new list<AccountShare>([SELECT UserOrGroupId, RowCause, AccountAccessLevel, OpportunityAccessLevel, ContactAccessLevel, AccountId, IsDeleted FROM AccountShare WHERE UserOrGroupId NOT IN (SELECT ID FROM GROUP) AND AccountId = :ApexPages.currentPage().getParameters().get('id') ORDER BY RowCause]);
        
        return listAS;
    }

}