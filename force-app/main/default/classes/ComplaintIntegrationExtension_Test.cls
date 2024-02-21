@isTest
public class ComplaintIntegrationExtension_Test {
	
    static testMethod void testDataSetup(){
        
        
        
    }//end of autoSubmitComplaintTest

    @isTest static void ComplaintIntegrationExtensionTest() {
        Profile p = [select id from profile where name='System Administrator'];
        String userRoleLatin = [SELECT Id, Name FROM UserRole WHERE Name LIKE '%Latin%' LIMIT 1].Id;
        String userRole = [SELECT Id, Name FROM UserRole WHERE Name LIKE '%Teleflex Global%' LIMIT 1].Id;
        RecordType recTypeObj= [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Vascular' LIMIT 1];
        User compUser = [SELECT Id, Name, CommunityNickname FROM User WHERE UserRole.Name LIKE '%Customer Advocacy%' LIMIT 1];
        
        User u = new User(
            alias = 'uflex76',
            email='unit.test@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Adam',
            lastname='Franks',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p.Id,
            timezonesidkey='Europe/London',
            username='unit.test@unit.teleflex.com',
            Business_Unit__c = 'Vascular',
            UserRoleId = userRole,
            CommunityNickname  = 'DSILVER',
            Title = 'Developer'
        );
        insert u;
        
        User u2 = new User(
            alias = 'latam76',
            email='latam.test@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Latam',
            lastname='Franks',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p.Id,
            timezonesidkey='Europe/London',
            username='latam.test@unit.teleflex.com',
            Business_Unit__c = 'Latin America',
            UserRoleId = userRoleLatin,
            CommunityNickname  = 'LAFRANK',
            Title = 'Doctor'
        );
        insert u2;
        
        System.runAs(u){
            list<Account> acc = new list<Account>();
            for(integer i=0;i<5;i++){
                Account a = new Account(Name='Test'+i, Sales_by_BU_Key__c='Has Sales', ERP_Active__c = TRUE,
                                       Type = 'Ship-To (Z002)');
                acc.add(a);
            }
            //insert acc;
            //System.assertEquals(10,acc.size());
            
            for(integer i=5;i<10;i++){
                Account a = new Account(Name='Test'+i, Sales_by_BU_Key__c='Has Sales', ERP_Active__c = TRUE,
                                       Type = 'Indirect (ZREB)');
                acc.add(a);
            }
            insert acc;
            System.assertEquals(10,acc.size());
            
            Product2 prod = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='30',
                Family = 'Hardware',
                Material__c='AA-10511-1',
                Brand_Name__c='Arrow',
                Buom__c='EA',
                Class__c='Cardiac Care Specialty',
                Cost__c=11587.40,
                Cost_Price_Unit__c=1000,
                Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Qty_Sales_Unit__c=5,
                Sales_Unit__c='CS',
                List_Price__c=380.00,
                Rep_Price__c=350.00,
                RSM_Price__c=330.00,
                Material_Key__c = 'AA-10511-1-US60-10',
                Sales_Org_Key__c = 'US6010',
                Sales_Org__c = 'US60',
                Distribution_Channel__c = '10'
            );
            insert prod;
            
            Product_List__c  compProd = new Product_List__c(
                Name = 'AA-10511-1',
                Product_Code__c= 'AA-10511-1',
                UOM__c='CS',
                Eaches_per_Case__c = 5,
                Class__c='Cardiac Care Specialty',
                Description__c='TRANSRADIAL ACCESS TRAY'
            );
            insert compProd;
            
            list<Complaint__c> comps = new list<Complaint__c>();
            for(integer j = 0;j<10;j++){
                Complaint__c c = new Complaint__c();
                c.RecordTypeId = recTypeObj.Id;
                c.Event_Date__c=Date.today();
                c.Units_with_Alleged_Issue__c=100;
                c.Issue_Incident_Description__c='test'+j;
                c.Lot_Number_Action_Taken__c='Called';
                c.Patients_Current_Condition__c='Unknown';
                c.Status__c='Open';
                c.Contact_Title__c='test'+j;
                c.Contact_Email__c='test'+j+'@gmail.com';
                c.Contact_Name__c='User Test'+j;
                c.Account__c = acc[j].Id;
                c.Customer_response_letter_requested__c = 'Yes';
                c.How_the_product_was_being_used__c = 'During use on a patient';
                c.During_use_on_a_patient__c = 'No Patient injury or consequence';
                c.Did_device_cause_contribute_to_death_inj__c='No';
                c.Patient_exposed_to_infectious_disease__c='No';
                c.Was_therapy_delayed_interrupted__c='No';
                c.Type_of_Sample_For_Investigation__c='Actual';
                c.Please_provide_rationale_for_the_late_s__c='TEST';
                c.Gender__c = 'Male';
                c.Lot_Number__c = 'Unknown';
                c.A_medical_intervention_was_performed__c='No';
                c.UDI_GTIN__c = 'Unknown';
                c.Return_Quantity_for_Investigation__c = 0;
                c.Serial_Number__c = 'Unknown';
                c.Has_Customer_Requested_Replacement_Produ__c = 'Yes';
                c.Complaint_submitted_within_24_hours_of_T__c ='Yes';
                c.Medical_Procedure__c = 'Test';
                c.Did_device_cause_contribute_to_death_inj__c='No';
                c.Age__c = 30;
                c.Weight__c = '175';
                c.Contact_Phone__c = '9199999999';
                c.Device_User_Email__c = 'test@test.com';
                c.Device_User_Phone__c = '1234569999';
                c.Device_User_Title__c = 'Developer';
                c.Please_provide_rationale_for__c = 'Test';
                comps.add(c);
            }
            insert comps;
            System.assertEquals(10,comps.size());

            list<Complaint__c> comps2 = new list<Complaint__c>();
        for(integer k = 0;k<10;k++){
            Complaint__c c2 = new Complaint__c();
            c2.Event_Date__c=Date.today();
            c2.Teleflex_Aware_Date__c=Date.today();
            c2.Units_with_Alleged_Issue__c=100;
            c2.Issue_Incident_Description__c='test'+k;
            c2.Lot_Number_Action_Taken__c='Called';
            c2.Patients_Current_Condition__c='Unknown';
            c2.Status__c='Submitted';
            c2.Contact_Title__c='test2'+k;
            c2.Contact_Email__c='test2'+k+'@gmail.com';
            c2.Contact_Name__c='User Test2'+k;
            c2.Account__c = acc[k].Id;
            c2.Customer_response_letter_requested__c = 'Yes';
            c2.A_medical_intervention_was_performed__c='No';
            c2.Did_device_cause_contribute_to_death_inj__c='No';
            c2.Has_Customer_Requested_Replacement_Produ__c = 'No';
            c2.Please_provide_rationale_for_the_late_s__c='Test';
            c2.Patient_exposed_to_infectious_disease__c='No';
            c2.Was_therapy_delayed_interrupted__c='No';
            c2.Complaint_submitted_within_24_hours_of_T__c ='Yes';
            c2.Type_of_Sample_For_Investigation__c='Actual';
            c2.Did_device_cause_contribute_to_death_inj__c='No';
            c2.How_the_product_was_being_used__c = 'During incoming inspection/inventory review, product training/demonstration';
            c2.Gender__c = 'Female';
            c2.Please_provide_rationale_for__c = 'Test';
            comps2.add(c2);
            comps.add(c2);
        }
        insert comps2;
        System.assertEquals(10,comps2.size());
        
        list<Complaint__c> comps3 = new list<Complaint__c>();
        for(integer k = 0;k<10;k++){
            Complaint__c c3 = new Complaint__c();
            c3.Event_Date__c=Date.today();
            c3.Units_with_Alleged_Issue__c=100;
            c3.Issue_Incident_Description__c='test'+k;
            c3.Lot_Number_Action_Taken__c='Called';
            c3.Patients_Current_Condition__c='Deceased';
            c3.Status__c='Submitted';
            c3.Contact_Title__c='test2'+k;
            c3.Contact_Email__c='test2'+k+'@gmail.com';
            c3.Contact_Name__c='User Test2'+k;
            c3.Account__c = acc[k].Id;
            c3.A_medical_intervention_was_performed__c='No';
            c3.Customer_response_letter_requested__c = 'Yes';
            c3.Patient_exposed_to_infectious_disease__c='No';
            c3.Did_device_cause_contribute_to_death_inj__c='No';
            c3.Was_therapy_delayed_interrupted__c='No';
            c3.Please_provide_rationale_for_the_late_s__c='Test';
            c3.Name_of_Device_User__c = 'John Doe';
            c3.Type_of_Sample_For_Investigation__c='Actual';
            c3.Complaint_submitted_within_24_hours_of_T__c ='Yes';
            c3.Did_device_cause_contribute_to_death_inj__c='No';
            c3.How_the_product_was_being_used__c = 'Prior to use on patient (pre-testing)';
            c3.Please_provide_rationale_for__c = 'Test';
            comps3.add(c3);
            comps.add(c3);
        }
        insert comps3;
        
        list<Complaint__c> comps4 = new list<Complaint__c>();
        for(integer k = 0;k<10;k++){
            Complaint__c c4 = new Complaint__c();
            c4.Estimated_Event_Date__c = Date.today();
            //c4.Event_Date__c=Date.today();
            c4.Units_with_Alleged_Issue__c=100;
            c4.Issue_Incident_Description__c='test'+k;
            c4.Lot_Number_Action_Taken__c='Called';
            c4.Patients_Current_Condition__c='Critical';
            c4.Status__c='Submitted';
            c4.Contact_Title__c='test2'+k;
            c4.Contact_Email__c='test2'+k+'@gmail.com';
            c4.Contact_Name__c='User Test2'+k;
            c4.Account__c = acc[k].Id;
            c4.A_medical_intervention_was_performed__c='No';
            c4.Customer_response_letter_requested__c = 'Yes';
            c4.Did_device_cause_contribute_to_death_inj__c='No';
            c4.Was_therapy_delayed_interrupted__c='No';
            c4.Patient_exposed_to_infectious_disease__c='No';
            c4.Type_of_Sample_For_Investigation__c='Actual';
            c4.Complaint_submitted_within_24_hours_of_T__c ='Yes';
            c4.Did_device_cause_contribute_to_death_inj__c='No';
            c4.Please_provide_rationale_for_the_late_s__c='Test';
            c4.How_the_product_was_being_used__c = 'Unknown at this time';
            c4.Name_of_Device_User__c='TEST';
            c4.Please_provide_rationale_for__c = 'Test';
            comps4.add(c4);
            comps.add(c4);
        }
        insert comps4;
        	
            //update to status to Submitted
            for(Complaint__c c1 : comps){
                c1.Status__c = 'Submitted';
            }
            update comps;
            System.assertEquals(40,comps.size());
            
            ComplaintIntegrationExtension compClass = new ComplaintIntegrationExtension();
            compClass.setSubmittedComplaintDate(comps[0]);
            
            
            //update status to Approved
            for(Complaint__c c1 : comps){
                c1.Status__c = 'Approved';
            }
            update comps;
            
            String complaintId = compClass.complaintId;
            System.debug('*** comps[0].name *** ' + comps[0].name);
            System.debug('*** comps[0].Id *** ' + comps[0].Id);
            for(integer i = 0;i<40;i++){
                ComplaintIntegrationExtension.createSapComplaintService(comps[i].Id, comps[i].name);
            }
            //ComplaintIntegrationExtension.createSapComplaintService(comps[0].Id, comps[0].name);
            //compClass.sfdcTcMatch(comps[0].name, );
            
            //Testing Aura Methods
            ComplaintIntegrationExtension.getComplaint(comps[0].Id);
            ComplaintIntegrationExtension.getQmList(comps[0].Id);
            ComplaintIntegrationExtension.createSapComplaintLightning(comps[0].Id,comps[0].name);
            ComplaintIntegrationExtension.sendSapConfirmationEmail('THIS IS A TEST!!!','THIS IS A TEST!!!',comps[0]);
        }//end of System.runAs(u)
        
    }//end of ComplaintIntegrationExtensionTest    
}//end of ComplaintIntegrationExtension_Test