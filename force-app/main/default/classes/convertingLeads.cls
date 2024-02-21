/*********************************************************************
* Description      : Extension Class for custom lead conversion process.
* Test Class       : convertingLeadsTest
* VisualForce      : LeadConversionAccount, LeadConversionContact, LeadConversionProducts
* Author(s)        : Dun Silver
**********************************************************************/
global class convertingLeads {

    // Primary Test Class: convertingLeadsTest

	private Lead lead {get;set;}
	public String saccId {get;set;}
	public String sconId {get;set;}
	public boolean displayPopup {get;set;}

	//start of create account variables
	public String aName {get;set;}
	public String aStreet {get;set;}
	public String aCity {get;set;}
	public String aState {get;set;}
	public String aZip {get;set;}
	//end of create account variable

	//booleans to help with render of related list
	public Boolean simAccBool {get{
			List<Account> saccs = [SELECT Id, Name, SAP_Sold_To__c,
							ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
							FROM Account
							WHERE Name LIKE :'%'+lead.Company+'%'
							ORDER BY LastViewedDate DESC limit 10];
			if(saccs.size()>0){
					return true;
			}else{
					return false;
			}

	}set;}

	public Boolean simRecBool {get{
			List<Account> raccs = [SELECT Id, Name, SAP_Sold_To__c,
							ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
							FROM Account
							WHERE LastViewedDate != NULL
							ORDER BY LastViewedDate DESC limit 10];
			if(raccs.size()>0){
					return true;
			}else{
					return false;
			}

	}set;}

	public Boolean conAccsBool {get{
			List<Contact> cons = [SELECT Id, Name, Email, Phone, Account.Name
							FROM Contact
							WHERE Account.Id = :lead.Account__c
							];
			if(cons.size()>0){
					return true;
			}else{
					return false;
			}

	}set;}

	public Boolean conSimsBool {get{
			List<Contact> cons = [SELECT Id, Name, Email, Phone, Account.Name
							FROM Contact
							WHERE FirstName LIKE :'%'+lead.FirstName+'%'
							AND LastName LIKE :'%'+lead.LastName+'%'
							AND AccountId =:lead.Account__c
							];
			if(cons.size()>0){
					return true;
			}else{
					return false;
			}

	}set;}
	//end of booleans to help with render of related list

	//constructor
	public convertingLeads(ApexPages.StandardController stdController){
		system.debug('1ST STEP IN CONSTRUCTOR ***** ');
		//ApexPages.StandardController stdController
		//this.ld = (Lead)stdController.getRecord();

		lead = new Lead();

		if(ApexPages.currentPage().getParameters().get('id') != NULL){
			lead = [SELECT Id, Name, Email, Phone, Title, Account__c, Contact__c, Description, Company, FirstName, LastName, RecordTypeId, Business_Unit__c,
						Product_Family__c, Product_Of_Interest__c, Product_Family_Latam__c, Product_Of_Interest_Latam__c, Do_not_create_opportunity__c, Amount__c,
						Existing_Opportunity__c,RecordType.Name, Zip_Code_Auto_Route__c, Product_Family_GPL__c, Product_of_Interest_GPL__c
						FROM Lead WHERE Id =:ApexPages.currentPage().getParameters().get('id')];
		}

	}//end of constructor

	public Lead getLead(){
		return lead;
	}

	//get list of recent Accounts
	public list<Account> getsimAccs(){
			return [SELECT Id, Name, SAP_Sold_To__c,
							ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
							FROM Account
							WHERE Name LIKE :'%'+lead.Company+'%'
							ORDER BY LastViewedDate DESC limit 10];

	}//end of recent Accounts

	public list<Account> getrecAccs(){
			return [SELECT Id, Name, SAP_Sold_To__c,
							ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
							FROM Account
							WHERE LastViewedDate != NULL
                    ORDER BY LastViewedDate DESC limit 10];

    }//end of recent Accounts

    public list<Contact> getconAccs(){
        return [SELECT Id, Name, Email, Phone, Account.Name
                FROM Contact
                WHERE Account.Id = :lead.Account__c
                LIMIT 1000];
    }//end of contacts for Account

    public list<Contact> getconSims(){
        return [SELECT Id, Name, Email, Phone, Account.Name
                FROM Contact
                WHERE FirstName LIKE :'%'+lead.FirstName+'%'
                AND LastName LIKE :'%'+lead.LastName+'%'
                AND AccountId =:lead.Account__c
                LIMIT 1000];

	}//end of contacts for Account

	public void showAccFields(){
		displayPopup = true;
		system.debug('displayPopup ***** ' + displayPopup);
	}

	public void showAccFieldsFalse(){
		displayPopup = false;
		system.debug('displayPopup ***** ' + displayPopup);
	}

	//method to handle Looking up an account
	public PageReference lookupAcc(){

		system.debug('lead.Account__c ***** ' + lead.Account__c);
		if(lead.Account__c == NULL){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please lookup, select, or create a New Account to continue...'));
			return null;
		}
		else{
			lead = new Lead(
                Id=lead.id,
                Account__c=lead.Account__c,
                Zip_Code_Auto_Route__c=true,
                Custom_Conversion__c=true
            );

			try{
				system.debug('UPDATING LEAD WITH ACCOUNT ' + lead.Account__c);
				update lead;
				PageReference leadContact = new PageReference('/apex/LeadConversionContact?id=' + lead.Id).setRedirect(true);
				return leadContact;
			}
			catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error generated from lookupAcc method in convertingLeads.cls: \n' + e.getMessage()));
				return null;
			}
		}
	}
	//end of lookup account method

	//method to handle selecting an Account
	public PageReference selectedAccount(){
		List<Lead> updLeads = new List<Lead>();

		system.debug('saccId ***** ' + saccId);
		system.debug('lead.Account__c ***** ' + lead.Account__c);
		if(saccId != NULL && lead.Contact__c != NULL){
			system.debug('TRYING TO CHANGE ACCOUNT W/ CONTACT');
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'In order to change Accounts, please remove the associated Contact.'));
			return null;
		}
		else{
			if(saccId != NULL){
				Lead l = new Lead(
                    Id=lead.Id,
                    Account__c=saccId,
                    Zip_Code_Auto_Route__c=TRUE,
                    Custom_Conversion__c=TRUE
                );
				updLeads.add(l);

				if(updLeads.size()>0){
					try{
						system.debug('UPDATING THE LEAD');
						update updLeads;
						PageReference leadContact = new PageReference('/apex/LeadConversionContact?id=' + lead.Id).setRedirect(true);
						return leadContact;
					}
					catch(Exception e){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
						return null;
					}

				}//end of if for lead list size
				else{
					return null;
				}
			}
			else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select an Account...'));
				PageReference leadPage = new PageReference('/apex/LeadConversionAccount?id=' + lead.Id).setRedirect(true);
				return leadPage;
			}
			//end of if/else block saccId != NULL
		}//end of if/else block for contact check

	}//end selectedAccount

	//method to create an Account
	public PageReference createAccount(){
		Account a = new Account(Name=aName,ShippingStreet=aStreet,
														ShippingState=aState,ShippingCity=aCity,
														ShippingPostalCode=aZip);

		if(a != NULL){
			insert a;
		}

		Lead l = new Lead(Id=lead.Id,Account__c=a.Id,Zip_Code_Auto_Route__c=true);
		try{
			update l;
			PageReference leadContact = new PageReference('/apex/LeadConversionContact?id=' + lead.Id
																	+ '&aid=' + a.Id).setRedirect(true);
			return leadContact;
		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error generated from createAccount method in convertingLeads.cls: \n' + e.getMessage()));
			return null;
		}
	}
	//end of create Account method

	//method to lookup an Existing Account
	public PageReference lookupCon(){

		system.debug('lead.Contact__c ***** ' + lead.Contact__c);
		if(lead.Contact__c != NULL){
			lead = new Lead(
                Id = lead.id,
                Contact__c = lead.Contact__c,
                Contact_ID__c = lead.Contact__c,
                Custom_Conversion__c = TRUE
            );

			try{
				system.debug('UPDATING LEAD WITH Contact ' + lead.Contact__c);
				update lead;
				PageReference leadProds = new PageReference('/apex/LeadConversionProducts?id=' + lead.Id).setRedirect(true);
				return leadProds;
			}
			catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error generated from lookupCon method in convertLead.cls: \n' + e.getMessage()));
				return null;
			}
		}
		else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'You must lookup a contact/select a contact, to save this record...otherwise, ' +
														'move to the next step and a Contact will be auto created with information from this Lead...'));
			return null;
		}
	}
	//end of lookup contact method

	//method to select an existing contact
	public PageReference selectedContact(){
		if(sconId != NULL){
			//save existing contact
			lead = new Lead(
                Id=lead.id,
                Contact__c=sconId,
                Contact_ID__c = sconId,
                Custom_Conversion__c = TRUE
            );

			try{
				system.debug('UPDATING LEAD WITH CONTACT ' + lead);
				update lead;

				PageReference leadProds = new PageReference('/apex/LeadConversionProducts?id=' + lead.Id).setRedirect(true);
				return leadProds;
			}
			catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error generated from selectedContact method in convertingLeads.cls if block: \n' + e.getMessage()));
				return null;
			}
		}//end if for Id check
		else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error generated from selectedContact method in convertingLeads.cls else block.'));
			return null;
		}

	}//end selectedContact

	//method to update Lead
	public PageReference updateLead(){

		lead = new Lead(Id=lead.id, FirstName=lead.FirstName,
										LastName=lead.LastName, Email=lead.Email,
										Phone=lead.Phone, Title=lead.Title);

		try{
			system.debug('UPDATING LEAD INFORMATION ' + lead);
			update lead;

			PageReference leadProds = new PageReference('/apex/LeadConversionProducts?id=' + lead.Id).setRedirect(true);
			return leadProds;
		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error generated from Update Lead button in updateLead method in convertingLeads.cls if block: \n' + e.getMessage()));
			return null;
		}

	}//end of update lead method

	//start of method to save product information
	public PageReference saveProds(){
		system.debug('IN SAVEPRODS METHOD *****');
		//save product information to leads
		lead = new Lead(Id=lead.Id,Business_Unit__c=lead.Business_Unit__c,
						//Product_Family__c=lead.Product_Family__c,
						Amount__c=lead.Amount__c,
						//Product_Of_Interest__c=lead.Product_Of_Interest__c,
						//Product_Family_Latam__c=lead.Product_Family_Latam__c,
						Product_Of_Interest_Latam__c=lead.Product_Of_Interest_Latam__c,
						Do_not_create_opportunity__c=lead.Do_not_create_opportunity__c,
						Zip_Code_Auto_Route__c=true, Cancel_Workflow__c=true,
						Product_Family_GPL__c=lead.Product_Family_GPL__c,
						Product_of_Interest_GPL__c=lead.Product_of_Interest_GPL__c
						);

		try{
			system.debug('Updating Lead *****');
			if(!lead.Do_not_create_opportunity__c && lead.Amount__c == NULL){
			    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Amount field is required if an Opportunity is being created.\n'+
			                        'If no Opportunity is being created, please check the "Do Not Create Opportunity" checkbox.' ));
			    return null;
			}
			else{
			    update lead;

			    try{
				String finishURL = convertingLeads.doConvert(lead.Id);
				System.debug('*** finishURL *** ' + finishURL);
				if(finishURL.containsIgnoreCase('/')){
					PageReference reDirect = new PageReference(finishURL).setRedirect(true);
					return reDirect;
				}
				else{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, finishURL ));
					return null;
				}
    			}
    			catch(Exception e){
    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
    				return null;
    			}//end of catch
			}//end of else

