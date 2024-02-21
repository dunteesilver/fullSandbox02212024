@isTest
public class Focus_Profile_Apxt_Helper_Test {
    
     static testmethod void createData() {
        
        Account acc = new Account();
        acc.Name = 'CXTestAcc';
        acc.SAP_Sold_To__c = '123456';
        acc.SAP_Code__c='123456';
        acc.Territory_Key__c='123456;234567';
        insert acc;
         
         Focus_Profile__c fpObj = new Focus_Profile__c();
         fpObj.Account__c = acc.Id;
         fpObj.Current_Status__c = 'test status';
         fpObj.Stage_of_Action__c = 'Stage of Action';
         fpObj.End_Customer__c = acc.SAP_Sold_To__c;
         insert fpObj;

         fpObj.Account__c = acc.Id;
         fpObj.Current_Status__c = 'test status';
         fpObj.Stage_of_Action__c = 'Stage of Action';
         fpObj.End_Customer__c = acc.SAP_Sold_To__c;
         update fpObj;

     }

}