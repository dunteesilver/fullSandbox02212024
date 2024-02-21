/*********************************************************************
* Description      : Test coverage for Pricing Portal PP_Update_Sales_Org.
* Coverage         : Classes(PP_Update_Sales_Org)
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
@isTest
public class PP_Update_Sales_Org_Test {
    @istest static void Test_User_Update(){
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

        

        System.runAs(u){
            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex/Arrow',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = FALSE
                //Division_10__c = TRUE
            );
            insert cu;
            system.debug('CU:' + cu);
        
            PageReference pageRef = new PageReference('/apex/PP_Update_Sales_Org?so=US');
            system.debug('User Edit Page' + pageRef);
            Test.setCurrentPage(pageRef);
            PP_Update_Sales_Org sotest = new PP_Update_Sales_Org();
            sotest.updateSalesOrg3();

            PageReference pageRef1 = new PageReference('/apex/PP_Update_Sales_Org?so=CA');
            system.debug('User Edit Page' + pageRef1);
            Test.setCurrentPage(pageRef1);
            PP_Update_Sales_Org sotest1 = new PP_Update_Sales_Org();
            sotest1.updateSalesOrg3();

            PageReference pageRef2 = new PageReference('/apex/PP_Update_Sales_Org?so=LA');
            system.debug('User Edit Page' + pageRef2);
            Test.setCurrentPage(pageRef2);
            PP_Update_Sales_Org sotest2 = new PP_Update_Sales_Org();
            sotest2.updateSalesOrg3();

            PageReference pageRef3 = new PageReference('/apex/PP_Update_Sales_Org?so=MX');
            system.debug('User Edit Page' + pageRef3);
            Test.setCurrentPage(pageRef3);
            PP_Update_Sales_Org sotest3 = new PP_Update_Sales_Org();
            sotest3.updateSalesOrg3();

            PageReference pageRef4 = new PageReference('/apex/PP_Update_Sales_Org?so=CL');
            system.debug('User Edit Page' + pageRef4);
            Test.setCurrentPage(pageRef4);
            PP_Update_Sales_Org sotest4 = new PP_Update_Sales_Org();
            sotest4.updateSalesOrg3();

            cu.Active_Region__c = 'US - Teleflex/Arrow';
            UPDATE cu;
            System.assertNotEquals('CL1010', cu.Active_Sales_Org_Key__c);
        }
    }

}