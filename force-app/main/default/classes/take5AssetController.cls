public class take5AssetController {
 public List<Note> notes;
 public List<Attachment> atts;
 public Take5__c take5;
 public User currentUser;
 public string bu {get;set;}
 public Boolean eligible {get;set;}

public take5AssetController(){
    String userId = ApexPages.currentPage().getParameters().get('uid');
    if(userId == null){
      userId = Userinfo.getUserID();
    }
	  currentUser = [select Id, Business_Unit__c, FirstName, LastName, SmallPhotoUrl FROM User where Id=:userId limit 1];
    bu = currentUser.Business_Unit__c;
    Date todaysDate = date.today();
    eligible = true;
    try {
      take5 = [select id FROM Take5__c WHERE Qualified_Business_Unit__c = :bu AND Eligible_Start__c <= :todaysDate AND Eligible_Stop__c >= :todaysDate];
    }catch(Exception ex){
      eligible = false;
    }
    
}

 public List<Note> getNotes() {
  notes = [select id, Title, Body FROM Note WHERE ParentId =:take5.Id];
  return notes;
 }

 public List<Attachment> getAtts() {
  atts = [select id, Name FROM Attachment WHERE ParentId =:take5.Id];
  return atts;
 }

  @RemoteAction
  public static User queryUser(String uid){
    User currentUser = [select Id, Business_Unit__c, FirstName, LastName, SmallPhotoUrl FROM User where Id=:uid limit 1];
    return currentUser;
  }

  @RemoteAction
  public static Take_5_Record__c updateTake5(String uid, String take5Id, String attName) {
  	List<Take_5_Record__c> t5temp = [SELECT Id FROM Take_5_Record__c WHERE Take_5_Attachment__c=:take5Id AND User__c=:uid];
  	if(t5temp.isempty()){

  		Take_5_Record__c t5 = new Take_5_Record__c(Take_5_Attachment__c=take5Id,Attachment_Name__c=attName,User__c=uid);
  		insert t5;
  	}
  	return null;
  }

  @RemoteAction
  public static List<Take_5_Record__c> queryTake5(String uid) {
  	List<Take_5_Record__c> t5temp1 = [SELECT Take_5_Attachment__c FROM Take_5_Record__c WHERE User__c=:uid];
     	return t5temp1;
  }
}