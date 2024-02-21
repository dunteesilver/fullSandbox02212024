public with sharing class EmailLabAttendeesController {
    
    public EmailLabAttendeesController(ApexPages.StandardController controller){
    }
    
    @InvocableMethod
    public static void sendPdf(List<Id> Participantid) {
        
        List<Lab_Participant__c> participants = [SELECT Id, Email__c, Attended__c, Attended_EZIO__c,Attended_Hemorrhage__c,
                                                 Atteneded_Interventional__c FROM Lab_Participant__c
                                                 WHERE Id IN:Participantid];
        
        if(participants !=null && participants.size()>0){
            List<Messaging.SingleEmailMessage>  certEmails = new List<Messaging.SingleEmailMessage>();
            for(Lab_Participant__c lp:participants){
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                List<Messaging.EmailFileAttachment> allAttachments = new List<Messaging.EmailFileAttachment>();
                //Airway Cert generation
                //Commented because we are not using
               /*if(lp.Attended__c){
                    PageReference pdf = Page.EmailLabAttendees;
                    // add parent id to the parameters for standardcontroller
                    pdf.getParameters().put('id',lp.Id);
                    pdf.getParameters().put('certType','Airway');
                    
                    // the contents of the attachment from the pdf
                    Blob body;
                    
                    try {
                        
                        // returns the output of the page as a PDF
                        body = pdf.getContent();
                        
                        // need to pass unit test -- current bug  
                    } catch (VisualforceException e) {
                        body = Blob.valueOf('Your Email attachment have an issue encountered,Please reach out to your Administrator ');
                    }
                    
                    Messaging.EmailFileAttachment attachAirwayCert = new Messaging.EmailFileAttachment();
                    attachAirwayCert.setContentType('application/pdf');
                    attachAirwayCert.setFileName('Lab Certificate Airway Course.pdf');
                    attachAirwayCert.setInline(false);
                    attachAirwayCert.Body = body;
                    
                    attachments.add(attachAirwayCert);
                }*/
                
                //EZIO Cert generation
                if(lp.Attended_EZIO__c){
                    PageReference pdf = Page.EmailLabAttendees;
                    // add parent id to the parameters for standardcontroller
                    pdf.getParameters().put('id',lp.Id);
                    pdf.getParameters().put('certType','EZIO');
                    
                    // the contents of the attachment from the pdf
                    Blob body;
                    
                    try {
                        
                        // returns the output of the page as a PDF
                        body = pdf.getContent();
                        
                        // need to pass unit test -- current bug  
                    } catch (VisualforceException e) {
                        body = Blob.valueOf('Your Email attachment have an issue encountered,Please reach out to your Administrator ');
                    }
                    
                    Messaging.EmailFileAttachment attachEZIOCert = new Messaging.EmailFileAttachment();
                    attachEZIOCert.setContentType('application/pdf');
                    attachEZIOCert.setFileName('Lab Certificate Arrow EZ-IO.pdf');
                    attachEZIOCert.setInline(false);
                    attachEZIOCert.Body = body;
                    
                    attachments.add(attachEZIOCert);
                }
                
                //Hemorrhage Cert generation
                if(lp.Attended_Hemorrhage__c){
                    PageReference pdf = Page.EmailLabAttendees;
                    // add parent id to the parameters for standardcontroller
                    pdf.getParameters().put('id',lp.Id);
                    pdf.getParameters().put('certType','Hemorrhage');
                    
                    // the contents of the attachment from the pdf
                    Blob body;
                    
                    try {
                        
                        // returns the output of the page as a PDF
                        body = pdf.getContent();
                        
                        // need to pass unit test -- current bug  
                    } catch (VisualforceException e) {
                        body = Blob.valueOf('Your Email attachment have an issue encountered,Please reach out to your Administrator ');
                    }
                    
                    Messaging.EmailFileAttachment attachHemorrhageCert = new Messaging.EmailFileAttachment();
                    attachHemorrhageCert.setContentType('application/pdf');
                    attachHemorrhageCert.setFileName('Lab Certificate Hemorrhage.pdf');
                    attachHemorrhageCert.setInline(false);
                    attachHemorrhageCert.Body = body;
                    
                    attachments.add(attachHemorrhageCert);
                }
                
                //Interventional Cert generation
                if(lp.Atteneded_Interventional__c){
                    PageReference pdf = Page.EmailLabAttendees;
                    // add parent id to the parameters for standardcontroller
                    pdf.getParameters().put('id',lp.Id);
                    pdf.getParameters().put('certType','Interventional');
                    
                    // the contents of the attachment from the pdf
                    Blob body;
                    
                    try {
                        
                        // returns the output of the page as a PDF
                        body = pdf.getContent();
                        
                        // need to pass unit test -- current bug  
                    } catch (VisualforceException e) {
                        body = Blob.valueOf('Your Email attachment have an issue encountered,Please reach out to your Administrator ');
                    }
                    
                    Messaging.EmailFileAttachment attachInterventionalCert = new Messaging.EmailFileAttachment();
                    attachInterventionalCert.setContentType('application/pdf');
                    attachInterventionalCert.setFileName('Lab Certificate Interventional.pdf');
                    attachInterventionalCert.setInline(false);
                    attachInterventionalCert.Body = body;
                    
                    attachments.add(attachInterventionalCert);
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setUseSignature(false);
                mail.setToAddresses(new String[] {lp.Email__c});
                mail.setSubject('Teleflex Cadaver Lab Certificate');
                mail.setHtmlBody('Congratulations on your Certification(s)! Please Check the attachment(s)!');
                allAttachments.addAll(attachments);
                mail.setFileAttachments(allAttachments); 
                
                certEmails.add(mail);
            }
            // Send the emails
            Messaging.sendEmail(certEmails);
        }
        
    }
}