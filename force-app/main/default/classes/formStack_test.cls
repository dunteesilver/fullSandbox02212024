@istest
public class formStack_test {
    @istest static void validate_Formstack(){
        Quick_Disable__c cs = new Quick_Disable__c(
            Name = 'territory_user_maintenance',
            Enable__c = FALSE
        );
        System.debug('insert cs-->' + cs);
        insert cs;
        
        BaseQuotaException__c bqe = new BaseQuotaException__c(
            Name = 'territory_user_maintenance',
            IsException__c = TRUE
        );
        insert bqe;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='TeleflexTESTER@teleflex.test.com',
            Business_Unit__c = 'EMS'
        );
        insert u;
        System.debug('Insert User-->' + u);
        
        Account a = new Account(
            Name = 'Test PP Account', 
            SAP_Sold_To__c ='100123', 
            ShippingStreet='123 Main Street ', 
            ShippingCity='Raleigh',
            ShippingState='NC', 
            ShippingPostalCode='27614',
            Customer_Group__c = '19',
            Account_Group__c = 'Z001'
        );
        insert a;
        
        Territory_Master__c tm = new Territory_Master__c(
            Name = '700123',
            Territory_Number__c = '700123',
            Business_Unit__c = 'EMS'
        );
        insert tm;
        System.debug('Insert Territory Master-->' + tm);
        
        Territory_User__c tu = new Territory_User__c(
            User__c = u.Id,
            Business_Unit__c = 'EMS',
            Role__c = 'Sales Rep',
            Territory_Master__c = tm.Id,
            Territory_Number__c = '700123'
        );
        insert tu;
        
        Territory_Alignment__c tarstate = new Territory_Alignment__c(
            Key__c  = 'NC-700123',
            Region__c = 'NC',
            Territory__c = '700123',
            Territory_Name__c = '700123',
            Territory2__c = '700123',
            Territory_2_Name__c = '700123',
            Territory3__c = '',
            Territory_3_Name__c = '',
            Territory4__c = '',
            Territory_4_Name__c = '',
            Business_Unit__c = 'EMS',
            ZPSA_Table__c = 'A659'
        );
        insert tarstate;
        
        Territory_Alignment__c tarsap = new Territory_Alignment__c(
            Key__c	= '999999-700123',
            SAP_Code__c	= '999999',
            Account_Name__c	= 'Test',
            Territory__c = '700123',
            Territory_Name__c = '700123',
            Territory2__c = '700123',
            Territory_2_Name__c = '700123',
            Territory3__c = '',
            Territory_3_Name__c = '',
            Territory4__c = '',
            Territory_4_Name__c = '',
            Business_Unit__c = 'EMS',
            ZPSA_Table__c = 'A681'
        );
        insert tarsap;
        
        Territory_Alignment__c tarzip = new Territory_Alignment__c(
            Key__c	= '27614-700123',
            Zip10__c = '27614',
            Territory__c = '700123',
            Territory_Name__c = '700123',
            Territory2__c = '700123',
            Territory_2_Name__c = '700123',
            Territory3__c = '',
            Territory_3_Name__c = '',
            Territory4__c = '',
            Territory_4_Name__c = '',
            Business_Unit__c = 'EMS',
            ZPSA_Table__c = 'A626'
        );
        insert tarzip;
        
        Territory_Alignment__c tarzip2 = new Territory_Alignment__c(
            Key__c	= '98989-700123',
            Zip10__c = '98989',
            Territory__c = '700123',
            Territory_Name__c = '700123',
            Territory2__c = '700123',
            Territory_2_Name__c = '700123',
            Territory3__c = '',
            Territory_3_Name__c = '',
            Territory4__c = '',
            Territory_4_Name__c = '',
            Business_Unit__c = 'EMS',
            ZPSA_Table__c = 'A626'
        );
        insert tarzip2;
        
        Territory_Alignment__c tarbc = new Territory_Alignment__c(
            Key__c = '276-02-700123',
            Zip3__c = '276',
            Customer_Group__c = '02',
            Customer_Group_Name__c = 'Dist/Dlr Emg Med Svc',
            Territory__c = '700123',
            Territory_Name__c = '700123',
            Territory2__c = '700123',
            Territory_2_Name__c = '700123',
            Territory3__c = '',
            Territory_3_Name__c = '',
            Territory4__c = '',
            Territory_4_Name__c = '',
            Business_Unit__c = 'EMS',
            ZPSA_Table__c = 'A672'
        );
        insert tarbc;
        
