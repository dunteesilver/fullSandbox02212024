public without sharing class Education_Record_AddAttachment {
    // We need to get the CRF Id / Education Record ID
    
    // New Stuff
    public Id OrgId {get{ return UserInfo.getOrganizationId();} set;}
    //SELECT Id FROM Document WHERE DeveloperName = 'Teleflex_Logo_72dps'
    public Id logoId {get{ return [SELECT Id FROM Document WHERE DeveloperName = 'Teleflex_Logo_72dps'].Id;} set;}
    
    public Id crfid {
        get{
            crfid = ApexPages.currentPage().getparameters().get('ID');
            return crfid;
        }
        set;
    }
    
    Public CE_Reimbursement_Expense__c Reimb {get;set;}
    
    public Attachment attachment {
        get {
            if (attachment == null)
                attachment = new Attachment();
            return attachment;
        }
        set;
    }
    
    public PageReference uploadroster() {
        
        Reimb = [select id,name,Education_Record__r.id, Education_Record__r.RecordType.Name from CE_Reimbursement_Expense__c where id=:CRFID];
        
        attachment.OwnerId = UserInfo.getUserId();
        attachment.Name = 'Roster';
        attachment.ParentId = Reimb.Education_Record__r.id; // the record the file is attached to
        attachment.IsPrivate = false;
        system.debug('attachment.ContentType *** ' + attachment.ContentType);
        
        Attachment attachment2 = new Attachment();
        attachment2.body = attachment.body;
        attachment2.OwnerId = UserInfo.getUserId();
        attachment2.Name = 'Roster';
        attachment2.ParentId = crfid; // the record the file is attached to
        attachment2.IsPrivate = false;
        attachment2.ContentType = attachment.ContentType;
        system.debug('attachment2.ContentType *** ' + attachment2.ContentType);
        
        
        try {
            insert attachment;
            insert attachment2;
            Reimb.Roster_Attached_in_Portal__c = TRUE;
            update Reimb;
            //   attachment.ParentID = Reimb.Id;
            //  insert attachment;
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
            PageReference AddAttachmentPage2 = new PageReference('/ClinicalEducation/Education_Record_CEPublic?ID='+crfid+'&success=true');
            AddAttachmentPage2.setRedirect(true);
            return AddAttachmentPage2;
            
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            return null;
        }
    }//end of uploadroster
    
    public PageReference upload() {
        
        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = crfid; // the record the file is attached to
        attachment.IsPrivate = false;
        system.debug('attachment.ContentType *** ' + attachment.ContentType);
        try {
            insert attachment;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            return null;
        } finally {
            attachment = new Attachment();
        }
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
        return null;
    }//end of upload
    
    public PageReference go_next_step() {
        
        if(attachment.body != NULL){
            upload();
        }
        
        PageReference AddAttachmentPage = new PageReference('/ClinicalEducation/Education_Record_AddAttachment?ID='+CRFId);
        AddAttachmentPage.setRedirect(true);
        return AddAttachmentPage;
    }//end of go_next_step
    
    
}//end of class