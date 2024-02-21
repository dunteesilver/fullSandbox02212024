public without sharing class Education_Record_Update {
    
    // New Stuff
    public Id OrgId {get{ return UserInfo.getOrganizationId();} set;}
    //SELECT Id FROM Document WHERE DeveloperName = 'Teleflex_Logo_72dps'
    public Id logoId {get; set;}
    
    
    // End New
    public ApexPages.StandardController ctrl;
    public CE_Reimbursement_Expense__c crf {get;set;}
    public Education_Record__c er {get; set;}
    public Boolean rosterCount {get; set;}
    public Boolean receiptsCount {get; set;}
    
    public Education_Record_Update(){
    //public Education_Record_Update(ApexPages.StandardController controller) {
        /*
        //ctrl = controller;
        crf = (ApexPages.currentPage().getParameters().get('id') == NULL) ? new CE_Reimbursement_Expense__c():
        [SELECT Id,  Travel_Time__c,  T_Travel__c, Mileage__c, T_InsHours__c,
         Ground_Transportation__c,  Airline_Ticket__c,  Meals__c,  Cad_t__c, Oncontrol__c,
         Hotel__c, Conference_Booth__c,  Education_record__r.education_type__c, Eggs__c, Other_Fee1__c,
         Total_Other1__c, Other_Fee1_Detail__c, Status__c, T_In_Hours__c, Inservice_Hours__c,
         Other_Fee2__c, CMA_Travel__c, T_days__c,Pain__c, Cadaver_Lab__c, Other_Fee2_Detail__c,
         Education_Record__c,  Grand_Total_Reimbursement__c,Notes__c, Total_Travel_Time__c,
         Engagement_Type__c, Reimbursement_Rate__c, Total_Time_Worked__c, Time_Worked__c, 
         T_Air__c,T_Cad_Lab__c, T_Booth__c, T_Ed__c, T_Eggs__c, T_Tran__c, T_Hotel__c, T_Meals__c,
         T_Mil__c, T_Speak__c, T_S_Fee__c, T_ExpCMA__c,  Total_Other2__c,CE_Save_Record__c,
         Education_Record__r.Primary_Product__c, Education_Record__r.Name, CE_Contractor_Email__c, Education_Record__r.SecondaryProduct__c, 
         Education_Record__r.Program__r.Name, Education_Record__r.Date_of_Event_Start__c, Education_Record__r.Account_Facility__r.Name, 
         Education_Record__r.Contact_Name__r.FirstName, Education_Record__r.Clinical_Educator__r.FullName__c, Education_Record__r.Total_Lab_Days__c, 
         Education_Record__r.Clinical_Educator__r.E_mail_Address__c, Education_Record__r.of_Attendees__c, Education_Record__r.How_did_the_training_go__c, 
         Education_Record__r.copy_Recordtype__c, Education_Record__r.business_unit__c, Education_Record__r.How_did_the_training_go_Explain__c, 
         Education_Record__r.Clinical_Educator_Email__c, Education_Record__r.Roster_Attached__c, Education_Record__r.Type_of_In_Service__c, 
         Education_Record__r.RecordType.Name, Lab_Role__c, Education_Record__r.Ending_Date__c, Education_Record__r.Comments_from_Attendees__c
         FROM CE_Reimbursement_Expense__c 
         WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
             
             ctrl = controller;
        */
        
        crf = [SELECT Id,  Travel_Time__c,  T_Travel__c, Mileage__c, T_InsHours__c,
               Ground_Transportation__c,  Airline_Ticket__c,  Meals__c,  Cad_t__c, Oncontrol__c,
               Hotel__c, Conference_Booth__c,  Education_record__r.education_type__c, Eggs__c, Other_Fee1__c,
               Total_Other1__c, Other_Fee1_Detail__c, Status__c, T_In_Hours__c, Inservice_Hours__c,
               Other_Fee2__c, CMA_Travel__c, T_days__c,Pain__c, Cadaver_Lab__c, Other_Fee2_Detail__c,
               Education_Record__c,  Grand_Total_Reimbursement__c,Notes__c, Total_Travel_Time__c,
               Engagement_Type__c, Reimbursement_Rate__c, Total_Time_Worked__c, Time_Worked__c, 
               T_Air__c,T_Cad_Lab__c, T_Booth__c, T_Ed__c, T_Eggs__c, T_Tran__c, T_Hotel__c, T_Meals__c,
               T_Mil__c, T_Speak__c, T_S_Fee__c, T_ExpCMA__c,  Total_Other2__c, CE_Save_Record__c, Education_Record__r.TotalofAttendees__c,
               CE_Contractor_Email__c, Travel_Eligible__c, Clinical_Educator_Name__c, PresentationPrepTime__c, TotalPresentation__c   
               /*
               Education_Record__r.Primary_Product__c, Education_Record__r.Name, Education_Record__r.SecondaryProduct__c, Education_Record__r.Id,
               Education_Record__r.Program__r.Name, Education_Record__r.Date_of_Event_Start__c, Education_Record__r.Account_Facility__r.Name, 
               Education_Record__r.Contact_Name__r.FirstName, Education_Record__r.Clinical_Educator__r.FullName__c, Education_Record__r.Total_Lab_Days__c, 
               Education_Record__r.Clinical_Educator__r.E_mail_Address__c, Education_Record__r.of_Attendees__c, Education_Record__r.How_did_the_training_go__c, 
               Education_Record__r.copy_Recordtype__c, Education_Record__r.business_unit__c, Education_Record__r.How_did_the_training_go_Explain__c, 
               Education_Record__r.Clinical_Educator_Email__c, Education_Record__r.Roster_Attached__c, Education_Record__r.Type_of_In_Service__c, 
               Education_Record__r.RecordType.Name, Lab_Role__c, Education_Record__r.Ending_Date__c, Education_Record__r.Comments_from_Attendees__c
               */
               FROM CE_Reimbursement_Expense__c 
               WHERE Id =: ApexPages.currentPage().getParameters().get('id') LIMIT 1];
        er = [SELECT Id, Primary_Product__c, Name, SecondaryProduct__c, Program__r.Name, Date_of_Event_Start__c, Account_Facility__r.Name, 
              Contact_Name__r.FirstName, Clinical_Educator__r.FullName__c, Total_Lab_Days__c, Clinical_Educator__r.E_mail_Address__c, of_Attendees__c, 
              How_did_the_training_go__c, copy_Recordtype__c, business_unit__c, How_did_the_training_go_Explain__c, Clinical_Educator_Email__c, 
              Roster_Attached__c, Type_of_In_Service__c, RecordType.Name, Ending_Date__c, Comments_from_Attendees__c, TotalofAttendees__c
              FROM Education_Record__c 
              WHERE Id = :crf.Education_Record__r.Id];

        rosterCount = FALSE;
        for(Attachment att : [SELECT Id 
                              FROM Attachment 
                              WHERE ParentID = :crf.Education_Record__c])
        {
            rosterCount = TRUE;
        }
        
        receiptsCount = FALSE;
        for(Attachment att : [SELECT Id 
                              FROM Attachment 
                              WHERE ParentID =: crf.Id])
        {
            receiptsCount = TRUE;            
        }
        //{ return [SELECT Id FROM Document WHERE DeveloperName = 'Teleflex_Logo_72dps'].Id;}
        for(Document d : [SELECT Id FROM Document WHERE DeveloperName = 'Teleflex_Logo_72dps'])
        {
            logoId = d.Id;
        }

        if(ApexPages.currentPage().getParameters().get('success') == 'true'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your roster was successfully uploaded.  You can now Submit for Approval. Be sure all appropriate recipes, rosters, information is uploaded prior to submission. You will not be able to edit once submitted'));
            ApexPages.currentPage().getParameters().remove('success');
        }
        
        if(crf.Status__c == 'Pending Approval'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Record is currently being reviewed.'));
        }
        
        if(crf.Status__c == 'Approved for Payment'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Record has been approved.'));
        }
    }//end of constructor
    
    public PageReference save() {
        
        try{
            Education_Record__c saveEdu = new Education_Record__c(
                id = crf.Education_Record__c,
                of_Attendees__c = er.of_Attendees__c,
                Comments_from_Attendees__c = er.Comments_from_Attendees__c,
                How_did_the_training_go__c = er.How_did_the_training_go__c,
                How_did_the_training_go_Explain__c = er.How_did_the_training_go_Explain__c,
                Clinical_Educator_Email__c = er.Clinical_Educator_Email__c,
                Type_of_In_Service__c = er.Type_of_In_Service__c
            );
            crf.CE_Save_REcord__c = True;
            update CRF;
            update saveEdu;
            
            PageReference AddAttachmentPage = new PageReference('/ClinicalEducation/Education_Record_AddAttachment2?ID='+crf.Id);
            AddAttachmentPage.setRedirect(true);
            return AddAttachmentPage;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            
            return null;
        }
    }//end of save
    
    public List<Attachment> getRosters(){
        List<Attachment> rosters = [SELECT id, name, LastModifiedDate, Owner.Name, CreatedBy.Name FROM Attachment WHERE ParentID =: crf.Education_Record__c];
        return rosters;
    }
    
    public List<Attachment> getReceipts(){
        List<Attachment> receipts = [SELECT id, name, LastModifiedDate, Owner.Name, CreatedBy.Name FROM Attachment WHERE ParentID =: crf.Id];
        return receipts;
    }
    
    //set redirect to true sending the id
    public PageReference submit() {

        String recId = ApexPages.currentPage().getParameters().get('id');
        //Below SOQL to get Service Account ID to submit record for Approval due to Winer '21 Update in SF
        String tfxServiceId = [SELECT Id FROM User WHERE Name = 'TFX Service Account'].Id;
        
        try{
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(recId);
            req1.setSubmitterId(tfxServiceId); 
            Approval.ProcessResult result = Approval.process(req1);
            if(result.isSuccess()){
                //retUrl = new pagereference('/apex/Education_Record_Instructions?id='+ crf.Id).setRedirect(true);
                /*retUrl = new pageReference('/apex/Education_Record_Instructions?id=' + ApexPages.currentPage().getParameters().get('id'));
                system.debug('*** After retUrl redirect *** ');
                retUrl.setRedirect(true);
                return retUrl;*/
                return new Pagereference('/ClinicalEducation/Education_Record_Instructions?id='+recId).setRedirect(True);
            }
            else{
                return new Pagereference('/ClinicalEducation/Education_Record_Instructions?id='+recId).setRedirect(True);
            }
            
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
        
    }//end of submit()
    
    public PageReference saveRefresh() {
        
        try{
            update crf;
            update er;
            /*
PageReference refreshedPage = new PageReference('/apex/Education_Record_CEPublic?id='+CRF.Id);
refreshedPage.setRedirect(true);
return refreshedPage;*/
            return new Pagereference('/ClinicalEducation/Education_Record_CEPublic?id='+ApexPages.currentPage().getParameters().get('id')).setRedirect(True);
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }//end of saveRefresh
/*
 @future(callout=true)
    Public static void sendemail(LIST<id> crfids)
    {
        List<CE_Reimbursement_Expense__c> crfs=new List<CE_Reimbursement_Expense__c>();
        list<string> emailList = new list<string>();

        crfs = [SELECT Id, Name, CE_Contractor_Email__c, Education_Record__c, Education_Record__r.Contact_Email__c,
                Education_Record__r.copy_recordtype__c, Education_Record__r.business_unit__c
                FROM CE_Reimbursement_Expense__c WHERE Id IN:crfids ];

        // We now search for the template based on the above SOQL query by technical name. - ESC 16Sep2016
        Id templateId = [SELECT Id from EmailTemplate WHERE DeveloperName = 'CA_Check_Request_Form_Supa' LIMIT 1].Id;

        for (CE_Reimbursement_Expense__c crf: crfs) {
            emailList.clear();
            // Test Class: Education_Record_CE_Expenses_Form_Test

            system.debug('sendEmail to'+ crf.CE_Contractor_Email__c);
            String contEmail = crf.Education_Record__r.Contact_Email__c;

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            for(CS_Education_Record__C cser : [SELECT Administrative_Assistant_Email__c
                                               FROM CS_Education_Record__c
                                               WHERE RecordType__c =: crf.Education_Record__r.copy_Recordtype__c
                                               AND Business_Unit_Abbr__c =: crf.Education_Record__r.business_unit__C])
            {
                emailList.add(cser.Administrative_Assistant_Email__c);
                emailList.add('Kristin.Elliott@teleflex.com');
            }
            message.setCCAddresses(emailList);
            message.setReplyTo(contEmail); //added replyTo to fix issue with user's replying back to Salesforce.com Team
            // We now search for the template based on the above SOQL query by technical name. - ESC 16Sep2016
            message.setTemplateID(templateId);

            // This set's the TO
            message.setTargetObjectId('003E000001ZTlRJ') ; // This is AP
            //message.setTargetObjectId('003E000001WG2OF') ; // This is eric.clay@teleflex.com

            //sandbox message.setTargetObjectId('0035600000BrHrk') ;
            message.setWhatId(crf.Id);
            message.setSaveAsActivity(true);
            // Cath error in the attachments to A/p
            try{
                system.debug('*** Body to PDF ***');
            }
            catch(Exception e){
                system.debug('*** Failed to get Body as PDF ***');
            }

            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

            for (Attachment a : [select Id, Name, Body, BodyLength, ContentType from Attachment where ParentId = :crf.Id])
            {
                // Add to attachment file list
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                If (a.ContentType<>'application/pdf'){
                    efa.setFileName(a.Name);
                }
                Else{
                    efa.setFileName(a.Name+'.pdf');
                    efa.setContentType('application/pdf');
                }
                efa.setBody(a.Body);
                efa.setcontenttype(a.ContentType);
                fileAttachments.add(efa);
            }
            message.setFileAttachments(fileAttachments);
            //Send Email with attachments
            try{
                system.debug('Sending email to A/P');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ message });
            }
            catch(Exception e){
                system.debug('Exception caught... no email was sent.' +e);
            }

        }//end of for loop

    }//end of sendemail method
*/
}//end of class