@isTest
public class Education_Assign_Approvers_Test {
    // Education_Global_Test_Class replaces this test class - 08Mar2018 - ESC
/*
    static testmethod void myUnitTest() {
        Test.startTest();
        
        Account accTest = new Account(
            Name='Test Account',
            // Account_Code__c='3333333',
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
            username = 'ManagerTest4545@test.com',
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
            username = 'ManagerTest5656@test.com',
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
            username = 'SalesRepTest4545@test.com',
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
            username = 'SalesRepTest5656@test.com',
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
        
        Profile__c profTest = new Profile__c(
            
            First_Name__c = 'Prof1',
            Name = 'Last1',
            CEM__c = ManagerTest.Id,
            Status__c = 'Active',
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
            Status__c = 'Active',
            Name = 'Last2',
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
            Hotel_Requested__c = 'No',
            Clinical_Educator__c = profTest.Id
        );
        Insert EducTest;
        System.debug('EducTest-->' + EducTest);
        
        System.assertNotEquals(EducTest.RSM__c,ManagerTest.Id);
        System.assertEquals(EducTest.Clinical_Educator__c,profTest.Id);
        
        EducTest.Sales_Rep__c = SalesRepTest2.Id;
        EducTest.Clinical_Educator__c = profTest2.Id;
        update EducTest;
        
        System.assertEquals(EducTest.Clinical_Educator__c,profTest2.Id);
        
        //  list<Id> EDList = new List<Id>();
        //      EDList.add(EducTest.Id);
        
        Test.stopTest();
        
    }*/
}