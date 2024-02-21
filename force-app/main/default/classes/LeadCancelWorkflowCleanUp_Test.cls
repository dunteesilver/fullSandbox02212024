@IsTest
public class LeadCancelWorkflowCleanUp_Test {
    @testSetup static void setup() {
            // Create common test leads
            List<Lead> testLeads = new List<Lead>();
            for(Integer i=0;i<2;i++) {
                testLeads.add(new Lead(LastName = 'TestLead+'+i, Company = 'TestComp'+i, Cancel_Workflow__c = true, Status = 'Convert', Preferred_language__c ='English (American)', Position_Job_Title__c ='Assistant', Credentials__c='CEO'));
            }
            for(Integer i=0;i<2;i++) {
                testLeads.add(new Lead(LastName = 'TestLead-'+i, Company = 'TestComp'+i, Cancel_Workflow__c = true, Status = 'New'));
            }
            for(Integer i=0;i<2;i++) {
                testLeads.add(new Lead(LastName = 'TestLead-'+i, Company = 'TestComp'+i, Cancel_Workflow__c = false, Status = 'Convert', Preferred_language__c ='English (American)', Position_Job_Title__c ='Assistant', Credentials__c='CEO'));
            }
            insert testLeads;        
        }
    @isTest static void testBatch() {
        Test.startTest();
        
        LeadCancelWorkflowCleanUp batchSch=new LeadCancelWorkflowCleanUp();
        Database.executebatch(batchSch,200);
        
        String sch='0 0 0 ? * * *';
        String jobId = System.schedule('LeadCancelWorkflowCleanUp Schedule', sch , batchSch);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        List<Lead> testLeads = [SELECT Id FROM Lead WHERE cancel_workflow__c = true AND isConverted = false AND status = 'Convert'];
        system.assertEquals(0, testLeads.size());
    }

}