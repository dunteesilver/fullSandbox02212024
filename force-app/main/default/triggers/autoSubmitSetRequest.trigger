trigger autoSubmitSetRequest on Set_Request__c (after insert, after update) {
  /*
      //hold list of approvals
      list<Approval.ProcessSubmitRequest> reqList = new list<Approval.ProcessSubmitRequest>();
      //holds list of new IDs
      list<Id> myIds = new list<Id>();
      //holds Ids of records already submitted
      set<Id> submittedSet = new Set<Id>();
      //list to hold
      list<Id> pIds = new list<Id>();

      //loop through new records and add new IDs to a list
      for(Set_Request__c newC : Trigger.new){
          myIds.add(newC.Id);
          pIds.add(newC.National_Pool_Set__c);
      }
      //map of Set Request Ids with matching National Pool Record
      Map<Id,National_Pool_Set__c> npsMap = new Map<Id,National_Pool_Set__c>([SELECT Id, Status__c FROM National_Pool_Set__c WHERE Id IN :pIds]);
      system.debug('npsMap ============= ' + npsMap);

      //query for IDs already in approval process
      list<ProcessInstance> submitted = new list<ProcessInstance>([SELECT TargetObject.Id FROM ProcessInstance Where TargetObject.id = : myIds]);
      //loop through submitted IDs and add to a set
      for(ProcessInstance curr : submitted){
          submittedSet.add(curr.TargetObjectId);
      }

      //loop through new records to submit for approval
      for (Set_Request__c c : Trigger.New) {
          //condition to avoid submitting records already in approval process
          if(!submittedSet.contains(c.Id)){
              //check status of record
              if (Trigger.isInsert && c.Status__c == 'Pending') {
                  reqList.add(subRequest(c));
              }
              else if(Trigger.isUpdate){
                  Set_Request__c oldSet = Trigger.oldMap.get(c.id);
                  if(c.Status__c=='Pending' && oldSet.Status__c !='Pending'){
                      reqList.add(subRequest(c));
                  }
              }

          }
          //check status of child to update parent record status
          if(submittedSet.contains(c.id)){
              National_Pool_Set__c mapRecs = npsMap.get(c.National_Pool_Set__c);
               if(c.status__c == 'Fulfilled'){
                	mapRecs.status__c = 'Out on Lease';
              }

              //check status of child to update parent record status
              if(c.status__c == 'Denied'){
                mapRecs.status__c = 'Available';
              }
              update mapRecs;
          }
      }

    //submit list of approval request
    List<Approval.ProcessResult> resultList = Approval.process(reqList);

    //method for creating approval request
    public Approval.ProcessSubmitRequest subRequest(Set_Request__c c){
        //create an approval request
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(c.id);
        return req;
	}
  */
}