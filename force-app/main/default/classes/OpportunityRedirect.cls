public class OpportunityRedirect {

private ApexPages.StandardController controller;
public String retURL {get; set;}
public String saveNewURL {get; set;}
public String cancelURL {get; set;}
public String ent {get; set;}
public String confirmationToken {get; set;}
public String OpportunityID {get; set;}
public String displayAccess {get; set;}
//public String contactID {get; set;}


public static map<string,string> getRecordTypes(string objectName){
    map<string,string> rtMap = new map<String,string>();
    for(RecordType rt:[select id,DeveloperName from RecordType where sobjectType=:objectName]){
        rtMap.put(rt.DeveloperName ,rt.Id);
    }
    return rtMap;
}
public OpportunityRedirect(ApexPages.StandardController controller) {

    this.controller = controller;

    retURL = ApexPages.currentPage().getParameters().get('retUrl');
    cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
    ent = ApexPages.currentPage().getParameters().get('ent');
    confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
    saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
    OpportunityID = ApexPages.currentPage().getParameters().get('id');
    displayAccess = ApexPages.currentPage().getParameters().get('displayTrueTeamAccess');
//    contactID = ApexPages.currentPage().getParameters().get('def_contact_id');

}

public PageReference redirect() {

    PageReference returnURL;

    // Redirect if Record Type corresponds to custom VisualForce page

    Boolean bypass = false;

    Opportunity tempOpp = [SELECT RecordTypeID FROM Opportunity WHERE Id = :OpportunityId LIMIT 1];


    IF(tempOpp.RecordTypeId == '012E0000000R4kk') {
        returnURL = new PageReference('/apex/opportunitiesSurgical');
    } ELSE IF(tempOpp.RecordTypeId == '012E0000000RWd6') { //Surgical Instruments RecordType
        returnURL = new PageReference('/apex/opportunitiesSurgical');
    } ELSE IF(tempOpp.RecordTypeId == '012E0000000RWd5') { //Surgical Disposables RecordType
        returnURL = new PageReference('/apex/opportunitiesSurgical');
    } ELSE IF (tempOpp.RecordTypeId == '012E0000000R4Cz'){
        returnURL = new PageReference('/apex/opportunitiesAR');
    } ELSE IF (tempOpp.RecordTypeId == '012E0000000RWQf'){
        returnURL = new PageReference('/apex/opportunitiesAnesthesia');
    } ELSE IF (tempOpp.RecordTypeId == '012E0000000RWQg'){
        returnURL = new PageReference('/apex/opportunitiesRespiratory');
    } ELSE IF (tempOpp.RecordTypeId == '012E0000000PQUt' || tempOpp.RecordTypeId == '012E0000000QHTO' || tempOpp.RecordTypeId == '012E0000000PS2q'){
        returnURL = new PageReference('/apex/opportunitiesVascular');
    } ELSE IF (tempOpp.RecordTypeId == '012E0000000RPlH' || tempOpp.RecordTypeId == '012E0000000RQI9'){
        returnURL = new PageReference('/apex/opportunitiesNA');
    } ELSE IF (tempOpp.RecordTypeId == '012E0000000RPlM'){
        returnURL = new PageReference('/apex/opportunitiesCS');
    } ELSE IF (tempOpp.RecordTypeId == '012E0000000RGuR'){
        returnURL = new PageReference('/apex/opportunitiesIA');
    } ELSE IF (tempOpp.RecordTypeId == '012E0000000RR7z'){
        returnURL = new PageReference('/apex/opportunitiesSM');
    } ELSE IF (tempOpp.RecordTypeId == '012E0000000RHDm'){
        returnURL = new PageReference('/apex/opportunitiesLANT');
    } ELSE IF (tempOpp.RecordTypeId == '012E0000000RHDn') {
        returnURL = new PageReference('/apex/opportunitiesLAT');
    } ELSE IF (tempOpp.RecordTypeId == '012E00000005y2T') {
        returnURL = new PageReference('/apex/opportunitiesEMS');
    } ELSE {
        returnURL = new PageReference('/' + OpportunityID);
        bypass = true;
    }

    returnURL.getParameters().put('retUrl', retUrl);
    returnURL.getParameters().put('cancelURL', cancelURL);
    returnURL.getParameters().put('ent', ent);
    returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
    returnURL.getParameters().put('save_new_url', saveNewURL);
    returnURL.getParameters().put('nooverride', '1');
    If (displayAccess == '1'){
        returnURL.getParameters().put('displayTrueTeamAccess', '1');
    }

    IF (OpportunityID != null && !bypass){

        returnURL.getParameters().put('id', OpportunityID);

    }

//    IF (contactID != null){

//        returnURL.getParameters().put('def_contact_id', contactID);

//    }

    returnURL.setRedirect(true);
    return returnURL;

}

public static testMethod void opportunityRedirectTest() {

    // create a new lead...
    //
    Account acct = new Account(Name='Test Account ');
    insert acct;

    Contact c = new Contact(
        FirstName='Test',
        lastname='second',
        Email='abc@123.com',
        Position_Job_Title__c='Administrator',
        Credentials__c='RN',
        Preferred_language__c='English (American)',
        AccountId = acct.id
    );
    insert c;

    Opportunity opp = new Opportunity(
        name = 'testopportunity',
        CloseDate = date.today() + 1,
        Type='New Business',
        LeadSource='Self Generated',
        Description='Test',
        Amount=10000,
        Product_Family__c='Ligation',
        Product_Of_Interest__c='Metal',
        Business_Unit__c='Surgical Disposables',
        Business_Unit_GPL__c='Anesthesia',
        Product_Family_GPL__c='Airway',
        Product_of_Interest_GPL__c='TruLite',
        RecordTypeId = '01244000000NNcz',
        StageName='Close',
        Primary_Contact__c = c.id
    );
    // ...set additional fields...
    insert opp;

    //Create a reference to the VF page
    PageReference pageRef = Page.accountsRedirect;
    Test.setCurrentPageReference(pageRef);
    // if you wanted to test an existing lead, use the line below (assuming your extension expects the ID param to be set)
    ApexPages.currentPage().getParameters().put('id', opp.Id);

    // create an instance of your extension
    // this assumes a new Lead...
    //accountRedirect extension = new accountRedirect(new ApexPages.StandardController(new Lead()));
    // if you wanted to test an existing lead, use the line below...
    opportunityRedirect extension = new opportunityRedirect(new ApexPages.StandardController(opp));

    opportunityRedirect.getRecordTypes('Opportunity');
    extension.redirect();
    

    // ... start calling methods to exercise your code ...

    // tear down objects created in the test
    delete opp;
}

}