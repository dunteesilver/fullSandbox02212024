@isTest
private class addBUtoContactsTriggerTest {

    static testMethod void testAddBUtoContacts(){
        Profile p = [SELECT Id FROM Profile WHERE Id='00eE0000000lT3QIAU'];
        User u = new User(Username='trey.flowers@teleflex.com.testingforBUtrigger',Email='trflowers@teleflex.com',Lastname='User', Firstname='Test', Alias='tuser',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', profileid=p.Id,Business_Unit__c='Surgical',timezonesidkey='America/New_York');
        insert u;
        
        Contact c = new Contact(FirstName ='Test',
            email = 'abc@123.com', Lastname='testing123',Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)');
        insert c;
        
        c.Firstname='juniper';
        update c;
    }

}