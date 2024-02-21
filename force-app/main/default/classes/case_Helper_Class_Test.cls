/*********************************************************************
* Description     : Main test class for case_Helper_Class
* Covered Classes : case_Helper_Class
* Author(s)       : Dun Silver
**********************************************************************/

@isTest
public with sharing class case_Helper_Class_Test {
	static testMethod void testCases() {
			Account a = new Account(
					Name = 'Test PP Account',
					SAP_Sold_To__c ='100123',
					ShippingStreet='123 Main Street ',
					ShippingCity='Raleigh',
					ShippingState='NC',
					ShippingPostalCode='27614',
					Customer_Group__c = '19',
					zBlock__c = '00',
					Account_Group__c = 'Z001',
					ERP_Active__c = FALSE
			);
			//master_TriggerHelperClass.runOnce('resetOnceSet');
			insert a;

			Account a2 = new Account(
					Name = 'Teleflex Case Support Users',
					SAP_Sold_To__c ='100124',
					ShippingStreet='123 Main Street ',
					ShippingCity='Raleigh',
					ShippingState='NC',
					ShippingPostalCode='27614',
					Customer_Group__c = '19',
					zBlock__c = '00',
					Account_Group__c = 'Z001',
					ERP_Active__c = FALSE
			);
			//master_TriggerHelperClass.runOnce('resetOnceSet');
			insert a2;



			Contact con = new Contact(
					FirstName ='Test',
                    LastName = 'Test',
					AccountId = a.Id,
					email = 'abc@123.com',
                    Position_Job_Title__c='Administrator',
                    Credentials__c='RN',
                    Preferred_language__c='English (American)',
					Business_Unit1__c = 'Surgical Disposables'
			);
			insert con;

			Contact con2 = new Contact(
                    FirstName ='Test',
					LastName = 'Test2',
					AccountId = a2.Id,
					email = 'abc@123.com',
                    Position_Job_Title__c='Administrator',
                    Credentials__c='RN',
                    Preferred_language__c='English (American)',
					Business_Unit1__c = 'Surgical Disposables'
			);
			insert con2;


			Case c = new Case(
			Subject = 'Incident INC000000842915 has been assigned to your group CRM. Priority: Medium. Description: Need help to log in to SalesForce.com',
					Description = 'Incident INC000000845265 has been assigned to your group CRM. Customer: Clay, Eric Service Type: User Service Restoration Priority: Medium Summary: Error Message in Sales force Notes: Alfonso called in because they are getting an error message when opening an account in Sales force.',
					OwnerId = UserInfo.getUserId()
			);
			insert c;

			agf__ADM_Scrum_Team__c agfScrum = new agf__ADM_Scrum_Team__c(
				agf__Active__c = true,
				agf__Cloud__c = 'Shared Services',
				agf__Copy_Record_Type_Name__c = 'Scrum Team',
				agf__External_Name__c = 'Salesforce.com Team',
				agf__Kanban__c = true,
				Name = 'Salesforce.com Team'
			);
			insert agfScrum;

			agf__ADM_Product_Tag__c agfProd = new agf__ADM_Product_Tag__c(
				Name = 'Salesforce.com',
				agf__Active__c = true,
				agf__Team_Tag_Key__c = 'a3PE0000000kB8cMAE@Salesforce.com',
				agf__Team__c = agfScrum.Id
			);
			insert agfProd;

			agf__ADM_Work__c agfWork = new agf__ADM_Work__c(
				agf__Subject__c = c.Subject,
				agf__Details__c = c.Description,
				agf__Assignee__c = UserInfo.getUserId()
			);

			case_Helper_Class.getCase(c.Id);
			case_Helper_Class.createWorkObject(agfWork, c);
			//case_Helper_Class.createWorkLightning(c.Id);
	}//end of testCases Method

}