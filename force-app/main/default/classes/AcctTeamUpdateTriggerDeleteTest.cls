@isTest
private class AcctTeamUpdateTriggerDeleteTest {
    
    static testMethod void testAcctTeamDelete(){
        
        Integer count1 = 1;
        List<Account> lotsaccts = new List<Account>();
        
        while(count1 <= 200){
            Account newAcct = new Account(Name='Test Lots Account '+count1);
            lotsaccts.add(newAcct);
            count1++;
        }
        insert lotsaccts;
        
        Territory_Master__c tm3 = new Territory_Master__c(Name='990096', Territory_Number__c='990096');
        insert tm3;
        
        List<Territory_Account__c> tl = new List<Territory_Account__c>();
        
        for(Account al:lotsaccts){
            tl.add(new Territory_Account__c(Account__c=al.Id, Territory_Master__c=tm3.Id));
        }
        insert tl;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Username='trey.flowers@teleflex.com.testing4654654',Email='trflowers@teleflex.com',Lastname='User', Firstname='Test', Alias='tuser',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', profileid=p.Id,timezonesidkey='America/New_York');
        insert u;
        
        List<AccountTeamMember> atmlots = new List<AccountTeamMember>();
        
        for(Account a1a: lotsaccts){
            AccountTeamMember atm1 = new AccountTeamMember(AccountId=a1a.id, UserId=u.Id);
            atmlots.add(atm1);
        }
        insert atmlots;

        Database.executeBatch(new BatchTerrUserTriggerDelete());
        
        BatchTerrUserTriggerDelete delTerrs = new BatchTerrUserTriggerDelete();
        delTerrs.oldTerritory=tm3.Id;
        delTerrs.oldUser=u.Id;
        ID batchprocessid = Database.executeBatch(delTerrs);
        
        
    }
}