@isTest
public class EmailLabattendeesTest {
    @testSetup
    public static Void CreateData() {
        Lab__c lab = new Lab__c(
            Name = 'UNC Lab',
            Lab_Key__c = 'UNC Lab'
        );
        insert lab;
        Lab_Participant__c lp = new Lab_Participant__c(
            Name = 'test',
            Lab__c = lab.Id,
            Lab_Time__c = '7pm',
            Lab_Time_2__c = '7:35pm',
            Email__c = '123321@1232222.com',
            Mailing_Zip_Code__c = '27614',
            Address__c = '123 Mainstreet Raleigh, NC 98989 US',
            Affiliation__c = 'EMS',
            Lab_Unique_ID__c = '123123',
            Attended__c = true,
            Attended_EZIO__c = true,
            Attended_Hemorrhage__c= true,
            Atteneded_Interventional__c= true
        );
        insert lp;
    }
    
    @isTest
    static void test_method() {
        Lab_Participant__c participant = [SELECT Id, Email__c
                                          FROM Lab_Participant__c];
        Test.startTest();
        EmailLabAttendeesController.sendPdf(new List<Id>{participant.Id});
        Test.stopTest();
    }
}