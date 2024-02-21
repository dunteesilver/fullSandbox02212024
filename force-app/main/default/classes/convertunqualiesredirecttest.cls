@istest

public class convertunqualiesredirecttest {
    static testMethod void convertUnqualifiesRedirecttest(){
      
      Lead testLead = new Lead (LastName='test', Company='test company');
      
      insert testLead;
      
    //Create a reference to the VF page
    PageReference pageRef = page.LeadsAR;
    Test.setCurrentPageReference(pageRef);
    // if you wanted to test an existing lead, use the line below (assuming your extension expects the ID param to be set)
    ApexPages.currentPage().getParameters().put('id', testLead.Id);

    // create an instance of your extension
    // this assumes a new Lead...
    //accountRedirect extension = new accountRedirect(new ApexPages.StandardController(new Lead()));
    // if you wanted to test an existing lead, use the line below...
    convertUnqualifiesRedirect extension = new convertUnqualifiesRedirect (new ApexPages.StandardController(testLead));
    
    extension.unqualify();

    // ... start calling methods to exercise your code ...
    
    // tear down objects created in the test
    delete testLead;
    }
}