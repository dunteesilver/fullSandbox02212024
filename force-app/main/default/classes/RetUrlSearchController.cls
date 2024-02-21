public class RetUrlSearchController {
 public String nameQuery {get; set;}
 public List<User> Users {get; set;}
 public List<Note> assets {get; set;}
 public Take5__c take5;
 public User currentUser;
 public string bu {get;set;}
  
 public PageReference executeSearch()
 {
  String queryStr='%' + nameQuery + '%';
  If(queryStr.length() < 4){
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Must contain at least 2 characters'));
      Users=null;
      return null;
  }
  Users=[select id, Name, SmallPhotoUrl
            from User
            where name like :queryStr];
            
  return null;
 }
  
 public RetUrlSearchController()
 {
  // if query appears in URL, execute it
  String urlQuery=ApexPages.currentPage().getParameters().get('query');
   
  if ( (null!=urlQuery) && (0!=urlQuery.length()) )
  {
   nameQuery=urlQuery;
   executeSearch();
  }
 }

 public List<Note> getAssets() {
  currentUser = [select Business_Unit__c FROM User where Id=:Userinfo.getUserId() limit 1];
  bu = currentUser.Business_Unit__c;
  system.debug(currentUser);
  take5 = [select id FROM Take5__c WHERE Qualified_Business_Unit__c = :bu];
  assets = [select id FROM Note WHERE ParentId =:take5.Id];
  return assets;
 }

}