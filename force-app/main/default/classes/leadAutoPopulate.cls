public class leadAutoPopulate {

    public String accIndustry {get;set;}
    public String accNumber {get;set;}
    public Lead currentLead {get;set;}
    
    public leadAutoPopulate(ApexPages.StandardController stdController) {
        currentLead = (lead)stdController.getRecord();
    }
     
    public PageReference populateOtherFields()
    {
        Lead a = [Select Id, LastName, FirstName from Lead where Id=:currentLead.Contact__c];
        accIndustry = a.FirstName;
        accNumber = a.LastName;
        return null;
    }
}