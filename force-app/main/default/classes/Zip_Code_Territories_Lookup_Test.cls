@isTest
public class Zip_Code_Territories_Lookup_Test {
    static testmethod void myUnitTest() {
      
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
            UserName='TeleflexTESTER@teleflex.test.com'
        );
        insert u;
        System.debug('Insert User-->' + u);
        
        Territory_Master__c tm = new Territory_Master__c(
            Name = '800123',
            Territory_Number__c = '800123',
            Business_Unit__c = 'EMS'
        );
        insert tm;
        System.debug('Insert Territory Master-->' + tm);
        
        Territory_User__c tu = new Territory_User__c(
            Territory_Master__c = tm.Id,
            User__c = u.id
        );
        
        insert tu;
        System.debug('Insert Territory User-->' + tu);
                
        Zip_Code_Territories__c zipt = new Zip_Code_Territories__c(
            Name='Test',
            Alternate_Care__c ='800123', 
            Anesthesia__c ='800123', 
            EMS__c='800123', 
            IA__c='800123',
            Respiratory__c='800123',
            Surgical_Instruments__c='800123', 
            Surgical_Disposables__c='800123',
            Urology__c='800123',
            Vascular__c='800123'
        );
        Insert zipt;
    Test.startTest();
        PageReference pageRef = new PageReference('/apex/Zip_Code_Territories_Section');
    	Test.setCurrentPage(pageRef);
        Zip_Code_Territories_Lookup testcontroller = new Zip_Code_Territories_Lookup (new ApexPages.StandardController(zipt));
        testcontroller.getAlt_Care();
        testcontroller.getAnesthesia();
        testcontroller.getEMS();
        testcontroller.getRespiratory();
        testcontroller.getIA();
        testcontroller.getSurg_Inst();
        testcontroller.getSurg_Disp();
        testcontroller.getUrology();
        testcontroller.getVascular(); 
    Test.stopTest();   
	}
}