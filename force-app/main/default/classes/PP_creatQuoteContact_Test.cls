@isTest
private class PP_creatQuoteContact_Test {
    
    static testMethod void PP_creatQuoteContact_UnitTest() {

        String roleId = [SELECT Id, Name FROM UserRole WHERE Name LIKE '%EMEA%' LIMIT 1].Id;
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
            Business_Unit__c='EMEA',
            timezonesidkey='Europe/London',
            username='unit.test@unit.teleflex.com',
            UserRoleId = roleId
        );
        insert u;
     
        System.runAs(u){

            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex/Arrow',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Active_Sales_Org_Key__c = 'AU1010',
                Active_Currency__c = 'USD'
            );
            insert cu;

            Account accObj = TestDataFactory.createAccount('Test Account');
            Contact conObj = TestDataFactory.createContact('Test Contact', accObj.id);

            Test.startTest();
            PP_creatQuoteContact.creatQuoteContact(conObj.Id);
            PP_creatQuoteContact.creatQuoteContactLightning(conObj.Id);
            Test.stopTest();
            
        }
    }
}