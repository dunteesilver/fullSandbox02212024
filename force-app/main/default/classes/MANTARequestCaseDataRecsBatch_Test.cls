@IsTest
public class MANTARequestCaseDataRecsBatch_Test {
    
    
    @isTest static void testBatch() {
        
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
        
        Account acc = new Account();
        acc.Name = 'CXTestAcc';
        acc.SAP_Sold_To__c = '123456';
        acc.SAP_Code__c='123456';
        acc.Territory_Key__c='123456;234567';
        insert acc;
        
        MANTA_Proctorship_Request__c mantaProcReqObj = new MANTA_Proctorship_Request__c();
        mantaProcReqObj.Case_Date__c = System.Today() - 10;
        mantaProcReqObj.Case_Initiator__c = u.Id;
        mantaProcReqObj.Proctor__c = u.Id;
        mantaProcReqObj.Case_Type__c = 'TVAR';
        mantaProcReqObj.Estimated_of_Cases__c = 3.0;
        mantaProcReqObj.Hospital__c = acc.Id;
        mantaProcReqObj.Status__c = 'Accepted';
        insert mantaProcReqObj;
        
   Test.startTest();
     MANTARequestCaseDataRecsBatch batch = new  MANTARequestCaseDataRecsBatch();
        database.executebatch(batch,200);  
    
    String sch='0 0 0 ? * * *';
		String jobId = System.schedule('MANTARequestCaseDataRecsBatchSchdl Schedule', sch , batch);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals(0, ct.TimesTriggered);
    
    Test.stopTest();
        List<MANTA_Proctorship_Request__c> mntaProcReqObj = [SELECT Id from MANTA_Proctorship_Request__c];
        system.assertEquals(1, mntaProcReqObj.size());
    }
    
 
}