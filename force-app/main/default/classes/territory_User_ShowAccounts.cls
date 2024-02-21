public class territory_User_ShowAccounts {
    public String uid {get; set;}
    public String userName { 
        get { 
            String user_name = '';
            if(ApexPages.currentPage().getParameters().get('id') != NULL){
                user_name = [Select name FROM user WHERE id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1].Name; 
            }
            return user_name; 
        } 
        set; }
    
    public String getuserName2(){ 
        
        String user_name = '';
        if(ApexPages.currentPage().getParameters().get('id') != NULL){
            user_name = [Select name FROM user WHERE id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1].Name; 
        }
        
        return user_name;
    }
        
    
    public list<Territory_Account__c> getAccounts(){
        uid = ApexPages.currentPage().getParameters().get('id');
        list<String> terlist = new list<String>();
        
        for(Territory_User__c t : [SELECT Territory_Master__r.Territory_Number__c FROM Territory_User__c WHERE User__c = :uid]){
            terlist.add(t.Territory_Master__r.Territory_Number__c);
        }
        
        list<Territory_Account__c> taList = new list<Territory_Account__c>([SELECT Name, Account__r.Billing_Address_Full__c, Account__r.SAP_Sold_To__c, Account__r.name, Territory_Master__r.Region_Name__c, Territory_Master__r.Region_Number__c, Territory_Master__r.Territory_Name__c, Territory_Master__c, Territory_Master__r.Business_Unit__c, Territory_Master__r.Name FROM Territory_Account__c WHERE Territory_Master__r.name IN :terlist ORDER by Account__r.name]);
        
        return talist;
    }
    
}