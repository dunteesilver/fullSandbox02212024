/*********************************************************************
* Description      : Test class for Custom Lead Conversion Process.
* Covered Classes  : convertingLeads
* Author(s)        : Dun Silver
**********************************************************************/
@isTest
private class convertingLeadsTest {
    
    @isTest static void convertTest() {
        //Create test data
        Account a = new account(
            Name = 'Test',
            SAP_Sold_To__c = '999999',
            BillingStreet = '123 Street',
            BillingCity = 'Raleigh',
            BillingState = 'NC',
            BillingPostalCode = '27614'
        );
        insert a;
        system.debug('a: '+ a);
        
        Account a1 = new account(
            Name = 'Teleflex',
            SAP_Sold_To__c = '999990',
            BillingStreet = '125 Street',
            BillingCity = 'Raleigh',
            BillingState = 'NC',
            BillingPostalCode = '27614'
        );
        insert a1;
        
        Contact c = new Contact(
            
            email = 'abc@123.com',  
            FirstName='Dun',
            lastname='Test', 
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',

            AccountId = a.id
        );
        insert c;
        
        Contact c1 = new Contact(
            
            email = 'abc@123.com',  
            FirstName='John',
            lastname='Doe',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
 
            AccountId = a.id
        );
        insert c1;
        
        Id leadRTid = [Select Id From RecordType Where SobjectType = 'Lead' and DeveloperName = 'Teleflex_Standard_Lead'].Id;
        
        Lead l = new Lead(
            FirstName='Trey',
            LastName='Stone',
            Status='Open',
            Amount__c=2000.00,
            Zip_Code_Auto_Route__c=true,
            Do_not_create_opportunity__c=false,
            //Business_Unit__c='Surgical',
            Product_Family__c='test',
            Product_Of_Interest__c='test',
            Product_Family_Latam__c='TestLA',
            Product_Of_Interest_Latam__c='TestLA',
            Business_Unit__c='Anesthesia',
            Product_Family_GPL__c='Airway',
            Product_of_Interest_GPL__c='TruLite',
            Account__c=a.Id,
            Contact__c =c.Id,
            Company='test',
            Cancel_Workflow__c = TRUE
        );
        insert l;
        
        Lead lead2 = new Lead(
            RecordTypeId = leadRTid,
            FirstName='Chuck',
            LastName='Barkley',
            Status='Open',
            Amount__c=1000.00,
            Zip_Code_Auto_Route__c=true,
            Do_not_create_opportunity__c=true,
            //Business_Unit__c='Anesthesia',
            Product_Family__c='test',
            Product_Of_Interest__c='test',
            Product_Family_Latam__c='TestLA',
            Product_Of_Interest_Latam__c='TestLA',
            Business_Unit__c='Anesthesia',
            Product_Family_GPL__c='Airway',
            Product_of_Interest_GPL__c='TruLite',
            Account__c=a.Id,
            Contact__c =c.Id,
            Company='Medical',
            Cancel_Workflow__c = TRUE
        );
        insert lead2;
        system.debug('lead2 ***** ' + lead2);
        
        PageReference lca = Page.LeadConversionAccount;
        Test.setCurrentPage(lca);
        lca.getParameters().put('id',l.Id);
        
        convertingLeads convert = new convertingLeads(new ApexPages.StandardController(new lead()));
        //ApexPages.StandardController ctlr = new ApexPages.StandardController(l);
        //convertingLeads convert = new convertingLeads(ctlr);
        Test.startTest();
        convert.saccId = a.Id;
        convert.sconId = c.Id;
        convert.simAccBool = true;
        Boolean testsimAccBool = convert.simAccBool;
        convert.simRecBool = true;
        Boolean testsimRecBool = convert.simRecBool;
        convert.conAccsBool = true;
        Boolean testconAccsBool = convert.conAccsBool;
        convert.conSimsBool = true;
        Boolean testconSimsBool = convert.conSimsBool;
        convert.getLead();
        convert.getsimAccs();
        convert.getrecAccs();
        convert.getconAccs();
        convert.getconSims();
        convert.showAccFields();
        convert.showAccFieldsFalse();
        convert.lookupAcc();
        convert.sconId = c.Id;
        convert.selectedAccount();
        convert.aName = 'Test Account 1';
        convert.aStreet = '123 Street';
        convert.aCity = 'Raleigh';
        convert.aState = 'NC';
        convert.aZip = '27610';
        convert.createAccount();
        convert.removeContact();
        convert.lead.Contact__c = c.Id;
        convert.lookupCon();
        convert.selectedContact();
        convert.updateLead();
        convert.lead.Product_Family__c = 'Test';
        convert.lead.Product_Of_Interest__c = 'Test';
        convert.lead.Business_Unit__c='Anesthesia';
        convert.lead.Product_Family_GPL__c='Airway';
        convert.lead.Product_of_Interest_GPL__c='TruLite';
        convert.lead.Amount__c = 3000.00;
        convert.lead.Do_not_create_opportunity__c = false;
        convert.saveProds();
        //convertingLeads.doConvert(lead.Id);
        
        convertingLeads convert1 = new convertingLeads(new ApexPages.StandardController(lead2));
        convert1.saccId = a.Id;
        convert1.sconId = c.Id;
        convert1.simAccBool = false;
        Boolean testsimAccBool1 = convert1.simAccBool;
        convert1.simRecBool = false;
        Boolean testsimRecBool1 = convert1.simRecBool;
        convert1.conAccsBool = false;
        Boolean testconAccsBool1 = convert1.conAccsBool;
        convert1.conSimsBool = false;
        Boolean testconSimsBool1 = convert1.conSimsBool;
        convert1.getLead();
        convert1.getsimAccs();
        convert1.getrecAccs();
        convert1.getconAccs();
        convert1.getconSims();
        convert1.showAccFields();
        convert1.showAccFieldsFalse();
        convert1.lookupAcc();
        convert1.selectedAccount();
        convert1.aName = 'Test Account 2';
        convert1.aStreet = '456 Street';
        convert1.aCity = 'Garner';
        convert1.aState = 'NC';
        convert1.aZip = '27529';
        convert.createAccount();
        convert1.lookupCon();
        convert1.selectedContact();
        convert1.updateLead();
        convert1.saveProds();
        //convertingLeads.doConvert(lead2.Id);
        
        lead2.Account__c = NULL;
        UPDATE lead2;
        PageReference lca2 = Page.LeadConversionAccount;
        //PageReference lca2 = new PageReference('/apex/LeadConversionAccount?id='+lead2.Id);
        //Test.setCurrentPageReference(new PageReference('Page.PP_Contract_Detail'));
        lca2.getParameters().put('id',lead2.Id);
        Test.setCurrentPage(lca2);
        convertingLeads convert2 = new convertingLeads(new ApexPages.StandardController(new lead()));
        convert2.saccId = a1.Id;
        convert2.sconId = c.Id;
        convert2.lookupAcc();
        System.assertEquals(NULL,convert2.lookupAcc() );
        System.assertEquals(NULL,convert2.selectedAccount() );
        convert2.saccId = NULL;
        convert2.selectedAccount();
        convert2.sconId = NULL;
        convert2.selectedContact();
        convert2.updateLead();
        convert2.aName = 'TFX';
        convert2.createAccount();
        lead2.Account__c = a1.Id;
        UPDATE lead2;
        convertingLeads.doConvert(l.Id);
        convertingLeads.doConvert(lead2.Id);
        Test.stopTest();
    }
    
}