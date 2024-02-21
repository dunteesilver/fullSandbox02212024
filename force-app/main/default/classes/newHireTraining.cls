public class newHireTraining {
    
    public static Document tfxAcademyImg {get;set;}
    
	public newHireTraining() {
	    tfxAcademyImg = [SELECT Id FROM Document WHERE DeveloperName = 'Teleflex_Academy_Image'];
	}

	@RemoteAction
	public static New_Hire_Training_Record__c updateNHTR(String uid, String linkId, String bu) {
		List<New_Hire_Training_Record__c> nhtrtemp = [SELECT Id FROM New_Hire_Training_Record__c WHERE LinkId__c=:linkId AND User__c=:uid AND Business_Unit__c=:bu];
		if(NHTRtemp.isempty()){
			New_Hire_Training_Record__c nhtr = new New_Hire_Training_Record__c(Business_Unit__c=bu,LinkId__c=linkId,User__c=uid);
			insert nhtr;
		}
		return null;
	}
	@RemoteAction
	public static List<New_Hire_Training_Record__c> queryNHTR(String uid, String bu) {
		List<New_Hire_Training_Record__c> nhtrtemp1 = [SELECT linkId__c FROM New_Hire_Training_Record__c WHERE User__c=:uid AND Business_Unit__c=:bu];
	 	return nhtrtemp1;
	}
	
}