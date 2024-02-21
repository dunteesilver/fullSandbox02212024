public class PP_Membership_Export_Test {

    public String filename { 
        get { 
            String temp_name = [Select Owner_Name__c FROM Contract_Header__c WHERE Owner__c = :ApexPages.currentPage().getParameters().get('oid') LIMIT 1].Owner_Name__c;
			temp_name = temp_name.replace(',','');
            temp_name += ' Membership ';
            temp_name += datetime.now().format('mm-dd-yyyy');
            System.debug('Temp_Name ===================================== ' + temp_name);            
            return temp_name; 
        } 
        set; }
    public transient list<Account> accList {get; set;}
    public transient list<Contract_Customer__c> accList_temp {get; set;}
    public transient set<String> accSet {get; set;}

    public list<Account> getAccounts(){
        list<Contract_Customer__c> accList_temp;
        accList_temp = [SELECT SAP_Code__c FROM Contract_Customer__c WHERE Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid')];
        set<String> accSet;
        for(Contract_Customer__c c : accList_temp){
            accSet.add(c.Sap_Code__c);
        }
        list<Account> accList;
        
        //accSet =  [SELECT id, SAP_Code__c, Account_Name__c FROM Contract_Customer__c WHERE Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid') ORDER BY Account_Name__c];
        //accList = [SELECT id, SAP_Sold_To__c, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Customer_Group__c, Customer_Group_Name__c FROM Account where Agreement_Count__c > 0 AND id IN (SELECT Account__c FROM Contract_Customer__c WHERE Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid')) ORDER BY Name];
        
        accList = [SELECT SAP_Sold_To__c, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Customer_Group__c, Customer_Group_Name__c FROM Account where SAP_Sold_To__c IN :accSet ORDER BY Name];
        return accList;
    }
    
    

}