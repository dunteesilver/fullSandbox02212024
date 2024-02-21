/******************************************************************************************************************************
    Class Name       : PP_creatQuoteContact
    Custom Button    : Create Quote (Contact Object)
    Created On       : June 17
    Created By       : Sankarsh
	Test Classes     : PP_creatQuoteContact_Test
    Purpose          : This class is used to create price quote from contact

*******************************************************************************************************************************/

global class PP_creatQuoteContact{

         webservice static String creatQuoteContact(Id cid){
             string salesCurrency;
             string salesOrgKey;
             string userBu;
             string userRoleName;
             Decimal pricingAccess;
             
             for(Contract_User__c cu : [SELECT Active_Currency__c, Active_Sales_Org_Key__c, Business_Unit__c, User__r.UserRole.Name, Pricing_Tier_Access__c
                                        FROM Contract_User__c
                                        WHERE User__c = :UserInfo.getUserId()
                                        LIMIT 1])
             {
                 salesCurrency = cu.Active_Currency__c;
                 salesOrgKey = cu.Active_Sales_Org_Key__c;
                 userBu = cu.Business_Unit__c;
                 userRoleName = cu.User__r.UserRole.Name;
                 pricingAccess = cu.Pricing_Tier_Access__c;
             }

             Id aid = [SELECT Accountid
                       FROM Contact
                       WHERE Id = :cid limit 1].Accountid;

             Price_Quote__c priceQuote = new Price_Quote__c(
                 Account_Name__c = aid,
                 Contact_Name__c =  cid,
                 Date__c = system.today(),
                 //Expiration_Date__c = system.today() +90,
                 CurrencyIsoCode = salesCurrency,
                 Sales_Org_Key__c = salesOrgKey,
                 BusinessUnit__c = userBu,
                 Pricing_Tier_Level__c = pricingAccess
             );

             //check for ANZ user and set Expiration date
             Date anzDate = system.today() +30; //date for ANZ
             Date allDate = system.today() +90; //date for Other BUs
             
             if(salesOrgKey == 'AU1010' || salesOrgKey == 'NZ1010'){
                 priceQuote.Expiration_Date__c = anzDate;
             }
             else{
                 priceQuote.Expiration_Date__c = allDate;
             }
             
             //check for Latin American User
             system.debug('salesOrgKey ' + salesOrgKey);
             if(salesOrgKey.right(2) == '20' || userRoleName.containsIgnoreCase('EMEA') ){
               priceQuote.One_Time_Purchase__c = true;
             }
             if(aid != NULL && cid != NULL){
                 insert priceQuote; 
             }
             
             return '/apex/PP_Price_Quote?pqId=' + priceQuote.Id;
         }//end of webservice method
    
    @AuraEnabled
    public static Price_Quote__c creatQuoteContactLightning(Id cid){
        string salesCurrency;
        string salesOrgKey;
        string userBu;
        string userRoleName;
        Decimal pricingAccess;

        Map<String,String> resultMap = new Map<String,String>();
        
        for(Contract_User__c cu : [SELECT Active_Currency__c, Active_Sales_Org_Key__c, Business_Unit__c, User__r.UserRole.Name, Pricing_Tier_Access__c
                                   FROM Contract_User__c
                                   WHERE User__c = :UserInfo.getUserId()
                                   LIMIT 1])
        {
            salesCurrency = cu.Active_Currency__c;
            salesOrgKey = cu.Active_Sales_Org_Key__c;
            userBu = cu.Business_Unit__c;
            userRoleName = cu.User__r.UserRole.Name;
            pricingAccess = cu.Pricing_Tier_Access__c;
        }
        
        Id aid = [SELECT Accountid
                  FROM Contact
                  WHERE Id = :cid limit 1].Accountid;
        
        Price_Quote__c priceQuote = new Price_Quote__c(
            Account_Name__c = aid,
            Contact_Name__c =  cid,
            Date__c = system.today(),
            //Expiration_Date__c = system.today() +90,
            CurrencyIsoCode = salesCurrency,
            Sales_Org_Key__c = salesOrgKey,
            BusinessUnit__c = userBu,
            Pricing_Tier_Level__c = pricingAccess
        );
        
        //check for ANZ user and set Expiration date
        Date anzDate = system.today() +30; //date for ANZ
        Date allDate = system.today() +90; //date for Other BUs
        
        if(salesOrgKey == 'AU1010' || salesOrgKey == 'NZ1010'){
            priceQuote.Expiration_Date__c = anzDate;
        }
        else{
            priceQuote.Expiration_Date__c = allDate;
        }
        
        //check for Latin American User
        system.debug('salesOrgKey ' + salesOrgKey);
        if(salesOrgKey.right(2) == '20' || userRoleName.containsIgnoreCase('EMEA') ){
            priceQuote.One_Time_Purchase__c = true;
        }
        
        if(aid != NULL && cid != NULL){
            insert priceQuote;
            resultMap.put('status','success');
            resultMap.put('message','Price Quote Successfully Created!');
        }
        else{
            resultMap.put('status','error');
            resultMap.put('message','Price Quote was NOT Created!' );
        }
        
        //return resultMap;
        return priceQuote;
    }//end of lightning method
    
}//end of class