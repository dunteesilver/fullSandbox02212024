/*********************************************************************
* Description      : Test coverage for Pricing Portal Contract Process.
* Coverage         : Classes(PP_Build_Contract_Divisions, PP_Build_Group_Future)
* Author(s)        : Eric Clay
**********************************************************************/
@isTest
public class PP_Build_Contract_Divisions_Test {
    
    @istest static void Test_Divisions(){
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman01', 'User01', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
        User usUser = testDataFactoryPP.createUser('US00', 'User00', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US01', 'User01', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        
        User usUser2 = testDataFactoryPP.createUser('US02', 'User07', 'Sales Rep', 'Anesthesia');
        insert usUser2;
        
        User usUser3 = testDataFactoryPP.createUser('US03', 'User03', 'Sales Rep', 'Anesthesia');
        insert usUser3;
        
        User usUser4 = testDataFactoryPP.createUser('US04', 'User04', 'Sales Rep', 'Anesthesia');
        insert usUser4;
        
        User usUser5 = testDataFactoryPP.createUser('US05', 'User05', 'Sales Rep', 'Anesthesia');
        insert usUser5;
        
        User usUser6 = testDataFactoryPP.createUser('US06', 'User06', 'Sales Rep', 'Anesthesia');
        insert usUser6;
        
        User usUser7 = testDataFactoryPP.createUser('US07', 'User07', 'Sales Rep', 'Anesthesia');
        insert usUser7;
        
        usUser.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser.UserRoleId = roleId;
        update usUser;
        
        System.runAs(usUser){
            Quick_Disable__c cs = new Quick_Disable__c(
                Name = 'buildDivisions',
                Enable__c = TRUE
            );
            System.debug('insert cs-->' + cs);
            insert cs;
            
            Account a = new Account(
                Name = 'Test PP Account',
                SAP_Sold_To__c ='100123',
                ShippingStreet='123 Main Street ',
                ShippingCity='Raleigh',
                ShippingState='NC',
                ShippingPostalCode='27614',
                Customer_Group__c = '19'
            );
            insert a;
            
            Date ValidFromDate = Date.today();
            Date ValidToDate = ValidFromDate.addYears(2);
            
            Contract_Header__c ch = new Contract_Header__c(
                Name = '50001234',
                Owner__c = 'Amerinet',
                Agreement_Number__c = '50001234',
                Description__c = 'PP Test Health Systems Tier 1',
                GPO_Contract_Ref__c  = 'VH11227',
                Valid_From__c = ValidFromDate,
                Valid_To__c = ValidToDate,
                Division_10__c = FALSE,
                Division_20__c = FALSE,
                Division_30__c = FALSE,
                Division_40__c = FALSE,
                Division_50__c = FALSE,
                Division_60__c = FALSE
            );
            insert ch;
            system.debug('ch:' + ch);
            
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US60');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US60');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US60');
            insert ch4;
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009068', 'GPO-999','D','US60');
            insert ch5;
            
            Product2 p = new Product2(
                Name = '000-11',
                Division__c = '10'
            );
            insert p;
            system.debug('p:' + p);
            
            Contract_Material__c cm = new Contract_Material__c(
                Name = '000-11',
                Agreement__c = ch.id,
                Agreement_Number_Text__c = '50001234',
                Material_Division__c = '10',
                Product__c = p.id
            );
            insert cm;
            system.debug('cm:' + cm);
            
            update ch;
            system.debug('Update CM:' + cm);
            
            p.Division__c = '20';
            update p;
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update cm;
            p.Division__c = '30';
            update p;
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update cm;
            p.Division__c = '40';
            update p;
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update cm;
            p.Division__c = '50';
            update p;
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update cm;
            p.Division__c = '60';
            update p;
            master_TriggerHelperClass.runOnce('resetOnceSet');
            update cm;
            
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            List<String> cList = new List<String>();
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            insert cuUs;
            
            Contract_User__c cuUs1 = testDataFactoryPP.createPricingPortalUser(usUser1.Name, usUser1.Id, 'CA - Canada', 'CA1010', 3);
            insert cuUs1;

            Contract_User__c cuUs2 = testDataFactoryPP.createPricingPortalUser(usUser2.Name, usUser2.Id, 'LA - Latin America', 'US6020', 2);
            insert cuUs2;

            Contract_User__c cuUs3 = testDataFactoryPP.createPricingPortalUser(usUser3.Name, usUser3.Id, 'MX - Mexico', 'MX4010', 1);
            insert cuUs3;

            Contract_User__c cuUs4 = testDataFactoryPP.createPricingPortalUser(usUser4.Name, usUser4.Id, 'CL - Chile', 'CL1010', 1);
            insert cuUs4;
            
            Contract_User__c cuUs5 = testDataFactoryPP.createPricingPortalUser(usUser5.Name, usUser5.Id, 'AU - Australia', 'AU1010', 1);
            insert cuUs5;
            
            Contract_User__c cuUs6 = testDataFactoryPP.createPricingPortalUser(usUser6.Name, usUser6.Id, 'NZ - New Zealand', 'NZ1010', 1);
            insert cuUs6;
            
            Contract_User__c cuUs7 = testDataFactoryPP.createPricingPortalUser(usUser7.Name, usUser7.Id, 'BR - Brazil', 'BR1010', 1);
            insert cuUs7;

            cList.add(cuUs.Id);
            cList.add(cuUs1.Id);
            cList.add(cuUs2.Id); 
            cList.add(cuUs3.Id);
            cList.add(cuUs4.Id);
            cList.add(cuUs5.Id);
            cList.add(cuUs6.Id);
            cList.add(cuUs7.Id);
            Test.startTest();
            //string query = 'SELECT Id, SAP_Sold_To__c FROM Account Where SAP_Sold_To__c = \'100123\'';
            PP_Contract_Header_Build_Divisions_Batch chBD = new PP_Contract_Header_Build_Divisions_Batch();
            Database.executeBatch(chBD);
            
            PP_Build_Group_Future.Update_Group_Membership(cList);
            
            Test.stopTest();
        }//end System.runAs
    }
}//end PP_Build_Contract_Divisions_Test