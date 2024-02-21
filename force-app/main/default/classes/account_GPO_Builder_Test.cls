@isTest
public class account_GPO_Builder_Test {
    public static String CRON_EXP = '0 0 0 15 3 ?';

    static testmethod void GPO_Builder_Test(){
        
        Account a = new Account(
            Name='Teleflex Test Account 123',
            SAP_Sold_To__c = '102059'
        );
        insert a;
        
        Account a2 = new Account(
            Name='Teleflex Test Account 456',
            SAP_Sold_To__c = '102058',
            Main_GPO__c = 'Test Removal #1',
            Secondary_GPO__c = 'Test Removal #2'
        );
        insert a2;

        //Contract Header Test Records
        Contract_Header__c ch = new Contract_Header__c(
            Name = '50009999',
            Description__c = 'Teleflex Test Contract',
            Agreement_Number__c = 'TestId',
            GPO_Contract_Ref__c = 'TestRef',
            Valid_From__c = System.Today().addMonths(-1),
            Valid_To__c = System.Today().addMonths(1),
            Owner_Name__c = 'Novation',
            Owner__c = 'GPO-008'
        );
        insert ch;
        
        Contract_Customer__c cc = new Contract_Customer__c(
            Account__c = a.Id,
            Agreement__c = ch.Id,
            Name = '50009999-TEST',
            SAP_Code__c= '102059',
            Condition__c = 'XPRI'
        );
        insert cc;
        
        Contract_Customer__c cc2 = new Contract_Customer__c(
            Account__c = a.Id,
            Agreement__c = ch.Id,
            Name = '50009999-TEST',
            SAP_Code__c= '102059',
            Condition__c = 'XSEC'
        );
        insert cc2;
        
        Test.startTest();

        string query = 'SELECT Id, SAP_Sold_To__c FROM Account WHERE Id = \'' + a.Id + '\'';
        account_GPO_Builder buildGPO = new account_GPO_Builder();
        buildGPO.query = query;
        Database.executeBatch(buildGPO);
        
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP, 
                                       new account_GPO_Builder_Scheduler());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, 
                            ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
        
    }
}