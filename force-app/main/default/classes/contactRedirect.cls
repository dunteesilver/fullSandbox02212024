public class contactRedirect {

private ApexPages.StandardController controller;
public String retURL {get; set;}
public String saveNewURL {get; set;}
public String cancelURL {get; set;}
public String ent {get; set;}
public String confirmationToken {get; set;}
//public String accountID {get; set;}
public String contactID {get; set;}

public contactRedirect(ApexPages.StandardController controller) {

    this.controller = controller;

    retURL = ApexPages.currentPage().getParameters().get('retUrl');
    cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
    ent = ApexPages.currentPage().getParameters().get('ent');
    confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
    saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
//    accountID = ApexPages.currentPage().getParameters().get('id');
    contactID = ApexPages.currentPage().getParameters().get('id');

}

public PageReference redirect() {

    PageReference returnURL;

    // Redirect if Record Type corresponds to custom VisualForce page

    String a = UserInfo.getUserId();

    Boolean bypass = false;

    User u = [SELECT Business_Unit__c FROM User WHERE id = :a];


    IF (u.Business_Unit__c == 'Latin America'){
        returnURL = new PageReference('/apex/contactsLA');
    } ELSE IF (u.Business_Unit__c == 'Latin America Distributor'){
        returnURL = new PageReference('/apex/contactsLA');
    } ELSE IF (u.Business_Unit__c == 'Vascular' || u.Business_Unit__c == 'Vascular Vendor' || u.Business_Unit__c == 'Canada'){
        returnURL = new PageReference('/apex/contactsVascular');
    } ELSE IF (u.Business_Unit__c == 'Mayo'){
        returnURL = new PageReference('/' + contactID);
    } ELSE {    
        returnURL = new PageReference('/apex/contactsAR');
    }

    
    returnURL.getParameters().put('retUrl', retUrl);
    returnURL.getParameters().put('cancelURL', cancelURL);
    returnURL.getParameters().put('ent', ent);
    returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
    returnURL.getParameters().put('save_new_url', saveNewURL); 
    returnURL.getParameters().put('nooverride', '1');
    
    IF (contactID != null && !bypass){

        returnURL.getParameters().put('id', contactID);

    }

//    IF (contactID != null){

//        returnURL.getParameters().put('def_contact_id', contactID);

//    }
    
    returnURL.setRedirect(true);
    return returnURL;

}


public static testMethod void contactRedirectTest() {

    // create a new lead...
    Contact cont = new Contact(FirstName ='Test',
            email = 'abc@123.com',LastName='tester',Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)');
    // ...set additional fields...
    insert cont;

    //Create a reference to the VF page
    PageReference pageRef = Page.contactsRedirect;
    Test.setCurrentPageReference(pageRef);
    // if you wanted to test an existing lead, use the line below (assuming your extension expects the ID param to be set)
    ApexPages.currentPage().getParameters().put('id', cont.Id);

    // create an instance of your extension
    // this assumes a new Lead...
    //accountRedirect extension = new accountRedirect(new ApexPages.StandardController(new Lead()));
    // if you wanted to test an existing lead, use the line below...
    contactRedirect extension = new contactRedirect(new ApexPages.StandardController(cont));
    
    extension.redirect();

    // ... start calling methods to exercise your code ...
    
    // tear down objects created in the test
    delete cont;
}


}