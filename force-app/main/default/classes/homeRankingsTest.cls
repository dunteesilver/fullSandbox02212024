@isTest
public class homeRankingsTest {
    static testMethod void homeRankingsTest(){
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(Username='trey.flowers@teleflex.com.testing12',Email='trflowers@teleflex.com',Lastname='User12', Firstname='Test12', Alias='tuser12',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', UserRoleID='00EE0000000d5PA', profileid=p.Id,timezonesidkey='America/New_York', Business_Unit__c='Vascular');
        insert u;
        
        User u2= new User(Username='trey.flowers@teleflex.com.testing19',Email='trflowers@teleflex.com',Lastname='User19', Firstname='Test19', Alias='tuser19',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', UserRoleID='00EE0000000d5Ol', profileid=p.Id,timezonesidkey='America/New_York', Business_Unit__c='Surgical');
        insert u2;
        
        User u3= new User(Username='trey.flowers@teleflex.com.testing18',Email='trflowers@teleflex.com',Lastname='User18', Firstname='Test18', Alias='tuser18',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', UserRoleID='00EE0000000d5PA', profileid=p.Id,timezonesidkey='America/New_York');
        insert u3;  
        
        User u4= new User(Username='trey.flowers@teleflex.com.testing14',Email='trflowers@teleflex.com',Lastname='User14', Firstname='Test14', Alias='tuser14',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', UserRoleID='00EE0000000d5PA', profileid=p.Id,timezonesidkey='America/New_York');
        insert u4;
        
        User u5= new User(Username='trey.flowers@teleflex.com.testing15',Email='trflowers@teleflex.com',Lastname='User15', Firstname='Test15', Alias='tuser15',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', UserRoleID='00EE0000000d5PA', profileid=p.Id,timezonesidkey='America/New_York');
        insert u5; 
        User u6= new User(Username='trey.flowers@teleflex.com.testing16',Email='trflowers@teleflex.com',Lastname='User16', Firstname='Test16', Alias='tuser16',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', UserRoleID='00EE0000000d5PA', profileid=p.Id,timezonesidkey='America/New_York');
        insert u6; 
        User u7= new User(Username='trey.flowers@teleflex.com.testing17',Email='trflowers@teleflex.com',Lastname='User17', Firstname='Test17', Alias='tuser17',emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US', UserRoleID='00EE0000000d5PA', profileid=p.Id,timezonesidkey='America/New_York');
        insert u7; 
        
        system.runas(u){
            Territory_Master__c tm = new Territory_Master__c(Name='900130', Territory_Number__c='900130');
            insert tm;
            
            Quota__c qu = new Quota__c(Territory_Master__c=tm.Id,Rank_Current_Month__c=1);
            insert qu;
            
            
            
            Territory_User__c tu = new Territory_User__c(User__c=u.Id,Territory_Master__c=tm.Id);
            insert tu;
            
            //AccountTeamMember check1 = [SELECT UserId FROM AccountTeamMember WHERE AccountId= :a.Id];
            //System.assertEquals(u.Id,check1.UserId);
            
            homeRankings hr = new homeRankings();
            system.debug(hr.getWonOppValue());
            system.debug(hr.getWonOppSize());
            system.debug(hr.getWonOppRank());
            system.debug(hr.getVP());
            system.debug(hr.getTotalOppValue());
            system.debug(hr.getTotalConvertedLeads());
            system.debug(hr.getRookiesSize());
            system.debug(hr.getRookieRank());
            system.debug(hr.getRookie());
            system.debug(hr.getRanking());
            system.debug(hr.getQuotaName());
            system.debug(hr.getQuotaId());
            system.debug(hr.getPctQuota());
            system.debug(hr.getManager());
            system.debug(hr.getEffectiveMonth());
            system.debug(hr.getConvertedLeadRank());
            system.debug(hr.getConvertedLeadCount());
        }
        
        system.runas(u2){
            Territory_Master__c tm = new Territory_Master__c(Name='900130', Territory_Number__c='900130');
            insert tm;
            Territory_Master__c tm1 = new Territory_Master__c(Name='900131', Territory_Number__c='900131');
            insert tm1;
            Territory_Master__c tm2 = new Territory_Master__c(Name='900132', Territory_Number__c='900132');
            insert tm2;
            Territory_Master__c tm3 = new Territory_Master__c(Name='900133', Territory_Number__c='900133');
            insert tm3;
            Territory_Master__c tm4 = new Territory_Master__c(Name='900134', Territory_Number__c='900134');
            insert tm4;
            Territory_Master__c tm5 = new Territory_Master__c(Name='900135', Territory_Number__c='900135');
            insert tm5;
            Territory_Master__c tm6 = new Territory_Master__c(Name='900136', Territory_Number__c='900136');
            insert tm6;
            
            Territory_User__c tu = new Territory_User__c(User__c=u.Id,Territory_Master__c=tm.Id);
            insert tu;
            Territory_User__c tu1 = new Territory_User__c(User__c=u2.Id,Territory_Master__c=tm1.Id);
            insert tu1;
            Territory_User__c tu2 = new Territory_User__c(User__c=u3.Id,Territory_Master__c=tm2.Id);
            insert tu2;
            Territory_User__c tu3 = new Territory_User__c(User__c=u4.Id,Territory_Master__c=tm3.Id);
            insert tu3;
            Territory_User__c tu4 = new Territory_User__c(User__c=u5.Id,Territory_Master__c=tm4.Id,Regional_Manager__c=true);
            insert tu4;
            Territory_User__c tu5 = new Territory_User__c(User__c=u6.Id,Territory_Master__c=tm5.Id,Regional_Manager__c=true);
            insert tu5;
            Territory_User__c tu6 = new Territory_User__c(User__c=u7.Id,Territory_Master__c=tm6.Id,Regional_Manager__c=true);
            insert tu6;
            
            Quota__c qu = new Quota__c(Territory_Master__c=tm.Id,Rank_Current_Month__c=1);
            insert qu;
            Quota__c qu1 = new Quota__c(Territory_Master__c=tm1.Id,Rank_Current_Month__c=2);
            insert qu1;
            Quota__c qu2 = new Quota__c(Territory_Master__c=tm2.Id,Rank_Current_Month__c=3);
            insert qu2;
            Quota__c qu3 = new Quota__c(Territory_Master__c=tm3.Id,Rank_Current_Month__c=4);
            insert qu3;
            Quota__c qu4 = new Quota__c(Territory_Master__c=tm4.Id,Rank_Current_Month__c=5);
            insert qu4;
            Quota__c qu5 = new Quota__c(Territory_Master__c=tm5.Id,Rank_Current_Month__c=6);
            insert qu5;
            Quota__c qu6 = new Quota__c(Territory_Master__c=tm6.Id,Rank_Current_Month__c=7);
            insert qu6;
            
            homeRankings hr2 = new homeRankings();
            system.debug(hr2.getRank1idVP());
            system.debug(hr2.getRank1VP());
            system.debug(hr2.getRank2idVP());
            system.debug(hr2.getRank2VP());
            system.debug(hr2.getRank3idVP());
            system.debug(hr2.getRank3VP());
            system.debug(hr2.getRank2pctVP());
            system.debug(hr2.getRank1pctVP());
            system.debug(hr2.getRank3pctVP());
        }
        
    }
}