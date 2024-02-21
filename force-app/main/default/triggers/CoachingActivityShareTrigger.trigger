trigger CoachingActivityShareTrigger on Coaching_Activity__c (after insert) {
    
    if(trigger.isInsert){


 List<Coaching_Activity__Share> caShares = new List<Coaching_Activity__Share>();
	
 /** For each of the Coaching_Activity__c records being inserted, do the following: **/
 for(Coaching_Activity__c caObj : trigger.new){

 /** Create a new Coaching_Activity_Share record to be inserted in to the Coaching_Activity_Share table. **/
 Coaching_Activity__Share shareThisRecord = new Coaching_Activity__Share();

 /** Populate the Coaching_Activity_Share record with the ID of the record to be shared. **/
 shareThisRecord.ParentId = caObj.Id;

 /** Then, set the ID of user or group being granted access. In this case,
 * we're setting the Id of the Coaching_Activity__c.Contact__c that was specified by the Coaching_Activity__c
 * Result in the Contact__c lookup field on the Coaching_Activity__c record.
 **/

 shareThisRecord.UserOrGroupId = caObj.User_Name__r.ID;//caObj.Contact__c;
     	  System.debug('In CoachingActivityShareTrigger sharing with User-->'+caObj.User_Name__c);
          System.debug('In CoachingActivityShareTrigger sharing with contact-->'+caObj.Contact__c);

 /** Specify that the Contact__c should have edit access for this particular Test Coaching_Activity__c. **/
 shareThisRecord.AccessLevel = 'edit';

 /** Specify that the reason the Contact__c can edit the record is because its his Coaching_Activity__c result
 * (Student_Access__c is the Apex Sharing Reason that we defined earlier.)
 **/
 shareThisRecord.RowCause = Schema.Coaching_Activity__Share.RowCause.Coaching_Activity_Share_Reason__c;

 /** Add the new Share record to the list of new Share records. **/
 caShares.add(shareThisRecord);
 }

 /** Insert all of the newly created Share records and capture save result **/
 Database.SaveResult[] jobShareInsertResult = Database.insert(caShares,false);
 }
}