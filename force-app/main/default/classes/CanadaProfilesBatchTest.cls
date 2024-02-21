@istest
public class CanadaProfilesBatchTest {
    @testSetup static void setup() {
        Account acc = new Account();
        acc.Name = 'Testacc';
        insert acc;
      // Create  test Pain Profiles
      List<Canada_Profile__c> canLst  = new List<Canada_Profile__c>();
        for(Integer i=0;i<2;i++) {
                canLst.add(new Canada_Profile__c(Account__c = acc.ID));
            }
        for(Integer i=0;i<2;i++) {
                canLst.add(new Canada_Profile__c(Account__c = acc.ID));
            } 
         for(Integer i=0;i<2;i++) {
                canLst.add(new Canada_Profile__c(Account__c = acc.ID));
            } 
        insert canLst;
    }
        
@isTest static void testBatch() {
   Test.startTest();
     CanadaProfilesBatch batch = new  CanadaProfilesBatch ();
        
        database.executebatch(batch,100);
    
    String sch='0 0 0 ? * * *';
		String jobId = System.schedule('PainProfilesBatchUpdate Schedule', sch , batch);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals(0, ct.TimesTriggered);
    
    Test.stopTest();
        List<Canada_Profile__c> canLst1 = [SELECT Id,Account__c from Canada_Profile__c];
        system.assertEquals(6, canLst1.size());
    }
    }