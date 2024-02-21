public class PP_Print_Center {
    // Test Class: PP_Print_Quote_Test
    public Price_Quote__c pqRec {get;set;}
    public string qId {get;set;}
    public string custEmail {get;set;}
    public String selectedReport { get; set; }  // Report selected
    public String subject { get; set; }
    public String lang { get{
        if(pqRec.Language__c != NULL){
            if(pqRec.Language__c == 'English'){
                lang = 'en';
                RETURN '&lang=en';
            }
            else if(pqRec.Language__c == 'French'){
                lang = 'fr';
                RETURN '&lang=fr';
            }
            else if(pqRec.Language__c == 'Spanish'){
                lang = 'es';
                RETURN '&lang=es';
            }
            else if(pqRec.Language__c == 'German'){
                lang = 'de';
                RETURN '&lang=de';
            }
            else if(pqRec.Language__c == 'Dutch'){
                lang = 'nl';
                RETURN '&lang=nl';
            }
            else if(pqRec.Language__c == 'Czech'){
                lang = 'cs';
                RETURN '&lang=cs';
            }
            else if(pqRec.Language__c == 'Polish'){
                lang = 'pl';
                RETURN '&lang=pl';
            }
            else if(pqRec.Language__c == 'Portuguese'){
                lang = 'pt_PT';
                RETURN '&lang=pt_PT';
            }
            else if(pqRec.Language__c == 'Slovak'){
                lang = 'sk';
                RETURN '&lang=sk';
            }
            else if(pqRec.Language__c == 'Slovakian'){
                lang = 'sk';
                RETURN '&lang=sk';
            }
            else if(pqRec.Language__c == 'Italian'){
                lang = 'it';
                RETURN '&lang=it';
            }
            else{
                lang = 'en';
                RETURN '&lang=en';
            }
        }
        else{
            lang = 'en';
            RETURN '&lang=en';
        }
    } set;}
    public String body { get; set; }
    public Boolean bccCheck { get; set; }

    public String qURL { get{
        Map<String, Quote_Logos__c> buMap = Quote_Logos__c.getAll();
        System.debug('****buMap**** ' + buMap);
        System.debug('****buMap.get(pqRec.Stationary__c).Quote_Page__c**** ' + buMap.get(pqRec.Stationary__c).Quote_Page__c);
        if(buMap.get(pqRec.Stationary__c) != NULL){
            System.debug('****IN IF Stationary****');
            return buMap.get(pqRec.Stationary__c).Quote_Page__c;
        }
        else{
            return 'PP_Print_Quote_TFX';
        }
    } set; }

    public PP_Print_Center(){
        pqRec = [SELECT Name, Id, Status__c, Account_Name__r.Name, Contact_Name__r.Name,
                 Stationary__c, Show_Images__c, Show_List_Price__c, Contact_Name__r.Email,
                 Account_Name__r.Sap_Sold_To__c, Approval_Flag_Rollup__c, Owner_ID__c,
                 Template__c, Language__c, Discount__c, Discount_Type__c, Discounted_Total__c,
                 Business_Unit__c, BusinessUnit__c, Language_Formula__c
                 FROM Price_Quote__c
                 WHERE id = :ApexPages.currentPage().getParameters().get('id')
                 LIMIT 1];

    }

    public Price_Quote__c getpq(){
        return pqRec;
    }

    public PageReference save(){
        update pqRec;
        return NULL;
    }


    public PageReference preview() {
        update pqRec;

        PageReference redir = New Pagereference('/apex/' + qURL + '?r=pdf&id=' + ApexPages.currentPage().getParameters().get('id') + lang);

        redir.setRedirect(true);
        return redir;
    }

    public PageReference saveFile() {

        PageReference redir = New Pagereference('/apex/PP_Print_Quote_File_Export?r=pdf&id=' + pqRec.Id);

        redir.setRedirect(false);
        return redir;
    }

    public PageReference cancel() {

        PageReference redir = New Pagereference('/apex/PP_Price_Quote?pqid=' + ApexPages.currentPage().getParameters().get('id'));
        redir.setRedirect(true);
        return redir;
    }

    public PageReference print() {

        PageReference redir = New Pagereference('/apex/' + qURL + '?r=pdf&id=' + ApexPages.currentPage().getParameters().get('id') + lang);
        redir.setRedirect(true);
        return redir;
    }

    public map<string, string> getsm(){

        map<string, string> sMap = new map<string, string>();
        //sMap.put('', 'Test');
        for(Quote_Logos__c ql : Quote_Logos__c.getAll().values()){
            sMap.put(ql.name, ql.URL__c);
        }
        system.debug('*** Mapping *** ' + sMap);
        return sMap;
    }

//Email Quote
    // Action method for the [Send Account Summary] button
    public PageReference sendReport() {

		qId = ApexPages.currentPage().getParameters().get('id');
    	system.debug('qId ***** ' + qId);
        //custEmail = ApexPages.currentPage().getParameters().get('email');
        //custEmail = [SELECT Owner_Email__c FROM Price_Quote__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')].Owner_Email__c;
        custEmail = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()].email;
        
        //surya.arvan@teleflex.com - 08.20.2020 - adding code to email cc quote owner.
        String qteOwnrEm = [SELECT Owner_Email__c FROM Price_Quote__c WHERE id =: qId].Owner_Email__c;
        // NOTE: Abbreviated error checking to keep the code sample short
        //       You, of course, would never do this little error checking
        /*
        if(String.isBlank(this.qid) || String.isBlank(this.custEmail)) {
            ApexPages.addMessage(new
                ApexPages.Message(ApexPages.Severity.ERROR,
               'Errors on the form. Please correct and resubmit.'));
            return null; // early out
        }
        */
        // Get quote name for email message strings
        /*
        Price_Quote__c quote = [SELECT Name,Contact_Name__c, Account_Name__r.Name, Account_Name__r.Sap_Sold_To__c
                           FROM Price_Quote__c
                           WHERE Id = :this.qId
                           LIMIT 1];
        */
        /*
        if(null == quote) {
            // Got a bogus ID from the form submission
            ApexPages.addMessage(new
                ApexPages.Message(ApexPages.Severity.ERROR,
               'Invalid account. Please correct and resubmit.'));
            return null; // early out
        }
        */
        // Create email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new String[]{ this.custEmail });
        message.setCcAddresses(new String[]{ qteOwnrEm });
        //message.setTargetObjectId(quote.Contact_Name__c);
        //message.setSaveAsActivity(true);
        //message.setWhatId(qId);
        message.setSubject('Quote summary for ' + pqRec.Name);
        message.setHtmlBody('Here\'s a summary for the ' + pqRec.Name + ' quote.');

        string quoteURL;
        Map<String, Quote_Logos__c> buMap = Quote_Logos__c.getAll();
        if(buMap.get(pqRec.Stationary__c) != NULL){
            quoteURL = buMap.get(pqRec.Stationary__c).Quote_Page__c;
        }
        else{
            quoteURL = 'PP_Print_Quote';
        }

        PageReference PP_Print_Quote_POC = New PageReference('/apex/' + quoteURL + '?id=' + pqRec.Id + lang);
        Blob quotePDF;
        try {
            system.debug('In Try Block ==================== ');
            quotePDF = PP_Print_Quote_POC.getContentAsPDF();
            system.debug('quotePDF==================== ' + quotePDF);
        }
        catch (Exception e) {
            system.debug('In Exception ==================== ');
            quotePDF = Blob.valueOf(e.getMessage());
        }

        system.debug('quotePdf==================== ' + quotePdf);
        // Attach PDF to email and send
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        Attachment att = new Attachment();
        attachment.setContentType('application/pdf');
        attachment.setFileName(pqRec.Name + '-' + pqRec.Account_Name__r.Name + '-#' + pqRec.Account_Name__r.Sap_Sold_To__c + '-' + datetime.Now() + '.pdf');
        attachment.setInline(false);
        attachment.setBody(quotePDF);
        att.Body = quotePDF;
        att.ParentId = pqRec.Id;
        att.ContentType = 'application/pdf';
        att.Name = pqRec.Name + '-' + pqRec.Account_Name__r.Name + '-#' + pqRec.Account_Name__r.Sap_Sold_To__c + '-' + datetime.Now();
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{ attachment });
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ message });
        insert att;
        system.debug('attachment==================== ' + attachment);
        //PageReference emailPage = new PageReference('/apex/PP_Print_Center?id={!qId}&email={!custEmail}');

        ApexPages.addMessage(new
            ApexPages.Message(ApexPages.Severity.INFO,
           'Email sent with PDF attachment to ' + this.custEmail));

        //https://teleflex--sandbox.cs14.my.salesforce.com/_ui/core/email/author/EmailAuthor?p3_lkid=a0Sc0000002IUhT&retURL=%2Fa0Sc0000002IUhT
        //return null; // Stay on same page, even on success
        /*
        PageReference redir = New Pagereference('/_ui/core/email/author/EmailAuthor?p3_lkid='
                                                + ApexPages.currentPage().getParameters().get('id') + '&retURL='
                                                + ApexPages.currentPage().getParameters().get('id'));
        */
        //PageReference redir = New Pagereference('/apex/PP_SendEmail?id='+ pqRec.Id);
        //redir.setRedirect(true);
        return null;
    }
