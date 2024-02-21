//created by Dunte'e Silver
//class to handle batch update of Contact Business Unit for A&R split
global class batchUpdateContactBU implements Database.Batchable<sObject>
{
    public String query = 'SELECT Id, Business_Unit1__c FROM Contact WHERE Business_Unit1__c INCLUDES (\'Anesthesia\')';
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {
         for(Contact c : scope)
         {
             c.Business_Unit1__c += ';' + 'Respiratory';            
         }
         update scope;
    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}