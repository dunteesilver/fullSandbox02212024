/*********************************************************************
* Description     : Main test class for task_Helper_Class
* Covered Classes : task_Helper_Class
* Author(s)       : Dun Silver
**********************************************************************/

@isTest
public with sharing class task_Helper_Class_Test {
    
    
    @istest static void taskTest(){
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
            username='unit.test@unit.teleflex.com'
        );
        insert u;
        
        Account a = new Account(
            Name = 'Test PP Account',
            SAP_Sold_To__c ='100123',
            ShippingStreet='123 Main Street ',
            ShippingCity='Raleigh',
            ShippingState='NC',
            ShippingPostalCode='27614',
            Customer_Group__c = '19',
            AnnualRevenue=23.0,
            Sales_Org__c='CA10',
            Customer_Group_Name__c='Test Cust Grp Name'
        );
        insert a;
        system.debug('a:' + a);
        
        Contact c = new Contact(
            FirstName ='Test',
            email = 'abc@123.com',
            lastname = 'Test',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
            AccountId = a.id
        );
        insert c;
        system.debug('c:' + c);
        
        Contact c1 = new Contact(
            FirstName ='Test1',
            email = 'abcd@123.com',
            lastname = 'Test',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)'
        );
        insert c1;

        
        Lead l = new lead(
            lastname = 'test',
            company = 'test',
            Status = 'Open'
        );
        insert l;
        
        Campaign cam = New Campaign(
            Name = 'Zuant Test',
            Status = 'In Progress',
            IsActive = TRUE,
            Type = 'Lead Test'
        );
        insert cam;
        
        Opportunity o = new Opportunity(
            Name = 'Test Opp',
            AccountId = a.Id,
            CloseDate = Date.Today() + 90,
            Primary_Contact__c = c.Id,
            StageName = 'Qualified Prospect',
            Amount = 1.00,
            Product_Family__c = 'Airway',
            Business_Unit__c='Surgical Disposables',
            //RecordTypeId = '01244000000NNcz',
            Business_Unit_GPL__c='Anesthesia',
            Product_Family_GPL__c='Airway',
            Product_of_Interest_GPL__c='TruLite',
            CampaignId = cam.Id
            //Pricebook2 = pb,
            //Price_Quote__c = PQTest.Id
        );
        insert o;
        Id isRT = [SELECT Id FROM RecordType WHERE Name = 'CMA Record' AND SobjectType = 'Education_Record__c'].Id;
        Education_Record__c er1 = new Education_Record__c(
                Name = 'Test',
                Business_Unit__c = 'VA',
                Primary_Product__c = 'EZ-IO',
                SecondaryProduct__c = 'EZ-IO',
                Department_a__c = 'EMS',
                Check_in_Date__c = date.today(),
                Recommended_Hotel_1st_Choice__c = 'Hilton',
                Recommended_Hotel_2nd_Choice__c = 'Holiday Inn',
                First_Street_Address__c = '123 Main Street',
                Second_Street_Address__c = '321 Main Street',
                Stage__c = 'New',
                First_City__c = 'Raleigh',
                Second_City__c = 'Raleigh',
                RecordTypeId = isRT
            );
            insert er1;
        
        list<Task> newTasks = new list<Task>();

        Task t1 = new Task(
            OwnerId = u.Id,
            Subject = 'Test',
            WhatId = o.Id,
            WhoId = c.Id,
            Status = 'Not Started',
            Priority = 'Normal',
            Type__c = 'EPA review'
        );
        newTasks.add(t1);
        insert t1;
        
        Task t2 = new Task(
            OwnerId = u.Id,
            Subject = 'Test',
            //WhatId = o.Id,
            WhoId = l.Id,
            Status = 'Not Started',
            Priority = 'Normal',
            Type__c = 'EPA review'
        );
        newTasks.add(t2);
        insert t2;
        
        Task t3 = new Task(
            OwnerId = u.Id,
            Subject = 'Test',
            WhatId = a.Id,
            WhoId = c.Id,
            Status = 'Not Started',
            Priority = 'Normal',
            Type__c = 'EPA review'
        );
        newTasks.add(t3);
        insert t3;
        
        Task t4 = new Task(
            OwnerId = u.Id,
            Subject = 'Test',
            //WhatId = a.Id,
            WhoId = c.Id,
            Status = 'Not Started',
            Priority = 'Normal',
            Type__c = 'Spotlight on Urology'
        );
        newTasks.add(t4);
        insert t4;
        
        Task t5 = new Task(
            OwnerId = u.Id,
            Subject = 'Test',
            WhatId = er1.Id,
            WhoId = c.Id,
            Status = 'Not Started',
            Priority = 'Normal',
            Type__c = 'Spotlight on Urology'
        );
        newTasks.add(t5);
        insert t5;
        
        Task t6 = new Task(
            OwnerId = u.Id,
            Subject = 'Test',
            WhatId = er1.Id,
            WhoId = c1.Id,
            Status = 'Not Started',
            Priority = 'Normal',
            Type__c = 'Spotlight on Urology'
        );
        newTasks.add(t6);
        insert t6;
        
        task_Helper_Class.addLookups(newTasks);
        task_Helper_Class.addNewProductTracking(newTasks);
        task_Helper_Class.eloquaTaskUpdate(newTasks);
        /*

PageReference pageRef2 = new PageReference('/apex/PP_PRF?id=' + pq.Id);
system.debug('PRF Page' + pageRef2);
Test.setCurrentPage(pageRef2);

PP_PRF pqtest = new PP_PRF();

PP_PRF.settu();
pqtest.getPLI();
pqtest.gettodaysdate();
pqtest.getprf();
pqtest.save();
pqtest.cancel();
pqtest.xls();


PageReference pageRef3 = new PageReference('/apex/PP_PRF_EXPORT?id=' + pq.Id);
system.debug('PRF Page' + pageRef3);
Test.setCurrentPage(pageRef3);

PP_PRF pqtest2 = new PP_PRF();
pqtest2.getPLI();
pqtest2.getprf();
*/
        
    }
}