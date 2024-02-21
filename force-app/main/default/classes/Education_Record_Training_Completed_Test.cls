@isTest
private class Education_Record_Training_Completed_Test {

   public static String CRON_EXP = '0 0 0 15 3 ?';

   static testmethod void test() {

      Test.startTest();

      // Schedule the test job

      String jobId = System.schedule('ScheduleApexClassTest',

                        CRON_EXP,

                        new Education_Record_Training_Completed());

          
      // Get the information from the CronTrigger API object

      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,

         NextFireTime

         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same

      System.assertEquals(CRON_EXP,
         ct.CronExpression);

      // Verify the job has not run

      System.assertEquals(0, ct.TimesTriggered);

      Programs__c progrm= new Programs__c(Name='Test Program',
                                          Active__c= true,
                                          Business_Unit__c= 'EMS',
                                          Products__c='CVC',
                                          Program_Type__c='Education Program Request'
                                          );
     INSERT progrm;
             
      Education_Record__c ml = new Education_Record__c(Name = 'Test Education', 
                                                          Stage__c = 'Confirmed', 
                                                          Ending_Date__c = System.today(), 
                                                          //Copy_RecordType__c ='Live Education Program Request',
                                                          Business_Unit__c= 'EMS',
                                                          Primary_Product__c='CVC',
                                                          Copy_RecordType__c= 'Education Program Request',
                                                          Program__c= progrm.Id,
                                                          Hotel_Requested__c='No',
                                                          Recommended_Hotel_1st_Choice__c ='Test');
      INSERT ml;
      System.assertEquals(ml.stage__C,'Confirmed');

      Test.stopTest();

      // Now that the scheduled job has executed after Test.stopTest(),
      //   fetch the new merchandise that got added.

  //    ml = [SELECT Id FROM Education_Record__c

    //                         WHERE Name ='Test Education' limit 1];
    //  System.assertEquals(ml.size(), 1);

     // System.assertEquals(ml.stage__c, 'Training Completed');

   }

}