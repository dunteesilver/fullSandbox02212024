/*********************************************************************
* Description      : Test coverage for demoAssigned VPS process.
* Coverage         : Triggers(demoAssigned)
* Author(s)        : Dun Silver
**********************************************************************/
@isTest
public class demoAssignedTest {

    static testMethod void TestdemoAssigned(){
        //create User test records
        list<User> users = new list<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            for (Integer i=0;i<10;i++) {
                User u1 = new User(alias = 'tUsr'+i, email='testUser'+i+'@teleflex.com',
                                   emailencodingkey='UTF-8', lastname='TestUser',
                                   languagelocalekey='en_US',
                                   localesidkey='en_US', profileid = p2.Id,
                                   UserRoleId='00EE0000000cNk8',
                                   timezonesidkey='America/New_York',
                                   username='myTestUser'+i+'@teleflex.com');

                users.add(u1);
            }

            insert users;
            system.assertEquals(10,users.size());
            //}// Old

            //create Request Demo Unit test records
            list<Request_Demo_Unit__c> RequestDemoUnitList = new list<Request_Demo_Unit__c>();
            for(integer j=0;j<10;j++){
                Request_Demo_Unit__c  RequestDemo = new Request_Demo_Unit__c(
                    Trainings__c = 'Completed Product Training',
                    //Agree__c = true,
                    //Status__c = 'Approved',
                    User__c = users[j].id,
                    OwnerId = users[j].id
                );
                RequestDemoUnitList.add(RequestDemo);
            }

            insert RequestDemoUnitList;
            system.assertEquals(10,RequestDemoUnitList.size());

            for(integer a=0; a < RequestDemoUnitList.size(); a++){
                RequestDemoUnitList[a].Status__c = 'Approved';
                RequestDemoUnitList[a].Agree__c = true;
            }
            update RequestDemoUnitList;
  Account acct = new Account(name = 'vpsconsoletestaccount');
            insert (acct);
            //create VPS Console test records
            list<VPS_Console__c> VPSconsoles = new list<VPS_Console__c>();
            for(integer k=0;k<10;k++){
                VPS_Console__c VPScon= new VPS_Console__c(
                    CurrencyIsoCode = 'USD',
                    Name = 'GB4'+k+k+k+k,
                    Approved_Rep__c = RequestDemoUnitList[k].id,
                    Account__c= acct.id,
                    Unit_Status__c = 'In Progress',
                    Part_Number__c = '123123123'
                );
                VPSconsoles.add(VPScon);
            }

            insert VPSconsoles;
            system.assertEquals(10,VPSconsoles.size());

            //create test Account records
            list<Account> acc = new list<Account>();
            for(integer n=0;n<10;n++){
                Account a = new Account(Name='Test '+n);
                acc.add(a);
            }
            insert acc;
            System.assertEquals(10,acc.size());

            list<Contact> con = new list<Contact>();
            for(integer n=0;n<10;n++){
                Contact c = new Contact(
                    FirstName ='Test',
                    email = 'abc@123.com',   
                    lastname='second' + n,
                    Position_Job_Title__c='Administrator',
                    Credentials__c='RN',
                    Preferred_language__c='English (American)',
                    AccountId = acc[n].id
                );
                con.add(c);
            }
            insert con;

            //create test Opportunity records
            list<Opportunity> opp = new list<Opportunity>();
            for(integer p=0;p<10;p++){
                Opportunity o = new Opportunity();
                o.Name = 'Test Opp '+ p;
                o.Account = acc[p];
                o.Type = 'New Business';
                o.LeadSource = 'Self Generated';
                // o.Current_Status__c = 'test ' + p;
                o.Description = 'test ' + p;
                o.CloseDate = date.today() + 1;
                o.NextStep = 'test ' + p;
                o.Next_Step_Date__c = date.today();
                o.Product_Family__c = 'Respiratory';
                o.Product_of_Interest__c = 'Neptune';
                o.Business_Unit__c='Surgical Disposables';
                o.Business_Unit_GPL__c='Anesthesia';
                o.Product_Family_GPL__c='Airway';
                o.Product_of_Interest_GPL__c='TruLite';
                //o.RecordTypeId = '01244000000NNcz';
                o.StageName = 'Educate';
                o.Primary_Contact__c = con[p].id;
                opp.add(o);
            }
            insert opp;
            System.assertEquals(10,opp.size());
            //edited code end

            //create test Demo records
            List<Demo__c> DemoList = new List<Demo__c>();
            for(integer l=0;l<10;l++){
                Demo__c demo = new Demo__c(
                    Name = 'Test Demo'+l,
                    VPS_Console__c = VPSconsoles[l].id,
                    Status__c = 'In Progress',
                    OwnerId = users[l].id,
                    Start_Date__c = date.today() + l,
                    End_Date__c = date.today() + l
                );
                DemoList.add(demo);
            }

            insert DemoList;
            system.assertEquals(10,DemoList.size());

            //create more Demo test records
            test.startTest();
            List<Demo__c> DemoList1 = new List<Demo__c>();
            for(integer m=0;m<10;m++){
                Demo__c demo = new Demo__c(
                    Name = 'Test Demo'+m,
                    VPS_Console__c = VPSconsoles[m].id,
                    Status__c = 'In Progress',
                    OwnerId = users[m].id,
                    Start_Date__c = date.today() + m,
                    End_Date__c = date.today() + m
                );
                DemoList1.add(demo);
            }

            //try to insert duplicate test Demo records
            try{
                insert DemoList1;
            }
            catch(exception e){
                system.debug('exception caught in openDemoCheck Trigger: '+e.getMessage());
            }
            system.assertEquals(10,DemoList1.size());
            test.stoptest();

        }
    }

}