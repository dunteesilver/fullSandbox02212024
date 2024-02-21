@IsTest
public class TFX_MANTA_Handler_Test {


    static testmethod void createData() {
        
        Date fromDate = System.today().addYears(-1);
        Date toDate = System.today();

        Profile p = [select id from profile where name='System Administrator'];
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
                Region__c = 'Southeast'
            );
            insert u;
        
        Account_Region__c accRgn = new Account_Region__c();
        accRgn.Name = 'Southeast';
        accRgn.Region_Zone__c = 'South';
        insert accRgn;
        
        Account acc = new Account();
        acc.Name = 'CXTestAcc';
        acc.SAP_Sold_To__c = '123456';
        acc.SAP_Code__c='123456';
        acc.Territory_Key__c='123456;234567';
        insert acc;
        
        Contact con = new Contact(
                FirstName ='Test',
                email = 'abc@123.com',
            	phone = '1111111111',
                LastName = 'TestContact',
                Position_Job_Title__c = 'Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                AccountId = acc.Id,
                Salutation = 'Dr.'
            );
            insert con;
        
        Territory_Master__c tm = new Territory_Master__c(
            Name = '700123',
            Territory_Number__c = '123456',
            Business_Unit__c = 'Interventional',
            Region_Name__c = 'INTV RSM SOUTHWEST',
            Sales_Rep_Email__c = 'unit.test@unit.teleflex.com'
        );
        insert tm;
        
        Territory_Assignment__c taObj = new Territory_Assignment__c(
        Territory__c = tm.Id,
        Account__c = acc.Id,
        Business_Unit_Text__c = 'Interventional' 
        );
        
