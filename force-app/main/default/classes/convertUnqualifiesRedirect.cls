public class convertUnqualifiesRedirect {
    Lead tempLead;
    private ApexPages.StandardController controller {get; set;}    
    
    public convertUnqualifiesRedirect(ApexPages.StandardController controller) {
        this.controller = controller;
        this.tempLead = (Lead)controller.getRecord();  
    }
    
    public PageReference unqualify() {
        if ( tempLead != null ) {
            tempLead.ownerID = '00GE0000000fW2U';
            tempLead.status = 'unqualifed';
            update tempLead;
        }
        PageReference newRef = new PageReference('/00Q/o');
        newRef.setRedirect(true);
        return newRef;
    }
}