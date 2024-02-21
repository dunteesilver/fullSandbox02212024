@istest
public class lead_SAP_Helper_Test {
    public static testMethod void validate_SAP(){
        Quick_Disable__c cs = new Quick_Disable__c(
            Name = 'insertSAP',
            Enable__c = TRUE
        );
        System.debug('insert cs-->' + cs);
        insert cs;
        
        Account a = new account(
            Name = 'Test',
            SAP_Sold_To__c = '999999',
            BillingStreet = '123 Street',
            BillingCity = 'Raleigh', 
            BillingState = 'NC', 
            BillingPostalCode = '27614'
        );
        insert a;
        Account a2 = new account(
            Name = 'Test2',
            SAP_Sold_To__c = '888888',
            BillingStreet = '123 Street',
            BillingCity = 'Raleigh', 
            BillingState = 'NC', 
            BillingPostalCode = '27614'
        );
        insert a2;
        Lead l = new lead(
            lastname = 'test',
            company = 'test',
            Status = 'Open',
            SAP_Code__c = '9999999',
            PostalCode = '27614'
        );
        insert l;
        l.SAP_Code__c = '888888';
        update l;
    }

}