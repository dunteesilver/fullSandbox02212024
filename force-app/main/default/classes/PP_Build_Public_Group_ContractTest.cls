@isTest
public class PP_Build_Public_Group_ContractTest {
   @TestSetup
        static void setup(){
        
        //Create test users
        List<User> listOfUsers =new List<User>();
            
          // Create a test Contract User record
       List<Contract_User__c> listOfContrUsers= new List<Contract_User__c>();   
        for(integer i=1; i<=15; i++){
       User testUser = new User(
        FirstName = 'Test',
        LastName = 'User',
        Email = 'testuser' + i + '@telecomflex.com',
        Alias = 'tuser' + i,
        Username = 'testuser' + i + '@telecomflex.com',
        ProfileId = UserInfo.getProfileId(),
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US'
    );
            listOfUsers.add(testUser);
     }
        insert listOfUsers;
            
            for(User u: listOfUsers){
                Contract_User__c contractUser = new Contract_User__c(
                user__c= u.Id,
                Pricing_Tier_Access__c = 2,
                Pricing_Portal_Access__c = true,
                DE_Division_50__c=true,
                UK_Division_20__c=true,
                DE_Division_40__c=true
            );  
             listOfContrUsers.add(contractUser);
           }
        insert listOfContrUsers;
            
        // Create Group objects to use in the test
        List<Group> groups = new List<Group>{
            new Group(Name = 'Pricing Tier 1 - Rep'),
            new Group(Name = 'Pricing Tier 2 - Manager'),
            new Group(Name = 'Pricing Tier 3 - Director'),
            new Group(Name = 'Pricing Tier 4 - VP'),
            new Group(Name = 'Pricing Portal'),
            new Group(Name = 'DE Division 50'),
            new Group(Name = 'UK Division 20'),
            new Group(Name = 'DE Division 40')
        };
        insert groups;     
            
            
     } //end of setup
    
    @isTest
    static void testUpdateGroupMembership(){
        
        Test.startTest();
         //Query Contract Users 
         List<Contract_User__c> contractUsers=[SELECT User__r.id, Pricing_Portal_Access__c, Pricing_Tier_Access__c, Name, 
                                               DE_Division_50__c, UK_Division_20__c, DE_Division_40__c 
                                               FROM Contract_User__c LIMIT 20]; 
        
        System.debug('*** Printing contract users **** '+contractUsers);
        
          List<Id> contractUserIds = new List<Id>();
          for (Contract_User__c contractUser : contractUsers) {
             contractUserIds.add(contractUser.User__r.id);
       
        }     
         
        // Calling the method 
        PP_Build_Public_Group_Contract.Update_Groups_Membership(contractUserIds);   
                     
        // Query public groups
       map<String, Id> gMap = new map<String, Id>();
        for(Group g: [SELECT Name, Id FROM GROUP
                     WHERE Name = 'Pricing Portal'
                       OR Name like 'DE Division%'
                      OR Name like 'UK Division%'
                      OR Name like 'Pricing Tier%']){
         gMap.put(g.Name, g.Id);                     
                          
                      }
              
        
        // Verify that the contract users have been added to the respective public group
        // Check if the users has been added to the Pricing Portal group
          Id groupIdPricingPortal = gMap.get('Pricing Portal');
          List<GroupMember> pricingPortalMembers =[SELECT UserOrGroupId, Group.Name FROM GroupMember 
                                                   WHERE GroupId =:groupIdPricingPortal AND UserOrGroupId IN : contractUserIds];
         System.debug('*** pricing Portal  Members **** '+pricingPortalMembers);
         System.assertEquals(15, pricingPortalMembers.size());
        
         // Check if the users has been added to the DE Division group
         Id groupIdDEdivison50 = gMap.get('DE Division 50');
         List<GroupMember> DE50groupMembers =[SELECT Id FROM GroupMember 
                                              WHERE GroupId =:groupIdDEdivison50 AND UserOrGroupId IN : contractUserIds];
         System.debug('*** DE50groupMembers **** '+DE50groupMembers.size());
         System.assertEquals(15, DE50groupMembers.size());
       
         // Check if the users has been added to the UK Division group
         Id groupIdUKdivison20 = gMap.get('UK Division 20');
          List<GroupMember> UK20groupMembers =[SELECT Id FROM GroupMember 
                                              WHERE GroupId =:groupIdUKdivison20 AND UserOrGroupId IN : contractUserIds];
         System.assertEquals(15, UK20groupMembers.size());
        
         // Check if the users has been added to the Pricing Tier 2 group
         Id groupIdPricingTier2 = gMap.get('Pricing Tier 2 - Manager');
          List<GroupMember> pricingTierManagerMembers =[SELECT Id FROM GroupMember 
                                                       WHERE GroupId =:groupIdPricingTier2 AND UserOrGroupId IN : contractUserIds];
         System.debug(' pricingTierManagerMembers '+pricingTierManagerMembers.size());
         System.assertEquals(15, pricingTierManagerMembers.size());
        
        //Testing removal from the public groups
        for(Contract_User__c contUser:contractUsers){
             contUser.DE_Division_50__c=false;
             contUser.DE_Division_40__c=false;
            contUser.UK_Division_20__c=false;
            contUser.Pricing_Tier_Access__c=3;
             contUser.Pricing_Portal_Access__c=false;
            
           }
        update contractUsers;
        
        // Calling the method 
        PP_Build_Public_Group_Contract.Update_Groups_Membership(contractUserIds); 
         Test.stoptest();
        
        // Check if the users has been removed from the UK Division group
         List<GroupMember> UK20groupremoval =[SELECT Id FROM GroupMember 
                                              WHERE GroupId =:groupIdUKdivison20 AND UserOrGroupId IN : contractUserIds];
         System.debug('*** UK20groupremoval **** '+UK20groupremoval.size());
         System.assertEquals(0, UK20groupremoval.size());
              
        // Check if the users has been removed from the DE Division group
         List<GroupMember> DE50grRemoval =[SELECT Id FROM GroupMember 
                                              WHERE GroupId =:groupIdDEdivison50 AND UserOrGroupId IN : contractUserIds];
         System.debug('*** DE50groupMembers **** '+DE50grRemoval.size());
         System.assertEquals(0, DE50grRemoval.size());
        
          
         // Check if the users has been removed from Portal access groups
         List<GroupMember> portalGroupremoval =[SELECT Id FROM GroupMember 
                                              WHERE GroupId =:groupIdPricingPortal AND UserOrGroupId IN : contractUserIds];
         System.debug('***portalGroupremoval **** '+portalGroupremoval.size());
         System.assertEquals(0, portalGroupremoval.size());
        
         // Check if the users has been added to the Pricing Tier 3 group
         Id groupIdPricingTier3 = gMap.get('Pricing Tier 3 - Director');
          List<GroupMember> pricingTierDirector =[SELECT Id FROM GroupMember 
                                                       WHERE GroupId =:groupIdPricingTier3 AND UserOrGroupId IN : contractUserIds];
         System.debug(' pricingTierDirector '+pricingTierDirector.size());
         System.assertEquals(15, pricingTierDirector.size());
              
        
    
} //end of testMethod
} // end of class