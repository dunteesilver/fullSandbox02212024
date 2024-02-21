@isTest
public class take5Test {
    static testMethod void take5Test() {

        Profile p = [select id from profile where name='System Administrator'];
        User tu1 = new User(Username='testing0@teleflex.com.testuser',Email='testuser@teleflex.com',Business_Unit__c = 'Anesthesia/Respiratory', Lastname='User', Firstname='Test', Alias='tuser1',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', profileid=p.Id,timezonesidkey='America/New_York');

        Date todaysDate = date.today();
        Take5__c t5 = new Take5__c(Qualified_Business_Unit__c='Anesthesia/Respiratory',Eligible_Start__c=todaysDate,Eligible_Stop__c=todaysDate);
        insert t5;

        Note newNote = new Note(Title='test',Body='http://www.google.com',ParentId=t5.Id);
        insert newNote;

        system.runAs(tu1){
            take5AssetController t5ac = new take5AssetController();
            t5ac.getNotes();

        }
    }
}