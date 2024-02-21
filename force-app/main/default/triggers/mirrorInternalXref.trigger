trigger mirrorInternalXref on Internal_Cross_Reference__c (Before Insert, After Insert, Before Update, After Update, After Delete) {
	List<Internal_Cross_Reference__c> newiXref = new List<Internal_Cross_Reference__c>();
	List<Internal_Cross_Reference__c> updatediXref = new List<Internal_Cross_Reference__c>();
	List<Internal_Cross_Reference__c> deleteiXref = new List<Internal_Cross_Reference__c>();
	
	//Boolean already = false;
	if((trigger.isInsert || trigger.isUpdate)&& trigger.isBefore){
		for(Internal_Cross_Reference__c iXref : trigger.new){
			Integer tmpSize = [Select Id FROM Internal_Cross_Reference__c WHERE Product__c = :iXref.Product__c AND Cross_Reference_Product__c = :iXref.Cross_Reference_Product__c].size();
			if(tmpSize != 0){
				iXref.adderror('Duplicate record exists');
			}
			if(iXref.Product__c == iXref.Cross_Reference_Product__c){
				iXref.adderror('This product can\'t cross-reference to itself');
			}
		}
	}

	if(trigger.isInsert && trigger.isAfter){
		for(Internal_Cross_Reference__c iXref : trigger.new){
			Integer tmpSize = [Select Id FROM Internal_Cross_Reference__c WHERE Product__c = :iXref.Cross_Reference_Product__c AND Cross_Reference_Product__c = :iXref.Product__c].size();
			if(iXref.Product__c != null && iXref.Cross_Reference_Product__c != null && tmpSize == 0){
				Internal_Cross_Reference__c tmpXref = new Internal_Cross_Reference__c();
				tmpXref.Product__c = iXref.Cross_Reference_Product__c;
				tmpXref.Cross_Reference_Product__c = iXref.Product__c;
				newiXref.add(tmpXref);
			}
		}
		if(!newiXref.isEmpty()){
			insert newiXref;
		}
	}

	if(trigger.isUpdate && trigger.isAfter){
		for(Internal_Cross_Reference__c iXref : trigger.new){
			Internal_Cross_Reference__c oldInfo = trigger.oldMap.get(iXref.Id);
			List<Internal_Cross_Reference__c> tmpXref = [SELECT Id From Internal_Cross_Reference__c WHERE Product__c = :oldInfo.Cross_Reference_Product__c AND Cross_Reference_Product__c = :oldInfo.Product__c LIMIT 1];
			if(!tmpXref.isEmpty()){
				tmpXref[0].Product__c = iXref.Cross_Reference_Product__c;
				tmpXref[0].Cross_Reference_Product__c = iXref.Product__c;
				updatediXref.add(tmpXref[0]);
			}
		}
		if(!updatediXref.isEmpty()){
			update updatediXref;
		}
	}

	if(trigger.isDelete){
		for(Internal_Cross_Reference__c iXref : trigger.old){
			List<Internal_Cross_Reference__c> tmpXref = [SELECT Id From Internal_Cross_Reference__c WHERE Product__c = :iXref.Cross_Reference_Product__c AND Cross_Reference_Product__c = :iXref.Product__c LIMIT 1];
			if(!tmpXref.isEmpty()){
				deleteiXref.add(tmpXref[0]);
			}
		}
		if(!deleteiXref.isEmpty()){
			delete deleteiXref;
		}
	}
}