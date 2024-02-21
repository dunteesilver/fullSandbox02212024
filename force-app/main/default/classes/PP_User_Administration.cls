/*********************************************************************
* Description      : Controller Class for Pricing Portal PP_User_Administration.
* Test Class       : PP_User_Administration_Test
* VisualForce      : PP_User_Administration
* Author(s)        : Eric Clay, Dun Silver
**********************************************************************/
public class PP_User_Administration {

    private final Contract_User__c cUser;
    public List<SelectOption> paginationSizeOptions{get;set;}
    public List<Contract_User__c> uList {get;set;}
    Public Integer size{get;set;}
    Public Integer noOfRecords{get; set;}

    public PP_User_Administration(){
        if(ApexPages.currentPage().getParameters().get('id') != NULL){
            try{
                cUser = [Select Name, Pricing_Portal_Access__c, Active_Price_Quote__c, Create_Quotes__c, Currency_Preference__c,
                         Division_10__c, Division_20__c, Division_30__c, Division_40__c, Division_50__c, Division_60__c,
                         CA_Division_10__c, CA_Division_20__c, CA_Division_30__c, CA_Division_40__c, CA_Division_50__c, CA_Division_60__c,
                         MX_Division_10__c, MX_Division_20__c, MX_Division_30__c, MX_Division_40__c, MX_Division_50__c, MX_Division_60__c,
                         LA_Division_10__c, LA_Division_20__c, LA_Division_30__c, LA_Division_40__c, LA_Division_50__c, LA_Division_60__c,
                         CL_Division_10__c, CL_Division_20__c, CL_Division_30__c, CL_Division_40__c, CL_Division_50__c, CL_Division_60__c,
                         Stationary_Preference__c, User_Administration__c, View_Margin__c,
                         US_Material__c, MX_Material__c, LA_Material__c, CA_Material__c, CL_Material__c, Active_Region__c
                         FROM Contract_User__c
                         WHERE id = :ApexPages.currentPage().getParameters().get('id')
                         LIMIT 1];
            }
            catch(Exception e){
                system.debug('Exception: ' + e);
            }

        }//end of if

        size=100;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
    }

