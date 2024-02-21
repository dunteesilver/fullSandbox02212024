public class Contract_Partnership_Helper_Class {
    
    public static void validateAccount(List<Contract_Partnership__c> newTrigger){
        map<String, Boolean> accountCheck = new map<String, Boolean>();
        
        for(Contract_Partnership__c cp : newTrigger){
            accountCheck.put(cp.Ship_to__c, FALSE);
            accountCheck.put(cp.Sale_to__c, FALSE);
        }
        
        System.debug('*** accountCheck.size() *** ' + accountCheck.size() );
        System.debug('*** accountCheck *** ' + accountCheck );
        List<Account> accountList = new List<Account>();
        if(accountCheck.size() > 0 ){
            System.debug('*** Contract_Partnership_Helper_Class validateAccount accountList.size > 0 ***');
            accountList = [SELECT Id, SAP_Sold_To__c 
                         FROM Account
                         WHERE SAP_Sold_To__c =:accountCheck.keySet()];
        
            for(Account a : accountList)
            {
                accountCheck.put(a.SAP_Sold_To__c, TRUE);
            }
            
            for(Contract_Partnership__c cp : newTrigger){
                if(accountCheck.get(cp.Ship_to__c) == FALSE){
                    cp.Ship_to__c = NULL;
                    cp.Disabled__c = TRUE;
                }
                else if(accountCheck.get(cp.Sale_to__c) == FALSE){
                    cp.Sale_to__c = NULL;
                    cp.Disabled__c = TRUE;
                }
                else{
                    cp.Disabled__c = FALSE;
                }
            }
            
        }//end if   
        
    }//end validateAccount
}//end class