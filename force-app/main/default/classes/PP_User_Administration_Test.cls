/*********************************************************************
* Description      : Test coverage for Pricing Portal PP_User_Administration.
* Coverage         : Classes(PP_User_Administration,  PP_Build_Group_Future)
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
@isTest
public class PP_User_Administration_Test {

    @istest static void Test_UserAdmin(){


        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'uflex76',
            email='unit.test@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Adam',
            lastname='Franks',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p.Id,
            timezonesidkey='Europe/London',
            username='unit.test@unit.teleflex.com'
        );
        insert u;

        Group d10 = new Group(
            Name = 'Division 10'
        );
        insert d10;

        Group d20 = new Group(
            Name = 'Division 20'
        );
        insert d20;

        Group d30 = new Group(
            Name = 'Division 30'
        );
        insert d30;

        Group d40 = new Group(
            Name = 'Division 40'
        );
        insert d40;

        Group d50 = new Group(
            Name = 'Division 50'
        );
        insert d50;

        Group d60 = new Group(
            Name = 'Division 60'
        );
        insert d60;

        Group pp = new Group(
            Name = 'Pricing Portal'
        );
        insert pp;

        System.runAs(u){

            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex/Arrow',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Division_10__c = TRUE,
                Division_20__c = TRUE,
                Division_30__c = TRUE,
                Division_40__c = TRUE,
                Division_50__c = TRUE,
                Division_60__c = TRUE,
                CA_Division_10__c = TRUE,
                CA_Division_20__c = TRUE,
                CA_Division_30__c = TRUE,
                CA_Division_40__c = TRUE,
                CA_Division_50__c = TRUE,
                CA_Division_60__c = TRUE,
                LA_Division_10__c = TRUE,
                LA_Division_20__c = TRUE,
                LA_Division_30__c = TRUE,
                LA_Division_40__c = TRUE,
                LA_Division_50__c = TRUE,
                LA_Division_60__c = TRUE,
                MX_Division_10__c = TRUE,
                MX_Division_20__c = TRUE,
                MX_Division_30__c = TRUE,
                MX_Division_40__c = TRUE,
                MX_Division_50__c = TRUE,
                MX_Division_60__c = TRUE,
                CL_Division_10__c = TRUE,
                CL_Division_20__c = TRUE,
                CL_Division_30__c = TRUE,
                CL_Division_40__c = TRUE,
                CL_Division_50__c = TRUE,
                CL_Division_60__c = TRUE,
                AU_Division_10__c = TRUE,
                AU_Division_20__c = TRUE,
                AU_Division_30__c = TRUE,
                AU_Division_40__c = TRUE,
                AU_Division_50__c = TRUE,
                AU_Division_60__c = TRUE,
                NZ_Division_10__c = TRUE,
                NZ_Division_20__c = TRUE,
                NZ_Division_30__c = TRUE,
                NZ_Division_40__c = TRUE,
                NZ_Division_50__c = TRUE,
                NZ_Division_60__c = TRUE,
                BR_Division_10__c = TRUE,
                BR_Division_20__c = TRUE,
                BR_Division_30__c = TRUE,
                BR_Division_40__c = TRUE,
                BR_Division_50__c = TRUE,
                BR_Division_60__c = TRUE
            );
            Test.startTest();
            insert cu;
            Test.stopTest();
            system.debug('CU:' + cu);

            PageReference pageRef = new PageReference('/apex/PP_User_Administration?id=' + cu.Id);
            system.debug('User Edit Page' + pageRef);
            Test.setCurrentPage(pageRef);

            PP_User_Administration uatest = new PP_User_Administration();
            uatest.GroupCheck();

            PageReference pageRef2 = new PageReference('/apex/PP_User_Administration?id=' + cu.Id);
            system.debug('User Edit Page' + pageRef2);
            Test.setCurrentPage(pageRef2);

            uatest = new PP_User_Administration();
            uatest.getu();
            uatest.cancel();
            uatest.getulist1();
            uatest.getva();
            uatest.save();
            string uid = uatest.uid;

            Contract_User__c cuUpdate = new Contract_User__c(
                Id = cu.Id,
                Active_Region__c = 'US - Teleflex/Arrow',
                US_Material__c = FALSE,
                Pricing_Portal_Access__c = TRUE,
                Division_10__c = FALSE,
                Division_20__c = FALSE,
                Division_30__c = FALSE,
                Division_40__c = FALSE,
                Division_50__c = FALSE,
                Division_60__c = FALSE,
                CA_Division_10__c = FALSE,
                CA_Division_20__c = FALSE,
                CA_Division_30__c = FALSE,
                CA_Division_40__c = FALSE,
                CA_Division_50__c = FALSE,
                CA_Division_60__c = FALSE,
                LA_Division_10__c = FALSE,
                LA_Division_20__c = FALSE,
                LA_Division_30__c = FALSE,
                LA_Division_40__c = FALSE,
                LA_Division_50__c = FALSE,
                LA_Division_60__c = FALSE,
                MX_Division_10__c = FALSE,
                MX_Division_20__c = FALSE,
                MX_Division_30__c = FALSE,
                MX_Division_40__c = FALSE,
                MX_Division_50__c = FALSE,
                MX_Division_60__c = FALSE,
                CL_Division_10__c = FALSE,
                CL_Division_20__c = FALSE,
                CL_Division_30__c = FALSE,
                CL_Division_40__c = FALSE,
                CL_Division_50__c = FALSE,
                CL_Division_60__c = FALSE,
                AU_Division_10__c = FALSE,
                AU_Division_20__c = FALSE,
                AU_Division_30__c = FALSE,
                AU_Division_40__c = FALSE,
                AU_Division_50__c = FALSE,
                AU_Division_60__c = FALSE,
                NZ_Division_10__c = FALSE,
                NZ_Division_20__c = FALSE,
                NZ_Division_30__c = FALSE,
                NZ_Division_40__c = FALSE,
                NZ_Division_50__c = FALSE,
                NZ_Division_60__c = FALSE,
                BR_Division_10__c = FALSE,
                BR_Division_20__c = FALSE,
                BR_Division_30__c = FALSE,
                BR_Division_40__c = FALSE,
                BR_Division_50__c = FALSE,
                BR_Division_60__c = FALSE
            );
            update cuUpdate;
            //Test Catch exception in Constructor
            //DELETE cu;
            PageReference pageRef3 = new PageReference('/apex/PP_User_Administration?id=' + cuUpdate.Id);
            system.debug('User Edit Page' + pageRef3);
            Test.setCurrentPage(pageRef3);

            PP_User_Administration uatest1 = new PP_User_Administration();
        }




    }


}