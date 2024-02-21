@isTest
public class BulkXrefTest {
    static testMethod void BulkXrefTest(){
    	Account acct1 = new Account(name='test account');
    	insert acct1;
        Product2 prod1 = new Product2(name='testprod');
        insert prod1;
        Product2 prod2 = new Product2(name='testprod2');
        insert prod2;
        Product2 prod3 = new Product2(name='testprod3');
        insert prod3;
        Cross_Reference__c cr1 = new Cross_Reference__c(Competitor_Name__c='Bard', Competitor_Product_Code__c='ABC123');
        insert cr1;
        Cross_Reference_Project__c crp1 = new Cross_Reference_Project__c(Account__c=acct1.Id);
        insert crp1;

        bulkXRefController.pullXref('ABC123',string.valueof(crp1.Id));

        List<Cross_Reference_Project_Item__c> crpi1 = [SELECT Id FROM Cross_Reference_Project_Item__c WHERE Cross_Reference_Project__c = :crp1.Id];
        if(crpi1.size() > 0){
        	 bulkXRefController.pullItems(string.valueof(crp1.Id));
        	 bulkXRefController.pullRelationships(string.valueof(crp1.Id));
        	 bulkXRefController.commitChange(cr1.Competitor_Product_Code__c,string.valueof(cr1.Id),'','','',string.valueof(crp1.Id));
        	 bulkXRefController.commitChange(cr1.Competitor_Product_Code__c,string.valueof(cr1.Id),string.valueof(cr1.Id),string.valueof(cr1.Id),string.valueof(cr1.Id),string.valueof(crp1.Id));
        	 bulkXRefController.pullDescriptors(string.valueof(crp1.Id),string.valueof(cr1.Id));
        	 bulkXRefController.removeRecord(cr1.Competitor_Product_Code__c);
        }
		
		Internal_Cross_Reference__c icr1 = new Internal_Cross_Reference__c(Cross_Reference_Product__c=string.valueof(prod1.Id),Product__c=string.valueof(prod2.Id));
		insert icr1;
		icr1.Product__c=prod3.Id;
		update icr1;
		delete icr1;
		
    }
}