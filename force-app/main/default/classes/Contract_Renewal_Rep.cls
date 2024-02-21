/*********************************************************************
* Description      : This class is used in the Contract Renewal Process
										 to help re-assign contracts to reps (Extension class).
* Test Class       : Contract_Renewal_Test
* VisualForce      : Contract_Renewal_Rep
* Author(s)        : Dun Silver
**********************************************************************/
public class Contract_Renewal_Rep {

	public ApexPages.StandardController stdController;
	public Contract_Renewal__c cr {get;set;}
	public List<User> userList {get;set;}
	public String strName {get;set;}
	public List<Contract_Renewal__c> crList {get;set;}
	public List<String> lstString = new List<String>();

	public Contract_Renewal_Rep(ApexPages.StandardController controller) {
		//stdController = controller;
		this.stdController = stdController;
		cr = new Contract_Renewal__c();
		getCrList();

	}//end of constructor

	//get list of contracts
	public List<Contract_Renewal__c> getCrList(){
		String contractId = ApexPages.currentPage().getParameters().get('contractId');
		System.debug('*** contractId *** ' + contractId);
		//cr = new Contract_Renewal__c();
	   	//List<Contract_Renewal__c> contracts = (Contract_Renewal__c)stdController.getRecord();
	   	//this.stdController = stdController;
	    	//lookupObj = new Contract_Renewal__c();
		if( contractId.contains(',') ){
			System.debug('*** In Contructor If Contains Comma *** ');
				lstString = contractId.split(',');
				//getCrList();
		}
		else{
			System.debug('*** In Contructor Else No Commas *** ');
				lstString.add(contractId);
				System.debug('*** lstString *** ' + lstString);
				//getCrList();
		}

		System.debug('*** In getCrList *** ');
		System.debug('*** lstString *** ' + lstString);
		crList = [SELECT Id,Status__c, Owner.Name, Agreement_Number__c, Contract_Description__c,
								 Owner__c, Owner_Name__c, GPO_Contract_Ref__c, Sales__c, Contract_Header__c,
								 Sales_Org__c, Distribution_Channel__c, Group__c, Group_Name__c, Account_Count__c,
								 Material_Count__c, Objective_Name__c, Sub_Group__c, Sub_Group_Name__c, Valid_From__c,
								 Valid_To__c, Business_Unit__c, Sales_Manager__r.Name, Sales_Rep__r.Name
								 FROM Contract_Renewal__c
								 WHERE Id IN :lstString];

		return crList;
	}
	//get list of users from search
	public void getUserList(){
        //strName = Apexpages.currentpage().getParameters().get('searchText');
        String search = '%'+strName+'%';
        system.debug('*** search *** '+ search);
        userList = [SELECT id, Name, Business_Unit__c, Manager.Name, UserRole.Name, License_Name__c
        					FROM User
        					WHERE Name LIKE :search AND isActive = true AND License_Name__c = 'Salesforce'];

        system.debug('*** userList.size() *** ' + userList.size() );
        system.debug('*** userList *** ' + userList);

        //return userList;
    }
    //end of method to get line items

    public PageReference setNewOwner(){
    	String uId = ApexPages.currentPage().getParameters().get('uId');
    	String contractId = ApexPages.currentPage().getParameters().get('contractId');
			List<Contract_Renewal__c> updOwnerList = new List<Contract_Renewal__c>();

    	system.debug('*** uId *** '+ uId);
    	for(Contract_Renewal__c curr : getCrList()){
				curr.OwnerId = uId;
				updOwnerList.add(curr);
			}

    	//Contract_Renewal__c newOwner = new Contract_Renewal__c(Id=contractId, OwnerId=uId);
    	update updOwnerList;

    	PageReference refreshContract = new Pagereference('/apex/Contract_Renewal_Rep?contractId='+contractId).setRedirect(true);
     return refreshContract;
    }
}//end of class