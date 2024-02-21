@isTest
public class SObjectUtilityTest {

    
    @isTest
    public static void SObjectUtilityTestAll(){
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;

         //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman', 'User', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        User usUser = testDataFactoryPP.createUser('US1', 'User1', 'Sales Rep', 'Anesthesia');
        usUser.ManagerId = usUserMan.Id;
        usUser.UserRoleId = roleId;
        insert usUser;
        
        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
		System.runAs(usUser){
        
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser.Name, usUser.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            SObjectUtility.getChkBoxFieldLabelNames('Account');
            SObjectUtility.getChkBoxFieldAPINames('Account');
            SObjectUtility.getAllChkBoxFieldAPIAndLabelNames('Account');
            SObjectUtility.getContractUserRecords(new List<Id>{cuUs.Id});
            SObjectUtility.main(new List<Id>{cuUs.Id});
            SObjectUtility.replaceMessedUpCharacters('ÃŸTEST');

        }
        
    }
}