@isTest
public class complaints_update_test {

    public static testMethod void testOptOut(){
        
        Account a = new account(
            Name = 'Test',
            Sales_by_BU_Key__c = 'Has Sales',
             ERP_Active__c = TRUE
        );
        insert a;
        
        Product_List__c p = new Product_List__c (
            Name = '000-11'
        );
        insert p;
        
        Complaint__c c = new Complaint__c(
            Event_Date__c = date.today(),
            Units_with_Alleged_Issue__c = 1,
            Lot_Number_Action_Taken__c = 'Called',
            Issue_Incident_Description__c = 'Test',
            Patients_Current_Condition__c = 'Fine',
            Patient_exposed_to_infectious_disease__c = 'No',
            Contact_Name__c = 'Test User',
            Contact_Title__c = 'Director',
            Contact_Email__c = 'abc@123.com',
            Account__c = a.Id,
            Product_List__c = p.Id,
            Customer_response_letter_requested__c = 'Yes',
            Complaint_submitted_within_24_hours_of_T__c= 'Yes'
        );
        
        insert c;
        
        PageReference pageRef = new PageReference('/complaints_update?id=' + c.id );
        Test.setCurrentPage(pageRef);
        
        complaints_update controller = new complaints_update();
        
        complaints_update tc = new complaints_update();
        tc.save();
        tc.getComplaints();
        tc.cancel();
        
    }
    
    


    
    

    
    
}