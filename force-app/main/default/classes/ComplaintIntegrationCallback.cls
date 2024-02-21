global class ComplaintIntegrationCallback extends DataSource.AsyncSaveCallback {

    private final String complaintId;

    public ComplaintIntegrationCallback(String complaintId) {
        this.complaintId = complaintId;
    }

    override global void processSave(Database.SaveResult sr){
        if(sr.isSuccess() ){
          System.debug('*** IN processSave isSuccess sr *** ' + sr);
            QM_NotificationSet__x qm = [SELECT Id, Zzqmnum__c
                                        FROM QM_NotificationSet__x
                                        WHERE Id =: sr.Id];
            System.debug('*** qm *** ' + qm);
            Complaint__c c = [SELECT Id, Name, TC__c, CreatedBy.Email, Owner.Email
                              FROM Complaint__c
                              WHERE Id =: complaintId];
            System.debug('*** c *** ' + c);
            c.TC__c = qm.Zzqmnum__c.trim();
            System.debug('*** c.TC__c *** ' + c.TC__c);
            update(c);

            //Prepare and send email confirmation
            String subject = 'Complaint ' + c.Name + ' was successfully created.  TC#: ' + c.TC__c;
            String textBody = 'Complaint ' + c.Name + ' was successfully created in SAP with TC#: ' + c.TC__c + '.  '+
                              'If this number does not appear in the TC# field on the record, please follow ' +
                              'the link below add the number ' + c.TC__c + ' to the record.';

            sendSapConfirmationEmail(subject,textBody,c);
        }//end of if statement
        else{
          System.debug('*** IN processSave failed sr *** ' + sr);
          Complaint__c c = [SELECT Id, Name, TC__c, CreatedBy.Email, Owner.Email
                            FROM Complaint__c
                            WHERE Id =: complaintId];

          for(Database.Error err : sr.getErrors() ){
              System.debug('The following error has occurred.');
              System.debug('FULL ERROR: ' + err );
              System.debug('Error Message: ' + err.getStatusCode() + ': ' + err.getMessage());
              System.debug('Complaint fields that affected this error: ' + err.getFields());
          }
          //Prepare and send email confirmation
          String subject = 'Complaint ' + c.Name + ' was NOT created.';
          String textBody = 'Complaint ' + c.Name + ' was NOT created in SAP.  You can retry this process by clicking \n' +
          'the "Create SAP Complaint" button on the record.  See link below';

          sendSapConfirmationEmail(subject,textBody,c);
        }
    }//end of overrid global void processSave

    public void sendSapConfirmationEmail(String subject, String textBody, Complaint__c c){
      List<String> emailList = new List<String>();
      emailList.add('duntee.silver@teleflex.com');
      // Send an email to the Apex job's submitter notifying of job completion.
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddresses = new String[] {UserInfo.getUserEmail()};
      system.debug('toAddresses *** ' + toAddresses);
      mail.setToAddresses(toAddresses);
      mail.setCcAddresses(emailList);
      mail.setSubject(subject);
      mail.setPlainTextBody
      (textBody + '\n\n Link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.Id +')');
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }//end of sendSapConfirmationEmail

}//end of class