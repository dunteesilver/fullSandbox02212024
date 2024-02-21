@IsTest
public class WinnersGuideHandlerTest {

    static testmethod void createData() {
        
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
                Region__c = 'Southwest'
            );
            insert u;
        
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
        
         Opportunity newOpp = new Opportunity(
                Name = 'Test Opp',
                Account = acc,
                CloseDate = Date.Today() + 90,
                Primary_Contact__c = con.Id,
                StageName = 'Qualified Prospect',
                Amount = 1.00,
                Product_Family__c = 'Airway',
                Business_Unit__c='Surgical Disposables',
                //RecordTypeId = '01244000000NNcz',
                Business_Unit_GPL__c='Anesthesia',
                Product_Family_GPL__c='Airway',
                Product_of_Interest_GPL__c='TruLite'
            );
            insert newOpp;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = newOpp.Id;
        ocr.ContactId = con.Id;
        insert ocr;
        
        Winners_Guide__c wgObj = new Winners_Guide__c(
            Opportunity__c = newOpp.Id
        );
        insert wgObj;
        
        WinnersGuideHandler.ConRoleWrapper conWrpObj = new WinnersGuideHandler.ConRoleWrapper();
        	conWrpObj.contactName = ocr.Contact.Name;
            conWrpObj.title = ocr.Contact.Position_Job_Title__c;
            conWrpObj.role = ocr.Role; 
            conWrpObj.email = ocr.Contact.Email;
        
        

        
        Test.startTest();
        
        WinnersGuideHandler.getWGinfoForRecID(wgObj.Id);
        WinnersGuideHandler.saveWGBalSellerDetails(JSON.serialize(wgObj));
        WinnersGuideHandler.getWGDetails(wgObj.Id);
        
        Test.stopTest();
        
        
        
    }
}