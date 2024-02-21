global class customLeadConversionNOVF{ 
    
    webService static String doConvert(Id l){

        PageReference finishURL;
        String tempAcctId;
        Contact tempContact;
        List<Account_Contact__c> tempMultiList;
        Lead leadContactId;
        Opportunity ExistingOpportunity;
        List<String> errors = new List<String>();

        Lead lead = [SELECT Id,Product_Of_Interest_Latam__c,Product_Of_Interest__c,Account__c,Contact__c,Existing_Opportunity__c,Do_not_create_opportunity__c,Product_Family_Latam__c,Product_Family__c FROM Lead WHERE Id=:l LIMIT 1];

        lead.Status = 'Qualified';
        update lead;

        if(lead.Product_Of_Interest_Latam__c == null && lead.Product_Of_Interest__c==null){
            errors.add('Please enter Product Family and Product of Interest');
        }    
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id);
        
        if(lead.Account__c != null){
            lc.setAccountId(lead.Account__c);
        }else{
            errors.add('Please enter Existing Account');
        }
        
        if(lead.Contact__c != null){
            leadContactId = [SELECT Contact__r.AccountId FROM Lead WHERE Id=:lead.Id];
            if(leadContactId.Contact__r.AccountId != lead.Account__c){
                tempMultiList = [SELECT Contact__c FROM Account_Contact__c WHERE Account__c=: lead.Account__c];
                if (tempMultiList != null){
                    Set<Id> contactList = new Set<Id>();
                    for(Account_Contact__c ac:tempMultiList){
                        contactList.add(ac.Contact__c);
                    }
                    if(contactList.contains(lead.Contact__c)){
                        tempContact = [SELECT Id, AccountId FROM Contact WHERE Id = :lead.Contact__c ];
                        tempAcctId=tempContact.AccountId;
                        tempContact.AccountId=lead.Account__c;
                        update tempContact;
                    } else {
                        errors.add('Existing Contact must be attached to Existing Account');
                    }
                }

            }
            lc.setContactId(lead.Contact__c);
        }
        
        if(lead.Existing_Opportunity__c != null){
            ExistingOpportunity = [SELECT Product_Family__c, Product_Family_Latam__c FROM Opportunity WHERE Id=:lead.Existing_Opportunity__c LIMIT 1];
            if((lead.Product_Family_Latam__c != ExistingOpportunity.Product_Family_Latam__c) || (lead.Product_Family__c != ExistingOpportunity.Product_Family__c)){
                errors.add('Product Family must match on Lead and Existing Opportunity');
            }
            lc.setDoNotCreateOpportunity(true);
            
        } else if(lead.do_not_create_opportunity__c == true){
            lc.setDoNotCreateOpportunity(true);
        } else {
            lc.setDoNotCreateOpportunity(false);
        }
        
        if(errors.size()==0){
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            
            if(tempContact != null){
                tempContact.AccountId=tempAcctId;
                update tempContact;
            }
            
            if(lead.Existing_Opportunity__c != null){

                if(lead.Contact__c == null && [SELECT count() from OpportunityContactRole where OpportunityId =:lead.Existing_Opportunity__c AND ContactId =:lcr.getContactId() ] == 0){
                    OpportunityContactRole ocr = new OpportunityContactRole();
                    ocr.OpportunityId = lead.Existing_Opportunity__c;
                    ocr.ContactId = lcr.getContactId();
                    ocr.Role = 'Other';                
                    insert ocr;            
                }else if(lead.Contact__c != null && [SELECT count() from OpportunityContactRole where OpportunityId =:lead.Existing_Opportunity__c AND ContactId =:lead.Contact__c ] == 0){
                    OpportunityContactRole ocr = new OpportunityContactRole();
                    ocr.OpportunityId = lead.Existing_Opportunity__c;
                    ocr.ContactId = lead.Contact__c;
                    ocr.Role = 'Other';                
                    insert ocr;            
                }
            }
            
            if(lcr.isSuccess()){

                if(lead.Existing_Opportunity__c != null){
                    finishURL = new PageReference('/' + lead.Existing_Opportunity__c);
                } else if(lead.do_not_create_opportunity__c == true && lead.Existing_Opportunity__c == null){
                    finishURL = new PageReference('/' + lcr.getContactId());
                }else{
                    finishURL = new PageReference('/' + lcr.getOpportunityId());
                }
                return finishURL.getUrl();
            }else{
                return 'fail';
            }
        } else {
            String allErrors = 'ERRORPlease fix the following errors:\n\n';
            for(String e: errors){
                allErrors += e + '\n\n';
            }
            return allErrors;
        }
        
    }
    public static testMethod void customLeadConversionNOVFTest() {
        
        Quick_Disable__c cs = new Quick_Disable__c(
            Name = 'insertSAP',
            Enable__c = TRUE
        );
        System.debug('insert cs-->' + cs);
        insert cs;
    
        Account acct = new Account(Name='Test Account ');
        insert acct;
        
        Contact cont = new Contact(FirstName='test',lastname='dude',Email='abc@123.com', Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)');
        insert cont;
        
        Contact cont1 = new Contact(FirstName='test1',lastname='dude1',Email='abc1@123.com', Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)');
        insert cont1;
        
        Account_Contact__c accCont = new Account_Contact__c(Account__c=acct.Id, Contact__c=cont.Id);
        insert accCont;
        
        Opportunity opp = new Opportunity(
            Name='a',
            Account=acct,
            StageName='Target',
            Closedate=date.today(),
            Product_Family__c='test',
            Product_Of_Interest__c='test',
            Primary_Contact__c=cont.id
        );
        insert Opp;
        
        Lead lead1 = new Lead(
            FirstName='trey',
            LastName='stone',
            Product_Family__c='test',
            Product_Of_Interest__c='test',
            Account__c=acct.Id,
            Company='test',
            Contact__c=cont.Id
        );
        insert lead1;
        
        Lead lead2 = new Lead(
            FirstName='trey',
            LastName='wood',
            Product_Family__c='test',
            Product_Of_Interest__c='test',
            Account__c=acct.Id,
            Company='test',
            Contact__c=cont.Id
        );
        insert lead2;
        
        Lead lead3 = new Lead(
            FirstName='trey',
            LastName='brick',
            Product_Family__c='test',
            Product_Of_Interest__c='test',
            Account__c=acct.Id,
            Company='test',
            Existing_Opportunity__c=opp.Id,
            Contact__c=cont.Id
        );
        insert lead3;
        
        Lead lead4 = new Lead(
            FirstName='trey',
            LastName='brick',
            Product_Family__c='test',
            Company='test',
            Existing_Opportunity__c=opp.Id,
            Contact__c=cont1.Id
        );
        insert lead4;
        
    
        //Create a reference to the VF page
        //PageReference pageRef = Page.accountsRedirect;
        //Test.setCurrentPageReference(pageRef);
        // if you wanted to test an existing lead, use the line below (assuming your extension expects the ID param to be set)
        //ApexPages.currentPage().getParameters().put('id', lead.Id);
    
        // create an instance of your extension
        // this assumes a new Lead...
        //accountRedirect extension = new accountRedirect(new ApexPages.StandardController(new Lead()));
        // if you wanted to test an existing lead, use the line below...
        /*customLeadConversion extension = new customLeadConversion(new ApexPages.StandardController(lead1));
        customLeadConversion extension2 = new customLeadConversion(new ApexPages.StandardController(lead2));
        customLeadConversion extension3 = new customLeadConversion(new ApexPages.StandardController(lead3));
        
        extension.doConvert();
        extension2.doConvert();
        extension3.doConvert();*/
        
        customLeadConversionNOVF.doConvert(lead1.Id);
        customLeadConversionNOVF.doConvert(lead2.Id);
        customLeadConversionNOVF.doConvert(lead3.Id);
        customLeadConversionNOVF.doConvert(lead4.Id);
    
    }
}