@istest
public class PP_Price_Quote_Edit_Test {
    @istest static void Test_Quote_Edit_Test(){
        Account a = new Account(
            Name = 'Test PP Account',
            SAP_Sold_To__c ='100123',
            ShippingStreet='123 Main Street ',
            ShippingCity='Raleigh',
            ShippingState='NC',
            ShippingPostalCode='27614',
            Customer_Group__c = '19'
        );
        insert a;
        system.debug('a:' + a);

        Contact c = new Contact(
            FirstName ='Test',
            email = 'abc@123.com',     
            lastname = 'Marcus',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
            AccountId = a.id
        );
        insert c;
        system.debug('c:' + c);

        Price_Quote__c pq = new Price_Quote__c(
            Account_Name__c = a.id,
            Contact_Name__c = c.id,
            Expiration_Date__c = Date.today() + 90
        );
        insert pq;
        system.debug('PQ:' + pq);

        PageReference pageRef2 = new PageReference('/apex/PP_Price_Quote_Edit?pqid=' + pq.Id);
        system.debug('PRF Page' + pageRef2);
        Test.setCurrentPage(pageRef2);

        PP_Price_Quote_Edit pqe = new PP_Price_Quote_Edit();
        pqe.getpq();
        pqe.save();
        pqe.cancel();


    }
}