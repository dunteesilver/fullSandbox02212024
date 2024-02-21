@isTest public class ContactSearchCtrlTest {
    static testMethod void PP_Create_Contact_UnitTest() {
        
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
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
            Business_Unit__c = 'Australia',
            UserRoleId = roleId
        );
        insert u;
        System.runAs(u){
            Account accRec = new Account(
                Name= 'TestAccount',
                SAP_Sold_To__c = '102059',
                Description = 'AA-10511-1',
                Account_Group__c = 'Z001'
            );
            insert accRec;
            Contact conRec = TestDataFactory.createContact('TestContact', accRec.Id);            
            Test.startTest();
            String reactiveValue = accRec.Id;
            ContactSearchCtrl.getContacts('Test',accRec.Id);
            Test.stopTest();
        }
    }
}