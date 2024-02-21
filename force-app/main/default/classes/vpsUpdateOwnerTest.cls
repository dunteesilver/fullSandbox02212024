/*********************************************************************
* Description      : Test coverage for vpsUpdateOwner VPS process.
* Coverage         : Triggers(vpsUpdateOwner)
* Author(s)        : Dun Silver
**********************************************************************/
@isTest
public class vpsUpdateOwnerTest {

    static testMethod void TestvpsUpdateOwner(){
       list<User> users = new list<User>();
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs (thisUser) {
                Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
                for (Integer i=0;i<10;i++) {
                    //create instance of a user
                    User u = new User();
                    u.Alias = 'tUsr'+i;
                    u.Email = 'testUser'+i+'@teleflex.com';
                    u.EmailEncodingKey = 'UTF-8';
                    u.LastName = 'TestUser' + i;
                    u.LanguageLocaleKey = 'en_US';
                    u.LocaleSidKey = 'en_US';
                    u.ProfileId = p.id;
                    u.UserRoleId = '00EE0000000cNk8';
                    u.TimeZoneSidKey = 'America/Los_Angeles';
                    u.Username = 'myTestUser'+i+'@teleflex.com';
                    //add new users to list
                    users.add(u);
                }
                //insert new users from list
                insert users;
                system.assertEquals(10,users.size());
           }

        //list of demo request
        list<Request_Demo_Unit__c> reqRep = new list<Request_Demo_Unit__c>();

        for(integer j=0;j<10;j++){
            //instance of request
            Request_Demo_Unit__c  r = new Request_Demo_Unit__c();
            r.Trainings__c = 'Completed Product Training';
            //r.Agree__c = true;
            //r.Status__c = 'Approved';
            r.User__c = users[j].id;
            r.OwnerId = users[j].id;
            //add request to list of request
            reqRep.add(r);
        }

        //insert new request
        insert reqRep;
        system.assertEquals(10,reqRep.size());

        for(integer a=0; a < reqRep.size(); a++){
            reqRep[a].status__c = 'Approved';
            reqRep[a].Agree__c = true;
        }
        update reqRep;
Account acct = new Account(name = 'vpsconsoletestaccount');
            insert (acct);
        //list of demo request
        list<VPS_Console__c> vps = new list<VPS_Console__c>();

        for(integer k=0;k<10;k++){
            //instance of request
            VPS_Console__c  v = new VPS_Console__c();
            v.Approved_Rep__c = reqRep[k].id;
            v.Unit_Status__c = 'With Rep';
            v.Name = 'GB4' +k+k+k+k;
            v.OwnerId = users[k].id;
            v.account__c= acct.id;
            //add request to list of request
            vps.add(v);
        }

        //insert new request
        insert vps;
        system.assertEquals(10,vps.size());

    }

}