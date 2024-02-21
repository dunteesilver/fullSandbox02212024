/*********************************************************************
* Description      : Test coverage for account_Active_Flag_Batch process.
* Coverage         : Classes(account_Active_Flag_Batch)
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
@istest
public class account_Active_Flag_Batch_Test {

    static testmethod void flag_Test(){
        Account a = new Account(
            Name='Teleflex Test Account 123',
            SAP_Sold_To__c = '102059',
            ERP_Active__c = TRUE,
            Last_SAP_Update__c = System.now()
        );
        insert a;

        Test.startTest();
        String CRON_EXP = '0 0 0 15 3 ?';
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP,
                                       new account_Active_Flag_Batch());

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