@isTest
public class Education_Record_Utility_Test {
  
    Public static List<Education_Record__c> createTestRecords(Integer numEducRecs) {
        
	  List<Account> accts = new List<Account>();
		 for(Integer i=0;i<numEducRecs;i++) {
             
            Account a = new Account(name='TestAccount'+i);
            accts.add(a); 
        }

        insert accts;

        List<Contact> cons = new List<Contact>();

        for (Integer i=0;i<numEducRecs;i++) {

            Account acct = accts[i];           
			
            Contact c = (new Contact(firstname='Test'+i,
									lastname='Test'+i,
                                    email = 'abc@123.com'+i, 
                                    Position_Job_Title__c='Administrator'+i,
                                    Credentials__c='RN'+i,
                                    Preferred_language__c='English (American)'+i,
									AccountId=acct.Id));
            cons.add(c);

            }

        insert cons;

  	    List<Education_Record__c> edrecs = new List<Education_Record__c>();

        for (Integer i=0;i<numEducRecs;i++) {

            Account acct1 = accts[i];   
            
			Contact con1 = cons[i];
            
            Profile__c profTest = new Profile__c(
                
                First_Name__c = 'Prof1',
                Name = 'Last1',
                //	CEM__c = ManagerTest.Id,
                Phone_Number__c = '9192223333',
                Mailing_Address__c = '123 Test St',
                Mailing_City__c = 'Raleigh',
                Mailing_State__c = 'NC',
                Mailing_Zip__c = '27610',
                Mailing_Country__c = 'US',
                E_mail_Address__c = 'andreina.mendoza@teleflex.com',
                Hourly_Rate__c = 50,
                Status__c = 'Active' // Another Fix 25Oct2016 - ESC
            );
            insert profTest;
            
            Education_Record__c er = (new Education_Record__c(
                Name='Education Record Test'+i,
                recordtypeid='012E000000095BM',
                Account_Facility__c=acct1.Id,
                Contact_Name__c = con1.id,
                Hotel_Requested__c = 'No', // This is what fixes all the validation rule errors - ESC
                Clinical_Educator__c = profTest.id 
            ));
            edrecs.add(er);
            
        }

        insert edrecs;
        return edrecs;

    }
    

}