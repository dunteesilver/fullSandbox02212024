public class leadEditRedirect {

private ApexPages.StandardController controller;
public String retURL {get; set;}
public String saveNewURL {get; set;}
public String cancelURL {get; set;}
public String ent {get; set;}
public String confirmationToken {get; set;}
//public String accountID {get; set;}
//public String contactID {get; set;}
public String leadID {get; set;}

public leadEditRedirect(ApexPages.StandardController controller) {

    this.controller = controller;

    retURL = ApexPages.currentPage().getParameters().get('retUrl');
    cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
    ent = ApexPages.currentPage().getParameters().get('ent');
    confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
    saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
    leadID = ApexPages.currentPage().getParameters().get('id');
//    accountID = ApexPages.currentPage().getParameters().get('id');
//    contactID = ApexPages.currentPage().getParameters().get('def_contact_id');

}

public PageReference redirect() {

    PageReference returnURL;

    // Redirect if Record Type corresponds to custom VisualForce page

    String a = UserInfo.getUserId();

    Boolean bypass = false;

    User u = [SELECT Business_Unit__c FROM User WHERE id = :a];

    IF(u.Business_Unit__c == 'Surgical') {
        returnURL = new PageReference('/apex/leadsSurgicalEdit');
    } ELSE {    
        returnURL = new PageReference('/' + leadID);
        bypass = true;
    }

    
    returnURL.getParameters().put('retUrl', retUrl);
    returnURL.getParameters().put('cancelURL', cancelURL);
    returnURL.getParameters().put('ent', ent);
    returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
    returnURL.getParameters().put('save_new_url', saveNewURL); 
    returnURL.getParameters().put('nooverride', '1');
    
    IF (leadID != null && !bypass){

        returnURL.getParameters().put('id', leadID);

    }

//    IF (contactID != null){

//        returnURL.getParameters().put('def_contact_id', contactID);

//    }
    
    returnURL.setRedirect(true);
    return returnURL;

}

public static testMethod void leadEditRedirectTest() {

    // create a new lead...
    Lead lead = new Lead(FirstName='Test', LastName='Dude',Company='Test Company', Status='Qualified');
    // ...set additional fields...
    insert lead;

    //Create a reference to the VF page
    PageReference pageRef = Page.leadsEditRedirect;
    Test.setCurrentPageReference(pageRef);
    // if you wanted to test an existing lead, use the line below (assuming your extension expects the ID param to be set)
    ApexPages.currentPage().getParameters().put('id', lead.Id);

    // create an instance of your extension
    // this assumes a new Lead...
    //accountRedirect extension = new accountRedirect(new ApexPages.StandardController(new Lead()));
    // if you wanted to test an existing lead, use the line below...
    leadEditRedirect extension = new leadEditRedirect(new ApexPages.StandardController(lead));
    
    extension.redirect();

    // ... start calling methods to exercise your code ...
    
    // tear down objects created in the test
    delete lead;
}


}