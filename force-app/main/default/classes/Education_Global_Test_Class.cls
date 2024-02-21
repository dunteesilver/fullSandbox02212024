@isTest
public class Education_Global_Test_Class {
    
    @testSetup static void dataSetup(){
        Profile p = [select id from profile where name='System Administrator'];
        Profile p2 = [select id from profile where name='Clinical Affairs'];
        User uMSG = new User(
            alias = 'uflex76', 
            email='unit.uMSG@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Adam',
            lastname='Franks', 
            languagelocalekey='en_US',
            localesidkey='en_GB', 
            profileid = p2.Id,
            timezonesidkey='Europe/London', 
            username='unit.uMSG@unit.teleflex.com',
            Business_Unit__c = 'Vascular'
        );
        insert uMSG;
        
        User uSR = new User(
            alias = 'uflex76', 
            email='unit.uSR@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Adam',
            lastname='Franks', 
            languagelocalekey='en_US',
            localesidkey='en_GB', 
            profileid = p.Id,
            timezonesidkey='Europe/London', 
            username='unit.uSR@unit.teleflex.com',
            Business_Unit__c = 'Vascular',
            CEM__c = uMSG.Id,
            RCEM__c = uMSG.Id, 
            ManagerId = uMSG.Id
        );
        insert uSR;
        
        User uMSG2 = new User(
            alias = 'uflex76', 
            email='unit.uMSG2@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Adam',
            lastname='Franks', 
            languagelocalekey='en_US',
            localesidkey='en_GB', 
            profileid = p2.Id,
            timezonesidkey='Europe/London', 
            username='unit.uMSG2@unit.teleflex.com',
            Business_Unit__c = 'Vascular'
        );
        insert uMSG2;
        
        User uSR2 = new User(
            alias = 'uflex76', 
            email='unit.uSR2@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Adam',
            lastname='Franks', 
            languagelocalekey='en_US',
            localesidkey='en_GB', 
            profileid = p.Id,
            timezonesidkey='Europe/London', 
            username='unit.uSR2@unit.teleflex.com',
            Business_Unit__c = 'Vascular',
            CEM__c = uMSG.Id,
            RCEM__c = uMSG.Id, 
            ManagerId = uMSG.Id
        );
        insert uSR2;
        
        System.runAs(uSR){
            Account a = new Account(
                Name = 'Test PP Account', 
                SAP_Sold_To__c ='100123', 
                ShippingStreet='123 Main Street ', 
                ShippingCity='Raleigh',
                ShippingState='NC', 
                ShippingPostalCode='27614',
                Customer_Group__c = '19',
                zBlock__c = '00',
                Account_Group__c = 'Z001',
                ERP_Active__c = TRUE
            );
            insert a;
            
            Contact c = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'TestContact@email.com',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                
                AccountId = a.Id,
                Business_Unit1__c = 'Vascular'
            );
            insert c;
            
            Programs__c pgr = new Programs__c(
                Name = 'EZ-IO Product Training',
                Business_Unit__c = 'VA',
                Program_Type__c = 'Live Education Program Request',
                Type__c = 'Live Training',
                Products__c = 'EZ-IO',
                Key__c = 'ALL',
                Active__c = TRUE
            );
            insert pgr;
            
            
            
            Pay_Profile__c pp = new Pay_Profile__c(
                Name = 'Test',
                Active__c = TRUE,
                Travel_Eligible__c = TRUE,
                Inservice_Hour__c = 123.00,
                Role__c = 'MD',
                Level__c = 'Tier 1'
            );
            insert pp;
            
            // Education Contractor only accepts 'Contractor' Profiles
            map<String, Id> profileMap = new map<String, Id>();
            for(RecordType rt : [SELECT Name, ID 
                                 FROM RecordType 
                                 WHERE SobjectType = 'Profile__c'])
            {
                profileMap.put(rt.Name, rt.Id);
            }
            Id ProfileId = [SELECT ID FROM RecordType WHERE Name = 'Contractor' AND SobjectType = 'Profile__c' LIMIT 1].Id;
            //Clinical Educator
            //Contractor
            Profile__c newProfile = new Profile__c(
                Name = 'First Last',
                First_Name__c = 'First',
                Last_Name__c = 'Last',
                Pay_Rate_Card__c = pp.Id,
                CEM__c = uMSG.Id,
                Phone_Number__c = '919-555-1212',
                E_mail_Address__c = 'abc@123.com',
                //RecordTypeId = ProfileId,
                RecordTypeId = profileMap.get('Contractor'),
                Mailing_Address__c = '123 Main St',
                Mailing_City__c = 'Raleigh',
                Mailing_Country__c = 'US',
                Mailing_State__c = 'NC',
                Mailing_Zip__c = '27614',
                Status__c = 'Active'
            );
            insert newProfile;
            
            Profile__c ceProfile = new Profile__c(
                Name = 'First Last',
                First_Name__c = 'First',
                Last_Name__c = 'Last',
                Pay_Rate_Card__c = pp.Id,
                CEM__c = uMSG.Id,
                Phone_Number__c = '919-555-1212',
                E_mail_Address__c = 'abc@123.com',
                //RecordTypeId = ProfileId,
                RecordTypeId = profileMap.get('TFX - Internal Resource'),
                Mailing_Address__c = '123 Main St',
                Mailing_City__c = 'Raleigh',
                Mailing_Country__c = 'US',
                Mailing_State__c = 'NC',
                Mailing_Zip__c = '27614',
                Status__c = 'Active',
                Sales_Rep__c = uSR.Id
            );
            insert ceProfile;
            Id isRT = [SELECT Id FROM RecordType WHERE Name = 'Live Education Program Request' AND SobjectType = 'Education_Record__c'].Id;
            Education_Record__c er1 = new Education_Record__c(
                Name = 'Test',
                Business_Unit__c = 'VA',
                Primary_Product__c = 'EZ-IO',
                SecondaryProduct__c = 'EZ-IO',
                Program__c = pgr.Id,
                Department_a__c = 'EMS',
                Account_Facility__c = a.Id,
                Contact_Name__c = c.Id,
                Check_in_Date__c = date.today(),
                Recommended_Hotel_1st_Choice__c = 'Hilton',
                Recommended_Hotel_2nd_Choice__c = 'Holiday Inn',
                First_Street_Address__c = '123 Main Street',
                Second_Street_Address__c = '321 Main Street',
                Stage__c = 'New',
                First_City__c = 'Raleigh',
                Second_City__c = 'Raleigh',
                Clinical_Educator__c = ceProfile.Id,
                Clinical_Educator2__c = ceProfile.Id,
                Clinical_Educator3__c = ceProfile.Id,
                RecordTypeId = isRT
            );
            insert er1;
            //Inservice Record
            
            Education_Record__c er2 = new Education_Record__c(
                Name = 'Test2',
                Business_Unit__c = 'VA',
                Primary_Product__c = 'EZ-IO',
                SecondaryProduct__c = 'EZ-IO',
                Program__c = pgr.Id,
                Department_a__c = 'EMS',
                Account_Facility__c = a.Id,
                Contact_Name__c = c.Id,
                Check_in_Date__c = date.today(),
                Recommended_Hotel_1st_Choice__c = 'Hilton',
                Recommended_Hotel_2nd_Choice__c = 'Holiday Inn',
                First_Street_Address__c = '123 Main Street',
                Second_Street_Address__c = '321 Main Street',
                Stage__c = 'New',
                First_City__c = 'Raleigh',
                Second_City__c = 'Raleigh',
                Clinical_Educator__c = ceProfile.Id,
                Clinical_Educator2__c = ceProfile.Id,
                Clinical_Educator3__c = ceProfile.Id,
                RecordTypeId = isRT
            );
            insert er2;
            
            dateTime dtToday = DateTime.valueOfGMT(String.valueOf(DateTime.now()));
            date dToday = date.newinstance(dtToday.year(), dtToday.month(), dtToday.day());
            
            Id inserviceRT = [SELECT Id FROM RecordType WHERE Name = 'Inservice Record' AND SobjectType = 'Education_Record__c'].Id;
            Education_Record__c er3 = new Education_Record__c(
                Name = 'Test3',
                //Date_of_Event_Start__c = date.today()-1, // Confirmed Start Date
                Date_of_Event_Start__c = dToday-1, // Confirmed Start Date
                //Ending_Date__c = date.today(), // Confirmed End Date
                Ending_Date__c = dToday, // Confirmed End Date
                Business_Unit__c = 'VA',
                Primary_Product__c = 'EZ-IO',
                SecondaryProduct__c = 'EZ-IO',
                CEM__c = uSR.Id,
                Account_Facility__c = a.Id,
                Contact_Name__c = c.Id,
                RecordTypeId = inserviceRT,
                Clinical_Educator__c = ceProfile.Id,
                Clinical_Educator2__c = ceProfile.Id,
                Clinical_Educator3__c = ceProfile.Id,
                Stage__c = 'New'  
            );
            insert er3;
            
            Education_Contractor__c ec = new Education_Contractor__c(
                Contractor_Profile__c = newProfile.Id,
                Engagement_Type__c = 'Inservice (Hour)',
                Education_Record__c = er1.Id,
                Reimbursement_Rate__c = 123.00,
                Email__c = 'abc@123.com'
            );
            insert ec;
            
            Education_Contractor__c ec3 = new Education_Contractor__c(
                Contractor_Profile__c = newProfile.Id,
                Engagement_Type__c = 'Inservice (Hour)',
                Education_Record__c = er3.Id,
                Reimbursement_Rate__c = 123.00,
                Email__c = 'abc@123.com'
            );
            insert ec3;
            system.debug('Education Contractor 3: ' + ec3);    
        }
        
        
        
        
    }
    
    @isTest static void testClasses(){
        Education_Record__c er = [SELECT Id, Ending_Date__c, Stage__c FROM Education_Record__c WHERE Name = 'Test3' LIMIT 1];
        for(Education_Contractor__c ec : [SELECT Status__c, Engagement_Type__c, Education_Record__c, Contractor_Profile__c 
                                          FROM Education_Contractor__c])
        {
            system.debug('Education Contractor: ' + ec);
        }
        
        master_TriggerHelperClass.runOnce('resetOnceSet');
        //er.Stage__c = 'Training Completed';
        er.Simulate_Training_Complete__c = TRUE;
        system.debug('Education Record Test3: ' + er);
        update er;
        
        User newSalesUser = [SELECT Id FROM User WHERE email = 'unit.uSR2@unit.teleflex.com' LIMIT 1];
        er.Sales_Rep__c = newSalesUser.Id;
        master_TriggerHelperClass.runOnce('resetOnceSet');
        update er;
        
        CE_Reimbursement_Expense__c CRF = [SELECT Id FROM CE_Reimbursement_Expense__c LIMIT 1];
        //system.debug('ER Name: ' + er.Name);
        PageReference pageRef = new PageReference('/apex/Education_Record_CEPublic?id=' + CRF.Id);
        Test.setCurrentPage(pageRef);
        
        System.currentPageReference().getParameters().put('id', CRF.Id);
        System.currentPageReference().getParameters().put('success', 'true');
        
        //ApexPages.StandardController stdController = new ApexPages.StandardController(er);
        //Education_Record_Update eru = new Education_Record_Update(stdController);
        Education_Record_Update eru = new Education_Record_Update();
        
        eru.getReceipts();
        eru.getRosters();
        eru.save();
        eru.saveRefresh();
        eru.submit();
        id testOrgId = eru.OrgId;
        id testLogoId = eru.logoId;
        Boolean testrosterCount = eru.rosterCount;
        Boolean testreceiptsCount = eru.receiptsCount;
    }
    
    @isTest static void testVFPages(){
        
        
        /*                eru.crf
eru.ctrl;
eru.er;
eru.logoId;
eru.OrgId;
eru.receiptsCount;
eru.rosterCount;


OrgId
logoId
rosterCount
receiptsCount
save
getRosters
getReceipts
submit
saveRefresh
*/
        
    }
    
}