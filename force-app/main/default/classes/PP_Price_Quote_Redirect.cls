public class PP_Price_Quote_Redirect {
    
    public PageReference redirect(){
        
        Opportunity opp = [SELECT Id, Price_Quote__c, Primary_Contact__c, AccountId, One_Time_Sale__c 
                          FROM Opportunity 
                          WHERE Id = :ApexPages.currentPage().getParameters().get('oid')];
        
        if(opp.Price_Quote__c != NULL){
            system.debug('ID Found: Navigating!');
            PageReference returnURL = new Pagereference('/apex/PP_Price_Quote?pqId=' + opp.Price_Quote__c).setRedirect(true);
            return returnURL;
        }
        else{
            system.debug('No ID: Creating PQ');

            Price_Quote__c newPQ = new Price_Quote__c(
                Account_Name__c = opp.AccountId,
                Opportunity__c = opp.Id,
                One_Time_Purchase__c = opp.One_Time_Sale__c
            );
            if(opp.Primary_Contact__c != NULL){
                newPQ.Contact_Name__c = opp.Primary_Contact__c;                
            }
            Opportunity updateOpp = new Opportunity(
                Id = Opp.Id,
                Price_Quote__c = newPQ.Id
            );
            update updateOpp;
            
            insert newPQ;
            system.debug('newPQ: ' + newPQ );
            
            PageReference returnURL = new Pagereference('/apex/PP_Price_Quote?pqId='+newPQ.Id).setRedirect(true);
            return returnURL;
            
        }
        
        
        

        /* Old Logic
        //PageReference returnURL;
        system.debug('Id: ' + ApexPages.currentPage().getParameters().get('id'));
        if(pqid.length() > 0){
            system.debug('ID Found: Navigating!');
            PageReference returnURL = new Pagereference('/apex/PP_Price_Quote?pqId=' + pqid).setRedirect(true);
            return returnURL;
        }
        else{
            system.debug('No ID: Creating PQ');

            boolean otp = FALSE;
            String cidString = ApexPages.currentPage().getParameters().get('cid');
            
            if(ApexPages.currentPage().getParameters().get('otp') == '0'){
                otp = TRUE;
            }

            Price_Quote__c newPQ = new Price_Quote__c(
                Account_Name__c = ApexPages.currentPage().getParameters().get('aid'),
                Opportunity__c = ApexPages.currentPage().getParameters().get('oid'),
                One_Time_Purchase__c = otp
            );
            if(cidString.length() > 0){
                newPQ.Contact_Name__c = cidString;                
            }
            Opportunity updateOpp = new Opportunity(
                Id = ApexPages.currentPage().getParameters().get('oid'),
                Price_Quote__c = newPQ.Id
            );
            update updateOpp;
            
            insert newPQ;
            system.debug('newPQ: ' + newPQ );
            
            PageReference returnURL = new Pagereference('/apex/PP_Price_Quote?pqId='+newPQ.Id).setRedirect(true);
            return returnURL;
            
        }
*/

        
        
    }

}