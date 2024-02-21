public with sharing class PP_Membership_Export {

    String lastId;
    Public Integer size{get;set;}
    Public Integer noOfRecords{get; set;}
    
    public String filename { 
        get { 
            String temp_name = [Select Owner_Name__c FROM Contract_Header__c WHERE Owner__c = :ApexPages.currentPage().getParameters().get('oid') LIMIT 1].Owner_Name__c;
			temp_name = temp_name.replace(',','');
            temp_name += ' Membership ';
            temp_name += datetime.now().format('MM-dd-yyyy');
            System.debug('Temp_Name ===================================== ' + temp_name);            
            return temp_name; 
        } 
        set; }
    //public transient list<Account> accList {get; set;}

    public list<Account> getAccounts(){
        list<Account> accList = new list<Account>();
        list<Contract_Header__c> headers = [SELECT Agreement_Number__c FROM Contract_Header__c WHERE Owner__c = :ApexPages.currentPage().getParameters().get('oid')];
        system.debug('headers:' + headers.size());
        //list<Contract_Customer__c> cclist = [SELECT Account__r.id FROM Contract_Customer__c WHERE Agreement__c IN :headers];
        //system.debug('cclist:' + cclist.size());
        set<Id> accids = new set<id>();
        for(Contract_Customer__c cc : [SELECT Account__r.id FROM Contract_Customer__c WHERE Agreement__c IN :headers] ){
            if(cc.Account__r.id != NULL){
                accids.add(cc.Account__r.id);    
            }
        }
        system.debug('accids:' + accids.size());
        //system.debug('accids:' + accids);
        //accList = [SELECT SAP_Sold_To__c, Account_Name__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry, Account__r.Customer_Group__c, Account__r.Customer_Group_Name__c FROM Account where id IN (SELECT Account__c FROM Contract_Customer__c WHERE Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid')) ORDER BY Account_Name__c];
        //accList = [SELECT id, SAP_Sold_To__c, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Customer_Group__c, Customer_Group_Name__c FROM Account where id IN (SELECT Account__c FROM Contract_Customer__c WHERE Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid')) ORDER BY Name];
        //accList = [SELECT id, SAP_Sold_To__c, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Customer_Group__c, Customer_Group_Name__c FROM Account where id IN (SELECT Account__c FROM Contract_Customer__c WHERE Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid')) ORDER BY Name];
        accList = [SELECT id, SAP_Sold_To__c, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, 
                    Customer_Group__c, Customer_Group_Name__c 
                    FROM Account WHERE Id IN :accids ORDER BY Id LIMIT 10000];
        
        lastId = accList[accList.size()-1].Id;
        system.debug('*** accList.size() *** ' + accList.size() );
        system.debug('*** lastId *** ' + lastId);
        return accList;
    }//end of getAccounts
    
    public list<Account> getAccounts2(){
        list<Account> accList = new list<Account>();
        list<Contract_Header__c> headers = [SELECT Agreement_Number__c FROM Contract_Header__c WHERE Owner__c = :ApexPages.currentPage().getParameters().get('oid')];
        system.debug('headers:' + headers.size());
        //list<Contract_Customer__c> cclist = [SELECT Account__r.id FROM Contract_Customer__c WHERE Agreement__c IN :headers];
        //system.debug('cclist:' + cclist.size());
        set<Id> accids = new set<id>();
        for(Contract_Customer__c cc : [SELECT Account__r.id FROM Contract_Customer__c WHERE Agreement__c IN :headers] ){
            if(cc.Account__r.id != NULL){
                accids.add(cc.Account__r.id);    
            }
        }
        system.debug('accids:' + accids.size());
        //system.debug('accids:' + accids);
        //accList = [SELECT SAP_Sold_To__c, Account_Name__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry, Account__r.Customer_Group__c, Account__r.Customer_Group_Name__c FROM Account where id IN (SELECT Account__c FROM Contract_Customer__c WHERE Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid')) ORDER BY Account_Name__c];
        //accList = [SELECT id, SAP_Sold_To__c, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Customer_Group__c, Customer_Group_Name__c FROM Account where id IN (SELECT Account__c FROM Contract_Customer__c WHERE Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid')) ORDER BY Name];
        //accList = [SELECT id, SAP_Sold_To__c, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Customer_Group__c, Customer_Group_Name__c FROM Account where id IN (SELECT Account__c FROM Contract_Customer__c WHERE Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid')) ORDER BY Name];
        accList = [SELECT id, SAP_Sold_To__c, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, 
                    Customer_Group__c, Customer_Group_Name__c 
                    FROM Account 
                    WHERE Id IN :accids AND Id > :lastId ORDER BY Id LIMIT 10000];
        return accList;
    }//end of getAccounts2
      
}