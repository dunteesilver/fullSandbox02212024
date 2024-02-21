@isTest
public class AcctTeamBatchTest {
    static testMethod void testAcctTeamBatch(){
        
        Territory_Master__c tm = new Territory_Master__c(Name='900130', Territory_Number__c='900130');
        insert tm;
        
        Profile p = [SELECT Id FROM Profile WHERE Id='00eE0000000lT3QIAU'];
        User u = new User(Username='trey.flowers@teleflex.com.testing1',Email='trflowers@teleflex.com',Lastname='User', Firstname='Test', Alias='tuser',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', profileid=p.Id,timezonesidkey='America/New_York');
        insert u;
        
        Territory_User__c tu = new Territory_User__c(User__c=u.Id,Territory_Master__c=tm.Id);
        insert tu;
        
        Account a = new Account(Name='Test Account ', zBlock__c ='00', ERP_Active__c= true);
        insert a;
        
        Territory_Account__c ta = new Territory_Account__c(Account__c=a.Id, Territory_Master__c=tm.Id);
        insert ta;
        
        //AccountTeamMember check1 = [SELECT UserId FROM AccountTeamMember WHERE AccountId= :a.Id];
        //System.assertEquals(u.Id,check1.UserId);

        //clearAcctTeams clear = new clearAcctTeams();
        //ID batchprocessid1 = Database.executeBatch(clear);
        
        //delete check1;
        
        BatchAcctTeamAssignment assign = new BatchAcctTeamAssignment();
        ID batchprocessid2 = Database.executeBatch(assign);

    }
}