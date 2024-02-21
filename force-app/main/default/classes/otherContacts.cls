public with sharing class otherContacts {
        
        private Account acct;

    public otherContacts(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }
    
    user u = [SELECT Business_Unit__c FROM User WHERE Id=:userinfo.getuserid()];
    string bu = u.business_unit__c;
    
    List<Contact> otherCtcs;

    public List<Contact> getotherCtcs() {
        otherCtcs = [SELECT Id, AccountId, Salutation, Name, Business_Unit1__c, Title, Position_Job_Title__c, email, phone FROM Contact WHERE AccountId=:acct.id AND Contact.Business_Unit1__c EXCLUDES (:bu) ORDER BY Name ASC NULLS LAST];
        return otherCtcs;
    
    }

}