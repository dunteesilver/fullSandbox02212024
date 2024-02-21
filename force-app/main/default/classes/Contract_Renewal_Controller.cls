/*********************************************************************
* Description      : This class is used as the main extension class in
										 the Contract Renewal Process.
* Test Class       : Contract_Renewal_Test
* VisualForce      : Contract_Renewal_Home, Contract_Renewal_Materials
* Author(s)        : Dun Silver
**********************************************************************/
global with sharing class Contract_Renewal_Controller {
	private ApexPages.StandardController stdController;
	public List<Contract_Renewal__c> contracts;
	public List<Contract_Renewal_Item__c> materials;
	public Contract_Renewal__c lookupObj {get;set;}
	public Boolean fetchMoreRecords {get;set;}
	public Integer currOffset = 0;
	//public string fname {get; set;}

	public String fname {get{
		fname = '';
		String urlId = ApexPages.currentPage().getParameters().get('contractId');
		try{
			if(urlId != ''){
				system.debug('*** fname *** ' + fname);
				fname = [Select Id, Agreement_Number__c FROM Contract_Renewal__c
																			 WHERE Id = :urlId LIMIT 1].Agreement_Number__c;

				fname = fname + '-Customers-' + datetime.now().format('MM-dd-yyyy');
			}
			else{
				fname = '';
			}
				return fname;
		}
		catch(Exception e){
			return fname;
		}

	}set;}

	//constructor
	public Contract_Renewal_Controller(ApexPages.StandardController stdController) {
     	//List<Contract_Renewal__c> contracts = (Contract_Renewal__c)stdController.getRecord();
     	this.stdController = stdController;
     	lookupObj = new Contract_Renewal__c();
	}

	//used by Contract_Renewal_Materials views
	global static Boolean getCanView(){
     	Boolean canView = false;
     	String currUserId = UserInfo.getUserId();
     	String uId = currUserId.left(15);
     	system.debug('*** currUserId *** ' + currUserId);
     	system.debug('*** uId *** ' + uId);
     	List<Contracts_Team__c> cTeam = [select Id__c, Name from Contracts_Team__c Where Id__c =:uId];

     	List<User> adminTeam = [SELECT Id FROM User WHERE Id =:uId AND UserRole.Name = 'Teleflex Global IT'];

		 	//gives Contracts Team access to certain actions in action bar
     	if(cTeam.size()>0){
     		system.debug('*** cTeam *** ' + cTeam);
     			canView = true;
     	}

		 	//gives Salesforce Team access to certain actions in action bar
     	if(adminTeam.size()>0){
     		system.debug('*** adminTeam *** ' + adminTeam);
     			canView = true;
     	}

     	return canView;
	}
	//end of getCanView

	//used by Contract_Renewal_Materials
	global static Boolean getDirectorView(){
     	Boolean directorView = false;
     	String currUserId = UserInfo.getUserId();
     	String uId = currUserId.left(15);
     	system.debug('*** currUserId *** ' + currUserId);
     	system.debug('*** uId *** ' + uId);
     	List<User> dirAboveList = [SELECT Id, Name, Approval_Level__c FROM User WHERE Id =:uid AND Approval_Level__c >=:3];
     	List<Contracts_Team__c> cTeam = [select Id__c, Name from Contracts_Team__c Where Id__c =:uId];
     	List<User> adminTeam = [SELECT Id FROM User WHERE Id =:uId AND UserRole.Name = 'Teleflex Global IT'];

		 	//gives director and above view of security fields
     	if(dirAboveList.size()>0){
     		system.debug('*** dirAboveList *** ' + dirAboveList);
     			directorView = true;
     	}

			//gives Contracts Team and above view of security fields
			if(cTeam.size()>0){
     		system.debug('*** cTeam *** ' + cTeam);
     			directorView = true;
     	}

			//gives Salesforce Team and above view of security fields
     	if(adminTeam.size()>0){
     		system.debug('*** adminTeam *** ' + adminTeam);
     			directorView = true;
     	}

     	return directorView;
	}

	//method to get contracts team list for action bar
	global static String getContractsTeam(){
		return JSON.serialize([select Id__c, Name from Contracts_Team__c] );
	}//end of Contract Team custom setting build

	//get initial list of contracts
	 global static String getContractList() {
		 return JSON.serialize([select Id, Agreement_Number__c, Condition__c, Contract_Description__c,Contract_Header__c,
							Contract_Partnership__c, Customer_Group__c, Distribution_Channel__c, GPO_Contract_Ref__c,
							Group__c, Key__c, Material_Count__c, Objective_Name__c, Owner__c,Owner_Name__c, Sales__c,
							Sub_Group_Name__c, Group_Name__c, Status__c, Contract_Notes__c, Owner.Name, Account_Count__c,
							Contracts_Rep__c, Sales_Manager__c, Sales_Rep__c, Contracts_Rep_Name__c, In_Approval__c,
							Sales_Org__c, Sub_Group__c, Valid_From__c, Valid_To__c, Contracts_Rep__r.Name,
							Sales_Manager__r.Name, Sales_Rep__r.Name, Business_Unit__c
							FROM Contract_Renewal__c ORDER BY Valid_To__c ASC]);
	 }
	 //end of getContractList

      //get initial list of contracts
       global static String getContractListRep() {
 		 return JSON.serialize([select Id, Agreement_Number__c, Condition__c, Contract_Description__c,Contract_Header__c,
 							Contract_Partnership__c, Customer_Group__c, Distribution_Channel__c, GPO_Contract_Ref__c,
 							Group__c, Key__c, Material_Count__c, Objective_Name__c, Owner__c,Owner_Name__c, Sales__c,
 							Sub_Group_Name__c, Group_Name__c, Status__c, Contract_Notes__c, Owner.Name, Account_Count__c,
 							Contracts_Rep__c, Sales_Manager__c, Sales_Rep__c, Contracts_Rep_Name__c, In_Approval__c,
 							Sales_Org__c, Sub_Group__c, Valid_From__c, Valid_To__c, Contracts_Rep__r.Name,
 							Sales_Manager__r.Name, Sales_Rep__r.Name, Business_Unit__c
 							FROM Contract_Renewal__c WHERE Status__c != 'New' AND Status__c != 'Do Not Renew' AND Status__c != 'Contract Audit'
 							ORDER BY Valid_To__c ASC]);
       }
       //end of getContractList

    //search by Status
    @RemoteAction
    global static List<Contract_Renewal__c> getContractByStatus(String searchStatus){
    	system.debug('*** searchStatus *** ' + searchStatus);
        if(searchStatus == 'All'){
		return [SELECT Id, Agreement_Number__c, Condition__c, Contract_Description__c,Contract_Header__c,
			 Contract_Partnership__c, Customer_Group__c, Distribution_Channel__c, GPO_Contract_Ref__c,
			 Group__c, Key__c, Material_Count__c, Objective_Name__c, Owner__c,Owner_Name__c, Sales__c,
			 Sub_Group_Name__c, Group_Name__c, Status__c, Contract_Notes__c, Owner.Name, Account_Count__c,
			 Contracts_Rep__c, Sales_Manager__c, Sales_Rep__c, Contracts_Rep_Name__c, In_Approval__c,
			 Sales_Org__c, Sub_Group__c, Valid_From__c, Valid_To__c, Contracts_Rep__r.Name
			 FROM Contract_Renewal__c ORDER BY Valid_To__c ASC];
        }
        else{
            return [SELECT Id, Agreement_Number__c, Condition__c, Contract_Description__c,Contract_Header__c,
				 Contract_Partnership__c, Customer_Group__c, Distribution_Channel__c, GPO_Contract_Ref__c,
				 Group__c, Key__c, Material_Count__c, Objective_Name__c, Owner__c,Owner_Name__c, Sales__c,
				 Sub_Group_Name__c, Group_Name__c, Status__c, Contract_Notes__c, Owner.Name, Account_Count__c,
				 Contracts_Rep__c, Sales_Manager__c, Sales_Rep__c, Contracts_Rep_Name__c, In_Approval__c,
				 Sales_Org__c, Sub_Group__c, Valid_From__c, Valid_To__c, Contracts_Rep__r.Name
				 FROM Contract_Renewal__c WHERE Status__c =:searchStatus ORDER BY Valid_To__c ASC];
        }

    }
    //end of search by Status

	//search by Contracts Rep
    @RemoteAction
    global static List<Contract_Renewal__c> viewByContractsRep(String cRepId){
    	system.debug('*** cRepId *** ' + cRepId);
        if(cRepId == '00GE0000002Pqz0MAC'){
					return [SELECT Id, Agreement_Number__c, Condition__c, Contract_Description__c,Contract_Header__c,
					 Contract_Partnership__c, Customer_Group__c, Distribution_Channel__c, GPO_Contract_Ref__c,
					 Group__c, Key__c, Material_Count__c, Objective_Name__c, Owner__c,Owner_Name__c, Sales__c,
					 Sub_Group_Name__c, Group_Name__c, Status__c, Contract_Notes__c, Owner.Name, Account_Count__c,
					 Contracts_Rep__c, Sales_Manager__c, Sales_Rep__c, Contracts_Rep_Name__c, In_Approval__c,
					 Sales_Org__c, Sub_Group__c, Valid_From__c, Valid_To__c, Contracts_Rep__r.Name
					 FROM Contract_Renewal__c ORDER BY Valid_To__c ASC];
        }
        else{
            return [SELECT Id, Agreement_Number__c, Condition__c, Contract_Description__c,Contract_Header__c,
					 Contract_Partnership__c, Customer_Group__c, Distribution_Channel__c, GPO_Contract_Ref__c,
					 Group__c, Key__c, Material_Count__c, Objective_Name__c, Owner__c,Owner_Name__c, Sales__c,
					 Sub_Group_Name__c, Group_Name__c, Status__c, Contract_Notes__c, Owner.Name, Account_Count__c,
					 Contracts_Rep__c, Sales_Manager__c, Sales_Rep__c, Contracts_Rep_Name__c, In_Approval__c,
					 Sales_Org__c, Sub_Group__c, Valid_From__c, Valid_To__c, Contracts_Rep__r.Name
					 FROM Contract_Renewal__c WHERE Contracts_Rep__c =:cRepId ORDER BY Valid_To__c ASC];
        }

    }
    //end of search by Contracts Rep

	//update Contracts Rep field CR Header bulk
	 @RemoteAction
	 global static Contract_Renewal__c updateContractsRep(String lineId, string repId){
	   system.debug('In setContractsRep Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
	   Contract_Renewal__c cr = new Contract_Renewal__c(Id=lineId, Contracts_Rep__c=repId);
	   update cr;
	   Contract_Renewal__c cRepName = [SELECT Id, Contracts_Rep__c, Contracts_Rep_Name__c, Contracts_Rep__r.Name FROM Contract_Renewal__c WHERE Id =:lineId LIMIT 1];
	   system.debug('*** cRepName.Contracts_Rep_Name__c *** ' + cRepName.Contracts_Rep_Name__c);
	   system.debug('*** cRepName.Contracts_Rep__r.Name *** ' + cRepName.Contracts_Rep__r.Name);
	   cr.recalculateFormulas();
	   return cRepName;
	 }
	 //end of method to update Contracts Rep

	//update status field CR Header ****** Possibly Remove ******
	 @RemoteAction
	 global static Contract_Renewal__c updateContractStatus(Id lineId, String status){
 		system.debug('In updateContractStatus Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
 		Contract_Renewal__c cr = new Contract_Renewal__c(Id=lineId, Status__c=status);
 		update cr;
 		return cr;
	 }
	 //end of updateContractStatus

//******************************* Material Detail Stuff Below ********************************************

     //get contract header on details page
     global static String getContract() {
            return JSON.serialize([select Id, Agreement_Number__c, Condition__c, Contract_Description__c,Contract_Header__c,
                                 Contract_Partnership__c, Customer_Group__c, Distribution_Channel__c, GPO_Contract_Ref__c,
                                 Group__c, Key__c, Material_Count__c, Objective_Name__c, Owner__c, Account_Count__c,
                                 Owner_Name__c, Sales__c, Sales_Org__c, Sub_Group__c, Valid_From__c, Valid_To__c,
                                 Sub_Group_Name__c, Group_Name__c, Status__c, Contract_Notes__c, Owner.Name,
                                 Contracts_Rep__c, Sales_Manager__c, Sales_Rep__c, Contracts_Rep_Name__c, In_Approval__c,
                                 Sales_Manager__r.Name, Sales_Rep__r.Name, New_Agreement_Number__c
                                 FROM Contract_Renewal__c
                                 WHERE Id = :ApexPages.currentPage().getParameters().get('contractId') LIMIT 1] );
    }

     //get list of materials on details page
    global String getMaterials() {
				List<Contract_Renewal_Item__c> materials = new List<Contract_Renewal_Item__c>();
				materials = [SELECT Product__r.Name, Product__r.Description, Current_Price__c, Valid_From__c, Material_Line_Note__c,
														Valid_To__c, Product__r.Brand_Name__c, Product__r.Class__c, Product__r.Product_Line__c,
														Product__r.Material_Status_Description__c, Product__r.Cost_Formula__c, Sales__c, Detail_Contracts_Notes__c,
														Product__r.List_Price__c, Product__r.Floor_Price__c, Final_Increase__c, Product__r.Last_Year_ASP__c,
														Default_Per_Increase__c, Default_Gross_Profit__c, Default_Renewal_Price__c, Current_Gross_Profit__c,
														Requested_Increase__c, Requested_Price_GP__c, Requested_Renewal_Price__c, Current_Price_with_30_GP__c,
														Product__r.Material_Status_Check__c, Approval_Flag__c, Detail_Notes__c, Contract_Renewal__r.In_Approval__c,
														Product__r.Material_Status__c, Material_Status_Description__c, Material_Status__c, Product__r.ASK_Custom_Kit__c,
														Product__r.Product_Line_Text__c, Product__r.Product_Class__c, Contract_Renewal__r.Owner.Name,
														Recently_Added__c, BelowGp__c
														FROM Contract_Renewal_Item__c WHERE Contract_Renewal__c = :ApexPages.currentPage().getParameters().get('contractId')
														ORDER BY Product__r.Name LIMIT 2000];

				system.debug('*** materials.size() *** ' + materials.size());
				if(materials.size() == 2000){
					fetchMoreRecords = true;
					currOffset += 2000;
				}
				else{
					fetchMoreRecords = false;
					currOffset = 0;
				}

				Limits.getHeapSize();
				system.debug('*** Limits.getHeapSize() *** ' + Limits.getHeapSize());
				return JSON.serialize(materials);
    }//end of getMaterials

		//get more materials on details page
		@RemoteAction
    global static List<Contract_Renewal_Item__c> getMoreMaterials(Id conId, List<Id> usedIds){
    	List<Contract_Renewal_Item__c> addMaterials = new List<Contract_Renewal_Item__c>();
			addMaterials = [SELECT Product__r.Name, Product__r.Description, Current_Price__c, Valid_From__c, Material_Line_Note__c,
													Valid_To__c, Product__r.Brand_Name__c, Product__r.Class__c, Product__r.Product_Line__c,
													Product__r.Material_Status_Description__c, Product__r.Cost_Formula__c, Sales__c, Detail_Contracts_Notes__c,
													Product__r.List_Price__c, Product__r.Floor_Price__c, Final_Increase__c, Product__r.Last_Year_ASP__c,
													Default_Per_Increase__c, Default_Gross_Profit__c, Default_Renewal_Price__c, Current_Gross_Profit__c,
													Requested_Increase__c, Requested_Price_GP__c, Requested_Renewal_Price__c, Current_Price_with_30_GP__c,
													Product__r.Material_Status_Check__c, Approval_Flag__c, Detail_Notes__c, Contract_Renewal__r.In_Approval__c,
													Product__r.Material_Status__c, Material_Status_Description__c, Material_Status__c,
													Product__r.Product_Line_Text__c, Product__r.Product_Class__c
													FROM Contract_Renewal_Item__c WHERE Id NOT IN :usedIds AND Contract_Renewal__c =:conId
													ORDER BY Product__r.Name LIMIT 2000];

			system.debug('*** addMaterials *** ' + addMaterials);
			return addMaterials;
    }

     //update status field CR Header ****** Possibly Remove ******
    @RemoteAction
    global static Contract_Renewal__c setContractStatus(id lineId, string status){
            system.debug('In setContractStatus Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            Contract_Renewal__c cr = new Contract_Renewal__c(Id=lineId, Status__c=status);
            update cr;
            return cr;
    }

     //update New Agreement Number field CR Header ****** Possibly Remove ******
    @RemoteAction
    global static Contract_Renewal__c updateNewNumber(id lineId, string newNumber){
            system.debug('In updateNewNumber Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            Contract_Renewal__c cr = new Contract_Renewal__c(Id=lineId, New_Agreement_Number__c=newNumber);
            update cr;
            return cr;
    }

     //update Material Line Note field CR Header ****** Possibly Remove ******
    @RemoteAction
    global static Contract_Renewal_Item__c materialLineNote(Id lineId, string note){
            system.debug('In materialLineNote Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            Contract_Renewal_Item__c cr = new Contract_Renewal_Item__c(Id=lineId, Material_Line_Note__c=note);
            update cr;
            return cr;
    }

     //update percent and price for CRI
    @RemoteAction
    global static Contract_Renewal_Item__c updatePricePercent(id lineId, decimal price, decimal perc){
            system.debug('In updatePricePercent Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            Contract_Renewal_Item__c cri = new Contract_Renewal_Item__c(Id=lineId, Requested_Renewal_Price__c=price,Requested_Increase__c=perc);
            update cri;
            return cri;
    }
    //end of updatePricePercent

		//update default percent and default renewal price for CRI
	 @RemoteAction
	 global static Contract_Renewal_Item__c updateDefaultPricePercent(id lineId, decimal price, decimal perc){
					 system.debug('In updatePricePercent Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
					 Contract_Renewal_Item__c cri = new Contract_Renewal_Item__c(Id=lineId, Default_Renewal_Price__c=price,Default_Per_Increase__c=perc);
					 update cri;
					 return cri;
	 }
	 //end of updateDefaultPricePercent

    //update Contract Notes for CR
    @RemoteAction
    global static Contract_Renewal__c updateNotes(id lineId, string note){
            system.debug('In updateNotes Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            Contract_Renewal__c cr = new Contract_Renewal__c(Id=lineId, Contract_Notes__c=note);
            update cr;
            return cr;
    }

    //update Material Detail Notes for CRM
    @RemoteAction
    global static Contract_Renewal_Item__c updateDetails(Id lineId, String note){
            system.debug('In updateNotes Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            Contract_Renewal_Item__c cri = new Contract_Renewal_Item__c(Id=lineId, Detail_Notes__c=note);
            update cri;
            return cri;
    }

    //submit for approval
    @RemoteAction
    global static String submitApproval(String conId) {
        //Contract_Renewal__c cr = new Contract_Renewal__c(Id=conId);

        system.debug('In submitApproval RemoteAction!!!!');
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting for Approval');
        req1.setObjectId(conId);
        req1.setNextApproverIds(new ID[]{UserInfo.getUserId()});
        Approval.ProcessResult pr = Approval.process(req1);
        return 'Success';

    }
    //end of submit for approval

		//update status field CR Header ****** Possibly Remove ******
		 @RemoteAction
		 global static Contract_Renewal_Item__c updateContractRecom(Id lineId, String status){
			system.debug('In updateContractRecom Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			Contract_Renewal_Item__c cri = new Contract_Renewal_Item__c(Id=lineId, Material_Line_Note__c=status);
			update cri;
			return cri;
		 }
		 //end of updateContractStatus

}//end of class