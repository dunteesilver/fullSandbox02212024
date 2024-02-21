public class PP_Quote_Redirect {

    public PP_Quote_Redirect(ApexPages.StandardController controller) {

    }

    string qid  {get; set;}
    
    public pagereference redirect(){
        qid = ApexPages.currentPage().getParameters().get('id');
        PageReference quote_redirect = New Pagereference('/apex/pp_price_quote?pqid='+qid);
        quote_redirect.setRedirect(true); 
        return quote_redirect;
    }
    
}