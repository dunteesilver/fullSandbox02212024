@istest
public class territory_zipcode_test {
    @istest static void validate_ZIP(){
        /*
        Quick_Disable__c cs = new Quick_Disable__c(
            Name = 'insertSAP',
            Enable__c = TRUE
        );
        System.debug('insert cs-->' + cs);
        insert cs;
        
        RecordType leadrt = [SELECT Id, Name 
                             FROM RecordType 
                             WHERE SobjectType='Lead' AND Name = 'EMS Lead' 
                             LIMIT 1];
        
        Group g1 = new Group(
            Name='EMS Lead Queue', 
            type='Queue'
        );
        insert g1;
        System.runAs(new User(Id = UserInfo.getUserId())){
            
            QueuesObject q1 = new QueueSObject(
                QueueID = g1.id, 
                SobjectType = 'Lead'
            );
            insert q1;
            
        }
        
        
        
        Lead_Settings__c  ls = new Lead_Settings__c (
            Name = 'EMS',
            Lead_Owner_ID__c = g1.id,
            Record_Type_ID__c = leadrt.Id
        );
        System.debug('insert Lead Settings-->' + ls);
        insert ls;
        
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
            UserName='TeleflexTESTER@teleflex.test.com'
        );
        insert u;
        System.debug('Insert User-->' + u);
        
        Territory_Master__c tm = new Territory_Master__c(
            Name = '800123',
            Territory_Number__c = '800123',
            Business_Unit__c = 'EMS'
        );
        insert tm;
        System.debug('Insert Territory Master-->' + tm);
        
        Territory_User__c tu = new Territory_User__c(
            Territory_Master__c = tm.Id,
            User__c = u.id
        );
        insert tu;
        System.debug('Insert Territory User-->' + tu);
        
        Zip_Code_Territories__c  zct = new Zip_Code_Territories__c(
            Name = '27614',
            Zip_Code__c = '27614',
            EMS__c = '800123'
        );
        insert zct;
        System.debug('Insert Zip Code Territory: ' + zct); 
        
        Zip_Code_Territories__c  zct2 = new Zip_Code_Territories__c(
            Name = '27615',
            Zip_Code__c = '27615',
            EMS__c = ''
        );
        insert zct2;
        System.debug('Insert Zip Code Territory2: ' + zct2);  
        
        // Create the Lead
        Lead l = new lead(
            lastname = 'test',
            company = 'test',
            Status = 'Open',
            PostalCode = '27614',
            Business_Unit__c = 'EMS'
        );
        insert l;
        
        // Create the Lead
        Lead l2 = new lead(
            lastname = 'test',
            company = 'test',
            Status = 'Open',
            PostalCode = '27615'
        );
        insert l2;
        
        l2.Business_Unit__c = 'EMS';
        update l2;
        */
        
    }
}