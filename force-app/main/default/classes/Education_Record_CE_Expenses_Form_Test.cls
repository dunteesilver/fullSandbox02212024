@isTest
private class Education_Record_CE_Expenses_Form_Test  {
        // Education_Global_Test_Class replaces this test class - 08Mar2018 - ESC
/*

    static testmethod void test1() {
        
        List<Education_Record__c> edrecs = Education_Record_Utility_Test.createTestRecords(1);
        
        //added by Dun
        // Implement test code
        test.startTest();
        Account accTest = new Account(
            Name='Test Account',
     //       Account_Code__c='3333333',
            Description = 'Test_Account');
        
        insert accTest;
        System.debug('Account-->' + accTest);
        
        Contact contTest = new Contact(
            FirstName='Contact',
            LastName='Test',
            Account = accTest,
            email = 'test@test.com'
        );
        
        insert contTest;
        System.debug('Contact-->' + ContTest);
        
        Profile profile1 = [Select Id from Profile where name = 'Clinical Team'];
        
        User ManagerTest = new User(
            FirstName = 'Test',
            LastName = 'Test',
            username = 'ManagerTest1212@test.com',
            Email = 'ManagerTest@test.com',
            Alias = 'ManTest',
            ProfileId = profile1.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert ManagerTest;
        System.debug('ManagerTest-->' + ManagerTest);
        
        User ManagerTest2 = new User(
            FirstName = 'Test2',
            LastName = 'Test2',
            username = 'ManagerTest2323@test.com',
            Email = 'ManagerTest2@test.com',
            Alias = 'ManTest2',
            ProfileId = profile1.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert ManagerTest2;
        System.debug('ManagerTest2-->' + ManagerTest2);
        
        User SalesRepTest = new User(
            FirstName = 'Test SR',
            LastName = 'Test',
            username = 'SalesRepTest1212@test.com',
            Manager = ManagerTest,
            CEM__c =  ManagerTest.Id,
            Email = 'SalesRepTest@test.com',
            Alias = 'SalTest',
            ProfileId = profile1.Id,
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        
        insert SalesRepTest;
        System.debug('SalesRepTest-->' + SalesRepTest);
        
        User SalesRepTest2 = new User(
            FirstName = 'Test2 SR',
            LastName = 'Test2',
            username = 'SalesRepTest2323@test.com',
            Manager = ManagerTest,
            CEM__c =  ManagerTest.Id,
            Email = 'SalesRepTest2@test.com',
            Alias = 'SalTest2',
            ProfileId = profile1.Id,
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        
        insert SalesRepTest2;
        System.debug('SalesRepTest2-->' + SalesRepTest2);
        
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
            username='unit.test1313@unit.teleflex.com'
        );
        insert u;
        
        
        
        System.runAs(u){
            
            EmailTemplate e = new EmailTemplate (
                developerName = 'CA_Check_Request_Form_Supa', 
                //FolderId = 'Give Id Of Email Folder', 
                FolderId = UserInfo.getUserId(),
                TemplateType= 'Text', 
                Name = 'test'
            ); 
            insert e;
            
            Profile__c profTest = new Profile__c(
                
                First_Name__c = 'Prof1',
                Name = 'Last1',
                Status__c = 'Active',
                CEM__c = ManagerTest.Id,
                Phone_Number__c = '9192223333',
                Mailing_Address__c = '123 Test St',
                Mailing_City__c = 'Raleigh',
                Mailing_State__c = 'NC',
                Mailing_Zip__c = '27610',
                Mailing_Country__c = 'US',
                E_mail_Address__c = 'duntee.silver@teleflex.com'
            );
            insert profTest;
            
            Profile__c profTest2 = new Profile__c(
                
                First_Name__c = 'Prof2',
                Name = 'Last2',
                Status__c = 'Active',
                CEM__c = ManagerTest.Id,
                Phone_Number__c = '9192223333',
                Mailing_Address__c = '123 Test St',
                Mailing_City__c = 'Raleigh',
                Mailing_State__c = 'NC',
                Mailing_Zip__c = '27610',
                Mailing_Country__c = 'US',
                E_mail_Address__c = 'eric.clay@teleflex.com'
            );
            insert profTest2;
            
            Education_Record__c EducTest = new Education_Record__c(
                Name = 'Education Test',
                Account_Facility__c =  accTest.Id,
                Sales_Rep__c = SalesRepTest.Id,
                CEM__c = SalesRepTest.Id,
                Hotel_Requested__c = 'No', // This is what fixes all the validation rule errors - ESC
                Clinical_Educator__c = profTest.Id
            );
            Insert EducTest;
            System.debug('EducTest-->' + EducTest);
            
            System.assertNotEquals(EducTest.RSM__c,ManagerTest.Id);
            System.assertEquals(EducTest.Clinical_Educator__c,profTest.Id);
            
            EducTest.Sales_Rep__c = SalesRepTest2.Id;
            EducTest.Clinical_Educator__c = profTest2.Id;
            update EducTest;
            //end of Dun' stuff
            
            //PageReference pageRef = Page.Education_Record_CEPublic; 
            //Test.setCurrentPage(pageRef);    
            CE_Reimbursement_Expense__c CRF = new CE_Reimbursement_Expense__c(
                Education_Record__c=EducTest.id, 
                Status__c='New', 
                Clinical_Educator_Name__c=edrecs[0].Clinical_Educator__c, 
                CEM__c='005E0000006meGU'
            );
            
            insert CRF;
            
            
            
            CRF.status__c = 'Approved for Payment';
            system.assertEquals('Approved for Payment', CRF.Status__c);
            system.debug('*** CRF *** ' + CRF);
            update CRF;
            test.stopTest();
            /*
Attachment attach=  new Attachment(Name='TestMeals',Body= blob.valueOf('Unit Test'),parentId=crf.id);
insert attach; 

Attachment attach2=  new Attachment(Name='Roster',Body= blob.valueOf('Unit Test'),parentId=edrecs[0].id);
insert attach2; 

List<CE_Reimbursement_Expense__c> crfs = new List<CE_Reimbursement_Expense__c>();
crfs.add(crf) ;


            //ApexPages.standardController controller = new ApexPages.standardController(CRF);
            //Education_Record_Update pag = new Education_Record_Update(controller);
            //    Education_Record_AddAttachment pag1 = new Education_Record_AddAttachment(controller);   
            
            PageReference pageRef = new PageReference('/apex/Education_Record_CEPublic?id=' + CRF.Id);
            Test.setCurrentPage(pageRef);
            
            System.currentPageReference().getParameters().put('id', CRF.Id);
            Education_Record_Update pag = new Education_Record_Update();
            pag.save();
            pag.saverefresh();
            pag.submit();
            //pag.getReceipts();
            //pag.getRosters();
            
        }
        
        
        
        
        
        
    }*/
}