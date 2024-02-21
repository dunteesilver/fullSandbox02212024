public class topTen {
        
        private Account acct;
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public topTen(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }
        
        List<Top_10_Selling_Products__c> myT10;

    public List<Top_10_Selling_Products__c> getmyT10() {
        myT10 = [SELECT Item_Number__c, Product_Description__c, Business_Unit__c, Sales_YTD__c, Sales_Prior_Year__c, Growth_pct__c FROM Top_10_Selling_Products__c WHERE Account__c=:acct.id ORDER BY Sales_YTD__c DESC NULLS LAST LIMIT 1000];
        return myT10;
    
    }
    
    public List<Top_10_Selling_Products__c> getmyT10Growth() {
        myT10 = [SELECT Item_Number__c, Product_Description__c, Business_Unit__c, Sales_YTD__c, Sales_Prior_Year__c, Growth__c, Growth_pct__c FROM Top_10_Selling_Products__c WHERE Account__c=:acct.id ORDER BY Growth__c DESC NULLS LAST LIMIT 1000];
        return myT10;
    
    }
    
    public static testMethod void topTenTest() {

        // create a new lead...
        Account acct = new Account(Name='Test Account ');
        // ...set additional fields...
        insert acct;
    
        //Create a reference to the VF page
        PageReference pageRef = Page.accountsRedirect;
        Test.setCurrentPageReference(pageRef);
        // if you wanted to test an existing lead, use the line below (assuming your extension expects the ID param to be set)
        ApexPages.currentPage().getParameters().put('id', acct.Id);
    
        // create an instance of your extension
        // this assumes a new Lead...
        //accountRedirect extension = new accountRedirect(new ApexPages.StandardController(new Lead()));
        // if you wanted to test an existing lead, use the line below...
        accountRedirect extension = new accountRedirect(new ApexPages.StandardController(acct));
        topTen extension1 = new topTen(new ApexPages.StandardController(acct));
        extension1.getmyT10();
        extension1.getmyT10Growth();
        extension.redirect();
    
        // ... start calling methods to exercise your code ...
        
        // tear down objects created in the test
        delete acct;
    }

}