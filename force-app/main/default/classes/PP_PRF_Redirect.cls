public class PP_PRF_Redirect {
    
    public PP_PRF_Redirect(ApexPages.StandardController controller) {

    }

    string qid  {get; set;}
    
    public pagereference redirect(){
        qid = ApexPages.currentPage().getParameters().get('id');
        PageReference prf_redirect = New Pagereference('/apex/PP_PRF?id='+qid);
        prf_redirect.setRedirect(true); 
        return prf_redirect;
    }

}