public class CE_Reimbursement_Expense_Helper_Class {
    // Education_Helper_Class is the sister class
    public static void updateLookups(List<CE_Reimbursement_Expense__c> newTrigger){
        for(CE_Reimbursement_Expense__c ce : newTrigger){
            if(ce.Travel_Eligible__c != ce.Workflow_Travel_Eligible__c){
                ce.Travel_Eligible__c = ce.Workflow_Travel_Eligible__c;
            }
        }
    }
    
    public static void finalEmailtoAP(List<CE_Reimbursement_Expense__c> newTrigger){
        // This class looks at the Expense records and sends them to AP if they're ready.
        system.debug('Starting Opp Approval Info Trigger - After Update');
        
        List<Id> CRFIds = new List<Id>();
        for (CE_Reimbursement_Expense__c crf: newTrigger) {
            if(
                system.isFuture() == FALSE && 
                crf.Status__c == 'Approved for Payment' && 
                crf.Email_Sent_to_AP__c == FALSE
            ){
               CRFIds.add(CRF.Id); 
            } 
        }
        // Check the list size before calling the future call to reduce empty calls that are filling up the logs now. 12Sep2016 - ESC
        if(CRFIds.size() > 0){
            CE_Reimbursement_Expense_Helper_Class.sendemail(CRFIds);   
        }
    }
    
    // Moved from Education_Record_Update which is a VF controller class
    // 18Oct2017 - ESC
    @future(callout=true)
    Public static void sendemail(list<id> crfids){
        // Test Class: Education_Record_CE_Expenses_Form_Test

        // We now search for the template based on the above SOQL query by technical name. - ESC 16Sep2016
        Id templateId = [SELECT Id from EmailTemplate WHERE DeveloperName = 'CA_Check_Request_Form_Supa' LIMIT 1].Id;
        // Load in the Custom Settings in to list.
        list<CS_Education_Record__c> csList = CS_Education_Record__c.getall().values(); 
        // List to store the CC email addresses
        list<string> emailList = new list<string>();
        list<CE_Reimbursement_Expense__c> crfUpdateList = new list<CE_Reimbursement_Expense__c>();
        
        // Cycle through the records
        for (CE_Reimbursement_Expense__c crf: [SELECT Id, Name, CE_Contractor_Email__c, Education_Record__c, 
                                               Education_Record__r.Contact_Email__c,
                                               Education_Record__r.copy_recordtype__c, 
                                               Education_Record__r.business_unit__c,PresentationPrepTime__c,TotalPresentation__c
                                               FROM CE_Reimbursement_Expense__c 
                                               WHERE Id = :crfids ]) 
        {
            CE_Reimbursement_Expense__c updateCRF = new CE_Reimbursement_Expense__c(
                id = crf.Id,
                Email_Sent_to_AP__c = TRUE
            );
            crfUpdateList.add(updateCRF);
            
            emailList.clear(); // Empty out the list from previous loops/iterations

            system.debug('sendEmail to'+ crf.CE_Contractor_Email__c);
            String contEmail = crf.Education_Record__r.Contact_Email__c;
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            
            // Loop through the custom setting for the Administrative Assistants Email Address (18Oct2017 - ESC)
            for(CS_Education_Record__C cser : csList)
            {
                if(
                    cser.RecordType__c == crf.Education_Record__r.copy_Recordtype__c && 
                    cser.Business_Unit_Abbr__c == crf.Education_Record__r.business_unit__c
                )
                {
                    emailList.add(cser.Administrative_Assistant_Email__c);
                    emailList.add(cser.SFDC_Admin_Email__c); // This replaced the static email address.
                    //emailList.add('Kristin.Elliott@teleflex.com');   -- Let's kill the static email address.
                }
            }
            
            /* -- Old method was not properly bulked
            for(CS_Education_Record__C cser : [SELECT Administrative_Assistant_Email__c
                                               FROM CS_Education_Record__c
                                               WHERE RecordType__c =: crf.Education_Record__r.copy_Recordtype__c
                                               AND Business_Unit_Abbr__c =: crf.Education_Record__r.business_unit__C])
            {
                emailList.add(cser.Administrative_Assistant_Email__c);
                emailList.add('Kristin.Elliott@teleflex.com');
            }*/
            
            message.setCCAddresses(emailList);
            message.setReplyTo(contEmail); //added replyTo to fix issue with user's replying back to Salesforce.com Team
            message.setTemplateID(templateId); // Set above before the loop.
            
            // This set's the TO
            message.setTargetObjectId('003E000001ZTlRJ') ; // This is the AP Contract Record O_O
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
            
            for(Attachment a : [SELECT Id, Name, Body, BodyLength, ContentType 
                                FROM Attachment 
                                WHERE ParentId = :crf.Id])
            {
                // Add to attachment file list
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                If(a.ContentType<>'application/pdf'){
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
                update crfUpdateList; // Updates "Email Sent to Contractor" to TRUE
            }
            catch(Exception e){
                system.debug('Exception caught... no email was sent.' +e);
            }

        }//end of for loop

    }//end of sendemail method
}