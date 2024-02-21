public with sharing class topTenBU {

    private Account acct;
    
    
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public topTenBU(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }
    
    user u = [SELECT Business_Unit__c FROM User WHERE Id=:userinfo.getuserid()];
    string bu = u.business_unit__c;
    string newBu;
    List<Top_10_Selling_Products__c> myT10BU;

    public List<Top_10_Selling_Products__c> getmyT10BU() {
        if(bu == 'Cross BU'){
                return null;
            //myT10BU = [SELECT Item_Number__c, Product_Description__c, Business_Unit__c, Sales_YTD__c, Sales_Prior_Year__c FROM Top_10_Selling_Products__c WHERE Account__c=:acct.id ORDER BY Sales_YTD__c DESC NULLS LAST];
        }else{
            if(bu.contains('Surgical')){
                newBu = bu.substringBefore(' ');
                myT10BU = [SELECT Item_Number__c, Product_Description__c, Business_Unit__c, Sales_YTD__c, Sales_Prior_Year__c, Growth_pct__c FROM Top_10_Selling_Products__c WHERE Account__c=:acct.id AND Business_Unit__c=:newBu ORDER BY Sales_YTD__c DESC NULLS LAST];
            }
            else if(bu.contains('Alternate')){
                newBu = 'Specialty';
                myT10BU = [SELECT Item_Number__c, Product_Description__c, Business_Unit__c, Sales_YTD__c, Sales_Prior_Year__c, Growth_pct__c FROM Top_10_Selling_Products__c WHERE Account__c=:acct.id AND Business_Unit__c=:newBu ORDER BY Sales_YTD__c DESC NULLS LAST];
            }
            else{
                myT10BU = [SELECT Item_Number__c, Product_Description__c, Business_Unit__c, Sales_YTD__c, Sales_Prior_Year__c, Growth_pct__c FROM Top_10_Selling_Products__c WHERE Account__c=:acct.id AND Business_Unit__c=:bu ORDER BY Sales_YTD__c DESC NULLS LAST];
            }
            
        }
               
        return myT10BU;
    
    }
    
    public String getmyBU() {
        return bu;
    }

    public static testMethod void topTenBUTest() {

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
        topTenBU extension1 = new topTenBU(new ApexPages.StandardController(acct));
        extension1.getmyT10BU();
        extension.redirect();
    
        // ... start calling methods to exercise your code ...
        
        // tear down objects created in the test
        delete acct;
    }

}