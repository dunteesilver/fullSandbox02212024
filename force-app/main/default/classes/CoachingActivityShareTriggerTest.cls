@isTest
private class CoachingActivityShareTriggerTest {
  
   static testMethod void testApexShare(){
      // Select users for the test.
      List<User> users = [SELECT Id FROM User WHERE IsActive = true LIMIT 2];
      Id User1Id = users[0].Id;
      Id User2Id = users[1].Id;
   
      // Create new coaching activity.
      Coaching_Activity__c caObj = new Coaching_Activity__c();
      //caObj.Name = 'Test Job';
      caObj.OwnerId = user1Id;
      insert caObj;    
                
 
   
      // Query job sharing records.
      List<Coaching_Activity__Share> caShrs = [SELECT Id, UserOrGroupId, AccessLevel, 
         RowCause FROM Coaching_Activity__Share WHERE ParentId = :caObj.Id AND UserOrGroupId= :user2Id];
      
      /* Test for only one manual share on job.
      System.assertEquals(caShrs.size(), 1, 'Set the object\'s sharing model to Private.');
      
      // Test attributes of manual share.
      System.assertEquals(caShrs[0].AccessLevel, 'Read');
      System.assertEquals(caShrs[0].RowCause, 'Manual');
      System.assertEquals(caShrs[0].UserOrGroupId, user2Id); */
      
      // Test invalid job Id.
      delete caObj;   

   }  
}