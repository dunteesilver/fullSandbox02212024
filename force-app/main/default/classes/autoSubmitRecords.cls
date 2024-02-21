public with sharing class autoSubmitRecords {
		public autoSubmitRecords() {
		}

		//method for creating approval request
		public Approval.ProcessSubmitRequest subRequest(sObject obj){
				//create an approval request
				Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
				req.setObjectId(obj.id);
				return req;
		}

        //Method to handle auto-submit of records for approval (Complaint__c, Set_Request__c)
		public void autoSubmit(List<sObject> triggerNew, Map<Id,sObject> triggerOld, String type){

			System.debug('*** object *** ' + triggerNew.getSObjectType() );
			/************************ Start of logic to handle auto-submitting Records ************************/

			//hold list of approvals
			List<Approval.ProcessSubmitRequest> reqList = new List<Approval.ProcessSubmitRequest>();
			//holds list of new IDs
			List<Id> myIds = new List<Id>();
			//holds Ids of records already submitted
			Set<Id> submittedSet = new Set<Id>();

			//list to hold National Pool Set IDs
      List<Id> pIds = new List<Id>();
			//list of Complaint records
			List<Complaint__c> setDate = new List<Complaint__c>();
			//list of National Pool Set
			List<National_Pool_Set__c> updateNps = new List<National_Pool_Set__c>();

			//loop through new records and add new IDs to a list
			for(sObject curr : triggerNew){
				String objType = curr.getSObjectType().getDescribe().getName(); //gets sObject Type
				myIds.add(curr.Id);
				if(objType == 'Set_Request__c'){
					pIds.add( (String)curr.get('National_Pool_Set__c') );
				}
			}

			//map of Set Request Ids with matching National Pool Record
      Map<Id,National_Pool_Set__c> npsMap = new Map<Id,National_Pool_Set__c>([SELECT Id, Status__c FROM National_Pool_Set__c WHERE Id IN :pIds]);
      system.debug('npsMap ============= ' + npsMap);

			//query for IDs already in approval process
			List<ProcessInstance> submitted = new List<ProcessInstance>([SELECT TargetObject.Id FROM ProcessInstance Where TargetObject.id = : myIds]);
			//loop through submitted IDs and add to a set
			for(ProcessInstance curr : submitted){
				submittedSet.add(curr.TargetObjectId);
			}

			//loop through new records to submit for approval
			for(sObject curr : triggerNew) {
				System.debug('*** IN for(sObject curr : triggerNew) LOOP OF autoSubmitRecords CLASS TO AUTO SUBMIT RECORDS ***');
				System.debug('*** curr *** ' + curr);
				String objType = curr.getSObjectType().getDescribe().getName(); //gets sObject Type
				//condition to avoid submitting records already in approval process
				if(!submittedSet.contains(curr.Id)){
					//check status of record
					if (type == 'isInsert' && ( (String)curr.get('Status__c') == 'Submitted' || (String)curr.get('Status__c') == 'Pending')   ){
						System.debug('*** Submitting Record for Approval in type == isInsert *** ' + curr.Id);
						reqList.add(subRequest(curr));
						if( (String)curr.get('Status__c') == 'Submitted' && objType == 'Complaint__c' ){
							Complaint__c objComp = (Complaint__c)curr; //type casting from generic sObject to Complaint__c
							setDate.add(objComp);
						}
					}
					else if(type == 'isUpdate'){
						sObject oldObj = triggerOld.get(curr.Id);
						if( (String)curr.get('Status__c') == 'Submitted' && oldObj.get('Status__c') != 'Submitted'){
							System.debug('*** Submitting Record for Approval *** in else if(type == isUpdate) if statement *** ' + curr.Id);
							reqList.add(subRequest(curr));
							if(objType == 'Complaint__c'){
								Complaint__c objComp = (Complaint__c)curr; //type casting from generic sObject to Complaint__c
								setDate.add(objComp);
							}
						}
						else if( (String)curr.get('Status__c') == 'Pending' && oldObj.get('Status__c') != 'Pending'){
							System.debug('*** Submitting Record for Approval *** in else if(type == isUpdate) else if statement *** ' + curr.Id);
						  reqList.add(subRequest(curr));
						}
					}
				}//end of if(!submittedSet.contains(curr.Id))

			  //check status of Set Request Records to update parent National Pool Set Record
				if(objType == 'Set_Request__c'){
					if(submittedSet.contains(curr.id)){
							National_Pool_Set__c mapRecs = npsMap.get( (String)curr.get('National_Pool_Set__c') );
							 if( (String)curr.get('Status__c') == 'Fulfilled'){
									mapRecs.Status__c = 'Out on Lease';
									updateNps.add(mapRecs);
							 }
							 else if( (String)curr.get('Status__c') == 'Denied'){
									mapRecs.Status__c = 'Available';
									updateNps.add(mapRecs);
							 }

					}//end of if(submittedSet.contains(c.id))
				}//end of if for objType check


			}//end of for(sObject curr : triggerNew)

			//submit list of approval request
			if(reqList.size() >0){
				List<Approval.ProcessResult> resultList = Approval.process(reqList);
			}

			//Update SubmittedForApprovalDate__c field for Complaint Records
			//ComplaintIntegrationExtension setSubmitDate = new ComplaintIntegrationExtension();
			//setSubmitDate.setSubmittedComplaintDate(setDate);
	    /************************ End of logic to handle auto-submitting Records ************************/

		}//end of autoSubmit method

}//end of class