        Territory_User__c tu = new Territory_User__c(
            User__c = u.Id,
            Business_Unit__c = 'Interventional',
            Role__c = 'Sales Rep',
            Territory_Master__c = tm.Id,
            Territory_Number__c = '123456'
        );
        insert tu;
        
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
            Business_Unit__c = 'Surgical Disposables',
            ZPSA_Table__c = 'A672'
        );
        insert tarbc;
        
         Territory_Assignment__c terrAssignment = new Territory_Assignment__c (
            Name = 'NC-700123',
            Account__c = acc.id,
            Territory_Alignment__c = tarbc.id,
            Territory__c = tm.Id,
            Territory_Number__c = '123456'
        );
        
        insert terrAssignment; 
        
        
        
        MANTA_Master__c mantaMastrObj1 = new MANTA_Master__c();
        mantaMastrObj1.Trainer__c = u.Id;
        mantaMastrObj1.isAdminAccess__c = true;
        insert mantaMastrObj1;
        
        MANTA_Master__c mantaMastrObj = new MANTA_Master__c();
        mantaMastrObj.Trainer__c = u.Id;
        mantaMastrObj.isAdminAccess__c = true;
        insert mantaMastrObj;
        
        mantaMastrObj.Type__c = 'proctor';
  		update mantaMastrObj;
        
        MANTA_Proctorship_Request__c mantaProcReqObj = new MANTA_Proctorship_Request__c();
        mantaProcReqObj.Case_Date__c = System.Today();
        mantaProcReqObj.Case_Initiator__c = u.Id;
        mantaProcReqObj.Case_Type__c = 'TVAR';
        mantaProcReqObj.Estimated_of_Cases__c = 3.0;
        mantaProcReqObj.Hospital__c = acc.Id;
        mantaProcReqObj.Region__c = 'South';
        insert mantaProcReqObj;
        
        
        mantaProcReqObj.Case_Date__c = System.Today() + 3;
        mantaProcReqObj.Status__c = 'Open (Not Accepted)';
        update mantaProcReqObj;
        
        MANTA_Proctorship_Request__c mantaProcReqObj1 = new MANTA_Proctorship_Request__c();
        mantaProcReqObj1.Case_Date__c = mantaProcReqObj.Case_Date__c;
        mantaProcReqObj1.Status__c = 'Open (Not Accepted)';
        mantaProcReqObj1.Hospital__c = acc.Id;
        mantaProcReqObj1.Case_Initiator__c = u.Id;
        mantaProcReqObj1.Proctor__c = u.Id;
        mantaProcReqObj1.Region__c = 'South';
        insert mantaProcReqObj1;
        mantaProcReqObj1.Status__c = 'Accepted';
        update mantaProcReqObj1;
        
        MANTA_Case_Data__c mantaCaseDtaObj = new MANTA_Case_Data__c(
            Case_Start_Time__c=Time.newInstance(1, 2, 3, 4),
            Deploying_Physician__c=con.Id,
            Hospital_Name__c=acc.Id,
            MANTA_Trainer__c=u.Id,
            MANTA_Trainer_in_Training__c=u.Id,
            Case_Type__c='VAD',
            MANTA_Proctorship_Request__c=mantaProcReqObj1.Id
        );
        

         Test.startTest();
        TFX_MANTA_Handler.getLoggedInUser();
        TFX_MANTA_Handler.saveMANTANewRequest(JSON.serialize(mantaProcReqObj));
        TFX_MANTA_Handler.updateMANTAOpenReq(JSON.serialize(mantaProcReqObj));
        TFX_MANTA_Handler.updateMANTAOpenReq(JSON.serialize(mantaProcReqObj1));
        TFX_MANTA_Handler.sendEmailToProctorsInAccRegion(mantaProcReqObj1);
        TFX_MANTA_Handler.updateMANTAAcceptedReq(JSON.serialize(mantaProcReqObj));
        TFX_MANTA_Handler.updateMANTAAcceptedReq(JSON.serialize(mantaMastrObj));
        TFX_MANTA_Handler.getAllOrSelHospOpenReqs(String.valueOf(mantaProcReqObj.Hospital__c), 'Great Plains');
        TFX_MANTA_Handler.getAllOrSelHospOpenReqs('All', 'Great Plains');
        TFX_MANTA_Handler.getAllOrSelHospOpenReqs('All', 'Great Plains');
        TFX_MANTA_Handler.getDfltValsForDateFilters();
        TFX_MANTA_Handler.getAllOrSelHospArchivedReqs('All', 'Great Plains', fromDate, toDate);
        TFX_MANTA_Handler.getAllOrSelHospArchivedReqs('All', 'Great Plains', fromDate, toDate);
        TFX_MANTA_Handler.getAllOrSelHospCancelledReqs('All', 'Great Plains');
        TFX_MANTA_Handler.getAllOrSelHospCancelledReqs('All', 'Great Plains');
        TFX_MANTA_Handler.getUsrProcForEdit(mantaMastrObj.Trainer__c);
        TFX_MANTA_Handler.getAllOrSelHospAcptdReqs(mantaProcReqObj1.Hospital__c, 'Great Plains');
        TFX_MANTA_Handler.getAllOrSelHospAcptdReqs('All', 'Great Plains');
        TFX_MANTA_Handler.getAllProctorsInSF();
        TFX_MANTA_Handler.getProctorByProctorId(u.Id);
        TFX_MANTA_Handler.getProctorByProctorId('All');
        TFX_MANTA_Handler.addProctorInSF(u.Id);
        TFX_MANTA_Handler.updateMANTAProctor(JSON.serialize(mantaMastrObj));
        TFX_MANTA_Utility_Handler.getAllPhysAndRgnByHospAccId(acc.Id);
        TFX_MANTA_Utility_Handler.getAllProctorsInSF();
        TFX_MANTA_Handler.getAllPhysAndRgnByHospAccId(acc.Id);
        TFX_MANTA_Handler.getMANTACaseEvents('All');
        TFX_MANTA_Handler.getMANTACaseEvents('Lone Star');
        TFX_MANTA_Handler.updateEvent(mantaProcReqObj.Id, String.valueOf(mantaProcReqObj.Case_Date__c + 3));
        TFX_MANTA_Handler.getAllCaseDataRecsForProcId(mantaProcReqObj1.Id);
        TFX_MANTA_Handler.saveMANTACaseDataRecs(JSON.serialize(mantaCaseDtaObj));
        TFX_MANTA_Handler.emailCaseDataToUser(JSON.serialize(mantaCaseDtaObj), u.Id);
        
         Test.stopTest();
        
    }
    
    
}