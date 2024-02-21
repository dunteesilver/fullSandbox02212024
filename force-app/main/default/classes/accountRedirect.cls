public class accountRedirect {

    private ApexPages.StandardController controller;
    public String retURL {get; set;}
    public String saveNewURL {get; set;}
    public String cancelURL {get; set;}
    public String ent {get; set;}
    public String confirmationToken {get; set;}
    public String accountID {get; set;}
    //public String contactID {get; set;}
    private Account acct;

public accountRedirect(ApexPages.StandardController controller) {

    //this.controller = controller;
    this.acct = (Account)controller.getRecord();

    retURL = ApexPages.currentPage().getParameters().get('retUrl');
    cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
    ent = ApexPages.currentPage().getParameters().get('ent');
    confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
    saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
    accountID = ApexPages.currentPage().getParameters().get('id');
//    contactID = ApexPages.currentPage().getParameters().get('def_contact_id');

}

public PageReference redirect() {

    PageReference returnURL;

    // Redirect if Record Type corresponds to custom VisualForce page

    String a = UserInfo.getUserId();

    Boolean bypass = false;

    User u = [SELECT Business_Unit__c FROM User WHERE id = :a];

    Account tempA = [SELECT RecordTypeId, SAP_Sold_To__c FROM Account WHERE Id = :accountID];

      IF(tempA.RecordTypeId == '012E0000000RPlv'){
          returnURL = new PageReference('/apex/accountsGPO');
      } ELSE IF(tempA.RecordTypeId == '012E0000000NJhu'){ //added for CE project
          returnURL = new PageReference('/' + tempA.Id);
      } ELSE IF (tempA.RecordTypeId == '012E0000000RPlw'){
          returnURL = new PageReference('/apex/accountsIDN');
      } ELSE IF (u.Business_Unit__c == 'Surgical Instruments') {
          returnURL = new PageReference('/apex/accountsSurgInstr');
      } ELSE IF (u.Business_Unit__c == 'Surgical Disposables') {
          returnURL = new PageReference('/apex/accountsSurgDisp');
      } ELSE IF (u.Business_Unit__c == 'Anesthesia/Respiratory'){
          returnURL = new PageReference('/apex/accountsAR');
      } ELSE IF (u.Business_Unit__c == 'Anesthesia'){ // added for AR split
          returnURL = new PageReference('/apex/accountsAnesthesia');
      } ELSE IF (u.Business_Unit__c == 'Respiratory'){  //added for AR split
          returnURL = new PageReference('/apex/accountsRespiratory');
      } ELSE IF (u.Business_Unit__c == 'Vascular'){
          returnURL = new PageReference('/apex/accountsVascular');
      } ELSE IF (u.Business_Unit__c == 'Canada'){
          returnURL = new PageReference('/apex/accountsVascular');
      } ELSE IF (u.Business_Unit__c == 'OEM'){
          returnURL = new PageReference('/apex/accountsOEM');
      } ELSE IF (u.Business_Unit__c == 'Interventional'){
          returnURL = new PageReference('/apex/accountsIA');
      } ELSE IF (u.Business_Unit__c == 'Specialty'){
          returnURL = new PageReference('/apex/accountsSM');
      } ELSE IF (u.Business_Unit__c == 'National Accounts'){
          returnURL = new PageReference('/apex/accountsNA');
      } ELSE IF (u.Business_Unit__c == 'Latin America'){
          returnURL = new PageReference('/apex/accountsLA');
      } ELSE IF (u.Business_Unit__c == 'Latin America Distributor'){
          returnURL = new PageReference('/apex/accountsLADist');
      } ELSE IF (u.Business_Unit__c == 'Vascular Vendor'){
          returnURL = new PageReference('/apex/accountsVascularVendor');
      } ELSE IF (u.Business_Unit__c == 'EMS'){
          returnURL = new PageReference('/apex/accountsEMS');
      } ELSE IF (u.Business_Unit__c == 'Commercial Operations'){
        returnURL = new PageReference('/apex/accountsSurgical');
      } ELSE IF (u.Business_Unit__c == 'Urology'){
        returnURL = new PageReference('/apex/accountsUrology');
      } ELSE IF (u.Business_Unit__c == 'Alternate Care'){
        returnURL = new PageReference('/apex/accountsAltCare');
      } ELSE IF (u.Business_Unit__c == 'Cardiac'){
        returnURL = new PageReference('/apex/accountsCardiac');
      } ELSE IF (u.Business_Unit__c == 'Surgical'){
        returnURL = new PageReference('/apex/accountsSurgical');
      } ELSE IF (u.Business_Unit__c == 'Surgical Percuvance'){
        returnURL = new PageReference('/apex/accountsSurgical');
      }
      ELSE {
          returnURL = new PageReference('/' + accountID);
          bypass = true;
      }

    returnURL.getParameters().put('retUrl', retUrl);
    returnURL.getParameters().put('cancelURL', cancelURL);
    returnURL.getParameters().put('ent', ent);
    returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
    returnURL.getParameters().put('save_new_url', saveNewURL);
    returnURL.getParameters().put('nooverride', '1');

    IF (accountID != null && !bypass){

        returnURL.getParameters().put('id', accountID);

    }

//    IF (contactID != null){

//        returnURL.getParameters().put('def_contact_id', contactID);

//    }

    returnURL.setRedirect(true);
    return returnURL;

}

    public PageReference redirect2() {

        // 25Feb2016 - ESC
        // 02Apr2016 - Switched lookups from SOQL to 'getvalues' method
        //
        PageReference returnURL;
        Boolean bypass = false;

        system.debug('-- Start Account Record Type Check --');
        system.debug('acct.RecordTypeId: ' + acct.RecordTypeId);
        string art = acct.RecordTypeId;
        if(art != NULL){
            art = art.left(15);
        }
        system.debug('ART: ' + art);
        Account_Page_Layout_Override__c aplo = Account_Page_Layout_Override__c.getValues(art);
        //Business_Unit__c newBu = Business_Unit__c.getValues(userBU);
        system.debug('aplo: ' + aplo);

        // Based on the Account Page RecordTypeId we will check to see if we should use a specific Custom Page.
        // GPO and IDN Accounts use this functionality as this is BU independent.
        if(aplo != NULL){
            system.debug('-- This account has a Page Layout Override set because of the Accounts record type id. -- ');
            if(aplo.Page__c != NULL){
                system.debug('-- Custom Page Layout Defined - using this page: -- ' + aplo.Page__c);
                returnURL = new PageReference('/apex/' + aplo.Page__c);
            }
            else{
                system.debug('-- No Page Defined so using the default page layout. -- ');
                returnURL = new PageReference('/' + accountID);
                bypass = true;
            }
            system.debug('-- Finished Account Record Type Check --');
        }

        // The Custom Page will be assigned based on the Users Business Unit
        if(returnURL == NULL){
            string userBU;
            userBU = [SELECT Business_Unit__c
                      FROM User
                      WHERE Id = :UserInfo.getUserId()
                      LIMIT 1].Business_Unit__c;
            system.debug('userBU: ' + userBU);


            if(userBU != NULL){
                system.debug('-- User has BU set! -- ' + userBU);
                Business_Unit__c newBu = Business_Unit__c.getValues(userBU);

                if(newBu == NULL){
                    system.debug('-- Users BU NOT FOUND in the BUSINESS_Unit__c Custom Setting! -- ' + newBU);
                    returnURL = new PageReference('/' + accountID);
                    bypass = true;
                }
                else{
                    system.debug('-- Success! Forwarding user to their page: ' + newBu.Page__c);
                    returnURL = new PageReference('/apex/' + newBu.Page__c);
                }
            }
            else{
                system.debug('-- User does not have a BU set under their user record! -- ' + userBU);
                returnURL = new PageReference('/' + accountID);
                bypass = true;
            }

        }

        //system.debug('returnURL: ' + returnURL);

        returnURL.getParameters().put('retUrl', retUrl);
        returnURL.getParameters().put('cancelURL', cancelURL);
        returnURL.getParameters().put('ent', ent);
        returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
        returnURL.getParameters().put('save_new_url', saveNewURL);
        returnURL.getParameters().put('nooverride', '1');

        IF (accountID != null && !bypass){
            returnURL.getParameters().put('id', accountID);
        }

        returnURL.setRedirect(true);
        return returnURL;

    }


public static testMethod void accountRedirectTest() {

    // create a new lead...
    Account a = new Account(Name='Test Account ');
    // ...set additional fields...
    insert a;

    //Create a reference to the VF page
    PageReference pageRef = Page.accountsRedirect;
    Test.setCurrentPageReference(pageRef);
    // if you wanted to test an existing lead, use the line below (assuming your extension expects the ID param to be set)
    ApexPages.currentPage().getParameters().put('id', a.Id);

    // create an instance of your extension
    // this assumes a new Lead...
    //accountRedirect extension = new accountRedirect(new ApexPages.StandardController(new Lead()));
    // if you wanted to test an existing lead, use the line below...
    accountRedirect extension = new accountRedirect(new ApexPages.StandardController(a));
    extension.redirect2();

    // ... start calling methods to exercise your code ...

    // tear down objects created in the test
    delete a;
}


}