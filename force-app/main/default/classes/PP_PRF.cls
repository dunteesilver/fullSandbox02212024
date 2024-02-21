/*********************************************************************
* Description      : Controller Class for Pricing Portal PRF process.
* Test Class       : PP_Global_Test_Class_Test
* VisualForce      : PP_PRF
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
public without sharing class PP_PRF {

    public String strProdSearch {get; set;}
    public String bulkMatStr {get; set;}
    public Map<String,Sales_Orgs__c> soMap;
    public List<Prf_Line_Item__c> currList; 
    //public PRF__c prf2 {get;set;}
    /*
    public PageReference pageReturnPRF {get{
        PageReference pageReturn;
        if(pageReturnPRF == NULL && ApexPages.currentPage().getParameters().get('id') != NULL){
            pageReturn = new PageReference('/apex/PP_Price_Quote?pqId='+ ApexPages.currentPage().getParameters().get('id')).setRedirect(True);
        }
        return pageReturn;
    } set;}*/

    //Variable used in pricing logic to determine list price
    /*Public Map<String,Sales_Orgs__c> soMap {get{
        Map<String,Sales_Orgs__c> soMapNew = new Map<String,Sales_Orgs__c>();
        List<Sales_Orgs__c> soList = [SELECT Id,Name, Sales_Org__c, Distribution_Channel__c, Pricing_Type__c FROM Sales_Orgs__c WHERE Active__c = true];
        
        if(soList.size() > 0){
            for(Sales_Orgs__c curr : soList){
                soMapNew.put(curr.Name,curr);
            }//end for loop
        }//end if
        return soMapNew;
    }set;}*/
    
    public Boolean isDirect{get;set;} //get Type value to rerender distributor field
    public Boolean isAsk{get;set;} //get Type value to rerender fields for ASK process
    public Boolean hasAskItems {get;set;} //help determin if line items are ASK products

    public String prfid {get{
        return ApexPages.currentPage().getParameters().get('id');
    } set;}
    public Decimal requestedPrice {get{
        if(requestedPrice == 0.0){
            return NULL;
        }
        else{
            return requestedPrice;
        }
    } set;}
    public boolean createPath {get{
        if(ApexPages.currentPage().getParameters().get('step') != NULL){
            return TRUE;
        }
        else return FALSE;
    } set;}

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

    public String selectedValue {get;set;}
    public List<SelectOption> options {get;set;}

    public String selectedGPO {get{
      if(prf.Id != NULL){
        PRF__c pickGPO = [SELECT Id, GPO_Affiliation__c FROM PRF__c WHERE Id =:prf.Id LIMIT 1];

        if(pickGPO.GPO_Affiliation__c != NULL && pickGPO.GPO_Affiliation__c != ''){
          selectedGPO = pickGPO.GPO_Affiliation__c;
          selectedValue = selectedGPO;
        }
      }
      else{
        selectedGPO = selectedValue;
        //selectedValue = '';
      }

      return selectedGPO;
    }
    set;}

    //used to disable Export PRF Form button when PRF needs approval
    public Boolean needsApproval {get{
        Decimal num = [Select Id, Approval_Flag_Rollup__c FROM Prf__c
                       WHERE id = :prf.Id LIMIT 1].Approval_Flag_Rollup__c;
        if(num > 0.0){
            return true;
        }else{
            return false;
        }

    }set;}

    //variables for displaying Sold To Account and Type
    Public String soldToAcct {get{
      try{
        if(prf.Account__r.Account_Group__c == 'Z002'){
            soldToAcct = [SELECT Sale_to__c, Ship_to__c
                          FROM Contract_Partnership__c
                          WHERE Ship_to__c =:prf.Account__r.SAP_Sold_To__c
                          AND Disabled__c = FALSE].Sale_to__c;

            return soldToAcct;
        }
        else{
            return NULL;
        }
      }
      catch(Exception e){
        soldToAcct = '';
        return soldToAcct;
      }
    }set;}

    Public String soldToAcctType {get{
      try{
        soldToAcctType = [SELECT Price_List_Type__c
                      FROM Account
                      WHERE SAP_Sold_To__c =:soldToAcct].Price_List_Type__c;

        return soldToAcctType;
      }
      catch(Exception e){
        soldToAcctType = '';
        return soldToAcctType;
      }
    }set;}

    public String wrkId {get{
      Set<String> mySet = new Set<String>();
      Set<String> actorSet = new Set<String>();
      String tempActorId;
      String currUserId = UserInfo.getUserId();

      Map<String,String> appMap = new Map<String,String>();

        List<ProcessInstanceWorkitem> appName = [SELECT ActorId,Actor.Name,Id,OriginalActor.Name,OriginalActorId,ProcessInstanceId
                                        FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =:prf.Id];

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
      List<GroupMember> groupInfo= new List<GroupMember>();
      String uName = UserInfo.getName();
      String uRoleId = UserInfo.getUserRoleId();
      String currUserId = UserInfo.getUserId();
      List<ProcessInstanceWorkitem> appName = [SELECT ActorId,Actor.Name,Id,OriginalActor.Name,OriginalActorId,ProcessInstanceId
                                        FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =:prf.Id];
      
      if(appName!=null && appName.size()>0){  
          for(ProcessInstanceWorkitem curr: appName){
            myset.add(curr.Actor.Name);
          }
      }
      
      if(mySet.size()>0){
          groupInfo = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember WHERE Group.Name IN :mySet];
      }
      
      if(groupInfo.size()>0){
          for(GroupMember curr: groupInfo){
            actorSet.add(curr.UserOrGroupId);
          }
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

    public String mySalesOrg {get{
        Contract_User__c cc = [SELECT User_Administration__c, View_Margin__c, Active_Region__c
                               FROM Contract_User__c
                               WHERE User__c = :UserInfo.getUserId()
                               LIMIT 1];

        mySalesOrg = cc.Active_Region__c.left(2);

        return mySalesOrg;
    }
                              set;}

    public PRF__c prf2 {get{
        return [SELECT Material_Status_Check__c, Approval_Level__c, Pricing_Tier_Level__c, Business_Unit__c, InApproval__c,
                Price_Tier_Status__c, OwnerId, Owner_Approval_Role__c, Workflow_Owner_Approval_Level__c,
                Status__c, PRF_Promotion_related__c
                FROM PRF__c
                WHERE id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];
    }set;}

    private PRF__c prf{get;set;}
    public List<PRF_Line_Item__c> PLI;
    private list<Territory_User__c> tulist;
    private Territory_User__c tu;
    public string salesCurrency {get; set;}
    public string salesOrgKey {get; set;}
    public boolean isLocked {get; set;}
    public string activeSalesOrgKey {get;set;}
    public string prfType {get;set;}
    //public boolean InApproval {get; set;}

    //PRF Approval Layout Stuff
    //public Integer convUnit = 1000;
    public Map<Id,Decimal> margins {get;set;}
    public Map<Id,String> priceCheck {get;set;}
    public Map<Id,Decimal> minContract {get;set;}
    public Map<Id,Decimal> minGpo {get;set;}
    public Map<Id,String> minContractAgree {get;set;}
    public Map<Id,String> minGpoAgree {get;set;}
    //end of PRF Approval Layout Stuff

    //Approval Process Stuff
    public String processId;
    public ProcessInstance objProcessInstance;
    public String appComments {get;set;}
    public List<ProcessInstanceWorkitem> approvalInfo;
    //end Approval Process Stuff

    //start of getter setters to handle User bu change
    public String buValue {get;set;}
    public String userId {get;set;}
    public String currentBu {get;set;}
    //get owner's current bu setting on user record
    public String userBu {get{
        List<User> myUserBu = [Select Id, Business_Unit__c FROM User
                                       WHERE id =:UserInfo.getUserId() LIMIT 1];

         if(myUserBu.size() > 0 ){
            userBu = myUserBu[0].Business_Unit__c;
            System.debug('*** userBu setter *** ' + userBu);
         }
         return userBu;
    }set;}

    public String userBuAsk {get{
        List<User> myUserBuAsk = [Select Id, Business_Unit__c FROM User
                                       WHERE id =:UserInfo.getUserId() LIMIT 1];

         if(myUserBuAsk.size() > 0 ){
            userBuAsk = myUserBuAsk[0].Business_Unit__c;

         }
         return userBuAsk;
    }set;}
    //end of getter setters to handle User bu change

    public Boolean subButton {get{
        List<PRF__c> prfLines = [Select Line_Count__c FROM PRF__c
                                WHERE id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];
        if(prfLines[0].Line_Count__c > 0 ){
            return true;
        }else{
            return false;
        }

    }set;}

    //pricing formatting by locale
    public String userLocale {get;set;}
    public Map<Id,String> formatListPrices {get;set;}
    public Map<Id,String> formatRsmPrices {get;set;}
    public Map<Id,String> formatRepPrices {get;set;}
    public Map<Id,String> formatEligiblePrices {get;set;}
    public Map<Id,String> formatRequestedPrices {get;set;}

    //
    /**************************************** START Pricing Tier Matrix *******************************************************/
    // Start New Pricing Tier Stuff
    public list<String> tierHeaderList {get; set;} // Used to store the final list of pricing levels in order: REP1, REP2, RSM1, etc.
    public set<String> tierHeaderNames {get; set;} // Stores the major header names: REP, RSM, DIR
    //public list<String> tierHeaderListName {get; set;}
    public map<String, PP_Pricing_Tiers.tiers> tierMap {get; set;}
    public map<String, Integer> tierLevels {get; set;} // Used to store how many levels REP, RSM, DIR go in order to span columns appropriately
    public map<String, list<String>> tierChange {get; set;}
    public integer thSpan {get; set;}
    public integer pricingTierLevelPlus1 {get; set;}
    public boolean requestPlusOne {get; set;} // Determines whether to show the 'Request Tier' approval button - Has to be the owner with a material that has contracts one tier level higher
    map<String, list<Prf_Line_Item__c>> prfliMap = new map<String, list<Prf_Line_Item__c>>();

    // 22Jul2018 - ESC - Adding Approval Required, Reasons, and Level
    public string approval_reasons {get; set;} // String that shows Approval Reasons
    set<String> apReasons = new set<String>(); // Set to Capture the Approval Reasons

    //method used to show/hide RSM/Rep pricing
    public Boolean priceToggle {get;set;} //used to show Standard RSM/Rep pricing with tiered pricing
    
   
    public PageReference setPriceToggle(){
        if(priceToggle == false || priceToggle == NULL){
            priceToggle = true;
            Prf__c priceToggle = new Prf__c(Id=prf.Id);
            priceToggle.RsmRepToggle__c = true;
            update priceToggle;
        }
        else{
            priceToggle = false;
            Prf__c priceToggle = new Prf__c(Id=prf.Id);
            priceToggle.RsmRepToggle__c = false;
            update priceToggle;
        }

        return null;
    }

    // Method Used to Request One Level Higher Pricing Access
    public PageReference requestHigherTierAccess(){

        Prf__c priceToggle = new Prf__c(
            Id = prf.Id,
            Price_Tier_Status__c = 'Requested'
        );
        update priceToggle;

        // Submits the record for Approval
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(prf.id);
        Approval.ProcessResult result = Approval.process(req1);

        return NULL;
    }
    
    
    public boolean getCheckInit(){
        initCube();
        return TRUE;
    }

    public void initCube() {

        if(tierMap.isEmpty()){
            system.debug('Check TierMap: ' + tierMap);
        }
        else{
            system.debug('TierMap is EMPTY!');
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

        apReasons.clear(); // Make sure only the current values are in the set
        for(Prf_Line_Item__c prfli : [Select Id, Material_Name__c, Requested_Pricing__r.Parent_Contract_Name__c,
                                     Sales_Deal__r.Parent_Contract_Name__c, Sales_Deal__r.Pricing_Tier__c,
                                     Material_Name_Text__c, Sales_Deal__r.Agreement_Number__c, Approval_Flag_Reason__c
                                     FROM Prf_Line_Item__c
                                     WHERE Prf__c = :ApexPages.currentPage().getParameters().get('id')])
        {
            pids.add(prfli.Material_Name__c);
            if(prfliMap.containsKey(prfli.Material_Name_Text__c)){
                prfliMap.get(prfli.Material_Name_Text__c).add(prfli);
            }
            else{
                prfliMap.put(prfli.Material_Name_Text__c, new list<Prf_Line_Item__c>{prfli});
            }
            if(prfli.Approval_Flag_Reason__c != 'Ready'){
                apReasons.add(prfli.Approval_Flag_Reason__c);
            }
        }
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
        
        if(pids.size()>0){
            for(Product2 p : [SELECT Id, Name FROM Product2 WHERE Id = :pids]){
                plist.add(p);
            }
        }
        // Active User Level
        system.debug('prf: ' + prf);
        Integer pricingTierLevel = 1;

        if(prf2.Pricing_Tier_Level__c != NULL && UserInfo.getUserId() == prf2.OwnerId){
            pricingTierLevel = integer.valueOf(prf2.Pricing_Tier_Level__c);
        }
        else{
            for(Contract_User__c cu : [SELECT Pricing_Tier_Access__c, User__r.Name,
                                       User_Administration__c, View_Margin__c
                                       FROM Contract_User__c
                                       WHERE User__c = :UserInfo.getUserId()
                                       LIMIT 1])
            {
                system.debug('Setting Pricing Tier [' + cu.User__r.Name + '] - Access/Level: ' + cu.Pricing_Tier_Access__c);

                if(integer.valueOf(cu.Pricing_Tier_Access__c) != NULL){
                    pricingTierLevel = integer.valueOf(cu.Pricing_Tier_Access__c);
                }
                else{
                    pricingTierLevel = 1;
                }

            }

        }

        //Build the Cube
        PP_Pricing_Tiers newPT = new PP_Pricing_Tiers();
        tierMap =  newPT.getTiers(plist,pricingTierLevel); // Builds the map using a list of products
        tierHeaderList = newPT.getTierHeaderLevels(tierMap); // REP1, REP2, RSM1, etc.
        system.debug('tierMap: ' + tierMap);

        if(tierHeaderList.size() > 0){
            thSpan = tierHeaderList.size();
        }
        else{
            thSpan = 0;
        }

        set<String> pchSet = new set<String>();
        if(tierMap!=null && tierMap.size()>0){
            for(PP_Pricing_Tiers.tiers pt : tierMap.values()){
                pchSet.add(pt.chKey); // Add the Key
                if(tierChange.containsKey(pt.chKey)){
                    tierChange.get(pt.chKey).add(pt.Product_Name);
                }
                else{
                    tierChange.put(pt.chKey, new list<String>{pt.Product_Name});
                }
            }
        }

        // Determines whether to show the 'Request Tier' approval button
        // Has to be the owner with a material that has contracts one tier level higher
        if(pricingTierLevel < 4){ // No Need to run this for Level 4 users
            pricingTierLevelPlus1 = pricingTierLevel + 1;
            if(UserInfo.getUserId() == prf2.OwnerId &&
               pchSet.size() > 0 &&
               prf2.Price_Tier_Status__c != 'Approved' &&
               prf2.Price_Tier_Status__c != 'Requested'
              ){
                  integer ptCount = 0;
                  ptCount = [SELECT count() FROM Contract_Header__c WHERE Pricing_Tier__c = TRUE
                             AND Parent_Contract_Name__c = :pchSet AND Pricing_Tier_Access__c = :pricingTierLevelPlus1];
                  system.debug('ptCount: ' + ptCount + ' and Plus1: ' + pricingTierLevelPlus1);
                  if(ptCount > 0){
                      requestPlusOne = TRUE;
                  }
              }
        }

        // Build REP/RSM/DIR Set and Column Span Map
        if(tierHeaderList.size()>0){
            for(String s : tierHeaderList){
                string tName = s.left(3);// REP, RSM, DIR
                tierHeaderNames.add(tName);
                system.debug('tierHeaderList Loop: ' + s);
                // Build Map that controls column span. REP = 3, RSM = 3, etc.
                if(tierLevels.containsKey(tName)){
                    tierLevels.put(tName, 1+tierLevels.get(tName));
                }
                else{
                    tierLevels.put(tName, 1);
                }
            }
        }
        system.debug('tierHeaderList: ' + tierHeaderList + ' - ' + 'tierHeaderNames: ' + tierHeaderNames);

    }

    public PageReference massUpdateTiers(){
      System.debug('*** Starting massUpdateTiers ***');
        String tierLevel = Apexpages.currentpage().getParameters().get('tierLevel'); // REP1, REP2, RSM1
        string key;
        list<Prf_Line_Item__c> updateLines = new list<Prf_Line_Item__c>();

        for(Prf_Line_Item__c prfli : [Select Id, Material_Name_Text__c, Sales_Deal__r.Agreement_Number__c
                                     FROM Prf_Line_Item__c
                                     WHERE Prf__c = :ApexPages.currentPage().getParameters().get('id')])
        {
            key = tierLevel + '-' + prfli.Material_Name_Text__c;
            if(tierMap.containsKey(key) && tierMap.get(key).chId != NULL){
                Prf_Line_Item__c myPrfli = new Prf_Line_Item__c(
                    id = prfli.Id,
                    Requested_Price__c = tierMap.get(key).Price,
                    Requested_Pricing__c = tierMap.get(key).chId,
                    Requested_Pricing_CM__c = tierMap.get(key).cmId,
                    Requested_Price_PT__c = tierMap.get(key).Price
                );
                updateLines.add(myPrfli);
            }
        }
        if(updateLines.size() > 0){
            update updateLines;
        }

        System.debug('*** Ending massUpdateTiers ***');
        return new Pagereference('/apex/PP_PRF?id='+ApexPages.currentPage().getParameters().get('id')).setRedirect(True);
    }

    public PageReference updateTierPrice(){
        /* New Try -- Ignore for now */
        System.debug('*** Starting updateTierPrice in PP_PRF ***');
        String tierPrice = Apexpages.currentpage().getParameters().get('tierPrice');
        Id lineId = Apexpages.currentpage().getParameters().get('lineId');
        String key =  Apexpages.currentpage().getParameters().get('key');
        System.debug('*** tierPrice *** ' + tierPrice);
        System.debug('*** lineId *** ' + lineId);
        System.debug('*** key *** ' + key);
        System.debug('***** tiermap****** '+tierMap);
        System.debug('*** tierMap.get(key).Price *** ' + tierMap.get(key).Price);
        list<Prf_Line_Item__c> updateLines = new list<Prf_Line_Item__c>();
        Prf_Line_Item__c myPrfli = new Prf_Line_Item__c();

        myPrfli = new Prf_Line_Item__c(
            id = lineId,
            Requested_Price__c = tierMap.get(key).Price
        );
        string lineDesc;
        if(key == 'List' || key == 'Eligible'){
            lineDesc = key;
            myPrfli.Requested_Pricing__c = NULL;
            myPrfli.Requested_Pricing_CM__c = NULL;
            myPrfli.Requested_Price_PT__c = 0;
        }
        else{
            lineDesc = tierMap.get(key).chDesc;
            myPrfli.Requested_Pricing__c = tierMap.get(key).chId;
            myPrfli.Requested_Pricing_CM__c = tierMap.get(key).cmId;
            myPrfli.Requested_Price_PT__c = tierMap.get(key).Price;
        }
        updateLines.add(myPrfli);
        system.debug('*** key check *** ' + key);

        boolean tierUnlocked = FALSE;
        for(Business_Unit__c bu : Business_Unit__c.getall().values()){
            if(userBu == bu.Name && bu.Pricing_Tiers_Unlocked__c == TRUE){
                tierUnlocked = TRUE;
            }
        }
        system.debug('*** tierUnlocked *** ' + tierUnlocked);

        string subkey;
        if(key != NULL &&
           tierChange.containsKey(tierMap.get(key).chkey) &&
           tierUnlocked == FALSE
          ){
            system.debug('chKey: ' + tierMap.get(key).chkey);
            for(String s : tierChange.get(tierMap.get(key).chkey)){
                subkey = tierMap.get(key).TierName + '-' + s;
                if(prfliMap.containsKey(s)){
                    for(Prf_Line_Item__c prfli : prfliMap.get(s)){
                        if(prfli.Id == lineId){
                            myPrfli = new Prf_Line_Item__c(
                                id = prfli.Id,
                                Requested_Price__c = tierMap.get(subkey).Price,
                                Requested_Pricing__c = tierMap.get(subkey).chId,
                                Requested_Pricing_CM__c = tierMap.get(subkey).cmId,
                                Requested_Price_PT__c = tierMap.get(subkey).Price
                            );
                            if(!updateLines.contains(myPrfli)){
                                updateLines.add(myPrfli);
                            }

                        } // Id Check
                    } // END pqli map for loop
                } // End Map Check
            } // List of Materials related to the Parent Contract Name
        }

        System.debug('*** updateLines *** ' + updateLines);

        try{
            if(updateLines.size() > 0){
                update updateLines;
            }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        //return null;
        System.debug('*** Ending updateTierPrice in PP_PRF ***');
        return new Pagereference('/apex/PP_PRF?id='+ApexPages.currentPage().getParameters().get('id')).setRedirect(True);

    }//end of updateTierPrice

    //mass update List Price
    public PageReference massUpdList(){
        try{
            List<Prf_Line_Item__c> updItems = new List<Prf_Line_Item__c>();

            /*for(Prf_Line_Item__c curr : [SELECT id, List_Price__c, Requested_Price__c, Requested_Pricing__c,
                                         Requested_Pricing_CM__c, Requested_Price_PT__c
                                         FROM Prf_Line_Item__c Where Prf__c=: prf.Id
                                         AND Material_Name__c != NULL])*/
            for(Prf_Line_Item__c curr :currList)                             
            {
                curr.Requested_Price__c = curr.List_Price__c;
                curr.Requested_Pricing__c = NULL;
                curr.Requested_Pricing_CM__c = NULL;
                curr.Requested_Price_PT__c = 0;
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

    //mass update Rsm Price
    public PageReference massUpdRsm(){
        try{
            List<Prf_Line_Item__c> updItems = new List<Prf_Line_Item__c>();

            /*for(Prf_Line_Item__c curr : [SELECT id, Rsm_Price__c, Requested_Price__c, Requested_Pricing__c,
                                         Requested_Pricing_CM__c, Requested_Price_PT__c
                                         FROM Prf_Line_Item__c Where Prf__c=: prf.Id
                                         AND Material_Name__c != NULL])*/
            for(Prf_Line_Item__c curr :currList)
            {
                curr.Requested_Price__c = curr.Rsm_Price__c;
                curr.Requested_Pricing__c = NULL;
                curr.Requested_Pricing_CM__c = NULL;
                curr.Requested_Price_PT__c = 0;
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
    }//end of massUpdRsm

    //mass update Rep Price
    public PageReference massUpdRep(){
        try{
            List<Prf_Line_Item__c> updItems = new List<Prf_Line_Item__c>();

            /*for(Prf_Line_Item__c curr : [SELECT id, Rep_Price__c, Requested_Price__c, Requested_Pricing__c,
                                         Requested_Pricing_CM__c, Requested_Price_PT__c
                                         FROM Prf_Line_Item__c Where Prf__c=: prf.Id
                                         AND Material_Name__c != NULL])*/
            for(Prf_Line_Item__c curr :currList)
            {
                curr.Requested_Price__c = curr.Rep_Price__c;
                curr.Requested_Pricing__c = NULL;
                curr.Requested_Pricing_CM__c = NULL;
                curr.Requested_Price_PT__c = 0;
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
    }//end of massUpdRep

    //mass update Eligible Price
    public PageReference massUpdEligible(){
        try{
            List<Prf_Line_Item__c> updItems = new List<Prf_Line_Item__c>();

            /*for(Prf_Line_Item__c curr : [SELECT id, Eligible_Price__c, Requested_Price__c, Requested_Pricing__c,
                                         Requested_Pricing_CM__c, Requested_Price_PT__c
                                         FROM Prf_Line_Item__c Where Prf__c=: prf.Id
                                         AND Material_Name__c != NULL])*/
            for(Prf_Line_Item__c curr :currList)
            {
                curr.Requested_Price__c = curr.Eligible_Price__c;
                curr.Requested_Pricing__c = NULL;
                curr.Requested_Pricing_CM__c = NULL;
                curr.Requested_Price_PT__c = 0;
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
    }//end of massUpdEligible

    //single line List price update
    public PageReference updateListprice(){
        try{
            String listPrice = Apexpages.currentpage().getParameters().get('listPrice');
            String lineId = Apexpages.currentpage().getParameters().get('lineId');
            system.debug('listPrice ====================== ' + listPrice);
            system.debug('lineId ====================== ' + lineId);
            Decimal myListPrice;
            myListPrice = decimal.valueOf(listPrice);

            Prf_Line_Item__c myprfl = new Prf_Line_Item__c(
                id = lineId,
                Requested_Price__c = myListPrice,
                Requested_Pricing__c = NULL,
                Requested_Pricing_CM__c = NULL,
                Requested_Price_PT__c = 0
            );

            update myprfl;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return null;
    }//end updateListPrice

    //single line RSM price update
    public PageReference updateRSMprice(){
        try{
            String rsmPrice = Apexpages.currentpage().getParameters().get('rsmPrice');
            String lineId = Apexpages.currentpage().getParameters().get('lineId');
            system.debug('rsmPrice ====================== ' + rsmPrice);
            system.debug('lineId ====================== ' + lineId);
            Decimal myrsmPrice;
            myrsmPrice = decimal.valueOf(rsmPrice);

            Prf_Line_Item__c myprfl = new Prf_Line_Item__c(
                id = lineId,
                Requested_Price__c = myRSMPrice,
                Requested_Pricing__c = NULL,
                Requested_Pricing_CM__c = NULL,
                Requested_Price_PT__c = 0
            );

            update myprfl;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return null;
    }//end updateRsmPrice

    //single line Rep price update
    public PageReference updateRepPrice(){
        try{
            String repPrice = Apexpages.currentpage().getParameters().get('repPrice');
            String lineId = Apexpages.currentpage().getParameters().get('lineId');
            system.debug('repPrice ====================== ' + repPrice);
            system.debug('lineId ====================== ' + lineId);
            Decimal myrepPrice;
            myrepPrice = decimal.valueOf(repPrice);

            Prf_Line_Item__c myprfl = new Prf_Line_Item__c(
                id = lineId,
                Requested_Price__c = myRepPrice,
                Requested_Pricing__c = NULL,
                Requested_Pricing_CM__c = NULL,
                Requested_Price_PT__c = 0
            );

            update myprfl;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return null;
    }//end updateRepPrice

    //single line Eligible Price update
    public PageReference updateEligiblePrice(){
        try{
            String eligiblePrice = Apexpages.currentpage().getParameters().get('eligiblePrice');
            String lineId = Apexpages.currentpage().getParameters().get('lineId');

            Decimal myEligiblePrice = decimal.valueOf(eligiblePrice);

            PRF_Line_Item__c prfLI = new PRF_Line_Item__c(
                id = lineId,
                Requested_Price__c  = myEligiblePrice,
                Requested_Pricing__c = NULL,
                Requested_Pricing_CM__c = NULL,
                Requested_Price_PT__c = 0
            );

            update prfLI;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return NULL;
    }

    /**************************************** END Pricing Tier Matrix *******************************************************/


    public PP_PRF(){
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
      formatRequestedPrices = new Map<Id,String>();
      soMap= new Map<String, Sales_Orgs__c>();
      currList= new List<Prf_Line_Item__c>();
      //prf2 = new PRF__c();
      activeSalesOrgKey = ApexPages.currentPage().getParameters().get('salesOrgKey');
      prfType = ApexPages.currentPage().getParameters().get('type');
      System.debug('*** userLocale *** ' + userLocale);

        /**************************************** START POC Stuff *******************************************************/
        // Public collections //
        tierMap = new map<String, PP_Pricing_Tiers.tiers>(); // Major map used to store the pricing matrix
        tierLevels = new map<String, Integer>(); // Used to store how many levels REP, RSM, DIR go in order to span columns appropriately
        tierHeaderList = new list<String>(); // Used to store the final list of pricing levels in order: REP1, REP2, RSM1, etc.
        tierHeaderNames = new set<String>(); // Stores the major header names: REP, RSM, DIR
        tierChange = new map<String, list<String>>();
        /**************************************** END START UP POC Stuff *******************************************************/
        
        List<Sales_Orgs__c> soList= [SELECT Id,Name, Sales_Org__c, Distribution_Channel__c, Pricing_Type__c FROM Sales_Orgs__c WHERE Active__c = true];
        if(soList.size() > 0){
            for(Sales_Orgs__c curr : soList){
                soMap.put(curr.Name,curr);
            }//end for loop
        }
        
        /*prf2= [SELECT Material_Status_Check__c, Approval_Level__c, Pricing_Tier_Level__c, Business_Unit__c, InApproval__c,
                Price_Tier_Status__c, OwnerId, Owner_Approval_Role__c, Workflow_Owner_Approval_Level__c,
                Status__c, PRF_Promotion_related__c
                FROM PRF__c
                WHERE id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];*/
                
        
        currList= [SELECT id, List_Price__c, Rsm_Price__c, Rep_Price__c, Eligible_Price__c, Requested_Price__c, Requested_Pricing__c,
                                         Requested_Pricing_CM__c, Requested_Price_PT__c
                                         FROM Prf_Line_Item__c Where Prf__c=: ApexPages.currentPage().getParameters().get('id')
                                         AND Material_Name__c != NULL];
                
        prf = new PRF__c();
        if(prfid != NULL){
            prf = [SELECT Id, Name, Data_Driven_Justification__c, Owner_Full_Name__c, Agreement_Type__c, Eligible_Distributor__c,GPO_Affiliation__c,
                   Current_Annual_Purchases__c, Estimated_Annual_Purchases__c, Preferred_Start_Date__c, Preferred_End_Date__c, Requisition_Date__c,
                   PRF_Name__c, Owner_Business_Unit__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,Sales_Deal__c,Valid_To__c,
                   Account__r.Id, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry,CurrencyIsoCode,Valid_From__c,
                   Account__r.SAP_Sold_To__c, Contact__r.Id, Contact__r.name, Contact__r.email, Territory__c, Territory__r.Territory_Number__c,
                   Territory__r.Territory_Name__c,Status__c, Additional_Accounts__c,Sales_Org_Key__c, LastModifiedById, LastModifiedDate, Owner_ID__c,
                   CreatedById, CreatedDate, Price_Quote__c, Price_Quote__r.Name, Price_Quote__r.Price_Quote_Name__c, Line_Count__c, Owner_Email__c,
                   Audit_Check__c, Owner_Approval_Role__c, Owner_Approval_Level__c, Approval_Level__c, Workflow_Owner_Approval_Level__c, Account__r.Account_Group__c,
                   Product_Class_Count__c, Account__r.Price_List_Type__c, Current_Approver__c, Total_Annual_Eaches__c, Approval_Flag_Rollup__c, RsmRepToggle__c,
                   OwnerId, Owner.Name, Business_Unit__c, InApproval__c, Category__c, PRF_Promotion_related__c
                   FROM PRF__c
                   WHERE id = :ApexPages.currentPage().getParameters().get('id')
                   LIMIT 1];

                   if(prf.GPO_Affiliation__c != NULL && prf.GPO_Affiliation__c != ''){
                     selectedGPO = prf.GPO_Affiliation__c;
                     selectedValue = selectedGPO;
                     system.debug('selectedValue = ' + selectedValue + ' selectedGPO = ' + selectedGPO);
                   }
                   else{
                     selectedGPO = '';
                     selectedValue = '';
                   }

                   // Logic to determine whether the record is locked or not.
                   isLocked = FALSE;
                   for(ProcessInstance pi : [SELECT Status
                                             FROM ProcessInstance
                                             WHERE TargetObjectId =: prf.Id
                                             order by CreatedDate DESC LIMIT 1])
                   {
                     if(pi.Status != 'Rejected'){
                       isLocked = TRUE;
                       //system.debug('pi.Status: ' + pi.Status);
                     }
                   }

                   priceToggle = prf.RsmRepToggle__c;
        }//end of prfid != NULL
        processId = ApexPages.currentPage().getParameters().get('id');
    }//end of constructor

    //used to udpate Owner of Prf
    public Pagereference doUpdateOwnerValue() {
        //hasError = false;
        system.debug('**** Owner.Name ****'+prf.Owner.Name);

        try{
          String prfid = Apexpages.currentpage().getParameters().get('id');
          update prf;
          return new Pagereference('/apex/PP_Prf?id='+prfid).setRedirect(True);
        }
        catch(Exception e){
          //hasError = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please choose a valid owner!'));
          return null;
        }

    }

    public PRF__c getprf(){
        return prf;
    }

    public PageReference save() {
      System.debug('*** prf.InApproval__c *** ' + prf.InApproval__c);
      hasAskItems = false;
      String quoteId = NULL;
      Price_Quote__c checkStatus = new Price_Quote__c();
      String prfId = ApexPages.currentPage().getParameters().get('id');
      Boolean inApproval;
      activeSalesOrgKey = ApexPages.currentPage().getParameters().get('salesOrgKey');
        
        if(prfId != NULL){
            inApproval = [SELECT Id, InApproval__c FROM PRF__c WHERE Id =:ApexPages.currentPage().getParameters().get('id')].InApproval__c; 
        }
        else{
            InApproval = FALSE;
        }
      

      System.debug('*** inApproval *** ' + inApproval);
        
        if(ApexPages.currentPage().getParameters().get('pqid') != NULL){
        quoteId = ApexPages.currentPage().getParameters().get('pqid');
        checkStatus = [SELECT Id, Status__c, Product_Class_Count__c, Sales_Org_Key__c, Pricing_Tier_Level__c, Price_Tier_Status__c, InApproval__c
                      FROM Price_Quote__c
                      WHERE Id =:quoteId];
        }

        if(ApexPages.currentPage().getParameters().get('aid') != NULL){
            System.debug('*** PRF is not in the Approval Process in AID ***');
            string salesCurrency;
            string salesOrgKey;
            Decimal tierLevel = NULL;
            string tierStatus = NULL;
            string thisType = prfType;

            for(Contract_User__c cu : [SELECT Active_Currency__c, Active_Sales_Org_Key__c
                                       FROM Contract_User__c
                                       WHERE User__c = :UserInfo.getUserId()
                                       LIMIT 1])
            {
                salesCurrency = cu.Active_Currency__c;
                salesOrgKey = cu.Active_Sales_Org_Key__c;
            }

            if(ApexPages.currentPage().getParameters().get('pqid') != NULL){
              salesOrgKey = checkStatus.Sales_Org_Key__c;
              tierLevel = checkStatus.Pricing_Tier_Level__c;
              tierStatus = checkStatus.Price_Tier_Status__c;
            }

            system.debug('prf.Account__c ***** ' + prf.Account__c);
            //process handles PRF from scratch
            
            prf = new PRF__c(
                Requisition_Date__c = date.today(),
                Account__c = ApexPages.currentPage().getParameters().get('aid'),
                Contact__c = ApexPages.currentPage().getParameters().get('cid'),
                CurrencyIsoCode = salesCurrency,
                Sales_Org_Key__c = salesOrgKey,
                Agreement_Type__c = prf.Agreement_Type__c,
                Additional_Accounts__c = prf.Additional_Accounts__c,
                Eligible_Distributor__c = prf.Eligible_Distributor__c,
                Current_Annual_Purchases__c = prf.Current_Annual_Purchases__c,
                Estimated_Annual_Purchases__c = prf.Estimated_Annual_Purchases__c,
                Preferred_Start_Date__c = prf.Preferred_Start_Date__c,
                Preferred_End_Date__c = prf.Preferred_End_Date__c,
                Sales_Deal__c = prf.Sales_Deal__c,
                Valid_From__c = prf.Valid_From__c,
                Valid_To__c = prf.Valid_To__c,
                Category__c = prf.Category__c,
                GPO_Affiliation__c = selectedGPO,
                Data_Driven_Justification__c = prf.Data_Driven_Justification__c,
                Product_Class_Count__c = checkStatus.Product_Class_Count__c,
                Total_Annual_Eaches__c = prf.Total_Annual_Eaches__c,
                Pricing_Tier_Level__c = tierLevel,
                Price_Tier_Status__c = tierStatus
            );

            //logic for ASK Agreement
            if(prfType == 'ASK Agreement'){
                prf.Agreement_Type__c = prfType;
            }
            //end logic for ASK Agreement
            
            try{
                string uterritoryid = [SELECT Territory_Master__r.Id
                                       FROM Territory_User__c
                                       WHERE User__r.Id = :UserInfo.getUserId()
                                       LIMIT 1].Territory_Master__r.Id;
                if(uterritoryid != NULL){
                    prf.Territory__c = uterritoryid;
                }
            }
            catch(Exception e){
                system.debug('uterritoryid exception: ' + e);
            }


            if(quoteId != NULL){
              prf.Price_Quote__c = quoteId;

            }

            //check userBu and assign to Business Unit
            if(inApproval != TRUE){
                System.debug('*** PRF is not in the Approval Process in AID InApproval Check ***');
                if(userBu == 'Commercial Operations'){
                System.debug('*** userBu if *** ' + userBu);
                userBu = 'Vascular';
                prf.Business_Unit__c = 'Vascular';
                }
                else{
                    System.debug('*** userBu else *** ' + userBu);
                    prf.Business_Unit__c = userBu;
                }//end userbu check 
            }//end if for Approval check 

            system.debug('newPRF Inserted: ' + prf);
            insert prf;

            system.debug('*** quoteId *** ' + quoteId);
            system.debug('*** checkStatus.Status__c *** ' + checkStatus.Status__c);
            //logic to grab Price Quote Line Items
            if(quoteId != NULL && checkStatus.Status__c == 'Approved'){
              System.debug('*** Getting Price Quote Line Item Data If (checkStatus == Approved) ***');
              //string newPRFid;
              list<PRF__c> insertPRF = new list<PRF__c>();
              list<PRF_Line_Item__c> insertPRFLI = new list<PRF_Line_Item__c>();
              for(Price_Quote_Line_Item__c  pqli : [SELECT Id, Rep_Price__c, RSM_Price__c, Eligible_Price__c,Sales_Price__c, Director_Price__c, Floor_Price__c,
                                                    Sales_Deal__c, Material_Name__c, List_Price__c, Price_Quote__c,Objective__c, Material_Status__c, Cost__c, Price_Quote__r.Business_Unit__c,
                                                    CurrencyIsoCode, Condition__c, Sales_Number__c, Sales_Deal_Description__c, Product_Description__c,Material_Status_Description__c,
                                                    Sales_Deal__r.Agreement_Number__c, Material_Name_Text__c, Requested_Pricing__c, Requested_Pricing_CM__c, Requested_Price__c
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c = :quoteId
                                                    ORDER BY Row_Order__c NULLS LAST])
              {
                  PRF_Line_Item__c addPRFli = new PRF_Line_Item__c(
                      PRF__c = prf.Id,
                      PQLI_ID__c = pqli.Id,
                      CurrencyIsoCode = pqli.CurrencyIsoCode,
                      List_Price__c = pqli.List_Price__c,
                      Rep_Price__c = pqli.Rep_Price__c,
                      RSM_Price__c = pqli.RSM_Price__c,
                      Requested_Price__c = pqli.Sales_Price__c,
                      Eligible_Price__c = pqli.Eligible_Price__c,
                      Director_Price__c = pqli.Director_Price__c,
                      Floor_Price__c = pqli.Floor_Price__c,
                      Cost__c = pqli.Cost__c,
                      Sales_Deal__c = pqli.Sales_Deal__c,
                      Material_Name__c = pqli.Material_Name__c,
                      Product_Description__c = pqli.Product_Description__c,
                      Sales_Deal_Num__c = pqli.Sales_Number__c,
                      Sales_Deal_Description__c = pqli.Sales_Deal_Description__c,
                      Condition__c = pqli.Condition__c,
                      Objective__c = pqli.Objective__c,
                      Material_Status__c = pqli.Material_Status__c,
                      Requested_Pricing__c = pqli.Requested_Pricing__c,
                      Requested_Pricing_CM__c = pqli.Requested_Pricing_CM__c,
                      Requested_Price_PT__c = pqli.Requested_Price__c
                  );
                  system.debug('addPRFli: ' + addPRFli);
                  insertPRFLI.add(addPRFli);
              }//end of for loop


              if(insertPRFLI.size() > 0){
                  insert insertPRFLI;
              }
            }//end of if
            else{
              System.debug('*** Getting Price Quote Line Item Data Else ***');
              //string newPRFid;
              list<PRF__c> insertPRF = new list<PRF__c>();
              list<PRF_Line_Item__c> insertPRFLI = new list<PRF_Line_Item__c>();
              for(Price_Quote_Line_Item__c  pqli : [SELECT Id, Rep_Price__c, RSM_Price__c, Eligible_Price__c,Sales_Price__c, Product_Description__c, Price_Quote__r.Business_Unit__c,
                                                    Sales_Deal__c, Material_Name__c, List_Price__c, Price_Quote__c,Objective__c,Director_Price__c,Floor_Price__c,
                                                    CurrencyIsoCode, Condition__c, Sales_Number__c, Sales_Deal_Description__c,Material_Status__c, Cost__c,
                                                    Material_Status_Description__c, Requested_Pricing__c, Requested_Pricing_CM__c, Requested_Price__c
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c = :quoteId
                                                    AND Approval_Flag_Checkbox__c = true
                                                    ORDER BY Row_Order__c NULLS LAST])
              {
                  PRF_Line_Item__c addPRFli = new PRF_Line_Item__c(
                      PRF__c = prf.Id,
                      PQLI_ID__c = pqli.Id,
                      CurrencyIsoCode = pqli.CurrencyIsoCode,
                      List_Price__c = pqli.List_Price__c,
                      Rep_Price__c = pqli.Rep_Price__c,
                      RSM_Price__c = pqli.RSM_Price__c,
                      Requested_Price__c = pqli.Sales_Price__c,
                      Eligible_Price__c = pqli.Eligible_Price__c,
                      Director_Price__c = pqli.Director_Price__c,
                      Floor_Price__c = pqli.Floor_Price__c,
                      Cost__c = pqli.Cost__c,
                      Sales_Deal__c = pqli.Sales_Deal__c,
                      Material_Name__c = pqli.Material_Name__c,
                      Product_Description__c = pqli.Product_Description__c,
                      Sales_Deal_Num__c = pqli.Sales_Number__c,
                      Sales_Deal_Description__c = pqli.Sales_Deal_Description__c,
                      Condition__c = pqli.Condition__c,
                      Objective__c = pqli.Objective__c,
                      Material_Status__c = pqli.Material_Status__c,
                      Requested_Pricing__c = pqli.Requested_Pricing__c,
                      Requested_Pricing_CM__c = pqli.Requested_Pricing_CM__c,
                      Requested_Price_PT__c = pqli.Requested_Price__c
                  );
                  system.debug('addPRFli: ' + addPRFli);
                  insertPRFLI.add(addPRFli);
              }//end of for loop
                System.debug('*** insertPRFLI.size() *** ' + insertPRFLI.size() );
              if(insertPRFLI.size()>0 ){
                insert insertPRFLI;
              }

              if(quoteId != NULL ){
                Price_Quote__c updStatus = new Price_Quote__c(Id = quoteId, Status__c = 'PRF In Process');
                update updStatus;
              }

            }
        } //end of if (ApexPages.currentPage().getParameters().get('aid') != NULL)
        else{
          system.debug('selectedGPO ***** ' + selectedGPO);
          //system.debug('selectedValue ***** ' + selectedValue);
          if(ApexPages.currentPage().getParameters().get('pqid') != NULL){
            salesOrgKey = checkStatus.Sales_Org_Key__c;
          }

          prf = new PRF__c(
              Id = ApexPages.currentPage().getParameters().get('id'),
              //Requisition_Date__c = date.today(),
              Account__c = prf.Account__c,
              Contact__c = prf.Contact__c,
              //CurrencyIsoCode = salesCurrency,
              //Sales_Org_Key__c = salesOrgKey,
              Agreement_Type__c = prf.Agreement_Type__c,
              Additional_Accounts__c = prf.Additional_Accounts__c,
              Eligible_Distributor__c = prf.Eligible_Distributor__c,
              Current_Annual_Purchases__c = prf.Current_Annual_Purchases__c,
              Estimated_Annual_Purchases__c = prf.Estimated_Annual_Purchases__c,
              Preferred_Start_Date__c = prf.Preferred_Start_Date__c,
              Preferred_End_Date__c = prf.Preferred_End_Date__c,
              Sales_Deal__c = prf.Sales_Deal__c,
              Valid_From__c = prf.Valid_From__c,
              Valid_To__c = prf.Valid_To__c,
              Category__c = prf.Category__c,
              GPO_Affiliation__c = selectedGPO,
              Data_Driven_Justification__c = prf.Data_Driven_Justification__c,
              Total_Annual_Eaches__c = prf.Total_Annual_Eaches__c,
              PRF_Promotion_related__c = prf.PRF_Promotion_related__c
          );

            //check userBu and assign to Business Unit
            System.debug('*** prf.InApproval__c *** ' + prf.InApproval__c);
            if(inApproval != TRUE){
                System.debug('*** PRF is not in the Approval Process in else no AID ***');
                if(userBu == 'Commercial Operations'){
                System.debug('*** userBu if 2 *** ' + userBu);
                userBu = 'Vascular';
                prf.Business_Unit__c = 'Vascular';
                }
                else{
                    System.debug('*** userBu else 2 *** ' + userBu);
                    prf.Business_Unit__c = userBu;
                }
            }//end of approval check 
            
            

          List<PRF_Line_Item__c> askList = new List<PRF_Line_Item__c>();
          for(PRF_Line_Item__c curr : getPLI() ){
              //logic to handle changing of Agreement Type is ASK prods exist
              if(curr.Material_Name__r.ASK_Custom_Kit__c && !curr.Material_Name__r.SearchableProducts__c){
                  askList.add(curr);
              }
          }//end of for loop to check for ASK products

          if(askList.size() > 0 && prf.Agreement_Type__c != 'ASK Agreement'){
              hasAskItems = true;
              //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This PRF contains ASK products.  Please, remove the ASK products before changing the Agreement Type...'));
          }
          else{
              hasAskItems = false;
              update prf;
          }

        }//end of else for updating PRF Header

        PageReference redir = New Pagereference('/apex/PP_PRF?id=' + prf.Id);
        redir.setRedirect(true);
        if(hasAskItems){
          ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,
          'This PRF contains ASK products.  Please, remove the ASK product line items before changing the Agreement Type...' ));
            //redir.GetParameters().Put('errorMessage', 'This PRF contains ASK products.  Please, remove the ASK products before changing the Agreement Type...');
            return null;
        }
        else{
            return redir;
        }
    }
    //end of PRF save method

    public PageReference msearch(){
        string msearch = '';
        if(strProdSearch != NULL && strProdSearch != ''){
            msearch = '&prdsrch=' + strProdSearch;
        }
        PageReference redir = New Pagereference('/apex/PP_ProductSearch?gs=off&prfid=' + ApexPages.currentPage().getParameters().get('id') + msearch);
        redir.setRedirect(true);
        return redir;
    }

    public PageReference edit() {

        PageReference redir = New Pagereference('/apex/PP_PRF_Edit?id=' + ApexPages.currentPage().getParameters().get('id'));
        redir.setRedirect(true);
        return redir;
    }

    public PageReference xls() {

        PageReference redir = New Pagereference('/apex/PP_PRF_EXPORT?id=' + ApexPages.currentPage().getParameters().get('id'));
        redir.setRedirect(false);
        return redir;
    }

    public PageReference cancel() {

        PageReference redir = New Pagereference('/apex/PP_PRF?id=' + ApexPages.currentPage().getParameters().get('id'));
        redir.setRedirect(true);
        return redir;
    }

    public list<PRF_Line_Item__c> getPLI(){
        List<PRF_Line_Item__c> PLI = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Description, Eligible_Price__c, Material_Name_Text__c,
                                      Current_Price__c, Sales_Deal_Num__c, Sales_Deal_Description__c, Condition__c, Objective_Name__c, Material_Name__r.Distribution_Channel__c,
                                      List_Price__c, Rep_Price__c, RSM_Price__c, CurrencyIsoCode, Requested_Price__c, Material_Name__r.Sales_Org__c,Director_Price__c, Floor_Price__c,
                                      Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, Product_Description__c, Material_Name__r.Transfer_Price__c, Material_Name__r.Cost_Price_Unit__c,
                                      Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Material_Name__r.Director_Price__c, Material_Name__r.Cost__c, Cost__c,
                                      Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c,Material_Name__r.SubGroup__c,
                                      Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Floor_Price__c, Material_Name__r.Brand__c, Material_Status__c,Material_Name__r.Class__c,
                                      Material_Name__r.Cost_Formula__c, Material_Name__r.ASK_Custom_Kit__c, Material_Status_Description__c, Material_Name__r.SearchableProducts__c,
                                      Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Sales_Deal__r.Pricing_Tier__c, Sales_Deal__r.Agreement_Number__c,
                                      Requested_Pricing__r.Parent_Contract_Name__c, Requested_Pricing__r.Agreement_Number__c, Requested_Pricing__r.Description__c,
                                      Material_Name__r.VP_Price__c, PRF__r.Business_Unit__c
                                      FROM PRF_Line_Item__c
                                      WHERE PRF__c = :ApexPages.currentPage().getParameters().get('id')];

        if(PLI.size() > 0){
          margins = getMargins(PLI);
          priceCheck = getPriceCheck(PLI);
          minContract = getMinContract(PLI);
          minContractAgree = getMinContractAgree(PLI);
          minGpo = getMinGpo(PLI);
          minGpoAgree = getMinGpoAgree(PLI);
          formatListPrices = getFormatListPrices(PLI);
          formatRsmPrices = getFormatRsmPrices(PLI);
          formatRepPrices = getFormatRepPrices(PLI);
          formatEligiblePrices = getFormatEligiblePrices(PLI);
          formatRequestedPrices = getFormatRequestedPrices(PLI);
          System.debug('*** formatListPrices *** ' + formatListPrices);
        }

        return PLI;
    }

    //get User Business Unit picklist field values
    public List<SelectOption> getPickListValuesIntoList(){
        List<SelectOption> pickListValuesList= new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = User.Business_Unit__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            //pickListValuesList.add(pickListVal.getLabel());
              if(pickListVal.getValue() != 'Commercial Operations' &&  pickListVal.getValue() != 'Chatter' && pickListVal.getValue() != 'Canada' &&
                pickListVal.getValue() != 'Cross BU (Stop Using This)' && pickListVal.getValue() != 'Customer Advocacy' && pickListVal.getValue() != 'Customer Service'){
                    pickListValuesList.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
              }

        }
        return pickListValuesList;
    }

    //method to add product from cross reference
    public PageReference setBu(){
      system.debug('*** buValue *** ' + buValue);
      //system.debug('*** userId *** ' + userId);
      if(prf.InApproval__c){
        return null;
      }//end if
      else{
        //start Try
        try{
            PRF__c myPrf = new PRF__c(
                id = prf.Id,
              Business_Unit__c = buValue
            );

            update myPrf;
            /*
            User myUser = new User(
                id = userId,
                Business_Unit__c = buValue);
            update myUser;
          */
            //c.save();
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return null;
        //end try
      }//end if/else

    }//end setBu

    public string gettodaysdate(){
        Datetime todaysdate = Datetime.now();
        string ydate = todaysdate.formatlong();

        return ydate;
    }

    public static void settu(){

        Id usrId = [SELECT Owner_ID__c
                    FROM PRF__c
                    WHERE Id = :ApexPages.currentPage().getParameters().get('id')].Owner_ID__c;
        system.debug('usrID' + usrId);

        list<Territory_User__c> tusers = [SELECT Territory_Master__r.Id, Territory_Master__r.Territory_Name__c
                                          FROM Territory_User__c
                                          WHERE User__r.Id = :usrId];

        if(tusers.size() > 0){
            list<PRF__c> prfupdate = new list<PRF__c>();

            for(PRF__c prf : [SELECT Id
                              FROM PRF__c
                              WHERE id = :ApexPages.currentPage().getParameters().get('id')
                              LIMIT 1])
            {
                PRF__c prfrec = new PRF__c(
                    Id = prf.Id,
                    Territory__c = tusers[0].Territory_Master__r.Id
                );
                prfupdate.add(prfrec);
            }
            if(prfupdate.size() > 0){
                update prfupdate;
            }
        }
    }

    //method to get gpo picklist
    public List<SelectOption> getgpoOptions(){

        List<SelectOption> options = new List<SelectOption>();
        //List<GPO_PickList__c> gpoList = [SELECT Key__c, Name, Active__c FROM GPO_PickList__c WHERE Active__c = TRUE ORDER BY Name];

        options.add(new SelectOption('','None'));

        Map<String, GPO_PickList__c> gpos = GPO_PickList__c.getAll();

        List<String> gpoNames = new List<String>();
        gpoNames.addAll(gpos.keySet());
        gpoNames.sort();

        for(String curr : gpoNames){
            GPO_PickList__c gpo = gpos.get(curr);
            //system.debug('curr.Name ***** ' + curr.Name);
            if(prf.Sales_Org_Key__c != NULL && prf.Sales_Org_Key__c != ''){
                if(gpo.Sales_Org_Key__c == prf.Sales_Org_Key__c.left(2) && gpo.Active__c){
                    options.add(new SelectOption(gpo.Name,gpo.Name));
                }
            }
            else{
                system.debug('gpo.Name ***** ' + gpo.Name);
                system.debug('gpo.Sales_Org_Key__c ***** ' + gpo.Sales_Org_Key__c);
                if(gpo.Sales_Org_Key__c == mysalesOrg && gpo.Active__c){
                    options.add(new SelectOption(gpo.Name,gpo.Name));
                }
            }

        }


        system.debug('options ***** ' + options);
        return options;
    }

    // This is what updates the 'GPO Picklist value'
    public PageReference updateGPO() {
        selectedGPO = selectedValue;
        if(ApexPages.currentPage().getParameters().get('id') != NULL){
            PRF__c myprf = new PRF__c(
                id = ApexPages.currentPage().getParameters().get('id'),
                GPO_Affiliation__c = selectedValue);

            update myprf;
            system.debug('LOOPING!');
            return null;
        }
        else{
            prf.GPO_Affiliation__c = selectedValue;
            selectedGPO = selectedValue;
            return null;
        }

    }

    // Method to add line items (1)
    public PageReference sapPrice(){

        String prfId = ApexPages.currentPage().getParameters().get('prfId');

        List<String> prods = new List<String>();
        strProdSearch = strProdSearch.toUpperCase();
        prods.add(strProdSearch);
        system.debug('prods ===== ' + prods);

        PP_PRF sapPrice = new PP_PRF();
        sapPrice.getSapPrice(prods,requestedPrice,null,prfId);

        return NULL;
    }

    public PageReference sapBulkInsert(){
        //bulkMatStr
        String prfId = ApexPages.currentPage().getParameters().get('prfId');
        string bulkstr;
        List<String> bulkMatList = new List<String>();
        for(String bl : bulkMatStr.split('\n')){
            bulkstr = bl.trim();
            bulkstr = bulkstr.toUpperCase();
            bulkMatList.add(bulkstr);
        }
        system.debug('bulkMatList: ' + bulkMatList);

        PP_PRF sapPrice = new PP_PRF();
        sapPrice.getSapPrice(bulkMatList,null,null,prfId);

        return NULL;
    }
    //Start New SAP Price Logic
    public void getSAPprice(List<String> materialStr,Decimal requestedPrice,String lineItemId, String quoteId){

        system.debug('PRF Id ====================== ' + quoteId);
        system.debug('materialStr ======================= ' + materialStr);
        List<Product2> mcheck = new List<Product2>();
        String SAP_1stPick = '00000000';
        List<PRF_Line_Item__c > lineItemList = new List<PRF_Line_Item__c >();
        String soldToType; //Variable to hold Sold To Price List Type

        try{

            PRF__c prf = [SELECT Account__r.SAP_Sold_To__c, Account__r.Account_Group__c, Sales_Org_Key__c, PRF_Name__c, Owner_Business_Unit__c,
                          Account__r.Price_List_Type__c, Agreement_Type__c, Business_Unit__c, InApproval__c, Category__c, CurrencyIsoCode
                          FROM PRF__c
                          WHERE Id =: quoteId LIMIT 1];
            system.debug('prf ====================== ' + prf);

            if(prf.Agreement_Type__c == 'ASK Agreement'){
              mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c, Director_Price__c, Floor_Price__c,
                       List_Price__c, RSM_Price__c, Rep_Price__c, Description, Brand_Name__c, Cost__c, Cost_Formula__c,
                       Distributor_List__c, Alt_Site_List__c
                       FROM Product2
                       WHERE Name IN :materialStr
                       AND Sales_Org_Key__c =: prf.Sales_Org_Key__c
                       AND Duplicate__c = FALSE];
            }
            else{
              mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c, Director_Price__c, Floor_Price__c,
                       List_Price__c, RSM_Price__c, Rep_Price__c, Description, Brand_Name__c, Cost__c, Cost_Formula__c,
                       Distributor_List__c, Alt_Site_List__c
                       FROM Product2
                       WHERE Name IN :materialStr
                       AND Sales_Org_Key__c =: prf.Sales_Org_Key__c
                       AND Duplicate__c = FALSE AND SearchableProducts__c = TRUE];
            }

            system.debug('mcheck ====================== ' + mcheck);


            // Create the Product Mapping
            map<String, Product2> prodmap = new map<String, Product2>();
            for(Product2 pmap : mcheck){
                prodmap.put(pmap.Name, pmap);
            }
            system.debug('prodmap: ' + prodmap);

            string pcn = prf.Account__r.SAP_Sold_To__c;
            string shipTo = '';
            if(prf.Account__r.Account_Group__c == 'Z002'){
                for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                                  FROM Contract_Partnership__c
                                                  WHERE Ship_to__c =:prf.Account__r.SAP_Sold_To__c
                                                  AND Disabled__c = FALSE])
                {
                    pcn = cp.Sale_to__c;
                }
                 shipTo = pcn; 
                
            }
          
            //Query to get Price List Type of SAP Sold To Account
            soldToType = [SELECT Price_List_Type__c FROM Account WHERE SAP_Sold_To__c = :pcn LIMIT 1].Price_List_Type__c;
            system.debug('pcn (Primary Customer Number) ================ ' + pcn);

            // Start building the line items
            // Prospect Account Process
            system.debug('prf.Account__r.SAP_Sold_To__c in getSAPprice PP_Prf ==== ' + prf.Account__r.SAP_Sold_To__c);
            if(prf.Account__r.SAP_Sold_To__c == NULL){
                system.debug('Starting getPrice without SAP');

                for(String ml : materialStr){
                    if(prodmap.get(ml) != NULL){
                        PRF_Line_Item__c  prfLineItem = new PRF_Line_Item__c (
                            PRF__c = prf.Id,
                            Material_Name__c = prodmap.get(ml).Id,
                            Product_Description__c = prodmap.get(ml).Description,
                            CurrencyIsoCode = prf.CurrencyIsoCode,
                            //List_Price__c = prodmap.get(ml).List_Price__c,
                            RSM_Price__c = prodmap.get(ml).RSM_Price__c,
                            Rep_Price__c = prodmap.get(ml).Rep_Price__c,
                            //Current_Price__c = prodmap.get(ml).List_Price__c,
                            //Eligible_Price__c = prodmap.get(ml).List_Price__c,
                            Director_Price__c = prodmap.get(ml).Director_Price__c,
                            Floor_Price__c = prodmap.get(ml).Floor_Price__c,
                            Cost__c = prodmap.get(ml).Cost_Formula__c
                        );
                        if(requestedPrice == NULL || requestedPrice == 0.00){
                          //logic to handle Hospital, Distributor, and Alt Site pricing

                          if( soMap.get(prf.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                              //Alt Site Accounts
                              if(soldToType == 'ZA'){
                                if(prodmap.get(ml).Alt_Site_List__c != 0.00){
                                  prfLineItem.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                  prfLineItem.Requested_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                  prfLineItem.Eligible_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                }
                                else{
                                  prfLineItem.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                  prfLineItem.Requested_Price__c = 0.01;
                                  prfLineItem.Eligible_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                }
                              }

                              //Distributor Accounts
                              if(soldToType == 'ZD'){
                                if(prodmap.get(ml).Distributor_List__c != 0.00){
                                  prfLineItem.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                  prfLineItem.Requested_Price__c = prodmap.get(ml).Distributor_List__c;
                                  prfLineItem.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                }
                                else{
                                  prfLineItem.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                  prfLineItem.Requested_Price__c = 0.01;
                                  prfLineItem.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                }
                              }

                              //Hospital Accounts
                              if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                if(prodmap.get(ml).List_Price__c != 0.00){
                                  prfLineItem.List_Price__c = prodmap.get(ml).List_Price__c;
                                  prfLineItem.Requested_Price__c = prodmap.get(ml).List_Price__c;
                                  prfLineItem.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                }
                                else{
                                  prfLineItem.List_Price__c = prodmap.get(ml).List_Price__c;
                                  prfLineItem.Requested_Price__c = 0.01;
                                  prfLineItem.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                }
                              }
                              //end of logic to handle Hospital, Distributor, and Alt Site pricing
                          }//end of if pq.Sales_Org_Key__c
                          else{
                              //Start of US6020 ZD Pricing Only
                              if( soMap.get(prf.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                  if(prodmap.get(ml).Distributor_List__c != 0.00){
                                      prfLineItem.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                      prfLineItem.Requested_Price__c = prodmap.get(ml).Distributor_List__c;
                                      prfLineItem.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                  }
                                  else{
                                      prfLineItem.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                      prfLineItem.Requested_Price__c = 0.01;
                                      prfLineItem.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                  }
                              }
                              else{
                                  //All other Sales Orgs
                                  if(prodmap.get(ml).List_Price__c != 0.00){
                                      prfLineItem.List_Price__c = prodmap.get(ml).List_Price__c;
                                      prfLineItem.Requested_Price__c = prodmap.get(ml).List_Price__c;
                                      prfLineItem.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                  }
                                  else{
                                      prfLineItem.List_Price__c = prodmap.get(ml).List_Price__c;
                                      prfLineItem.Requested_Price__c = 0.01;
                                      prfLineItem.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                  }
                              }//end else for pq.Sales_org_Key__c = US6020
                          }//end of else pq.Sales_Org_Key__c

                        }//end of if requestedPrice == NULL || requestedPrice == 0.00
                        else{
                            prfLineItem.Requested_Price__c = requestedPrice;
                        }
                        lineItemList.add(prfLineItem);
                    }//end of if prodmap.get(ml) != NULL
                    else{
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Invalid Material!'));
                    }
                }
            }

            // Customer Account Process
            else{
                system.debug('Starting getPrice with SAP');

                Map<String, String> cMap = new Map<String, String>();
                for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
                    cMap.put(scm.Name, scm.Mapped_Value__c);
                }
                system.debug('cMap ============== ' + cMap);

                //Start getting SAP info
                for(String ml : materialStr)
                {
                    if(prodmap.get(ml) != NULL){
                        list<SAPRealPriceSet__x> sapList = new list<SAPRealPriceSet__x>();
                        if (Test.isRunningTest()) {
                            if(prf.Account__r.SAP_Sold_To__c == '999999'){
                              SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
                                    SalesDeal__c = '50009064',
                                    Price__c = 0.00,
                                    Material__c = '353535',
                                    MtrlStatus__c = '40',
                                    SalesMtrlStatus__c = '40',
                                    ValidFrom__c = Date.Today(),
                                    ValidTo__c = Date.Today() + 1000,
                                    AgrDesc__c = 'Duke University SURGR',
                                    Condition__c = 'XNAF',
                                    OwnerName__c = 'Duke Univ Health System',
                                    Owner__c = 'IDN-032',
                                    AgrObjective__c = 'Direct',
                                    Customer__c  = '0000102059'
                                );
                                sapList.add(testSAP);   
                            }//end if sap code check
                            else{
                                SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
                                    SalesDeal__c = '50009064',
                                    Price__c = 123.00,
                                    Material__c = '353535',
                                    MtrlStatus__c = '40',
                                    SalesMtrlStatus__c = '40',
                                    ValidFrom__c = Date.Today(),
                                    ValidTo__c = Date.Today() + 1000,
                                    AgrDesc__c = 'Duke University SURGR',
                                    Condition__c = 'XNAF',
                                    OwnerName__c = 'Duke Univ Health System',
                                    Owner__c = 'IDN-032',
                                    AgrObjective__c = 'Direct',
                                    Customer__c  = '0000102059'
                                );
                                sapList.add(testSAP); 
                            }//end sap code check
                            
                        }//end (Test.isRunningTest())
                        else{
                            sapList = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c,
                                       ValidFrom__c, ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                       OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                       DistChnl__c,ShipTo__c
                                       FROM SAPRealPriceSet__x
                                       WHERE SalesOrg__c =:prodmap.get(ml).Sales_Org__c
                                       AND DistChnl__c =:prodmap.get(ml).Distribution_Channel__c
                                       AND Customer__c =:pcn
                                       AND ShipTo__c = :shipTo
                                       AND Material__c =:prodmap.get(ml).Name
                                       AND EffDate__c =:datetime.now()
                                      ];
                        }
                        for(SAPRealPriceSet__x sap : sapList)
                        {
                            system.debug('sap: ' + sap);

                            string conremap = sap.Condition__c;
                            if(cMap.get(sap.Condition__c) != NULL){
                                conremap = cMap.get(sap.Condition__c);
                            }

                            if(sap.SalesDeal__c != NULL){
                                SAP_1stPick = sap.SalesDeal__c.right(8);
                            }
                            else{
                                SAP_1stPick = '';
                            }
                            system.debug('SAP_1stPick ================ ' + SAP_1stPick);

                            String cnum2;
                            if(sap.Customer__c != NULL){
                                cnum2 = sap.Customer__c.replaceAll('^0+', '');
                            }

                            string mstatus;
                            if(sap.SalesMtrlStatus__c != NULL){
                                mstatus = sap.SalesMtrlStatus__c;
                            }
                            else if(sap.MtrlStatus__c != NULL){
                                mstatus = sap.MtrlStatus__c;
                            }

                            PRF_Line_Item__c  li = new PRF_Line_Item__c (
                                PRF__c = prf.Id,
                                Material_Name__c = prodmap.get(ml).Id,
                                Product_Description__c = prodmap.get(ml).Description,
                                Material_Status__c = mstatus,
                                CurrencyIsoCode = prf.CurrencyIsoCode,
                                //List_Price__c = prodmap.get(ml).List_Price__c,
                                RSM_Price__c = prodmap.get(ml).RSM_Price__c,
                                Rep_Price__c = prodmap.get(ml).Rep_Price__c,
                                Director_Price__c = prodmap.get(ml).Director_Price__c,
                                Floor_Price__c = prodmap.get(ml).Floor_Price__c,
                                Cost__c = prodmap.get(ml).Cost_Formula__c,
                                Requested_Price__c = requestedPrice,
                                Condition__c = conremap,
                                Sales_Deal_Num__c = SAP_1stPick,
                                Sales_Deal_Description__c = sap.AgrDesc__c,
                                SAP_Sold_to__c = cnum2,
                                Objective__c = sap.AgrObjective__c
                            );


                            // Check for eligible price = 0
                            if(sap.Price__c == 0.00 || sap.Price__c == NULL){
                                //logic to handle Hospital, Distributor, and Alt Site pricing
                                if( soMap.get(prf.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                                    //Alt Site Accounts
                                    if(soldToType == 'ZA'){
                                        li.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                        //li.Requested_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                        li.Eligible_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                    }

                                    //Distributor Accounts
                                    if(soldToType == 'ZD'){
                                        li.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                        //li.Requested_Price__c = 0.01;
                                        li.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                    }

                                    //Hospital Accounts
                                    if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                        li.List_Price__c = prodmap.get(ml).List_Price__c;
                                        //li.Requested_Price__c = 0.01;
                                        li.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                    }
                                    //end of logic to handle Hospital, Distributor, and Alt Site pricing
                                }//end of if pq.Sales_Org_Key__c
                                else{
                                    if( soMap.get(prf.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                        li.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                        li.Eligible_Price__c = prodmap.get(ml).Distributor_List__c; 
                                    }else{
                                       li.List_Price__c = prodmap.get(ml).List_Price__c; 
                                       li.Eligible_Price__c = prodmap.get(ml).List_Price__c; 
                                    }
                                    
                                    //li.Requested_Price__c = 0.01;
                                    
                                }//end of else pq.Sales_Org_Key__c

                            }//end of if sap.Price__c == 0.00 || sap.Price__c == NULL
                            else{
                              //logic to handle Hospital, Distributor, and Alt Site pricing
                              if( soMap.get(prf.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                                  //Alt Site Accounts
                                  if(soldToType == 'ZA'){
                                      li.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                  }

                                  //Distributor Accounts
                                  if(soldToType == 'ZD'){
                                      li.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                  }

                                  //Hospital Accounts
                                  if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                      li.List_Price__c = prodmap.get(ml).List_Price__c;
                                  }
                                  //end of logic to handle Hospital, Distributor, and Alt Site pricing
                              }//end of if pq.Sales_Org_Key__c
                              else{
                                  if( soMap.get(prf.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                      li.List_Price__c = prodmap.get(ml).Distributor_List__c;    
                                  }else{
                                      li.List_Price__c = prodmap.get(ml).List_Price__c;
                                  }
                                  
                              }//end of else pq.Sales_Org_Key__c

                              li.Eligible_Price__c = sap.Price__c;
                            }//end of else sap.Price__c == 0.00 || sap.Price__c == NULL

                            //set requested price
                            if(requestedPrice == NULL || requestedPrice == 0.00){
                                li.Requested_Price__c = li.Eligible_Price__c;
                            }
                            else{
                                li.Requested_Price__c = requestedPrice;
                            }

                            if(lineItemId != NULL){
                                li.Id = lineItemId;
                            }

                            lineItemList.add(li);
                            system.debug('lineItemList ======================== ' + lineItemList);
                        }
                    }
                    else{
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Invalid Material!'));
                    }


                }
                //End of Sap info

                //check list size and insert list
                If(lineItemList.size() > 0){
                    system.debug('lineItemList ======================= ' + lineItemList);
                    If(lineItemId == NULL){
                        database.insert(lineItemList,false);
                        //insert lineItemList;
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, + ' Successfully added to PRF: ' + prf.PRF_Name__c  ));

                        //conditions below helps with Price Quote and PRF Approval Matrix Routing
                        if(prf.Owner_Business_Unit__c == 'Alternate Care'){
                            PP_SAP_Price sapPrice = new PP_SAP_Price();
                            sapPrice.lineClassCheck(quoteId);
                        }

                        if(prf.Owner_Business_Unit__c == 'Anesthesia'){
                            PP_SAP_Price sapPrice = new PP_SAP_Price();
                            sapPrice.lineProdCheckAnes(quoteId);
                        }

                        if(prf.Owner_Business_Unit__c == 'Interventional Capital' || prf.Owner_Business_Unit__c == 'Cardiac'){
                            PP_SAP_Price sapPrice = new PP_SAP_Price();
                            sapPrice.lineProdCheckIcap(quoteId);
                        }

                        if(prf.Owner_Business_Unit__c == 'Surgical Instruments'){
                            PP_SAP_Price sapPrice = new PP_SAP_Price();
                            sapPrice.lineClassCheck(quoteId);
                        }

                    }
                    else{
                        system.debug('UPDATING PRF LINE ITEM');
                        update lineItemList;
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Updated ' +  ' on PRF: ' + prf.PRF_Name__c  ));

                        //conditions below helps with Price Quote and PRF Approval Matrix Routing
                        if(prf.Owner_Business_Unit__c == 'Alternate Care'){
                            PP_SAP_Price sapPrice = new PP_SAP_Price();
                            sapPrice.lineClassCheck(quoteId);
                        }

                        if(prf.Owner_Business_Unit__c == 'Anesthesia'){
                            PP_SAP_Price sapPrice = new PP_SAP_Price();
                            sapPrice.lineProdCheckAnes(quoteId);
                        }

                        if(prf.Owner_Business_Unit__c == 'Interventional Capital' || prf.Owner_Business_Unit__c == 'Cardiac'){
                            PP_SAP_Price sapPrice = new PP_SAP_Price();
                            sapPrice.lineProdCheckIcap(quoteId);
                        }

                        if(prf.Owner_Business_Unit__c == 'Surgical Instruments'){
                            PP_SAP_Price sapPrice = new PP_SAP_Price();
                            sapPrice.lineClassCheck(quoteId);
                        }
                    }
                }
            }

        }
        catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
        }

    }
    //End New SAP Price Logic

    @RemoteAction
    public static PRF_Line_Item__c updatePrice(id lineId, decimal price){
        system.debug('In updatePrice Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

        Id pid; // Product Id
        Id prfId; // Price Quote Id - In Case we need it for Phase 2
        string userBu; // Users Business Unit
        for(PRF_Line_Item__c  prfli : [Select Material_Name__c, PRF__c, PRF__r.Owner_Business_Unit__c
                                             FROM PRF_Line_Item__c
                                             WHERE Id = :lineId])
        {
            userBu = prfli.PRF__r.Owner_Business_Unit__c;
            pid = prfli.Material_Name__c;
            prfId = prfli.PRF__c;
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

        PRF_Line_Item__c li = new PRF_Line_Item__c(
            Id = lineId,
            Requested_Price__c  = price
        );

        if(cmId != NULL){
            // Phase 2
            list<PRF_Line_Item__c> prfliList = new list<PRF_Line_Item__c>();
            list<PRF_Line_Item__c> prfliUpdate = new list<PRF_Line_Item__c>();
            map<Id, Contract_Material__c> cmMap = new map<Id, Contract_Material__c>(); // Product Id == CM Record
            set<Id> pSet = new set<Id>();

            // Checks to see if the related Business Unit on the Price Quote has 'Tier Unlocked'
            boolean tierUnlocked = FALSE;
            for(Business_Unit__c bu : Business_Unit__c.getall().values()){
                if(userBu == bu.Name && bu.Pricing_Tiers_Unlocked__c == TRUE){
                    tierUnlocked = TRUE;
                }
            }

            // Update the PQ Line Item
            li.Requested_Pricing__c = chId;
            li.Requested_Pricing_CM__c = cmId;
            li.Requested_Price_PT__c = cmPrice;
            li.Requested_Price__c = cmPrice;
            prfliUpdate.add(li); // Add it to the list

            if(tierUnlocked == FALSE){ // Checks to see if the related Business Unit on the Price Quote has 'Tier Unlocked'

                // Time to fix the rest of the line items
                for(PRF_Line_Item__c prfli : [Select Id, Material_Name__c, Requested_Price_PT__c, Requested_Pricing__c,
                                              Requested_Pricing_CM__c, Requested_Price__c
                                              FROM PRF_Line_Item__c
                                              WHERE PRF__c = :prfId])
                {
                    if(prfli.Material_Name__c != NULL){
                        if(prfli.Id != lineId){
                            prfliList.add(prfli);
                        }
                        pSet.add(prfli.Material_Name__c);
                    }
                }

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
                if(prflilist.size()>0){
                    for(PRF_Line_Item__c prfli : prfliList){
                        if(cmMap.containsKey(prfli.Material_Name__c)){
                            PRF_Line_Item__c newli = new PRF_Line_Item__c(
                                id = prfli.Id,
                                Requested_Price__c = cmMap.get(prfli.Material_Name__c).Price__c,
                                Requested_Pricing__c = cmMap.get(prfli.Material_Name__c).Agreement__c,
                                Requested_Pricing_CM__c = cmMap.get(prfli.Material_Name__c).Id,
                                Requested_Price_PT__c = cmMap.get(prfli.Material_Name__c).Price__c
                            );
                            prfliUpdate.add(newli);
    
                        }
                    }
                }
            }
            // Update the PQ Line Items
            if(prfliUpdate.size() > 0){
                update prfliUpdate;
            }

        }
        else{
            li.Requested_Pricing__c = NULL;
            li.Requested_Pricing_CM__c = NULL;
            li.Requested_Price_PT__c = 0;

            update li;
        }

        return li;
    }


    /* Backup of updatePrice --
    //remote action to update Requested price
    @RemoteAction
    public static PRF_Line_Item__c updatePrice(id lineId, decimal price){
        system.debug('In updatePrice Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        PRF_Line_Item__c li = new PRF_Line_Item__c(
            Id = lineId, Requested_Price__c = price,
            Requested_Pricing__c = NULL,
            Requested_Pricing_CM__c = NULL,
            Requested_Price_PT__c = 0
        );

        update li;
        return li;
    }*/

    //method to refresh lines
    public PageReference Refresh(){
        String materialId = Apexpages.currentpage().getParameters().get('itemId');
        String lineItemId = Apexpages.currentpage().getParameters().get('lineItemId');
        String prfId = ApexPages.currentPage().getParameters().get('id');
        String strPrice = ApexPages.currentPage().getParameters().get('requestedPrice');
        Decimal price = null;
        try{
            price = Decimal.valueOf(strPrice);
        }
        catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Issue with price line 318 PP_PRF class ...' + e.getMessage()));
        }

        system.debug('materialId ====================== ' + materialId);
        system.debug('lineItemId ====================== ' + lineItemId);
        system.debug('prfId ====================== ' + prfId);
        system.debug('price ====================== ' + price);

        PP_PRF sapPrice = new PP_PRF();
        List<String> prods = new List<String>();
        prods.add(materialId);
        system.debug('prods ===== ' + prods);

        sapPrice.getSAPprice(prods,price,lineItemId,prfId);
        Return NULL;
    }
    //end method to refresh lines

    //method to delete lines
    public PageReference removingRow() {
        String prflid = apexpages.currentpage().getparameters().get('itemId');
        system.debug('prflid =============================== ' + prflid);
        system.debug('IN REMOVINGROW METHOD!!!!!!!!!!!!!!!');
        List<PRF_Line_Item__c> delLine = [Select Id From PRF_Line_Item__c WHERE id =:prflid];
        system.debug('delLine=============================== ' + delLine);
        //delete delLine;

        try{
            delete delLine;
            //conditions below helps with Price Quote and PRF Approval Matrix Routing
            if(prf.Owner_Business_Unit__c == 'Alternate Care'){
              PP_SAP_Price check = new PP_SAP_Price();
              check.lineClassCheck(prf.Id);
            }

            if(prf.Owner_Business_Unit__c == 'Anesthesia'){
              PP_SAP_Price check = new PP_SAP_Price();
              check.lineProdCheckAnes(prf.Id);
            }

            if(prf.Owner_Business_Unit__c == 'Interventional Capital' || prf.Owner_Business_Unit__c == 'Cardiac'){
              PP_SAP_Price check = new PP_SAP_Price();
              check.lineProdCheckIcap(prf.Id);
            }

            if(prf.Owner_Business_Unit__c == 'Surgical Instruments'){
              PP_SAP_Price check = new PP_SAP_Price();
              check.lineClassCheck(prf.Id);
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        //return new PageReference('/apex/PP_Price_Quote?pqid={!strQuoteId}').setRedirect(true);
        return null;
    }
    //end of delete method

    //method to get Agreement Type from PRF_Edit Page
    public PageReference updateType(){
      system.debug('prf.Agreement_Type__c ***** ' + prf.Agreement_Type__c);
        if(prf.Agreement_Type__c == 'Direct Only Agreement'){
            isDirect = true;
            isAsk = false;
            system.debug('*** isDirect *** ' + isDirect);
            system.debug('*** isAsk *** ' + isAsk);
        }
        else if(prf.Agreement_Type__c == 'ASK Agreement'){
            isAsk = true;
            isDirect = false;
            system.debug('*** isAsk *** ' + isAsk);
            system.debug('*** isDirect *** ' + isDirect);
        }
        else{
            isDirect = false;
            isAsk = false;
            system.debug('*** isDirect *** ' + isDirect);
            system.debug('*** isAsk *** ' + isAsk);
        }
        return null;
    }
    //end of Agreement Type method

    //start of create Quote method
    public PageReference createQuote(){

        //create price quote header
        Price_Quote__c newPQ = new Price_Quote__c(
            Status__c = 'In Progress',
            PRF__c = prf.Id,
            Account_Name__c = prf.Account__c,
            Contact_Name__c = prf.Contact__c,
            Expiration_Date__c = system.today() +90,
            CurrencyIsoCode = prf.CurrencyIsoCode,
            Sales_Org_Key__c = prf.Sales_Org_Key__c
        );

        //check for Latin American User
        if(prf.Sales_Org_Key__c != NULL){
            system.debug('salesOrgKey ' + salesOrgKey);
            if(prf.Sales_Org_Key__c == 'US6010' || prf.Sales_Org_Key__c == 'US103010'){
                newPQ.One_Time_Purchase__c = true;
            }
        }

        insert newPQ;
        system.debug('newPQ: ' + newPQ);

        //update PRF to include related Price Quote
        /*PRF__c updPrf = new PRF__c(
            Id = prf.Id,
            prf.Price_Quote__c = newPQ.Id);
        */
        prf.Price_Quote__c = newPQ.Id;
        update prf;

        /*get list of PRF Line Items
        List<PRF_Line_Item__c> prfli = [SELECT Id, Condition__c, Current_Price__c, Eligible_Price__c, List_Price__c,
                                              Material_Name__c, Material_Status__c, Name, PQLI_ID__c, PRF__c,
                                              Rep_Price__c, Requested_Price__c, RSM_Price__c, Sales_Deal_Description__c, Sales_Deal_Num__c,
                                              Sales_Deal__c, SAP_Sold_to__c, CurrencyIsoCode
                                              FROM PRF_Line_Item__c WHERE PRF__c =:prf.Id];

        system.debug('prfli ***** ' + prfli); */

        List<Price_Quote_Line_Item__c> pqli = new List<Price_Quote_Line_Item__c>();

        //for loop to upsert Line Items of PRF to Price Quote
        for(PRF_Line_Item__c curr : [SELECT Id, Condition__c, Current_Price__c, Eligible_Price__c, List_Price__c, Cost__c,Material_Status_Description__c,
                                     Material_Name__c, Material_Status__c, Name, PQLI_ID__c, PRF__c,Objective__c, Floor_Price__c,
                                     Rep_Price__c, Requested_Price__c, RSM_Price__c, Sales_Deal_Description__c, Director_Price__c,
                                     Sales_Deal_Num__c, Sales_Deal__c, SAP_Sold_to__c, CurrencyIsoCode, Product_Description__c
                                     FROM PRF_Line_Item__c WHERE PRF__c =:prf.Id])
        {
            Price_Quote_Line_Item__c updLineItems = new Price_Quote_Line_Item__c(
                Price_Quote__c = newPQ.Id,
                Condition__c = curr.Condition__c,
                Eligible_Price__c = curr.Eligible_Price__c,
                List_Price__c = curr.List_Price__c,
                RSM_Price__c = curr.RSM_Price__c,
                Rep_Price__c = curr.Rep_Price__c,
                Sales_Price__c = curr.Requested_Price__c,
                Director_Price__c = curr.Director_Price__c,
                Floor_Price__c = curr.Floor_Price__c,
                Cost__c = curr.Cost__c,
                Material_Name__c = curr.Material_Name__c,
                Material_Status__c = curr.Material_Status__c,
                Sales_Deal_Description__c = curr.Sales_Deal_Description__c,
                Sales_Number__c = curr.Sales_Deal_Num__c,
                Sales_Deal__c = curr.Sales_Deal__c,
                Product_Description__c = curr.Product_Description__c,
                CurrencyIsoCode = curr.CurrencyIsoCode,
                Quantity__c = 1,
                Objective__c = curr.Objective__c
            );
            pqli.add(updLineItems);

        }//end of PRF_Line_Item__c for loop

        //update current Line Items
        if(pqli.size() > 0){
            system.debug('pqli ***** ' + pqli);
            insert pqli;
        }

        PageReference toQuote = new PageReference('/apex/PP_Price_Quote?pqId='+ newPQ.Id).setRedirect(True);
        return toQuote;
    }
    //end of create quote method

    // Bulk Refresh
    public void bulkrefresh(){

        String prfId = ApexPages.currentPage().getParameters().get('prfId');
        system.debug('prfId ***** ' + prfId);

        String soldToType; //Variable to hold Sold To Price List Type
        list<PRF_Line_Item__c> lineItemList = new list<PRF_Line_Item__c>();
        set<String> mstringid = new set<String>();
        Set<String> productNames= new Set<String>();
        Set<String> productSalesOrg= new Set<String>();
        Set<String> productDistChannel= new Set<String>();
        list<PRF_Line_Item__c> prflilist = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, PRF__r.Business_Unit__c,
                                            Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c,
                                            Requested_Price_PT__c, Requested_Pricing_CM__c
                                            FROM PRF_Line_Item__c
                                            WHERE PRF__r.Id = :prfid
                                            LIMIT 75];
        system.debug('prflilist: ' + prflilist);
        map<Id, Decimal> prfliSales = new map<Id, Decimal>();
        map<Id, Decimal> cmPrice = new map<Id, Decimal>();
        set<Id> prfliSet = new set<Id>();
        if(prflilist.size()>0){
            for(PRF_Line_Item__c prfli : prflilist){
                if(prfli.Requested_Price_PT__c == 0.00 && prfli.Requested_Pricing_CM__c != NULL){
                    prfliSet.add(prfli.Requested_Pricing_CM__c);
                }
                mstringid.add(prfli.Material_Name__r.Id);
                
                //Added - 20 March, 2023
                if(prfli.Material_Name__c !=null && prfli.Material_Name__r.Name!=null){
                    productNames.add(prfli.Material_Name__r.Name);
                }
                if(prfli.Material_Name__c !=null && prfli.Material_Name__r.Sales_Org__c!=null){
                    productSalesOrg.add(prfli.Material_Name__r.Sales_Org__c);
                }
                if(prfli.Material_Name__c !=null && prfli.Material_Name__r.Distribution_Channel__c!=null){
                    productDistChannel.add(prfli.Material_Name__r.Distribution_Channel__c);
                }
            }
        }
        system.debug('mstringid: ' + mstringid);

                               
        if(prfliSet.size() > 0){
            for(Contract_Material__c cm : [SELECT Id, Price__c
                                           FROM Contract_Material__c
                                           WHERE Id = :prfliSet])
            {
                cmPrice.put(cm.Id, cm.Price__c);
            }
        }
        try{

            PRF__c prf = [SELECT Account__r.SAP_Sold_To__c, Account__r.Account_Group__c, Sales_Org_Key__c, Line_Count__c, InApproval__c,
                          Account__r.Price_List_Type__c, Product_Class_Count__c, Owner_Business_Unit__c, Business_Unit__c, CurrencyIsoCode
                          FROM PRF__c
                          WHERE Id =: prfId LIMIT 1];
            system.debug('prf ====================== ' + prf);
            
            list<Product2> mcheck= new list<Product2>();
            if(mstringid.size()>0){
                mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c, Director_Price__c, Floor_Price__c,
                                         List_Price__c, RSM_Price__c, Rep_Price__c, Description, Brand_Name__c, Cost_Formula__c,
                                         Distributor_List__c, Alt_Site_List__c
                                         FROM Product2
                                         WHERE Id IN:mstringid
                                         AND Duplicate__c = FALSE AND SearchableProducts__c = TRUE];
                system.debug('mcheck ====================== ' + mcheck);
            }

            // Create the Product Mapping
            map<String, Product2> prodmap = new map<String, Product2>();
            if(mcheck.size()>0){
                for(Product2 pmap : mcheck){
                    prodmap.put(pmap.Name, pmap);
                }
                system.debug('prodmap: ' + prodmap);
            }
            

            // Determine which SAP Number to use for Lookup
            string pcn = prf.Account__r.SAP_Sold_To__c;
            string shipTo= '';
            if(prf.Account__r.Account_Group__c == 'Z002'){
                for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                                  FROM Contract_Partnership__c
                                                  WHERE Ship_to__c =:prf.Account__r.SAP_Sold_To__c
                                                  AND Disabled__c = FALSE])
                {
                    pcn = cp.Sale_to__c;
                }
                shipTo = pcn;  
            }
             
                
 
                //Query to get Price List Type of SAP Sold To Account
                soldToType = [SELECT Price_List_Type__c FROM Account WHERE SAP_Sold_To__c = :pcn LIMIT 1].Price_List_Type__c;
            
            
            system.debug('pcn (Primary Customer Number) ================ ' + pcn);

            // Start building the line items

            // Prospect Account Process (No SAP) #1
            if(prf.Account__r.SAP_Sold_To__c == NULL){
                system.debug('Starting getPrice without SAP');
                if(prflilist.size()>0){
                    for(PRF_Line_Item__c ml : prflilist){
    
                        PRF_Line_Item__c  prfLineItem = new PRF_Line_Item__c (
                            PRF__c = prf.Id,
                            Material_Name__c = prodmap.get(ml.Material_Name__r.Name).Id,
                            Product_Description__c = prodmap.get(ml.Material_Name__r.Name).Description,
                            CurrencyIsoCode = prf.CurrencyIsoCode,
                            //List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                            RSM_Price__c = prodmap.get(ml.Material_Name__r.Name).RSM_Price__c,
                            Rep_Price__c = prodmap.get(ml.Material_Name__r.Name).Rep_Price__c,
                            Director_Price__c = prodmap.get(ml.Material_Name__r.Name).Director_Price__c,
                            Floor_Price__c = prodmap.get(ml.Material_Name__r.Name).Floor_Price__c,
                            Cost__c = prodmap.get(ml.Material_Name__r.Name).Cost_Formula__c
                            //Requested_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                            //Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c
                        );
                        if(prfLineItem.Requested_Pricing_CM__c != NULL && prfLineItem.Requested_Price_PT__c == 0){
                            prfLineItem.Requested_Price_PT__c = cmPrice.get(prfLineItem.Requested_Pricing_CM__c);
                        }
                            //cmPrice
    
                        //logic to handle Hospital, Distributor, and Alt Site pricing
                        if( soMap.get(prf.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                            //Alt Site Accounts
                            if(soldToType == 'ZA'){
                                prfLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                prfLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                            }
    
                            //Distributor Accounts
                            if(soldToType == 'ZD'){
                                prfLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                prfLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                            }
    
                            //Hospital Accounts
                            if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                prfLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                prfLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                            }
                            //end of logic to handle Hospital, Distributor, and Alt Site pricing
                        }//end of if pq.Sales_Org_Key__c
                        else{
                            if( soMap.get(prf.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                prfLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                prfLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                            }else{
                                prfLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                prfLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                            }                      
                        }//end of else pq.Sales_Org_Key__c
                        
                        if(prfLineItem.Requested_Pricing_CM__c != NULL &&
                           prfLineItem.Requested_Price_PT__c == 0.00 &&
                           cmPrice.containsKey(prfLineItem.Requested_Pricing_CM__c)){
                            prfLineItem.Requested_Price_PT__c = cmPrice.get(prfLineItem.Requested_Pricing_CM__c);
                        }
                        lineItemList.add(prfLineItem);
                    }
                }
            }//end of if prf.Account__r.SAP_Sold_To__c == NULL
            // Customer Account Process #2
            else{
                system.debug('Starting getPrice with SAP');

                Map<String, String> cMap = new Map<String, String>();
                for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
                    cMap.put(scm.Name, scm.Mapped_Value__c);
                }
                system.debug('cMap ============== ' + cMap);
                
              /*  list<SAPRealPriceSet__x> sapList= [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c,
                               ValidFrom__c, ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                               OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                               DistChnl__c,ShipTo__c
                               FROM SAPRealPriceSet__x
                               WHERE SalesOrg__c IN: productSalesOrg
                               AND DistChnl__c IN: productDistChannel
                               AND Customer__c =:pcn
                               AND ShipTo__c =:shipTo
                               AND Material__c IN: productNames
                               AND EffDate__c =:datetime.now()
                              ];
                system.debug('__sapList__'+sapList);*/
                //Start getting SAP info
                if(prflilist.size()>0){
                    for(PRF_Line_Item__c ml : prflilist)
                    {
                        list<SAPRealPriceSet__x> sapList = new list<SAPRealPriceSet__x>();
                        
    
                        sapList = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c,
                                   ValidFrom__c, ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                   OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                   DistChnl__c,ShipTo__c
                                   FROM SAPRealPriceSet__x
                                   WHERE SalesOrg__c =:ml.Material_Name__r.Sales_Org__c
                                   AND DistChnl__c =:ml.Material_Name__r.Distribution_Channel__c
                                   AND Customer__c =:pcn
                                   AND ShipTo__c =:shipTo
                                   AND Material__c =:ml.Material_Name__r.Name
                                   AND EffDate__c =:datetime.now()
                                  ];
                        
                        if (Test.isRunningTest()) {
                            SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
                                SalesDeal__c = '50000000',
                                Price__c = 0.00,
                                Material__c = 'AA-10511-1',
                                MtrlStatus__c = '40',
                                SalesMtrlStatus__c = '40',
                                ValidFrom__c = Date.Today(),
                                ValidTo__c = Date.Today() + 1000,
                                AgrDesc__c = 'Duke University SURGR',
                                Condition__c = 'XNAF',
                                OwnerName__c = 'Duke Univ Health System',
                                Owner__c = 'IDN-032',
                                AgrObjective__c = 'Direct',
                                Customer__c  = '000SAPcode101'
                            );
                            sapList.add(testSAP);
                        }
    
                        for(SAPRealPriceSet__x sap : sapList)
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
    
                            PRF_Line_Item__c  li = new PRF_Line_Item__c (
                                PRF__c = prf.Id,
                                Material_Name__c = prodmap.get(ml.Material_Name__r.Name).Id,
                                Product_Description__c = prodmap.get(ml.Material_Name__r.Name).Description,
                                Material_Status__c = mstatus,
                                CurrencyIsoCode = prf.CurrencyIsoCode,
                                //List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                                RSM_Price__c = prodmap.get(ml.Material_Name__r.Name).RSM_Price__c,
                                Rep_Price__c = prodmap.get(ml.Material_Name__r.Name).Rep_Price__c,
                                Director_Price__c = prodmap.get(ml.Material_Name__r.Name).Director_Price__c,
                                Floor_Price__c = prodmap.get(ml.Material_Name__r.Name).Floor_Price__c,
                                Cost__c = prodmap.get(ml.Material_Name__r.Name).Cost_Formula__c,
                                //Requested_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                                Condition__c = conremap,
                                Sales_Deal_Description__c = sap.AgrDesc__c,
                                Sales_Deal_Num__c = salesDeal,
                                Id = ml.Id,
                                Objective__c = sap.AgrObjective__c
                            );
    
                            //check for eligible price = 0
                            if(sap.Price__c != 0.00){
                                //li.Requested_Price__c = sap.Price__c;
                                li.Eligible_Price__c = sap.Price__c;
    
                                //logic to handle Hospital, Distributor, and Alt Site pricing
                                if( soMap.get(prf.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
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
                                    //end of logic to handle Hospital, Distributor, and Alt Site pricing
                                }//end of if pq.Sales_Org_Key__c
                                else{
                                    if( soMap.get(prf.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                    }else{
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                    }
                                }//end of else pq.Sales_Org_Key__c
    
                            }//end of if sap.Price__c != 0.00
                            else{
                              //logic to handle Hospital, Distributor, and Alt Site pricing
                              if( soMap.get(prf.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                                  //Alt Site Accounts
                                  if(soldToType == 'ZA'){
                                      li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                      li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                  }
    
                                  //Distributor Accounts
                                  if(soldToType == 'ZD'){
                                      li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                      li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                  }
    
                                  //Hospital Accounts
                                  if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                      li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                      li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                  }
                                  //end of logic to handle Hospital, Distributor, and Alt Site pricing
                              }//end of if pq.Sales_Org_Key__c
                              else{
                                  if( soMap.get(prf.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                      li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                      li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                  }else{
                                      li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                      li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                  }
                              }//end of else pq.Sales_Org_Key__c
    
                            }
                            if(ml.Requested_Pricing_CM__c != NULL &&
                               ml.Requested_Price_PT__c == 0.00 &&
                               cmPrice.containsKey(ml.Requested_Pricing_CM__c)
                              ){
                                  li.Requested_Price_PT__c = cmPrice.get(ml.Requested_Pricing_CM__c);
                              }
    
                            //add object to list
                            lineItemList.add(li);
                            system.debug('lineItemList ======================== ' + lineItemList);
                        }
    
    
    
                    }
                }
                // DML - Insert Lines
                If(lineItemList.size() > 0){
                    system.debug('lineItemList ======================= ' + lineItemList);
                    database.update(lineItemList,false);

                    //conditions below helps with Price Quote and PRF Approval Matrix Routing
                    if(prf.Owner_Business_Unit__c == 'Alternate Care'){
                        PP_SAP_Price sapPrice = new PP_SAP_Price();
                        sapPrice.lineClassCheck(prfId);
                    }

                    if(prf.Owner_Business_Unit__c == 'Anesthesia'){
                        PP_SAP_Price sapPrice = new PP_SAP_Price();
                        sapPrice.lineProdCheckAnes(prfId);
                    }

                    if(prf.Owner_Business_Unit__c == 'Interventional Capital' || prf.Owner_Business_Unit__c == 'Cardiac'){
                        PP_SAP_Price sapPrice = new PP_SAP_Price();
                        sapPrice.lineProdCheckIcap(prfId);
                    }

                    if(prf.Owner_Business_Unit__c == 'Surgical Instruments'){
                        PP_SAP_Price sapPrice = new PP_SAP_Price();
                        sapPrice.lineClassCheck(prfId);
                    }
                }
            }//end of else prf.Account__r.SAP_Sold_To__c == NULL

        }
        catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
        }

    }//end of bulk refresh

    // Attach PDF

    public void createPDF() {

        string prfId = ApexPages.currentPage().getParameters().get('Id');

        PageReference pdf = Page.PP_PRF_Export_PDF;
        // add parent id to the parameters for standardcontroller
        pdf.getParameters().put('id',prfId);
        // create the new attachment
        Attachment attach = new Attachment();

        // the contents of the attachment from the pdf
        Blob body;

        try {

            // returns the output of the page as a PDF
            body = pdf.getContentAsPDF();

            // need to pass unit test -- current bug
        } catch (VisualforceException e) {
            body = Blob.valueOf('Error...');
        }

        attach.Body = body;
        // add the user entered name pdf.getContentAsPDF
        attach.Name = 'PRF-'+prfId;
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = prfId;
        attach.ContentType = 'application/pdf';
        system.debug('attach: ' + attach);
        insert attach;

        // send the user to the account to view results
        // return Apexpages.currentPage();
        // return new PageReference('/'+parentId);

        //   return Apexpages.currentPage();

    }

    public PageReference createAuditPDF() {

        string prfId = ApexPages.currentPage().getParameters().get('Id');
        boolean created = prf.Audit_Check__c;
        boolean doUpdate = FALSE;

        Prf__c updApprover = new Prf__c(
            Id = prfId
        );

        //variables and query for Current Approver stuff
        String listOfNames = '';
        List<String> nameList = new List<String>();

        //get information from getApprovaInfor list
        List<ProcessInstanceWorkitem> approvalNames = getApprovalInfo();
        system.debug('*** approvalNames *** ' + approvalNames);
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
            updApprover.Current_Approver__c = listOfNames;
            doUpdate = TRUE;

          if(prf.Current_Approver__c != listOfNames){
            System.debug('*** In if to update Approver ***');
            update updApprover;
          }

        }//end of Work Item IF
        else{
            updApprover.Current_Approver__c = listOfNames;

            if(prf.Current_Approver__c != listOfNames && prf.Current_Approver__c != NULL){
                System.debug('*** In else to update Approver ***');
                doUpdate = TRUE;
            }

        }
        //end of logic to get current approver
        //end of Current Approver Stuff

        if(!created && prf.Status__c == 'Approved'){
            PageReference pdf = Page.PP_PRF_Export_PDF;
            // add parent id to the parameters for standardcontroller
            pdf.getParameters().put('id',prfId);
            // create the new attachment
            Attachment attach = new Attachment();

            // the contents of the attachment from the pdf
            Blob body;

            try {

                // returns the output of the page as a PDF
                body = pdf.getContentAsPDF();

                // need to pass unit test -- current bug
            } catch (VisualforceException e) {
                body = Blob.valueOf('Error...');
            }

            string prfAuditName;
            if(prf.Name != NULL){
                prfAuditName = prf.Name;
            }
            else{
                prfAuditName = 'PRF-' + prfId;
            }//PRF_Name_Sales_Person__c

            attach.Body = body;
            // add the user entered name pdf.getContentAsPDF
            attach.Name = prfAuditName;
            attach.IsPrivate = false;
            // attach the pdf to the account
            attach.ParentId = prfId;
            attach.ContentType = 'application/pdf';
            system.debug('attach: ' + attach);
            insert attach;

            updApprover.Audit_Check__c = TRUE;
            doUpdate = TRUE;

        }

        // New Logic to set the Pricing Level on the Price Quote - 27Jun2018 - ESC
        if(prf2.Pricing_Tier_Level__c == NULL && UserInfo.getUserId() == prf2.OwnerId){
            Integer pricingTierLevel = 1;
            for(Contract_User__c cu : [SELECT Pricing_Tier_Access__c, User__r.Name
                                       FROM Contract_User__c
                                       WHERE User__c = :UserInfo.getUserId()
                                       LIMIT 1])
            {
                system.debug('Setting Pricing Tier [' + cu.User__r.Name + '] - Access/Level: ' + cu.Pricing_Tier_Access__c);

                if(integer.valueOf(cu.Pricing_Tier_Access__c) != NULL){
                    pricingTierLevel = integer.valueOf(cu.Pricing_Tier_Access__c);
                }
                if(UserInfo.getUserId() == prf2.OwnerId){
                    updApprover.Pricing_Tier_Level__c = pricingTierLevel;
                    doUpdate = TRUE;
                }
            }

        }

        if(doUpdate){
            system.debug('Updating PQ! -- [helperMethod] ');
            update updApprover;
        }

        //return pageReturnPRF;
        return NULL;


    }//end of createAuditPDF

    public static void checkSalesOrg(list<PRF__c> newTrigger){
        system.debug('-- Starting the Check Sales Org --');
        set<id> uid = new set<id>();
        map<id, string> soMap = new map<id, string>();
        for(PRF__c prf : newTrigger){
            if(prf.Sales_Org_Key__c == NULL){
                uid.add(prf.CreatedById);
                system.debug('Adding Key! ' + uid);
            }
        }
        if(uid.size() > 0){
            for(Contract_User__c cu : [SELECT User__r.Id, Active_Sales_Org_Key__c
                                       FROM Contract_User__c
                                       WHERE User__r.Id = :uid])
            {
                soMap.put(cu.User__r.Id, cu.Active_Sales_Org_Key__c);
            }

        }

        for(PRF__c prf : newTrigger){
            if(prf.Sales_Org_Key__c == NULL){
                prf.Sales_Org_Key__c = soMap.get(prf.CreatedById);
                system.debug('Fixed the Key! ' + soMap.get(prf.CreatedById));
            }
        }

    }

    //get gross margin %
    //public Map<Id,Decimal> getMargins(List<PRF_Line_Item__c> lineItemsObj){
    public Map<Id,Decimal> getMargins(List<PRF_Line_Item__c> lineItems){
        String strurl = ApexPages.currentPage().getUrl();
        strurl = strurl.split('apex/')[1];
        system.debug('strurl getMargins *** ' + strurl);
        /*List<String> lineItemIds = new List<String>();
        for(PRF_Line_Item__c curr : lineItemsObj){
            lineItemIds.add(curr.Id);
        }
        
        List<Prf_Line_Item__c> lineItems = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Description, Eligible_Price__c, Material_Name_Text__c,
                                      Current_Price__c, Sales_Deal_Num__c, Sales_Deal_Description__c, Condition__c, Objective_Name__c, Material_Name__r.Distribution_Channel__c,
                                      List_Price__c, Rep_Price__c, RSM_Price__c, CurrencyIsoCode, Requested_Price__c, Material_Name__r.Sales_Org__c,Director_Price__c, Floor_Price__c,
                                      Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, Product_Description__c, Material_Name__r.Transfer_Price__c, Material_Name__r.Cost_Price_Unit__c,
                                      Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Material_Name__r.Director_Price__c, Material_Name__r.Cost__c, Cost__c,
                                      Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c,Material_Name__r.SubGroup__c,
                                      Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Floor_Price__c, Material_Name__r.Brand__c, Material_Status__c,Material_Name__r.Class__c,
                                      Material_Name__r.Cost_Formula__c, Material_Name__r.ASK_Custom_Kit__c, Material_Status_Description__c, Material_Name__r.SearchableProducts__c,
                                      Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Sales_Deal__r.Pricing_Tier__c, Sales_Deal__r.Agreement_Number__c,
                                      Requested_Pricing__r.Parent_Contract_Name__c, Requested_Pricing__r.Agreement_Number__c, Requested_Pricing__r.Description__c,
                                      Material_Name__r.VP_Price__c, PRF__r.Business_Unit__c
                                      FROM PRF_Line_Item__c
                                      WHERE Id IN :lineItemIds];*/
        
        if(strurl.containsIgnoreCase('PP_ApprovalLayout')){
            system.debug('lineItems getMargins: ' + lineItems);

            if(lineItems.size()>0 ){

                for(PRF_Line_Item__c curr : lineItems){
                    System.debug('*** In getMargins for Loop ***');
                    System.debug('*** curr.Material_Name__r.Cost__c getMargins PP_PRF *** ' + curr.Material_Name__r.Cost__c);
                    if(curr.Material_Name__r.Cost__c != NULL && curr.Material_Name__r.Cost__c != 0.00){
                        system.debug('*** In getMargins curr.Material_Name__r.Cost__c != NULL && curr.Material_Name__r.Cost__c != 0.00 check ***');
                        Decimal myDecimal;
                        if(curr.Requested_Price__c == 0 || curr.Requested_Price__c == 0.00){
                            myDecimal = 0.01;
                        }
                        else{
                            myDecimal = curr.Requested_Price__c;
                        }
                        //system.debug('curr.Sales_Price__c ' + curr.Sales_Price__c);
                        Decimal grossMargin = 0;
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
                            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, myDecimal + ' Sales Price can not be 0.  Please enter a price other than 0...'));
                        }
                        else{
                            grossMargin = ((myDecimal - newCost)/(myDecimal)).setScale(3) *100;
                            grossMargin = grossMargin.stripTrailingZeros();
                            system.debug('curr.Id getMargins *** ' + curr.Id);
                            system.debug('grossMargin getMargins *** ' + grossMargin);
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
    public Map<Id,String> getPriceCheck(List<PRF_Line_Item__c> lineItems){
      system.debug('*** PRICE CHECK ***');
      String strurl = ApexPages.currentPage().getUrl();
      strurl = strurl.split('apex/')[1];
      system.debug('strurl *** ' + strurl);

      if(strurl.containsIgnoreCase('PP_ApprovalLayout')){
        String check = ' - ';
        Integer convUnit = 1000;
        system.debug('lineItems: ' + lineItems);

        if(lineItems.size()>0 ){

            for(PRF_Line_Item__c curr : lineItems){
              system.debug('requested price = ' + curr.Requested_Price__c);
              system.debug('Rep price = ' + curr.Rep_Price__c);
              system.debug('RSM price = ' + curr.RSM_Price__c);
              system.debug('Floor price = ' + curr.Material_Name__r.Floor_Price__c);
              system.debug('Director price = ' + curr.Material_Name__r.Director_Price__c);
              system.debug('eligible price = ' + curr.Eligible_Price__c);
              system.debug('Sales_deal_Description__c = ' + curr.Sales_deal_Description__c);

              if(curr.Requested_Price__c == NULL){
                check = '';
                //break;
              }
              else if(curr.Requested_Price__c != curr.Eligible_Price__c && curr.Sales_deal_Description__c != NULL){
                check = 'On Contract';
                //break;
              }
              else if(curr.Requested_Price__c < curr.Material_Name__r.Cost_Formula__c && curr.Requested_Price__c != NULL){
                check = 'Below Cost';
                //break;
              }
              else if(curr.Requested_Price__c < curr.Material_Name__r.Floor_Price__c && curr.Material_Name__r.Floor_Price__c != NULL){
                check = 'Below Floor';
                //break;
              }
              else if(curr.Requested_Price__c < curr.Material_Name__r.Director_Price__c && curr.Material_Name__r.Director_Price__c != NULL){
                check = 'Below Director';
                //break;
              }
              else if(curr.Requested_Price__c < curr.RSM_Price__c && curr.RSM_Price__c != NULL){
                check = 'Below RSM';
                //break;
              }
              else if(curr.Requested_Price__c < curr.Rep_Price__c && curr.Rep_Price__c != NULL){
                check = 'Below Rep';
                //break;
              }
              else if(curr.Requested_Price__c > curr.List_Price__c && curr.List_Price__c != NULL){
                check = 'Above Hospital List';
                //break;
              }
              else if(curr.Requested_Price__c > curr.Material_Name__r.Distributor_List__c && curr.Material_Name__r.Distributor_List__c != NULL){
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
      }//end if page check
      else{
        return null;
      }

    }
    //end of price check

    //get min contract price
    public Map<Id,Decimal> getMinContract(List<PRF_Line_Item__c> lineItems){

      String strurl = ApexPages.currentPage().getUrl();
      strurl = strurl.split('apex/')[1];
      system.debug('strurl getMinContract *** ' + strurl);

      if(strurl.containsIgnoreCase('PP_ApprovalLayout')){
        system.debug('lineItems: ' + lineItems);
        List<String> getIds = new List<String>();

        for(PRF_Line_Item__c curr : lineItems){
          getIds.add(curr.Material_Name__c);
        }

        system.debug('getIds getMinContract *** ' + getIds);

        Map<Id,Product2> prodMap = new Map<Id,Product2>([Select Id,
                                (Select Price__c From Contract_Material__r Order by Price__c ASC NULLS Last LIMIT 1)
                                From Product2 WHERE Id IN :getIds AND Sales_Org_key__c =: prf.Sales_Org_key__c]);

        if(prodMap.size() > 0){
          system.debug('prodMap ***** ' + prodMap);
          system.debug('prodMap keyset ***** ' + prodMap.keySet());
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
          return null;
        }
        return minContract;
      }//end if page check
      else{
        return null;
      }

    }
    //end of min contract price

    //get min contract agreement
    public Map<Id,String> getMinContractAgree(List<PRF_Line_Item__c> lineItems){

      String strurl = ApexPages.currentPage().getUrl();
      strurl = strurl.split('apex/')[1];
      system.debug('strurl getMinContractAgree *** ' + strurl);

      if(strurl.containsIgnoreCase('PP_ApprovalLayout')){
        system.debug('lineItems getMinContractAgree: ' + lineItems);
        List<String> getIds = new List<String>();

        for(PRF_Line_Item__c curr : lineItems){
          getIds.add(curr.Material_Name__c);
        }

        system.debug('getIds getMinContractAgree *** ' + getIds);
        
        Map<Id,Product2> prodMap = new Map<Id,Product2>();
        if(getIds.size()>0){
            prodMap = new Map<Id,Product2>([Select Id,
                                    (Select Agreement__r.Description__c From Contract_Material__r Order by Price__c ASC NULLS Last LIMIT 1)
                                    From Product2 WHERE Id IN :getIds AND Sales_Org_key__c =: prf.Sales_Org_key__c]);
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
        else{
          return null;
        }

        return minContractAgree;
      }//end if page check
      else{
        return null;
      }

    }
    //end of min contract agreement

    //get min gpo price
    public Map<Id,Decimal> getMinGpo(List<PRF_Line_Item__c> lineItems){

      String strurl = ApexPages.currentPage().getUrl();
      strurl = strurl.split('apex/')[1];
      system.debug('strurl getMinGpo *** ' + strurl);

      if(strurl.containsIgnoreCase('PP_ApprovalLayout')){
        system.debug('lineItems: ' + lineItems);
        List<String> getIds = new List<String>();

        for(PRF_Line_Item__c curr : lineItems){
          getIds.add(curr.Material_Name__c);
        }

        system.debug('getIds getMinGpo *** ' + getIds);

        Map<Id,Product2> prodMap = new Map<Id,Product2>([Select Id,
                                (Select Price__c From Contract_Material__r
                                WHERE Agreement__r.Owner__c LIKE '%GPO%' AND Price__c != NULL Order by Price__c ASC NULLS Last LIMIT 1)
                                From Product2 WHERE Id IN :getIds AND Sales_Org_key__c =: prf.Sales_Org_key__c]);

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
        else{
          return null;
        }
        system.debug('minGpo.size() getMinGpo *** ' + minGpo.size());
        return minGpo;
      }//end if page check
      else{
        return null;
      }

    }
    //end of min gpo price

    //get min gpo agreement
    public Map<Id,String> getMinGpoAgree(List<PRF_Line_Item__c> lineItems){

      String strurl = ApexPages.currentPage().getUrl();
      strurl = strurl.split('apex/')[1];
      system.debug('strurl getMinGpoAgree *** ' + strurl);

      if(strurl.containsIgnoreCase('PP_ApprovalLayout')){
        system.debug('lineItems getMinGpoAgree: ' + lineItems);
        List<String> getIds = new List<String>();

        for(PRF_Line_Item__c curr : lineItems){
          getIds.add(curr.Material_Name__c);
        }

        system.debug('getIds getMinGpoAgree *** ' + getIds);

        Map<Id,Product2> prodMap = new Map<Id,Product2>([Select Id,
                                (Select Agreement__r.Description__c From Contract_Material__r
                                WHERE Agreement__r.Owner__c LIKE '%GPO%' Order by Price__c ASC NULLS Last LIMIT 1)
                                From Product2 WHERE Id IN :getIds AND Sales_Org_key__c =: prf.Sales_Org_key__c]);

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
        else{
          return null;
        }

        return minGpoAgree;
      }//end if page check
      else{
        return null;
      }

    }
    //end of min gpo agreement

      //Approve Method for PP_ApprovalLayoutPrf page (click Approve button)
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
                     WHERE ProcessInstance.TargetObjectId =:prf.Id AND ActorId =:UserInfo.getUserId() ];

          //condition handles situation for unanimous approval
          System.debug('*** workList.size() *** ' + workList.size() );
          System.debug('*** workList *** ' + workList);
          if( workList.size() > 0 ){
            System.debug('*** Not a Contracts Person ***');
            retVal = workList[0].Id;
            approverId = workList[0].ActorId;
          }
          else{
            //check for Contracts Team Queue
            System.debug('*** Contracts Person ***');
            workListCheck = [Select Id, ActorId, OriginalActorId, OriginalActor.Name
                             FROM ProcessInstanceWorkitem
                             WHERE ProcessInstance.TargetObjectId =:prf.Id AND Actor.Name = 'Contracts Team'];

            if( workListCheck.size() > 0 ){
              System.debug('*** In Contracts Check ***');
              //get Contracts Team Member User Id
              String contractUserId = [SELECT UserOrGroupId
                                      FROM GroupMember
                                      WHERE Group.Name = 'Contracts Team'
                                      AND UserOrGroupId =:UserInfo.getUserId() LIMIT 1].UserOrGroupId;

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
            System.debug('*** Submitting Approval Response ***');
            System.debug('*** retVal *** ' + retVal);
            System.debug('*** approverId *** ' + approverId);
            //System.debug('*** retVal *** ' + retVal);
            req.setWorkitemId(retVal);
            Approval.ProcessResult result =  Approval.process(req);
          }

          PageReference approvalPage = new Pagereference('/apex/PP_Prf?id='+prf.Id).setRedirect(true);
          return approvalPage ;
      }//end off custom Approval (used on PP_ApprovalLayout page)

      //Reject Method for PP_ApprovalLayoutPrf page (click Reject button)
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
                  WHERE ProcessInstance.TargetObjectId =:prf.Id AND ActorId =:UserInfo.getUserId() ];

       //condition handles situation for unanimous approval
       if( workList.size() > 0 ){
         retVal = workList[0].Id;
         approverId = workList[0].ActorId;
       }
       else{
         //check for Contracts Team Queue
         workListCheck = [Select Id, ActorId, OriginalActorId, OriginalActor.Name
                          FROM ProcessInstanceWorkitem
                          WHERE ProcessInstance.TargetObjectId =:prf.Id AND Actor.Name = 'Contracts Team'];

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

       PageReference approvalPage = new Pagereference('/apex/PP_Prf?id='+prf.Id).setRedirect(true);
       return approvalPage ;
     }//end of custom reject

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
                             WHERE ProcessInstance.TargetObjectId =:ApexPages.currentPage().getParameters().get('Id')
                             ORDER BY CreatedDate ASC];

             return approvalInfo;
         }
         catch(Exception e){
             return null;
         }

     }//end of getApprovalInfo

     //format currency for different locales
     public Map<Id,String> getFormatListPrices(List<PRF_Line_Item__c> lineItems){
       System.debug('*** IN getFormatListPrices *** ');
         Decimal formDec;
         String newDec;
         for(Prf_Line_Item__c curr : lineItems){
           System.debug('*** curr.Id *** ' + curr.Id);
             if(userLocale != 'en_US'){
                 System.debug('*** userLocale *** ' + userLocale);
                 formDec = curr.List_Price__c;
                 newDec = formDec.format();
                 formatListPrices.put(curr.Id,newDec);
             }
             else{
                 newDec = String.valueOf(curr.List_Price__c);
                 formatListPrices.put(curr.Id,newDec);
             }
         }
         System.debug('*** formatListPrices *** ' + formatListPrices);
         return formatListPrices;
     }//end of getFormatListPrices

     //format currency for different locales
     public Map<Id,String> getFormatRsmPrices(List<Prf_Line_Item__c> lineItems){
       System.debug('*** IN getFormatRsmPrices *** ');
         Decimal formDec;
         String newDec;
         for(Prf_Line_Item__c curr : lineItems){
           System.debug('*** curr.Id *** ' + curr.Id);
             if(userLocale != 'en_US'){
                 System.debug('*** userLocale *** ' + userLocale);
                 formDec = curr.Rsm_Price__c;
                 newDec = formDec.format();
                 formatRsmPrices.put(curr.Id,newDec);
             }
             else{
                 newDec = String.valueOf(curr.Rsm_Price__c);
                 formatRsmPrices.put(curr.Id,newDec);
             }
         }
         System.debug('*** formatRsmPrices *** ' + formatRsmPrices);
         return formatRsmPrices;
     }//end of getFormatRsmPrices

     //format currency for different locales
     public Map<Id,String> getFormatRepPrices(List<Prf_Line_Item__c> lineItems){
       System.debug('*** IN getFormatRepPrices *** ');
         Decimal formDec;
         String newDec;
         for(Prf_Line_Item__c curr : lineItems){
           System.debug('*** curr.Id *** ' + curr.Id);
             if(userLocale != 'en_US'){
                 System.debug('*** userLocale *** ' + userLocale);
                 formDec = curr.Rep_Price__c;
                 newDec = formDec.format();
                 formatRepPrices.put(curr.Id,newDec);
             }
             else{
                 newDec = String.valueOf(curr.Rep_Price__c);
                 formatRepPrices.put(curr.Id,newDec);
             }
         }
         System.debug('*** formatRepPrices *** ' + formatRepPrices);
         return formatRepPrices;
     }//end of getFormatRepPrices

     //format currency for different locales
     public Map<Id,String> getFormatEligiblePrices(List<Prf_Line_Item__c> lineItems){
       System.debug('*** IN getFormatEligiblePrices *** ');
         Decimal formDec;
         String newDec;
         for(Prf_Line_Item__c curr : lineItems){
           System.debug('*** curr.Id *** ' + curr.Id);
             if(userLocale != 'en_US'){
                 System.debug('*** userLocale *** ' + userLocale);
                 formDec = curr.Eligible_Price__c;
                 newDec = formDec.format();
                 formatEligiblePrices.put(curr.Id,newDec);
             }
             else{
                 newDec = String.valueOf(curr.Eligible_Price__c);
                 formatEligiblePrices.put(curr.Id,newDec);
             }
         }
         System.debug('*** formatEligiblePrices *** ' + formatEligiblePrices);
         return formatEligiblePrices;
     }//end of getFormatEligiblePrices

     //format currency for different locales
     public Map<Id,String> getFormatRequestedPrices(List<Prf_Line_Item__c> lineItems){
       System.debug('*** IN getFormatRequestedPrices *** ');
         Decimal formDec;
         String newDec;
         for(Prf_Line_Item__c curr : lineItems){
           System.debug('*** curr.Id *** ' + curr.Id);
             if(userLocale != 'en_US'){
                 System.debug('*** userLocale *** ' + userLocale);
                 formDec = curr.Requested_Price__c;
                 newDec = formDec.format();
                 formatRequestedPrices.put(curr.Id,newDec);
             }
             else{
                 newDec = String.valueOf(curr.Requested_Price__c);
                 formatRequestedPrices.put(curr.Id,newDec);
             }
         }
         System.debug('*** formatRequestedPrices *** ' + formatRequestedPrices);
         return formatRequestedPrices;
     }//end of getFormatRequestedPrices

     //method to clone quote
     public Pagereference doCloning() {
       system.debug('*** IN doCloning method PRF ***');
         //String cloneType = Apexpages.currentpage().getParameters().get('cloneType');
         String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
         Savepoint sp = Database.setSavepoint();
         PageReference newPage = null;
         Prf__c clonedPrf = new Prf__c();
         List<Prf_Line_Item__c> lstPrfLines = new List<Prf_Line_Item__c>();
         List<Prf_Line_Item__c> newLines = new List<Prf_Line_Item__c>();

         try {
           System.debug('*** CLONING PRF ***');
           clonedPrf = prf.clone(false,false,false,false);
           clonedPrf.OwnerId = UserInfo.getUserId();
           insert clonedPrf;

         }catch (Exception ex) {
             Database.rollback(sp);
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
         }

         try{
           if(clonedPrf != NULL){
             System.debug('*** GETTING PRF LINE ITEMS FROM OLD PRF ***');
             lstPrfLines = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Description, Eligible_Price__c, Prf__c,
                           Current_Price__c, Sales_Deal_Num__c, Sales_Deal_Description__c, Condition__c, Objective_Name__c, Material_Name__r.Distribution_Channel__c,
                           List_Price__c, Rep_Price__c, RSM_Price__c, CurrencyIsoCode, Requested_Price__c, Material_Name__r.Sales_Org__c,Director_Price__c, Floor_Price__c,
                           Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, Product_Description__c, Material_Name__r.Transfer_Price__c, Material_Name__r.Cost_Price_Unit__c,
                           Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Material_Name__r.Director_Price__c, Material_Name__r.Cost__c, Cost__c,
                           Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c,Material_Name__r.SubGroup__c,
                           Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Floor_Price__c, Material_Name__r.Brand__c, Material_Status__c,Material_Name__r.Class__c,
                           Material_Name__r.Cost_Formula__c, Material_Name__r.ASK_Custom_Kit__c, Material_Status_Description__c, Material_Name__r.SearchableProducts__c
                           FROM PRF_Line_Item__c
                           WHERE PRF__c = :prf.Id];
             }

             PRF_Line_Item__c clonedLine = new PRF_Line_Item__c();

             if( lstPrfLines.size() > 0){

               for(Prf_Line_Item__c p : lstPrfLines){
                 clonedLine = p.clone(false,false,false,false);
                 clonedLine.PRF__c = clonedPrf.Id;
                 newLines.add(clonedLine);
               }
               System.debug('*** Inserting New Line Items to Cloned PRF ***');
               Database.insert(newLines,false);
             }


           if(clonedPrf != NULL){
             System.debug('*** Redirecting to new Cloned PRF ***');
             newPage = new Pagereference('/apex/PP_Prf?refresh=yes&Id='+clonedPrf.Id).setRedirect(True);
             return newPage;
           }
         }catch(Exception ex){
             Database.rollback(sp);
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
         }

         return newPage;
     }
     //end of method to clone PRF

}//end of class