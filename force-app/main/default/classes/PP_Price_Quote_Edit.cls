public class PP_Price_Quote_Edit {
    private Price_Quote__c pq;

    public PP_Price_Quote_Edit(){
        pq = new Price_Quote__c();

        if(ApexPages.currentPage().getParameters().get('pqid') != NULL){
            pq = [SELECT Price_Quote_Name__c, Quote_Description__c, Expiration_Date__c, Internal_Comments_Only__c, Customer_comments__c, Status__c,
                  No_Opp__c,Opportunity__c, One_Time_Purchase__c,PRF__c,InApproval__c,Opportunity__r.Price_Quote__c, Shipping__c, Tax__c, Discount__c,
                  Discounted_Total__c, Discount_Type__c, Type__c, Sales_Org_Key__c, BusinessUnit__c, Owner_Business_Unit__c
                  FROM Price_Quote__c
                  WHERE Id = :ApexPages.currentPage().getParameters().get('pqid')];
        }
        system.debug('pq.Status__c ***** ' + pq.Status__c);
    }

    public Price_Quote__c getpq(){
        return pq;
    }

    public PageReference save() {

        pq = new Price_Quote__c(
            Id = ApexPages.currentPage().getParameters().get('pqid'),
            Quote_Description__c = pq.Quote_Description__c,
            Expiration_Date__c = pq.Expiration_Date__c,
            Customer_comments__c = pq.Customer_comments__c,
            Internal_Comments_Only__c = pq.Internal_Comments_Only__c,
            No_Opp__c = pq.No_Opp__c,
            One_Time_Purchase__c = pq.One_Time_Purchase__c,
            Opportunity__c = pq.Opportunity__c,
            Shipping__c = pq.Shipping__c,
            Tax__c = pq.Tax__c,
            Discount__c = pq.Discount__c,
            Discount_Type__c = pq.Discount_Type__c,
            Type__c = pq.Type__c
        );

        //Logic for ASK Agreements
        if(pq.Type__c == 'ASK Agreement'){
            pq.One_Time_Purchase__c = true;
        }
        //end of ASK Agreement logic
        //
        try{
            update pq;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
        PageReference redir = New Pagereference('/apex/PP_Price_Quote?pqid=' + ApexPages.currentPage().getParameters().get('pqid'));
        redir.setRedirect(true);
        return redir;


        /*
         * We do not need this update anymore, the trigger handles all of this updates between PQ and Opp - ESC - 30Jun2016
        system.debug('pq.Opportunity__c ***** ' + pq.Opportunity__c);
        if(pq.Opportunity__c != NULL){
            system.debug('CHECKING ***** ' + pq.Opportunity__c);
            Opportunity opp = [SELECT Id, Name, Price_Quote__c FROM Opportunity WHERE Id =:pq.Opportunity__c];

            if(opp.Price_Quote__c != pq.Id){

                // Do we delete the old lines from the old Opp
            }
            pq.Opportunity__c = opp.Id;
            opp.Price_Quote__c = pq.Id;
            try{
                update pq;
                update opp;
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                return null;
            }
            PageReference redir = New Pagereference('/apex/PP_Price_Quote?pqid=' + ApexPages.currentPage().getParameters().get('pqid'));
            redir.setRedirect(true);
            return redir;

        }
        else{
            try{
                update pq;
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                return null;
            }
            PageReference redir = New Pagereference('/apex/PP_Price_Quote?pqid=' + ApexPages.currentPage().getParameters().get('pqid'));
            redir.setRedirect(true);
            return redir;
        }
        */

    }//end save method

    public PageReference cancel() {

        PageReference redir = New Pagereference('/apex/PP_Price_Quote?pqid=' + ApexPages.currentPage().getParameters().get('pqid'));
        redir.setRedirect(true);
        return redir;
    }



}