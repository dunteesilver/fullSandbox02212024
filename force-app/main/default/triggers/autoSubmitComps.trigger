//Trigger created by Dunte'e Silver
trigger autoSubmitComps on Complaint__c (after insert, after update) {
  /*
    //hold list of approvals
    list<Approval.ProcessSubmitRequest> reqList = new list<Approval.ProcessSubmitRequest>();
    //holds list of new IDs
    list<Id> myIds = new list<Id>();
    //holds Ids of records already submitted
    set<Id> submittedSet = new Set<Id>();

    //loop through new records and add new IDs to a list
    for(Complaint__c newC : Trigger.new){
        myIds.add(newC.Id);
    }

    //query for IDs already in approval process
    list<ProcessInstance> submitted = new list<ProcessInstance>([SELECT TargetObject.Id FROM ProcessInstance Where TargetObject.id = : myIds]);
    //loop through submitted IDs and add to a set
    for(ProcessInstance curr : submitted){
        submittedSet.add(curr.TargetObjectId);
    }

    //loop through new records to submit for approval
    for (Complaint__c c : Trigger.New) {
        //condition to avoid submitting records already in approval process
        if(!submittedSet.contains(c.Id)){
            //check status of record
            if (Trigger.isInsert && c.Status__c == 'Submitted') {
                reqList.add(subRequest(c));
            }
            else if(Trigger.isUpdate){
                Complaint__c oldComp = Trigger.oldMap.get(c.id);
                if(c.Status__c=='Submitted' && oldComp.Status__c !='Submitted'){
                    reqList.add(subRequest(c));
                }
            }
        }
    }

    //submit list of approval request
    List<Approval.ProcessResult> resultList = Approval.process(reqList);

    //method for creating approval request
    public Approval.ProcessSubmitRequest subRequest(Complaint__c c){
        //create an approval request
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(c.id);
        return req;
    }
    */
}