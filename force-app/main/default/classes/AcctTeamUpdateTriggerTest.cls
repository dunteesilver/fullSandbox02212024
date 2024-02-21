@isTest
private class AcctTeamUpdateTriggerTest {
    
    static testMethod void testAcctTeamUpdate(){
        
        Account a = new Account(Name='Test Account ');
        insert a;
        
        Account a2 = new Account(Name='Test Account 2');
        insert a2;
        
        Integer count1 = 1;
        List<Account> lotsaccts = new List<Account>();
        
        while(count1 <= 200){
            Account newAcct = new Account(Name='Test Lots Account '+count1);
            lotsaccts.add(newAcct);
            count1++;
        }
        insert lotsaccts;
        
        Territory_Master__c tm = new Territory_Master__c(Name='900130', Territory_Number__c='900130');
        insert tm;
        
        Territory_Master__c tm2 = new Territory_Master__c(Name='900086', Territory_Number__c='900086');
        insert tm2;
        
        Territory_Master__c tm3 = new Territory_Master__c(Name='990096', Territory_Number__c='990096');
        insert tm3;
        
        List<Territory_Account__c> tl = new List<Territory_Account__c>();
        
        for(Account al:lotsaccts){
            tl.add(new Territory_Account__c(Account__c=al.Id, Territory_Master__c=tm3.Id));
        }
        insert tl;
        
        Territory_Account__c ta = new Territory_Account__c(Account__c=a.Id, Territory_Master__c=tm.Id);
        insert ta;
        
        Territory_Account__c ta2 = new Territory_Account__c(Account__c=a2.Id, Territory_Master__c=tm2.Id);
        insert ta2;
        
        Profile p = [SELECT Id FROM Profile WHERE Id='00eE0000000lT3QIAU'];
        User u = new User(Username='trey.flowers@teleflex.com.testing4654654',Email='trflowers@teleflex.com',Lastname='User', Firstname='Test', Alias='tuser',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', profileid=p.Id,timezonesidkey='America/New_York');
        insert u;
        
        Territory_User__c tu = new Territory_User__c(User__c=u.Id,Territory_Master__c=tm.Id);
        insert tu;
        
        //AccountTeamMember atm1 = new AccountTeamMember(AccountId=a.id, UserId=u.Id);
        //insert atm1;
        
        //AccountTeamMember atm2 = new AccountTeamMember(AccountId=a2.id, UserId=u.Id);
        //insert atm2;
        
        //AccountTeamMember check1 = [SELECT UserId FROM AccountTeamMember WHERE AccountId= :a.Id];
        //System.assertEquals(u.Id,check1.UserId);
        
        tu.Territory_Master__c = tm2.id;
        update tu;
        
        //AccountTeamMember check2 = [SELECT UserId FROM AccountTeamMember WHERE AccountId= :a2.Id];
        //System.assertEquals(u.Id,check2.UserId);
        
        //delete tu;
        
        
        
        //the following lines are for testing AcctTeamTerrMaster.trigger
        Territory_User__c tu2 = new Territory_User__c(User__c=u.Id,Territory_Master__c=tm2.Id);
        insert tu2;
        
        //delete tm2;
        
        //BATCH TEST
        Territory_User__c tu3 = new Territory_User__c(User__c=u.Id,Territory_Master__c=tm3.Id);
        insert tu3;
        
        //delete tu3;
        
        
    }
}