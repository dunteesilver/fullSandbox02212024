public with sharing class myContacts {

    private Account acct;

    public myContacts(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }
    
    user u = [SELECT Business_Unit__c FROM User WHERE Id=:userinfo.getuserid()];
    string bu = u.business_unit__c;
    
    List<Contact> myCtcs;

    public List<Contact> getmyCtcs() {
        if(bu == 'Cross BU'){
            return null;
        }else{            
            myCtcs = [SELECT Id, Salutation, AccountId, Name, Business_Unit1__c, Title, Position_Job_Title__c, email, phone FROM Contact WHERE AccountId=:acct.id AND Contact.Business_Unit1__c INCLUDES (:bu) ORDER BY Name ASC NULLS LAST];
        }
            
        return myCtcs;
    
    }

}