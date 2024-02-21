/*********************************************************************
* Description      : Test coverage for demoAssigned VPS process.
* Test Class       : PP_Global_Search_Test
* VisualForce      : PP_Global_Search
* Author(s)        : Dun Silver
**********************************************************************/
Public with sharing class PP_Global_Search{
    Public transient List<Account> conCustList {get;set;}
    Public transient List<Product2> conMatList{get;set;}
    Public transient List<Contract_Header__c> conHeadList{get;set;}
    Public transient List<Price_Quote__c> quoteList{get;set;}
    Public transient List<Price_Quote__c> newQuoteList{get;set;}
    Public transient List<Prf__c> prfList{get;set;}
    Public transient List<Prf__c> newPrfList{get;set;}
    Public Boolean emeaUserFlag {get; set;}
    
    //URL string for passing variables to VF pages
    Public transient String searchStr{get;set;}
    
    // Start New Pricing Tier Variables - May 22 ESC
    public list<String> tierHeaderList {get; set;}
    public list<String> tierHeaderListName {get; set;}
    
    public map<String, PP_Pricing_Tiers.tiers> tierMap {get; set;}
    public map<String, list<PP_Pricing_Tiers.tiers>> newTierMap {get; set;}
    //end user language
    //get user language
    public String userLang{get{
        return UserInfo.getLanguage();
    }set;}
    
    // End New Pricing Tier Variables
    
    //get active sales org key of User
    public String myActiveSalesOrg { get{
        String myActiveSalesOrg1 ='';
        try{
            myActiveSalesOrg1 = [SELECT Active_Sales_Org_Key__c
                                 FROM Contract_User__c
                                 WHERE User__c = :UserInfo.getUserId()
                                 LIMIT 1].Active_Sales_Org_Key__c;
            
            if(myActiveSalesOrg1 == '' || myActiveSalesOrg1 == NULL){
                myActiveSalesOrg1 = 'US6010';
            }
            //System.debug('*** myActiveSalesOrg get/set ***' + myActiveSalesOrg);
        }
        catch(Exception e){
            System.debug('Exception occured in PP_Global_Search myActiveSalesOrg: ' + e);
        }
        
        return myActiveSalesOrg1;
    } set;}
    
    public Integer pricingTierAccessLevel { get{
        try{
            Decimal pricingTierAccessLevelDeci = [SELECT Pricing_Tier_Access__c
                                                  FROM Contract_User__c
                                                  WHERE User__c = :UserInfo.getUserId()
                                                  LIMIT 1].Pricing_Tier_Access__c;
            
            pricingTierAccessLevel = integer.valueOf(pricingTierAccessLevelDeci);
            if(pricingTierAccessLevel == NULL){
                pricingTierAccessLevel = 1;
            }
            //System.debug('*** pricingTierAccessLevel get/set ***' + pricingTierAccessLevel);
        }
        catch(Exception e){
            System.debug('Exception occured in PP_Global_Search pricingTierAccessLevel: ' + e);
        }
        
        return pricingTierAccessLevel;
    } set;}
    
    //Constructor
    Public PP_Global_Search(){
        //set variable to parameter passed in URL
        searchStr = ApexPages.currentPage().getParameters().get('srch');
        System.debug('*** searchStr in Global Search Constructor ===================================== ' + searchStr);
        system.debug('*** Sales Org Work? ' + PP_Menu.salesOrg);
        if(searchStr != NULL){
            searchStr = searchStr.trim();
        }
        
        //list containers for each object in SOSL query
        conCustList = New List<Account>();
        conMatList = New List<Product2>();
        conHeadList = New List<Contract_Header__c>();
        quoteList = New List<Price_Quote__c>();
        newQuoteList = new List<Price_Quote__c>();
        prfList = New List<Prf__c>();
        newPrfList = New List<Prf__c>();
        string search_SalesOrg = '';
        string activeSalesOrg = myActiveSalesOrg;
        String salesOrg = myActiveSalesOrg.left(4);
        String distChannel = myActiveSalesOrg.right(2);
        
        Sales_Orgs__c  srkey = Sales_Orgs__c.getInstance(myActiveSalesOrg);
        emeaUserFlag = false;
        if(srkey?.Region__c !='' && srkey?.Region__c =='EMEA'){
            emeaUserFlag = true;

        }else{
            emeaUserFlag = false;
        }
        
        System.debug('*** activeSalesOrg *** ' + activeSalesOrg);
        if(activeSalesOrg != NULL){
            //new logic makes variables dynamic to condense logic
            //Sales_Org_Key__c = \'' + activeSalesOrg + '\'
            search_SalesOrg = 'Where Sales_Org__c = \'' + salesOrg + '\' AND SearchableProducts__c = TRUE AND Distribution_Channel__c = \'' + distChannel + '\' AND Duplicate__c = false';
            system.debug('*** search_SalesOrg: ' + search_SalesOrg);
        }
        
        //error checking to handle null and empty strings
        System.debug('*** searchStr *** ' + searchStr);
        if( (searchStr != null && searchStr != '') && searchStr.length() > 1 ){
            //String searchStr1 = '*'+searchStr+'*';
            transient String searchQuery = 'FIND \'' + searchStr + '\' IN ALL FIELDS RETURNING Account(SAP_Sold_To__c,Name,Account_Name_2__c,ShippingStreet,' +
                'ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry, Account_Group__c, Type, Customer_Group_Name__c, Main_GPO__c, Secondary_GPO__c,' +
                'Customer_Group__c WHERE (Account_Group__c = \'Z001\' OR Account_Group__c = \'Z002\' OR Account_Group__c = \'ZREB\') AND Sales_Org_Key__c = \'' + activeSalesOrg + '\' AND zBlock__c = \'00\' AND Account_Number__c != \'' + searchStr + '\' ORDER BY Name),' +
                'Product2(Id,Name,Brand_Name__c, Description,Class__c, Sales_Unit__c, Qty_Sales_Unit__c,Image_URL__c, CurrencyIsoCode, Sales_Org__c, Distribution_Channel__c, List_Price__c, RSM_Price__c, Rep_Price__c, Director_Price__c, Floor_Price__c, Distributor_List__c, Alt_Site_List__c, Material_Status__c, MRP_Group__c, DChain_Material_Status__c ' + search_SalesOrg + ' ORDER BY Name),' +
                'Contract_Header__c (Name,Agreement_Number__c, Description__c,Owner__c,Owner_Name__c,GPO_Contract_Ref__c,Valid_From__c,Valid_To__c,Divisions__c WHERE Active_Future__c = true AND Sales_Org__c = \'' + salesOrg + '\' AND Distribution_Channel__c = \'' + distChannel + '\'),' +
                'Price_Quote__c (Id,Name,Account_Name__r.SAP_Sold_To__c,Account_Name__r.Name,Account_Name__r.BillingCountry,Contact_Name__r.Name,Grand_Total__c WHERE Sales_Org_Key__c = \'' + activeSalesOrg + '\'),' +
                'Prf__c (Id,Name,Account__r.SAP_Sold_To__c,Account__r.Name,Account__r.BillingCountry,Contact__r.Name WHERE Sales_Org_Key__c = \'' + activeSalesOrg + '\')';
            
            system.debug('*** searchQuery: ' + searchQuery);
            
            //add searchQuery to a lists
            List<List <sObject>> searchList = search.query(searchQuery);
            System.debug('*** searchList *** ' + searchList);
            conCustList = ((List<Account>)searchList[0]);
            conMatList  = ((List<Product2>)searchList[1]);
            conHeadList = ((List<Contract_Header__c>)searchList[2]);
            quoteList = ((List<Price_Quote__c>)searchList[3]);
            prfList = ((List<Prf__c>)searchList[4]);
            Set<Id> accId = new Set<Id>();
            Set<Id> accPrfId = new Set<Id>();
            List<UserRecordAccess> recAccessIds = new List<UserRecordAccess>();
            List<UserRecordAccess> recPrfAccessIds = new List<UserRecordAccess>();
            List<Id> recordIds = new List<Id>();
            List<Id> recordPrfIds = new List<Id>();
            
            System.debug('*** conMatList *** ' + conMatList );
            System.debug('*** conCustList.size() Constr *** ' + conCustList.size() );
            System.debug('*** conMatList.size() *** Constr ' + conMatList.size() );
            System.debug('*** conHeadList.size() *** Constr ' + conHeadList.size() );
            System.debug('*** quoteList.size() *** Constr ' + quoteList.size() );
            System.debug('*** prfList.size() *** Constr ' + prfList.size() );
            //loop to get account ids from price quotes in list
            for(Price_Quote__c curr : quoteList){
                accId.add(curr.Account_Name__c);
            }
            System.debug('*** accId.size() *** ' + accId.size() );
            
            //loop to get account ids from prfs in list
            for(PRF__c curr : prfList){
                //accountId = curr.Account_Name__c;
                //trimAccId = accountId.left(15);
                accPrfId.add(curr.Account__c);
            }
            System.debug('*** accPrfId.size() *** ' + accPrfId.size() );
            
            // Used to return the Text Status. Example: 40 = Saleable (40)
            PP_General_Helper_Class ghc = new PP_General_Helper_Class();
            map<String, String> mstatMap = ghc.mstatus();
            
            //loop to get Product Status
            for(Product2 curr: conMatList){
                //System.debug('*** curr.DChain_Material_Status__c *** ' + curr.DChain_Material_Status__c);
                if(curr.DChain_Material_Status__c != NULL){
                    curr.DChain_Material_Status__c = mstatMap.get(curr.DChain_Material_Status__c);
                }
                
            }
            
            //get list of ids user has access to
            recAccessIds = [SELECT RecordId FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND HasReadAccess = true AND RecordId IN :accId];
            recPrfAccessIds = [SELECT RecordId FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND HasReadAccess = true AND RecordId IN :accPrfId];
            
            for(UserRecordAccess curr : recAccessIds){
                recordIds.add(curr.RecordId);
            }
            System.debug('*** recordIds.size() *** ' + recordIds.size() );
            
            for(UserRecordAccess curr : recPrfAccessIds){
                recordPrfIds.add(curr.RecordId);
            }
            System.debug('*** recordPrfIds.size() *** ' + recordPrfIds.size() );
            
            for(Price_Quote__c curr : [SELECT Id,Name,Account_Name__r.SAP_Sold_To__c,BusinessUnit__c,Account_Name__r.Name,Account_Name__r.BillingCountry,Contact_Name__r.Name,Grand_Total__c, Account_Name__c
                                       FROM Price_Quote__c
                                       WHERE Account_Name__c IN :recordIds
                                       AND Id IN :quoteList]){
                                           newQuoteList.add(curr);
                                       }
            System.debug('*** newQuoteList.size() *** ' + newQuoteList.size() );
            
            for(Prf__c curr : [SELECT Id,Name,Account__r.SAP_Sold_To__c,Account__r.Name,Account__r.BillingCountry,Contact__r.Name, Account__c
                               FROM Prf__c
                               WHERE Account__c IN :recordPrfIds
                               AND Id IN :prfList]){
                                   newPrfList.add(curr);
                               }
            System.debug('*** newPrfList.size() *** ' + newPrfList.size() );
            
            //error check for empty list returns
            if(conHeadList.size() == 0 && conMatList.size() == 0 && conCustList.size() == 0
               && quoteList.size() == 0 && prfList.size() == 0){
                   apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sorry, no results returned with matching string...'));
                   return;
               }
            
        }
        else{
            //error checking to handle empty string submitted
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters...'));
            return;
        }//end of outter else
        
        system.debug('Starting New Pricing Tiers');
        // New Pricing Tiers - May 22 2018 - ESC
        // Stage 1 - Set the Variables/Environment
        
        //check if a product exist to get Pricing Tiers
        if( conMatList.size() > 0 ){
            tierMap = new map<String, PP_Pricing_Tiers.tiers>(); // Major map used to store the pricing matrix
            newTierMap = new map<String, list<PP_Pricing_Tiers.tiers>>();
            tierHeaderList = new list<String>(); // Used to store the final list of pricing levels in order: REP1, REP2, RSM1, etc.
            tierHeaderListName = new list<String>();
            //plist = new list<product2>(); // Holds the list of products
            //set<Id> pids = new set<Id>(); // Holds the set of product id's
            System.debug('*** tierMap 1 *** ' + tierMap);
            // Stage 2 - Ready the Lists/Sets
            //plist.add(prod); // List of Products to use to build the Pricing Tiers Table
            //pids.add(prod.Id); // Set of Id's to Pass to the Pricing Tier Map Method
            //List<Product2> prodList = new List<Product2>();
            
            // Stage 3 - Putting it all together
            PP_Pricing_Tiers newPT = new PP_Pricing_Tiers();
            tierMap =  newPT.getTiers(conMatList,pricingTierAccessLevel); // Pulls the map using a set of products
            
            //tierHeaderList = newPT.getTierHeaderNames(tierMap);
            System.debug('*** tierMap 2 *** ' + tierMap);
            tierHeaderList = newPT.getTierHeaderLevels(tierMap); // REP1, REP2, RSM1, etc.
            system.debug('tierMap: ' + tierMap);
            
            
            set<String> tempSet = new set<String>();
            
            for(PP_Pricing_Tiers.tiers pt : tierMap.values()){
                string key = pt.TierName + '-' + pt.Product_Name;
                tempSet.add(tierMap.get(pt.TierName + '-' + pt.Product_Name).TierName);
                
                if(newTierMap.containsKey(pt.TierName + '-' + pt.Product_Name)){
                    newTierMap.get(pt.TierName + '-' + pt.Product_Name).add(pt);
                    System.debug('*** pt if *** ' + pt);
                }
                else{
                    newTierMap.put(pt.TierName + '-' + pt.Product_Name, new list<PP_Pricing_Tiers.tiers>{pt});
                    System.debug('*** pt else *** ' + pt);
                }
            }
            //System.debug('*** newTierMap RREP-ML002EE *** ' + newTierMap.get('REP-ML002EE'));
            //System.debug('*** newTierMap RREP-003200 *** ' + newTierMap.get('REP-003200'));
            tierHeaderListName.addAll(tempSet);
            System.debug('*** tierHeaderListName *** ' + tierHeaderListName);        
            //End New Pricing Tiers 
        }//end if conMatList.size() check
        
    }//end of Global Search constructor
    
    public String getActiveQuoteIdStr() {
        String activeQuoteIdStr = '';
        //List<User> userList = [Select id, Active_Quote_Id__c from User Where Id=: UserInfo.getUserId()];
        
        List<Price_Quote__c> activeQuote =[SELECT Id
                                           FROM Price_Quote__c
                                           WHERE LastViewedDate != NULL
                                           AND sales_org_key__c= :myActiveSalesOrg
                                           ORDER BY LastViewedDate DESC limit 1];
        
        if(activeQuote.size() > 0) {
            activeQuoteIdStr = activeQuote[0].Id;
        }
        return activeQuoteIdStr;
    }
    
}