/*********************************************************************
* Description      : Controller Class for BatchContactBU.
* Test Class       : BatchContactBUTest
* VisualForce      : N/A
* Author(s)        : Eric Clay
**********************************************************************/
global class BatchContactBU implements Database.Batchable<sObject> {

   List<Contact> c1 = new List<Contact>();

   global Database.QueryLocator start(Database.BatchableContext BC){
       String query = 'SELECT Id, Owner.Business_Unit__c, Owner.ProfileId, OwnerId, Business_Unit1__c  FROM Contact';
       return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       for(sObject s: scope){
           Contact c = (Contact) s;
           string OId=c.OwnerId;

           if(c.Owner.Business_Unit__c != null && c.Owner.Business_Unit__c != 'Cross BU' && c.Owner.Business_Unit__c != 'Latin America' && c.Owner.Business_Unit__c != 'Latin America Distributor' && c.Owner.ProfileId != '00eE0000000lT3QIAU'){
               if(c.Business_Unit1__c == null){
                   c.Business_Unit1__c = c.Owner.Business_Unit__c;
               }else if (!c.Business_Unit1__c.contains(c.Owner.Business_Unit__c)){
                   c.Business_Unit1__c = c.Business_Unit1__c+';'+c.Owner.Business_Unit__c;
               }
               c1.add(c);
           }
       }
       update c1;
   }

   global void finish(Database.BatchableContext BC){
   }
}