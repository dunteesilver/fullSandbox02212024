@istest
public class painProfilesBatchTest {
    @testSetup static void setup() {
        Account acc = new Account();
        acc.Name = 'Testacc';
        insert acc;
      // Create  test Pain Profiles
      List<Pain_Profile__c> painLst  = new List<pain_profile__c>();
        for(Integer i=0;i<2;i++) {
                painLst.add(new pain_Profile__c(Account__c = acc.ID));
            }
        for(Integer i=0;i<2;i++) {
                painLst.add(new pain_Profile__c(Account__c = acc.ID));
            } 
         for(Integer i=0;i<2;i++) {
                painLst.add(new pain_Profile__c(Account__c = acc.ID));
            } 
        
         system.debug('Pain Profiles list' + painLst.size()); 

        insert painLst;
    }
        
@isTest static void testBatch() {
   Test.startTest();
     PainProfilesBatch batch = new  PainProfilesBatch ();
        
        database.executebatch(batch,200);  
    
    String sch='0 0 0 ? * * *';
		String jobId = System.schedule('PainProfilesBatchUpdate Schedule', sch , batch);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals(0, ct.TimesTriggered);
    
    Test.stopTest();
        List<Pain_Profile__c> painLst1 = [SELECT Id,Account__c from Pain_Profile__c];
        system.assertEquals(6, painLst1.size());
    }
    }