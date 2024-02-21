/*********************************************************************
* Description      : Test coverage for Pricing Portal Select Account page.
* Coverage         : Classes(PP_SelectAccount)
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
@isTest
public class PP_SelectAccount_Test {
    
      @testSetup static void setUpData() {
          //List<Contract_User__c> ppUsers = new List<Contract_User__c>();
          //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
          //Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(UserInfo.getUserName(), UserInfo.getUserId(), 'US - Teleflex', 'US6010', 4);
          
      }

    //start test for constructor code
    static testmethod void PP_SelectAccount_UnitTest(){
        User usUserMan = testDataFactoryPP.createUser('USman05', 'User05', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US05', 'User05', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US06', 'User06', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        usUser.ManagerId = usUserMan.Id;
        update usUser;

		System.runAs(usUser1){  
            User userinfo = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
            Contract_User__c cUser = testDataFactoryPP.createPricingPortalUser(userinfo.Name, userinfo.Id, 'US - Teleflex', 'US6010', 4);
            Insert cUser;
            
            //create Account test record
            Account accTest = new Account(
                Name='PP Test Account TFX',
                SAP_Sold_To__c = '102059',
                Description = 'AA-10511-1',
                Customer_Group__c='17',
                Customer_Group_Name__c='Hosp',
                ShippingStreet='Test Rd',
                ShippingCity='Raleigh',
                ShippingPostalCode='27610',
                ShippingState='NC',
                Account_Group__c = 'Z001'
            );
            insert accTest;
            
            PageReference pageRef2 = new PageReference('/apex/PP_SelectAccount?gs=off&cid=' + accTest.SAP_Sold_To__c);
            system.debug('User Edit Page' + pageRef2);
            Test.setCurrentPage(pageRef2);
            
            PP_SelectAccount sa0 = new PP_SelectAccount();
            sa0.getURL();
            sa0.getAccs();
            sa0.getPqs();
            sa0.getSearch();
            
            PageReference sa = Page.PP_SelectAccount;
            sa.getParameters().put('cid',accTest.SAP_Sold_To__c);
            Test.setCurrentPage(sa);
            
            PP_SelectAccount saController = new PP_SelectAccount();
            saController.getURL();
            saController.getAccs();
            saController.getPqs();
            saController.getSearch();
            
            PageReference sa1 = Page.PP_SelectAccount;
            sa1.getParameters().put('cid','102059');
            sa1.getParameters().put('prf','yes');
            Test.setCurrentPageReference(sa1);
            PP_SelectAccount saController1 = new PP_SelectAccount();
            saController1.strCust = 'PP Test Account TFX';
            saController1.getURL();
            saController1.getAccs();
            saController1.getPqs();
            saController1.getSearch();
            string prftest = saController1.prf;
            
            PageReference sa2 = Page.PP_SelectAccount;
            sa2.getParameters().put('cid','Durham');
            sa2.getParameters().put('prf',NULL);
            sa2.getParameters().put('pqId',NULL);
            Test.setCurrentPageReference(sa2);
            PP_SelectAccount saController2 = new PP_SelectAccount();
            System.assertEquals(NULL,saController2.prf);
            System.assertEquals(NULL,saController2.pq);
            saController2.getURL();
            saController2.getAccs();
            saController2.getPqs();
            saController2.getSearch();
            
            PageReference sa3 = Page.PP_SelectAccount;
            sa3.getParameters().put('cid','1');
            Test.setCurrentPageReference(sa3);
            PP_SelectAccount saController3 = new PP_SelectAccount();
            //saController.strCust = '';
            saController3.getURL();
            saController3.getAccs();
            saController3.getPqs();
            saController3.getSearch();
            
            PageReference sa4 = Page.PP_SelectAccount;
            sa4.getParameters().put('cid','  ');
            Test.setCurrentPageReference(sa4);
            PP_SelectAccount saController4 = new PP_SelectAccount();
            //saController.strCust = ' ';
            saController4.getURL();
            saController4.getAccs();
            saController4.getPqs();
            saController4.getSearch();
            
            PageReference sa5 = Page.PP_SelectAccount;
            sa5.getParameters().put('cid',NULL);
            Test.setCurrentPageReference(sa5);
            PP_SelectAccount saController5 = new PP_SelectAccount();
            //saController.strCust = ' ';
            saController5.getURL();
            saController5.getAccs();
            saController5.getPqs();
            saController5.getSearch();
        }
    }//end test for constructor code

}//end test class