/****************************************
Apex Class :  BatchContactInfoValidate
Description : Batch Class 
Author :  
****************************************/

global class BatchContactInfoValidate implements Database.Batchable<sObject>,Database.stateful{
    Set<String> checkEmailStrlst = new Set<String> ();
    global Database.QueryLocator start(Database.BatchableContext BC){    
        
        String query = 'SELECT Id, FirstName, LastName, AccountId,email, phone,owner.email, ownerId,owner.Name FROM Contact where AccountId = null and Email = null and Phone = null and MobilePhone = null';
        System.Debug('Main Query'+query);
        return Database.getQueryLocator(query);
     }

     global void execute(Database.BatchableContext BC, List<Sobject> scope){ 
         EmailTemplate et = [Select Id,Subject,Body from EmailTemplate where Name = 'ContactOwnersNoAcct' Limit 1];
         String subject = et.Subject;
         String htmlBody = et.Body;
         Report rep = [SELECT DeveloperName, Id, Name FROM Report WHERE Name = 'Contact Record Validate' LIMIT 1];
         for(sObject s : scope){
              Contact  c = (Contact)s;
              System.debug('Email'+c.owner.email);
              if(!checkEmailStrlst.contains(c.owner.email)){
                  String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + rep.Id+'?pv4='+c.owner.Name;
                  System.debug('ReporTUrl::'+fullRecordURL);
                  htmlBody = htmlBody.replace('{!Contact.Link}', fullRecordURL);
                  sendmail(c.owner.email, c.Id, et.Id, c.OwnerId, subject,htmlBody);
                  
              }
              checkEmailStrlst.add(c.owner.email);
         }
         
     }

     global void finish(Database.BatchableContext BC){
             
     }
     
     global void sendmail(String email, String conId, String emailtempId,String userId,String subject, String body){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            System.debug('Email'+email);
            mail.setToaddresses(new String[] {email});
            mail.settargetObjectId(userId);
            mail.setPlainTextBody(body);
            mail.setSubject(subject);
            mail.setsaveAsActivity(False);
            Messaging.sendEmail(New Messaging.SingleEmailMessage[]{mail});
            System.debug('EmailSent::::');
         
     }  
}