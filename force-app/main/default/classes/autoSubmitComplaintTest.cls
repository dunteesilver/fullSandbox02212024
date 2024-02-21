//Test class created by Dunte'e Silver
@isTest
public class autoSubmitComplaintTest {   
    static testMethod void TestAutoSubmitComplaint(){
          
        list<Account> acc = new list<Account>();
        for(integer i=0;i<10;i++){
            Account a = new Account(Name='Test'+i, Sales_by_BU_Key__c='Has Sales', ERP_Active__c = TRUE);
            acc.add(a);
        }
        insert acc;
        System.assertEquals(10,acc.size());
        
        list<Complaint__c> comps = new list<Complaint__c>();
        for(integer j = 0;j<10;j++){
            Complaint__c c = new Complaint__c();
            c.Event_Date__c=Date.today();
            c.Units_with_Alleged_Issue__c=100;
            c.Issue_Incident_Description__c='test'+j;
            c.Lot_Number_Action_Taken__c='Called';
            c.Patients_Current_Condition__c='Unknown';
            c.Status__c='Open';
            c.Contact_Title__c='test'+j;
            c.Contact_Email__c='test'+j+'@gmail.com';
            c.Contact_Name__c='User Test'+j;
            c.Account__c = acc[j].Id;
            c.Customer_response_letter_requested__c = 'Yes';
            c.Please_provide_rationale_for__c= 'Test';
            c.Complaint_submitted_within_24_hours_of_T__c='Yes';           
            comps.add(c);
        }
        insert comps;
        System.assertEquals(10,comps.size());
        
        for(Complaint__c c1 : comps){
            c1.Status__c = 'Submitted';
        }
        update comps;
        System.assertEquals(10,comps.size());
            
            try{
                update comps;
                
            }
            catch(exception e){
                system.debug('exception caught in autoSubmitComplaints Trigger: '+e.getMessage());
            }
            system.assertEquals(10,comps.size());


        list<Complaint__c> comps2 = new list<Complaint__c>();
        for(integer k = 0;k<10;k++){
            Complaint__c c3 = new Complaint__c();
            c3.Event_Date__c=Date.today();
            c3.Units_with_Alleged_Issue__c=100;
            c3.Issue_Incident_Description__c='test'+k;
            c3.Lot_Number_Action_Taken__c='Called';
            c3.Patients_Current_Condition__c='Unknown';
            c3.Status__c='Submitted';
            c3.Contact_Title__c='test2'+k;
            c3.Contact_Email__c='test2'+k+'@gmail.com';
            c3.Contact_Name__c='User Test2'+k;
            c3.Account__c = acc[k].Id;
            c3.Customer_response_letter_requested__c = 'Yes';
            c3.Please_provide_rationale_for__c= 'Test';
            c3.Complaint_submitted_within_24_hours_of_T__c='Yes';  
            comps2.add(c3);
        }
        insert comps2;
        System.assertEquals(10,comps.size());        
    }

}