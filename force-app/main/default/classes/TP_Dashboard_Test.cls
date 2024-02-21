@isTest
public class TP_Dashboard_Test {
    
 public static Id PreHospitalRecTypeId = Schema.getGlobalDescribe().get('Target_Profile__c').getDescribe().getRecordTypeInfosByName().get('Pre-Hospital').getRecordTypeId();
        
    @testSetup
    static void createData() {
        Account acc = new Account();
        acc.Name = 'Testacc';
        insert acc;
        
      
        List<Target_Profile__c> tps = new List<Target_Profile__c>();
        Target_Profile__c tp = new Target_Profile__c();
        tp.RecordTypeId = PreHospitalRecTypeId;
        tp.Account__c = acc.Id;
        tps.add(tp);
        insert tps;
    }//end of createData
    
    //start testing tpdashboards
    @isTest
    static void test_tpdashboard() {
        TP_Dashboard Dashboard=new TP_Dashboard();
        TPRecordsController Records=new TPRecordsController();
        //updateAccountType Record= new updateAccountType();
    }
}