		public ApexPages.StandardSetController setCon {get {
				try{
						System.debug('Running Product Search Query');
						if(setCon == null) {
							System.debug('*** In setCon if ***');
							setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
							[SELECT Id, Name, Pricing_Portal_Access__c, Active_Price_Quote__c, Create_Quotes__c, Currency_Preference__c,
							Division_10__c, Division_20__c, Division_30__c, Division_40__c, Division_50__c, Division_60__c,
							CA_Division_10__c, CA_Division_20__c, CA_Division_30__c, CA_Division_40__c, CA_Division_50__c, CA_Division_60__c,
							MX_Division_10__c, MX_Division_20__c, MX_Division_30__c, MX_Division_40__c, MX_Division_50__c, MX_Division_60__c,
							LA_Division_10__c, LA_Division_20__c, LA_Division_30__c, LA_Division_40__c, LA_Division_50__c, LA_Division_60__c,
							CL_Division_10__c, CL_Division_20__c, CL_Division_30__c, CL_Division_40__c, CL_Division_50__c, CL_Division_60__c,
							Stationary_Preference__c, User_Administration__c, View_Margin__c,
							Business_Unit__c
							FROM Contract_User__c
							ORDER BY Name]));

						 setCon.setPageSize(size);
						 noOfRecords = setCon.getResultSize();


						System.debug('*** setCon *** ' + setCon);
						System.debug('*** noOfRecords *** ' + noOfRecords);
					}//end of if
						return setCon;

				}
				catch(Exception e){
						Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'No products found... ' + e));
						return null;
				}

		} set;}

		//Changes the size of pagination
    public PageReference refreshPageSize() {
        try{
            setCon.setPageSize(size);
            return null;
        }
        catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
            return null;
        }
    }//end of refreshPageSize

    public Contract_User__c getu(){
        return cUser;
    }

    public List<Contract_User__c> getulist1(){
      uList = (List<Contract_User__c>) setCon.getRecords();
			System.debug('*** uList.size() *** ' + uList.size() );
      return (List<Contract_User__c>) setCon.getRecords();
    }

    public PageReference save() {
      cUser.Update_Type__c = 'updateUSR';
      system.debug('cUser:' + cUser);
      update cUser;

      PageReference redir = New Pagereference('/apex/PP_User_Administration');
      redir.setRedirect(true);
      return redir;
    }//end of save

    public PageReference cancel() {
      PageReference redir = New Pagereference('/apex/PP_User_Administration');
      redir.setRedirect(true);
      return redir;
    }

    public String uid {
	    get {
	    	return ApexPages.currentPage().getParameters().get('id');
	    }
    	set;
		}

    public boolean getva(){
      return [SELECT User_Administration__c
              FROM Contract_User__c
              WHERE User__c = :UserInfo.getUserId()
              LIMIT 1].User_Administration__c;
    }

    public PageReference GroupCheck() {

        list<GroupMember> addUser = new list<GroupMember>();

        map<String, Id> gMap = new map<String, Id>();
        for(Group g : [SELECT Name, Id FROM GROUP WHERE Name = 'Pricing Portal' OR Name like '%Division%']){
            gMap.put(g.Name, g.Id);
            //system.debug('g.name:' + g.name + ' g.Id ' + g.id);
        }

        for(Contract_User__c cu : [SELECT User__r.id, Pricing_Portal_Access__c,
                                   Division_10__c, Division_20__c, Division_30__c, Division_40__c, Division_50__c, Division_60__c,
                                   CA_Division_10__c, CA_Division_20__c, CA_Division_30__c, CA_Division_40__c, CA_Division_50__c, CA_Division_60__c,
                                   MX_Division_10__c, MX_Division_20__c, MX_Division_30__c, MX_Division_40__c, MX_Division_50__c, MX_Division_60__c,
                                   LA_Division_10__c, LA_Division_20__c, LA_Division_30__c, LA_Division_40__c, LA_Division_50__c, LA_Division_60__c,
                                   CL_Division_10__c, CL_Division_20__c, CL_Division_30__c, CL_Division_40__c, CL_Division_50__c, CL_Division_60__c
                                   FROM Contract_User__c
                                   WHERE Not User__r.Profile.Name Like 'Chatter%'])
        {

            //system.debug('List of Groups:' + ' 10: ' + cu.Division_10__c + ' 20: ' + cu.Division_20__c + ' 30: ' + cu.Division_30__c + ' 40: ' + cu.Division_40__c + ' 50: ' + cu.Division_50__c + ' 60: ' + cu.Division_60__c);
            //system.debug('List of Maps:' + ' 10: ' + gMap.get('Division 10') + ' 20: ' + gMap.get('Division 20') + ' 30: ' + gMap.get('Division 30') + ' 40: ' + gMap.get('Division 40') + ' 50: ' + gMap.get('Division 50') + ' 60: ' + gMap.get('Division 60'));

            String uId = cu.User__r.id;
            system.debug('uId: ' + uId);

            // 10
            if(cu.Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('US Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // 20
            if(cu.Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('US Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // 30
            if(cu.Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('US Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // 40
            if(cu.Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('US Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // 50
            if(cu.Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('US Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // 60
            if(cu.Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('US Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // CA Division 10
            if(cu.CA_Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CA Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // CA Division 20
            if(cu.CA_Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CA Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // CA Division 30
            if(cu.CA_Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CA Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // CA Division 40
            if(cu.CA_Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CA Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // CA Division 50
            if(cu.CA_Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CA Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // CA Division 60
            if(cu.CA_Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CA Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // Latin America
            // LA Division 10
            if(cu.LA_Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('LA Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // LA Division 20
            if(cu.LA_Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('LA Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // LA Division 30
            if(cu.LA_Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('LA Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // LA Division 40
            if(cu.LA_Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('LA Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // LA Division 50
            if(cu.LA_Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('LA Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // LA Division 60
            if(cu.LA_Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('LA Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            //Mexico
            //MX Division 10
            if(cu.MX_Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('MX Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // MX Division 20
            if(cu.MX_Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('MX Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // MX Division 30
            if(cu.MX_Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('MX Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // MX Division 40
            if(cu.MX_Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('MX Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // MX Division 50
            if(cu.MX_Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('MX Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // MX Division 60
            if(cu.MX_Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('MX Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }

            //Chile
            // CL Division 10
            if(cu.CL_Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CL Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // CL Division 20
            if(cu.CL_Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CL Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // CL Division 30
            if(cu.CL_Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CL Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // CL Division 40
            if(cu.CL_Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CL Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // CL Division 50
            if(cu.CL_Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CL Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            // CL Division 60
            if(cu.CL_Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CL Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }

            // Pricing Portal
            if(cu.Pricing_Portal_Access__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('Pricing Portal'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            system.debug('addUser: ' + addUser.size());
        }

        if(addUser.size() > 0){
            insert addUser;
        }

        PageReference redir = New Pagereference('/apex/PP_User_Administration');
        redir.setRedirect(true);
        return redir;
    }


}