/*
            String finishURL = convertLead.doConvert(lead.Id);
            system.debug('Just converted Lead *****');
            system.debug('finishURL ***** ' + finishURL);
            PageReference reDirect = new PageReference(finishURL).setRedirect(true);
            system.debug('reDirect ***** ' + reDirect);
            return reDirect;
*/
            //String finishURL;
			//String finishURL = convertLead.doConvert(lead.Id);
			//system.debug('Just converted Lead *****');
			//system.debug('finishURL ***** ' + finishURL);



		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
			return null;
		}//end of outter catch

	}
	//end of method to save product information

	 public PageReference removeContact(){
		 lead = new Lead(Id=lead.Id, Contact__c=Null);
		 update lead;

		 return new PageReference('/apex/LeadConversionAccount?id='+lead.Id).setRedirect(true);
	 }

		//method to convert lead
		webservice static String doConvert(Id l){
			system.debug('START OF DO CONVERT PROCESS *****');
			PageReference finishURL;
			String tempAcctId;
			Contact tempContact;
			List<Account_Contact__c> tempMultiList;
			Lead leadContactId;
			Opportunity ExistingOpportunity;
			List<String> errors = new List<String>();

			Lead convertlead = [SELECT Id,Product_Of_Interest_Latam__c,Product_Of_Interest__c,Account__c,Contact__c,Existing_Opportunity__c,
													Do_not_create_opportunity__c, Product_Family_Latam__c,Product_Family__c, Description, RecordTypeId,
													Product_Family_GPL__c, Product_of_Interest_GPL__c, Business_Unit__c
													FROM Lead WHERE Id=:l LIMIT 1];

			Database.LeadConvert lc = new database.LeadConvert();
			lc.setLeadId(convertlead.Id);
			lc.setConvertedStatus('Qualified');
			lc.setAccountId(convertlead.Account__c);

			//handle process for Contact__c and Existing_Opportunity__c
			if(convertlead.Contact__c != null){
				system.debug('CONTACT IS NOT NULL ***** ' + convertLead.Contact__c);
					leadContactId = [SELECT Contact__r.AccountId FROM Lead WHERE Id=:convertlead.Id];
					if(leadContactId.Contact__r.AccountId != convertlead.Account__c){
							tempMultiList = [SELECT Contact__c FROM Account_Contact__c WHERE Account__c=: convertlead.Account__c];
							if (tempMultiList != null){
									Set<Id> contactList = new Set<Id>();
									for(Account_Contact__c ac:tempMultiList){
											contactList.add(ac.Contact__c);
									}
									if(contactList.contains(convertLead.Contact__c)){
											tempContact = [SELECT Id, AccountId FROM Contact WHERE Id = :convertlead.Contact__c ];
											tempAcctId=tempContact.AccountId;
											tempContact.AccountId=convertlead.Account__c;
											update tempContact;
									} else {
											errors.add('Existing Contact must be attached to Existing Account');
									}
							}

					}
					lc.setContactId(convertlead.Contact__c);
			}

			/*
			if(convertLead.Existing_Opportunity__c != null){
				system.debug('Existing_Opportunity__c IS NOT NULL ***** ' + convertLead.Existing_Opportunity__c);
					ExistingOpportunity = [SELECT Product_Family__c, Product_Family_Latam__c FROM Opportunity WHERE Id=:convertlead.Existing_Opportunity__c LIMIT 1];
					if(convertlead.RecordTypeId == '012E0000000RHE7' && (convertlead.Product_Family_Latam__c != ExistingOpportunity.Product_Family_Latam__c) ){
							errors.add('Product Family must match on Lead and Existing Opportunity');
					}

					if(convertlead.RecordTypeId != '012E0000000RHE7' && (convertlead.Product_Family__c != ExistingOpportunity.Product_Family__c) ){
							errors.add('Product Family must match on Lead and Existing Opportunity');
					}

					lc.setDoNotCreateOpportunity(true);

			} else if(convertlead.do_not_create_opportunity__c == true){
				system.debug('DO NOT CREATE AN OPP ***** ');
					lc.setDoNotCreateOpportunity(true);
			} else {
				system.debug('WILL CREATE AN OPP ***** ');
					lc.setDoNotCreateOpportunity(false);
			}
			//end of Contact__c and Existing_Opportunity__c logic
			*/

			if(convertlead.do_not_create_opportunity__c == true){
				system.debug('DO NOT CREATE AN OPP ***** ');
					lc.setDoNotCreateOpportunity(true);
			} else {
				system.debug('WILL CREATE AN OPP ***** ');
					lc.setDoNotCreateOpportunity(false);
			}

			System.debug('*** errors.size() *** ' + errors.size() );

			//process to convert lead
			if(errors.size() == 0){
					System.debug('*** errors.size() == 0 *** ');
					LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
					lc.setConvertedStatus(convertStatus.MasterLabel);
					Database.LeadConvertResult lcr = Database.convertLead(lc);
					System.debug('AFTER CONVERT ***** ');
					if(tempContact != null){
							tempContact.AccountId=tempAcctId;
							update tempContact;
					}

					/*
					if(convertLead.Existing_Opportunity__c != null){
						system.debug('IN OPP CONTACT ROLE STUFF ***** ' + convertLead.Existing_Opportunity__c);
							if(convertLead.Contact__c == null && [SELECT count() from OpportunityContactRole where OpportunityId =:convertLead.Existing_Opportunity__c AND ContactId =:lcr.getContactId() ] == 0){
									OpportunityContactRole ocr = new OpportunityContactRole();
									ocr.OpportunityId = convertLead.Existing_Opportunity__c;
									ocr.ContactId = lcr.getContactId();
									ocr.Role = 'Other';
									insert ocr;
							}else if(convertLead.Contact__c != null && [SELECT count() from OpportunityContactRole where OpportunityId =:convertLead.Existing_Opportunity__c AND ContactId =:convertLead.Contact__c ] == 0){
									OpportunityContactRole ocr = new OpportunityContactRole();
									ocr.OpportunityId = convertLead.Existing_Opportunity__c;
									ocr.ContactId = convertLead.Contact__c;
									ocr.Role = 'Other';
									insert ocr;
							}
					}
					*/

					if(lcr.isSuccess()){
							system.debug('LCR.ISSUCCESS ***** ');
							//if(convertLead.Existing_Opportunity__c != null){
								//system.debug('Redirect to Existing Opportunity *****');
									//finishURL = new PageReference('/' + convertLead.Existing_Opportunity__c); }
							if(convertLead.do_not_create_opportunity__c == true){
								system.debug('CONTACT URL ***** ');
									finishURL = new PageReference('/' + lcr.getContactId());
							}else{
								system.debug('OPPORTUNITY URL ***** ');
									finishURL = new PageReference('/' + lcr.getOpportunityId());
							}
							return finishURL.getUrl();
					}else{
						system.debug('FAILED ***** ');
							return 'fail';
					}
			} else {
					String allErrors = 'ERROR! Please fix the following errors:\n\n';
					for(String e: errors){
							allErrors += e + '\n\n';
					}

					return allErrors;
			}
			//end of process to convert lead

		}
		//end of webservice lead convert

}//end of class