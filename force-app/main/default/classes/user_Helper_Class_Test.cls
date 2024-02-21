@istest
public class user_Helper_Class_Test {
    public static testMethod void user_Helper_testClass(){
        Business_Unit__c bu = new Business_Unit__c(
            name = 'Surgical Instruments',
            Key__c = 'SINS'
        );
        insert bu;

        Business_Unit__c bu2 = new Business_Unit__c(
            name = 'Vascular',
            Key__c = 'VAS'
        );
        insert bu2;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(
            Alias = 'standt',
            Email='standarduser76@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='TeleflexTESTER@teleflex.test.com',
            Business_Unit__c = 'Surgical Instruments'
        );
        insert u;
        System.debug('Insert User-->' + u);

        u.Business_Unit__c = 'Vascular';
        update u;

        u.Business_Unit__c = NULL;
        update u;

        master_TriggerHelperClass.runOnce('resetOnceSet');
        u.Business_Unit__c = '';
        update u;

    }

}