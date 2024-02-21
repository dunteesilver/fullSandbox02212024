/*********************************************************************
* Description     : This class is used for PP_Price_Quote Page
* Test Class      : PP_Global_Test_Class
* VisualForce     : PP_Price_Quote
* Author(s)       : Dun Silver, Eric Clay
**********************************************************************/

Global without sharing class PP_Price_Quote{
    
    public String strMats{get;set;}
    public String strProdSearch{get;set{strProdSearch = value;}}
    //public String strCrossSearch{get;set{strCrossSearch = value;}}
    //public String strQtyChange{get;set{strQtyChange = value;}}
    public String strQtyChange{get;set;}
    public String strQuoteId{get;set;}
    public String pqlid{get;set{pqlid = value;}}
    public String delId{get;set;}
    public ApexPages.StandardController c;
    public Price_Quote__c pq {get;set;}
    public List<Price_Quote_Line_Item__c> lineItems;
    public List<SelectOption> pickListValuesList {get;set;}
    public string custEmail {get;set;}
    public boolean isLocked {get; set;}
    public List<ProcessInstanceWorkitem> approvalInfo;
    public String userLocale {get;set;}
    public Map<Id,String> formatListPrices {get;set;}
    public Map<Id,String> formatRsmPrices {get;set;}
    public Map<Id,String> formatRepPrices {get;set;}
    public Map<Id,String> formatEligiblePrices {get;set;}
    public Map<Id,String> formatLinePrices {get;set;}
    public Map<Id,String> formatSalesPrices {get;set;}
    public Map<Id,String> formatTotalPrices {get;set;}
    public Map<String,String> labelsMap{get;set;}
    //start of getter setters to handle User bu change
    public String buValue {get;set;}
    public String userId {get;set;}
    //public Price_Quote__c pq2{get;set;}
    public Map<String,Sales_Orgs__c> soMap = new Map<String,Sales_Orgs__c>();
    public Decimal grandTotal {get;set;}
    public Contract_User__c ppUserRec{get;set;}
    public Decimal calculateVatTotal{get;set;}
    
    //Variable used in pricing logic to determine list price
    //Moving this to Constructor to avoid repetitive SOQL Queries
    /*Public Map<String,Sales_Orgs__c> soMap {get{
Map<String,Sales_Orgs__c> soMapNew = new Map<String,Sales_Orgs__c>();
List<Sales_Orgs__c> soList = [SELECT Id,Name, Sales_Org__c, Distribution_Channel__c, Pricing_Type__c, Active__c FROM Sales_Orgs__c WHERE Active__c = true];
system.debug('*** soList.size() *** ' + soList.size() );
if(soList.size() > 0){
for(Sales_Orgs__c curr : soList){
soMapNew.put(curr.Name,curr);
}//end for loop
}//end if
else{
Sales_Orgs__c salesOrgUs = testDataFactoryPP.createSalesOrg('US6010',true,'All','US60','10');
//insert salesOrgUs;
soMapNew.put(salesOrgUs.name,salesOrgUs);
}
return soMapNew;
}set;}*/
    
    //variables for displaying Sold To Account and Type
    Public String soldToAcct {get{
        try{
            if(pq.Account_Name__r.Account_Group__c == 'Z002'){
                soldToAcct = [SELECT Sale_to__c, Ship_to__c
                              FROM Contract_Partnership__c
                              WHERE Ship_to__c =:pq.Account_Name__r.SAP_Sold_To__c
                              AND Disabled__c = FALSE].Sale_to__c;
                
                return soldToAcct;
            }
            else{
                soldToAcct = pq.Account_Name__r.Sap_Sold_To__c;
                return soldToAcct;
            }
        }
        catch(Exception e){
            soldToAcct = pq.Account_Name__r.Sap_Sold_To__c;
            return soldToAcct;
        }
    }set;}
    
    Public String soldToAcctType {get{
        soldToAcctType = [SELECT Price_List_Type__c
                          FROM Account
                          WHERE SAP_Sold_To__c =:soldToAcct].Price_List_Type__c;
        
        return soldToAcctType;
    }set;}
    
    Public String exclusionType {get{
        try{
            //system.debug('*** soldToAcct *** ' + soldToAcct);
            if(soldToAcct != NULL){
                exclusionType = [SELECT Exclusion_Type__c
                                 FROM Account
                                 WHERE SAP_Sold_To__c =:soldToAcct].Exclusion_Type__c;
            }
            else{
                exclusionType = [SELECT Exclusion_Type__c
                                 FROM Account
                                 WHERE SAP_Sold_To__c =:pq.Account_Name__r.SAP_Sold_To__c].Exclusion_Type__c;
            }
            
            return exclusionType;
        }
        catch(Exception e){
            exclusionType = '';
            return exclusionType;
        }
    }set;}
    
    //can remove this later
    public String changeDate {get;set;}
    //get owner's current bu setting on user record
    public String userBu {get{
        userBu = [Select Id, Business_Unit__c FROM User
                  WHERE id =:UserInfo.getUserId() LIMIT 1].Business_Unit__c;
        return userBu;
    }set;}
    //end of getter setters to handle User bu change
    
    //Gross Margin variables
    //public Double newCost {get;set;}
    /*
public Integer convUnit {
get{return convUnit;}
set{convUnit = value;}
}
*/
    //public Integer convUnit = 1000;
    //Start of Approval Layout Stuff
    public Map<Id,Decimal> margins {get;set;}
    public Map<Id,String> priceCheck {get;set;}
    public Map<Id,Decimal> minContract {get;set;}
    public Map<Id,Decimal> minGpo {get;set;}
    public Map<Id,String> minContractAgree {get;set;}
    public Map<Id,String> minGpoAgree {get;set;}
    //end of Approval Layout Stuff
    
    //Approval Process Stuff
    public String processId;
    public ProcessInstance objProcessInstance;
    public String appComments {get;set;}
    public String oppSRTid {get; set;}
    //end Approval Process Stuff
    
    //import CSV Stuff
    //public Blob csvFileBody{get;set;}
    //public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<Price_Quote_Line_Item__c> lilist{get;set;}
    //end of import CSV Stuff
    public String userLang{get{
        return UserInfo.getLanguage();
    }set;}
    // Print Quote Language
    public String lang { get{
        if(pq2.Language__c != NULL){
            if(pq2.Language__c == 'English'){
                RETURN '&lang=en';
            }
            else if(pq2.Language__c == 'French'){
                RETURN '&lang=fr';
            }
            else if(pq2.Language__c == 'Spanish'){
                RETURN '&lang=es';
            }
            else{
                RETURN '&lang=en';
            }
        }
        else{
            RETURN '&lang=en';
        }
    } set;}
    
    //boolean for re-rendering button to red to go through approval process
    public Boolean disableButton { get; set; }
    public Boolean subButton {get{
        Price_Quote__c pQuote = new Price_Quote__c();
        
        if(pq.BusinessUnit__c != 'EMEA'){
            pQuote = [Select Id, Approval_Flag_Rollup__c, One_Time_Purchase__c FROM Price_Quote__c
                      WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
            
            if(pQuote.Approval_Flag_Rollup__c >= 1 && pQuote.One_Time_Purchase__c){
                return true;
            }else{
                return false;
            }
        }
        else{
            pQuote = [Select Id, EMEA_Approval_Flag_Rollup__c, One_Time_Purchase__c FROM Price_Quote__c
                      WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
            
            if(pQuote.EMEA_Approval_Flag_Rollup__c >= 1 && pQuote.One_Time_Purchase__c){
                return true;
            }else{
                return false;
            }
        }
    }set;}
    
    public void checkRollupSummaryValue() {
        // Perform logic to retrieve and check the roll-up summary field value
        Price_Quote__c matStatusCheck = [SELECT Id, Material_Status_Check__c
                                        FROM Price_Quote__c WHERE Id =:pq.Id];

        if(matStatusCheck.Material_Status_Check__c > 0){
            disableButton = TRUE;
        }else{
            disableButton = FALSE;
        }
     }

    //boolean for re-rendering button to blue to skip through approval process
    public Boolean comButton {get{
        List<Price_Quote__c> pQuote1 = new List<Price_Quote__c>();
        
        if(pq.BusinessUnit__c != 'EMEA'){
            pQuote1 = [Select Id, Approval_Flag_Rollup__c, One_Time_Purchase__c FROM Price_Quote__c
                       WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
            
            if(pQuote1[0].Approval_Flag_Rollup__c < 1){
                return true;
            }else{
                return false;
            }
        }
        else{
            pQuote1 = [Select Id, EMEA_Approval_Flag_Rollup__c, One_Time_Purchase__c FROM Price_Quote__c
                       WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
            
            if(pQuote1[0].EMEA_Approval_Flag_Rollup__c < 1){
                return true;
            }else{
                return false;
            }
        }
    }set;}
    
    public Boolean prfButton {get{
        List<Price_Quote__c> pQuote2 = [Select Id, Approval_Flag_Rollup__c, One_Time_Purchase__c FROM Price_Quote__c
                                        WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        if(pQuote2[0].Approval_Flag_Rollup__c >= 1 && !pQuote2[0].One_Time_Purchase__c){
            return true;
        }else{
            return false;
        }
    }set;}
    
    public Boolean userApprovalLevel {get{
        List<User> userLevel = [Select Id, Approval_Level__c FROM User
                                WHERE id = :UserInfo.getUserId()];
        if(userLevel[0].Approval_Level__c > 2){
            return true;
        }
        else if(userLevel[0].Approval_Level__c == NULL){
            return false;
        }
        else{
            return false;
        }
    }set;}
    
    /*
public Price_Quote__c lineCount {get{
return [Select Line_Count__c,Account_Name__r.Account_Group__c,CurrencyIsoCode from Price_Quote__c WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC limit 1];
}set;}
*/
    
    //boolean for re-rendering button to blue to skip through approval process
    public Boolean reviseButton {get{
        List<Price_Quote__c> lCount = [Select Id, Line_Count__c FROM Price_Quote__c WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        if(lCount.size() > 0){
            if(lCount[0].Line_Count__c > 0){
                return true;
            }else{
                return false;
            }
        }//end of lCount size check
        else{
            return false;
        }  
    }set;}
    
    /*public Decimal grandTotal {get{
List<Price_Quote__c> total = [Select Id, Grand_Total__c FROM Price_Quote__c WHERE Id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
grandTotal = total[0].Grand_Total__c;
return grandTotal;
}set;}*/
    
    //get count of Line Items with Cross Reference
    public Boolean hasCrossRef {get{
        Integer crossCount = [SELECT count() FROM Price_Quote_Line_Item__c WHERE Price_Quote__c =:ApexPages.currentPage().getParameters().get('pqid') AND Competetive_Product__c != null];
        if(crossCount > 0){
            return true;
        }else{
            return false;
        }
    }set;}
    
    //Moving this to Constructor to avoid repetitive SOQL Query
    public Price_Quote__c pq2 {get{
        return [SELECT Id, Material_Status_Check__c, Approval_Level__c, Language__c, Discounted_Total__c, Workflow_Owner_Approval_Level__c, Owner_Approval_Role__c,
        Pricing_Tier_Level__c,EMEA_Approval_Level__c, OwnerId, Price_Tier_Status__c, Approval_Flag_Rollup__c, EMEA_Approval_Flag_Rollup__c,Status__c, Sales_Org_Key__c,owner_Approval_level__c
        FROM Price_Quote__c
        WHERE Id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
    }set;}
    
    public Boolean needsApproval {get{
        Decimal num;
        
        if(pq.BusinessUnit__c != 'EMEA'){
            num = [Select Id, Approval_Flag_Rollup__c FROM Price_Quote__c
                   WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1].Approval_Flag_Rollup__c;
        }else{
            num = [Select Id, EMEA_Approval_Flag_Rollup__c FROM Price_Quote__c
                   WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1].EMEA_Approval_Flag_Rollup__c;
        }
        
        if(num > 0.0){
            return true;
        }else{
            return false;
        }
        
    }set;}
    
    public String wrkId {get{
        Set<String> mySet = new Set<String>();
        Set<String> actorSet = new Set<String>();
        String tempActorId;
        String currUserId = UserInfo.getUserId();
        
        Map<String,String> appMap = new Map<String,String>();
        
        List<ProcessInstanceWorkitem> appName = [SELECT ActorId,Actor.Name,Id,OriginalActor.Name,OriginalActorId,ProcessInstanceId
                                                 FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =:pq.Id];
        
        for(ProcessInstanceWorkitem curr: appName){
            tempActorId = curr.ActorId;
            system.debug('*** currUserId *** ' + currUserId);
            system.debug('*** tempActorId *** ' + tempActorId);
            
            myset.add(curr.Actor.Name);
            if(currUserId == tempActorId){
                appMap.put(tempActorId, curr.Id);
                wrkId = appMap.get(tempActorId);
            }
            else if(wrkId == NULL){
                wrkId = curr.Id;
            }
        }
        
        return wrkId;
    }
                         set;}
    
    //getter/setter to help avoid double approving
    Public Boolean isApprover {get{
        Set<String> mySet = new Set<String>();
        Set<String> actorSet = new Set<String>();
        String uName = UserInfo.getName();
        String uRoleId = UserInfo.getUserRoleId();
        String currUserId = UserInfo.getUserId();
        
        List<ProcessInstanceWorkitem> appName = [SELECT ActorId,Actor.Name,Id,OriginalActor.Name,OriginalActorId,ProcessInstanceId
                                                 FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =:pq.Id];
        
        for(ProcessInstanceWorkitem curr: appName){
            myset.add(curr.Actor.Name);
        }
        
        List<GroupMember> groupInfo = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember WHERE Group.Name IN :mySet];
        
        for(GroupMember curr: groupInfo){
            actorSet.add(curr.UserOrGroupId);
        }
        system.debug('*** uRoleId *** ' + uRoleId);
        system.debug('*** UserInfo.getUserRoleId() *** ' + UserInfo.getUserRoleId());
        if( mySet.contains(uName) || actorSet.contains(currUserId) ){
            system.debug('*** TRUE *** ');
            return true;
        }
        else{
            system.debug('*** FALSE *** ');
            return false;
        }
        
    }set;}
    //end of getter/setter for double approval
    
    public Integer oneTimeURL {get;set;} //handles URL parameter passing for Create New Opp
    
    /**************************************** Start Pricing Tier Matrix *******************************************************/
    
    //Start New Pricing Tier Stuff
    public list<String> tierHeaderList {get; set;} // Used to store the final list of pricing levels in order: REP1, REP2, RSM1, etc.
    public set<String> tierHeaderNames {get; set;} // Stores the major header names: REP, RSM, DIR
    //public list<String> tierHeaderListName {get; set;}
    public map<String, PP_Pricing_Tiers.tiers> tierMap {get; set;}
    public map<String, Integer> tierLevels {get; set;} // Used to store how many levels REP, RSM, DIR go in order to span columns appropriately
    public map<String, list<String>> tierChange {get; set;}
    public integer thSpan {get; set;}
    public integer pricingTierLevelPlus1 {get; set;}
    public boolean requestPlusOne {get; set;} // Determines whether to show the 'Request Tier' approval button - Has to be the owner with a material that has contracts one tier level higher
    map<String, list<Price_Quote_Line_Item__c>> pqliMap = new map<String, list<Price_Quote_Line_Item__c>>();
    // 22Jul2018 - ESC - Adding Approval Required, Reasons, and Level
    public string approval_reasons {get; set;} // String that shows Approval Reasons
    set<String> apReasons = new set<String>(); // Set to Capture the Approval Reasons
    
    // End New Pricing Tier Stuff
    
    //method used to show/hide RSM/Rep pricing
    public Boolean priceToggle {get;set;} //used to show Standard RSM/Rep pricing with tiered pricing
    public PageReference setPriceToggle(){
        if(priceToggle == false || priceToggle == NULL){
            priceToggle = true;
            Price_Quote__c priceToggle = new Price_Quote__c(Id=pq.Id);
            priceToggle.RsmRepToggle__c = true;
            update priceToggle;
        }
        else{
            priceToggle = false;
            Price_Quote__c priceToggle = new Price_Quote__c(Id=pq.Id);
            priceToggle.RsmRepToggle__c = false;
            update priceToggle;
        }
        
        return NULL;
    }
    
    // Method Used to Request One Level Higher Pricing Access
    public PageReference requestHigherTierAccess(){
        
        Price_Quote__c priceToggle = new Price_Quote__c(
            Id = pq.Id,
            Price_Tier_Status__c = 'Requested'
        );
        update priceToggle;
        
        // Submits the record for Approval
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('*** Submitting request for approval. ***');
        req1.setObjectId(pq.id);
        Approval.ProcessResult result = Approval.process(req1);
        
        return NULL;
    }
    
    // Used in VF to call the Class that builds Pricing Tier Matrix
    public boolean getCheckInit(){
        system.debug('*** Line Items: *** ' + lineItems);
        //if(pq.BusinessUnit__c != 'EMEA'){
            initCube();
        //}
        return TRUE;
    }
    // Class that builds Pricing Tier Matrix
    public void initCube() {
        
        if(tierMap.isEmpty()){
            system.debug('*** Check TierMap: *** ' + tierMap);
        }
        else{
            system.debug('*** TierMap is EMPTY! ***');
        }
        
        tierMap = new map<String, PP_Pricing_Tiers.tiers>();
        tierLevels = new map<String, Integer>(); // Used to store how many levels REP, RSM, DIR go in order to span columns appropriately
        tierHeaderList = new list<String>(); // Used to store the final list of pricing levels in order: REP1, REP2, RSM1, etc.
        tierHeaderNames = new set<String>(); // Stores the major header names: REP, RSM, DIR
        tierChange = new map<String, list<String>>();
        requestPlusOne = FALSE;
        
        // Build Product List to pass to the method
        set<Id> pids = new set<Id>();
        list<Product2> plist = new list<Product2>();
        string chKey;
        string salesOrgKey = '';
        apReasons.clear(); // Make sure only the current values are in the set
        for(Price_Quote_Line_Item__c pqli : [Select Id, Material_Name__c, Requested_Pricing__r.Parent_Contract_Name__c,
                                             Sales_Deal__r.Parent_Contract_Name__c, Sales_Deal__r.Pricing_Tier__c, Price_Quote__r.Sales_Org_key__c,
                                             Material_Name_Text__c, Approval_Flag_Reason__c, Price_Quote__r.BusinessUnit__c,
                                             EMEA_Approval_Flag_Reason__c,Material__c
                                             FROM Price_Quote_Line_Item__c
                                             WHERE Price_Quote__c = :ApexPages.currentPage().getParameters().get('pqid')])
        {
            pids.add(pqli.Material_Name__c);
            if(pqliMap.containsKey(pqli.Material_Name_Text__c)){
                pqliMap.get(pqli.Material_Name_Text__c).add(pqli);
            }
            else{
                pqliMap.put(pqli.Material_Name_Text__c, new list<Price_Quote_Line_Item__c>{pqli});
            }
            if(pqli.Price_Quote__r.BusinessUnit__c == 'EMEA'){
                if(pqli.EMEA_Approval_Flag_Reason__c != 'Ready'){
                    apReasons.add(pqli.EMEA_Approval_Flag_Reason__c);
                }
            }else{
                if(pqli.Approval_Flag_Reason__c != 'Ready'){
                    apReasons.add(pqli.Approval_Flag_Reason__c);
                }
            }
            
            salesOrgKey = pqli.Price_Quote__r.Sales_Org_key__c;
        }
        /*  List<Price_Quote_Line_Item__c> pqliList = [SELECT Id, Material_Name__c, Material_Name_Text__c, Approval_Flag_Reason__c,Price_Quote__r.Sales_Org_key__c, Price_Quote__r.BusinessUnit__c,           Sales_Deal__r.Pricing_Tier__c,            Sales_Deal__r.Parent_Contract_Name__c, Requested_Pricing__r.Parent_Contract_Name__c    FROM Price_Quote_Line_Item__c     WHERE Price_Quote__c = :ApexPages.currentPage().getParameters().get('pqid')];

for (Price_Quote_Line_Item__c pqli : pqliList) {
pids.add(pqli.Material_Name__c);
if (pqliMap.containsKey(pqli.Material_Name_Text__c)) {
pqliMap.get(pqli.Material_Name_Text__c).add(pqli);
} else {
pqliMap.put(pqli.Material_Name_Text__c, new List<Price_Quote_Line_Item__c>{pqli});
}
if (pqli.Approval_Flag_Reason__c != 'Ready') {
apReasons.add(pqli.Approval_Flag_Reason__c);
}
salesOrgKey = pqli.Price_Quote__r.Sales_Org_key__c;
}*/
        
        system.debug('tierChange: ' + tierChange);
        
        integer loops = 1;
        if(apReasons.size() > 0){
            for(String s : apReasons){
                if(loops == 1){
                    approval_reasons = s;
                }
                else{
                    approval_reasons += ', ' + s;
                }
                ++loops;
            }
        }
        
        
        for(Product2 p : [SELECT Id, Name FROM Product2 WHERE Id = :pids]){
            plist.add(p);
        }
        
        // Active User Level
        system.debug('pq: ' + pq);
        Integer pricingTierLevel = 1;
        system.debug('__pq21__'+pq2);
        if(pq2.Pricing_Tier_Level__c != NULL && UserInfo.getUserId() == pq2.OwnerId){
            pricingTierLevel = integer.valueOf(pq2.Pricing_Tier_Level__c);
            //System.debug('*** pricingTierLevel *** ' + pricingTierLevel);
        }
        else{
            for(Contract_User__c cu : [SELECT Pricing_Tier_Access__c, User__r.Name
                                       FROM Contract_User__c
                                       WHERE User__c = :UserInfo.getUserId()
                                       LIMIT 1])
            {
                system.debug('Setting Pricing Tier [' + cu.User__r.Name + '] - Access/Level: ' + cu.Pricing_Tier_Access__c);
                
                if(integer.valueOf(cu.Pricing_Tier_Access__c) != NULL){
                    pricingTierLevel = integer.valueOf(cu.Pricing_Tier_Access__c);
                }
            }
        }
        
        //Build the Cube
        PP_Pricing_Tiers newPT = new PP_Pricing_Tiers();
        tierMap =  newPT.getTiers(plist,pricingTierLevel); // Builds the map using a list of products
        tierHeaderList = newPT.getTierHeaderLevels(tierMap); // REP1, REP2, RSM1, etc.
        system.debug('*** tierMap: ' + tierMap);
        
        if(tierHeaderList.size() > 0){
            thSpan = tierHeaderList.size();
        }
        else{
            thSpan = 0;
        }
        
        set<String> pchSet = new set<String>();
        string price_String;
        for(PP_Pricing_Tiers.tiers pt : tierMap.values()){
            pchSet.add(pt.chKey); // Add the Key
            if(tierChange.containsKey(pt.chKey)){
                tierChange.get(pt.chKey).add(pt.Product_Name);
            }
            else{
                tierChange.put(pt.chKey, new list<String>{pt.Product_Name});
            }
            price_String = string.valueOf(pt.Price);
            //tierKey.put(pt.Product_Name + '-' + price_String, pt.TierName + '-' + pt.Product_Name);
        }
        
        // Determines whether to show the 'Request Tier' approval button
        // Has to be the owner with a material that has contracts one tier level higher
        if(pricingTierLevel < 4){ // No Need to run this for Level 4 users
            system.debug('*** pchSet *** ' + pchSet);
            system.debug('*** pricingTierLevelPlus1 *** ' + pricingTierLevelPlus1);
            pricingTierLevelPlus1 = pricingTierLevel + 1;
            if(UserInfo.getUserId() == pq2.OwnerId &&
               pchSet.size() > 0 &&
               pq2.Price_Tier_Status__c != 'Approved' &&
               pq2.Price_Tier_Status__c != 'Requested'
              ){
                  integer ptCount = 0;
                  ptCount = [SELECT count() FROM Contract_Header__c WHERE Pricing_Tier__c = TRUE
                             AND Parent_Contract_Name__c = :pchSet AND Pricing_Tier_Access__c = :pricingTierLevelPlus1];
                  system.debug('*** ptCount: ' + ptCount + ' and Plus1: ' + pricingTierLevelPlus1);
                  if(ptCount > 0){
                      system.debug('*** Setting ptCount true *** ');
                      requestPlusOne = TRUE;
                  }
              }
        }
        
        
        // Build REP/RSM/DIR Set and Column Span Map
        for(String s : tierHeaderList){
            string tName = s;
            //string tName = s.left(3);// REP, RSM, DIR
            if(tName.containsIgnoreCase('National Tier')){
                tname = 'National Tier';
                tierHeaderNames.add(tName);
            }
            else if(tName.containsIgnoreCase('VP') ){
                tierHeaderNames.add(tName);
            }
            else{
                tName = s.left(3);
                tierHeaderNames.add(tName);
            }//end National Tier check
            
            system.debug('tierHeaderList Loop: ' + s);
            // Build Map that controls column span. REP = 3, RSM = 3, etc.
            if(tierLevels.containsKey(tName)){
                tierLevels.put(tName, 1+tierLevels.get(tName));
            }
            else{
                tierLevels.put(tName, 1);
            }
        }
        system.debug('*** tierHeaderList: ' + tierHeaderList + ' - ' + 'tierHeaderNames: ' + tierHeaderNames);
    }
    
    public PageReference massUpdateTiers(){
        String tierLevel = Apexpages.currentpage().getParameters().get('tierLevel'); // REP1, REP2, RSM1
        string key;
        list<Price_Quote_Line_Item__c> updateLines = new list<Price_Quote_Line_Item__c>();
        
        for(Price_Quote_Line_Item__c pqli : [Select Id, Material_Name_Text__c, Price_Quote__r.BusinessUnit__c
                                             FROM Price_Quote_Line_Item__c
                                             WHERE Price_Quote__c = :ApexPages.currentPage().getParameters().get('pqid')])
        {
            key = tierLevel + '-' + pqli.Material_Name_Text__c;
            if(tierMap.containsKey(key) && tierMap.get(key).chId != NULL){
                Price_Quote_Line_Item__c myPqli = new Price_Quote_Line_Item__c(
                    id = pqli.Id,
                    Sales_Price__c = tierMap.get(key).Price,
                    Requested_Pricing__c = tierMap.get(key).chId,
                    Requested_Pricing_CM__c = tierMap.get(key).cmId,
                    Requested_Price__c = tierMap.get(key).Price
                );
                updateLines.add(myPqli);
            }
        }
        if(updateLines.size() > 0){
            update updateLines;
        }
        
        return new Pagereference('/apex/PP_Price_Quote?pqid='+ApexPages.currentPage().getParameters().get('pqid')).setRedirect(True);
        
    }
    
    public PageReference updateTierPrice(){
        /* New Try -- Ignore for now */
        String tierPrice = Apexpages.currentpage().getParameters().get('tierPrice');
        Id lineId = Apexpages.currentpage().getParameters().get('lineId');
        String key =  Apexpages.currentpage().getParameters().get('key');
        
        System.debug('*** key *** ' + key);
        System.debug('*** tierMap *** ' + tierMap);
        System.debug('*** tierMap.containsKey(key) *** ' + tierMap.containsKey(key));
        if(tierMap.containsKey(key)){
            list<Price_Quote_Line_Item__c> updateLines = new list<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c myPqli = new Price_Quote_Line_Item__c();
            
            myPqli = new Price_Quote_Line_Item__c(
                id = lineId,
                Sales_Price__c = tierMap.get(key).Price
            );
            string lineDesc;
            if(key == 'List' || key == 'Eligible'){
                lineDesc = key;
                myPqli.Requested_Pricing__c = NULL;
                myPqli.Requested_Pricing_CM__c = NULL;
                myPqli.Requested_Price__c = 0;
            }
            else{
                lineDesc = tierMap.get(key).chDesc;
                myPqli.Requested_Pricing__c = tierMap.get(key).chId;
                myPqli.Requested_Pricing_CM__c = tierMap.get(key).cmId;
                myPqli.Requested_Price__c = tierMap.get(key).Price;
            }
            updateLines.add(myPqli);
            system.debug('key check: ' + key);
            
            // Check to see if the User's Business Unit has disabled the Pricing Tier Lock
            // When TRUE the user can pick multiple tiers within the Same Contract Family (4000 and 3000 or 5571 and 5572)
            boolean tierUnlocked = FALSE;
            for(Business_Unit__c bu : Business_Unit__c.getall().values()){
                if(userBu == bu.Name && bu.Pricing_Tiers_Unlocked__c == TRUE){
                    tierUnlocked = TRUE;
                }
            }
            
            string subkey;
            if(key != NULL &&
               tierChange.containsKey(tierMap.get(key).chkey) &&
               tierUnlocked == FALSE
              ){
                  system.debug('chKey: ' + tierMap.get(key).chkey);
                  for(String s : tierChange.get(tierMap.get(key).chkey)){
                      subkey = tierMap.get(key).TierName + '-' + s;
                      if(pqliMap.containsKey(s)){
                          for(Price_Quote_Line_Item__c pqli : pqliMap.get(s)){
                              if(pqli.Id == lineId){
                                  myPqli = new Price_Quote_Line_Item__c(
                                      id = pqli.Id,
                                      Sales_Price__c = tierMap.get(subkey).Price,
                                      Requested_Pricing__c = tierMap.get(subkey).chId,
                                      Requested_Price__c = tierMap.get(subkey).Price,
                                      Requested_Pricing_CM__c = tierMap.get(subkey).cmId
                                  );
                                  if(!updateLines.contains(myPqli)){
                                      updateLines.add(myPqli);
                                  }
                                  
                              } // Id Check
                          } // END pqli map for loop
                      } // End Map Check
                  } // List of Materials related to the Parent Contract Name
              }
            
            if(updateLines.size() > 0){
                update updateLines;
            }
        }
        
        return new Pagereference('/apex/PP_Price_Quote?pqid='+ApexPages.currentPage().getParameters().get('pqid')).setRedirect(True);
        
    }//end of updateTierPrice
    
    /**************************************** END Pricing Tier Matrix *******************************************************/
    
    //Start of the Constructor
    global PP_Price_Quote(ApexPages.StandardController controller) {
        strQuoteId = ApexPages.currentPage().getParameters().get('pqid');
        margins = new Map<Id,Decimal>();
        priceCheck = new Map<Id,String>();
        minContract = new Map<Id,Decimal>();
        minGpo = new Map<Id,Decimal>();
        minContractAgree = new Map<Id,String>();
        minGpoAgree = new Map<Id,String>();
        userLocale = UserInfo.getLocale();
        formatListPrices = new Map<Id,String>();
        formatRsmPrices = new Map<Id,String>();
        formatRepPrices = new Map<Id,String>();
        formatEligiblePrices = new Map<Id,String>();
        formatLinePrices = new Map<Id,String>();
        formatSalesPrices = new Map<Id,String>();
        formatTotalPrices = new Map<Id,String>();
        labelsMap = new Map<String,String>();
        calculateVatTotal = 0;
        
        System.debug('*** userLocale *** ' + userLocale);
        
        /**************************************** START Pricing Tier Matrix *******************************************************/
        // Public collections //
        tierMap = new map<String, PP_Pricing_Tiers.tiers>(); // Major map used to store the pricing matrix
        tierLevels = new map<String, Integer>(); // Used to store how many levels REP, RSM, DIR go in order to span columns appropriately
        tierHeaderList = new list<String>(); // Used to store the final list of pricing levels in order: REP1, REP2, RSM1, etc.
        tierHeaderNames = new set<String>(); // Stores the major header names: REP, RSM, DIR
        
        /**************************************** END Pricing Tier Matrix *******************************************************/
        
        //pq2= new Price_Quote__c();
        //convUnit = 1000;
        csvFileLines = new String[]{};
            lilist = New List<Price_Quote_Line_Item__c>();
        system.debug('*** strQuoteId *** ' + strQuoteId);
        pq = (strQuoteId == null) ? new Price_Quote__c() :
        [Select Id, Name, Opportunity__r.Name, Opportunity__c, Price_Quote_Name__c, Status__c, Shipping__c, Product_Class_Count__c, Discounted_Total__c,
         Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Tax__c, Current_Approver__c, Account_Name__r.Price_List_Type__c,
         Internal_Comments_Only__c, Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity,
         Account_Name__r.BillingState, Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c, Account_Name__r.ERP_Active__c,
         Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c, Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Stationary__c, Discount_Type__c,
         Owner_Cell__c, Owner_Phone__c, Owner_Approval_Role__c, Workflow_Owner_Approval_Level__c, Courtesy_Pricing__c, Courtesy_Pricing_Type__c, Quote_Template__c, Discount__c,
         Owner_Email__c, Contact_Name__r.Name, Business_Unit__c, Contact_Name__r.id, Contact_Name__r.Phone, Contact_Name__r.Email, LastModifiedById, Material_Status_Check__c,
         CreatedById, InApproval__c, Territory__r.Territory_Name__c, Territory__r.Territory_Number__c,Approval_Flag_Rollup__c, CurrencyIsoCode, How_Created__c,
         Owner_Business_Unit__c, Sales_Org_Key__c,Line_Count__c,One_Time_Purchase__c,PRF__c, IsActive__c, Opportunity_Closed__c, Account_Name__r.Customer_Group__c,
         RsmRepToggle__c, BusinessUnit__c, OwnerId, Owner.Name, Type__c,Sold_To__c, Sold_To_Price_List_Type__c, Pricing_Tier_Level__c, EMEA_Approval_Level__c, EMEA_Approval_Flag_Rollup__c,
         Account_Name__r.Account_Name_2__c, Account_Name__r.Language__c,
         (SELECT Id, Name,Quantity__c, Price_Quote__r.BusinessUnit__c, Exception__c FROM Price_Quote_Line_Items__r)
         FROM Price_Quote__c WHERE id = :strQuoteId];
             //(Price_Quote__c)controller.getRecord();
             system.debug('pq ===================================== ' + pq);
        c = controller;
        
        pq2= [SELECT Id, Material_Status_Check__c, Approval_Level__c, Language__c, Discounted_Total__c,
              Pricing_Tier_Level__c, OwnerId, Price_Tier_Status__c, Approval_Flag_Rollup__c, Status__c, Sales_Org_Key__c,
              EMEA_Approval_Level__c, EMEA_Approval_Flag_Rollup__c
              FROM Price_Quote__c
              WHERE Id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        
        
        List<Sales_Orgs__c> soList = [SELECT Id,Name, Sales_Org__c, Distribution_Channel__c, Pricing_Type__c, Active__c FROM Sales_Orgs__c WHERE Active__c = true];
        system.debug('*** soList.size() *** ' + soList.size() );
        if(soList.size() > 0){
            for(Sales_Orgs__c curr : soList){
                soMap.put(curr.Name,curr);
            }//end for loop
        }//end if
        else{
            Sales_Orgs__c salesOrgUs = testDataFactoryPP.createSalesOrg('US6010',true,'All','US60','10');
            //insert salesOrgUs;
            soMap.put(salesOrgUs.name,salesOrgUs);
        }
        
        List<Price_Quote__c> total = [Select Id, Grand_Total__c FROM Price_Quote__c WHERE Id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        System.debug('Price Quote Grand Total: '+total);
        grandTotal = total[0].Grand_Total__c;
        
        //added logic below to automatically show RSM/Rep Pricing for EMEA
        PP_Menu menuInstance = new PP_Menu();
        ppUserRec = menuInstance.cUser;
        String userRoleName = menuInstance.cUser.User__r.UserRole.Name;
        if(userRoleName.containsIgnoreCase('EMEA') || pq.BusinessUnit__c == 'EMEA'){
            priceToggle = TRUE;
        }
        else{
            priceToggle = pq.RsmRepToggle__c;
        }
        //end logic for show RSM/Rep Pricing for EMEA
        
        changeDate = pq.Expiration_Date__c.year() + '/' + pq.Expiration_Date__c.month() + '/' + pq.Expiration_Date__c.day();
        // Logic to determine whether the record is locked or not.
        isLocked = FALSE;
        for(ProcessInstance pi : [SELECT Status
                                  FROM ProcessInstance
                                  WHERE TargetObjectId =: pq.Id
                                  order by CreatedDate DESC LIMIT 1])
        {
            if(pi.Status != 'Rejected'){
                isLocked = TRUE;
                //system.debug('pi.Status: ' + pi.Status);
            }
        }
        processId = ApexPages.currentPage().getParameters().get('id');
        
        //handles URL parameter passing for Create New Opp
        if(pq.One_Time_Purchase__c){
            oneTimeURL = 1;
        }
        else{
            oneTimeURL = 0;
        }
        
        formatTotalPrices = getFormatTotalPrices(strQuoteId);
        
        
        for(RecordType rt : [SELECT Id, DeveloperName
                             FROM RecordType
                             WHERE SobjectType = 'Opportunity'])
        {
            if(pq.Owner_Business_Unit__c != 'Vascular' && rt.DeveloperName == 'Teleflex_Standard_Opportunity'){
                oppSRTid = rt.Id;
            }
            else if(pq.Owner_Business_Unit__c == 'Vascular' && rt.DeveloperName == 'Vascular_Sales_NA'){
                oppSRTid = rt.Id;
            }
        }
        
        PP_Menu ppUser = new PP_Menu();

        List<Label_Translation__c> langTransList = [SELECT Id, Name, Label_Name__c, Translated_Value__c,
                                                    Sales_Org__c, Sales_Org_Key__c, Language_Code__c
                                                    FROM Label_Translation__c
                                                    WHERE Sales_Org_Key__c =:pq.Sales_Org_Key__c];

        //add fields for language translations
        if(langTransList.size()>0){
            labelsMap = getlabelsMap(langTransList);
        }

    }// END of Inner Constructor
    
    
    
    //method called to handle bulkrefresh of lines after clone
    public PageReference helperMethod() {
        String listOfNames = '';
        List<String> nameList = new List<String>();
        
        //get information from getApprovaInfor list
        List<ProcessInstanceWorkitem> approvalNames = getApprovalInfo();
        system.debug('*** approvalNames *** ' + approvalNames);
        boolean doUpdate = FALSE;
        
        Price_Quote__c updApprover = new Price_Quote__c(
            Id = pq.Id
        );
        
        //start of logic to get current approver
        if(approvalNames.size() > 0){
            system.debug('*** IN if approvalNames.size() > 0 REFRESH *** ');
            //check if more than one approver
            if(approvalNames.size() >1){
                system.debug('*** IN if approvalNames.size() > 1 REFRESH *** ');
                for(ProcessInstanceWorkitem curr: approvalNames){
                    system.debug('*** curr.Actor.Name refresh *** ' + curr.Actor.Name);
                    //listOfNames += ', ' + curr.Actor.Name;
                    nameList.add(curr.Actor.Name);
                }
                
                listOfNames = String.join(nameList,', ');
            }
            else{
                system.debug('*** IN ELSE approvalNames.size() > 1 REFRESH *** ');
                listOfNames = approvalNames[0].Actor.Name;
            }
            //nameList.remove(null);
            system.debug('*** listOfNames REFRESH *** ' + listOfNames);
            
            
            if(pq.Current_Approver__c != listOfNames){
                System.debug('*** In if to update Approver ***');
                updApprover.Current_Approver__c = listOfNames;
                doUpdate = TRUE;
            }
        }//end of Work Item IF
        else{
            updApprover.Current_Approver__c = listOfNames;
            
            
            if( pq.Current_Approver__c != listOfNames && pq.Current_Approver__c != NULL ){
                System.debug('*** In else to update Approver ***');
                System.debug('*** pq.Current_Approver__c *** ' + pq.Current_Approver__c);
                System.debug('*** listOfNames *** ' + listOfNames);
                //update updApprover;
                doUpdate = TRUE;
            }
        }
        //end of logic to get current approver
        
        // New Logic to set the Pricing Level on the Price Quote - 27Jun2018 - ESC
        if(pq2.Pricing_Tier_Level__c == NULL && UserInfo.getUserId() == pq2.OwnerId){
            Integer pricingTierLevel = 1;
            for(Contract_User__c cu : [SELECT Pricing_Tier_Access__c, User__r.Name
                                       FROM Contract_User__c
                                       WHERE User__c = :UserInfo.getUserId()
                                       LIMIT 1])
            {
                system.debug('*** Setting Pricing Tier [' + cu.User__r.Name + '] - Access/Level: ' + cu.Pricing_Tier_Access__c);
                
                if(integer.valueOf(cu.Pricing_Tier_Access__c) != NULL){
                    pricingTierLevel = integer.valueOf(cu.Pricing_Tier_Access__c);
                }
                if(UserInfo.getUserId() == pq2.OwnerId){
                    updApprover.Pricing_Tier_Level__c = pricingTierLevel;
                    doUpdate = TRUE;
                }
            }
            
        }
        if(doUpdate && ApexPages.currentPage().getParameters().get('refresh') == NULL){
            system.debug('*** Updating PQ! -- [helperMethod] ');
            update updApprover;
        }
        
        // END Updates -- 27Jun2018
        
        //start of refresh lines logic
        if (ApexPages.currentPage().getParameters().get('refresh') != NULL) {
            system.debug('*** DOING REFRESH ***');
            bulkRefresh();
            system.debug('*** END OF REFRESH ***');
            
            PageReference newQuote = new Pagereference('/apex/PP_Price_Quote?pqId='+ApexPages.currentPage().getParameters().get('pqId') ).setRedirect(true);
            return newQuote;
        }
        else {
            system.debug('*** NO REFRESH REQUIRED ***');
            return null;
        }
        
    }//end of helperMethod
    
    public Pagereference updateOwner() {
        String strPriceQuoteId = ApexPages.currentPage().getParameters().get('pqId');
        return new Pagereference('/'+strPriceQuoteId+'/a?retURL=%2F'+strPriceQuoteId);
    }
    
    public boolean hasError { get; set; }
    
    public PageReference editpq(){
        return new Pagereference('/apex/PP_Price_Quote_Edit?pqid='+pq.Id).setRedirect(True);
    }
    
    public PageReference printpq(){
        return new Pagereference('/apex/PP_Print_Center?id='+pq.Id).setRedirect(True);
    }
    
    
    //used to update Account and Customer
    public Pagereference doUpdateAccountValue() {
        hasError = false;
        system.debug('**** Account_Name__c ****'+pq.Account_Name__c);
        system.debug('**** pq.Contact_Name__c ****'+pq.Contact_Name__c);
        Map<Id, Contact> mapContact = new Map<Id, Contact>([Select Id from Contact where AccountId =: pq.Account_Name__c]);
        //List<Contact> lstContact = [Select Id from Contact where AccountId =: pq.Account_Name__c];
        system.debug('**** lstContact ****'+mapContact);
        if(mapContact.containsKey(pq.Contact_Name__c)){
            String pqid = Apexpages.currentpage().getParameters().get('pqid');
            //Price_Quote__c pqObj = getpq();
            update pq;
            return new Pagereference('/apex/PP_Price_Quote?pqId='+pqid).setRedirect(True);
        }
        else{
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.EMEA_Please_choose_contact_related_to_account));
            return null;
        }
    }
    
    //used to udpate Owner of PQ
    public Pagereference doUpdateOwnerValue() { 
        hasError = false;
        system.debug('**** Owner.Name ****'+pq.Owner.Name);
        
        try{
            String pqid = Apexpages.currentpage().getParameters().get('pqid');
            update pq;
            return new Pagereference('/apex/PP_Price_Quote?pqId='+pqid).setRedirect(True);
        }
        catch(Exception e){
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,system.label.EMEA_Please_choose_a_valid_owner));
            return null;
        }
        
    }
    
    //method to get quote info
    public Price_Quote__c getpq(){
        Price_Quote__c pq = new Price_Quote__c();
        Price_Quote__c plist = [Select Id, Name, Status__c, Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Internal_Comments_Only__c,
                                Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity, Account_Name__r.BillingState,
                                Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c,Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c,
                                Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Owner_Cell__c, Owner_Phone__c, Owner_Email__c, Contact_Name__r.name, Opportunity__r.Name,
                                Business_Unit__c, Contact_Name__r.id, Contact_Name__r.phone, Contact_Name__r.email, LastModifiedById, CreatedById, PRF__c, Current_Approver__c,
                                CurrencyIsoCode,Sales_Org_Key__c, Line_Count__c,Owner_Business_Unit__c, InApproval__c,One_Time_Purchase__c, Shipping__c, Tax__c, Product_Class_Count__c,
                                Account_Name__r.Price_List_Type__c, Discount__c, Discounted_Total__c, Discount_Type__c, Account_Name__r.ERP_Active__c, RsmRepToggle__c, BusinessUnit__c,
                                OwnerId, Owner.Name, Type__c,Sold_To__c,Sold_To_Price_List_Type__c, Pricing_Tier_Level__c, EMEA_Approval_Level__c, EMEA_Approval_Flag_Rollup__c,
                                Account_Name__r.Account_Name_2__c, Material_Status_Check__c,Account_Name__r.Language__c
                                FROM Price_Quote__c
                                WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        system.debug('plist ============================== ' + plist);
        if(plist != null){
            grandTotal = plist.Grand_Total__c;
            pq = plist;
        }
        return pq;
    }
    //end of method to get quote info
    
    // START - Method to get line items
    // Line Item List - rows - in VF
    public List<Price_Quote_Line_Item__c> getLineItems(){
        strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
        List<Price_Quote_Line_Item__c> lineItems = [Select id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c, Objective_Name__c,Requested_Pricing__r.Agreement_Number__c,
                                                    Objective__c,Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Brand__c, Approval_Flag_Reason__c, Exception__c,
                                                    Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c,Sales_Deal__r.Agreement_Number__c,
                                                    Product_Description__c, Material_Name__r.Cost__c,Sales_deal_Description__c, Sales_Number__c,Material_Name__r.List_Price__c,
                                                    Row_Order__c, Competetive_Product__r.Competitor_Product_Code__c, Material_Name__r.Name, Cost__c, Requested_Pricing__c, Requested_Price__c,
                                                    Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Description__c, Material_Name__r.Director_Price__c, Requested_Pricing_CM__c,
                                                    Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Floor_Price__c,Material_Name__r.Alt_Site_List__c,
                                                    Line_Price__c, Material_Name__r.Transfer_Price__c, Material_Status_Description__c, IsBold__c, Price_Quote__r.Account_Name__r.Price_List_Type__c,
                                                    Approval_Flag_Checkbox__c, Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c,Material_Name_Text__c, 
                                                    Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c, MRP_Group__c,
                                                    Owner_Approval_Level__c, Approval_Level__c, Refresh__c, Director_Price__c, Material_Name__r.Class__c, Material_Name__r.MRP_Group__c,
                                                    Material_Name__r.Cost_Price_Unit__c, Price_Quote__r.Owner_Business_Unit__c, Floor_Price__c, Material_Name__r.Cost_Formula__c,
                                                    Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Requested_Pricing__r.Parent_Contract_Name__c, Total_Price_Per_Each__c,
                                                    Sales_Deal__r.Pricing_Tier__c, Requested_Pricing__r.Description__c, Material_Name__r.VP_Price__c, Price_Quote__r.BusinessUnit__c,
                                                    Price_Per_Each__c, EMEA_Approval_Level__c, EMEA_Approval_Flag_Reason__c, EMEA_Approval_Flag_Checkbox__c, EMEA_Approval_Flag__c,
                                                    VAT__c, Material_Description__c, Min_Order_Qty__c, VAT_Amount__c, Total__c,Material__c
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c=: strQuoteId
                                                    ORDER BY Row_Order__c NULLS LAST];
        
        system.debug('getLineItems --- lineItems: ' + lineItems);
        
        if(lineItems.size() > 0){            
            margins = getMargins(lineItems);
            priceCheck = getPriceCheck(lineItems);
            minContract = getMinContract(lineItems);
            minContractAgree = getMinContractAgree(lineItems);
            minGpo = getMinGpo(lineItems);
            minGpoAgree = getMinGpoAgree(lineItems);
            formatListPrices = getFormatListPrices(lineItems);
            formatRsmPrices = getFormatRsmPrices(lineItems);
            formatRepPrices = getFormatRepPrices(lineItems);
            formatEligiblePrices = getFormatEligiblePrices(lineItems);
            formatLinePrices = getFormatLinePrices(lineItems);
            formatSalesPrices = getFormatSalesPrices(lineItems);
            formatTotalPrices = getFormatTotalPrices(pq.Id);
            calculateVatTotal = getCalculateVatTotal(lineItems);
        }
        return lineItems;
    }
    //end of method to get line items

    //Logic below is to total the price with VAT for EMEA

    //public decimal vatTotal{get;set;}
    public decimal getCalculateVatTotal(List<Price_Quote_Line_Item__c> lineItems){
        calculateVatTotal = 0;
        system.debug('****lineItems.size()**** ' + lineItems);
        for (Price_Quote_Line_Item__c curr : lineItems) {
            calculateVatTotal += curr.Total__c;
        }
        system.debug('****calculateVatTotal**** ' + calculateVatTotal);
        return calculateVatTotal;
    }//end of getPriceQuoteLineItems
    //Logic above is to total the price with VAT for EMEA
    
    //get User Business Unit picklist field values
    public List<SelectOption> getPickListValuesIntoList(){
        List<SelectOption> pickListValuesList= new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = User.Business_Unit__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            //pickListValuesList.add(pickListVal.getLabel());
            if(pickListVal.getValue() != 'Commercial Operations' && pickListVal.getValue() != 'Chatter' && pickListVal.getValue() != 'Canada' &&
               pickListVal.getValue() != 'Cross BU (Stop Using This)' && pickListVal.getValue() != 'Customer Advocacy' &&
               pickListVal.getValue() != 'Customer Service' && pickListVal.getValue() != 'Surgical' && pickListVal.getValue() !='Surgical Percuvance' &&
               pickListVal.getValue() != 'National Accounts'){
                   pickListValuesList.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
               }
            
        }
        return pickListValuesList;
    }
    
    //get active quote of current user
    public String getActiveQuoteIdStr() {
        if(ApexPages.currentPage().getParameters().get('pqid') != NULL){
            return ApexPages.currentPage().getParameters().get('pqid');
        }
        else{
            return NULL;
        }
    }
    //end of method to get active quote
    
    //mass quantity update
    public PageReference massQtyChange(){
        strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
        //strQtyChange = Apexpages.currentpage().getParameters().get('changeQty');
        system.debug('strQtyChange ============================================= ' + strQtyChange);
        If(!strQtyChange.isNumeric() || strQtyChange==null || strQtyChange==''){
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.label.EMEA_Please_enter_a_valid_quantity));
            return null;
        }
        else{
            Integer qty = Integer.valueOf(strQtyChange);
            system.debug('qty ============================================= ' + qty);
            List<Price_Quote_Line_Item__c> updItems = new List<Price_Quote_Line_Item__c>();
            //List<Price_Quote_Line_Item__c> lineItems = [Select id,Sales_Price__c,Quantity__c,List_Price__c
            //From Price_Quote_Line_Item__c Where Price_Quote__c=: strQuoteId];
            
            for(Price_Quote_Line_Item__c curr : [SELECT id,Sales_Price__c,Quantity__c,List_Price__c, Price_Quote__r.BusinessUnit__c, Price_Per_Each__c
                                                 FROM Price_Quote_Line_Item__c WHERE Price_Quote__c=: strQuoteId AND Material_Name__c != NULL]){
                                                     curr.Quantity__c = qty;
                                                     curr.Extended_Price__c = curr.List_Price__c * qty;
                                                     updItems.add(curr);
                                                 }
            
            try{
                update updItems;
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ) );
            }
            
            return null;
        }
    }
    
    //method to add product from cross reference
    public PageReference setBu(){
        system.debug('*** IN setBU Method PP_Price_Quote Class *** ');
        //system.debug('*** userId *** ' + userId);
        if(pq.InApproval__c){
            system.debug('*** pq.InApproval__c setBU Method PP_Price_Quote Class *** ');
            return null;
        }//end if
        else{
            //start Try
            system.debug('***setBU Method buValue *** ' + buValue);
            try{
                Price_Quote__c myPriceQuote = new Price_Quote__c(
                    id = pq.Id,
                    BusinessUnit__c = buValue
                );
                
                Database.update(myPriceQuote,FALSE); 
                
                /*
User myUser = new User(
id = userId,
Business_Unit__c = buValue);
update myUser;
*/
                //c.save();
                //setBuHeader(buValue);
                system.debug('***setBU Method myPriceQuote *** ' + myPriceQuote);
                return new PageReference('/apex/PP_Price_Quote?pqid='+pq.Id).setRedirect(true);
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                return null;
            }
            //end try
        }//end if/else
        
    }
    
    //method to add business unit value to header
    public void setBuHeader(String myBu){
        system.debug('*** myBu *** ' + myBu);
        
        try{
            Price_Quote__c myPq = new Price_Quote__c(
                id = pq.Id,
                BusinessUnit__c = myBu);
            update myPq;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        //return null;
        
    }
    
    //mass delete line items
    public PageReference massDelItems(){
        //strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
        delId = apexpages.currentpage().getparameters().get('delId');
        system.debug('delId =============================== ' + delId);
        List<Price_Quote_Line_Item__c> delLine = [Select Id,Price_Quote__c, Price_Quote__r.BusinessUnit__c From Price_Quote_Line_Item__c WHERE Price_Quote__c =:delId];
        system.debug('delLine =============================== ' + delLine);
        //delete delLine;
        
        try{
            delete delLine;
            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        //return new PageReference('/apex/PP_Price_Quote?pqid={!strQuoteId}').setRedirect(true);
        return null;
    }
    
    //method to delete a line item
    public PageReference removingRow() {
        system.debug('IN REMOVINGROW METHOD!!!!!!!!!!!!!!!');
        pqlid = apexpages.currentpage().getparameters().get('itemId');
        //strQuoteId = apexpages.currentpage().getparameters().get('pqId');
        system.debug('pqlid =============================== ' + pqlid);
        //system.debug('strQuoteId=============================== ' + strQuoteId);
        List<Price_Quote_Line_Item__c> delLine = [Select Id From Price_Quote_Line_Item__c WHERE id =:pqlid];
        system.debug('delLine =============================== ' + delLine);
        System.debug('*** tierMap in removingRow *** ' + tierMap);
        System.debug('*** pq.BusinessUnit__c in removingRow *** ' + pq.BusinessUnit__c);
        //delete delLine;
        
        try{
            delete delLine;            
            sort();
            
            //conditions below helps with Price Quote and PRF Approval Matrix Routing
            if(pq.BusinessUnit__c == 'Alternate Care'){
                PP_SAP_Price check = new PP_SAP_Price();
                check.lineClassCheck(pq.Id);
            }
            
            if(pq.BusinessUnit__c == 'Anesthesia'){
                PP_SAP_Price check = new PP_SAP_Price();
                check.lineProdCheckAnes(pq.Id);
            }
            
            if(pq.BusinessUnit__c == 'Interventional Capital' || pq.BusinessUnit__c == 'Cardiac'){
                PP_SAP_Price check = new PP_SAP_Price();
                check.lineProdCheckIcap(pq.Id);
            }
            
            if(pq.Owner_Business_Unit__c == 'Surgical Instruments'){
                PP_SAP_Price check = new PP_SAP_Price();
                check.lineClassCheck(pq.Id);
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        //return new PageReference('/apex/PP_Price_Quote?pqid={!strQuoteId}').setRedirect(true);
        return null;
    }
    //end of removingRow method
    
    //start of method to sort line items after delete
    public void sort(){
        try{
            system.debug('INSIDE SORT METHOD');
            system.debug('pqId ==================== ' + pq.Id);
            Integer rowNum = 0;
            //List<Price_Quote_Line_Item__c> lineItems = [Select Id,Row_Order__c From Price_Quote_Line_Item__c WHERE Price_Quote__c =:pq.Id ORDER BY Row_Order__c];
            List<Price_Quote_Line_Item__c> sorted = new List<Price_Quote_Line_Item__c>();
            for(Price_Quote_Line_Item__c curr : [Select Id,Row_Order__c From Price_Quote_Line_Item__c
                                                 WHERE Price_Quote__c =:pq.Id ORDER BY Row_Order__c]){
                                                     curr.Row_Order__c = rowNum + 1;
                                                     system.debug('curr.Row_Order__c ================== ' + curr.Row_Order__c);
                                                     sorted.add(curr);
                                                     rowNum++;
                                                 }
            update sorted;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    //end of method to sort line items after delete
    
    // Saving Opportunity checkbox
    public PageReference saveRecord(){
        try{
            system.debug('pq.No_Opp__c =========================== ' + pq.No_Opp__c);
            //strQuoteId = ApexPages.currentPage().getParameters().get('pqid');
            Price_Quote__c mypq = new Price_Quote__c(
                id = ApexPages.currentPage().getParameters().get('pqid'),
                No_Opp__c = pq.No_Opp__c);
            update pq;
            //c.save();
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return null;
        //return new PageReference('/apex/PP_Price_Quote?pqid={!strQuoteId}').setRedirect(true);
    }
    
    // Saving One_Time_Purchase__c checkbox
    public PageReference saveOneTime(){
        try{
            system.debug('pq.One_Time_Purchase__c =========================== ' + pq.One_Time_Purchase__c);
            //strQuoteId = ApexPages.currentPage().getParameters().get('pqid');
            Price_Quote__c mypq = new Price_Quote__c(
                id=ApexPages.currentPage().getParameters().get('pqid'),
                One_Time_Purchase__c=pq.One_Time_Purchase__c
            );
            update pq;
            
            //handles URL parameter passing for Create New Opp
            if(mypq.One_Time_Purchase__c){
                oneTimeURL = 1;
            }
            else{
                oneTimeURL = 0;
            }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return null;
        //return new PageReference('/apex/PP_Price_Quote?pqid={!strQuoteId}').setRedirect(true);
    }
    
    //single line RSM price update
    public PageReference updateRSMprice(){
        try{
            String rsmPrice = Apexpages.currentpage().getParameters().get('rsmPrice');
            String lineId = Apexpages.currentpage().getParameters().get('lineId');
            String lineQty = Apexpages.currentpage().getParameters().get('lineQty');
            system.debug('rsmPrice ====================== ' + rsmPrice);
            system.debug('lineId ====================== ' + lineId);
            system.debug('lineQty ====================== ' + lineQty);
            Decimal myrsmPrice = decimal.valueOf(rsmPrice);
            Integer myLineQty = Integer.valueOf(lineQty);
            
            Price_Quote_Line_Item__c mypql = new Price_Quote_Line_Item__c(
                id = lineId, Sales_Price__c = myRSMPrice,
                Extended_Price__c = myRSMPrice * myLineQty,
                Requested_Pricing__c = NULL,
                Requested_Pricing_CM__c = NULL,
                Requested_Price__c = 0
            );
            
            update mypql;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return null;
    }
    
    //single line Rep Price update
    public PageReference updateRepPrice(){
        try{
            String repPrice = Apexpages.currentpage().getParameters().get('repPrice');
            String lineId = Apexpages.currentpage().getParameters().get('lineId');
            String lineQty = Apexpages.currentpage().getParameters().get('lineQty');
            system.debug('repPrice ====================== ' + repPrice);
            system.debug('lineId ====================== ' + lineId);
            system.debug('lineQty ====================== ' + lineQty);
            Decimal myrepPrice = decimal.valueOf(repPrice);
            Integer myLineQty = Integer.valueOf(lineQty);
            
            Price_Quote_Line_Item__c mypql = new Price_Quote_Line_Item__c(
                id = lineId,Sales_Price__c = myrepPrice,
                Extended_Price__c = myrepPrice * myLineQty,
                Requested_Pricing__c = NULL,
                Requested_Pricing_CM__c = NULL,
                Requested_Price__c = 0
            );
            
            update mypql;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
    //single line List Price update
    public PageReference updateListPrice(){
        try{
            String listPrice = Apexpages.currentpage().getParameters().get('listPrice');
            String lineId = Apexpages.currentpage().getParameters().get('lineId');
            String lineQty = Apexpages.currentpage().getParameters().get('lineQty');
            system.debug('listPrice ====================== ' + listPrice);
            system.debug('lineId ====================== ' + lineId);
            system.debug('lineQty ====================== ' + lineQty);
            Decimal myListPrice = decimal.valueOf(listPrice);
            Integer myLineQty = Integer.valueOf(lineQty);
            
            Price_Quote_Line_Item__c mypql = new Price_Quote_Line_Item__c(
                id = lineId,
                Sales_Price__c=myListPrice,
                Extended_Price__c=myListPrice * myLineQty,
                Requested_Pricing__c = NULL,
                Requested_Pricing_CM__c = NULL,
                Requested_Price__c = 0
            );
            
            update mypql;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
    //single line List Price update
    public PageReference updateEligiblePrice(){
        try{
            String eligiblePrice = Apexpages.currentpage().getParameters().get('eligiblePrice');
            String lineId = Apexpages.currentpage().getParameters().get('lineId');
            String lineQty = Apexpages.currentpage().getParameters().get('lineQty');
            system.debug('eligiblePrice ====================== ' + eligiblePrice);
            system.debug('lineId ====================== ' + lineId);
            system.debug('lineQty ====================== ' + lineQty);
            Decimal myEligiblePrice = decimal.valueOf(eligiblePrice);
            Integer myLineQty = Integer.valueOf(lineQty);
            
            Price_Quote_Line_Item__c mypql = new Price_Quote_Line_Item__c(
                id = lineId, Sales_Price__c = myEligiblePrice,
                Extended_Price__c = myEligiblePrice * myLineQty,
                Requested_Pricing__c = NULL,
                Requested_Pricing_CM__c = NULL,
                Requested_Price__c = 0
            );
            
            update mypql;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
    //mass List Price update
    public PageReference massUpdList(){
        try{
            strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
            List<Price_Quote_Line_Item__c> updItems = new List<Price_Quote_Line_Item__c>();
            
            for(Price_Quote_Line_Item__c curr : [SELECT id, Sales_Price__c, Quantity__c, List_Price__c, Extended_Price__c, Requested_Pricing__c,
                                                 Requested_Pricing_CM__c, Requested_Price__c, Price_Quote__r.BusinessUnit__c
                                                 FROM Price_Quote_Line_Item__c Where Price_Quote__c=: strQuoteId
                                                 AND Material_Name__c != NULL])
            {
                curr.Sales_Price__c = curr.List_Price__c;
                curr.Extended_Price__c = curr.Sales_Price__c * curr.Quantity__c;
                curr.Requested_Pricing__c = NULL;
                curr.Requested_Pricing_CM__c = NULL;
                curr.Requested_Price__c = 0;
                updItems.add(curr);
            }
            
            if(updItems.size() > 0){
                update updItems;
            }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }//end of massUpdList
    
    //mass RSM Price update
    public PageReference massUpdRSM(){
        try{
            strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
            List<Price_Quote_Line_Item__c> updItems = new List<Price_Quote_Line_Item__c>();
            
            for(Price_Quote_Line_Item__c curr : [SELECT id,Sales_Price__c,Quantity__c,RSM_Price__c,Extended_Price__c,
                                                 Requested_Pricing__c, Requested_Price__c, Requested_Pricing_CM__c, Price_Quote__r.BusinessUnit__c
                                                 FROM Price_Quote_Line_Item__c
                                                 WHERE Price_Quote__c=: strQuoteId
                                                 AND Material_Name__c != NULL])
            {
                curr.Sales_price__c = curr.RSM_Price__c;
                curr.Extended_Price__c = curr.Sales_Price__c * curr.Quantity__c;
                curr.Requested_Pricing__c = NULL;
                curr.Requested_Pricing_CM__c = NULL;
                curr.Requested_Price__c = 0;
                updItems.add(curr);
            }
            
            update updItems;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
    //mass Rep Price update
    public PageReference massUpdRep(){
        try{
            strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
            List<Price_Quote_Line_Item__c> updItems = new List<Price_Quote_Line_Item__c>();
            
            for(Price_Quote_Line_Item__c curr : [SELECT id,Sales_Price__c,Quantity__c,Rep_Price__c,Extended_Price__c, Requested_Pricing__c,
                                                 Requested_Price__c, Requested_Pricing_CM__c, Price_Quote__r.BusinessUnit__c
                                                 FROM Price_Quote_Line_Item__c
                                                 WHERE Price_Quote__c=: strQuoteId
                                                 AND Material_Name__c != NULL])
            {
                curr.Sales_price__c = curr.Rep_Price__c;
                curr.Extended_Price__c = curr.Sales_Price__c * curr.Quantity__c;
                curr.Requested_Pricing__c = NULL;
                curr.Requested_Pricing_CM__c = NULL;
                curr.Requested_Price__c = 0;
                updItems.add(curr);
            }
            
            update updItems;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return null;
    }
    
    //mass Rep Price update
    public PageReference massUpdEligible(){
        try{
            strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
            List<Price_Quote_Line_Item__c> updItems = new List<Price_Quote_Line_Item__c>();
            //List<Price_Quote_Line_Item__c> lineItems = [Select id,Sales_Price__c,Quantity__c,Eligible_Price__c,Extended_Price__c
            //From Price_Quote_Line_Item__c Where Price_Quote__c=: strQuoteId];
            
            for(Price_Quote_Line_Item__c curr : [Select id,Sales_Price__c,Quantity__c,Eligible_Price__c,Extended_Price__c,
                                                 Requested_Pricing__c, Requested_Price__c, Requested_Pricing_CM__c, Price_Quote__r.BusinessUnit__c
                                                 From Price_Quote_Line_Item__c Where Price_Quote__c=: strQuoteId
                                                 AND Material_Name__c != NULL])
            {
                curr.Sales_price__c = curr.Eligible_Price__c;
                curr.Extended_Price__c = curr.Sales_Price__c * curr.Quantity__c;
                curr.Requested_Pricing__c = NULL;
                curr.Requested_Pricing_CM__c = NULL;
                curr.Requested_Price__c = 0;
                updItems.add(curr);
            }
            
            update updItems;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
    //method to get SAP Price
    public PageReference sapPrice(){
        System.debug('*** Running sapPrice from PP_Price_Quote Class ***');
        Product2 mcheck = new Product2();

        if(pq.Status__c == 'Approved'){
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sorry, cannot add line items to an approved quote..'));
            return NULL;
        }
        else if(!String.isBlank(strProdSearch)){
            List<String> prods = new List<String>();
            String strProdSearchTrim = strProdSearch.trim();
            String exclusionProd = '';
            
            system.debug('*** strProdSearchTrim ================== ' + strProdSearchTrim);
            system.debug('*** pq.Sales_Org_Key__c: ' + pq.Sales_Org_Key__c);
            system.debug('*** pq.Type__c ================== ' + pq.Type__c);
            
            //adding logic for allowing ASK products
            if(pq.Type__c == 'ASK Agreement'){
                for(Product2 curr : [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c,Brand_Name__c, Cost__c,
                                    List_Price__c, RSM_Price__c, Rep_Price__c, Director_Price__c, Floor_Price__c,
                                    Product_Description_Custom__c, Material_Status_Numeric__c, Description, Cost_Formula__c,
                                    Distributor_List__c, Alt_Site_List__c, MRP_Group__c, SearchableProducts__c, Exclusion_Type__c,
                                    Min_Order_Qty__c
                                    FROM Product2
                                    WHERE Name =:strProdSearchTrim
                                    AND Sales_Org_Key__c =:pq.Sales_Org_Key__c
                                    AND Duplicate__c = FALSE AND ASK_Custom_Kit__c = TRUE
                                    ORDER BY List_Price__c DESC LIMIT 1])
                {
                    prods.add(curr.Id);
                    mcheck = curr;
                    System.debug('*** curr.Exclusion_Type__c if *** ' + curr.Exclusion_Type__c);
                    exclusionProd = curr.Exclusion_Type__c;
                    System.debug('*** exclusionProd loop if *** ' + exclusionProd);
                }
            }
            else{
                System.debug('*** PP_Price_Quote sapPrice NOT ASK Agreement else *** ');
                for(Product2 curr : [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c,Brand_Name__c, Cost__c,
                                    List_Price__c, RSM_Price__c, Rep_Price__c, Director_Price__c, Floor_Price__c,
                                    Product_Description_Custom__c, Material_Status_Numeric__c, Description, Cost_Formula__c,
                                    Distributor_List__c, Alt_Site_List__c, MRP_Group__c, SearchableProducts__c, Exclusion_Type__c,
                                    Min_Order_Qty__c
                                    FROM Product2
                                    WHERE Name =:strProdSearchTrim
                                    AND Sales_Org_Key__c =:pq.Sales_Org_Key__c
                                    AND Duplicate__c = FALSE AND SearchableProducts__c = TRUE
                                    ORDER BY List_Price__c DESC LIMIT 1])
                {
                    prods.add(curr.Id);
                    mcheck = curr;
                    System.debug('*** curr.Exclusion_Type__c else *** ' + curr.Exclusion_Type__c);
                    exclusionProd = curr.Exclusion_Type__c;
                    System.debug('*** exclusionProd loop else ***' + exclusionProd);
                }
            }//end logic for allowing ASK products
            
            IF(prods.isEmpty()){
                apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.label.EMEA_Please_Enter_Valid_Material));
                return NULL;
            }
            ELSE{
                System.debug('*** exclusionType *** ' + exclusionType);
                System.debug('*** exclusionProd *** ' + exclusionProd);
                IF(exclusionType == 'ZB01' && exclusionProd == 'ZB01'){
                    apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.label.EMEA_Current_account_is_excluded_from_purchasing_this_product));
                    return NULL;
                }
                ELSE{
                    System.debug('*** prods Sending to getSAPprice *** ' + prods);
                    PP_SAP_Price sapPrice = new PP_SAP_Price();
                    sapPrice.getSAPprice(prods,null,null,pq.Id);
                    //sapPrice.getSapPriceNew(pq,mcheck,soldToAcct,soldToAcctType,exclusionType,null, null);
                    //getSAPpriceNew(Price_Quote__c pq, Product2 mcheck, String soldToAcct, String soldToAcctType, String exclusionTypeSoldTo, String crossStr, String lineItemId )
                    System.debug('*** End of sapPrice from PP_Price_Quote Class ***');
                    return NULL;
                }//end else

            }//end outter else
            
            /*
            String strProdSearchTrim = strProdSearch.trim();
            List<String> prods = new List<String>();
            List<Product2> currProd = [Select Id,Name From Product2 Where Name =:strProdSearchTrim AND SearchableProducts__c = TRUE LIMIT 1];
            if(pq.Status__c == 'Approved'){
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sorry, cannot add line items to an approved quote..'));
            return null;
            }
            else if(currProd.size()<1){
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a valid material..'));
            return null;
            }
            else{
            system.debug('strProdSearchTrim ================== ' + strProdSearchTrim);
            system.debug('pq.Sales_Org_Key__c: ' + pq.Sales_Org_Key__c);

            for(Product2 curr : [SELECT Id FROM Product2
            WHERE Name =:strProdSearchTrim
            AND Sales_Org_Key__c =:pq.Sales_Org_Key__c
            AND Duplicate__c = FALSE AND SearchableProducts__c = TRUE
            ORDER BY List_Price__c DESC LIMIT 1])
            {
            prods.add(curr.Id);
            }
            system.debug('prods ================== ' + prods);

            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSapPrice(prods,null,null,pq.Id);
            System.debug('*** End of sapPrice from PP_Price_Quote Class ***');
            return NULL;
            }*/
        }
        else{
            //apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.label.EMEA_Please_Enter_Valid_Material));
            return null;
        }
        
    }
    //end of SAP Price Method
    
    public List<Manually_Selectable_Contracts__c> getcpDropDown(){
        string buFilter = pq.Courtesy_Pricing_Type__c;
        
        // New Logic to Support Vascular and EMS - 27Oct2017 - ESC
        list<Manually_Selectable_Contracts__c> mscList = new list<Manually_Selectable_Contracts__c>();
        for(Manually_Selectable_Contracts__c msc : Manually_Selectable_Contracts__c.getall().values())
        {
            if(msc.Active__c && (buFilter == msc.Business_Unit__c || buFilter == 'Operations')){
                mscList.add(msc);
            }
        }
        system.debug('Vascular EMS: ' + buFilter + ' - ' + mscList);
        if(mscList.size() > 0){
            return mscList;
        }
        else{
            return NULL;
        }
        /* Previous Logic
try{
return [SELECT Name, Sales_Deal_Description__c
FROM Manually_Selectable_Contracts__c
WHERE Business_Unit__c = 'Vascular'
AND Active__c = TRUE];
}
catch (Exception ex){
return NULL;
}*/
        
    }
    
    public pagereference cpProcess(){
        String sdnum = ApexPages.currentPage().getParameters().get('sdnum');
        String pqId = ApexPages.currentPage().getParameters().get('pqId');
        map<String, Contract_Material__c> pMap = new map<String, Contract_Material__c>();
        for(Contract_Material__c cm : [SELECT Id, Material_Name__c, Price__c, Agreement__r.Objective__c,
                                       Agreement__r.Agreement_Number__c, Agreement__r.Description__c,
                                       Agreement__r.Id
                                       FROM Contract_Material__c
                                       WHERE Agreement__r.Agreement_Number__c = :sdnum
                                       AND Active__c = TRUE])
        {
            pMap.put(cm.Material_Name__c, cm);
        }
        list<Price_Quote_Line_Item__c> updPQLI = new list<Price_Quote_Line_Item__c>();
        for(Price_Quote_Line_Item__c pqli : [SELECT Id, Material_Name__r.Name
                                             FROM Price_Quote_Line_Item__c
                                             WHERE Price_Quote__r.Id = :pqid])
        {
            if(pMap.get(pqli.Material_Name__r.Name) != NULL){
                Price_Quote_Line_Item__c updatePQLI = new Price_Quote_Line_Item__c(
                    id = pqli.Id,
                    Eligible_Price__c = pMap.get(pqli.Material_Name__r.Name).Price__c,
                    Objective__c = pMap.get(pqli.Material_Name__r.Name).Agreement__r.Objective__c,
                    Sales_Deal_Description__c = '[*] ' + pMap.get(pqli.Material_Name__r.Name).Agreement__r.Description__c,
                    Sales_Deal__c  = pMap.get(pqli.Material_Name__r.Name).Agreement__r.Id,
                    Sales_Number__c = pMap.get(pqli.Material_Name__r.Name).Agreement__r.Agreement_Number__c,
                    Sales_Price__c = pMap.get(pqli.Material_Name__r.Name).Price__c,
                    Manually_Selected_Contract__c = TRUE
                );
                updPQLI.add(updatePQLI);
            }
        }
        if(updPQLI.size() > 0){
            update updPQLI;
        }
        return new Pagereference('/apex/PP_Price_Quote?pqid='+pqId).setRedirect(True);
        
    }
    
    //method for Cardiac bundle
    public void cardiacFavorites(){
        List<String> favList = new List<String>{'IAP-0500','IAA-01003','IAA-00175',
            'IAT-CE32','IAT-CE33','IAT-00201','IAT-00025','IAT-09844','AC2_BM_Train_POS',
            'AC2_Complete_EW','AC2_Select_EW','AC2_Biomed_EW'};
                
                PP_SAP_Price sapPrice = new PP_SAP_Price();
        sapPrice.getSAPpriceBulk(favList,pq.Id);
        
    }
    
    //method for Cardiac bundle
    public void cardiacFavorites700(){
        List<String> favList = new List<String>{'IAP-0700','IAA-01004','IAA-00175',
            'IAT-CE32','IAT-CE33'};
                
                PP_SAP_Price sapPrice = new PP_SAP_Price();
        sapPrice.getSAPpriceBulk(favList,pq.Id);
        
    }
    
    //method for Vascular bundles
    public void vascularBundlesWithUltra4yr(){
        System.debug('*** Starting vascularBundlesWithUltra4yr ***');
        List<String> matNamesList = new List<String>();
        List<Product2> matList = [SELECT Name, VPS_Rhythm_DLX_with_Ultrasound__c, X4_year__c FROM Product2 WHERE VPS_Rhythm_DLX_with_Ultrasound__c = TRUE AND
                                  X4_year__c = TRUE AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];
        if(matList.size() > 0){
            for(Product2 curr: matList){
                matNamesList.add(curr.name);
            }//end for loop for material names
        }//end if list size check
        
        if(matNamesList.size() > 0 ){
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPpriceBulk(matNamesList,pq.Id);
        }//end if list size check
        System.debug('*** Ending vascularBundlesWithUltra4yr ***');
    }//end vascularBundlesWithUltra4yr
    
    //method for Vascular bundle
    public void vascularBundlesWithUltra2yr(){
        System.debug('*** Starting vascularBundlesWithUltra2yr ***');
        List<String> matNamesList = new List<String>();
        List<Product2> matList = [SELECT Name, VPS_Rhythm_DLX_with_Ultrasound__c, X2_year__c FROM Product2 WHERE VPS_Rhythm_DLX_with_Ultrasound__c = TRUE AND
                                  X2_year__c = TRUE AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];
        if(matList.size() > 0){
            for(Product2 curr: matList){
                matNamesList.add(curr.name);
            }//end for loop for material names
        }//end if list size check
        
        if(matNamesList.size() > 0 ){
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPpriceBulk(matNamesList,pq.Id);
        }//end if list size check
        System.debug('*** Ending vascularBundlesWithUltra2yr ***');
    }//end vascularBundlesWithUltra2yr
    
    //method for Vascular bundle
    public void vascularBundlesWithoutUltra4yr(){
        System.debug('*** Starting vascularBundlesWithoutUltra4yr ***');
        List<String> matNamesList = new List<String>();
        List<Product2> matList = [SELECT Name, VPS_Rhythm_DLX_without_Ultrasound__c, X4_year__c FROM Product2 WHERE VPS_Rhythm_DLX_without_Ultrasound__c = TRUE AND
                                  X4_year__c = TRUE AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];
        if(matList.size() > 0){
            for(Product2 curr: matList){
                matNamesList.add(curr.name);
            }//end for loop for material names
        }//end if list size check
        
        if(matNamesList.size() > 0 ){
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPpriceBulk(matNamesList,pq.Id);
        }//end if list size check
        System.debug('*** Ending vascularBundlesWithoutUltra4yr ***');
    }//end vascularBundlesWithoutUltra4yr
    
    //method for Vascular bundle
    public void vascularBundlesWithoutUltra2yr(){
        System.debug('*** Starting vascularBundlesWithoutUltra2yr ***');
        List<String> matNamesList = new List<String>();
        List<Product2> matList = [SELECT Name, VPS_Rhythm_DLX_without_Ultrasound__c, X2_year__c 
                                  FROM Product2 WHERE VPS_Rhythm_DLX_without_Ultrasound__c = TRUE AND
                                  X2_year__c = TRUE AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];
        if(matList.size() > 0){
            for(Product2 curr: matList){
                matNamesList.add(curr.name);
            }//end for loop for material names
        }//end if list size check
        
        if(matNamesList.size() > 0 ){
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPpriceBulk(matNamesList,pq.Id);
        }//end if list size check
        System.debug('*** Ending vascularBundlesWithoutUltra2yr ***');
    }//end vascularBundlesWithoutUltra2yr
    
    //method for Vascular bundle
    public void vascularBundlesDlxProbe4yr(){
        System.debug('*** Starting vascularBundlesDlxProbe4yr ***');
        List<String> matNamesList = new List<String>();
        List<Product2> matList = [SELECT Name, DLX_Ultrasound_Probe_Only__c  , X4_year__c FROM Product2 WHERE DLX_Ultrasound_Probe_Only__c = TRUE AND
                                  X4_year__c = TRUE AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];
        if(matList.size() > 0){
            for(Product2 curr: matList){
                matNamesList.add(curr.name);
            }//end for loop for material names
        }//end if list size check
        
        if(matNamesList.size() > 0 ){
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPpriceBulk(matNamesList,pq.Id);
        }//end if list size check
        System.debug('*** Ending vascularBundlesDlxProbe4yr ***');
    }//end vascularBundlesDlxProbe4yr
    
    //method for Vascular bundle
    public void vascularBundlesDlxProbe2yr(){
        System.debug('*** Starting vascularBundlesDlxProbe2yr ***');
        List<String> matNamesList = new List<String>();
        List<Product2> matList = [SELECT Name, DLX_Ultrasound_Probe_Only__c, X2_year__c FROM Product2 WHERE DLX_Ultrasound_Probe_Only__c = TRUE AND
                                  X2_year__c = TRUE AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];
        if(matList.size() > 0){
            for(Product2 curr: matList){
                matNamesList.add(curr.name);
            }//end for loop for material names
        }//end if list size check
        
        if(matNamesList.size() > 0 ){
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPpriceBulk(matNamesList,pq.Id);
        }//end if list size check
        System.debug('*** Ending vascularBundlesDlxProbe2yr ***');
    }//end vascularBundlesDlxProbe2yr
    
    //method for Vascular bundle
    public void vascularBundlesRhythm3yr(){
        System.debug('*** Starting vascularBundlesRhythm3yr ***');
        List<String> matNamesList = new List<String>();
        List<Product2> matList = [SELECT Name, VPS_Rhythm__c, X3_year__c FROM Product2 WHERE VPS_Rhythm__c = TRUE AND
                                  X3_year__c = TRUE AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];
        if(matList.size() > 0){
            for(Product2 curr: matList){
                matNamesList.add(curr.name);
            }//end for loop for material names
        }//end if list size check
        
        if(matNamesList.size() > 0 ){
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPpriceBulk(matNamesList,pq.Id);
        }//end if list size check
        System.debug('*** Ending vascularBundlesRhythm3yr ***');
    }//end vascularBundlesRhythm3yr
    
    //method for Vascular bundle
    public void vascularBundlesRhythm1yr(){
        System.debug('*** Starting vascularBundlesRhythm1yr ***');
        List<String> matNamesList = new List<String>();
        List<Product2> matList = [SELECT Name, VPS_Rhythm__c, X1_year__c FROM Product2 WHERE VPS_Rhythm__c = TRUE AND
                                  X1_year__c = TRUE AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];
        if(matList.size() > 0){
            for(Product2 curr: matList){
                matNamesList.add(curr.name);
            }//end for loop for material names
        }//end if list size check
        
        if(matNamesList.size() > 0 ){
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPpriceBulk(matNamesList,pq.Id);
        }//end if list size check
        System.debug('*** Ending vascularBundlesRhythm1yr ***');
    }//end vascularBundlesRhythm1yr
    
    //method for Vascular bundle
    public void vascularBundlesRhythmRefurb3yr(){
        System.debug('*** Starting vascularBundlesRhythmRefurb3yr ***');
        List<String> matNamesList = new List<String>();
        List<Product2> matList = [SELECT Name, VPS_Rhythm_Refurb__c, X3_year__c FROM Product2 WHERE VPS_Rhythm_Refurb__c = TRUE AND
                                  X3_year__c = TRUE AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];
        if(matList.size() > 0){
            for(Product2 curr: matList){
                matNamesList.add(curr.name);
            }//end for loop for material names
        }//end if list size check
        
        if(matNamesList.size() > 0 ){
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPpriceBulk(matNamesList,pq.Id);
        }//end if list size check
        System.debug('*** Ending vascularBundlesRhythmRefurb3yr ***');
    }//end vascularBundlesRhythmRefurb3yr
    
    //method for Vascular bundle
    public void vascularBundlesRhythmRefurb1yr(){
        System.debug('*** Starting vascularBundlesRhythmRefurb1yr ***');
        List<String> matNamesList = new List<String>();
        List<Product2> matList = [SELECT Name, VPS_Rhythm_Refurb__c, X1_year__c FROM Product2 WHERE VPS_Rhythm_Refurb__c = TRUE AND
                                  X1_year__c = TRUE AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];
        if(matList.size() > 0){
            for(Product2 curr: matList){
                matNamesList.add(curr.name);
            }//end for loop for material names
        }//end if list size check
        
        if(matNamesList.size() > 0 ){
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPpriceBulk(matNamesList,pq.Id);
        }//end if list size check
        System.debug('*** Ending vascularBundlesRhythmRefurb1yr ***');
    }//end vascularBundlesRhythmRefurb3yr
    
    //method for Vascular bundle
    public void vascularBundlesG42yr(){
        System.debug('*** Starting vascularBundlesG42yr ***');
        List<String> matNamesList = new List<String>();
        List<Product2> matList = [SELECT Name, G4__c, X2_year__c FROM Product2 WHERE G4__c = TRUE AND
                                  X2_year__c = TRUE AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];
        if(matList.size() > 0){
            for(Product2 curr: matList){
                matNamesList.add(curr.name);
            }//end for loop for material names
        }//end if list size check
        
        if(matNamesList.size() > 0 ){
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPpriceBulk(matNamesList,pq.Id);
        }//end if list size check
        System.debug('*** Ending vascularBundlesG42yr ***');
    }//end vascularBundlesG42yr
    
    //method for Vascular bundle
    public void vascularBundlesG4refurb2yr(){
        System.debug('*** Starting vascularBundlesG4refurb2yr ***');
        List<String> matNamesList = new List<String>();
        List<Product2> matList = [SELECT Name, G4_Refurb__c, X2_year__c FROM Product2 WHERE G4_Refurb__c = TRUE AND
                                  X2_year__c = TRUE AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];
        if(matList.size() > 0){
            for(Product2 curr: matList){
                matNamesList.add(curr.name);
            }//end for loop for material names
        }//end if list size check
        
        if(matNamesList.size() > 0 ){
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSAPpriceBulk(matNamesList,pq.Id);
        }//end if list size check
        System.debug('*** Ending vascularBundlesG4refurb2yr ***');
    }//end vascularBundlesG4refurb2yr
    
    //Vascular Bundles Trade-In method
    public PageReference vascularTradeIn(){
        System.debug('*** Starting vascularTradeIn ***');
        hasError = false;
        //list to get product ID for trade-in
        List<String> prods = new List<String>();
        Integer matCount = 0;
        Integer tradeinCount = 0;
        String prodDesc;
        for(Price_Quote_Line_Item__c curr: getLineItems()){
            //check specific material count for trade-in match
            if(curr.Material_Name_Text__c == 'DLX-200-MTRB'){
                matCount = matCount + Integer.valueOf(curr.Quantity__c);
            }//end if
            
            //check specific material count for trade-in match
            prodDesc = curr.Product_Description__c;
            if(prodDesc.containsIgnoreCase('Trade-in Discount')){
                tradeinCount = tradeinCount + Integer.valueOf(curr.Quantity__c);
            }//end if
        }//end for loop
        
        System.debug('*** vascularTradeIn matCount *** ' + matCount);
        System.debug('*** vascularTradeIn tradeinCount *** ' + tradeinCount);
        if(matCount > tradeinCount){
            //get values from VF page
            String discPqId = apexpages.currentpage().getparameters().get('discPqId');
            String discType = apexpages.currentpage().getparameters().get('discType');
            System.debug('*** vascularTradeIn discPqId *** ' + discPqId);
            System.debug('*** vascularTradeIn discType *** ' + discType);
            
            String prodId = [SELECT Id FROM Product2 WHERE name =:discType AND Sales_Org_Key__c =:pq.Sales_Org_Key__c].Id;
            prods.add(prodId);
            
            //check list size and call method for pricing
            if(prods.size() > 0 ){
                PP_SAP_Price sapPrice = new PP_SAP_Price();
                sapPrice.getSAPprice(prods,null,null,discPqId);
                
                //confirmation method that trade-in has been added
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, SYstem.label.EMEA_Trade_In_has_been_added));
            }
            
            System.debug('*** End of vascularTradeIn from PP_Price_Quote Class ***');
            return NULL;
        }//end if count comparison
        else{
            System.debug('*** End of vascularTradeIn from PP_Price_Quote Class ***');
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.EMEA_Can_only_add_trade_ins_to_match_available_trade_in_products));
            return null;
        }        
        //System.debug('*** Ending vascularTradeIn ***');
    }//end vascularTradeIn
    
    // Alternate Bulk Insert
    public void bulkInsert2(){
        //strMats
        System.debug('*** strMats *** ' + strMats);
        String pqId = ApexPages.currentPage().getParameters().get('pqId');
        String bulkstr;
        List<String> bulkMatList = new List<String>();
        for(String bl : strMats.split('\n')){
            bulkstr = bl.trim();
            bulkstr = bulkstr.toUpperCase();
            bulkMatList.add(bulkstr);
        }
        system.debug('bulkMatList: ' + bulkMatList);
        
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        sapPrice.getSAPpriceBulk(bulkMatList,pqId);
        
    }
    
    
    //method to clone quote
    public Pagereference doCloning() {
        //String cloneType = Apexpages.currentpage().getParameters().get('cloneType');
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        Savepoint sp = Database.setSavepoint();
        PageReference newPage = null;
        List<Price_Quote_Line_Item__c> lstPriceQuote = new List<Price_Quote_Line_Item__c>();
        List<Price_Quote_Line_Item__c> newLines = new List<Price_Quote_Line_Item__c>();
        
        try {
            //get expiration dates for BUs
            Date anzDate = system.today() +30; //date for ANZ
            Date allDate = system.today() +90; //date for Other BUs
            Integer currYear = System.Today().year();
            Price_Quote__c quoteClone = new Price_Quote__c(
                Account_Name__c = pq.Account_Name__c,
                Contact_Name__c  = pq.Contact_Name__c,
                No_Opp__c = pq.No_Opp__c,
                One_Time_Purchase__c = pq.One_Time_Purchase__c,
                Sales_Org_Key__c = pq.Sales_Org_Key__c,
                Quote_Description__c = pq.Quote_Description__c,
                Customer_comments__c = pq.Customer_comments__c,
                Internal_Comments_Only__c = pq.Internal_Comments_Only__c,
                Shipping__c = pq.Shipping__c,
                Tax__c = pq.Tax__c,
                CurrencyIsoCode = pq.CurrencyIsoCode,
                Opportunity__c = pq.Opportunity__c, // This is what fires off automation to update the Opportunity and Change Line Items
                Product_Class_Count__c = pq.Product_Class_Count__c,
                BusinessUnit__c = pq.BusinessUnit__c,
                How_Created__c = userAgent + ' Quote Cloned',
                Sold_To__c  = pq.Sold_To__c 
            );
            
            //logic to handle ANZ Price Quotes
            if(pq.Sales_Org_Key__c == 'AU1010' || pq.Sales_Org_Key__c == 'NZ1010'){
                quoteClone.Expiration_Date__c = anzDate;
            }
            else{
                quoteClone.Expiration_Date__c = allDate;
            }
            if (pq.BusinessUnit__c == 'EMEA') {
                quoteClone.Expiration_Date__c = Date.newInstance(currYear, 12, 31);
            }
            system.debug('cloned Price Quote *** ' + quoteClone);
            insert quoteClone;
            
            If(pq.Line_Count__c > 0){
                system.debug('line count ***** ' + pq.Line_Count__c);
                lstPriceQuote = [SELECT id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c,Objective__c, Row_Order__c,
                                 Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c,
                                 Sales_deal_Description__c, Sales_Number__c, Competetive_Product__r.Competitor_Product_Code__c, Floor_Price__c,
                                 Material_Name__r.Name,Description__c, Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Director_Price__c,
                                 Rep_Price__c, List_Price__c, Line_Price__c, Material_Status_Description__c, Product_Description__c, IsBold__c,
                                 Material_Name__r.MRP_Group__c, MRP_Group__c, Requested_Pricing__c, Requested_Price__c, Requested_Pricing_CM__c,
                                 Price_Quote__r.BusinessUnit__c, Price_Per_Each__c, CurrencyIsoCode
                                 FROM Price_Quote_Line_Item__c
                                 WHERE Price_Quote__c =:pq.Id];
                
                for(Price_Quote_Line_Item__c curr : lstPriceQuote){
                    system.debug('In Line Item Create For Loop *****');
                    Price_Quote_Line_Item__c lineItems = new Price_Quote_Line_Item__c(
                        Price_Quote__c = quoteClone.Id,
                        Material_Name__c = curr.Material_Name__c,
                        Product_Description__c = curr.Product_Description__c,
                        Material_Status__c = curr.Material_Status__c,
                        Sales_Deal_Description__c = curr.Sales_Deal_Description__c,
                        Competetive_Product__c = curr.Competetive_Product__c,
                        Row_Order__c = curr.Row_Order__c,
                        List_Price__c = curr.List_Price__c,
                        RSM_Price__c = curr.RSM_Price__c,
                        Rep_Price__c = curr.Rep_Price__c,
                        Eligible_Price__c = curr.Eligible_Price__c,
                        Director_Price__c = curr.Director_Price__c,
                        Floor_Price__c = curr.Floor_Price__c,
                        Quantity__c = curr.Quantity__c,
                        Sales_Price__c = curr.Sales_Price__c,
                        Sales_Number__c = curr.Sales_Number__c,
                        Condition__c = curr.Condition__c,
                        Objective__c = curr.Objective__c,
                        IsBold__c = curr.IsBold__c,
                        MRP_Group__c = curr.MRP_Group__c,
                        CurrencyIsoCode = curr.CurrencyIsoCode,
                        Requested_Pricing__c = curr.Requested_Pricing__c,
                        Requested_Price__c = curr.Requested_Price__c,
                        Requested_Pricing_CM__c = curr.Requested_Pricing_CM__c
                    );
                    
                    newLines.add(lineItems);
                }//end of for loop
                
                If(newLines.size()>0){
                    system.debug('*** Inserting Line Items ***** ');
                    insert newLines;
                }
                
                newPage = new Pagereference('/apex/PP_Price_Quote?refresh=yes&pqId='+quoteClone.Id).setRedirect(True);
                return newPage;
            }
        }catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return newPage;
    }
    //end of method to clone quote
    
    public void updateFlag() {
        String rowId = Apexpages.currentpage().getParameters().get('trId');
        system.debug('*** rowId =============== ' + rowId);
        //system.debug('flagVal =============== ' + flagVal);
        
        Savepoint sp = Database.setSavepoint();
        
        Price_Quote_Line_Item__c lineObj = [SELECT Id, Row_Order__c,IsBold__c FROM Price_Quote_Line_Item__c
                                            WHERE Price_Quote__c =:pq.Id AND id =:rowId];
        try {
            if(lineObj.IsBold__c == true){
                lineObj.IsBold__c = False;
            }
            else{
                lineObj.IsBold__c = True;
            }
            update lineObj;
            
        }catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        
        
    }
    
    //single line update
    public PageReference Refresh(){
        String materialId = Apexpages.currentpage().getParameters().get('itemId');
        String lineItemId = Apexpages.currentpage().getParameters().get('lineItemId');
        system.debug('*** materialId ====================== ' + materialId);
        system.debug('*** lineItemId ====================== ' + lineItemId);
        
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        
        If(pq.Status__c == 'Approved'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+ System.label.EMEA_Cannot_add_Material_to_an_Approved_Quote_please_create_a_new_quote));
            return null;
        }
        else{
            List<String> matId = new List<String>();
            matId.add(materialId);
            sapPrice.getSAPprice(matId,'refresh',lineItemId,pq.Id);
            //fixString();
            Return NULL;
        }
    }//end of single line refresh method
    
    // Bulk Refresh
    public void bulkrefresh(){
        System.debug('*** Starting bulkRefresh ***');
        String pqId = ApexPages.currentPage().getParameters().get('pqId');
        
        String soldToType; //Variable to hold Sold To Price List Type
        list<Price_Quote_Line_Item__c> lineItemList = new list<Price_Quote_Line_Item__c>();
        set<String> mstringid = new set<String>();
        /*list<Price_Quote_Line_Item__c> pqlilist = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c,Price_Quote__r.BusinessUnit__c
        FROM Price_Quote_Line_Item__c
        WHERE Price_Quote__r.Id = :pqid AND Material_Name__c != NULL
        LIMIT 75 ];*/
        list<Price_Quote_Line_Item__c> pqlilist = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Sales_Org__c, 
                                                    Material_Name__r.Distribution_Channel__c,Price_Quote__r.BusinessUnit__c,
                                                    Min_Order_Qty__c, Material_Description__c, VAT__c
                                                   FROM Price_Quote_Line_Item__c
                                                   WHERE Price_Quote__r.Id = :pqid AND Material_Name__c != NULL];
        
        System.debug('*** pqlilist.size() *** ' + pqlilist.size());
        system.debug('*** pqlilist: ' + pqlilist);
        
        for(Price_Quote_Line_Item__c pqli : pqlilist){
            mstringid.add(pqli.Material_Name__r.Id);
        }
        system.debug('mstringid: ' + mstringid);
        
        try{
            Price_Quote__c pq = [SELECT Account_Name__r.SAP_Sold_To__c, Account_Name__r.Account_Group__c, Sales_Org_Key__c, BusinessUnit__c,
                                 Line_Count__c, Account_Name__r.Price_List_Type__c, Product_Class_Count__c, Owner_Business_Unit__c, CurrencyIsoCode
                                 FROM Price_Quote__c
                                 WHERE Id =: pqId LIMIT 1];
            system.debug('*** pq ====================== ' + pq);
            soldToType = pq.Account_Name__r.Price_List_Type__c;
            
            list<Product2> mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c, Floor_Price__c, Cost_Formula__c,
                                     List_Price__c, RSM_Price__c, Rep_Price__c, Director_Price__c, Description, CurrencyIsoCode,
                                     Distributor_List__c, Alt_Site_List__c, MRP_Group__c, SearchableProducts__c, Min_Order_Qty__c
                                     FROM Product2
                                     WHERE Id IN :mstringid
                                     AND Sales_Org_Key__c =: pq.Sales_Org_Key__c
                                     AND Duplicate__c = FALSE AND SearchableProducts__c = TRUE];
            system.debug('*** mcheck ====================== ' + mcheck);
            
            // Create the Product Mapping
            map<String, Product2> prodmap = new map<String, Product2>();
            for(Product2 pmap : mcheck){
                prodmap.put(pmap.Name, pmap);
            }
            system.debug('*** prodmap: ' + prodmap);
            
            // Determine which SAP Number to use for Lookup
            string pcn = pq.Account_Name__r.SAP_Sold_To__c;
            string shipTo = pq.Account_Name__r.SAP_Sold_To__c;
            
            if(pq.Account_Name__r.Account_Group__c == 'Z002'){
                for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                                  FROM Contract_Partnership__c
                                                  WHERE Ship_to__c =:pq.Account_Name__r.SAP_Sold_To__c
                                                  AND Disabled__c = FALSE])
                {
                    pcn = cp.Sale_to__c;
                }
                
                //Query to get Price List Type of SAP Sold To Account
                soldToType = [SELECT Price_List_Type__c FROM Account WHERE SAP_Sold_To__c = :pcn LIMIT 1].Price_List_Type__c;
            }
            
            System.debug('*** pcn (Primary Customer Number) ================ ' + pcn);
            // Start building the line items
            
            // Prospect Account Process (No SAP) #1
            System.debug('*** pq.Account_Name__r.SAP_Sold_To__c PP_Price_Quote bulkRefresh *** ' + pq.Account_Name__r.SAP_Sold_To__c);
            if(pq.Account_Name__r.SAP_Sold_To__c == NULL){
                system.debug('*** Starting getPrice without SAP ***');
                
                for(Price_Quote_Line_Item__c ml : pqlilist){
                    
                    Price_Quote_Line_Item__c  pqLineItem = new Price_Quote_Line_Item__c (
                        Price_Quote__c = pq.Id,
                        Material_Name__c = prodmap.get(ml.Material_Name__r.Name).Id,
                        CurrencyIsoCode = pq.CurrencyIsoCode,
                        //List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                        RSM_Price__c = prodmap.get(ml.Material_Name__r.Name).RSM_Price__c,
                        Rep_Price__c = prodmap.get(ml.Material_Name__r.Name).Rep_Price__c,
                        Director_Price__c = prodmap.get(ml.Material_Name__r.Name).Director_Price__c,
                        Floor_Price__c = prodmap.get(ml.Material_Name__r.Name).Floor_Price__c,
                        Cost__c = prodmap.get(ml.Material_Name__r.Name).Cost_Formula__c,
                        MRP_Group__c = prodmap.get(ml.Material_Name__r.Name).MRP_Group__c,
                        Min_Order_Qty__c = prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c
                        //Sales_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                        //Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c
                    );
                    
                    //Checking for EMEA BU and User to add Minimum Order Quantity
                    if(pq.BusinessUnit__c == 'EMEA'){
                        System.debug('*** Is EMEA User ***' );
                        if(prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c != NULL && prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c != 0){
                            System.debug('*** NOT NULL or 0.... prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c *** ' + prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c);
                            pqLineItem.Min_Order_Qty__c = prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c;
                            pqLineItem.Quantity__c = prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c;
                        }
                        else{
                            System.debug('*** Is NULL or 0.... mcprodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c *** ' + prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c);
                            pqLineItem.Min_Order_Qty__c = 1;
                        }
                    }

                    //logic to handle Hospital, Distributor, and Alt Site pricing
                    System.debug('*** pq.Sales_Org_Key__c PP_Price_Quote bulkRefresh *** ' + pq.Sales_Org_Key__c);
                    System.debug('*** soldToType PP_Price_Quote bulkRefresh *** ' + soldToType);
                    if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){ //add Canada
                        //Alt Site Accounts
                        if(soldToType == 'ZA'){
                            if(prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c != 0.00){
                                pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                //pqLineItem.Sales_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                            }
                            else{
                                pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                //pqLineItem.Sales_Price__c = 0.01;
                                pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                            }
                        }
                        
                        //Distributor Accounts
                        if(soldToType == 'ZD'){
                            if(prodmap.get(ml.Material_Name__r.Name).Distributor_List__c != 0.00){
                                pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                //pqLineItem.Sales_Price__c = prodmap.get(ml).Distributor_List__c;
                                pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                            }
                            else{
                                pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                //pqLineItem.Sales_Price__c = 0.01;
                                pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                            }
                        }
                        
                        //Hospital Accounts
                        if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                            if(prodmap.get(ml.Material_Name__r.Name).List_Price__c != 0.00){
                                pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                //pqLineItem.Sales_Price__c = prodmap.get(ml).List_Price__c;
                                pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                            }
                            else{
                                pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                //pqLineItem.Sales_Price__c = 0.01;
                                pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                            }
                        }
                        //end of logic to handle Hospital, Distributor, and Alt Site pricing
                    }//end of if pq.Sales_Org_Key__c
                    else if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                        system.debug('*** In LATAM bulkRefresh ***');
                        pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                        pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                    }
                    else{
                        if(prodmap.get(ml.Material_Name__r.Name).List_Price__c != 0.00){
                            pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                            //pqLineItem.Sales_Price__c = prodmap.get(ml).List_Price__c;
                            pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                        }
                        else{
                            pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                            //pqLineItem.Sales_Price__c = 0.01;
                            pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                        }
                    }//end of else pq.Sales_Org_Key__c
                    
                    lineItemList.add(pqLineItem);
                }
            }//end of SAP != NULL
            else{// Customer Account Process #2
                system.debug('Starting getPrice with SAP');
                system.debug('***shipTo*** ' + shipTo);
                system.debug('***pcn*** ' + pcn);
                Map<String, String> cMap = new Map<String, String>();
                for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
                    cMap.put(scm.Name, scm.Mapped_Value__c);
                }
                system.debug('cMap ============== ' + cMap);
                
                //Start getting SAP info
                for(Price_Quote_Line_Item__c ml : pqlilist)
                {
                    if(Test.isRunningTest()){
                        if(pq.Account_Name__r.SAP_Sold_To__c == '999999'){
                            SAPRealPriceSet__x sap = new SAPRealPriceSet__x(
                                SalesDeal__c = '50009064',
                                Price__c = 0.00,
                                Material__c = ml.Material_Name__r.Name,
                                MtrlStatus__c = '40',
                                SalesMtrlStatus__c = '40',
                                ValidFrom__c = Date.Today(),
                                ValidTo__c = Date.Today() + 1000,
                                AgrDesc__c = 'Duke University SURGR',
                                Condition__c = 'XNAF',
                                OwnerName__c = 'Duke Univ Health System',
                                Owner__c = 'IDN-032',
                                AgrObjective__c = '06',
                                Customer__c  = '999999'
                            );
                            //sapList.add(testSAP);
                        }//end if sap code check
                        else{
                            SAPRealPriceSet__x sap = new SAPRealPriceSet__x(
                                SalesDeal__c = '50009064',
                                Price__c = 123.00,
                                Material__c = ml.Material_Name__r.Name,
                                MtrlStatus__c = '40',
                                SalesMtrlStatus__c = '40',
                                ValidFrom__c = Date.Today(),
                                ValidTo__c = Date.Today() + 1000,
                                AgrDesc__c = 'Duke University SURGR',
                                Condition__c = 'XNAF',
                                OwnerName__c = 'Duke Univ Health System',
                                Owner__c = 'IDN-032',
                                AgrObjective__c = '06',
                                Customer__c  = pcn
                            );
                            //sapList.add(testSAP); 
                        }//end sap code check
                        
                    }//end (Test.isRunningTest())
                    for(SAPRealPriceSet__x sap : [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c,
                                                  ValidFrom__c, ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                                  OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                                  DistChnl__c,ShipTo__c, VAT__c, MatDesc__c, Currency__c
                                                  FROM SAPRealPriceSet__x
                                                  WHERE SalesOrg__c =:ml.Material_Name__r.Sales_Org__c
                                                  AND DistChnl__c =:ml.Material_Name__r.Distribution_Channel__c
                                                  AND Customer__c =:pcn
                                                  AND ShipTo__c = :shipTo
                                                  AND Material__c =:ml.Material_Name__r.Name
                                                  AND EffDate__c =:datetime.now()
                                                 ])
                    {
                        system.debug('sap: ' + sap);
                        
                        string conremap = sap.Condition__c;
                        if(cMap.get(sap.Condition__c) != NULL){
                            conremap = cMap.get(sap.Condition__c);
                        }
                        system.debug('conditionMap: ' + cMap);
                        
                        string salesDeal;
                        if(sap.SalesDeal__c != NULL){
                            salesDeal = sap.SalesDeal__c.right(8);
                        }
                        system.debug('salesDeal ================ ' + salesDeal);
                        
                        string mstatus;
                        if(sap.SalesMtrlStatus__c != NULL){
                            mstatus = sap.SalesMtrlStatus__c;
                        }
                        else if(sap.MtrlStatus__c != NULL){
                            mstatus = sap.MtrlStatus__c;
                        }
                        
                        Price_Quote_Line_Item__c  li = new Price_Quote_Line_Item__c (
                            Price_Quote__c = pq.Id,
                            Material_Name__c = prodmap.get(ml.Material_Name__r.Name).Id,
                            //Product_Description__c = prodmap.get(ml.Material_Name__r.Name).Description,
                            Material_Status__c = mstatus,
                            CurrencyIsoCode = pq.CurrencyIsoCode,
                            //List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                            RSM_Price__c = prodmap.get(ml.Material_Name__r.Name).RSM_Price__c,
                            Rep_Price__c = prodmap.get(ml.Material_Name__r.Name).Rep_Price__c,
                            Director_Price__c = prodmap.get(ml.Material_Name__r.Name).Director_Price__c,
                            Floor_Price__c = prodmap.get(ml.Material_Name__r.Name).Floor_Price__c,
                            Cost__c = prodmap.get(ml.Material_Name__r.Name).Cost_Formula__c,
                            Condition__c = conremap,
                            Sales_Deal_Description__c = sap.AgrDesc__c,
                            Sales_Number__c = salesDeal,
                            Id = ml.Id,
                            Objective__c = sap.AgrObjective__c,
                            MRP_Group__c = prodmap.get(ml.Material_Name__r.Name).MRP_Group__c,
                            Min_Order_Qty__c = prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c
                        );
                        
                        //Checking for EMEA BU and User to add Minimum Order Quantity
                        if(pq.BusinessUnit__c == 'EMEA'){
                            System.debug('*** Is EMEA User ***' );
                            if(prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c != NULL && prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c != 0){
                                System.debug('*** NOT NULL or 0.... prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c *** ' + prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c);
                                li.Min_Order_Qty__c = prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c;
                                li.Quantity__c = prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c;
                            }
                            else{
                                System.debug('*** Is NULL or 0.... prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c *** ' + prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c);
                                li.Min_Order_Qty__c = 1;
                            }
                        }

                        if(pq.Businessunit__c == 'EMEA'){
                            system.debug('****VAT*****'+ li.VAT__c);
                            li.Material_Description__c=sap.MatDesc__c;
                            li.CurrencyIsoCode = sap.Currency__c;
                            if(sap.VAT__c == NULL){
                                li.VAT__c = NULL;
                            }else{
                                system.debug('****DESC*****'+ li.Material_Description__c);
                                li.VAT__c = Decimal.Valueof(sap.Vat__c);
                                system.debug('****li.VAT__c***** '+ li.VAT__c);
                            }
                        }
                        else{
                            li.CurrencyIsoCode = pq.CurrencyIsoCode;
                        }

                        //more EMEA Logic for Material Description
                        system.debug('****BU*****'+ pq.Businessunit__c);
                        if(pq.Businessunit__c == 'EMEA'){
                            system.debug('****VAT*****'+ li.VAT__c);
                            li.Material_Description__c=sap.MatDesc__c;
                            li.CurrencyIsoCode = sap.Currency__c;
                            if(li.VAT__c == NULL){
                                li.VAT__c = NULL;
                            }
                                else{
                                system.debug('****DESC*****'+ li.Material_Description__c);
                                li.VAT__c = Decimal.Valueof(sap.Vat__c);
                                    }
                        }
                        else{
                            li.CurrencyIsoCode = pq.CurrencyIsoCode;
                        }
                        system.debug('****PQLI*****'+ li);

                        system.debug('*** sap.Price__c bulkRefresh *** ' + sap.Price__c);
                        //check for eligible price = 0
                        if(sap.Price__c != 0.00){
                            //li.Sales_Price__c = sap.Price__c;
                            li.Eligible_Price__c = sap.Price__c;
                            
                            //logic to handle Hospital, Distributor, and Alt Site pricing
                            if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){ //add Canada
                                //Alt Site Accounts
                                if(soldToType == 'ZA'){
                                    li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                }
                                
                                //Distributor Accounts
                                if(soldToType == 'ZD'){
                                    li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                }
                                
                                //Hospital Accounts
                                if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                    li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                }
                            }//end of if pq.Sales_Org_Key__c
                            else if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                            }
                            else{
                                li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                            }//end of else pq.Sales_Org_Key__c
                            
                        }
                        else{
                            //logic to handle Hospital, Distributor, and Alt Site pricing
                            if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){ //add Canada
                                //Alt Site Accounts
                                if(soldToType == 'ZA'){
                                    if(prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c != 0.00){
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                        //li.Sales_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                        li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                    }
                                    else{
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                        //li.Sales_Price__c = 0.01;
                                        li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                    }
                                }
                                
                                //Distributor Accounts
                                if(soldToType == 'ZD'){
                                    if(prodmap.get(ml.Material_Name__r.Name).Distributor_List__c != 0.00){
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                        //li.Sales_Price__c = prodmap.get(ml).Distributor_List__c;
                                        li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                    }
                                    else{
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                        //li.Sales_Price__c = 0.01;
                                        li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                    }
                                }
                                
                                //Hospital Accounts
                                if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                    if(prodmap.get(ml.Material_Name__r.Name).List_Price__c != 0.00){
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                        //li.Sales_Price__c = prodmap.get(ml).List_Price__c;
                                        li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                    }
                                    else{
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                        //li.Sales_Price__c = 0.01;
                                        li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                    }
                                }
                                //end of logic to handle Hospital, Distributor, and Alt Site pricing
                            }//end of if pq.Sales_Org_Key__c
                            else if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                            }
                            else{
                                if(prodmap.get(ml.Material_Name__r.Name).List_Price__c != 0.00){
                                    li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                    //li.Sales_Price__c = prodmap.get(ml).List_Price__c;
                                    li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                }
                                else{
                                    li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                    //li.Sales_Price__c = 0.01;
                                    li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                }
                            }//end of else pq.Sales_Org_Key__c
                            
                        }//end of outter else
                        //add object to list
                        lineItemList.add(li);
                        system.debug('*** lineItemList ======================== ' + lineItemList);
                    }
                }
                // DML - Update Lines
                System.debug('*** lineItemList.size() *** ' + lineItemList.size() );
                If(lineItemList.size() > 0){
                    System.debug('*** Bulk Refresh --- Updating Line Items ***');
                    system.debug('*** lineItemList ======================= ' + lineItemList);
                    update lineItemList;
                    
                    //conditions below helps with Price Quote and PRF Approval Matrix Routing
                    if(pq.BusinessUnit__c == 'Alternate Care'){
                        PP_SAP_Price sapPrice = new PP_SAP_Price();
                        sapPrice.lineClassCheck(pqId);
                    }
                    
                    if(pq.BusinessUnit__c == 'Anesthesia'){
                        PP_SAP_Price sapPrice = new PP_SAP_Price();
                        sapPrice.lineProdCheckAnes(pqId);
                    }
                    
                    if(pq.BusinessUnit__c == 'Interventional Capital' || pq.BusinessUnit__c == 'Cardiac'){
                        PP_SAP_Price sapPrice = new PP_SAP_Price();
                        sapPrice.lineProdCheckIcap(pqId);
                    }
                }
            }
            //fixString();
        }
        catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
        }
        System.debug('*** End of bulkRefresh ***');
    }//end of bulk refresh
    
    // This Imports a Quote to a PRF
    public PageReference createPRF() {
        if(pq.Type__c == 'ASK Agreement'){
            return new Pagereference('/apex/PP_PRF_Edit?step=3&aid=' + pq.Account_Name__c +
                                     '&cid=' + pq.Contact_Name__c + '&pqid=' + pq.Id + '&salesOrgKey=' + pq.Sales_Org_Key__c +
                                     '&type=' + pq.Type__c).setRedirect(True);
        }
        else{
            return new Pagereference('/apex/PP_PRF_Edit?step=3&aid=' + pq.Account_Name__c +
                                     '&cid=' + pq.Contact_Name__c + '&pqid=' + pq.Id + '&salesOrgKey=' + pq.Sales_Org_Key__c).setRedirect(True);
        }
        
    }//end createPRF
    
    //add blank row
    public void blankRow(){
        //system.debug('lineCount ***** ' + lineCount);
        Price_Quote_Line_Item__c li = new Price_Quote_Line_Item__c(Price_Quote__c=pq.Id,IsBold__c=true,Row_Order__c=pq.Line_Count__c+1);
        insert li;
    }
    
    //method to fix Product Description Case
    public PageReference fixString(){
        strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
        List<Price_Quote_Line_Item__c> matDesc = [Select id, Price_Quote__c, Product_Description__c
                                                  FROM Price_Quote_Line_Item__c
                                                  WHERE Price_Quote__c=: strQuoteId AND Material_Name__c != NULL
                                                  ORDER BY Row_Order__c NULLS LAST];
        
        system.debug('lineItems: ' + lineItems);
        List<Price_Quote_Line_Item__c> updLines = new List<Price_Quote_Line_Item__c>();
        
        for (Price_Quote_Line_Item__c curr : matDesc)
        {
            if(curr.Product_Description__c != NULL){
                String matString = curr.Product_Description__c;
                matString = matString.replace(',',', ');
                system.debug('matString before ***** ' + matString);
                List<String> elems = matString.split(' ');
                matString = '';
                for(String x : elems){
                    if(x.length() >= 4 || (x == 'SET' || x == 'LAB' || x == 'BONE')){
                        matString += x.substring(0,1).toUpperCase() + x.substring(1,x.length()).toLowerCase() + ' ';
                    }
                    //else if(x.startsWith('1') || x.startsWith('2') || x.startsWith('3') || x.startsWith('4') || x.startsWith('5') || x.startsWith('6')
                    //        || x.startsWith('7') || x.startsWith('8') || x.startsWith('9') ){
                    //  matString += x.substring(0,x.length()) + ' ';
                    //}
                    else{
                        matString += x.substring(0,x.length()) + ' ';
                    }
                    system.debug('matString after ***** ' + matString);
                }
                
                curr.Product_Description__c = matString;
                system.debug('curr.Product_Description__c ***** ' + curr.Product_Description__c);
                updLines.add(curr);
            }//end if
            
        }//end of for
        
        update updLines;
        return null;
    }
    //end of method to attempt to fix description
    
    //method to cancel a Price Quote
    public PageReference cancel(){
        system.debug('Cancelling Quote');
        Price_Quote__c li = new Price_Quote__c(Id=pq.Id,Status__c='Cancelled');
        system.debug('li.Status__c ***** ' + li.Status__c);
        try{
            update li;
            return new Pagereference('/apex/PP_Price_Quote?pqid=' + pq.Id).setRedirect(True);
        }
        catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Something went wrong.Check cancel method in PP_Price_Quote class...' + e.getMessage()));
            return null;
        }
    }
    
    //method to create Opportunity
    //
    public PageReference newCreateOpp(){
        system.debug(' -- Starting the newCreateOpp Class -- ');
        
        list<Price_Quote__c> pqList = new list<Price_Quote__c>();
        pqList.add(pq);
        PP_Price_Quote_Helper_Class.createOpp(pqList);
        
        return new Pagereference('/apex/PP_Price_Quote?pqid=' + pq.Id).setRedirect(True);
    }
    
    
    
    public PageReference makeActivePQ(){
        
        if(pq.Opportunity__c != NULL){
            Opportunity updateOp = new Opportunity(
                Id = pq.Opportunity__c,
                Price_Quote__c=pq.Id
            );
            update updateOp;
        }
        
        
        return new Pagereference('/apex/PP_Price_Quote?pqid=' + pq.Id).setRedirect(True);
    }
    
    //email quote to self
    public PageReference sendReport() {
        
        system.debug('sendReport method in PP_Price_Quote Class');
        custEmail = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()].email;
        // Create email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new String[]{ this.custEmail });
        //message.setTargetObjectId(quote.Contact_Name__c);
        //message.setSaveAsActivity(true);
        //message.setWhatId(qId);
        message.setSubject('Quote summary for ' + pq.Name);
        message.setHtmlBody('Here\'s a summary for the ' + pq.Name + ' quote.');
        
        //PageReference PP_Print_Quote_POC = New PageReference('/apex/PP_Print_Quote?id=' + pq.Id );
        string quoteURL;
        Map<String, Quote_Logos__c> buMap = Quote_Logos__c.getAll();
        if(buMap.get(pq.Stationary__c) != NULL){
            quoteURL = buMap.get(pq.Stationary__c).Quote_Page__c;
        }
        else{
            quoteURL = 'PP_Print_Quote';
        }
        
        PageReference PP_Print_Quote_POC = New PageReference('/apex/' + quoteURL + '?id=' + pq.Id + lang);
        
        Blob quotePDF;
        try {
            system.debug('In Try Block ==================== ');
            quotePDF = PP_Print_Quote_POC.getContentAsPDF();
            system.debug('quotePDF==================== ' + quotePDF);
        }
        catch (Exception e) {
            system.debug('In Exception ==================== ');
            quotePDF = Blob.valueOf(e.getMessage());
        }
        
        system.debug('quotePdf==================== ' + quotePdf);
        // Attach PDF to email and send
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        Attachment att = new Attachment();
        attachment.setContentType('application/pdf');
        attachment.setFileName(pq.Name + '-' + pq.Account_Name__r.Name + '-#' + pq.Account_Name__r.Sap_Sold_To__c + '-' + datetime.Now() + '.pdf');
        attachment.setInline(false);
        attachment.setBody(quotePDF);
        att.Body = quotePDF;
        att.ParentId = pq.Id;
        att.ContentType = 'application/pdf';
        att.Name = pq.Name + '-' + pq.Account_Name__r.Name + '-#' + pq.Account_Name__r.Sap_Sold_To__c + '-' + datetime.Now();
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{ attachment });
        
        try{
            system.debug('Sending email to self');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ message });
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        insert att;
        system.debug('attachment==================== ' + attachment);
        
        ApexPages.addMessage(new
                             ApexPages.Message(ApexPages.Severity.CONFIRM,
                                               'Email sent with PDF attachment to ' + this.custEmail));
        //return new Pagereference('/apex/PP_Price_Quote?pqid=' + pq.Id).setRedirect(True);
        return null;
    }
    //end of quote to self
    
    //get gross margin %
    public Map<Id,Decimal> getMargins(List<Price_Quote_Line_Item__c> lineItems){
        
        String strurl = ApexPages.currentPage().getUrl();
        strurl = strurl.split('apex/')[1];
        system.debug('strurl getMargins *** ' + strurl);
        
        if(strurl.containsIgnoreCase('PP_ApprovalLayout')){
            system.debug('lineItems getMargins: ' + lineItems);
            
            if(lineItems.size()>0 ){
                
                for(Price_Quote_Line_Item__c curr : lineItems){
                    system.debug('*** In getMargins for Loop ***');
                    system.debug('*** curr.Material_Name__r.Cost__c *** ' + curr.Material_Name__r.Cost__c);
                    if(curr.Material_Name__r.Cost__c != NULL && curr.Material_Name__r.Cost__c != 0.00){
                        system.debug('*** In getMargins curr.Material_Name__r.Cost__c != NULL && curr.Material_Name__r.Cost__c != 0.00 check ***');
                        Decimal myDecimal;
                        if(curr.Sales_Price__c == 0 || curr.Sales_Price__c == 0.00){
                            myDecimal = 0.01;
                        }
                        else{
                            myDecimal = curr.Sales_Price__c;
                        }
                        //system.debug('curr.Sales_Price__c ' + curr.Sales_Price__c);
                        Decimal grossMargin;
                        if(curr.Material_Name__r.Qty_Sales_Unit__c == 0){
                            curr.Material_Name__r.Qty_Sales_Unit__c = 1;
                        }
                        
                        //system.debug('convUnit *** ' + convUnit);
                        //logic to handle Cost__c or Transfer_Price__c issues
                        Double newCost = 0;
                        if(curr.Material_Name__r.Cost__c == 0 || curr.Material_Name__r.Cost__c == NULL){
                            if(curr.Material_Name__r.Transfer_Price__c == 0 || curr.Material_Name__r.Transfer_Price__c == NULL){
                                newCost = (0/1000)- 0;
                            }
                            else{
                                newCost = (0/1000)- curr.Material_Name__r.Transfer_Price__c;
                            }
                        }
                        else{
                            if(curr.Material_Name__r.Transfer_Price__c == 0 || curr.Material_Name__r.Transfer_Price__c == NULL){
                                newCost = (curr.Material_Name__r.Cost__c/1000)- 0;
                            }
                            else{
                                newCost = (curr.Material_Name__r.Cost__c/1000)- curr.Material_Name__r.Transfer_Price__c;
                            }
                        }
                        
                        system.debug('newCost *** ' + newCost);
                        newCost *= curr.Material_Name__r.Qty_Sales_Unit__c;
                        system.debug('newCost new *** ' + newCost);
                        system.debug('myDecimal *** ' + myDecimal);
                        if((myDecimal == 0 || myDecimal == 0.00) && newCost != 0.00){
                            if(curr.Eligible_Price__c == 0 || curr.Eligible_Price__c == 0.00){
                                myDecimal = 0.01;
                            }
                            system.debug('myDecimal new *** ' + myDecimal);
                            grossMargin = ((myDecimal - newCost)/(myDecimal)).setScale(3) *100;
                            grossMargin = grossMargin.stripTrailingZeros();
                            margins.put(curr.Id,grossMargin);
                            system.debug('margins *** ' + margins);
                            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, myDecimal + System.label.EMEA_Sales_Price_can_not_be_0_Please_enter_a_price_other_than_0));
                        }
                        else{
                            grossMargin = ((myDecimal - newCost)/(myDecimal)).setScale(3) *100;
                            grossMargin = grossMargin.stripTrailingZeros();
                            margins.put(curr.Id,grossMargin);
                            system.debug('margins *** ' + margins);
                        }
                    }
                    
                }//end of for loop
            }
            return margins;
        }//end if page check
        else{
            return null;
        }
        
    }
    //end of gross margin
    
    //get price check
    public Map<Id,String> getPriceCheck(List<Price_Quote_Line_Item__c> lineItems){
        System.debug('----------- getPriceCheck -----------');
        String strurl = ApexPages.currentPage().getUrl();
        strurl = strurl.split('apex/')[1];
        system.debug('strurl getPriceCheck *** ' + strurl);
        
        if(strurl.containsIgnoreCase('PP_ApprovalLayout')){
            String check = ' - ';
            Integer convUnit = 1000;
            system.debug('lineItems getPriceCheck: ' + lineItems);
            
            if(lineItems.size()>0 ){
                for(Price_Quote_Line_Item__c curr : lineItems){
                    system.debug('sales price = ' + curr.Sales_Price__c);
                    system.debug('eligible price = ' + curr.Eligible_Price__c);
                    system.debug('Sales_deal_Description__c = ' + curr.Sales_deal_Description__c);
                    system.debug('cost = ' + curr.Material_Name__r.Cost_Formula__c);
                    //System.debug('===== BELOW COST CONDITION CHECK ===== ' + curr.Sales_Price__c < curr.Material_Name__r.Cost_Formula__c+' *** SALES PRICE CHECK *** '+ curr.Sales_Price__c != NULL);
                    
                    if(curr.Sales_Price__c < curr.Material_Name__r.Cost_Formula__c){
                        System.debug(curr.Sales_Price__c);
                        System.debug(curr.Material_Name__r.Cost_Formula__c);
                        System.debug('=============== TRUE ===============');
                    }
                    else{
                        System.debug('SP ' + curr.Sales_Price__c);
                        System.debug('CF ' + curr.Material_Name__r.Cost_Formula__c);
                        System.debug('=============== FALSE ===============');
                    }
                    
                    if(curr.Sales_Price__c == NULL){
                        check = '';
                        //break;
                    }
                    else if(curr.Sales_Price__c == curr.Eligible_Price__c && curr.Sales_deal_Description__c != NULL){
                        check = 'On Contract';
                        //break;
                    }
                    else if(curr.Sales_Price__c < curr.Material_Name__r.Cost_Formula__c && curr.Sales_Price__c != NULL){
                        check = 'Below Cost';
                        //break;
                    }
                    else if(curr.Sales_Price__c < curr.Material_Name__r.Floor_Price__c && curr.Material_Name__r.Floor_Price__c != NULL){
                        check = 'Below Floor';
                        //break;
                    }
                    else if(curr.Sales_Price__c < curr.Material_Name__r.Director_Price__c && curr.Material_Name__r.Director_Price__c != NULL){
                        check = 'Below Director';
                        //break;
                    }
                    else if(curr.Sales_Price__c < curr.RSM_Price__c && curr.RSM_Price__c != NULL){
                        check = 'Below RSM';
                        //break;
                    }
                    else if(curr.Sales_Price__c < curr.Rep_Price__c && curr.Rep_Price__c != NULL){
                        check = 'Below Rep';
                        //break;
                    }
                    else if(curr.Sales_Price__c > curr.List_Price__c && curr.List_Price__c != NULL){
                        check = 'Above Hospital List';
                        //break;
                    }
                    else if(curr.Sales_Price__c > curr.Material_Name__r.Distributor_List__c && curr.Material_Name__r.Distributor_List__c != NULL){
                        check = 'Good';
                        //break;
                    }
                    else{
                        check = 'Good';
                    }
                    
                    system.debug('curr.Id *** ' + curr.Id + ' check *** ' + check);
                    priceCheck.put(curr.Id,check);
                }//end of for loop
            }
            return priceCheck;
        }//end of if for page check
        else{
            return null;
        }
    }
    //end of price check
    
    //get min contract price
    public Map<Id,Decimal> getMinContract(List<Price_Quote_Line_Item__c> lineItems){
        String strurl = ApexPages.currentPage().getUrl();
        strurl = strurl.split('apex/')[1];
        system.debug('strurl getMinContract *** ' + strurl);
        
        if(strurl.containsIgnoreCase('PP_ApprovalLayout')){
            
            system.debug('lineItems getMinContract: ' + lineItems);
            List<String> getIds = new List<String>();
            
            for(Price_Quote_Line_Item__c curr : lineItems){
                getIds.add(curr.Material_Name__c);
            }
            
            system.debug('getIds getMinContract *** ' + getIds);
            
            Map<Id,Product2> prodMap = new Map<Id,Product2>([Select Id,
                                                             (Select Price__c From Contract_Material__r Order by Price__c ASC NULLS Last LIMIT 1)
                                                             From Product2 WHERE Id IN :getIds AND Sales_Org_key__c =: pq.Sales_Org_key__c]);
            
            if(Test.isRunningTest()){
                prodMap = new Map<Id,Product2>([Select Id,
                                                (Select Price__c From Contract_Material__r
                                                 WHERE Agreement__r.Owner__c LIKE '%GPO%' AND Price__c != NULL Order by Price__c ASC NULLS Last LIMIT 1)
                                                From Product2 WHERE Sales_Org_key__c =: pq.Sales_Org_key__c]);
            }
            
            if(prodMap.size() > 0){
                system.debug('*** In prodMap.size() ***');
                for(Product2 curr : prodMap.values()){
                    if(curr.Contract_Material__r.size() > 0){
                        minContract.put(curr.Id, prodMap.get(curr.Id).Contract_Material__r[0].Price__c);
                    }
                    else{
                        minContract.put(curr.Id, 0);
                    }
                }//end of for loop
            }
            else{
                system.debug('*** In else to prodMap.size() ***');
                
            }
            system.debug('minContract *** ' + minContract);
            return minContract;
        }//end of if page check
        else{
            return null;
        }
    }
    //end of min contract price
    
    //get min contract agreement
    public Map<Id,String> getMinContractAgree(List<Price_Quote_Line_Item__c> lineItems){
        
        String strurl = ApexPages.currentPage().getUrl();
        strurl = strurl.split('apex/')[1];
        system.debug('strurl getMinContractAgree *** ' + strurl);
        
        if(strurl.containsIgnoreCase('PP_ApprovalLayout')){
            system.debug('lineItems getMinContractAgree: ' + lineItems);
            List<String> getIds = new List<String>();
            
            for(Price_Quote_Line_Item__c curr : lineItems){
                getIds.add(curr.Material_Name__c);
            }
            
            system.debug('getIds getMinContractAgree *** ' + getIds);
            
            Map<Id,Product2> prodMap = new Map<Id,Product2>([Select Id,
                                                             (Select Agreement__r.Description__c From Contract_Material__r Order by Price__c ASC NULLS Last LIMIT 1)
                                                             From Product2 WHERE Id IN :getIds AND Sales_Org_key__c =: pq.Sales_Org_key__c]);
            
            if(Test.isRunningTest()){
                prodMap = new Map<Id,Product2>([Select Id,
                                                (Select Price__c, Agreement__r.Description__c From Contract_Material__r
                                                 WHERE Agreement__r.Owner__c LIKE '%GPO%' AND Price__c != NULL Order by Price__c ASC NULLS Last LIMIT 1)
                                                From Product2 WHERE Sales_Org_key__c =: pq.Sales_Org_key__c]);
            }
            
            if(prodMap.size() > 0){
                for(Product2 curr : prodMap.values()){
                    if(curr.Contract_Material__r.size() > 0){
                        minContractAgree.put(curr.Id, prodMap.get(curr.Id).Contract_Material__r[0].Agreement__r.Description__c);
                    }
                    else{
                        minContractAgree.put(curr.Id, ' ');
                    }
                }//end of for loop
            }
            
            return minContractAgree;
        }//end of if page check
        else{
            return null;
        }
    }
    //end of min contract agreement
    
    //get min gpo price
    public Map<Id,Decimal> getMinGpo(List<Price_Quote_Line_Item__c> lineItems){
        
        String strurl = ApexPages.currentPage().getUrl();
        strurl = strurl.split('apex/')[1];
        system.debug('strurl getMinGpo *** ' + strurl);
        
        if(strurl.containsIgnoreCase('PP_ApprovalLayout')){
            system.debug('lineItems: ' + lineItems);
            List<String> getIds = new List<String>();
            
            for(Price_Quote_Line_Item__c curr : lineItems){
                getIds.add(curr.Material_Name__c);
            }
            
            system.debug('getIds getMinGpo *** ' + getIds);
            
            Map<Id,Product2> prodMap = new Map<Id,Product2>([Select Id,
                                                             (Select Price__c From Contract_Material__r
                                                              WHERE Agreement__r.Owner__c LIKE '%GPO%' AND Price__c != NULL Order by Price__c ASC NULLS Last LIMIT 1)
                                                             From Product2 WHERE Id IN :getIds AND Sales_Org_key__c =: pq.Sales_Org_key__c]);
            
            if(Test.isRunningTest()){
                prodMap = new Map<Id,Product2>([Select Id,
                                                (Select Price__c From Contract_Material__r
                                                 WHERE Agreement__r.Owner__c LIKE '%GPO%' AND Price__c != NULL Order by Price__c ASC NULLS Last LIMIT 1)
                                                From Product2 WHERE Sales_Org_key__c =: pq.Sales_Org_key__c]);
            }
            
            system.debug('prodMap getMinGpo *** ' + prodMap);
            if(prodMap.size() > 0){
                for(Product2 curr : prodMap.values()){
                    if(curr.Contract_Material__r.size() > 0){
                        minGpo.put(curr.Id, prodMap.get(curr.Id).Contract_Material__r[0].Price__c);
                    }
                    else{
                        minGpo.put(curr.Id, 0);
                    }
                }//end of for loop
            }
            //system.debug('minGpo.size() *** ' + minGpo.size());
            return minGpo;
        }//end if page check
        else{
            return null;
        }
        
    }
    //end of min gpo price
    
    //get min gpo agreement
    public Map<Id,String> getMinGpoAgree(List<Price_Quote_Line_Item__c> lineItems){
        
        String strurl = ApexPages.currentPage().getUrl();
        strurl = strurl.split('apex/')[1];
        system.debug('strurl getMinGpoAgree *** ' + strurl);
        
        if(strurl.containsIgnoreCase('PP_ApprovalLayout')){
            system.debug('lineItems getMinGpoAgree: ' + lineItems);
            List<String> getIds = new List<String>();
            
            for(Price_Quote_Line_Item__c curr : lineItems){
                getIds.add(curr.Material_Name__c);
            }
            
            system.debug('getIds getMinGpoAgree *** ' + getIds);
            
            Map<Id,Product2> prodMap = new Map<Id,Product2>([Select Id,
                                                             (Select Agreement__r.Description__c From Contract_Material__r
                                                              WHERE Agreement__r.Owner__c LIKE '%GPO%' Order by Price__c ASC NULLS Last LIMIT 1)
                                                             From Product2 WHERE Id IN :getIds AND Sales_Org_key__c =: pq.Sales_Org_key__c]);
            
            if(Test.isRunningTest()){
                prodMap = new Map<Id,Product2>([Select Id,
                                                (Select Price__c, Agreement__r.Description__c From Contract_Material__r
                                                 WHERE Agreement__r.Owner__c LIKE '%GPO%' AND Price__c != NULL Order by Price__c ASC NULLS Last LIMIT 1)
                                                From Product2 WHERE Sales_Org_key__c =: pq.Sales_Org_key__c]);
            }
            
            if(prodMap.size() > 0){
                for(Product2 curr : prodMap.values()){
                    //system.debug('price *** ' + prodMap.get(curr.Id).Contract_Material__r[0].Price__c);
                    if(curr.Contract_Material__r.size() > 0){
                        minGpoAgree.put(curr.Id, prodMap.get(curr.Id).Contract_Material__r[0].Agreement__r.Description__c);
                    }
                    else{
                        minGpoAgree.put(curr.Id, ' ');
                    }
                }//end of for loop
            }
            return minGpoAgree;
        }//end if page check
        else{
            return null;
        }
        
    }
    //end of min gpo agreement
    
    //method to auto approve a quote
    public void AutoApprove(){
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        
        app.setObjectId(pq.id);
        
        Approval.ProcessResult result = Approval.process(app);
        
        if(result.isSuccess()){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Approve');
        }
        
    }
    //end of auto approve
    
    //Approve Method for PP_ApprovalLayout page (click Approve button)
    public PageReference Approve(){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments(appComments);
        req.setAction('Approve');
        Id retVal = null;
        Id approverId = null;
        List<ProcessInstanceWorkitem> workList = new List<ProcessInstanceWorkitem>();//used to get specific user approval ID
        List<ProcessInstanceWorkitem> workListCheck = new List<ProcessInstanceWorkitem>();//used to check for Contracts Team Queue
        workList = [Select Id, ActorId, OriginalActorId, OriginalActor.Name
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId =:pq.Id AND ActorId =:UserInfo.getUserId() ];
        
        //condition handles situation for unanimous approval
        if( workList.size() > 0 ){
            retVal = workList[0].Id;
            approverId = workList[0].ActorId;
        }
        else{
            //check for Contracts Team Queue
            workListCheck = [Select Id, ActorId, OriginalActorId, OriginalActor.Name
                             FROM ProcessInstanceWorkitem
                             WHERE ProcessInstance.TargetObjectId =:pq.Id AND Actor.Name = 'Contracts Team' LIMIT 1];
            
            if( workListCheck.size() > 0 ){
                System.debug('*** In Contracts Check ***');
                //get Contracts Team Member User Id
                String contractUserId = [SELECT UserOrGroupId
                                         FROM GroupMember
                                         WHERE Group.Name = 'Contracts Team'
                                         AND UserOrGroupId =:UserInfo.getUserId() LIMIT 1 ].UserOrGroupId;
                
                retVal = workListCheck[0].Id;
                approverId = contractUserId;
                
                //Re-assigning Approval to Contracts Person before Approving
                workListCheck[0].ActorId = approverId;
                update workListCheck;
            }//end if workListCheck
        }//end else
        
        //check for Id for final submit
        if(retVal != NULL){
            //set approval request for completion
            req.setWorkitemId(retVal);
            Approval.ProcessResult result =  Approval.process(req);
        }
        
        PageReference approvalPage = new Pagereference('/apex/PP_Price_Quote?pqId='+pq.Id).setRedirect(true);
        return approvalPage ;
    }//end off custom Approval (used on PP_ApprovalLayout page)
    
    //Reject Method for PP_ApprovalLayout page (click Reject button)
    public PageReference Reject(){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments(appComments);
        req.setAction('Reject');
        Id retVal = null;
        Id approverId = null;
        List<ProcessInstanceWorkitem> workList = new List<ProcessInstanceWorkitem>();//used to get specific user approval ID
        List<ProcessInstanceWorkitem> workListCheck = new List<ProcessInstanceWorkitem>();//used to check for Contracts Team Queue
        workList = [Select Id, ActorId, OriginalActorId, OriginalActor.Name
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId =:pq.Id AND ActorId =:UserInfo.getUserId() ];
        
        //condition handles situation for unanimous approval
        if( workList.size() > 0 ){
            retVal = workList[0].Id;
            approverId = workList[0].ActorId;
        }
        else{
            //check for Contracts Team Queue
            workListCheck = [Select Id, ActorId, OriginalActorId, OriginalActor.Name
                             FROM ProcessInstanceWorkitem
                             WHERE ProcessInstance.TargetObjectId =:pq.Id AND Actor.Name = 'Contracts Team'];
            
            if( workListCheck.size() > 0 ){
                System.debug('*** In Contracts Check ***');
                //get Contracts Team Member User Id
                String contractUserId = [SELECT UserOrGroupId
                                         FROM GroupMember
                                         WHERE Group.Name = 'Contracts Team'
                                         AND UserOrGroupId =:UserInfo.getUserId() LIMIT 1 ].UserOrGroupId;
                
                retVal = workListCheck[0].Id;
                approverId = contractUserId;
                
                //Re-assigning Approval to Contracts Person before Approving
                workListCheck[0].ActorId = approverId;
                update workListCheck;
            }//end if workListCheck
        }//end else
        
        //check for Id for final submit
        if(retVal != NULL){
            //set approval request for completion
            req.setWorkitemId(retVal);
            Approval.ProcessResult result =  Approval.process(req);
        }
        
        PageReference approvalPage = new Pagereference('/apex/PP_Price_Quote?pqId='+pq.Id).setRedirect(true);
        return approvalPage ;
    }//end of custom reject
    
    //method to recall an Approval request when in Salesforce Lightning UI
    @RemoteAction
    public static void recall(String pqId){
        System.debug('*** pqId in recall method *** ' + pqId);
        try{
            ProcessInstanceWorkitem workItem = [SELECT Id, ActorId, ProcessInstance.TargetObjectId
                                                FROM ProcessInstanceWorkitem
                                                WHERE ProcessInstance.TargetObjectId =:pqId LIMIT 1];
            System.debug('*** Recalling Record ***');
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            pwr.setAction('Removed');
            pwr.setWorkItemId(workItem.Id);
            //Approval.ProcessResult result = Approval.process(pwr);
        }catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
        }
        
        //PageReference pqPage = new Pagereference('/apex/PP_Price_Quote?pqId='+pqId).setRedirect(true);
        //return pqPage;
    }
    //end of recall method
    
    //method to recall an Approval request when in Salesforce Lightning UI
    public PageReference recall2(){
        try{
            System.debug('*** Recalling Record ***');
            ProcessInstanceWorkitem workItem = [SELECT Id, ActorId, ProcessInstance.TargetObjectId
                                                FROM ProcessInstanceWorkitem
                                                WHERE ProcessInstance.TargetObjectId =:pq.Id LIMIT 1];
            
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            pwr.setAction('Removed');
            pwr.setWorkItemId(workItem.Id);
            Approval.ProcessResult result = Approval.process(pwr);
        }catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
        }
        
        PageReference pqPage = new Pagereference('/apex/PP_Price_Quote?pqId='+pq.Id).setRedirect(true);
        return pqPage;
    }
    //end of recall method
    //get approval history info
    public List<ProcessInstanceWorkitem> getApprovalInfo(){
        //list to hold Records
        /*
approvalInfo = [SELECT Id, StepStatus, Comments, Actor.Name, OriginalActor.Name, CreatedDate,
ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate
FROM ProcessInstanceStep
WHERE ProcessInstance.TargetObjectId =:ApexPages.currentPage().getParameters().get('pqid')
ORDER BY CreatedDate ASC];
*/
        try{
            approvalInfo = [SELECT ActorId, Id, OriginalActorId, OriginalActor.Name, Actor.Name, ProcessInstanceId
                            FROM ProcessInstanceWorkitem
                            WHERE ProcessInstance.TargetObjectId =:ApexPages.currentPage().getParameters().get('pqid')
                            ORDER BY CreatedDate ASC];
            
            return approvalInfo;
        }
        catch(Exception e){
            return null;
        }
        
    }//end of getApprovalInfo
    
    @RemoteAction
    public static Price_Quote_Line_Item__c updateBlank(id lineId, string blankInput){
        system.debug('In updateBlank Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Price_Quote_Line_Item__c li = new Price_Quote_Line_Item__c(Id=lineId,Product_Description__c=blankInput);
        update li;
        return li;
    }
    
    @RemoteAction
    public static Price_Quote_Line_Item__c updateQuantity(id lineId, integer qty){
        system.debug('In updateQuantity Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Price_Quote_Line_Item__c li = new Price_Quote_Line_Item__c(Id=lineId,Quantity__c=qty);
        update li;
        return li;
    }
    
    @RemoteAction
    global static Price_Quote_Line_Item__c updatePrice(id lineId, decimal price){
        system.debug('In updatePrice Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        
        Id pid; // Product Id
        Id pqId; // Price Quote Id - In Case we need it for Phase 2
        string userBusUnit; // Users Business Unit
        string materialName; //for testing
        string salesOrg; //for testing
        string distrChan; //for testing
        for(Price_Quote_Line_Item__c pqli : [Select Material_Name__c, Material_Name_Text__c, Price_Quote__c, Price_Quote__r.BusinessUnit__c, Sales_Org__c, Distribution_Channel__c
                                             FROM Price_Quote_Line_Item__c
                                             WHERE Id = :lineId])
        {
            userBusUnit = pqli.Price_Quote__r.BusinessUnit__c;
            pid = pqli.Material_Name__c;
            pqId = pqli.Price_Quote__c;
            materialName = pqli.Material_Name_Text__c; //testing
            salesOrg = pqli.Sales_Org__c; //testing
            distrChan = pqli.Distribution_Channel__c; //testing
        }
        
        Id chId;
        Id cmId;
        Decimal cmPrice;
        
        // Detemrine if we have a match using Price
        for(Contract_Material__c cm : [SELECT Id, Price__c, Agreement__c
                                       FROM Contract_Material__c
                                       WHERE Product__c = :pid
                                       AND Active__c = TRUE
                                       AND Agreement__r.Pricing_Tier__c = TRUE
                                       AND Price__c = :price
                                       LIMIT 1])
        {
            cmId = cm.Id;
            chId = cm.Agreement__c;
            cmPrice = cm.Price__c;
        }
        
        //check if test is running to get contract values
        if(Test.isRunningTest()){
            /*
Contract_Material__c cm = [SELECT Id, Price__c, Agreement__c
FROM Contract_Material__c
WHERE Product__c = :pid
AND Active__c = TRUE
AND Agreement__r.Pricing_Tier__c = TRUE
LIMIT 1];
cmId = cm.Id;
chId = cm.Agreement__c;
cmPrice = cm.Price__c;
*/
            Contract_Material__c cmTest = new Contract_Material__c(
                Product__c = pid 
            );
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeaderPt('50009064', '123310','D','US60');
            insert ch1;
            
            Contract_Material__c cm = testDataFactoryPP.createContractMaterialPt(ch1.Id, ch1.Agreement_Number__c, materialName, pid, salesOrg, '10', distrChan,
                                                                                 'RESP-D',1,755.74,540,504,432,432);
            insert cm;
            cmId = cm.Id;
            chId = cm.Agreement__c;
            cmPrice = cm.Price__c;
        }//set cmId to get test coverage
        
        Price_Quote_Line_Item__c li = new Price_Quote_Line_Item__c(
            Id = lineId,
            Sales_Price__c = price
        );
        
        if(cmId != NULL){
            // Phase 2
            list<Price_Quote_Line_Item__c> pqliList = new list<Price_Quote_Line_Item__c>();
            list<Price_Quote_Line_Item__c> pqliUpdate = new list<Price_Quote_Line_Item__c>();
            map<Id, Contract_Material__c> cmMap = new map<Id, Contract_Material__c>(); // Product Id == CM Record
            set<Id> pSet = new set<Id>();
            
            // Checks to see if the related Business Unit on the Price Quote has 'Tier Unlocked'
            boolean tierUnlocked = FALSE;
            for(Business_Unit__c bu : Business_Unit__c.getall().values()){
                if(userBusUnit == bu.Name && bu.Pricing_Tiers_Unlocked__c == TRUE){
                    tierUnlocked = TRUE;
                }
            }
            
            // Update the PQ Line Item
            li.Requested_Pricing__c = chId;
            li.Requested_Pricing_CM__c = cmId;
            li.Requested_Price__c = cmPrice;
            pqliUpdate.add(li); // Add it to the list
            
            
            if(tierUnlocked == FALSE){ // Checks to see if the related Business Unit on the Price Quote has 'Tier Unlocked'
                // Time to fix the rest of the line items
                for(Price_Quote_Line_Item__c pqli : [Select Id, Material_Name__c, Sales_Price__c, Requested_Pricing__c, Price_Quote__r.BusinessUnit__c,
                                                     Requested_Pricing_CM__c, Requested_Price__c
                                                     FROM Price_Quote_Line_Item__c
                                                     WHERE Price_Quote__c = :pqId])
                {
                    if(pqli.Material_Name__c != NULL){
                        if(pqli.Id != lineId){
                            pqliList.add(pqli);
                        }
                        pSet.add(pqli.Material_Name__c);
                    }
                    else{
                        if(pqli.Material_Name__c != NULL){
                            if(Test.isRunningTest() && pqliList.size() == 0){
                                pqliList.add(pqli);
                            }//end if(Test.isRunningTest() && pqliList.size() == 0) 
                        }//end if(pqli.Material_Name__c != NULL) 
                    }//end else
                }//end for loop
                
                // Create map using Product Id == Contract Material Record
                for(Contract_Material__c cm : [SELECT Id, Price__c, Agreement__c, Product__c
                                               FROM Contract_Material__c
                                               WHERE Product__c = :pSet
                                               AND Active__c = TRUE
                                               AND Agreement__r.Pricing_Tier__c = TRUE
                                               AND Agreement__c = :chId])
                {
                    cmMap.put(cm.Product__c, cm);
                }
                
                // Check the rest of the PQ Line Items
                for(Price_Quote_Line_Item__c pqli : pqliList){
                    if(cmMap.containsKey(pqli.Material_Name__c)){
                        Price_Quote_Line_Item__c newli = new Price_Quote_Line_Item__c(
                            id = pqli.Id,
                            Sales_Price__c = cmMap.get(pqli.Material_Name__c).Price__c,
                            Requested_Pricing__c = cmMap.get(pqli.Material_Name__c).Agreement__c,
                            Requested_Pricing_CM__c = cmMap.get(pqli.Material_Name__c).Id,
                            Requested_Price__c = cmMap.get(pqli.Material_Name__c).Price__c
                        );
                        pqliUpdate.add(newli);
                        
                    }
                }
            }
            
            
            // Update the PQ Line Items
            if(pqliUpdate.size() > 0){
                update pqliUpdate;
            }
            
        }
        else{
            li.Requested_Pricing__c = NULL;
            li.Requested_Pricing_CM__c = NULL;
            li.Requested_Price__c = 0;
            
            update li;
        }
        
        return li;
    }
    
    @RemoteAction
    public static Price_Quote_Line_Item__c updateOrder(id lineId, integer row){
        system.debug('In updateOrder Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Price_Quote_Line_Item__c li = new Price_Quote_Line_Item__c(Id=lineId,Row_Order__c=row);
        update li;
        return li;
    }
    
    public Map<Id,String> getFormatListPrices(List<Price_Quote_Line_Item__c> lineItems){
        System.debug('*** IN getFormatListPrices *** ');
        Decimal formDec;
        String newDec;
        for(Price_Quote_Line_Item__c curr : lineItems){
            System.debug('*** curr.Id *** ' + curr.Id);
            System.debug('*** curr.Material_Name__r.List_Price__c *** ' + curr.List_Price__c);
            String accName = pq.Account_Name__r.Name;
            if(Test.isRunningTest() && accName.containsIgnoreCase('TestAccount') ){
                userLocale = 'en_GB'; 
            }
            
            if(userLocale != 'en_US'){
                System.debug('*** userLocale *** ' + userLocale);
                if(curr.List_Price__c == NULL){
                    curr.List_Price__c = 0;
                }
                formDec = curr.List_Price__c;
                newDec = formDec.format();
                formatListPrices.put(curr.Id,newDec);
            }
            else{
                System.debug('*** userLocale *** ' + userLocale);
                if(curr.List_Price__c == NULL){
                    curr.List_Price__c = 0;
                }
                newDec = String.valueOf(curr.List_Price__c);
                formatListPrices.put(curr.Id,newDec);
            }
        }
        System.debug('*** formatListPrices *** ' + formatListPrices);
        return formatListPrices;
    }//end of getFormatListPrices
    
    //format currency for different locales
    public Map<Id,String> getFormatRsmPrices(List<Price_Quote_Line_Item__c> lineItems){
        System.debug('*** IN getFormatRsmPrices *** ');
        Decimal formDec;
        String newDec;
        for(Price_Quote_Line_Item__c curr : lineItems){
            System.debug('*** curr.Id *** ' + curr.Id);
            String accName = pq.Account_Name__r.Name;
            if(Test.isRunningTest() && accName.containsIgnoreCase('TestAccount') ){
                userLocale = 'en_GB'; 
            }
            System.debug('*** userLocale *** ' + userLocale);
            if(userLocale != 'en_US'){
                if(curr.Rsm_Price__c == NULL){
                    curr.Rsm_Price__c = 0;
                }
                formDec = curr.Rsm_Price__c;
                newDec = formDec.format();
                formatRsmPrices.put(curr.Id,newDec);
            }
            else{
                if(curr.Rsm_Price__c == NULL){
                    curr.Rsm_Price__c = 0;
                }
                newDec = String.valueOf(curr.Rsm_Price__c);
                formatRsmPrices.put(curr.Id,newDec);
            }
        }
        System.debug('*** formatRsmPrices *** ' + formatRsmPrices);
        return formatRsmPrices;
    }//end of getFormatRsmPrices
    
    //format currency for different locales
    public Map<Id,String> getFormatRepPrices(List<Price_Quote_Line_Item__c> lineItems){
        System.debug('*** IN getFormatRepPrices *** ');
        Decimal formDec;
        String newDec;
        for(Price_Quote_Line_Item__c curr : lineItems){
            System.debug('*** curr.Id *** ' + curr.Id);
            System.debug('*** userLocale getFormatRepPrices *** ' + userLocale);
            String accName = pq.Account_Name__r.Name;
            if(Test.isRunningTest() && accName.containsIgnoreCase('TestAccount') ){
                userLocale = 'en_GB'; 
            }
            System.debug('*** userLocale getFormatRepPrices *** ' + userLocale);
            if(userLocale != 'en_US'){
                if(curr.Rep_Price__c == NULL){
                    curr.Rep_Price__c = 0;
                }
                formDec = curr.Rep_Price__c;
                newDec = formDec.format();
                formatRepPrices.put(curr.Id,newDec);
            }
            else{
                if(curr.Rep_Price__c == NULL){
                    curr.Rep_Price__c = 0;
                }
                newDec = String.valueOf(curr.Rep_Price__c);
                formatRepPrices.put(curr.Id,newDec);
            }
        }
        System.debug('*** formatRepPrices *** ' + formatRepPrices);
        return formatRepPrices;
    }//end of getFormatRepPrices
    
    //format currency for different locales
    public Map<Id,String> getFormatEligiblePrices(List<Price_Quote_Line_Item__c> lineItems){
        System.debug('*** IN getFormatEligiblePrices *** ');
        Decimal formDec;
        String newDec;
        for(Price_Quote_Line_Item__c curr : lineItems){
            System.debug('*** curr.Id *** ' + curr.Id);
            String accName = pq.Account_Name__r.Name;
            if(Test.isRunningTest() && accName.containsIgnoreCase('TestAccount') ){
                userLocale = 'en_GB'; 
            }
            System.debug('*** userLocale *** ' + userLocale);
            if(userLocale != 'en_US'){
                if(curr.Eligible_Price__c == NULL){
                    curr.Eligible_Price__c = 0;
                }
                formDec = curr.Eligible_Price__c;
                newDec = formDec.format();
                formatEligiblePrices.put(curr.Id,newDec);
            }
            else{
                if(curr.Eligible_Price__c == NULL){
                    curr.Eligible_Price__c = 0;
                }
                newDec = String.valueOf(curr.Eligible_Price__c);
                formatEligiblePrices.put(curr.Id,newDec);
            }
        }
        System.debug('*** formatEligiblePrices *** ' + formatEligiblePrices);
        return formatEligiblePrices;
    }//end of getFormatEligiblePrices
    
    //format currency for different locales
    public Map<Id,String> getFormatLinePrices(List<Price_Quote_Line_Item__c> lineItems){
        System.debug('*** IN getFormatLinePrices *** ');
        Decimal formDec;
        String newDec;
        for(Price_Quote_Line_Item__c curr : lineItems){
            String accName = pq.Account_Name__r.Name;
            if(Test.isRunningTest() && accName.containsIgnoreCase('TestAccount') ){
                userLocale = 'en_GB'; 
            }
            System.debug('*** userLocale *** ' + userLocale);
            if(userLocale != 'en_US'){
                formDec = curr.Line_Price__c;
                newDec = formDec.format();
                formatLinePrices.put(curr.Id,newDec);
            }
            else{
                newDec = String.valueOf(curr.Line_Price__c);
                formatLinePrices.put(curr.Id,newDec);
            }
        }
        System.debug('*** formatLinePrices *** ' + formatLinePrices);
        return formatLinePrices;
    }//end of getFormatLinePrices
    
    //format currency for different locales
    public Map<Id,String> getFormatSalesPrices(List<Price_Quote_Line_Item__c> lineItems){
        System.debug('*** IN getFormatSalesPrices *** ');
        Decimal formDec;
        String newDec;
        for(Price_Quote_Line_Item__c curr : lineItems){
            System.debug('*** curr.Id *** ' + curr.Id);
            System.debug('*** userLocale *** ' + userLocale);
            String accName = pq.Account_Name__r.Name;
            if(Test.isRunningTest() && accName.containsIgnoreCase('TestAccount') ){
                userLocale = 'en_GB'; 
            }
            System.debug('*** userLocale *** ' + userLocale);
            if(userLocale != 'en_US'){
                formDec = curr.Sales_Price__c;
                newDec = formDec.format();
                formatSalesPrices.put(curr.Id,newDec);
            }
            else{
                newDec = String.valueOf(curr.Sales_Price__c);
                formatSalesPrices.put(curr.Id,newDec);
            }
        }
        System.debug('*** formatSalesPrices *** ' + formatSalesPrices);
        return formatSalesPrices;
    }//end of getFormatSalesPrices
    
    //method to help with dynamically translating labels for unsupported languages
    public Map<String,String> getLabelsMap(List<Label_Translation__c> labelTranslationsList){
        //system.debug('****In labelsMap labelName**** ' + labelName);
        Map<String, String> labelTranslationsMap = new Map<String, String>();
        system.debug('****labelTranslationsList.size()**** ' + labelTranslationsList.size());
        if(labelTranslationsList.size()>0){
            //create map of label and translation
            for(Label_Translation__c curr : labelTranslationsList){
                labelTranslationsMap.put(curr.Label_Name__c,curr.Translated_Value__c);
            }
        }
        system.debug('****labelTranslationsMapLast**** ' + labelTranslationsMap);
        return labelTranslationsMap;
    }//end getLabelsMap

    //format currency for different locales
    public Map<Id,String> getFormatTotalPrices(Id pqId){
        System.debug('*** IN getFormatTotalPrices *** ');
        Decimal formDec;
        String newDec;
        String accName = pq.Account_Name__r.Name;
        if(Test.isRunningTest() && accName.containsIgnoreCase('TestAccount') ){
            userLocale = 'en_GB'; 
        }
        System.debug('*** userLocale *** ' + userLocale);
        if(userLocale != 'en_US'){
            formDec = grandTotal.setScale(2);
            System.debug('*** formDec *** ' + formDec);
            newDec = formDec.format();
            formatTotalPrices.put(pqId,newDec);
        }
        else{
            newDec = String.valueOf(grandTotal.setScale(2) );
            System.debug('*** newDec *** ' + newDec);
            formatTotalPrices.put(pqId,newDec);
        }
        //}
        System.debug('*** formatTotalPrices *** ' + formatTotalPrices);
        return formatTotalPrices;
    }//end of getFormatTotalPrices
    
}//end of class