        Territory_Assignment__c terrAssignment = new Territory_Assignment__c (
            Name = 'NC-700123',
            Account__c = a.id,
            Territory_Alignment__c = tarstate.id,
            Territory__c = tm.Id,
            Territory_Number__c = '700123'
        );
        insert terrAssignment;
        
        Business_Unit__c bu = new Business_Unit__c(
            Name = 'Surgical',
            Active__c = TRUE,
            Page__c = 'account',
            Key__c = 'SURG'
        );
        insert bu;
        
        Business_Unit__c bu2 = new Business_Unit__c(
            Name = 'Anesthesia',
            Active__c = TRUE,
            Page__c = 'account',
            Key__c = 'ANES'
        );
        insert bu2;
        
        Zip_Code_Territories__c  zct = new Zip_Code_Territories__c(
            Name = '27614',
            Zip_Code__c = '27614',
            EMS__c = '700123'
        );
        insert zct;
        System.debug('Insert Zip Code Territory: ' + zct); 
        
        Lab_Evaluations__c le = new Lab_Evaluations__c(
            Name = 'UNC Lab Eval',
            email__c = '123321@1232222.com',
            Follow_up_Email__c = '123321@1232222.com',
            Course_Name__c = 'UNC Lab'
        );
        insert le;
        
        Campaign cc = New Campaign(
            Name = 'UNC Lab',
            Status = 'In Progress',
            IsActive = TRUE,
            Type = 'Lab'
        );
        insert cc;
        
        // Create the Lead
        Lead l = new lead(
            lastname = 'test799791',
            company = 'test992921',
            Status = 'Open',
            email = '123321@1232222.com',
            PostalCode = '27614',
            Business_Unit__c = 'EMS',
            Lab_Unique_ID__c = '123123',
            Zip_Code_Auto_Route__c = FALSE
        );
        insert l;
        system.debug('Lead' + l);
        
        Lab__c lab = new Lab__c(
            Name = 'UNC Lab',
            Lab_Key__c = 'UNC Lab'
        );
        master_TriggerHelperClass.runOnce('resetOnceSet');
        insert lab;
        system.debug('lab: ' + lab);
        
        Lab_Participant__c lp = new Lab_Participant__c(
            Name = 'test',
            Lead__c = l.id,
            Lab__c = lab.Id,
            Lab_Time__c = '7pm',
            Lab_Time_2__c = '7:35pm',
            Email__c = '123321@1232222.com',
            Mailing_Zip_Code__c = '27614',
            Address__c = '123 Mainstreet Raleigh, NC 98989 US',
            Affiliation__c = 'EMS',
            Lab_Unique_ID__c = '123123',
            Status__c='Attended'
        );
        master_TriggerHelperClass.runOnce('resetOnceSet');
        insert lp;

        master_TriggerHelperClass.runOnce('resetOnceSet');
        lp.Address__c = '123 Mainstreet Raleigh, NC 27614 US';
        update lp;
        system.debug('lp: ' + lp);
        
        lab.Default_Approver__c = u.id;
        update lab;
        
        Lab_Participant__c lp2 = new Lab_Participant__c(
            Name = 'test',
            Lead__c = l.id,
            Lab__c = lab.Id,
            Lab_Time__c = '7pm',
            Lab_Time_2__c = '7:30pm',
            Email__c = '123321@1232222.com',
            Address__c = '1234 Mainstreet Raleigh, NC 98989 US',
            Affiliation__c = 'EMS',
            Lab_Unique_ID__c = '123123',
            Status__c='Attended Interventional'
        );
        master_TriggerHelperClass.runOnce('resetOnceSet');
        insert lp2;
        
        Lab_Evaluations__c le2 = new Lab_Evaluations__c (
            name = 'test',
            Email__c = '123321@1232222.com'
        );
        master_TriggerHelperClass.runOnce('resetOnceSet');
        insert le2;
        
