@isTest
public class OptOut_Test {
    public static testMethod void testOptOut(){
        PageReference pageRef = Page.OptOut;
        Test.setCurrentPage(pageRef);
        
        Account a = new account(
            Name = 'Test'
        );
        insert a;
        
        Contact c = new contact(
            FirstName='Test',
            Lastname = 'Test',
            Email = 'abc@123.com',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
            AccountID = a.Id
        );
        insert c;
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('email', 'abc@123.com');
        
        OptOut controller = new OptOut();
        String nextPage = controller.save().getUrl();
        
        
        
    }
}