//End of email Quote

  //Email Quote to Customer
  public PageReference send() {
      // Define the email
      qId = ApexPages.currentPage().getParameters().get('id');
      system.debug('qId ***** ' + qId);

      String bccEmail = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()].email;

      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

      // Reference the attachment page and pass in the account ID
      //PageReference pdf =  Page.attachmentPDF;
      //pdf.getParameters().put('id',(String)account.id);
      //pdf.setRedirect(true);

      // Take the PDF content
      //Blob b = pdf.getContent();

      // Create the email attachment
      //Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
      //efa.setFileName('attachment.pdf');
      //efa.setBody(b);

      String addresses;
      if (pqRec.Contact_Name__r.Email != null) {
          addresses = pqRec.Contact_Name__r.Email;
          // Loop through the whole list of contacts and their emails
      }
      else{
        apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.label.EMEA_Contact_Email1+System.label.EMEA_Contact_Email2));
        return null;
      }

      //String[] toAddresses = addresses.split(':', 0);

      // Sets the paramaters of the email
      email.setSubject( subject );
      //email.setToAddresses( addresses );
      email.setToAddresses(new String[]{ addresses });
      email.setPlainTextBody( body );
      try{
          if(bccCheck){
              system.debug('***** BCCing MYSELF *****');
              system.debug('bccEmail ***** ' + bccEmail);
              email.setBccAddresses(new String[]{ bccEmail });
          }
      }
      catch(Exception e) {
      }


      //email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
      string quoteURL;
      Map<String, Quote_Logos__c> buMap = Quote_Logos__c.getAll();
      if(buMap.get(pqRec.Stationary__c) != NULL){
          quoteURL = buMap.get(pqRec.Stationary__c).Quote_Page__c;
      }
      else{
          quoteURL = 'PP_Print_Quote';
      }

      PageReference PP_Print_Quote_POC = New PageReference('/apex/' + quoteURL + '?id=' + pqRec.Id + lang);

      Blob quotePDF;
      try {
          system.debug('In Try Block ==================== ');
          quotePDF = PP_Print_Quote_POC.getContentAsPDF();
          system.debug('quotePDF==================== ' + quotePDF);
      }
      catch (Exception e) {
          system.debug('In Exception ==================== ');
          quotePDF = Blob.valueOf(e.getMessage());
      }

      //system.debug('quotePdf==================== ' + quotePdf);
      // Attach PDF to email and send
      Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
      Attachment att = new Attachment();
      attachment.setContentType('application/pdf');
      attachment.setFileName(pqRec.Name + '-' + pqRec.Account_Name__r.Name + '-#' + pqRec.Account_Name__r.Sap_Sold_To__c + '-' + datetime.Now() + '.pdf');
      attachment.setInline(false);
      attachment.setBody(quotePDF);
      att.Body = quotePDF;
      att.ParentId = qid;
      att.ContentType = 'application/pdf';
      att.Name = pqRec.Name + '-' + pqRec.Account_Name__r.Name + '-#' + pqRec.Account_Name__r.Sap_Sold_To__c + '-' + datetime.Now();
      email.setFileAttachments(new Messaging.EmailFileAttachment[]{ attachment });

      try{
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });
      }
      catch(Exception e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
      }

      try{
          //create a closed task for email sent to customer
          Task T = new Task();
          T.Type = 'Email';
          T.WhoId = pqRec.Contact_Name__c;
          T.ActivityDate = Date.today();
          T.Subject = 'Email: ' + subject;
          if(!bccCheck){
              T.Description = 'Additional to: ' + pqRec.Contact_Name__r.Email + '\n' +
                  'Attachment: ' + att.Name + '\n\n' +
                  'Subject: ' + subject + '\n' +
                  'Body: ' + body + '\n';
          }
          else{
              T.Description = 'Additional to: ' + pqRec.Contact_Name__r.Email + '\n' +
                  'BCC: ' + bccEmail + '\n' +
                  'Attachment: ' + att.Name + '\n\n' +
                  'Subject: ' + subject + '\n' +
                  'Body: ' + body + '\n';
          }
          T.OwnerId = pqRec.Owner_ID__c; //user id
          T.WhatId = pqRec.Id; //record id
          T.Status = 'Completed';

          insert T;
      }
      catch(Exception e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
      }

      //inserting attachment
      try{
        insert att;
      }
      catch(Exception e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
      }


      //HERE

      //PageReference PP_Print_Quote_POC = New PageReference('/apex/' + quoteURL + '?id=' + pqRec.Id );

      PageReference redir = New Pagereference('/apex/PP_Price_Quote?pqid=' + pqRec.Id);
                                             //'&email='+ ApexPages.currentPage().getParameters().get('email'));

      redir.setRedirect(true);
      return redir;

  }//end of Email Quote to Customer

  //process to redirect to Send Email page
  public PageReference sendEmail(){
      try{
          pageReference page = new pageReference('/apex/PP_SendEmail?id=' + pqRec.Id);
          page.setRedirect(true);
          return page;
      }
      catch(Exception e){
          return NULL;
      }

  }//end of direct to Send Email Page

  //process to handle blank email for contact
  public PageReference noEmail(){
    apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.label.EMA_Contact_Email+System.label.EMEA_Please_edit_contact_to_add_a_valid_email_address_or_email_Price_Quote));
    return null;
  }//end of cancel function

  //function to cancel email process
  public PageReference doCancel(){
    pageReference page = new pageReference('/apex/PP_Print_Center?id=' + pqRec.Id);
    page.setRedirect(true);
    return page;
  }//end of cancel function

}