        PageReference pageRef = new PageReference('/apex/lab_checkin?id=' + lab.Id + '&lpid=' + lp.Id + '&cstatus=FALSE');
        system.debug('User Edit Page' + pageRef);
        Test.setCurrentPage(pageRef);
        /*
        string lpid = ApexPages.currentPage().getParameters().get('lpid');
        string lid = ApexPages.currentPage().getParameters().get('id');
        string cstatus = ApexPages.currentPage().getParameters().get('cstatus');
        boolean attended;
*/
        PageReference pageRef1 = new PageReference('/apex/lab_CreateParticipant?id=' + lab.Id);
        Test.setCurrentPage(pageRef1);
        
        lab_CheckIn labCheck = new lab_CheckIn();
        labCheck.cancel();
        labCheck.checkin();
        labCheck.getLabDetails();
        labCheck.getlplist();
        labCheck.getShortCuts();
        labCheck.getTimeList();
        labCheck.getTimeList2();
        labcheck.getTimeList3();
        labcheck.getTimeList4();
        labCheck.save();
        boolean timeslot2 = labCheck.timeslot2;
        boolean timeslot3 = labCheck.timeslot3;
        boolean timeslot4 = labCheck.timeslot4;
        
		PageReference pageRef2 = new PageReference('/apex/lab_CreateParticipant?id=' + lab.Id + '&lpid='+ lp2.ID +'&cstatus=TRUE&cfield=Attended__c');
        Test.setCurrentPage(pageRef2);
		lab_CheckIn labCheck2 = new lab_CheckIn();
        labCheck2.checkin();

		PageReference pageRef3 = new PageReference('/apex/lab_CreateParticipant?id=' + lab.Id + '&lpid='+ lp2.ID +'&cstatus=TRUE&cfield=Attended_Hemorrhage__c');
        Test.setCurrentPage(pageRef3);
		lab_CheckIn labCheck3 = new lab_CheckIn();
        labCheck3.checkin();

		PageReference pageRef4 = new PageReference('/apex/lab_CreateParticipant?id=' + lab.Id + '&lpid='+ lp2.ID +'&cstatus=TRUE&cfield=Atteneded_Interventional__c');
        Test.setCurrentPage(pageRef4);
		lab_CheckIn labCheck4 = new lab_CheckIn();
        labCheck4.checkin();
        
        PageReference pageRef5 = new PageReference('/apex/lab_CreateParticipant?id=' + lab.Id + '&lpid='+ lp2.ID +'&cstatus=TRUE&cfield=Attended_EZIO__c');
        Test.setCurrentPage(pageRef5);
		lab_CheckIn labCheck5 = new lab_CheckIn();
        labCheck5.checkin();
        
        PageReference pageRef6 = new PageReference('/apex/lab_CreateParticipant?id=' + lab.Id + '&lpid='+ lp2.ID +'&cstatus=FALSE&cfield=Attended__c');
        Test.setCurrentPage(pageRef6);
		lab_CheckIn labCheck6 = new lab_CheckIn();
        labCheck6.checkin();

		PageReference pageRef7 = new PageReference('/apex/lab_CreateParticipant?id=' + lab.Id + '&lpid='+ lp2.ID +'&cstatus=FALSE&cfield=Attended_Hemorrhage__c');
        Test.setCurrentPage(pageRef7);
		lab_CheckIn labCheck7 = new lab_CheckIn();
        labCheck7.checkin();

		PageReference pageRef8 = new PageReference('/apex/lab_CreateParticipant?id=' + lab.Id + '&lpid='+ lp2.ID +'&cstatus=FALSE&cfield=Atteneded_Interventional__c');
        Test.setCurrentPage(pageRef8);
		lab_CheckIn labCheck8 = new lab_CheckIn();
        labCheck8.checkin();
        
        PageReference pageRef9 = new PageReference('/apex/lab_CreateParticipant?id=' + lab.Id + '&lpid='+ lp2.ID +'&cstatus=FALSE&cfield=Attended_EZIO__c');
        Test.setCurrentPage(pageRef9);
		lab_CheckIn labCheck9 = new lab_CheckIn();
        labCheck9.checkin();

        
    }

}