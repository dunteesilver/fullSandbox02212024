/*********************************************************************
* Description      : Test coverage for dupeRep VPS process.
* Coverage         : Triggers(dupeRep)
* Author(s)        : Dun Silver
**********************************************************************/
@isTest
public class dupeRepTest {

    static testMethod void TestdupeRep(){
       list<User> users = new list<User>();
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs (thisUser) {
                Profile p = [SELECT Id FROM Profile WHERE Name='system administrator'];
                for (Integer i=0;i<10;i++) {
                    //create instance of a user
                    User u = new User();
                    u.Alias = 'tUsr'+i;
                    u.Email = 'testUser'+i+'@teleflex.com';
                    u.EmailEncodingKey = 'UTF-8';
                    u.LastName = 'TestUser';
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
            //r.User__c = users[j].id;
            r.OwnerId = users[j].id;
            //add request to list of request
            reqRep.add(r);
        }

        //attempt rep insert without User field
        try{
            insert reqRep;
        }
        catch(exception e){
            system.debug('exception caught in dupeRep Trigger: '+e.getMessage());
        }
        system.assertEquals(10,reqRep.size());

        //new list to insert
        list<Request_Demo_Unit__c> reqRep1 = new list<Request_Demo_Unit__c>();
        //loop thru rep list and add user
        for(integer a=0;a<10;a++){
            //instance of request
            Request_Demo_Unit__c  r1 = new Request_Demo_Unit__c();
            r1.Trainings__c = 'Completed Product Training';
            r1.User__c = users[a].id;
            r1.OwnerId = users[a].id;
            //add request to list of request
            reqRep1.add(r1);
        }

        //insert new request
        insert reqRep1;
        system.assertEquals(10,reqRep.size());

        test.startTest();
        //list to hold dupes
        List<Request_Demo_Unit__c> noRep = new List<Request_Demo_Unit__c>();
        for(integer l=0;l<10;l++){
            Request_Demo_Unit__c req1 = new Request_Demo_Unit__c();
            req1.Trainings__c = 'Completed Product Training';
            req1.User__c = users[l].id;
            req1.OwnerId = users[l].id;
            //add request to list of request
            noRep.add(req1);
        }

        try{
            insert noRep;
        }
        catch(exception e){
            system.debug('exception caught Trigger: '+e.getMessage());
        }
        system.assertEquals(10,noRep.size());
        test.stopTest();
    }

}