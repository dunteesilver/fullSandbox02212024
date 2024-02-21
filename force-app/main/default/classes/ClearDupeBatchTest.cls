@isTest
public class ClearDupeBatchTest {
    static testMethod void testClearDupeBatch(){
        
        Dupe_Account__c dupe = new Dupe_Account__c(Name='9876543');
        insert dupe;
        
        Account a = new Account(Name='Test Account 1');
        insert a;
        
        Account b = new Account(Name='Test Account 2');
        insert b;
        
        
        Territory_Master__c tm = new Territory_Master__c(Name='900130', Territory_Number__c='900130');
        insert tm;
        
       
        BatchClearDupes assign = new BatchClearDupes();
        ID batchprocessid2 = Database.executeBatch(assign);

    }
}