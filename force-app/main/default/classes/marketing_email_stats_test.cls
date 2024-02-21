@isTest
public class marketing_email_stats_test {
    
    public static testMethod void testmes(){
        
        Quick_Disable__c cs = new Quick_Disable__c(
            Name = 'insertSAP',
            Enable__c = TRUE
        );
        System.debug('insert cs-->' + cs);
        insert cs;
        
        Account a = new account(
            Name = 'Test Acct2',
            SAP_Sold_To__c = '999998'
        );
        insert a;
        
        Contact c = new Contact(
            FirstName ='Test',
            email = 'abc@123.com',  
            lastname='test',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
            AccountId = a.id
        );
        insert c;
        
        Lead l = new Lead(
            FirstName='Bob',
            LastName='Stone',
            Product_Family__c = 'Test',
            Product_Of_Interest__c = 'Test',
            Company = 'test',
            SAP_Code__c = '999998'
        );
        insert l;
        
        PageReference pageRef = new PageReference('/apex/tiny?m=MC-0001309&id=' + c.id + '&a=dc&url=http://www.google.com');
        Test.setCurrentPage(pageRef);
        
        marketing_email_stats tc = new marketing_email_stats();
        tc.redirect();
        
        PageReference pageRef2 = new PageReference('/apex/tiny?m=MC-0001309&id=' + l.id + '&a=dc&url=http://www.google.com');
        Test.setCurrentPage(pageRef2);
        
        marketing_email_stats tc2 = new marketing_email_stats();
        tc2.redirect();
        
    }

}