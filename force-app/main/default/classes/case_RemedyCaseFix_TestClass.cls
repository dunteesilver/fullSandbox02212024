@istest
private class case_RemedyCaseFix_TestClass {
    static testMethod void validate_case_RemedyCaseFix() {
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
            FirstName ='Test1',
               
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
        
        c.ContactId = con.Id;
        master_TriggerHelperClass.runOnce('resetOnceSet');
        update c;
        
        c.ContactId = con2.Id;
        master_TriggerHelperClass.runOnce('resetOnceSet');
        update c;

    } 
}