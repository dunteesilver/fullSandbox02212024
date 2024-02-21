public class complaints_update {
    private final Complaint__c complaints;
    
    public complaints_update(){
        complaints = [SELECT Id, Name, Product_Description__c, Product_List__r.Name, Status__c, Rejection_Reason__c FROM Complaint__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }
    public Complaint__c getComplaints() {
        return complaints;
    }
    public PageReference save() {
        update complaints;
        
        PageReference redir = New Pagereference('/' + ApexPages.currentPage().getParameters().get('id'));
        redir.setRedirect(true); 
        return redir;
    }
    
    public PageReference cancel() {
        
        PageReference redir = New Pagereference('/' + ApexPages.currentPage().getParameters().get('id'));
        redir.setRedirect(true); 
        return redir;
    }
    
    
}