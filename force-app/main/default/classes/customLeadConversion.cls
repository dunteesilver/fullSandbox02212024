public class customLeadConversion{
    
    private ApexPages.StandardController controller {get; set;}    
    private Lead lead {get;set;}
    private PageReference finishURL;
    private string tempAcctId;
    private Contact tempContact;
    private List<Account_Contact__c> tempMultiList;
    private Lead leadContactId;
    private Opportunity ExistingOpportunity;
    
    public customLeadConversion(ApexPages.StandardController controller) {
        this.controller = controller;
        this.lead = (Lead)controller.getRecord();
    }
    
    public PageReference doConvert(){
        
        lead.Status = 'Qualified';
        update lead;
        
        //if(lead.Status != 'Qualified'){
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Only leads with a status of "Qualified" can be converted.'));
        //return null;
        //}   
        
        if(lead.Product_Of_Interest_Latam__c == null && lead.Product_Of_Interest__c==null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Product Family and Product of Interest'));
            //lead.Product_Family__c.addError('Product Family Required');
            return null;
        }    
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id);
        
        if(lead.Account__c != null){
            lc.setAccountId(lead.Account__c);
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter existing account'));
            return null;
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
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Existing Contact must be attached to Existing Account'));
                        return null;
                    }
                }
                
            }
            lc.setContactId(lead.Contact__c);
        }
        
        if(lead.Existing_Opportunity__c != null){
            ExistingOpportunity = [SELECT Product_Family__c, Product_Family_Latam__c FROM Opportunity WHERE Id=:lead.Existing_Opportunity__c LIMIT 1];
            if((lead.Product_Family_Latam__c != ExistingOpportunity.Product_Family_Latam__c) || (lead.Product_Family__c != ExistingOpportunity.Product_Family__c)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Product Family must match on Lead and Existing Opportunity'));
                return null;
            }
            lc.setDoNotCreateOpportunity(true);
            
        } else if(lead.do_not_create_opportunity__c == true){
            lc.setDoNotCreateOpportunity(true);
        } else {
            lc.setDoNotCreateOpportunity(false);
        }
        
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
            return finishURL;
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Conversion unsuccessful'));
            return null;
        }
        
    }
    
    
    
}