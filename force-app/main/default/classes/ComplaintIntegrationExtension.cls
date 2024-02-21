global class ComplaintIntegrationExtension {

    public QM_NotificationSet__x sapComplaint;
    public Complaint__c comp;
    public Id complaintId{get;set;}
    private final ApexPages.StandardController controller;

    public ComplaintIntegrationExtension() {
    }

    //method to get completed date from Approval Process
    public DateTime setSubmittedComplaintDate(Complaint__c submittedComplaint){
      System.debug('*** IN setSubmittedComplaintDate method IN ComplaintIntegrationExtension Class ***');
      ProcessInstanceStep step = new ProcessInstanceStep();
      DateTime completedDate = NULL;
        try{
            step = [SELECT ActorId,Comments,CreatedById,CreatedDate,Id,OriginalActorId,ProcessInstanceId,StepNodeId,StepStatus,ProcessInstance.TargetObjectId
                    FROM ProcessInstanceStep
                    WHERE ProcessInstance.TargetObjectId = : submittedComplaint.Id AND StepStatus = 'Started'
                    ORDER BY CreatedDate
                    ASC LIMIT 1];

        completedDate = step.CreatedDate;
        }catch(Exception e){
            System.debug('Exception occured in ComplaintIntegrationExtension setSubmittedComplaintDate method: ' + e.getMessage());
        }
        

      return completedDate;

    }//end of setCompletedDate

    //Complaints real data mapping
    public void createSapComplaint(List<Complaint__c> sfdcComplaints){
        System.debug('*** IN createSapComplaint METHOD/ComplaintIntegrationExtension CLASS ***');
        for(Complaint__c curr : sfdcComplaints){
            {
                System.debug('*** NOT VSI OR MANTA COMPLAINT ***');
                if(curr.Status__c == 'Approved' && (curr.TC__c == '' || curr.TC__c == NULL) ){
                    ComplaintIntegrationExtension.sfdcTcMatch(curr.Name, curr.Id);
                }//end of else for Approved Status check
            }

        }//end of for loop sfdcComplaints

    }//end of createSapComplaint1

    /****************************** Webservice Call ************************************/
    webservice static void createSapComplaintService(Id complaintIds, String sfNum){
        System.debug('*** complaintIds *** ' + complaintIds);
        System.debug('*** sfNum *** ' + sfNum);
        ComplaintIntegrationExtension.sfdcTcMatch(sfNum, complaintIds);
    }//end of createSapComplaint
    /****************************** End of Test Webservice Call ************************************/

    @future
    public static void sfdcTcMatch(String sfdcNum, String complaintId){
        System.debug('*** IN sfdcTcMatch METHOD ***');
        String tcMatch = NULL;
        Complaint__c sfdcComplaint = new Complaint__c();
        QM_NotificationSet__x sapComplaint = new QM_NotificationSet__x();

        QM_SFDC_Query__x sf = new QM_SFDC_Query__x();
        
        //query SAP for existing sfdc complaint
        try{
            if(Test.isRunningTest()) {
                sf = new QM_SFDC_Query__x(
                	DisplayUrl = 'https://gwq.teleflex.com/sap/opu/odata/SAP/ZSC_SFDC_PRODUCTION_SRV/QM_SFDC_Query(\'SF036530\')',
                    EccAuthorized__c = 'Y',
                    ExternalId = sfdcNum,
                    ImportSuccessful__c = 'N',
                    Mandt__c = NULL,
                    Message__c = 'Notification Created',
                    Qmnum__c = '000020031740',
                    SfdcApprover__c = 'JANSTEAD',
                    //ZimportDate__c = ,
                    //ZimportTime__c = ,
                    //Zzindex__c = ,
                    ZzsfdcNum__c = sfdcNum
                );
            }
            else{
            	sf = [SELECT DisplayUrl,EccAuthorized__c,ExternalId,Id,ImportSuccessful__c,
                      Mandt__c,Message__c,Qmnum__c,SfdcApprover__c,ZimportDate__c,ZimportTime__c,Zzindex__c,ZzsfdcNum__c
                      FROM QM_SFDC_Query__x
                      WHERE ZzsfdcNum__c =:sfdcNum Limit 1];    
            }
        }catch(Exception e){
            System.debug('Exception occured in ComplaintIntegrationExtension sfdcTcMatch method: ' + e.getMessage());
        }
        

        System.debug('*** QM_SFDC_Query__x *** ' + sf);
        //check to make sure object has values
        if( sf.ImportSuccessful__c == 'N' && sf != NULL ){
            System.debug('*** Search for Existing SAP Complaint failed ***');
            String uName = [SELECT Id, CommunityNickName FROM User WHERE Id =: UserInfo.getUserId()].CommunityNickName;
            System.debug('*** uName initial *** ' + uName);
            System.debug('*** complaintId *** ' + complaintId);

            sfdcComplaint = [SELECT  A_medical_professional_alleged_that__c,A_medical_intervention_was_performed__c,
                             Abnormalities_Doppler_ECG_Waveforms__c, Account__c, Account_Country__c, Account_Number__c,
                             Address__c, After_failed_IO_were_additonal_attempts__c, AgeUoM__c, Anatomical_insertion_site__c,
                             Approximate_delay_in_achieving_access__c, Are_pump_strips_available_for_review__c,
                             Assessment_Strips_attached__c, Can_patient_case_be_downloaded__c, Cardiac_Abnormality_Details__c,
                             Catheter_Placement_Additional_Info__c, Catheter_was_successfully_removed__c, RecordType.Name,
                             Clinician_attempting_insertion__c, Complaint_Related_Comments__c, Components_involved__c,
                             Contact__c, Contact_Email__c, Contact_Name__c, Contact_Phone__c, Contact_Dept__c, Contact_Title__c, CreatedById,
                             CreatedDate, CurrencyIsoCode, Date_Expired__c, Department__c, Describe_identification_insertion_site__c,
                             Describe_intervention_performed__c, Describe_the_problem_encountered__c, Describe_X_ray_findings__c,
                             Description_of_driver_problem__c, Diagnosis__c, Did_clinician_pull_straight_up_removal__c,
                             Did_delay_cause_harm_to_patient__c, Did_device_cause_contribute_to_death_inj__c,
                             Did_ECG_calibrate_on_the_VPS_correctly__c, Did_operator_attempt_manual_placement__c,
                             During_a_patient_treatment__c, During_use_on_a_patient__c, Email__c, Estimated_Event_Date__c,
                             Event_Date__c, EZ_IO_Complaint_Type__c, Follow_up__c, Follow_up_plan__c, Frequency_of_site_checks__c,
                             Gender__c, Has_Customer_Requested_Replacement_Produ__c, Has_operator_placed_EZ_IO_before__c, Height__c,
                             How_long_was_the_delay_interruption__c, How_many_uses__c, How_the_product_was_being_used__c,
                             How_was_the_issue_resolved__c, Id, If_insertion_s_were_successful_how_was__c,
                             If_no_who_made_the_medical_judgement__c, If_no_why_not__c, If_not_what_was_the_new_insertion_site__c,
                             If_yes_how_often_was_the_product_used__c, If_yes_state_basis_for_conclusion__c,
                             If_yes_was_the_same_insertion_site_used__c, In_yellow_or_black_hard_case__c, Indication_for_Use__c,
                             Infectious_Disease_Type__c, Insertion_site_involved_during_issue__c, Internal_Reference__c,
                             Is_operator_aware_a_manual_placement__c, Is_the_complaint_related_to__c,
                             Is_this_complaint_regarding_VPS_Consoles__c, Is_X_ray_available_for_review__c, IsDeleted,
                             Issue_Incident_Description__c, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate,
                             LastViewedDate, Length_of_time_in_use_prior_to_event__c, Leur_lock_syringe__c,
                             List_error_messages_if_applicable__c , List_specific_IABP_Alarms__c, Lot_Number_Action_Taken__c,
                             Medical_History_Diagnosis_Medications__c, Medical_Intervention__c, Medical_Procedure__c,
                             Most_recent_battery_check__c, Name, Needle_length_used_for_insertion__c, Owner_s_Manager_Email__c,
                             OwnerId, Patient_complications_or_injury__c, Patient_exposed_to_infectious_disease__c,
                             Patients_Current_Condition__c, PatientsCurrentConditionDescription__c, Phone_Number__c,
                             Please_provide_rationale_for_answer_yes__c, PO_Invoice__c, Problem_s_involving_call__c,
                             Procedure_discontinued_due_to_the_issue__c, Product_Description__c, Product_List__c, Product_Purchased_From__c,
                             Product_Purchased_From_Text__c, ProductName__c, Pump_used_Brand_Model_Serial__c, RecordTypeId,
                             Rejection_Reason__c, Related_treatment__c, REMINDER__c, Resolution_Outcome__c,
                             Return_Quantity_for_Investigation__c, Second_Attempt_Additional_Info__c, Serial_Number__c,
                             Specific_Case__c, Specify__c, Status__c, Successful__c, Surgical_Reminder__c, SystemModstamp, TC__c,
                             Teleflex_Aware_Date__c, Time_of_Call__c, Title__c, Trigger_guard_on__c, Type_of_Sample_For_Investigation__c,
                             UDI_GTIN__c, Units_with_Alleged_Issue__c, Used_or_contacted_with_Ebola_patient__c,
                             Was_a_back_up_driver_available__c, Was_a_large_amount_of_pressure_applied__c, Was_an_X_ray_performed__c,
                             Was_another_IAB_inserted__c, Was_Blue_Bullseye_Obtained__c, Was_catheter_successfully_removed__c,
                             Was_device_removed_entirely__c, was_device_resterilized_prior_event__c, 	Lot_Number__c,Was_green_batt_light_on_during_insertion__c,
                             Was_IO_acc_achieved_Needle_Cath_c__c, Was_IO_access_successful_Driver__c, Was_it_successful__c,
                             Was_operator_aware_proper_removal_tecnii__c, Was_other_vascular_access_attempted__c, Was_procedure_repeated__c,
                             Was_Second_Attempt_Made__c, Was_the_catheter_placed_without_VPS__c, Was_the_device_removed__c,
                             Was_the_device_replaced__c, Was_the_product_repaired_or_refurbished__c, Was_therapy_delayed_interrupted__c,
                             Was_treatment_delayed__c, Was_X_ray_other_imagery_done__c, Weight__c, WeightUoM__c, Were_pump_strips_generated__c,
                             Were_there_any_cardiac_abnormalities__c, What_kind_of_complications_or_injury__c, What_time_was_IO_Achieved__c,
                             What_type_of_Sheath__c, What_was_the_Insertion_type__c, What_was_the_outcome_of_placement__c,
                             When_the_problem_was_encountered__c, When_was_the_difficulty_encountered__c, When_was_the_last_X_ray_performed__c,
                             Where_is_driver_stored__c, Where_was_the_difficulty_encountered__c, Who_inserted_the_device__c,
                             Who_removed_the_device__c, Age__c, Account__r.Type, AccountType__c, Name_of_Device_User__c, Device_User_Email__c,
                             Device_User_Phone__c, Device_User_Title__c, Owner.Name, Owner.Email, Owner.Title
                             FROM Complaint__c
                             WHERE Id =: complaintId];

        System.debug('*** sfdcComplaint *** ' + sfdcComplaint);
        //System.debug('*** sfdcComplaint *** ' + sfdcComplaint);
        //System.debug('*** sfdcComplaint.Event_Date__c *** ' + sfdcComplaint.Event_Date__c);
        //System.debug('*** sfdcComplaint.Teleflex_Aware_Date__c *** ' + sfdcComplaint.Teleflex_Aware_Date__c);
        String mncodString = NULL;
        String genderString = NULL;
        String useProced = NULL;
        String currCond = NULL;
        String wasPerf = NULL;
        String beingUsed = NULL;
        String duringUse = 'N/A';
        String useEstimate = NULL;
        DateTime myDateTime = NULL;
        DateTime completedDate = NULL;
        Date awareDate = NULL;
        String shipTo = NULL;
        String soldTo = NULL;
        String accCheck = NULL;
        String medProcedure = NULL;
        String lotNumber = NULL;

        //limit characters of new fields to SAP
        String contactName = NULL;
        String contactTitle = NULL;
        String contactTel = NULL;
        String contactEmail = NULL;

        String deviceName = NULL;
        String deviceTitle = NULL;
        String deviceTel = NULL;
        String deviceEmail = NULL;

        String ownerName = NULL;
        String ownerTitle = NULL;
        String ownerTel = NULL;
        String ownerEmail = NULL;

        myDateTime = sfdcComplaint.Event_Date__c;
        System.debug('*** myDateTime *** ' + myDateTime);
          if( sfdcComplaint.Teleflex_Aware_Date__c != NULL ){
            awareDate = sfdcComplaint.Teleflex_Aware_Date__c;
          }

          //start of data translation
          if(myDateTime == NULL){
            myDateTime = sfdcComplaint.Estimated_Event_Date__c;
            useEstimate = 'Y';
          }
          else{
            useEstimate = 'N';
          }


          if(sfdcComplaint.Has_Customer_Requested_Replacement_Produ__c == 'Yes'){
              mncodString = '0080';
          }

          if(sfdcComplaint.Has_Customer_Requested_Replacement_Produ__c == 'No'){
              mncodString = NULL;
          }

          if(sfdcComplaint.Patients_Current_Condition__c == 'Deceased'){
              currCond = 'D';
          }

          if(sfdcComplaint.Patients_Current_Condition__c == 'Critical'){
              currCond = 'C';
          }

          if(sfdcComplaint.Patients_Current_Condition__c == 'Fine'){
              currCond = 'F';
          }

          if(sfdcComplaint.Patients_Current_Condition__c == 'Unknown'){
              currCond = 'U';
          }

          if(sfdcComplaint.Patients_Current_Condition__c == 'N/A'){
              currCond = 'N';
          }

          if(sfdcComplaint.A_medical_intervention_was_performed__c =='Yes'){
             wasPerf = 'Y';
          }
            if(sfdcComplaint.A_medical_intervention_was_performed__c =='Unknown'){
             wasPerf = 'U';
          }


         if(sfdcComplaint.A_medical_intervention_was_performed__c == 'No'){
              wasPerf = 'U';
          }
          if(sfdcComplaint.Gender__c == 'Male'){
              genderString = 'M';
          }

          if(sfdcComplaint.Gender__c == 'Female'){
              genderString = 'F';
          }

          if(sfdcComplaint.How_the_product_was_being_used__c == 'During use on a patient'){
              beingUsed = 'T';
              useProced = 'Y';
              duringUse = sfdcComplaint.During_use_on_a_patient__c;
          }

          if(sfdcComplaint.How_the_product_was_being_used__c == 'During incoming inspection/inventory review, product training/demonstration'){
              beingUsed = 'N';
              useProced = 'A';
          }

          if(sfdcComplaint.How_the_product_was_being_used__c == 'During post cleaning/reprocessing inspection' ||
              sfdcComplaint.How_the_product_was_being_used__c == 'Prior to use on patient (pre-testing)'){
              beingUsed = 'N';
              useProced = 'A';
          }

          if(sfdcComplaint.How_the_product_was_being_used__c == 'Unknown at this time'){
              beingUsed = 'U';
              useProced = 'A';
          }

          System.debug('*** sfdcComplaint.AccountType__c *** ' + sfdcComplaint.AccountType__c);
          accCheck = sfdcComplaint.AccountType__c;
          System.debug('*** accCheck *** ' + accCheck);
          if(accCheck != NULL && !accCheck.containsIgnoreCase('Indirect')){
            if(accCheck.containsIgnoreCase('Ship') ){
              shipTo = sfdcComplaint.Account_Number__c;
              System.debug('*** shipTo *** ' + shipTo);
            }
            else{
              soldTo = sfdcComplaint.Account_Number__c;
              System.debug('*** soldTo *** ' + soldTo);
            }
          }//end of outter if

          //get completed date from approval process
          completedDate = new ComplaintIntegrationExtension().setSubmittedComplaintDate(sfdcComplaint);
          System.debug('*** completedDate *** ' + completedDate);

          //start of QM creation
          sapComplaint = new QM_NotificationSet__x(
            Qmtxt__c = 'Created by Salesforce',//String max 40
            ZzsfdcNum__c = sfdcComplaint.Name,
            Zzevtdt__c = myDateTime,//DateTime precision 7, SFDC Date
            ZzdtCompleted__c = completedDate,
            ZzdtEstimated__c = useEstimate,
            Zzuser__c = uName
          );

          if( String.valueOf(sfdcComplaint.ProductName__c) != NULL ){
            sapComplaint.Matnr__c = String.valueOf(sfdcComplaint.ProductName__c);
          }

          if( sfdcComplaint.Units_with_Alleged_Issue__c != NULL ){
            sapComplaint.Rkmng__c = sfdcComplaint.Units_with_Alleged_Issue__c;
          }

          if( sfdcComplaint.Issue_Incident_Description__c != NULL ){
            sapComplaint.Text__c = sfdcComplaint.Issue_Incident_Description__c;
          }

          if( awareDate != NULL ){
            sapComplaint.Zzawrdt__c = awareDate;
          }

          if( sfdcComplaint.Lot_Number__c != NULL ){
            lotNumber = sfdcComplaint.Lot_Number__c;
            sapComplaint.Charg__c = lotNumber.left(10);
          }

          if(sfdcComplaint.Serial_Number__c != NULL){
            sapComplaint.Serialnr__c = sfdcComplaint.Serial_Number__c;
          }

          if(sfdcComplaint.UDI_GTIN__c != NULL){
            sapComplaint.ZzdevOthr__c = sfdcComplaint.UDI_GTIN__c;
          }

          if( sfdcComplaint.Return_Quantity_for_Investigation__c != NULL ){
            sapComplaint.Rgmng__c = sfdcComplaint.Return_Quantity_for_Investigation__c;
          }

          if(mncodString != NULL){
            sapComplaint.Mncod__c = mncodString;
          }

          if( currCond != NULL){
            sapComplaint.ZzcurrCondInd__c = currCond;
          }

          if(sfdcComplaint.PatientsCurrentConditionDescription__c != NULL){
            sapComplaint.ZzcurrCond__c = sfdcComplaint.PatientsCurrentConditionDescription__c;
          }

          if( beingUsed != NULL){
            sapComplaint.Zzusage__c = beingUsed;
          }

          if( useProced != NULL){
            sapComplaint.ZzuseProced__c = useProced;
          }

          if( wasPerf != NULL){
            sapComplaint.Zzintervent__c = wasPerf;
          }

          if(sfdcComplaint.Medical_Procedure__c != NULL){
            medProcedure = sfdcComplaint.Medical_Procedure__c;
            sapComplaint.ZzintrvntT__c = medProcedure.left(40);
          }

          if( duringUse != NULL){
            sapComplaint.Zzprocedure__c = duringUse;
          }

          if(genderString != NULL){
            sapComplaint.ZzpGender__c = genderString;
          }

          if(sfdcComplaint.Age__c != NULL){
            sapComplaint.ZzpAge__c = String.valueOf(sfdcComplaint.Age__c);
            sapComplaint.ZzpAgeUom__c = sfdcComplaint.AgeUoM__c;
          }

          if(sfdcComplaint.Weight__c != NULL){
            sapComplaint.ZzpWt__c = String.valueOf(sfdcComplaint.Weight__c);
            sapComplaint.ZzpWtUom__c = sfdcComplaint.WeightUoM__c;
          }

          if(accCheck != NULL && !accCheck.containsIgnoreCase('Indirect')){
            if(shipTo != NULL){
              sapComplaint.ShipTo__c = sfdcComplaint.Account_Number__c;
            }
            else{
              sapComplaint.SoldTo__c = sfdcComplaint.Account_Number__c;
            }
          }//end of outter if

          /**************** Integration changes below for CEX *********************/
          if(sfdcComplaint.Contact_Name__c != NULL){
            contactName = sfdcComplaint.Contact_Name__c;
            sapComplaint.ZzbpContact__c = contactName.left(35);
          }

          if(sfdcComplaint.Contact_Email__c != NULL){
            contactEmail = sfdcComplaint.Contact_Email__c;
            sapComplaint.ZzbpContactEmail__c = contactEmail.left(100);
          }

          if(sfdcComplaint.Contact_Phone__c != NULL){
            contactTel = sfdcComplaint.Contact_Phone__c;
            sapComplaint.ZzbpContactTel__c = contactTel.left(30);
            //sapComplaint.ZzbpContactTel__c = String.valueOf(sfdcComplaint.Contact_Phone__c);
          }

          if(sfdcComplaint.Contact_Title__c != NULL){
            contactTitle = sfdcComplaint.Contact_Title__c;
            sapComplaint.ZzbpContactTitle__c = contactTitle.left(40);
          }

          if(sfdcComplaint.Name_of_Device_User__c != NULL){
            deviceName = sfdcComplaint.Name_of_Device_User__c;
            sapComplaint.ZzdeviceUser__c = deviceName.left(35);
          }

          if(sfdcComplaint.Device_User_Email__c != NULL){
              deviceEmail = sfdcComplaint.Device_User_Email__c;
            sapComplaint.ZzdeviceUserEmail__c = deviceEmail.left(100);
          }

          if(sfdcComplaint.Device_User_Phone__c != NULL){
            deviceTel = sfdcComplaint.Device_User_Phone__c;
              sapComplaint.ZzdeviceUserTel__c = deviceTel.left(30);
            //sapComplaint.ZzdeviceUserTel__c = String.valueOf(sfdcComplaint.Device_User_Phone__c);
          }

          if(sfdcComplaint.Device_User_Title__c != NULL){
            deviceTitle = sfdcComplaint.Device_User_Title__c;
            sapComplaint.ZzdeviceUserTitle__c = deviceTitle.left(40);
          }

          if(sfdcComplaint.Owner.Name != NULL){
            ownerName = sfdcComplaint.Owner.Name;
            sapComplaint.Zzowner__c = ownerName.left(35);
          }

          if(sfdcComplaint.Owner.Email != NULL){
            ownerEmail = sfdcComplaint.Owner.Email;
            sapComplaint.ZzownerEmail__c = ownerEmail.left(100);
          }

          if(sfdcComplaint.Owner.Title != NULL){
            ownerTitle = sfdcComplaint.Owner.Title;
            sapComplaint.ZzownerTitle__c = ownerTitle.left(40);
          }
          /**************** Integration changes above for CEX *********************/

          //sapComplaint.Mncod__c = '0060';
          //end of QM creation
          //insertSapComps.add(sapComplaint);
          System.debug('*** sapComplaint *** ' + sapComplaint);

          try{
              System.debug('*** IN try block for ComplaintIntegrationExtension Class sfdcComplaint *** ' + sfdcComplaint);
              //if(sfdcComplaint.RecordType.Name != 'Interventional – Legacy VSI & Manta & OnControl Products' && sfdcComplaint.RecordType.Name != 'Manta'){
                System.debug('*** Passed If Check for Recordtype ***');  
                System.debug('*** sfdcComplaint.Id *** ' + sfdcComplaint.Id);
                ComplaintIntegrationCallback cb = new ComplaintIntegrationCallback(sfdcComplaint.Id);
                Database.insertAsync(sapComplaint, cb);
              //}//end if
          }catch(Exception e){
              System.debug('*** IN catch block for ComplaintIntegrationExtension Class ***');
              System.debug('*** sfdcComplaint *** ' + sfdcComplaint);
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record was not created in SAP...' + e.getMessage()));
          }
        }//end of if compMessage check
        else{
            //do asynchronous insert here
            System.debug('*** QM_SFDC_Query__x Record Found!!!! ***');
            try{
                tcMatch = sf.Qmnum__c;
                Complaint__c c = [SELECT Id, Name, TC__c
                                  FROM Complaint__c
                                  WHERE Name =: sfdcNum];
                
                c.TC__c = sf.Qmnum__c;
                update c;
                //Prepare and send email confirmation
                String subject = 'Complaint ' + c.Name + ' already existed in SAP.';
                String textBody = 'Complaint ' + c.Name + ' was found in SAP.  The record has been updated with the correct TC#('+ c.TC__c +')\n' +
                    'and a link has been provided below to view the record.\n' +
                    'SAP Complaint: ' + sapComplaint +'\n'+
                    'SFDC Complaint: ' + sfdcComplaint;
                ComplaintIntegrationExtension.sendSapConfirmationEmail(subject,textBody,c);                
            }catch(Exception e){
                System.debug('Exception occured in ComplaintIntegrationExtension sfdcTcMatch method: ' + e.getMessage());
            }
            
            
        }

        //return tcMatch;
    }//end of existing TC# check

    public static void sendSapConfirmationEmail(String subject, String textBody, Complaint__c c){
      List<String> emailList = new List<String>();
      emailList.add('duntee.silver@teleflex.com');
      emailList.add('siva.machineni@teleflex.com');
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

    /****************************** Everything Below is Lightning Development ************************************/
    @AuraEnabled
    public static Complaint__c getComplaint(Id complaintId) {
        Complaint__c complaint =
                [SELECT Id, Status__c, TC__c, Name FROM Complaint__c WHERE Id = :complaintId];

        return complaint;
    }

    @AuraEnabled
    public static List<QM_NotificationSet__x> getQmList(Id complaintId) {
        Complaint__c complaint =
                [SELECT Id, Status__c, TC__c, Name FROM Complaint__c WHERE Id = :complaintId];

        List<QM_NotificationSet__x> qmList = [SELECT Zzuser__c, Qmtxt__c, Matnr__c, Zzqmnum__c
                                              FROM QM_NotificationSet__x WHERE Zzqmnum__c = :complaint.TC__c];

        return qmList;
    }

    @AuraEnabled //this is used for the Lightning Component Button
    public static Map<String,String> createSapComplaintLightning(Id complaintIds, String sfNum){
        System.debug('*** IN createSapComplaintLightning method in ComplaintIntegrationExtension Class ***');
        System.debug('*** complaintIds *** ' + complaintIds);
        System.debug('*** sfNum *** ' + sfNum);
        Map<String,String> resultMap = new Map<String,String>();
        System.debug('*** Creating Complaint IN SAP ***');
        resultMap.put('status','success');
        resultMap.put('message','Sending to SAP!');
        ComplaintIntegrationExtension.sfdcTcMatch(sfNum, complaintIds);
        return resultMap;
    }//end of createSapComplaint

    /* -------- Below are the SAP fields and information about field attributes -----------
    //Matnr__c = String.valueOf(sfdcComplaint.ProductName__c),//String max 18, SFDC Formula
    //Rkmng__c = sfdcComplaint.Units_with_Alleged_Issue__c,//Decimal max (13,3), SFDC Number(18, 0)
    //Rkmng__c = 1.000,
    //Text__c = sfdcComplaint.Issue_Incident_Description__c,//String no max, SFDC Long Text Area(32768)
    //Zzawrdt__c = NULL,
    //Zzawrdt__c = sfdcComplaint.Teleflex_Aware_Date__c,//DateTime precision 7, SFDC Date
    //Charg__c = sfdcComplaint.Lot_Number__c,//String max 10, SFDC 64
    //Serialnr__c = sfdcComplaint.Serial_Number__c,//String max 18, SFDC SFDC 64
    //Serialnr__c = '*AM19599024',
    //ZzdevOthr__c = sfdcComplaint.UDI_GTIN__c,//String max 19, SFDC 20
    //ZzdevOthr__c = 'Y',
    //Rgmng__c = sfdcComplaint.Return_Quantity_for_Investigation__c,//Decimal max (13,3), SFDC Number(18, 0)
    //Rgmng__c = 1.000,
    //Mncod__c = mncodString,//String max 4, SFDC picklist
    //ZzcurrCondInd__c = currCond,//revist {F (Fine),C (Critical),U,(Unknown),O (Other)} String max 1, SFDC Picklist
    //ZzcurrCond__c = sfdcComplaint.PatientsCurrentConditionDescription__c,//revist String max 40, SFDC
    //Zzusage__c = beingUsed,//{T (Treatment),D (Diagnosis),U (Unknown),N (Not Applicable) }
    //Zzusage__c = 'U',
    //ZzuseProced__c = useProced,//{Y (Yes),N (No),A (Not Applicable),U (Unknown) }
    //ZzuseProced__c = 'Y',
    //Zzintervent__c = wasPerf,//SAP max 1 {Y (Yes),N (No),A (Not Applicable),U (Unknown) }
    //ZzintrvntT__c = sfdcComplaint.Medical_Procedure__c,//limit to 40 SFDC is 128
    //ZzintrvntT__c = sfdcComplaint.A_medical_intervention_was_performed__c,
    //Zzprocedure__c = duringUse,
    //Zzprocedure__c = curr.During_use_on_a_patient__c,//SAP max 40, SFDC 128
    //Zzprocedure__c = 'Y',
    //ZzpGender__c = genderString,//{M (Male), F (Female)} String max 1, SFDC Picklist (Male, Female)
    //ZzpAge__c = String.valueOf(sfdcComplaint.Age__c),//SAP String Max 3, SFDC Number max 3
    //ZzpAgeUom__c = sfdcComplaint.AgeUoM__c,//{Y (Years),M (Months),D (Days) } NOT in SFDC
    //ZzpWt__c = String.valueOf(sfdcComplaint.Weight__c),//SAP String max 3, SFDC String 50
    //ZzpWtUom__c = sfdcComplaint.WeightUoM__c,//NOT in SFDC {LBS (Pounds),KGS (Kilograms)}
    //Zzuser__c = 'jjoseph1',
    //Author__c = 'JJOSEPH1',
    //SoldTo__c = sfdcComplaint.Account_Number__c,
    //ShipTo__c = sfdcComplaint.Account_Number__c
    //ShipTo__c = '0001025989',
    //SoldTo__c = '0001025989'
    //ZzocLife__c = sfdcComplaints.Patient_complications_or_injury__c,//{ X (Yes),''(blank for (No) } String max 1, SFDC Picklist(Yes,No,Unknown)
    //ZzocHospital__c = curr.Patient_complications_or_injury__c,//{ X (Yes), ''(blank for (No) } String max 1, SFDC Picklist(Yes,No,Unknown)
    //ZzocInterven__c = curr.Patient_complications_or_injury__c,//{ X (Yes), ''(blank for (No) } String max 1, SFDC Picklist(Yes,No,Unknown)
    //ZzocDisable__c = curr.Patient_complications_or_injury__c,//{ X (Yes), ''(blank for (No) } String max 1, SFDC Picklist(Yes,No,Unknown)
    //ZzocBirthDef__c = curr.Patient_complications_or_injury__c,//{ X (Yes), ''(blank for (No) } String max 1, SFDC Picklist(Yes,No,Unknown)
    //ZzocOther__c = curr.Patient_complications_or_injury__c,//{ X (Yes), ''(blank for (No) } String max 1, SFDC Picklist(Yes,No,Unknown)
    */
}//end of class