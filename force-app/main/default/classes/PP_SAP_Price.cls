/*********************************************************************
* Description     : This class is used for handling Pricing Logic when
add line items from PP_Price_Quote Page.
* Author          : Dun Silver
* Test Class      : PP_SAP_Price_Test, PP_Global_Test_Class
**********************************************************************/
global without sharing class PP_SAP_Price {
    
    //getter setter to get user role (used for Customer Service Rebate Only Change)
    /*
    Public String userRole {get{
        try{
            User u = [SELECT Id, UserRole.Name FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
            
            userRole = u.UserRole.Name;
            return userRole;
        }
        catch(Exception e){
            userRole = '';
            return userRole;
        }
    }set;}
    */
    public string status{get;set;}
    Public Boolean userRoleBoolean {get;set;}
    public Map<String, String> cMap = new Map<String, String>();
    
    //Variable used in pricing logic to determine userType
    //Move to the Constructor
    /*Public Boolean userRoleBoolean {get{
        User u = [SELECT Id, UserRole.Name FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        String userRole = u.UserRole.Name;
        
        if(Test.isRunningTest() && userRole == NULL){
            userRole = 'Teleflex Global IT';
        }
        
        if(userRole.containsIgnoreCase('Customer Service') ){
            return TRUE;
        }
        else{
            return FALSE; 
        }
    }set;}*/
    
    public static List<Sales_Orgs__c> soList;
    static{
        soList = [SELECT Id,Name, Sales_Org__c, Distribution_Channel__c, Pricing_Type__c, Active__c FROM Sales_Orgs__c WHERE Active__c = true];
    }
    
    //Variable used in pricing logic to determine list price
    Public Map<String,Sales_Orgs__c> soMap {get{
        Map<String,Sales_Orgs__c> soMapNew = new Map<String,Sales_Orgs__c>();
        //List<Sales_Orgs__c> soList = [SELECT Id,Name, Sales_Org__c, Distribution_Channel__c, Pricing_Type__c, Active__c FROM Sales_Orgs__c WHERE Active__c = true];
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
    }set;}
    
    public string userRoleName{get;set;} //using to check role for EMEA
    //Start Constructor
    public PP_SAP_Price(){
        //Variable used in pricing logic to determine userType
        User u = [SELECT Id, UserRole.Name FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        String userRole = u.UserRole.Name;
        userRoleName = u.UserRole.Name; //added for logic for EMEA

        if(Test.isRunningTest() && userRole == NULL){
            userRole = 'Teleflex Global IT';
        }
        
        if(userRole.containsIgnoreCase('Customer Service') ){
            userRoleBoolean= TRUE;
        }
        else{
            userRoleBoolean= FALSE; 
        }
        
        //Map of Sales_Condition_Mapping__c to avoid repetitive SOQl Queries
        for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
            cMap.put(scm.Name, scm.Mapped_Value__c);
        }
        system.debug('cMap ============== getSAPpriceBulk ' + cMap);
    }
    
    //method for Alt Care approval process routing
    Public void lineClassCheck(Id objId){
        Integer countClass = 0;
        String className = '';
        Set<String> checkSet = new Set<String>();
        List<Price_Quote__c> updQuote = new List<Price_Quote__c>();
        
        List<Price_Quote_Line_Item__c> lineItems = [Select Id, Material_Name__r.Class__c, Price_Quote__c, Price_Quote__r.BusinessUnit__c
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c = :objId];
        
        if(lineItems.size() > 0){
            for(Price_Quote_Line_Item__c curr : lineItems){
                checkSet.add(curr.Material_Name__r.Class__c);
            }
            
            //system.debug('checkSet *** ' + checkSet);
            //checkSet.addAll(lineItems);
            if(checkSet.contains('Anesthesia') && checkSet.contains('Respiratory')){
                countClass = 3;
            }
            else if(checkSet.contains('Anesthesia') && !checkSet.contains('Respiratory')){
                countClass = 1;
            }
            else if(!checkSet.contains('Anesthesia') && checkSet.contains('Respiratory')){
                countClass = 2;
            }
            else if(checkSet.contains('Chest Drainage') ){
                className = 'Chest Drainage';
            }
            else{
                countClass = 3;
                className = '';
            }
            
            Price_Quote__c pq = new Price_Quote__c(id=objId, Product_Class_Count__c = countClass, Line_Item_Class__c = className);
            updQuote.add(pq);
            if(updQuote.size()>0)
                update updQuote;
        }//end outter if
        else{
            
            List<PRF__c> updPrf = new List<PRF__c>();
            
            List<PRF_Line_Item__c> prflineItems = [Select Id, Material_Name__r.Class__c, PRF__c,Material_Name__r.Brand_Name__c
                                                   FROM PRF_Line_Item__c
                                                   WHERE PRF__c = :objId];
            
            if(prflineItems.size() > 0){
                for(PRF_Line_Item__c curr : prflineItems){
                    checkSet.add(curr.Material_Name__r.Class__c);
                }
                
                //system.debug('checkSet *** ' + checkSet);
                //checkSet.addAll(lineItems);
                if(checkSet.contains('Anesthesia') && checkSet.contains('Respiratory')){
                    countClass = 3;
                }
                else if(checkSet.contains('Anesthesia') && !checkSet.contains('Respiratory')){
                    countClass = 1;
                }
                else if(!checkSet.contains('Anesthesia') && checkSet.contains('Respiratory')){
                    countClass = 2;
                }
                else if(checkSet.contains('Chest Drainage') ){
                    className = 'Chest Drainage';
                }
                else{
                    countClass = 3;
                    className = '';
                }
                
                //System.debug('*** className *** ' + className);
                PRF__c prf = new PRF__c(id=objId, Product_Class_Count__c = countClass, Line_Item_Class__c = className);
                updPrf.add(prf);
                if(updPrf.size()>0)
                    update updPrf;
            }//end lineitem size check
            
        }//end else
        
    }//end of lineClassCheck
    
    //method for Anesthesia Approval routing
    Public void lineProdCheckAnes(Id objId){
        Integer countClass = 0;
        Set<String> checkSet = new Set<String>();
        Set<String> lmaCheckSet = new Set<String>();
        Set<String> checkSet2 = new Set<String>();
        Set<String> isoCheckSet = new Set<String>();
        List<Price_Quote__c> updQuote = new List<Price_Quote__c>();
        
        List<Price_Quote_Line_Item__c> lineItems = [Select Id, Material_Name__r.Class__c, Price_Quote__c, Material_Name__r.SubGroup__c, Material_Name__r.Brand_Name__c,
                                                    Material_Name__r.Description, Price_Quote__r.BusinessUnit__c,Material__c  FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c = :objId];
        
        if(lineItems.size() > 0){
            String myDesc = '';
            for(Price_Quote_Line_Item__c curr : lineItems){
                if(curr.Material_Name__c!=null){
                    myDesc = curr.Material_Name__r.Description;
                    system.debug('curr.Material_Name__r.SubGroup__c *** ' + curr.Material_Name__r.SubGroup__c);
                    system.debug('curr.Material_Name__r.Brand_Name__c *** ' + curr.Material_Name__r.Brand_Name__c);
                    system.debug('myDesc *** ' + myDesc);
                    if(curr.Material_Name__r.SubGroup__c == 'LMA Atomizers'){
                        lmaCheckSet.add(curr.Material_Name__r.SubGroup__c);
                    }
                    else if(curr.Material_Name__r.Brand_Name__c == 'Hudson RCI' && (myDesc.contains('ISO-GARD') || myDesc.contains('ISO - GARD') ) ){
                        isoCheckSet.add(curr.Material_Name__r.Description);
                    }
                    else{
                        checkSet.add(curr.Material_Name__r.SubGroup__c);
                    }
                }
            }//end of for loop
            
            system.debug('checkSet *** ' + checkSet);
            system.debug('lmaCheckSet *** ' + lmaCheckSet);
            system.debug('isoCheckSet *** ' + isoCheckSet);
            //Set<String> productList = new Set<String>{'LMA Atomizers'};
            //checkSet.addAll(lineItems);
            if(lmaCheckSet.IsEmpty() && isoCheckSet.IsEmpty() ){//if product is LMA Atomizers (check SubGroup__c)
                countClass = 1;
            }
            else if( (!lmaCheckSet.IsEmpty() || !isoCheckSet.IsEmpty() ) && checkSet.IsEmpty()){ //if product is Hudson RCI ISO-Gard (check Brand_Name__c for Hudson and Description for ISO-GARD)
                countClass = 2;
            }
            else if( (!lmaCheckSet.IsEmpty() || !isoCheckSet.IsEmpty() ) && !checkSet.IsEmpty() ){//if quote contains both
                countClass = 3;
            }
            else{//cover all bases
                countClass = 1;
            }
            
            Price_Quote__c pq = new Price_Quote__c(id=objId, Product_Class_Count__c = countClass);
            updQuote.add(pq);
            if(updQuote.size()>0)
                update updQuote;
        }//end outter if
        else{
            
            List<PRF__c> updPrf = new List<PRF__c>();
            
            List<PRF_Line_Item__c> prflineItems = [Select Id, Material_Name__r.Class__c, PRF__c, Material_Name__r.Description, Material_Name__r.SubGroup__c,Material_Name__r.Brand_Name__c
                                                   FROM PRF_Line_Item__c
                                                   WHERE PRF__c = :objId];
            
            if(prflineItems.size() > 0){
                String myDesc = '';
                for(PRF_Line_Item__c curr : prflineItems){
                    if(curr.Material_Name__c!=null){
                        myDesc = curr.Material_Name__r.Description;
                        if(curr.Material_Name__r.SubGroup__c == 'LMA Atomizers'){
                            lmaCheckSet.add(curr.Material_Name__r.SubGroup__c);
                        }
                        else if(curr.Material_Name__r.Brand_Name__c == 'Hudson RCI' && (myDesc.contains('ISO-GARD') || myDesc.contains('ISO - GARD') ) ){
                            isoCheckSet.add(curr.Material_Name__r.Description);
                        }
                        else{
                            checkSet.add(curr.Material_Name__r.SubGroup__c);
                        }
                    }
                }
                
                system.debug('checkSet *** ' + checkSet);
                system.debug('lmaCheckSet *** ' + lmaCheckSet);
                system.debug('isoCheckSet *** ' + isoCheckSet);
                //Set<String> productList = new Set<String>{'LMA Atomizers'};
                //checkSet.addAll(lineItems);
                if(lmaCheckSet.IsEmpty() && isoCheckSet.IsEmpty() ){//if product is LMA Atomizers (check SubGroup__c)
                    countClass = 1;
                }
                else if( (!lmaCheckSet.IsEmpty() || !isoCheckSet.IsEmpty() ) && checkSet.IsEmpty()){ //if product is Hudson RCI ISO-Gard (check Brand_Name__c for Hudson and Description for ISO-GARD)
                    countClass = 2;
                }
                else if( (!lmaCheckSet.IsEmpty() || !isoCheckSet.IsEmpty() ) && !checkSet.IsEmpty() ){//if quote contains both
                    countClass = 3;
                }
                else{//cover all bases
                    countClass = 1;
                }
                
                PRF__c prf = new PRF__c(id=objId, Product_Class_Count__c = countClass);
                updPrf.add(prf);
                if(updPrf.size()>0)
                    update updPrf;
            }//end lineitem size check
            
        }//end else
        
    }//end of lineProdCheckAnes
    
    
    //Start Product Class check for Canada
    Public void lineProdCheckIcap(Id objId){
        
        Integer countClass = 0;
        Set<String> class2526 = new Set<String>();
        Set<String> class25 = new Set<String>();
        Set<String> class26 = new Set<String>();
        
        List<Price_Quote__c> updQuote = new List<Price_Quote__c>();
        
        List<Price_Quote_Line_Item__c> lineItems = [Select Id, Material_Name__r.Class__c, Price_Quote__c, Material_Name__r.SubGroup__c, Price_Quote__r.BusinessUnit__c,
                                                    Material_Name__r.Brand_Name__c, Material_Name__r.Description, Material_Name__r.Product_Class__c, Material__c 
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c = :objId];
        
        if(lineItems.size() > 0){
            String myDesc = '';
            for(Price_Quote_Line_Item__c curr : lineItems){
                if(curr.Material_Name__c!=null){
                    myDesc = curr.Material_Name__r.Description;
                    if(curr.Material_Name__r.Product_Class__c == '0025' ){
                        class25.add(curr.Material_Name__r.Product_Class__c);
                    }
                    else if(curr.Material_Name__r.Product_Class__c == '0026' ){
                        class26.add(curr.Material_Name__r.Product_Class__c);
                    }
                }
            }//end of for loop
            
            system.debug('class25 *** ' + class25);
            system.debug('class26 *** ' + class26);
            
            if(class25.size() > 0 ){
                countClass = 0025;
            }
            else if( class26.size() > 0 ){
                countClass = 0026;
            }
            else{
                countClass = 0;
            }
            
            Price_Quote__c pq = new Price_Quote__c(id=objId, Product_Class_Count__c = countClass);
            updQuote.add(pq);
            if(updQuote.size()>0)
                update updQuote;
        }//end outter if
        else{   //start of PRF product line check
            
            List<PRF__c> updPrf = new List<PRF__c>();
            
            List<PRF_Line_Item__c> prflineItems = [Select Id, Material_Name__r.Class__c, PRF__c, Material_Name__r.Description,
                                                   Material_Name__r.SubGroup__c,Material_Name__r.Brand_Name__c, Material_Name__r.Product_Class__c
                                                   FROM PRF_Line_Item__c
                                                   WHERE PRF__c = :objId];
            
            if(prflineItems.size() > 0){
                String myDesc = '';
                for(PRF_Line_Item__c curr : prflineItems){
                    if(curr.Material_Name__c!=null){
                        myDesc = curr.Material_Name__r.Description;
                        if(curr.Material_Name__r.Product_Class__c == '0025' || curr.Material_Name__r.Product_Class__c == '0026'){
                            class2526.add(curr.Material_Name__r.Product_Class__c);
                        }
                    }
                }//end of for loop
                
                system.debug('class2526 *** ' + class2526);
                
                if(class2526.size() > 0 ){//if product is LMA Atomizers (check SubGroup__c)
                    countClass = 2526;
                }
                else{
                    countClass = 0;
                }
                
                PRF__c prf = new PRF__c(id=objId, Product_Class_Count__c = countClass);
                updPrf.add(prf);
                if(updPrf.size()>0)
                    update updPrf;
            }//end lineitem size check
            
        }//end else
        //end
    }
    //End Product Class check for Canada
    
    public List<Contract_Partnership__c> getContractPartnership(String sapSold){
        List<Contract_Partnership__c> cp = [SELECT Sale_to__c, Ship_to__c
                                                  FROM Contract_Partnership__c
                                                  WHERE Ship_to__c =:sapSold
                                                  AND Disabled__c = FALSE]; 
        return cp;   
    }
    
    public List<Contract_Customer__c> getContractCustomer(List<String> cmList, List<String> cnlist){
        List<Contract_Customer__c> cc = [SELECT Agreement__r.Agreement_Number__c, Account__r.SAP_Sold_To__c, Condition__c
                                                           FROM Contract_Customer__c
                                                           WHERE Agreement__r.Agreement_Number__c IN :cmList
                                                           AND Account__r.SAP_Sold_To__c IN :cnlist
                                                           AND Active__c = TRUE
                                                           order by Condition_Rank__c
                                                           LIMIT 10];
        return cc;
    }
    
    //Start New SAP Price Logic
    public void getSAPpriceBulk(List<String> materialStr,String quoteId){
        
        //system.debug('Quote Id getSAPpriceBulk ====================== ' + quoteId);
        //system.debug('materialStr getSAPpriceBulk ======================= ' + materialStr);
        //system.debug('userRoleBoolean getSAPpriceBulk ======================= ' + userRoleBoolean);
        
        List<Price_Quote_Line_Item__c> lineItemList = new List<Price_Quote_Line_Item__c>();
        List<String> newMaterialStr = new List<String>();
        List<String> notInList = new List<String>();
        Set<String> str1 = new Set<String>();
        Set<String> str2 = new Set<String>();
        List<Product2> mcheck = new List<Product2>();
        String soldToType; //Variable to hold Sold To Price List Type
        String shipTo;
        
        str1.addAll(materialStr); //added 1st string to set for comparison later
        
        try{
            Price_Quote__c pq = [SELECT Account_Name__r.SAP_Sold_To__c, Account_Name__r.Account_Group__c, Sales_Org_Key__c, Line_Count__c,
                                 Owner_Business_Unit__c, Account_Name__r.Price_List_Type__c, BusinessUnit__c, CurrencyIsoCode, Type__c
                                 FROM Price_Quote__c
                                 WHERE Id =: quoteId LIMIT 1];
            system.debug('pq getSAPpriceBulk ====================== ' + pq);
            Decimal rowOrder = pq.Line_Count__c;
            
            shipTo = pq.Account_Name__r.Sap_Sold_To__c;
            //adding logic for ASK Agreements
            if(pq.Type__c == 'ASK Agreement'){
                mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c, Floor_Price__c,
                          List_Price__c, RSM_Price__c, Rep_Price__c, Director_Price__c, Description,
                          Product_Description_Custom__c, Material_Status_Numeric__c, Cost_Formula__c, Min_Order_Qty__c,
                          Distributor_List__c, Alt_Site_List__c, MRP_Group__c, SearchableProducts__c, CurrencyIsoCode
                          FROM Product2
                          WHERE Name IN :materialStr
                          AND Sales_Org_Key__c =: pq.Sales_Org_Key__c
                          AND Duplicate__c = FALSE AND ASK_Custom_Kit__c = TRUE];
            }
            else{
                mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c, Floor_Price__c,
                          List_Price__c, RSM_Price__c, Rep_Price__c, Director_Price__c, Description,
                          Product_Description_Custom__c, Material_Status_Numeric__c, Cost_Formula__c, Min_Order_Qty__c,
                          Distributor_List__c, Alt_Site_List__c, MRP_Group__c, SearchableProducts__c, CurrencyIsoCode
                          FROM Product2
                          WHERE Name IN :materialStr
                          AND Sales_Org_Key__c =: pq.Sales_Org_Key__c
                          AND Duplicate__c = FALSE AND SearchableProducts__c = TRUE];
            }
            //end of ASK Agreement logic
                
            //mcheck.remove(NULL);
            system.debug('mcheck.size() getSAPpriceBulk ====================== ' + mcheck.size() );
            //system.debug('mcheck getSAPpriceBulk ====================== ' + mcheck);
            
            
            // Create the Product Mapping
            map<String, Product2> prodmap = new map<String, Product2>();
            for(Product2 pmap : mcheck){
                prodmap.put(pmap.Name, pmap);
                newMaterialStr.add(pmap.Name);
            }
            //system.debug('prodmap getSAPpriceBulk: ' + prodmap);
            
            str2.addAll(newMaterialStr);
            
            for(String s : str1){
                if (!str2.contains(s)){System.debug('*** getSAPpriceBulk ERROR:  Does not contain the string ***');notInList.add(s);}
            }
            
            if(notInList.size() > 0){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The following product(s) where not added to the Price Quote: ' + notInList));}
            
            // Determine which SAP Number to use for Lookup
            string pcn = pq.Account_Name__r.SAP_Sold_To__c;
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
            else{
                soldToType = pq.Account_Name__r.Price_List_Type__c;
            }
			//system.debug('pcn (Primary Customer Number) getSAPpriceBulk ================ ' + pcn);            
            // Start building the line items
            
            // Prospect Account Process (No SAP) #1
            if(pq.Account_Name__r.SAP_Sold_To__c == NULL){
                //system.debug('Starting getPrice without SAP getSAPpriceBulk');
                //system.debug('*** pq.Sales_Org_Key__c right before getSAPpriceBulk 1 *** ' + pq.Sales_Org_Key__c);
                for(String ml : materialStr){
                    if(prodmap.get(ml) != NULL){
                        ++rowOrder;
                        Price_Quote_Line_Item__c  pqLineItem = new Price_Quote_Line_Item__c (
                            Price_Quote__c = pq.Id,
                            Material_Name__c = prodmap.get(ml).Id,
                            Quantity__c = 1,
                            RSM_Price__c = prodmap.get(ml).RSM_Price__c,
                            Rep_Price__c = prodmap.get(ml).Rep_Price__c,
                            Director_Price__c = prodmap.get(ml).Director_Price__c,
                            Floor_Price__c = prodmap.get(ml).Floor_Price__c,
                            Cost__c = prodmap.get(ml).Cost_Formula__c,
                            Material_Status__c = prodmap.get(ml).Material_Status_Numeric__c,
                            Row_Order__c = rowOrder,
                            MRP_Group__c = prodmap.get(ml).MRP_Group__c,
                            CurrencyIsoCode = pq.CurrencyIsoCode
                        );
                        
                        //system.debug('*** pq.Sales_Org_Key__c right before getSAPpriceBulk 2 *** ' + pq.Sales_Org_Key__c);
                        //system.debug('*** soldToType right before getSAPpriceBulk 2 *** ' + soldToType);
                        //logic to handle Hospital, Distributor, and Alt Site pricing
                        if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                               //Alt Site Accounts
                               if(soldToType == 'ZA'){
                                   if(prodmap.get(ml).Alt_Site_List__c != 0.00){
                                       pqLineItem.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                       pqLineItem.Sales_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                       pqLineItem.Eligible_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                   }
                                   else{
                                       pqLineItem.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                       pqLineItem.Sales_Price__c = 0.00;
                                       pqLineItem.Eligible_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                   }
                               }
                               
                               //Distributor Accounts
                               if(soldToType == 'ZD'){
                                   if(prodmap.get(ml).Distributor_List__c != 0.00){
                                       pqLineItem.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                       pqLineItem.Sales_Price__c = prodmap.get(ml).Distributor_List__c;
                                       pqLineItem.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                   }
                                   else{
                                       pqLineItem.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                       pqLineItem.Sales_Price__c = 0.00;
                                       pqLineItem.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                   }
                               }
                               
                               //Hospital Accounts
                               if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                   if(prodmap.get(ml).List_Price__c != 0.00){
                                       pqLineItem.List_Price__c = prodmap.get(ml).List_Price__c;
                                       pqLineItem.Sales_Price__c = prodmap.get(ml).List_Price__c;
                                       pqLineItem.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                   }
                                   else{
                                       pqLineItem.List_Price__c = prodmap.get(ml).List_Price__c;
                                       pqLineItem.Sales_Price__c = 0.00;
                                       pqLineItem.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                   }
                               }
                               //end of logic to handle Hospital, Distributor, and Alt Site pricing
                           }//end of if pq.Sales_Org_Key__c
                        else{
                            //Start of US6020 ZD Pricing Only
                            if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                if(prodmap.get(ml).Distributor_List__c != 0.00){
                                    pqLineItem.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                    pqLineItem.Sales_Price__c = prodmap.get(ml).Distributor_List__c;
                                    pqLineItem.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                }
                                else{
                                    pqLineItem.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                    pqLineItem.Sales_Price__c = 0.00;
                                    pqLineItem.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                }
                            }
                            /*
                            else{
                                //All other Sales Orgs
                                if(prodmap.get(ml).List_Price__c != 0.00){
                                    pqLineItem.List_Price__c = prodmap.get(ml).List_Price__c;
                                    pqLineItem.Sales_Price__c = prodmap.get(ml).List_Price__c;
                                    pqLineItem.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                }
                                else{
                                    pqLineItem.List_Price__c = prodmap.get(ml).List_Price__c;
                                    pqLineItem.Sales_Price__c = 0.00;
                                    pqLineItem.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                }
                            }//end else for pq.Sales_org_Key__c = US6020
                            */
                        }//end of else pq.Sales_Org_Key__c
                        
                        // Check for custom product description. Was specifically for Surgical but now we have Cardiac as well.
                        if(prodmap.get(ml).Product_Description_Custom__c != NULL){
                            pqLineItem.Product_Description__c = prodmap.get(ml).Product_Description_Custom__c;
                        }
                        else{
                            pqLineItem.Product_Description__c = prodmap.get(ml).Description;
                        }
                        
                        lineItemList.add(pqLineItem);
                    }
                    else{
                        //Add line to miss list
                    }
                    
                }
                // DML - Insert Lines
                If(lineItemList.size() > 0){
                    //system.debug('lineItemList getSAPpriceBulk ======================= ' + lineItemList);
                    database.insert(lineItemList,false);
                }
            }//end of NO SAP Code Testing
            else{ // Customer Account Process #2
                system.debug('Starting getPrice with SAP');
                List<SAPRealPriceSet__x> sapList = new List<SAPRealPriceSet__x>();
                List<string> cnlist = new List<String>();
                cnlist.add(pq.Account_Name__r.SAP_Sold_To__c);
                
                system.debug('pcn (Primary Customer Number) getSAPpriceBulk ================ ' + pcn);
                system.debug('cnlist (Customer Number List) getSAPpriceBulk ================= ' + cnlist);
                
                Map<String, String> cMap = new Map<String, String>();
                for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
                    cMap.put(scm.Name, scm.Mapped_Value__c);
                }
                system.debug('cMap ============== getSAPpriceBulk ' + cMap);
                
                Map<String, String> obMap = new Map<String, String>();
                obMap.put('01', 'Direct/Rebate');
                obMap.put('02', 'Direct');
                obMap.put('03', 'Distributor Netbill');
                obMap.put('04', 'Specialty Market');
                obMap.put('05', 'Strategic Accounts');
                obMap.put('06', 'Rebate Only');
                system.debug('obMap ============== getSAPpriceBulk ' + obMap);
                //system.debug('prodmap.size() ============== getSAPpriceBulk ' + prodmap.size() );
                //system.debug('materialStr ============== getSAPpriceBulk ' + materialStr);
                //Start getting SAP info
                for(String ml : materialStr)
                {
                    System.debug('*** IN for(String ml : materialStr) ***');
                    if(prodmap.get(ml) != NULL){
                        System.debug('*** IN if(prodmap.get(ml) != NULL) ***');
                        if(Test.isRunningTest()){
                            system.debug('Test Is Running ============== ' + Test.isRunningTest() );
                            if(pq.Account_Name__r.SAP_Sold_To__c == '999999'){
                                System.debug('*** Test Is Running and SAP Code 999999 ***');
                                SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
                                    SalesDeal__c = '50009064',
                                    Price__c = 0.00,
                                    Material__c = prodmap.get(ml).name,
                                    MtrlStatus__c = '40',
                                    SalesMtrlStatus__c = '40',
                                    ValidFrom__c = Date.Today(),
                                    ValidTo__c = Date.Today() + 1000,
                                    AgrDesc__c = 'Duke University SURGR',
                                    Condition__c = 'XNAF',
                                    OwnerName__c = 'Duke Univ Health System',
                                    Owner__c = 'IDN-032',
                                    AgrObjective__c = '06',
                                    Customer__c  = '0000999999'
                                );
                                sapList.add(testSAP);
                            }//end if sap code check
                            else if(Test.isRunningTest() && pq.Account_Name__r.SAP_Sold_To__c != '999999'){
                                System.debug('*** Test Is Running and SAP Code != 999999 ***');
                                SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
                                    SalesDeal__c = '50009064',
                                    Price__c = 123.00,
                                    Material__c = prodmap.get(ml).name,
                                    MtrlStatus__c = '40',
                                    SalesMtrlStatus__c = '40',
                                    ValidFrom__c = Date.Today(),
                                    ValidTo__c = Date.Today() + 1000,
                                    AgrDesc__c = 'Duke University SURGR',
                                    Condition__c = 'XNAF',
                                    OwnerName__c = 'Duke Univ Health System',
                                    Owner__c = 'IDN-032',
                                    AgrObjective__c = '06',
                                    Customer__c  = '0000'+pq.Account_Name__r.Sap_Sold_To__c
                                );
                                sapList.add(testSAP); 
                            }//end sap code check
                        }//end (Test.isRunningTest())
                        else{
                            System.debug('*** Test Is NOT Running ***');
                            sapList = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c,
                                       ValidFrom__c, ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                       OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                       DistChnl__c, Currency__c, MatDesc__c, VAT__c
                                       FROM SAPRealPriceSet__x
                                       WHERE SalesOrg__c =:prodmap.get(ml).Sales_Org__c
                                       AND DistChnl__c =:prodmap.get(ml).Distribution_Channel__c
                                       AND Customer__c =:pcn
                                       AND ShipTo__c =:shipTo
                                       AND Material__c =:prodmap.get(ml).Name
                                       AND EffDate__c =:datetime.now()
                                      ];
                        }
                        //System.debug('*** sapList Test running getSAPpriceBulk *** ' + sapList);
                        //system.debug('============== ml getSAPpriceBulk ============== ' + ml);
                        //system.debug('============== sapList[0].Price__c getSAPpriceBulk ============== ' + sapList[0].Price__c);
                        //system.debug('============== prodmap.get(ml).Sales_Org__c getSAPpriceBulk ============== ' + prodmap.get(ml).Sales_Org__c);
                        //system.debug('============== prodmap.get(ml).Distribution_Channel__c getSAPpriceBulk ============== ' + prodmap.get(ml).Distribution_Channel__c);
                        //system.debug('============== pcn getSAPpriceBulk ============== ' + pcn);
                        //system.debug('============== prodmap.get(ml).Name getSAPpriceBulk ============== ' + prodmap.get(ml).Name);
                        
                        //************************************* Start Rebate Only Check *******************************************
                        //System.debug('*** sapList getSAPpriceBulk *** ' + sapList);
                        //System.debug('*** sapList[0].AgrObjective__c getSAPpriceBulk *** ' + sapList[0].AgrObjective__c);
                        //System.debug('*** userRole *** ' + userRole);
                        /*
                        * boolean is used to determine the type of user
                        * SF Admins and Commercial Ops Team can view Rebate Only Contracts
                        * Everyone else should not have access
                        */                       
                        //System.debug('*** userRoleBoolean getSAPpriceBulk *** ' + userRoleBoolean);
						//System.debug('*** sapList[0].AgrObjective__c getSAPpriceBulk *** ' + sapList[0].AgrObjective__c);                        
                        if( sapList[0].AgrObjective__c == '06' && userRoleBoolean ){
                            System.debug('*** IN REBATE ONLY CHECK ***');
                            //SAP_1stPick = sapList[0].Agreement_Number__c.right(8);
                            list<String> ccaList = new list<String>();
                            for(Contract_Customer__c cc : [SELECT Agreement__r.Agreement_Number__c
                                                           FROM Contract_Customer__c
                                                           WHERE Account__r.SAP_Sold_To__c IN :cnlist
                                                           AND Agreement__r.Objective__c != '06'
                                                           AND Active__c = TRUE])
                            {
                                ccaList.add(cc.Agreement__r.Agreement_Number__c);
                            }
                            //system.debug('ccalist getSAPpriceBulk:' + ccaList);
                            
                            // Contract Material List - Used to filter the Contract Customers
                            list<String> cmList = new list<String>();
                            // Material Map - Used to filter...
                            map<String, String> matMap = new map<String, String>();
                            for(Contract_Material__c cm : [SELECT Product__r.Name, Agreement__r.Agreement_Number__c, Agreement__r.Sales_Org__c
                                                           FROM Contract_Material__c
                                                           WHERE Product__r.Name IN :materialStr
                                                           AND Agreement_Number__c IN :ccaList
                                                           AND Active__c = TRUE
                                                           ORDER BY Price__c])
                            {
                                cmList.add(cm.Agreement__r.Agreement_Number__c);
                                matMap.put(cm.Agreement__r.Agreement_Number__c, cm.Product__r.Name);
                            }
                            //system.debug('cmList.size getSAPpriceBulk: ' + cmList.size());
                            
                            sapList.remove(0);
                            
                            //**************************** Start Contract Customer Lookup ************************************
                            for(Contract_Customer__c cc : [SELECT Agreement__r.Agreement_Number__c, Account__r.SAP_Sold_To__c, Condition__c
                                                           FROM Contract_Customer__c
                                                           WHERE Agreement__r.Agreement_Number__c IN :cmList
                                                           AND Account__r.SAP_Sold_To__c IN :cnlist
                                                           AND Active__c = TRUE
                                                           order by Condition_Rank__c
                                                           LIMIT 10])
                            {
                                sapList = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c, ValidFrom__c,
                                           ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                           OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                           DistChnl__c, Currency__c, MatDesc__c, VAT__c
                                           FROM SAPRealPriceSet__x
                                           WHERE SalesOrg__c = :prodMap.get(ml).Sales_Org__c
                                           AND DistChnl__c = :prodMap.get(ml).Distribution_Channel__c
                                           AND Agreement__c = :cc.Agreement__r.Agreement_Number__c
                                           AND Customer__c = :cc.Account__r.SAP_Sold_To__c
                                           AND ShipTo__c =:shipTo 
                                           AND Material__c = :matMap.get(cc.Agreement__r.Agreement_Number__c)
                                           AND EffDate__c = :datetime.now()
                                           LIMIT 1 ];
                            }
                            //**************************** End Contract Customer Lookup ************************************
                        }//end of if( sapList[0].AgrObjective__c == '06' && userRoleBoolean )
                            
                        //re-populating sapList if test is running
                        if(Test.isRunningTest()){
                            if(pq.Account_Name__r.SAP_Sold_To__c == '999999'){
                                SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
                                    SalesDeal__c = '50009064',
                                    Price__c = 0.00,
                                    Material__c = prodmap.get(ml).name,
                                    MtrlStatus__c = '40',
                                    SalesMtrlStatus__c = '40',
                                    ValidFrom__c = Date.Today(),
                                    ValidTo__c = Date.Today() + 1000,
                                    AgrDesc__c = 'Duke University SURGR',
                                    Condition__c = 'XNAF',
                                    OwnerName__c = 'Duke Univ Health System',
                                    Owner__c = 'IDN-032',
                                    AgrObjective__c = '06',
                                    Customer__c  = '0000999999'
                                );
                                sapList.add(testSAP);
                            }//end if sap code check
                            else{
                                SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
                                    SalesDeal__c = '50009064',
                                    Price__c = 123.00,
                                    Material__c = prodmap.get(ml).name,
                                    MtrlStatus__c = '40',
                                    SalesMtrlStatus__c = '40',
                                    ValidFrom__c = Date.Today(),
                                    ValidTo__c = Date.Today() + 1000,
                                    AgrDesc__c = 'Duke University SURGR',
                                    Condition__c = 'XNAF',
                                    OwnerName__c = 'Duke Univ Health System',
                                    Owner__c = 'IDN-032',
                                    AgrObjective__c = '06',
                                    Customer__c  = '0000'+pq.Account_Name__r.Sap_Sold_To__c
                                );
                                sapList.add(testSAP); 
                            }//end sap code check
                            
                        }//end (Test.isRunningTest())
                        
						System.debug('*** sapList.size() getSapPriceBulk *** ' + sapList.size() );                            
                        //************************************* Start Rebate Only Check *******************************************
                        for(SAPRealPriceSet__x sap : sapList )
                        {
                            ++rowOrder;
                            //system.debug('sap getSAPpriceBulk: ' + sap);
                            
                            string conremap = sap.Condition__c;
                            if(cMap.get(sap.Condition__c) != NULL){
                                conremap = cMap.get(sap.Condition__c);
                            }
                            //system.debug('conditionMap getSAPpriceBulk: ' + cMap);
                            
                            String salesDeal;
                            if(sap.SalesDeal__c != NULL){
                                //System.debug('*** IN sap.SalesDeal__c != NULL getSAPpriceBulk *** ' + sap.SalesDeal__c);
                                if( sap.AgrObjective__c == '06' && userRoleBoolean ){
                                    //System.debug('*** IN sap.AgrObjective__c == 06 && userRole.containsIgnoreCase(Customer Service) getSAPpriceBulk *** ');
                                    //SAP_1stPick = 'No Contract';
                                    salesDeal = sap.SalesDeal__c.right(8);
                                }
                                else{
                                    //System.debug('*** IN sap.SalesDeal__c != NULL getSAPpriceBulk *** ' + sap.SalesDeal__c);
                                    salesDeal = sap.SalesDeal__c.right(8);
                                    //System.debug('*** In else of 06 check salesDeal getSAPpriceBulk *** ' + salesDeal);
                                }
                                
                            }
                            else{
                                //System.debug('*** salesDeal = No Contract getSAPpriceBulk *** ');
                                salesDeal = 'No Contract';
                            }
                            //system.debug('salesDeal getSAPpriceBulk ================ ' + salesDeal);
                            
                            String mstatus;
                            if(sap.SalesMtrlStatus__c != NULL){
                                mstatus = sap.SalesMtrlStatus__c;
                            }
                            else if(sap.MtrlStatus__c != NULL){
                                mstatus = sap.MtrlStatus__c;
                            }
                            
                            System.debug('*** Final salesDeal check getSAPpriceBulk *** ' + salesDeal);
                            
                            Price_Quote_Line_Item__c  li = new Price_Quote_Line_Item__c (
                                Price_Quote__c = pq.Id,
                                Material_Name__c = prodmap.get(ml).Id,
                                Material_Status__c = mstatus,
                                Quantity__c = 1,
                                CurrencyIsoCode = pq.CurrencyIsoCode,
                                //List_Price__c = prodmap.get(ml).List_Price__c,
                                RSM_Price__c = prodmap.get(ml).RSM_Price__c,
                                Rep_Price__c = prodmap.get(ml).Rep_Price__c,
                                Director_Price__c = prodmap.get(ml).Director_Price__c,
                                Floor_Price__c = prodmap.get(ml).Floor_Price__c,
                                Cost__c = prodmap.get(ml).Cost_Formula__c,
                                Condition__c = conremap,
                                //Sales_Deal_Description__c = sap.AgrDesc__c,
                                Sales_Number__c = salesDeal,
                                Row_Order__c = rowOrder,
                                Objective__c = sap.AgrObjective__c,
                                MRP_Group__c = prodmap.get(ml).MRP_Group__c,
                                Material_Description__c = sap.MatDesc__c,
                                Min_Order_Qty__c = prodmap.get(ml).Min_Order_Qty__c
                            );
                            
                            // Check for custom product description. Was specifically for Surgical but now we have Cardiac as well.
                            if(prodmap.get(ml).Product_Description_Custom__c != NULL){
                                li.Product_Description__c = prodmap.get(ml).Product_Description_Custom__c;
                            }
                            else{
                                li.Product_Description__c = prodmap.get(ml).Description;
                            }
                            
                            //adding check for VAT for EMEA
                            system.debug('****BU*****'+ pq.Businessunit__c);
                            if(pq.Businessunit__c == 'EMEA'){
                                li.Quantity__c = prodmap.get(ml).Min_Order_Qty__c;
                                system.debug('****VAT*****'+ li.VAT__c);
                                li.Material_Description__c=sap.MatDesc__c;
                                li.CurrencyIsoCode = sap.Currency__c;
                                if(sap.VAT__c == NULL){
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

                            // Check for eligible price = 0
                            if(sap.Price__c != 0.00){
                                li.Sales_Price__c = sap.Price__c;
                                li.Eligible_Price__c = sap.Price__c;
                                
                                if(salesDeal == 'No Contract'){
                                    li.Sales_Deal_Description__c = NULL;
                                }
                                else{
                                    System.debug('*** sap.AgrDesc__c getSAPpriceBulk *** ' + sap.AgrDesc__c);
                                    li.Sales_Deal_Description__c = sap.AgrDesc__c;
                                }
                                
                                //start of check for Customer Service Rebate Only
                                //System.Debug('*** sap.AgrObjective__c line 735 getSAPpriceBulk *** ' + sap.AgrObjective__c);
                                //System.Debug('*** userRoleBoolean line 735 getSAPpriceBulk *** ' + userRoleBoolean);
                                //System.Debug('*** userRole line 735 getSAPpriceBulk *** ' + userRole);
                                if(sap.AgrObjective__c == '06' && userRoleBoolean ){
                                    //System.debug('*** salesDeal getSAPpriceBulk *** ' + salesDeal);
                                    //System.debug('*** sap.AgrObjective__c == 06 *** ' + sap.AgrObjective__c + ' userRole: ' + userRole);
                                    //prodQuoteLineItem1.Sales_Price__c = sap.Price__c;
                                    //prodQuoteLineItem1.Eligible_Price__c = sap.Price__c;
                                    li.Sales_Price__c = prodMap.get(ml).List_Price__c;
                                    li.Eligible_Price__c = prodMap.get(ml).List_Price__c;
                                    
                                    if(salesDeal == 'No Contract'){
                                        li.Sales_Deal_Description__c = NULL;
                                    }
                                    else{
                                        System.debug('*** sap.AgrDesc__c getSAPpriceBulk *** ' + sap.AgrDesc__c);
                                        li.Sales_Deal_Description__c = sap.AgrDesc__c;
                                    }
                                    
                                    
                                    if(soldToType == 'ZA'){
                                        System.debug('*** In Alt Site List Pricing for if sap.Price__c != 0.00 getSAPpriceBulk ***');
                                        li.List_Price__c = prodMap.get(ml).Alt_Site_List__c;
                                        li.Sales_Price__c = prodMap.get(ml).Alt_Site_List__c;
                                        li.Eligible_Price__c = prodMap.get(ml).Alt_Site_List__c;
                                    }
                                    
                                    //Distributor Accounts
                                    if(soldToType == 'ZD'){
                                        System.debug('*** In Distributor List Pricing for if sap.Price__c != 0.00 getSAPpriceBulk ***');
                                        li.List_Price__c = prodMap.get(ml).Distributor_List__c;
                                        li.Sales_Price__c = prodMap.get(ml).Distributor_List__c;
                                        li.Eligible_Price__c = prodMap.get(ml).Distributor_List__c;
                                    }
                                    
                                    //Hospital Accounts
                                    if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                        System.debug('*** In Hospital List Pricing for if sap.Price__c != 0.00 getSAPpriceBulk ***');
                                        li.List_Price__c = prodMap.get(ml).List_Price__c;
                                        li.Sales_Price__c = prodMap.get(ml).List_Price__c;
                                        li.Eligible_Price__c = prodMap.get(ml).List_Price__c;
                                    }
                                }
                                //end of check for Customer Service Rebate Only
                                System.debug('*** pq.Sales_Org_Key__c getSapPriceBulk *** ' + pq.Sales_Org_Key__c);
                                //logic to handle Hospital, Distributor, and Alt Site pricing
                                if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                                       //Alt Site Accounts
                                       if(pq.Account_Name__r.Price_List_Type__c == 'ZA'){
                                           li.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                       }
                                       
                                       //Distributor Accounts
                                       if(pq.Account_Name__r.Price_List_Type__c == 'ZD'){
                                           li.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                       }
                                       
                                       //Hospital Accounts
                                       if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                           li.List_Price__c = prodmap.get(ml).List_Price__c;
                                       }
                                       //end of logic to handle Hospital, Distributor, and Alt Site pricing
                                   }//end of if pq.Sales_Org_Key__c
                                else{
                                    if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                        li.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                        li.Sales_Price__c = prodmap.get(ml).Distributor_List__c;
                                        li.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                    }
                                    else{
                                        li.List_Price__c = prodmap.get(ml).List_Price__c;
                                    } 
                                }//end of else pq.Sales_Org_Key__c
                                
                            }//if(sap.Price__c != 0.00)
                            else{
                                //logic to handle Hospital, Distributor, and Alt Site pricing
                                System.debug('*** soldToType getSapPriceBulk *** ' + soldToType);
                                if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                                       //Alt Site Accounts
                                       if(soldToType == 'ZA'){
                                           if(prodmap.get(ml).Alt_Site_List__c != 0.00){
                                               li.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                               li.Sales_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                               li.Eligible_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                           }
                                           else{
                                               li.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                               li.Sales_Price__c = 0.00;
                                               li.Eligible_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                           }
                                       }
                                       
                                       //Distributor Accounts
                                       if(soldToType == 'ZD'){
                                           if(prodmap.get(ml).Distributor_List__c != 0.00){
                                               li.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                               li.Sales_Price__c = prodmap.get(ml).Distributor_List__c;
                                               li.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                           }
                                           else{
                                               li.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                               li.Sales_Price__c = 0.00;
                                               li.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                           }
                                       }
                                       
                                       //Hospital Accounts
                                       if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                           if(prodmap.get(ml).List_Price__c != 0.00){
                                               li.List_Price__c = prodmap.get(ml).List_Price__c;
                                               li.Sales_Price__c = prodmap.get(ml).List_Price__c;
                                               li.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                           }
                                           else{
                                               li.List_Price__c = prodmap.get(ml).List_Price__c;
                                               li.Sales_Price__c = 0.00;
                                               li.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                           }
                                       }
                                       //end of logic to handle Hospital, Distributor, and Alt Site pricing
                                   }//end of if pq.Sales_Org_Key__c
                                else{
                                    //Start of US6020 ZD Pricing Only
                                    if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                        li.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                        li.Sales_Price__c = prodmap.get(ml).Distributor_List__c;
                                        li.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                    }
                                    /*
                                    else{
                                        //All other Sales Orgs
                                        if(prodmap.get(ml).List_Price__c != 0.00){
                                            li.List_Price__c = prodmap.get(ml).List_Price__c;
                                            li.Sales_Price__c = prodmap.get(ml).List_Price__c;
                                            li.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                        }
                                        else{
                                            li.List_Price__c = prodmap.get(ml).List_Price__c;
                                            li.Sales_Price__c = 0.00;
                                            li.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                        }
                                    }//end else for pq.Sales_org_Key__c = US6020
                                    */
                                }//end of else pq.Sales_Org_Key__c
                                
                            }//end of else
                            
                            //add object to list
                            lineItemList.add(li);
                            system.debug('lineItemList ======================== ' + lineItemList);
                        }
                    }
                    else{
                        // Add Material to 'Miss' list
                    }
                }
                
                // DML - Insert Lines
                If(lineItemList.size() > 0){
                    system.debug('lineItemList ======================= ' + lineItemList);
                    database.insert(lineItemList,false);
                    
                    //conditions below helps with Price Quote and PRF Approval Matrix Routing
                    if(pq.BusinessUnit__c == 'Alternate Care'){
                        lineClassCheck(quoteId);
                    }
                    
                    if(pq.BusinessUnit__c == 'Anesthesia'){
                        lineProdCheckAnes(quoteId);
                    }
                    
                    if(pq.BusinessUnit__c == 'Interventional Capital' || pq.BusinessUnit__c == 'Cardiac'){
                        lineProdCheckIcap(quoteId);
                    }
                    
                    if(pq.BusinessUnit__c == 'Surgical Instruments'){
                        lineClassCheck(quoteId);
                    }
                }
            }
            
        }
        catch(Exception e){
            System.debug('=== e === ' + e);
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
        }
        
    }
    //End New SAP Price Logic
    
    //Start New SAP Price Logic w/Cross Reference
    public void getCrossBulk(List<String> crossRef,String quoteId){
        
        //system.debug('userRoleBoolean getCrossBulk ======================= ' + userRoleBoolean);
        
        Map<String,String> crossMap = new  Map<String,String>();
        List<Cross_Reference__c> prodsCross = new List<Cross_Reference__c>();
        List<String> materialStr = new List<String>();
        List<Product2> mcheck = new List<Product2>();
        String soldToType; //Variable to hold Sold To Price List Type
        
        prodsCross = [SELECT Id, Name, Product__r.Name, Competitor_Product_Code__c, Competitor_Product_Description__c, Product__r.Floor_Price__c,
                      TFX_Product__c, Product__c,Competitor_Name__c, Percent_Match__c, Product__r.List_Price__c, Product__r.Director_Price__c,
                      Product__r.Rep_Price__c,Product__r.RSM_price__c,Product__r.Sales_Org__c, Product__r.Distribution_Channel__c, Product__r.Cost_Formula__c,
                      Product__r.Distributor_List__c, Product__r.Alt_Site_List__c
                      FROM Cross_Reference__c
                      WHERE Competitor_Product_Code__c IN :crossRef];
        
        for(Cross_Reference__c curr : prodsCross) {
            materialStr.add(curr.TFX_Product__c);
            crossMap.put(curr.Product__r.Name,curr.Id);
        }
        
        system.debug('Quote Id ====================== ' + quoteId);
        system.debug('materialStr =======================  ' + materialStr);
        system.debug('crossMap =======================  ' + crossMap);
        
        list<Price_Quote_Line_Item__c> lineItemList = new list<Price_Quote_Line_Item__c>();
        //list<Price_Quote_Line_Item__c> list2 = new list<Price_Quote_Line_Item__c>();
        list<Price_Quote_Line_Item__c> finalList = new list<Price_Quote_Line_Item__c>();
        
        try{
            Price_Quote__c pq = [SELECT Account_Name__r.SAP_Sold_To__c, Account_Name__r.Account_Group__c, Sales_Org_Key__c,
                                 Line_Count__c, Account_Name__r.Price_List_Type__c, CurrencyIsoCode, Type__c, BusinessUnit__c,
                                 Owner_Business_Unit__c
                                 FROM Price_Quote__c
                                 WHERE Id =: quoteId LIMIT 1];
            system.debug('pq ====================== ' + pq);
            Decimal rowOrder = pq.Line_Count__c;
            
            //adding logic for ASK Agreements
            if(pq.Type__c == 'ASK Agreement'){
                mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c, Cost_Formula__c, Floor_Price__c,
                      List_Price__c, RSM_Price__c, Rep_Price__c, Description, Product_Description_Custom__c,
                      Distributor_List__c, Alt_Site_List__c, Director_Price__c, MRP_Group__c, SearchableProducts__c
                      FROM Product2
                      WHERE Name IN :materialStr
                      AND Sales_Org_Key__c =: pq.Sales_Org_Key__c
                      AND Duplicate__c = FALSE AND ASK_Custom_Kit__c = TRUE];
            }
            else{
                mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c, Cost_Formula__c, Floor_Price__c,
                      List_Price__c, RSM_Price__c, Rep_Price__c, Description, Product_Description_Custom__c,
                      Distributor_List__c, Alt_Site_List__c, Director_Price__c, MRP_Group__c, SearchableProducts__c
                      FROM Product2
                      WHERE Name IN :materialStr
                      AND Sales_Org_Key__c =: pq.Sales_Org_Key__c
                      AND Duplicate__c = FALSE AND SearchableProducts__c = TRUE];
            }
            //end of ASK Agreement logic

            system.debug('mcheck ====================== ' + mcheck);
            for(Product2 curr :mcheck){
               system.debug('curr.Description ====================== ' + curr.Description);
               system.debug('curr.Product_Description_Custom__c ====================== ' + curr.Product_Description_Custom__c); 
            }
            
            // Create the Product Mapping
            map<String, Product2> prodmap = new map<String, Product2>();
            for(Product2 pmap : mcheck){
                prodmap.put(pmap.Name, pmap);
            }
            system.debug('prodmap: ' + prodmap);
            
            // Determine which SAP Number to use for Lookup
            string pcn = pq.Account_Name__r.SAP_Sold_To__c;
            if(pq.Account_Name__c!=null && pq.Account_Name__r.Account_Group__c == 'Z002'){
                /*for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                                  FROM Contract_Partnership__c
                                                  WHERE Ship_to__c =:pq.Account_Name__r.SAP_Sold_To__c
                                                  AND Disabled__c = FALSE])*/
                for(Contract_Partnership__c cp : getContractPartnership(pq.Account_Name__r.SAP_Sold_To__c))
                {
                    pcn = cp.Sale_to__c;
                }
                
                //Query to get Price List Type of SAP Sold To Account
                soldToType = [SELECT Price_List_Type__c FROM Account WHERE SAP_Sold_To__c = :pcn LIMIT 1].Price_List_Type__c;
            }
            else{
                soldToType = pq.Account_Name__r.Price_List_Type__c;
            }
            
            system.debug('pcn (Primary Customer Number) ================ ' + pcn);
            // Start building the line items
            
            // Prospect Account Process (No SAP) #1
            if(pq.Account_Name__r.SAP_Sold_To__c == NULL){
                system.debug('Starting getPrice without SAP');
                
                for(String ml : materialStr){
                    system.debug('*** ml *** ' + ml);
                    system.debug('*** prodmap.get(ml) getCrossBulk No SAP *** ' + prodmap.get(ml));
                    if(prodmap.get(ml) != NULL){
                        ++rowOrder;
                        Price_Quote_Line_Item__c  pqLineItem = new Price_Quote_Line_Item__c (
                            Price_Quote__c = pq.Id,
                            Material_Name__c = prodmap.get(ml).Id,
                            Product_Description__c = prodmap.get(ml).Description,
                            Quantity__c = 1,
                            //List_Price__c = prodmap.get(ml).List_Price__c,
                            RSM_Price__c = prodmap.get(ml).RSM_Price__c,
                            Rep_Price__c = prodmap.get(ml).Rep_Price__c,
                            //Sales_Price__c = prodmap.get(ml).List_Price__c,
                            //Eligible_Price__c = prodmap.get(ml).List_Price__c,
                            Director_Price__c = prodmap.get(ml).Director_Price__c,
                            Floor_Price__c = prodmap.get(ml).Floor_Price__c,
                            Cost__c = prodmap.get(ml).Cost_Formula__c,
                            Material_Status__c = '40',
                            Row_Order__c = rowOrder,
                            Competetive_Product__c = crossMap.get(ml),
                            MRP_Group__c = prodmap.get(ml).MRP_Group__c,
                            CurrencyIsoCode = pq.CurrencyIsoCode 
                        );
                        
                        // Check for custom product description. Was specifically for Surgical but now we have Cardiac as well.
                        system.debug('prodmap.get(ml).Product_Description_Custom__c ================ ' + prodmap.get(ml).Product_Description_Custom__c);
                        //system.debug('pcn (Primary Customer Number) ================ ' + pcn);
                        if(prodmap.get(ml).Product_Description_Custom__c != NULL){
                            pqLineItem.Product_Description__c = prodmap.get(ml).Product_Description_Custom__c;
                        }
                        else{
                            pqLineItem.Product_Description__c = prodmap.get(ml).Description;
                        }
                        
                        //logic to handle Hospital, Distributor, and Alt Site pricing
                        
                        if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                               //Alt Site Accounts
                               if(soldToType == 'ZA'){
                                   if(prodmap.get(ml).Alt_Site_List__c != 0.00){
                                       pqLineItem.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                       pqLineItem.Sales_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                       pqLineItem.Eligible_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                   }
                                   else{
                                       pqLineItem.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                       pqLineItem.Sales_Price__c = 0.00;
                                       pqLineItem.Eligible_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                   }
                               }
                               
                               //Distributor Accounts
                               if(soldToType == 'ZD'){
                                   if(prodmap.get(ml).Distributor_List__c != 0.00){
                                       pqLineItem.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                       pqLineItem.Sales_Price__c = prodmap.get(ml).Distributor_List__c;
                                       pqLineItem.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                   }
                                   else{
                                       pqLineItem.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                       pqLineItem.Sales_Price__c = 0.00;
                                       pqLineItem.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                   }
                               }
                               
                               //Hospital Accounts
                               if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                   if(prodmap.get(ml).List_Price__c != 0.00){
                                       pqLineItem.List_Price__c = prodmap.get(ml).List_Price__c;
                                       pqLineItem.Sales_Price__c = prodmap.get(ml).List_Price__c;
                                       pqLineItem.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                   }
                                   else{
                                       pqLineItem.List_Price__c = prodmap.get(ml).List_Price__c;
                                       pqLineItem.Sales_Price__c = 0.00;
                                       pqLineItem.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                   }
                               }
                               //end of logic to handle Hospital, Distributor, and Alt Site pricing
                           }//end of if pq.Sales_Org__c
                        else{
                            //Start of US6020 ZD Pricing Only
                            if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                pqLineItem.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                pqLineItem.Sales_Price__c = prodmap.get(ml).Distributor_List__c;
                                pqLineItem.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                            }
                            /*
                            else{
                                //All other Sales Orgs
                                if(prodmap.get(ml).List_Price__c != 0.00){
                                    pqLineItem.List_Price__c = prodmap.get(ml).List_Price__c;
                                    pqLineItem.Sales_Price__c = prodmap.get(ml).List_Price__c;
                                    pqLineItem.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                }
                                else{
                                    pqLineItem.List_Price__c = prodmap.get(ml).List_Price__c;
                                    pqLineItem.Sales_Price__c = 0.00;
                                    pqLineItem.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                }
                            }//end else for pq.Sales_org_Key__c = US6020
                            */
                        }//end of else pq.Sales_Org_Key__c
                        
                        
                        lineItemList.add(pqLineItem);
                        //list2.add(pqLineItem);
                    }
                    
                }//end of for loop
            }
            else{ // Customer Account Process #2
                system.debug('Starting getPrice with SAP');
                
                if (Test.isRunningTest()){
                    list<Sales_Condition_Mapping__c> condMapList = new list<Sales_Condition_Mapping__c>();
                    Sales_Condition_Mapping__c condMap1 = new Sales_Condition_Mapping__c(
                        Name = 'ND', Mapped_Value__c = 'XNAF'
                    );
                    condMapList.add(condMap1);
                    
                    Sales_Condition_Mapping__c condMap2 = new Sales_Condition_Mapping__c(
                        Name = 'PR', Mapped_Value__c = 'XPRI'
                    );
                    condMapList.add(condMap2);
                    
                    Sales_Condition_Mapping__c condMap3 = new Sales_Condition_Mapping__c(
                        Name = 'SE', Mapped_Value__c = 'XSEC'
                    );
                    condMapList.add(condMap3);
                    
                    insert condMapList;
                    
                    //Move this to Constructor to avoid repetitive SOQl Query
                    /*Map<String, String> cMap = new Map<String, String>();
                    for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
                        cMap.put(scm.Name, scm.Mapped_Value__c);
                    }*/
                }//end of test running to create condition map
                
                //Move this to Constructor to avoid repetitive SOQl Query
                /*Map<String, String> cMap = new Map<String, String>();
                for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
                    cMap.put(scm.Name, scm.Mapped_Value__c);
                }
                system.debug('cMap ============== ' + cMap);*/
                
                //Start getting SAP info
                for(String ml : materialStr)
                {
                    if(prodmap.get(ml) != NULL){
                        list<SAPRealPriceSet__x> sapList = new list<SAPRealPriceSet__x>();
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
                        }//end if(!Test.isRunningTest())
                        else{
                            sapList = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c,
                                       ValidFrom__c, ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                       OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                       DistChnl__c
                                       FROM SAPRealPriceSet__x
                                       WHERE SalesOrg__c =:prodmap.get(ml).Sales_Org__c
                                       AND DistChnl__c =:prodmap.get(ml).Distribution_Channel__c
                                       AND Customer__c =:pcn
                                       AND Material__c =:prodmap.get(ml).Name
                                       AND EffDate__c =:datetime.now()
                                      ];
                        }
                        
                        for(SAPRealPriceSet__x sap : sapList )
                        {
                            ++rowOrder;
                            system.debug('sap: ' + sap);
                            
                            string conremap = sap.Condition__c;
                            if(cMap.size()>0 && cMap.containsKey(sap.Condition__c) && cMap.get(sap.Condition__c) != NULL){
                                conremap = cMap.get(sap.Condition__c);
                            }
                            
                            string salesDeal;
                            if(sap.SalesDeal__c != NULL){
                                salesDeal = sap.SalesDeal__c.right(8);
                            }
                            
                            string mstatus;
                            if(sap.SalesMtrlStatus__c != NULL){
                                mstatus = sap.SalesMtrlStatus__c;
                            }
                            else if(sap.MtrlStatus__c != NULL){
                                mstatus = sap.MtrlStatus__c;
                            }
                            
                            Price_Quote_Line_Item__c  li = new Price_Quote_Line_Item__c (
                                Price_Quote__c = pq.Id,
                                Material_Name__c = prodmap.get(ml).Id,
                                Product_Description__c = prodmap.get(ml).Description,
                                Material_Status__c = mstatus,
                                Quantity__c = 1,
                                //List_Price__c = prodmap.get(ml).List_Price__c,
                                RSM_Price__c = prodmap.get(ml).RSM_Price__c,
                                Rep_Price__c = prodmap.get(ml).Rep_Price__c,
                                Director_Price__c = prodmap.get(ml).Director_Price__c,
                                Floor_Price__c = prodmap.get(ml).Floor_Price__c,
                                Cost__c = prodmap.get(ml).Cost_Formula__c,
                                Condition__c = conremap,
                                Sales_Deal_Description__c = sap.AgrDesc__c,
                                Sales_Number__c = salesDeal,
                                Row_Order__c = rowOrder,
                                Objective__c = sap.AgrObjective__c,
                                Competetive_Product__c = crossMap.get(ml),
                                MRP_Group__c = prodmap.get(ml).MRP_Group__c,
                                CurrencyIsoCode = pq.CurrencyIsoCode
                            );
                            
                            // Check for custom product description. Was specifically for Surgical but now we have Cardiac as well.
                            if(prodmap.get(ml).Product_Description_Custom__c != NULL){
                                li.Product_Description__c = prodmap.get(ml).Product_Description_Custom__c;
                            }
                            else{
                                li.Product_Description__c = prodmap.get(ml).Description;
                            }
                            
                            //check for eligible price = 0
                            if(sap.Price__c != 0.00){
                                li.Sales_Price__c = sap.Price__c;
                                li.Eligible_Price__c = sap.Price__c;
                            }
                            else{
                                //logic to handle Hospital, Distributor, and Alt Site pricing
                                
                                if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                                       //Alt Site Accounts
                                       if(soldToType == 'ZA'){
                                           if(prodmap.get(ml).Alt_Site_List__c != 0.00){
                                               li.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                               li.Sales_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                               li.Eligible_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                           }
                                           else{
                                               li.List_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                               li.Sales_Price__c = 0.00;
                                               li.Eligible_Price__c = prodmap.get(ml).Alt_Site_List__c;
                                           }
                                       }
                                       
                                       //Distributor Accounts
                                       if(soldToType == 'ZD'){
                                           if(prodmap.get(ml).Distributor_List__c != 0.00){
                                               li.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                               li.Sales_Price__c = prodmap.get(ml).Distributor_List__c;
                                               li.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                           }
                                           else{
                                               li.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                               li.Sales_Price__c = 0.00;
                                               li.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                           }
                                       }
                                       
                                       //Hospital Accounts
                                       if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                           if(prodmap.get(ml).List_Price__c != 0.00){
                                               li.List_Price__c = prodmap.get(ml).List_Price__c;
                                               li.Sales_Price__c = prodmap.get(ml).List_Price__c;
                                               li.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                           }
                                           else{
                                               li.List_Price__c = prodmap.get(ml).List_Price__c;
                                               li.Sales_Price__c = 0.00;
                                               li.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                           }
                                       }
                                       //end of logic to handle Hospital, Distributor, and Alt Site pricing
                                   }//end of if pq.Sales_Org_Key__c
                                else{
                                    //Start of US6020 ZD Pricing Only
                                    if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                        li.List_Price__c = prodmap.get(ml).Distributor_List__c;
                                        li.Sales_Price__c = prodmap.get(ml).Distributor_List__c;
                                        li.Eligible_Price__c = prodmap.get(ml).Distributor_List__c;
                                    }
                                    else{
                                        //All other Sales Orgs
                                        if(prodmap.get(ml).List_Price__c != 0.00){
                                            li.List_Price__c = prodmap.get(ml).List_Price__c;
                                            li.Sales_Price__c = prodmap.get(ml).List_Price__c;
                                            li.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                        }
                                        else{
                                            li.List_Price__c = prodmap.get(ml).List_Price__c;
                                            li.Sales_Price__c = 0.00;
                                            li.Eligible_Price__c = prodmap.get(ml).List_Price__c;
                                        }
                                    }//end else for pq.Sales_org_Key__c = US6020
                                }//end else to US103010,US610,CA1010 if
                                
                            }//end of outter else
                            
                            lineItemList.add(li);
                            //list2.add(li);
                            system.debug('lineItemList ======================== ' + lineItemList);
                        }//end of for loop
                    }
                    
                }
                
                // DML - Insert Lines
                If(lineItemList.size() > 0){
                    system.debug('lineItemList ======================= ' + lineItemList);
                    database.insert(lineItemList,false);
                    //conditions below helps with Price Quote and PRF Approval Matrix Routing
                    if(pq.BusinessUnit__c == 'Alternate Care'){
                        lineClassCheck(quoteId);
                    }
                    
                    if(pq.BusinessUnit__c == 'Anesthesia'){
                        lineProdCheckAnes(quoteId);
                    }
                    
                    if(pq.BusinessUnit__c == 'Interventional Capital' || pq.BusinessUnit__c == 'Cardiac'){
                        lineProdCheckIcap(quoteId);
                    }
                    
                    if(pq.Owner_Business_Unit__c == 'Surgical Instruments'){
                        lineClassCheck(quoteId);
                    }
                }
            }
            
        }
        catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
        }
        
    }//End New SAP Price Logic w/Cross Reference
    
    
    /**************************************************** START OF REBATE ONLY CHANGES ****************************************************/
    /*
    global void getSAPpriceOld(List<String> materialStr,String crossStr,String lineItemId, String quoteId){
        // Initiatal Values
        system.debug('*** getSAPprice materialStr ======================= ' + materialStr);
        system.debug('*** getSAPprice quoteId ======================= ' + quoteId);
        
        PP_DataUtility ppdu = new PP_DataUtility();
        String soldToType; //Variable to hold Sold To Price List Type
        String shipTo;
        boolean refresh = FALSE;

        if(!String.isBlank(crossStr) && crossStr == 'refresh'){
            refresh = TRUE;
        }
        
        Price_Quote__c pq = [Select Id, Name, Status__c, Sales_Org_Key__c, Account_Name__r.SAP_Sold_To__c, BusinessUnit__c,
                             Line_Count__c, Account_Name__r.Account_Group__c, CurrencyIsoCode, Account_Name__r.Id, Type__c,
                             Price_Quote_Name__c, InApproval__c, Owner_Business_Unit__c, Account_Name__r.Price_List_Type__c
                             FROM Price_Quote__c
                             WHERE Id =:quoteId limit 1];
        
        Decimal rowOrder = pq.Line_Count__c;
        shipTo = pq.Account_Name__r.Sap_Sold_To__c;

        if(pq.Sales_Org_Key__c == NULL){
            pq.Sales_Org_Key__c = 'US6010';
        }
        
        IF(pq.InApproval__c){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Cannot add Material to an Approved Quote, please create a new quote and then try again or click Revise/Clone and try again.'));
        }
        else{
            try{
                String SAP_1stPick = '00000000';
                List<SAPRealPriceSet__x> listSAP = new List<SAPRealPriceSet__x>();
                List<Price_Quote_Line_Item__c> qLineItem = new List<Price_Quote_Line_Item__c>();
                Product2 mcheck = new Product2();
                
                system.debug('*** materialStr ====================== getSAPprice 1 ' + materialStr);
                
                //adding logic for ASK Agreements
                if(pq.Type__c == 'ASK Agreement'){
                    mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c,Brand_Name__c, Cost__c,
                              List_Price__c, RSM_Price__c, Rep_Price__c, Director_Price__c, Floor_Price__c,
                              Product_Description_Custom__c, Material_Status_Numeric__c, Description, Cost_Formula__c,
                              Distributor_List__c, Alt_Site_List__c, MRP_Group__c, SearchableProducts__c, Min_Order_Qty__c
                              FROM Product2
                              WHERE Id IN :materialStr
                              AND Duplicate__c = FALSE AND ASK_Custom_Kit__c = TRUE
                              LIMIT 1];
                }
                else{
                    mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c,Brand_Name__c, Cost__c,
                              List_Price__c, RSM_Price__c, Rep_Price__c, Director_Price__c, Floor_Price__c,
                              Product_Description_Custom__c, Material_Status_Numeric__c, Description, Cost_Formula__c,
                              Distributor_List__c, Alt_Site_List__c, MRP_Group__c, SearchableProducts__c, Min_Order_Qty__c
                              FROM Product2
                              WHERE Id IN :materialStr
                              AND Duplicate__c = FALSE AND SearchableProducts__c = TRUE
                              LIMIT 1];
                }
                //end of ASK Agreement logic
                
                system.debug('*** mcheck ====================== getSAPprice 1' + mcheck);
                system.debug('*** pq.Account_Name__r.SAP_Sold_To__c ====================== 2 ' + pq.Account_Name__r.SAP_Sold_To__c);
                if(pq.Account_Name__c !=null && pq.Account_Name__r.SAP_Sold_To__c == NULL){
                    system.debug('*** Starting getPrice without SAP ***');
                    ++rowOrder;
                    
                    Price_Quote_Line_Item__c prodQuoteLineItem1 = new Price_Quote_Line_Item__c(
                        Price_Quote__c = pq.Id,
                        Material_Name__c = mcheck.Id,
                        //List_Price__c = mcheck.List_Price__c,
                        RSM_Price__c = mcheck.RSM_Price__c,
                        Rep_Price__c = mcheck.Rep_Price__c,
                        Director_Price__c = mcheck.Director_Price__c,
                        Floor_Price__c = mcheck.Floor_Price__c,
                        Cost__c = mcheck.Cost_Formula__c,
                        //Eligible_Price__c = mcheck.List_Price__c,
                        Material_Status__c = mcheck.Material_Status_Numeric__c,
                        Row_Order__c = rowOrder,
                        MRP_Group__c = mcheck.MRP_Group__c,
                        CurrencyIsoCode = pq.CurrencyIsoCode
                    );
                    
                    //System.debug('*** lineItemId getSapPrice *** ' + lineItemId);
                    if(lineItemId == NULL){
                        //check for surgical custom product description
                        if(mcheck.Product_Description_Custom__c != NULL){
                            prodQuoteLineItem1.Product_Description__c = mcheck.Product_Description_Custom__c;
                        }
                        else{
                            prodQuoteLineItem1.Product_Description__c = mcheck.Description;
                        }
                        
                        //logic to handle Hospital, Distributor, and Alt Site pricing
                        //Alt Site Accounts
                        System.debug('*** pq.Account_Name__r.Price_List_Type__c getSapPrice lineItemId == Null *** ' + pq.Account_Name__r.Price_List_Type__c);
                        if(pq.Account_Name__r.Price_List_Type__c == 'ZA'){
                            System.debug('*** In Alt Site List Pricing ***');
                            if(mcheck.Alt_Site_List__c != 0.00){
                                prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                prodQuoteLineItem1.Sales_Price__c = mcheck.Alt_Site_List__c;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                            }
                            else{
                                prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                            }
                        }
                        
                        //Distributor Accounts
                        if(pq.Account_Name__c!=null && pq.Account_Name__r.Price_List_Type__c == 'ZD'){
                            System.debug('*** In Distributor List Pricing ***');
                            if(mcheck.Distributor_List__c != 0.00){
                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                            }
                            else{
                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                            }
                        }
                        
                        //Hospital Accounts
                        if(pq.Account_Name__c!=null && pq.Account_Name__r.Price_List_Type__c == 'ZH' || pq.Account_Name__r.Price_List_Type__c == ''){
                            System.debug('*** In Hospital List Pricing ***');
                            if(mcheck.List_Price__c != 0.00){
                                prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                            }
                            else{
                                prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                            }
                        }
                        //end of logic to handle Hospital, Distributor, and Alt Site pricing
                        if(pq.BusinessUnit__c == 'EMEA'){
                            prodQuoteLineItem1.Quantity__c = mcheck.Min_Order_Qty__c;
                            prodQuoteLineItem1.Row_Order__c = pq.Line_Count__c;
                        }else{
                            prodQuoteLineItem1.Quantity__c = 1;
                            prodQuoteLineItem1.Row_Order__c = pq.Line_Count__c;
                        }
                        
                    }//end of if(lineItemId == NULL)
                    else{
                        prodQuoteLineItem1.Id = lineItemId;
                        prodQuoteLineItem1.Hide_Crossreference__c = false;
                    }//end of else after if(lineItemId == NULL)
                    
                    //cross reference check
                    If(crossStr != null && crossStr != 'refresh'){
                        prodQuoteLineItem1.Competetive_Product__c = crossStr;
                    }
                    
                    //add object to list
                    qLineItem.add(prodQuoteLineItem1);
                    system.debug('*** qLineItem ======================== ' + qLineItem);
                    
                }//end of if(pq.Account_Name__r.SAP_Sold_To__c == NULL)
                else{
                    system.debug('*** Starting getPrice with SAP ***');
                    List<string> cnlist = new List<String>();
                    string pcn = '';
                    
                    if(pq.Account_Name__c!=null && shipTo != null){
                        cnlist.add(pq.Account_Name__r.SAP_Sold_To__c);
                        pcn = pq.Account_Name__r.SAP_Sold_To__c;
                    }
                    
                    
                    if(pq.Account_Name__c!=null && pq.Account_Name__r.Account_Group__c == 'Z002'){
                        
                        for(Contract_Partnership__c cp : getContractPartnership(shipTo))
                        {
                            cnlist.add(cp.Sale_to__c);
                            pcn = cp.Sale_to__c;
                        }
                        
                    }
                    //Query to get Price List Type of SAP Sold To Account
                    soldToType = [SELECT Price_List_Type__c FROM Account WHERE SAP_Sold_To__c = :pcn LIMIT 1].Price_List_Type__c;
                    system.debug('*** pcn (Primary Customer Number) ================ ' + pcn);
                    system.debug('*** cnlist (Customer Number List) ================= ' + cnlist);
                    
                    Map<String, String> obMap = new Map<String, String>();
                    obMap.put('01', 'Direct/Rebate');
                    obMap.put('02', 'Direct');
                    obMap.put('03', 'Distributor Netbill');
                    obMap.put('04', 'Specialty Market');
                    obMap.put('05', 'Strategic Accounts');
                    obMap.put('06', 'Rebate Only');
                    system.debug('*** obMap ============== ' + obMap);
                    
                    system.debug('*** mcheck.Sales_Org__c b4 SAP ============== ' + mcheck.Sales_Org__c);
                    system.debug('*** mcheck.Distribution_Channel__c b4 SAP============== ' + mcheck.Distribution_Channel__c);
                    system.debug('*** pcn b4 SAP============== ' + pcn);
                    system.debug('*** mcheck.Name b4 SAP============== ' + mcheck.Name);
                    datetime datenew = datetime.now();
                    List<SAPRealPriceSet__x> sapList = new List<SAPRealPriceSet__x>();
                    if(Test.isRunningTest()) {
                        
                        for(Integer i = 0; i < 5; i++){
                            Decimal testPrice = i == 2 ? 0.00 : 123.00;
                            SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
                                SalesDeal__c = '50009064',
                                Price__c = testPrice,
                                Material__c = '353535',
                                MtrlStatus__c = '40',
                                SalesMtrlStatus__c = '40',
                                ValidFrom__c = Date.Today(),
                                ValidTo__c = Date.Today() + 1000,
                                AgrDesc__c = 'Duke University SURGR',
                                Condition__c = 'XNAF',
                                OwnerName__c = 'Duke Univ Health System',
                                Owner__c = 'IDN-032',
                                AgrObjective__c = '06',
                                Customer__c  = '0000102059'
                            );
                            sapList.add(testSAP);
                        }
                    }//end if(!Test.isRunningTest())
                    else{    
                        SAPRealPriceSet__x sapObj = ppdu.getSapObj(pcn, shipTo, mcheck.name, mcheck.Sales_Org__c, mcheck.Distribution_Channel__c); 
                        sapList.add(sapObj);
                        
                    }
                        //************************************* Start Rebate Only Check *******************************************
                        System.debug('*** sapList[0].AgrObjective__c *** ' + sapList[0].AgrObjective__c);
                        System.debug('*** sapList[0].SalesDeal__c *** ' + sapList[0].SalesDeal__c);
                        String compDeal = sapList[0].SalesDeal__c;
                        //System.debug('*** userRole crossBulk *** ' + userRole);
                        if(sapList.size()>0 && sapList[0].AgrObjective__c == '06' && userRoleBoolean ){
                            System.debug('*** IN REBATE ONLY CHECK ***');
                            //SAP_1stPick = sapList[0].Agreement_Number__c.right(8);
                            list<String> ccaList = new list<String>();
                            if(cnlist.size()>0){
                                for(Contract_Customer__c cc : [SELECT Agreement__r.Agreement_Number__c
                                                               FROM Contract_Customer__c
                                                               WHERE Account__r.SAP_Sold_To__c IN :cnlist
                                                               AND Active__c = TRUE])
                                {
                                    ccaList.add(cc.Agreement__r.Agreement_Number__c);
                                }
                            }
                            System.debug('*** ccalist:' + ccaList);
                            
                            //System.debug('*** ccalist 2:' + ccaList);
                            // Contract Material List - Used to filter the Contract Customers
                            list<String> cmList = new list<String>();
                            // Material Map - Used to filter...
                            map<String, String> matMap = new map<String, String>();
                            for(Contract_Material__c cm : [SELECT Product__r.Name, Agreement__r.Agreement_Number__c, Agreement__r.Sales_Org__c
                                                           FROM Contract_Material__c
                                                           WHERE Product__r.Id = :materialStr
                                                           AND Agreement_Number__c IN :ccaList
                                                           AND Active__c = TRUE
                                                           ORDER BY Price__c
                                                           LIMIT 1])
                            {
                                cmList.add(cm.Agreement__r.Agreement_Number__c);
                                matMap.put(cm.Agreement__r.Agreement_Number__c, cm.Product__r.Name);
                            }
                            System.debug('*** cmList.size: ' + cmList.size());
                            //System.debug('*** cmList *** ' + cmList );
                            
                            sapList.remove(0);
                            //**************************** Start Contract Customer Lookup ************************************
                            
                            for(Contract_Customer__c cc: getContractCustomer(cmList, cnlist))
                            {
                                SAPRealPriceSet__x sapObj = ppdu.getSapObjAgree(pcn, shipTo, matMap.get(cc.Agreement__r.Agreement_Number__c), mcheck.Sales_Org__c, mcheck.Distribution_Channel__c, cc.Agreement__r.Agreement_Number__c); 
                                sapList.add(sapObj);
                                
                                System.debug('*** sapList *** ' + sapList );
                            }
                            //**************************** End Contract Customer Lookup ************************************
                        }
                        //************************************* Start Rebate Only Check *******************************************
                        
                    //}//end of esle after if(Test.isRunningTest())
                    
                    if(sapList!=null && sapList.size()>0){
                        for(SAPRealPriceSet__x sap : sapList)
                        {
                            //SAPRealPriceSet__x sap = newSAP;
                            
                            system.debug('*** in SAP for loop ================== ');
                            system.debug('*** sap ================== ' + sap);
                            //system.debug('*** sap.Price__c ================== ' + sap.Price__c);
                            string objname;
                            string mstatus;
                            ++rowOrder;
                            
                            string conremap = sap.Condition__c;
                            if(cMap.size()>0 && cMap.containsKey(sap.Condition__c) && cMap.get(sap.Condition__c) != NULL){
                                conremap = cMap.get(sap.Condition__c);
                            }
                            
                            if(sap.SalesDeal__c != NULL){
                                if( sap.AgrObjective__c == '06' && userRoleBoolean ){
                                    SAP_1stPick = 'No Contract';
                                }
                                else{
                                    SAP_1stPick = sap.SalesDeal__c.right(8);
                                }    
                            }
                            else{
                                SAP_1stPick = 'No Contract';
                            }
                            system.debug('*** SAP_1stPick ================ ' + SAP_1stPick);
                            
                            String cnum2;
                            // Strip the leading zero's - 06Jul2016 ESC
                            if(sap.Customer__c != NULL){
                                cnum2 = sap.Customer__c.replaceAll('^0+', '');
                            }
                            // Checks to see if the Sales Material Status Exists and if it does we use that, otherwise we default
                            // to the standard Material Status. - 06Jul2016 ESC
                            if(sap.SalesMtrlStatus__c != NULL){
                                mstatus = sap.SalesMtrlStatus__c;
                            }
                            else if(sap.MtrlStatus__c != NULL){
                                mstatus = sap.MtrlStatus__c;
                            }
                            
                            Price_Quote_Line_Item__c prodQuoteLineItem1 = new Price_Quote_Line_Item__c(
                                Price_Quote__c = pq.Id,
                                Material_Name__c = mcheck.Id,
                                Material_Status__c = mstatus,
                                //List_Price__c = mcheck.List_Price__c,
                                RSM_Price__c = mcheck.RSM_Price__c,
                                Rep_Price__c = mcheck.Rep_Price__c,
                                Director_Price__c = mcheck.Director_Price__c,
                                Floor_Price__c = mcheck.Floor_Price__c,
                                Cost__c = mcheck.Cost_Formula__c,
                                Objective__c = sap.AgrObjective__c,
                                MRP_Group__c = mcheck.MRP_Group__c,
                                CurrencyIsoCode = pq.CurrencyIsoCode
                            );
                            
                            if(lineItemId == NULL){
                                //check for surgical custom product description
                                if(mcheck.Product_Description_Custom__c != NULL){
                                    prodQuoteLineItem1.Product_Description__c = mcheck.Product_Description_Custom__c;
                                }
                                else{
                                    prodQuoteLineItem1.Product_Description__c = mcheck.Description;
                                }
                                
                                if(pq.BusinessUnit__c == 'EMEA'){
                                    prodQuoteLineItem1.Quantity__c = mcheck.Min_Order_Qty__c;
                                    prodQuoteLineItem1.Row_Order__c = pq.Line_Count__c;
                                }else{
                                    prodQuoteLineItem1.Quantity__c = 1;
                                    prodQuoteLineItem1.Row_Order__c = pq.Line_Count__c;
                                }
                            }
                            
                            //check for eligible price = 0
                            if(sap.Price__c != 0.00){
                                System.debug('*** sap.Price__c != 0.00 *** ');
                                if(!refresh){
                                    System.debug('*** if(!refresh) sap.Price__c != 0.00 *** ');
                                    prodQuoteLineItem1.Sales_Price__c = sap.Price__c;
                                }
                                prodQuoteLineItem1.Eligible_Price__c = sap.Price__c;
                                
                                //logic to handle Hospital, Distributor, and Alt Site pricing
                                
                                //start of check for Customer Service Rebate Only
                                if(sapList[0].AgrObjective__c == '06' && userRoleBoolean ){
                                    //prodQuoteLineItem1.Sales_Price__c = sap.Price__c;
                                    //prodQuoteLineItem1.Eligible_Price__c = sap.Price__c;
                                    
                                    if(soldToType == 'ZA'){
                                        System.debug('*** In Alt Site List Pricing for if sap.Price__c != 0.00 ***');
                                        prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                        prodQuoteLineItem1.Sales_Price__c = mcheck.Alt_Site_List__c;
                                        prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                    }
                                    
                                    //Distributor Accounts
                                    if(soldToType == 'ZD'){
                                        System.debug('*** In Distributor List Pricing for if sap.Price__c != 0.00 ***');
                                        prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                        prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                        prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                    }
                                    
                                    //Hospital Accounts
                                    if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                        System.debug('*** In Hospital List Pricing for if sap.Price__c != 0.00 ***');
                                        prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                        prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                        prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                    }
                                }
                                //end of check for Customer Service Rebate Only
                                System.debug('*** soMap.get(pq.Sales_Org_Key__c) *** ' + soMap.get(pq.Sales_Org_Key__c));
                                System.debug('*** soMap.get(pq.Sales_Org_Key__c)..Pricing_Type__c *** ' + soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c );
                                if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){ 
                                       //add Canada
                                       System.debug('*** In if pq.Sales_Org_Key__c == US103010 OR CA1010 *** ');
                                       System.debug('*** soldToType *** ' + soldToType);
                                       //Alt Site Accounts
                                       if(soldToType == 'ZA'){
                                           System.debug('*** In Alt Site List Pricing for if sap.Price__c != 0.00 ***');
                                           prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                       }
                                       
                                       //Distributor Accounts
                                       if(soldToType == 'ZD'){
                                           System.debug('*** In Distributor List Pricing for if sap.Price__c != 0.00 ***');
                                           prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                       }
                                       
                                       //Hospital Accounts
                                       if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                           System.debug('*** In Hospital List Pricing for if sap.Price__c != 0.00 ***');
                                           prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                       }
                                       //end of logic to handle Hospital, Distributor, and Alt Site pricing
                                   }//end of if pq.Sales_Org_Key__c
                                else{
                                    System.debug('*** In Hospital List Pricing for non US/CA Accounts after if sap.Price__c != 0.00 ***');
                                    if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                        prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                    }
                                    else{
                                        prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                    }
                                }//end of else of pq.Sales_Org_Key__c
                                
                            }//end of if sap.price__c != 0.00
                            else{
                                System.debug('*** Else after If sap.price__c != 0.00 ***');
                                if(!refresh){
                                    //logic to handle Hospital, Distributor, and Alt Site pricing
                                    System.debug('*** if(!refresh) *** ');
                                    if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                                        System.debug('*** IN All LOGIC Pricing_Type__c !refresh ***');
                                           //Alt Site Accounts
                                           if(soldToType == 'ZA'){
                                               System.debug('*** In Alt Site List Pricing !refresh ***');
                                               if(mcheck.Alt_Site_List__c != 0.00){
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                                   prodQuoteLineItem1.Sales_Price__c = mcheck.Alt_Site_List__c;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                               }
                                               else{
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                                   prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                               }
                                           }
                                           
                                           //Distributor Accounts
                                           if(soldToType == 'ZD'){
                                               System.debug('*** In Distributor List Pricing !refresh ***');
                                               if(mcheck.Distributor_List__c != 0.00){
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                   prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                               }
                                               else{
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                   prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                               }
                                           }
                                           
                                           //Hospital Accounts
                                           if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                               System.debug('*** In Hospital List Pricing !refresh ***');
                                               if(mcheck.List_Price__c != 0.00){
                                                   prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                   prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                               }
                                               else{
                                                   prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                   prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                               }
                                           }
                                           //end of logic to handle Hospital, Distributor, and Alt Site pricing
                                       }//end of if pq.Sales_Org_Key__c
                                    else{
                                        System.debug('*** Else after If pq.Sales_Org_Key__c == US103010 || pq.Sales_Org_Key__c == US6010 || pq.Sales_Org_Key__c == CA1010 ***');
                                        //Start of US6020 ZD Pricing Only
                                        if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                            System.debug('*** IN Distributor List LOGIC Pricing_Type__c !refresh ***');
                                            if(mcheck.Distributor_List__c != 0.00){
                                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                            }
                                            else{
                                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                            }
                                        }
                                        else{
                                            //All other Sales Orgs
                                            if(mcheck.List_Price__c != 0.00){
                                                prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                            }
                                            else{
                                                prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                            }
                                        }//end else for pq.Sales_org_Key__c = US6020
                                    }//end of else pq.Sales_Org_Key__c
                                }//end of if(!refresh)
                                else{//after if(!refresh)
                                    //start of refresh
                                    System.debug('*** if(!refresh) else *** ');
                                    if(soMap.containsKey(pq.Sales_Org_Key__c) && soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                                        System.debug('*** IN All LOGIC Pricing_Type__c refresh ***');
                                           //Alt Site Accounts
                                           if(soldToType == 'ZA'){
                                               System.debug('*** In Alt Site List Pricing !refresh ***');
                                               if(mcheck.Alt_Site_List__c != 0.00){
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                                   //prodQuoteLineItem1.Sales_Price__c = mcheck.Alt_Site_List__c;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                               }
                                               else{
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                                   prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                               }
                                           }
                                           
                                           //Distributor Accounts
                                           if(soldToType == 'ZD'){
                                               System.debug('*** In Distributor List Pricing refresh ***');
                                               if(mcheck.Distributor_List__c != 0.00){
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                   //prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                               }
                                               else{
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                   //prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                               }
                                           }
                                           
                                           //Hospital Accounts
                                           if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                               System.debug('*** In Hospital List Pricing refresh ***');
                                               if(mcheck.List_Price__c != 0.00){
                                                   prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                   //prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                               }
                                               else{
                                                   prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                   //prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                               }
                                           }
                                           //end of logic to handle Hospital, Distributor, and Alt Site pricing
                                       }//end of if pq.Sales_Org_Key__c
                                    else{
                                        System.debug('*** Else after If pq.Sales_Org_Key__c == US103010 || pq.Sales_Org_Key__c == US6010 || pq.Sales_Org_Key__c == CA1010 ***');
                                        //Start of US6020 ZD Pricing Only
                                        if(soMap.containsKey(pq.Sales_Org_Key__c) && soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                            System.debug('*** IN Distributor List LOGIC Pricing_Type__c refresh ***');
                                            if(mcheck.Distributor_List__c != 0.00){
                                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                            }
                                            else{
                                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                            }
                                        }
                                        else{
                                            //All other Sales Orgs
                                            if(mcheck.List_Price__c != 0.00){
                                                prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                            }
                                            else{
                                                prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                            }
                                        }//end else for pq.Sales_org_Key__c = US6020
                                    }//end of else pq.Sales_Org_Key__c
                                    //end of refresh
                                }
                                //prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                            }
                            
                            //check for SAP Agreement null or blank value
                            
                            prodQuoteLineItem1.Sales_Number__c = SAP_1stPick;
                            IF(SAP_1stPick != null){
                                System.debug('*** SAP_1stPick != null sapList[0].AgrObjective__c *** ' + sapList[0].AgrObjective__c);
                                //customer service rebate only check
                                if(sapList[0].AgrObjective__c == '06' && userRoleBoolean ){
                                    System.debug('*** Customer Service Rebate Only Sales Deal Description ***');
                                    prodQuoteLineItem1.Sales_deal_Description__c = NULL;
                                }
                                else{
                                    prodQuoteLineItem1.Sales_deal_Description__c = sap.AgrDesc__c;
                                }
                                
                            }
                            else{
                                prodQuoteLineItem1.Sales_deal_Description__c = 'No Contract';
                            }
                            
                            //cross reference check
                            If(crossStr != null && crossStr != 'refresh'){
                                prodQuoteLineItem1.Competetive_Product__c = crossStr;
                            }
                            
                            system.debug('*** prodQuoteLineItem1.Sales_Number__c: ' + prodQuoteLineItem1.Sales_Number__c);
                            system.debug('*** prodQuoteLineItem1.Sales_deal_Description__c: ' + prodQuoteLineItem1.Sales_deal_Description__c);
                            
                            prodQuoteLineItem1.Condition__c = conremap;
                            
                            If(lineItemId != NULL){
                                prodQuoteLineItem1.Id = lineItemId;
                                prodQuoteLineItem1.Hide_Crossreference__c = false;
                            }
                            
                            qLineItem.add(prodQuoteLineItem1);
                            system.debug('*** qLineItem ======================== ' + qLineItem);
                        }
                    } // End of SAP for(SAPRealPriceSet__x sap : sapList)
                    
                } // End of Else after if(pq.Account_Name__r.SAP_Sold_To__c == NULL)
                
                If(qLineItem.size() > 0){
                    system.debug('*** qLineItem ======================= ' + qLineItem);
                    if(lineItemId == NULL){
                        insert qLineItem;
                        //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, mcheck.Name + ' added to quote: ' + pq.Price_Quote_Name__c));
                        
                        //conditions below helps with Price Quote and PRF Approval Matrix Routing
                        if(pq.BusinessUnit__c == 'Alternate Care'){
                            lineClassCheck(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Anesthesia'){
                            lineProdCheckAnes(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Interventional Capital' || pq.BusinessUnit__c == 'Cardiac'){
                            lineProdCheckIcap(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Surgical Instruments'){
                            lineClassCheck(quoteId);
                        }
                    }
                    else{
                        update qLineItem;
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Updated ' + mcheck.Name + ' on Price Quote: ' + pq.Price_Quote_Name__c));
                        
                        //conditions below helps with Price Quote and PRF Approval Matrix Routing
                        if(pq.BusinessUnit__c == 'Alternate Care'){
                            lineClassCheck(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Anesthesia'){
                            lineProdCheckAnes(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Interventional Capital' || pq.BusinessUnit__c == 'Cardiac'){
                            lineProdCheckIcap(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Surgical Instruments'){
                            lineClassCheck(quoteId);
                        }
                    }
                    
                }
                
            }//end of outtermost try after IF(pq.InApproval__c)
            catch(Exception e){
                System.debug('*** e getSapPrice *** ' + e);
                //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
            }
        }//end of 1st else after IF(pq.InApproval__c)
        
    }//End New SAP Price Logic
    */
/**********SIVA-Copy of new method LOGIC for EMEA materials-05-12-2023****************/
    global void getSAPprice(List<String> materialStr,String crossStr,String lineItemId, String quoteId){
        // Initiatal Values
        system.debug('*** getSAPprice materialStr ======================= ' + materialStr);
        //system.debug('*** getSAPprice crossStr ======================= ' + crossStr);
        //system.debug('*** getSAPprice lineItemId ======================= ' + lineItemId);
        system.debug('*** getSAPprice quoteId ======================= ' + quoteId);
        /*if(Test.isRunningTest()){
            userRoleBoolean = FALSE;
        }*/
        //system.debug('*** userRoleBoolean getSAPprice ======================= ' + userRoleBoolean);
        
        String soldToType; //Variable to hold Sold To Price List Type
        
        boolean refresh = FALSE;
        if(!String.isBlank(crossStr) && crossStr == 'refresh'){
            refresh = TRUE;
        }
        
        Price_Quote__c pq = [Select Id, Name, Status__c, Sales_Org_Key__c, Account_Name__r.SAP_Sold_To__c, BusinessUnit__c,
                             Line_Count__c, Account_Name__r.Account_Group__c, CurrencyIsoCode, Account_Name__r.Id, Type__c,
                             Price_Quote_Name__c, InApproval__c, Owner_Business_Unit__c, Account_Name__r.Price_List_Type__c
                             FROM Price_Quote__c
                             WHERE Id =:quoteId limit 1];
        
        Decimal rowOrder = pq.Line_Count__c;
        if(pq.Sales_Org_Key__c == NULL){
            pq.Sales_Org_Key__c = 'US6010';
        }
        //system.debug('*** getSAPprice pq.Account_Name__r.SAP_Sold_To__c ====================== 1 ' + pq.Account_Name__r.SAP_Sold_To__c);
        //system.debug('*** getSAPprice pq.Sales_Org_Key__c *** ' + pq.Sales_Org_Key__c);
        //System.debug('*** getSAPprice soMap.get(pq.Sales_Org_Key__c) *** ' + soMap.get(pq.Sales_Org_Key__c));
        //System.debug('*** getSAPprice soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c *** ' + soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c );
        IF(pq.InApproval__c){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Cannot add Material to an Approved Quote, please create a new quote and then try again or click Revise/Clone and try again.'));
        }
        else{
            try{
                String SAP_1stPick = '00000000';
                List<SAPRealPriceSet__x> listSAP = new List<SAPRealPriceSet__x>();
                List<Price_Quote_Line_Item__c> qLineItem = new List<Price_Quote_Line_Item__c>();
                Product2 mcheck = new Product2();
                /*list<Product2> mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c,
                List_Price__c, RSM_Price__c, Rep_Price__c
                //Image_URL__c, Material_Status__c
                FROM Product2
                WHERE Id IN :materialStr];*/
                system.debug('*** materialStr ====================== getSAPprice 1 ' + materialStr);
                
                //adding logic for ASK Agreements
                if(pq.Type__c == 'ASK Agreement'){
                    mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c,Brand_Name__c, Cost__c,
                              List_Price__c, RSM_Price__c, Rep_Price__c, Director_Price__c, Floor_Price__c,
                              Product_Description_Custom__c, Material_Status_Numeric__c, Description, Cost_Formula__c,
                              Distributor_List__c, Alt_Site_List__c, MRP_Group__c, SearchableProducts__c, Min_Order_Qty__c
                              FROM Product2
                              WHERE Id IN :materialStr
                              AND Duplicate__c = FALSE AND ASK_Custom_Kit__c = TRUE
                              LIMIT 1];
                }
                else{
                    mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c,Brand_Name__c, Cost__c,
                              List_Price__c, RSM_Price__c, Rep_Price__c, Director_Price__c, Floor_Price__c,
                              Product_Description_Custom__c, Material_Status_Numeric__c, Description, Cost_Formula__c,
                              Distributor_List__c, Alt_Site_List__c, MRP_Group__c, SearchableProducts__c, Min_Order_Qty__c
                              FROM Product2
                              WHERE Id IN :materialStr
                              AND Duplicate__c = FALSE AND SearchableProducts__c = TRUE
                              LIMIT 1];
                }
                //end of ASK Agreement logic
                
                system.debug('*** mcheck ====================== getSAPprice 1' + mcheck);
                //system.debug('*** pq.Account_Name__r.SAP_Sold_To__c ====================== 2 ' + pq.Account_Name__r.SAP_Sold_To__c);
                if(pq.Account_Name__c !=null && pq.Account_Name__r.SAP_Sold_To__c == NULL){
                    system.debug('*** Starting getPrice without SAP ***');
                    ++rowOrder;
                    
                    Price_Quote_Line_Item__c prodQuoteLineItem1 = new Price_Quote_Line_Item__c(
                        Price_Quote__c = pq.Id,
                        Material_Name__c = mcheck.Id,
                        //List_Price__c = mcheck.List_Price__c,
                        RSM_Price__c = mcheck.RSM_Price__c,
                        Rep_Price__c = mcheck.Rep_Price__c,
                        Director_Price__c = mcheck.Director_Price__c,
                        Floor_Price__c = mcheck.Floor_Price__c,
                        Cost__c = mcheck.Cost_Formula__c,
                        //Eligible_Price__c = mcheck.List_Price__c,
                        Material_Status__c = mcheck.Material_Status_Numeric__c,
                        Row_Order__c = rowOrder,
                        MRP_Group__c = mcheck.MRP_Group__c,
                        CurrencyIsoCode = pq.CurrencyIsoCode,
                        Min_Order_Qty__c = mcheck.Min_Order_Qty__c
                    );

                    //Checking for EMEA BU and User to add Minimum Order Quantity
                    if(pq.BusinessUnit__c == 'EMEA' || userRoleName.containsIgnoreCase('EMEA')){
                        System.debug('*** Is EMEA User ***' );
                        if(mcheck.Min_Order_Qty__c != NULL && mcheck.Min_Order_Qty__c != 0){
                            System.debug('*** NOT NULL or 0.... mcheck.Min_Order_Qty__c *** ' + mcheck.Min_Order_Qty__c);
                            prodQuoteLineItem1.Min_Order_Qty__c = mcheck.Min_Order_Qty__c;
                            prodQuoteLineItem1.Quantity__c = mcheck.Min_Order_Qty__c;
                        }
                        else{
                            System.debug('*** Is NULL or 0.... mcheck.Min_Order_Qty__c *** ' + mcheck.Min_Order_Qty__c);
                            prodQuoteLineItem1.Min_Order_Qty__c = 1;
                        }
                    }
                    
                    //System.debug('*** lineItemId getSapPrice *** ' + lineItemId);
                    if(lineItemId == NULL){
                        //check for surgical custom product description
                        if(mcheck.Product_Description_Custom__c != NULL){
                            prodQuoteLineItem1.Product_Description__c = mcheck.Product_Description_Custom__c;
                        }
                        else{
                            prodQuoteLineItem1.Product_Description__c = mcheck.Description;
                        }
                        
                        //logic to handle Hospital, Distributor, and Alt Site pricing
                        //Alt Site Accounts
                        System.debug('*** pq.Account_Name__r.Price_List_Type__c getSapPrice lineItemId == Null *** ' + pq.Account_Name__r.Price_List_Type__c);
                        if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){ 
                            //add Canada
                            System.debug('*** In if pq.Sales_Org_Key__c == US103010 OR CA1010 *** ');
                            System.debug('*** soldToType *** ' + soldToType);
                            //Alt Site Accounts
                            if(pq.Account_Name__r.Price_List_Type__c == 'ZA'){
                                System.debug('*** In Alt Site List Pricing ***');
                                if(mcheck.Alt_Site_List__c != 0.00){
                                    prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                    prodQuoteLineItem1.Sales_Price__c = mcheck.Alt_Site_List__c;
                                    prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                }
                                else{
                                    prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                    prodQuoteLineItem1.Sales_Price__c = 0.00;
                                    prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                }
                            }
                        
                            //Distributor Accounts
                            if(pq.Account_Name__c!=null && pq.Account_Name__r.Price_List_Type__c == 'ZD'){
                                System.debug('*** In Distributor List Pricing ***');
                                if(mcheck.Distributor_List__c != 0.00){
                                    prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                    prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                    prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                }
                                else{
                                    prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                    prodQuoteLineItem1.Sales_Price__c = 0.00;
                                    prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                }
                            }
                        
                            //Hospital Accounts
                            if(pq.Account_Name__c!=null && pq.Account_Name__r.Price_List_Type__c == 'ZH' || pq.Account_Name__r.Price_List_Type__c == ''){
                                System.debug('*** In Hospital List Pricing ***');
                                if(mcheck.List_Price__c != 0.00){
                                    prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                    prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                    prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                }
                                else{
                                    prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                    prodQuoteLineItem1.Sales_Price__c = 0.00;
                                    prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                }
                            }
                           //end of logic to handle Hospital, Distributor, and Alt Site pricing
                        }//end of if pq.Sales_Org_Key__c
                        else{
                            System.debug('*** Distributor List for Prospect Customer/No SAP ***');
                            if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                            }
                            else{
                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                            }
                        }//end of else of pq.Sales_Org_Key__c
                        //end of logic to handle Hospital, Distributor, and Alt Site pricing
                        
                        if(pq.BusinessUnit__c == 'EMEA'){
                            prodQuoteLineItem1.Quantity__c = mcheck.Min_Order_Qty__c;
                            prodQuoteLineItem1.Row_Order__c = pq.Line_Count__c;
                        }else{
                            prodQuoteLineItem1.Quantity__c = 1;
                            prodQuoteLineItem1.Row_Order__c = pq.Line_Count__c;
                        }
                    }//end of if(lineItemId == NULL)
                    else{
                        prodQuoteLineItem1.Id = lineItemId;
                        prodQuoteLineItem1.Hide_Crossreference__c = false;
                    }//end of else after if(lineItemId == NULL)
                    
                    //cross reference check
                    If(crossStr != null && crossStr != 'refresh'){
                        prodQuoteLineItem1.Competetive_Product__c = crossStr;
                    }
                    
                    //add object to list
                    qLineItem.add(prodQuoteLineItem1);
                    system.debug('*** qLineItem ======================== ' + qLineItem);
                    
                }//end of if(pq.Account_Name__r.SAP_Sold_To__c == NULL)
                else{
                    system.debug('*** Starting getPrice with SAP ***');
                    List<string> cnlist = new List<String>();
                    string pcn = '';
                    String shipTo = '';
                    
                    if(pq.Account_Name__c!=null && pq.Account_Name__r.SAP_Sold_To__c!=null){
                        cnlist.add(pq.Account_Name__r.SAP_Sold_To__c);
                        pcn = pq.Account_Name__r.SAP_Sold_To__c;
                    }
                    
                    
                    if(pq.Account_Name__c!=null && pq.Account_Name__r.Account_Group__c == 'Z002'){
                        /*for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                                          FROM Contract_Partnership__c
                                                          WHERE Ship_to__c = :pq.Account_Name__r.SAP_Sold_To__c
                                                          AND Disabled__c = FALSE])*/
                        for(Contract_Partnership__c cp : getContractPartnership(pq.Account_Name__r.SAP_Sold_To__c))
                        {
                            cnlist.add(cp.Sale_to__c);
                            pcn = cp.Sale_to__c;
                        }
                        shipTo = pcn; 
                        
                    }
                    else{
                        shipTo = pq.Account_Name__r?.SAP_Sold_To__c;
                    }
                    
                    //Query to get Price List Type of SAP Sold To Account
                    soldToType = [SELECT Price_List_Type__c FROM Account WHERE SAP_Sold_To__c = :pcn LIMIT 1].Price_List_Type__c;
                    system.debug('*** pcn (Primary Customer Number) ================ ' + pcn);
                    system.debug('*** cnlist (Customer Number List) ================= ' + cnlist);
                    
                    //Move this to Constructor to avoid repetitive SOQl Query
                    /*Map<String, String> cMap = new Map<String, String>();
                    for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
                        cMap.put(scm.Name, scm.Mapped_Value__c);
                    }
                    system.debug('*** cMap ============== ' + cMap);*/
                    
                    Map<String, String> obMap = new Map<String, String>();
                    obMap.put('01', 'Direct/Rebate');
                    obMap.put('02', 'Direct');
                    obMap.put('03', 'Distributor Netbill');
                    obMap.put('04', 'Specialty Market');
                    obMap.put('05', 'Strategic Accounts');
                    obMap.put('06', 'Rebate Only');
                    system.debug('*** obMap ============== ' + obMap);
                    
                    system.debug('*** mcheck.Sales_Org__c b4 SAP ============== ' + mcheck.Sales_Org__c);
                    system.debug('*** mcheck.Distribution_Channel__c b4 SAP============== ' + mcheck.Distribution_Channel__c);
                    system.debug('*** pcn b4 SAP============== ' + pcn);
                    system.debug('*** mcheck.Name b4 SAP============== ' + mcheck.Name);
                    datetime datenew = datetime.now();
                    List<SAPRealPriceSet__x> sapList = new List<SAPRealPriceSet__x>();
                    if(Test.isRunningTest()) {
                        for(Integer i = 0; i < 3; i++){
                            Decimal testPrice = i == 2 ? 0.00 : 123.00;
                            SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
                                SalesDeal__c = '50009064',
                                Price__c = testPrice,
                                Material__c = '353535',
                                MtrlStatus__c = '40',
                                SalesMtrlStatus__c = '40',
                                ValidFrom__c = Date.Today(),
                                ValidTo__c = Date.Today() + 1000,
                                AgrDesc__c = 'Duke University SURGR',
                                Condition__c = 'XNAF',
                                OwnerName__c = 'Duke Univ Health System',
                                Owner__c = 'IDN-032',
                                AgrObjective__c = '06',
                                Customer__c  = '0000102059'
                            );
                            sapList.add(testSAP);
                        }
                    }//end if(!Test.isRunningTest())
                    else{    
                        sapList = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c,
                                   ValidFrom__c, ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                   OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                   DistChnl__c,MatDesc__c,vat__c,Currency__c,ShipTo__c
                                   FROM SAPRealPriceSet__x
                                   WHERE SalesOrg__c = :mcheck.Sales_Org__c
                                   AND DistChnl__c = :mcheck.Distribution_Channel__c
                                   AND Customer__c = :pcn
                                   AND Material__c = :mcheck.Name
                                   AND ShipTo__c = :shipTo
                                   AND EffDate__c = :datetime.now()
                                  ];
                    }
                        //************************************* Start Rebate Only Check *******************************************
                        System.debug('*** sapList[0].AgrObjective__c *** ' + sapList[0].AgrObjective__c);
                        System.debug('*** sapList[0].SalesDeal__c *** ' + sapList[0].SalesDeal__c);
                        String compDeal = sapList[0].SalesDeal__c;
                        //System.debug('*** userRole crossBulk *** ' + userRole);
                        if(sapList.size()>0 && sapList[0].AgrObjective__c == '06' && userRoleBoolean ){
                            System.debug('*** IN REBATE ONLY CHECK ***');
                            //SAP_1stPick = sapList[0].Agreement_Number__c.right(8);
                            list<String> ccaList = new list<String>();
                            if(cnlist.size()>0){
                                for(Contract_Customer__c cc : [SELECT Agreement__r.Agreement_Number__c
                                                               FROM Contract_Customer__c
                                                               WHERE Account__r.SAP_Sold_To__c IN :cnlist
                                                               AND Agreement__r.Objective__c != '06'
                                                               AND Active__c = TRUE])
                                {
                                    ccaList.add(cc.Agreement__r.Agreement_Number__c);
                                }
                            }
                            System.debug('*** ccalist:' + ccaList);
                            
                            /*
                            for(Integer i=0;i<ccaList.size();i++){
                            if(ccaList.get(i) == compDeal.right(8)){
                            System.debug('*** In if ccaList.get(i) ***:' + ccaList.get(i));
                            System.debug('*** In if sapList[0].Agreement__c ***:' + sapList[0].Agreement__c);
                            ccaList.remove(i);
                            }
                            }
                            */
                            System.debug('*** ccalist 2:' + ccaList);
                            // Contract Material List - Used to filter the Contract Customers
                            list<String> cmList = new list<String>();
                            // Material Map - Used to filter...
                            map<String, String> matMap = new map<String, String>();
                            for(Contract_Material__c cm : [SELECT Product__r.Name, Agreement__r.Agreement_Number__c, Agreement__r.Sales_Org__c
                                                           FROM Contract_Material__c
                                                           WHERE Product__r.Id = :materialStr
                                                           AND Agreement_Number__c IN :ccaList
                                                           AND Active__c = TRUE
                                                           ORDER BY Price__c
                                                           LIMIT 1])
                            {
                                cmList.add(cm.Agreement__r.Agreement_Number__c);
                                matMap.put(cm.Agreement__r.Agreement_Number__c, cm.Product__r.Name);
                            }
                            System.debug('*** cmList.size: ' + cmList.size());
                            System.debug('*** cmList *** ' + cmList );
                            
                            sapList.remove(0);
                            //**************************** Start Contract Customer Lookup ************************************
                            /*for(Contract_Customer__c cc : [SELECT Agreement__r.Agreement_Number__c, Account__r.SAP_Sold_To__c, Condition__c
                                                           FROM Contract_Customer__c
                                                           WHERE Agreement__r.Agreement_Number__c IN :cmList
                                                           AND Account__r.SAP_Sold_To__c IN :cnlist
                                                           AND Active__c = TRUE
                                                           order by Condition_Rank__c
                                                           LIMIT 10])*/
                            for(Contract_Customer__c cc: getContractCustomer(cmList, cnlist))
                            {
                                sapList = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c, ValidFrom__c,
                                           ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                           OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                           DistChnl__c,MatDesc__c,vat__c,Currency__c,ShipTo__c
                                           FROM SAPRealPriceSet__x
                                           WHERE SalesOrg__c = :mcheck.Sales_Org__c
                                           AND DistChnl__c = :mcheck.Distribution_Channel__c
                                           AND Agreement__c = :cc.Agreement__r.Agreement_Number__c
                                           AND Customer__c = :cc.Account__r.SAP_Sold_To__c
                                           AND Material__c = :matMap.get(cc.Agreement__r.Agreement_Number__c)
                                           AND ShipTo__c = :shipTo
                                           AND EffDate__c = :datetime.now()
                                           LIMIT 1 ];
                                System.debug('*** sapList *** ' + sapList );
                            }
                            //**************************** End Contract Customer Lookup ************************************
                        }
                        //************************************* Start Rebate Only Check *******************************************
                        
                    //}//end of esle after if(Test.isRunningTest())
                    
                    if(sapList!=null && sapList.size()>0){
                        for(SAPRealPriceSet__x sap : sapList)
                        {
                            //SAPRealPriceSet__x sap = newSAP;
                            
                            system.debug('*** in SAP for loop ================== ');
                            system.debug('*** sap ================== ' + sap);
                            //system.debug('*** sap.Price__c ================== ' + sap.Price__c);
                            string objname;
                            string mstatus;
                            ++rowOrder;
                            
                            string conremap = sap.Condition__c;
                            if(cMap.size()>0 && cMap.containsKey(sap.Condition__c) && cMap.get(sap.Condition__c) != NULL){
                                conremap = cMap.get(sap.Condition__c);
                            }
                            
                            if(sap.SalesDeal__c != NULL){
                                if(sap.AgrObjective__c !=NULL && sap.AgrObjective__c == '06' && userRoleBoolean ){
                                    //SAP_1stPick = 'No Contract';
                                    SAP_1stPick = sap.SalesDeal__c.right(8);
                                }
                                else{
                                    SAP_1stPick = sap.SalesDeal__c.right(8);
                                }    
                            }
                            else{
                                SAP_1stPick = 'No Contract';
                            }
                            system.debug('*** SAP_1stPick ================ ' + SAP_1stPick);
                            
                            String cnum2;
                            // Strip the leading zero's - 06Jul2016 ESC
                            if(sap.Customer__c != NULL){
                                cnum2 = sap.Customer__c.replaceAll('^0+', '');
                            }
                            // Checks to see if the Sales Material Status Exists and if it does we use that, otherwise we default
                            // to the standard Material Status. - 06Jul2016 ESC
                            if(sap.SalesMtrlStatus__c != NULL){
                                mstatus = sap.SalesMtrlStatus__c;
                            }
                            else if(sap.MtrlStatus__c != NULL){
                                mstatus = sap.MtrlStatus__c;
                            }
                            
                            Price_Quote_Line_Item__c prodQuoteLineItem1 = new Price_Quote_Line_Item__c(
                                Price_Quote__c = pq.Id,
                                Material_Name__c = mcheck.Id,
                                Material_Status__c = mstatus,
                                //List_Price__c = mcheck.List_Price__c,
                                RSM_Price__c = mcheck.RSM_Price__c,
                                Rep_Price__c = mcheck.Rep_Price__c,
                                Director_Price__c = mcheck.Director_Price__c,
                                Floor_Price__c = mcheck.Floor_Price__c,
                                Cost__c = mcheck.Cost_Formula__c,
                                Objective__c = sap.AgrObjective__c,
                                MRP_Group__c = mcheck.MRP_Group__c,
                                Min_Order_Qty__c = mcheck.Min_Order_Qty__c
                                //CurrencyIsoCode = pq.CurrencyIsoCode
                            );
                            
                            /***EMEA USER logic ******/
                            //Checking for EMEA BU and User to add Minimum Order Quantity
                            if(pq.BusinessUnit__c == 'EMEA' || userRoleName.containsIgnoreCase('EMEA')){
                                System.debug('*** Is EMEA User ***' );
                                if(mcheck.Min_Order_Qty__c != NULL && mcheck.Min_Order_Qty__c != 0){
                                    System.debug('*** NOT NULL or 0.... mcheck.Min_Order_Qty__c *** ' + mcheck.Min_Order_Qty__c);
                                    prodQuoteLineItem1.Min_Order_Qty__c = mcheck.Min_Order_Qty__c;
                                    prodQuoteLineItem1.Quantity__c = mcheck.Min_Order_Qty__c;
                                }
                                else{
                                    System.debug('*** Is NULL or 0.... mcheck.Min_Order_Qty__c *** ' + mcheck.Min_Order_Qty__c);
                                    prodQuoteLineItem1.Min_Order_Qty__c = 1;
                                }
                            }

                            system.debug('****BU*****'+ pq.Businessunit__c);
                            if(pq.Businessunit__c == 'EMEA'){
                                system.debug('****VAT*****'+ prodQuoteLineItem1.VAT__c);
                                prodQuoteLineItem1.Material_Description__c=sap.MatDesc__c;
                                prodQuoteLineItem1.CurrencyIsoCode = sap.Currency__c;
                                if(sap.VAT__c == NULL){
                                    prodQuoteLineItem1.VAT__c = NULL;
                                }
                                 else{
                                    system.debug('****DESC*****'+ prodQuoteLineItem1.Material_Description__c);
                                    prodQuoteLineItem1.VAT__c = Decimal.Valueof(sap.Vat__c);
                                     }
                            }
                            else{
                                
                                prodQuoteLineItem1.CurrencyIsoCode = pq.CurrencyIsoCode;
                            }
                             system.debug('****PQLI*****'+ prodQuoteLineItem1);
                            
                            if(lineItemId == NULL){
                                //check for surgical custom product description
                                if(mcheck.Product_Description_Custom__c != NULL){
                                    prodQuoteLineItem1.Product_Description__c = mcheck.Product_Description_Custom__c;
                                    
                                }
                                else{
                                    prodQuoteLineItem1.Product_Description__c = mcheck.Description;
                                }
                                
                                if(pq.BusinessUnit__c == 'EMEA'){
                                    prodQuoteLineItem1.Quantity__c = mcheck.Min_Order_Qty__c;
                                    prodQuoteLineItem1.Row_Order__c = pq.Line_Count__c;
                                }else{
                                    prodQuoteLineItem1.Quantity__c = 1;
                                    prodQuoteLineItem1.Row_Order__c = pq.Line_Count__c;
                                }
                            }
                            
                            //check for eligible price = 0
                            if(sap.Price__c != NULL && sap.Price__c != 0.00){
                                System.debug('*** sap.Price__c != 0.00 *** ');
                                if(!refresh){
                                    System.debug('*** if(!refresh) sap.Price__c != 0.00 *** ');
                                    prodQuoteLineItem1.Sales_Price__c = sap.Price__c;
                                    system.debug('******TROUBLESHOOT******' +  sap.Price__c);
                                }
                                prodQuoteLineItem1.Eligible_Price__c = sap.Price__c;
                                
                                //logic to handle Hospital, Distributor, and Alt Site pricing
                                
                                //start of check for Customer Service Rebate Only
                                if(sapList[0].AgrObjective__c!=NULL && sapList[0].AgrObjective__c == '06' && userRoleBoolean ){
                                    //prodQuoteLineItem1.Sales_Price__c = sap.Price__c;
                                    //prodQuoteLineItem1.Eligible_Price__c = sap.Price__c;
                                    
                                    if(soldToType == 'ZA'){
                                        System.debug('*** In Alt Site List Pricing for if sap.Price__c != 0.00 ***');
                                        prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                        prodQuoteLineItem1.Sales_Price__c = mcheck.Alt_Site_List__c;
                                        prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                    }
                                    
                                    //Distributor Accounts
                                    if(soldToType == 'ZD'){
                                        System.debug('*** In Distributor List Pricing for if sap.Price__c != 0.00 ***');
                                        prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                        prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                        prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                    }
                                    
                                    //Hospital Accounts
                                    if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                        System.debug('*** In Hospital List Pricing for if sap.Price__c != 0.00 ***');
                                        prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                        prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                        prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                    }
                                }
                                //end of check for Customer Service Rebate Only
                                System.debug('*** soMap.get(pq.Sales_Org_Key__c) *** ' + soMap.get(pq.Sales_Org_Key__c));
                                System.debug('*** soMap.get(pq.Sales_Org_Key__c)..Pricing_Type__c *** ' + soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c );
                                if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){ 
                                       //add Canada
                                       System.debug('*** In if pq.Sales_Org_Key__c == US103010 OR CA1010 *** ');
                                       System.debug('*** soldToType *** ' + soldToType);
                                       //Alt Site Accounts
                                       if(soldToType == 'ZA'){
                                           System.debug('*** In Alt Site List Pricing for if sap.Price__c != 0.00 ***');
                                           prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                       }
                                       
                                       //Distributor Accounts
                                       if(soldToType == 'ZD'){
                                           System.debug('*** In Distributor List Pricing for if sap.Price__c != 0.00 ***');
                                           prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                       }
                                       
                                       //Hospital Accounts
                                       if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                           System.debug('*** In Hospital List Pricing for if sap.Price__c != 0.00 ***');
                                           prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                       }
                                       //end of logic to handle Hospital, Distributor, and Alt Site pricing
                                   }//end of if pq.Sales_Org_Key__c
                                else{
                                    System.debug('*** In Hospital List Pricing for non US/CA Accounts after if sap.Price__c != 0.00 ***');
                                    if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                        prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                    }
                                    else{
                                        prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                    }
                                }//end of else of pq.Sales_Org_Key__c
                                
                            }//end of if sap.price__c != 0.00
                            else{
                                System.debug('*** Else after If sap.price__c != 0.00 ***');
                                if(!refresh){
                                    //logic to handle Hospital, Distributor, and Alt Site pricing
                                    System.debug('*** if(!refresh) *** ');
                                    if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                                        System.debug('*** IN All LOGIC Pricing_Type__c !refresh ***');
                                           //Alt Site Accounts
                                           if(soldToType == 'ZA'){
                                               System.debug('*** In Alt Site List Pricing !refresh ***');
                                               if(mcheck.Alt_Site_List__c != 0.00){
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                                   prodQuoteLineItem1.Sales_Price__c = mcheck.Alt_Site_List__c;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                               }
                                               else{
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                                   prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                               }
                                           }
                                           
                                           //Distributor Accounts
                                           if(soldToType == 'ZD'){
                                               System.debug('*** In Distributor List Pricing !refresh ***');
                                               if(mcheck.Distributor_List__c != 0.00){
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                   prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                               }
                                               else{
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                   prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                               }
                                           }
                                           
                                           //Hospital Accounts
                                           if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                               System.debug('*** In Hospital List Pricing !refresh ***');
                                               if(mcheck.List_Price__c != 0.00){
                                                   prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                   prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                               }
                                               else{
                                                   prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                   prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                               }
                                           }
                                           //end of logic to handle Hospital, Distributor, and Alt Site pricing
                                       }//end of if pq.Sales_Org_Key__c
                                    else{
                                        System.debug('*** Else after If pq.Sales_Org_Key__c == US103010 || pq.Sales_Org_Key__c == US6010 || pq.Sales_Org_Key__c == CA1010 ***');
                                        //Start of US6020 ZD Pricing Only
                                        if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                            System.debug('*** IN Distributor List LOGIC Pricing_Type__c !refresh ***');
                                            if(mcheck.Distributor_List__c != 0.00){
                                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                            }
                                            else{
                                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                            }
                                        }
                                        else{
                                            //All other Sales Orgs
                                            if(mcheck.List_Price__c != 0.00){
                                                prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                            }
                                            else{
                                                prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                            }
                                        }//end else for pq.Sales_org_Key__c = US6020
                                    }//end of else pq.Sales_Org_Key__c
                                }//end of if(!refresh)
                                else{//after if(!refresh)
                                    //start of refresh
                                    System.debug('*** if(!refresh) else *** ');
                                    if(soMap.containsKey(pq.Sales_Org_Key__c) && soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                                        System.debug('*** IN All LOGIC Pricing_Type__c refresh ***');
                                           //Alt Site Accounts
                                           if(soldToType == 'ZA'){
                                               System.debug('*** In Alt Site List Pricing !refresh ***');
                                               if(mcheck.Alt_Site_List__c != 0.00){
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                                   //prodQuoteLineItem1.Sales_Price__c = mcheck.Alt_Site_List__c;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                               }
                                               else{
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                                   prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                               }
                                           }
                                           
                                           //Distributor Accounts
                                           if(soldToType == 'ZD'){
                                               System.debug('*** In Distributor List Pricing refresh ***');
                                               if(mcheck.Distributor_List__c != 0.00){
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                   //prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                               }
                                               else{
                                                   prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                   //prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                               }
                                           }
                                           
                                           //Hospital Accounts
                                           if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                               System.debug('*** In Hospital List Pricing refresh ***');
                                               if(mcheck.List_Price__c != 0.00){
                                                   prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                   //prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                               }
                                               else{
                                                   prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                   //prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                   prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                               }
                                           }
                                           //end of logic to handle Hospital, Distributor, and Alt Site pricing
                                       }//end of if pq.Sales_Org_Key__c
                                    else{
                                        System.debug('*** Else after If pq.Sales_Org_Key__c == US103010 || pq.Sales_Org_Key__c == US6010 || pq.Sales_Org_Key__c == CA1010 ***');
                                        //Start of US6020 ZD Pricing Only
                                        if(soMap.containsKey(pq.Sales_Org_Key__c) && soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                            System.debug('*** IN Distributor List LOGIC Pricing_Type__c refresh ***');
                                            if(mcheck.Distributor_List__c != 0.00){
                                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                            }
                                            else{
                                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                            }
                                        }
                                        else{
                                            //All other Sales Orgs
                                            if(mcheck.List_Price__c != 0.00){
                                                prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                            }
                                            else{
                                                prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                                prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                            }
                                        }//end else for pq.Sales_org_Key__c = US6020
                                    }//end of else pq.Sales_Org_Key__c
                                    //end of refresh
                                }
                                //prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                            }
                            
                            //check for SAP Agreement null or blank value
                            
                            prodQuoteLineItem1.Sales_Number__c = SAP_1stPick;
                            IF(SAP_1stPick != null){
                                System.debug('*** SAP_1stPick != null sapList[0].AgrObjective__c *** ' + sapList[0].AgrObjective__c);
                                //customer service rebate only check
                                if(sapList[0].AgrObjective__c!=NULL && sapList[0].AgrObjective__c == '06' && userRoleBoolean ){
                                    System.debug('*** Customer Service Rebate Only Sales Deal Description ***');
                                    prodQuoteLineItem1.Sales_deal_Description__c = NULL;
                                }
                                else{
                                    prodQuoteLineItem1.Sales_deal_Description__c = sap.AgrDesc__c;
                                }
                                
                            }
                            else{
                                prodQuoteLineItem1.Sales_deal_Description__c = 'No Contract';
                            }
                            
                            //cross reference check
                            If(crossStr != null && crossStr != 'refresh'){
                                prodQuoteLineItem1.Competetive_Product__c = crossStr;
                            }
                            
                            system.debug('*** prodQuoteLineItem1.Sales_Number__c: ' + prodQuoteLineItem1.Sales_Number__c);
                            system.debug('*** prodQuoteLineItem1.Sales_deal_Description__c: ' + prodQuoteLineItem1.Sales_deal_Description__c);
                            
                            prodQuoteLineItem1.Condition__c = conremap;
                            
                            If(lineItemId != NULL){
                                prodQuoteLineItem1.Id = lineItemId;
                                prodQuoteLineItem1.Hide_Crossreference__c = false;
                            }
                            
                            qLineItem.add(prodQuoteLineItem1);
                            system.debug('*** qLineItem ======================== ' + qLineItem);
                        }
                    } // End of SAP for(SAPRealPriceSet__x sap : sapList)
                    
                } // End of Else after if(pq.Account_Name__r.SAP_Sold_To__c == NULL)
                
                If(qLineItem.size() > 0){
                    system.debug('*** qLineItem ======================= ' + qLineItem);
                    if(lineItemId == NULL){
                        insert qLineItem;
                        //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, mcheck.Name + ' added to quote: ' + pq.Price_Quote_Name__c));
                        
                        //conditions below helps with Price Quote and PRF Approval Matrix Routing
                        if(pq.BusinessUnit__c == 'Alternate Care'){
                            lineClassCheck(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Anesthesia'){
                            lineProdCheckAnes(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Interventional Capital' || pq.BusinessUnit__c == 'Cardiac'){
                            lineProdCheckIcap(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Surgical Instruments'){
                            lineClassCheck(quoteId);
                        }
                        
                    }
                    else{
                        update qLineItem;
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Updated ' + mcheck.Name + ' on Price Quote: ' + pq.Price_Quote_Name__c));
                        
                        //conditions below helps with Price Quote and PRF Approval Matrix Routing
                        if(pq.BusinessUnit__c == 'Alternate Care'){
                            lineClassCheck(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Anesthesia'){
                            lineProdCheckAnes(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Interventional Capital' || pq.BusinessUnit__c == 'Cardiac'){
                            lineProdCheckIcap(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Surgical Instruments'){
                            lineClassCheck(quoteId);
                        }
                        
                    }
                    
                }
                
            }//end of outtermost try after IF(pq.InApproval__c)
            catch(Exception e){
                System.debug('*** e getSapPrice *** ' + e);
                //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
            }
        }//end of 1st else after IF(pq.InApproval__c)
        
    }//End New SAP Price Logic

    /************************** Lightning Updates ************************/
    /* public CustomMessage getSAPpriceForAura(List<String> materialStr,String crossStr,String lineItemId, String quoteId){
        CustomMessage customMsg;
        String soldToType; //Variable to hold Sold To Price List Type
        
        boolean refresh = FALSE;
        if(crossStr == 'refresh'){
            refresh = TRUE;
        }
        
        Price_Quote__c pq = [Select Id, Name, Status__c, Sales_Org_Key__c, Account_Name__r.SAP_Sold_To__c, BusinessUnit__c,
                             Line_Count__c, Account_Name__r.Account_Group__c, CurrencyIsoCode, Account_Name__r.Id, Type__c,
                             Price_Quote_Name__c, InApproval__c, Owner_Business_Unit__c, Account_Name__r.Price_List_Type__c
                             FROM Price_Quote__c
                             WHERE Id =:quoteId limit 1];
        
        Decimal rowOrder = pq.Line_Count__c;
        IF(pq.InApproval__c){
            customMsg = new CustomMessage(ApexPages.Severity.INFO, 'Cannot add Material to an Approved Quote, please create a new quote and then try again or click Revise/Clone and try again.');
        }
        else{
            try{
                String SAP_1stPick = '00000000';
                List<SAPRealPriceSet__x> listSAP = new List<SAPRealPriceSet__x>();
                List<Price_Quote_Line_Item__c> qLineItem = new List<Price_Quote_Line_Item__c>();
                Product2 mcheck = new Product2();
                
                //adding logic for ASK Agreements
                if(pq.Type__c == 'ASK Agreement'){
                    mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c,Brand_Name__c, Cost__c,
                              List_Price__c, RSM_Price__c, Rep_Price__c, Director_Price__c, Floor_Price__c,
                              Product_Description_Custom__c, Material_Status_Numeric__c, Description, Cost_Formula__c,
                              Distributor_List__c, Alt_Site_List__c, MRP_Group__c, SearchableProducts__c
                              FROM Product2
                              WHERE Id IN :materialStr
                              AND Duplicate__c = FALSE AND ASK_Custom_Kit__c = TRUE
                              LIMIT 1];
                }
                else{
                    mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c,Brand_Name__c, Cost__c,
                              List_Price__c, RSM_Price__c, Rep_Price__c, Director_Price__c, Floor_Price__c,
                              Product_Description_Custom__c, Material_Status_Numeric__c, Description, Cost_Formula__c,
                              Distributor_List__c, Alt_Site_List__c, MRP_Group__c, SearchableProducts__c
                              FROM Product2
                              WHERE Id IN :materialStr
                              AND Duplicate__c = FALSE AND SearchableProducts__c = TRUE
                              LIMIT 1];
                }
                //end of ASK Agreement logic
                
                if(pq.Account_Name__r.SAP_Sold_To__c == NULL){
                    ++rowOrder;
                    
                    Price_Quote_Line_Item__c prodQuoteLineItem1 = new Price_Quote_Line_Item__c(
                        Price_Quote__c = pq.Id,
                        Material_Name__c = mcheck.Id,
                        RSM_Price__c = mcheck.RSM_Price__c,
                        Rep_Price__c = mcheck.Rep_Price__c,
                        Director_Price__c = mcheck.Director_Price__c,
                        Floor_Price__c = mcheck.Floor_Price__c,
                        Cost__c = mcheck.Cost_Formula__c,
                        Material_Status__c = mcheck.Material_Status_Numeric__c,
                        Row_Order__c = rowOrder,
                        MRP_Group__c = mcheck.MRP_Group__c,
                        CurrencyIsoCode = pq.CurrencyIsoCode
                    );
                    
                    if(lineItemId == NULL){
                        //check for surgical custom product description
                        if(mcheck.Product_Description_Custom__c != NULL){
                            prodQuoteLineItem1.Product_Description__c = mcheck.Product_Description_Custom__c;
                        }
                        else{
                            prodQuoteLineItem1.Product_Description__c = mcheck.Description;
                        }
                        
                        //logic to handle Hospital, Distributor, and Alt Site pricing
                        //Alt Site Accounts
                        if(pq.Account_Name__r.Price_List_Type__c == 'ZA'){
                            if(mcheck.Alt_Site_List__c != 0.00){
                                prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                prodQuoteLineItem1.Sales_Price__c = mcheck.Alt_Site_List__c;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                            }
                            else{
                                prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                            }
                        }
                        
                        //Distributor Accounts
                        if(pq.Account_Name__r.Price_List_Type__c == 'ZD'){
                            if(mcheck.Distributor_List__c != 0.00){
                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                            }
                            else{
                                prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                            }
                        }
                        
                        //Hospital Accounts
                        if(pq.Account_Name__r.Price_List_Type__c == 'ZH' || pq.Account_Name__r.Price_List_Type__c == ''){
                            if(mcheck.List_Price__c != 0.00){
                                prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                            }
                            else{
                                prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                prodQuoteLineItem1.Sales_Price__c = 0.00;
                                prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                            }
                        }
                        
                        prodQuoteLineItem1.Quantity__c = 1;
                        prodQuoteLineItem1.Row_Order__c = pq.Line_Count__c;
                    }
                    else{
                        prodQuoteLineItem1.Id = lineItemId;
                        prodQuoteLineItem1.Hide_Crossreference__c = false;
                    }
                    
                    //cross reference check
                    If(crossStr != null && crossStr != 'refresh'){
                        prodQuoteLineItem1.Competetive_Product__c = crossStr;
                    }
                    
                    //add object to list
                    qLineItem.add(prodQuoteLineItem1);
                    
                }
                else{
                    List<string> cnlist = new List<String>();
                    cnlist.add(pq.Account_Name__r.SAP_Sold_To__c);
                    
                    string pcn = pq.Account_Name__r.SAP_Sold_To__c;
                    if(pq.Account_Name__r.Account_Group__c == 'Z002'){
                        for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                                          FROM Contract_Partnership__c
                                                          WHERE Ship_to__c = :pq.Account_Name__r.SAP_Sold_To__c
                                                          AND Disabled__c = FALSE])
                        {
                            cnlist.add(cp.Sale_to__c);
                            pcn = cp.Sale_to__c;
                        }
                        
                        
                    }
                    //Query to get Price List Type of SAP Sold To Account
                    soldToType = [SELECT Price_List_Type__c FROM Account WHERE SAP_Sold_To__c = :pcn LIMIT 1].Price_List_Type__c;
                    
                    Map<String, String> cMap = new Map<String, String>();
                    for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
                        cMap.put(scm.Name, scm.Mapped_Value__c);
                    }
                    
                    Map<String, String> obMap = new Map<String, String>();
                    obMap.put('01', 'Direct/Rebate');
                    obMap.put('02', 'Direct');
                    obMap.put('03', 'Distributor Netbill');
                    obMap.put('04', 'Specialty Market');
                    obMap.put('05', 'Strategic Accounts');
                    obMap.put('06', 'Rebate Only');

                    datetime datenew = datetime.now();
                    List<SAPRealPriceSet__x> sapList = new List<SAPRealPriceSet__x>();
                    if(Test.isRunningTest()) {
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
                    }
                    else{    
                        sapList = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c,
                                   ValidFrom__c, ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                   OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                   DistChnl__c
                                   FROM SAPRealPriceSet__x
                                   WHERE SalesOrg__c = :mcheck.Sales_Org__c
                                   AND DistChnl__c = :mcheck.Distribution_Channel__c
                                   AND Customer__c = :pcn
                                   AND Material__c = :mcheck.Name
                                   AND EffDate__c = :datetime.now()
                                  ];
                    }
                        //************************************* Start Rebate Only Check *******************************************
                        String compDeal = sapList[0].SalesDeal__c;
                        if( sapList[0].AgrObjective__c == '06' && userRoleBoolean ){
                            list<String> ccaList = new list<String>();
                            for(Contract_Customer__c cc : [SELECT Agreement__r.Agreement_Number__c
                                                           FROM Contract_Customer__c
                                                           WHERE Account__r.SAP_Sold_To__c IN :cnlist
                                                           AND Active__c = TRUE])
                            {
                                ccaList.add(cc.Agreement__r.Agreement_Number__c);
                            }

                            // Contract Material List - Used to filter the Contract Customers
                            list<String> cmList = new list<String>();
                            // Material Map - Used to filter...
                            map<String, String> matMap = new map<String, String>();
                            for(Contract_Material__c cm : [SELECT Product__r.Name, Agreement__r.Agreement_Number__c, Agreement__r.Sales_Org__c
                                                           FROM Contract_Material__c
                                                           WHERE Product__r.Id = :materialStr
                                                           AND Agreement_Number__c IN :ccaList
                                                           AND Active__c = TRUE
                                                           ORDER BY Price__c
                                                           LIMIT 1])
                            {
                                cmList.add(cm.Agreement__r.Agreement_Number__c);
                                matMap.put(cm.Agreement__r.Agreement_Number__c, cm.Product__r.Name);
                            }
                            
                            sapList.remove(0);
                            //**************************** Start Contract Customer Lookup ************************************
                            for(Contract_Customer__c cc : [SELECT Agreement__r.Agreement_Number__c, Account__r.SAP_Sold_To__c, Condition__c
                                                           FROM Contract_Customer__c
                                                           WHERE Agreement__r.Agreement_Number__c IN :cmList
                                                           AND Account__r.SAP_Sold_To__c IN :cnlist
                                                           AND Active__c = TRUE
                                                           order by Condition_Rank__c
                                                           LIMIT 10])
                            {
                                sapList = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c, ValidFrom__c,
                                           ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                           OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                           DistChnl__c
                                           FROM SAPRealPriceSet__x
                                           WHERE SalesOrg__c = :mcheck.Sales_Org__c
                                           AND DistChnl__c = :mcheck.Distribution_Channel__c
                                           AND Agreement__c = :cc.Agreement__r.Agreement_Number__c
                                           AND Customer__c = :cc.Account__r.SAP_Sold_To__c
                                           AND Material__c = :matMap.get(cc.Agreement__r.Agreement_Number__c)
                                           AND EffDate__c = :datetime.now()
                                           LIMIT 1 ];
                            }
                        }

                    for(SAPRealPriceSet__x sap : sapList)
                    {
                        string objname;
                        string mstatus;
                        ++rowOrder;
                        
                        string conremap = sap.Condition__c;
                        if(cMap.get(sap.Condition__c) != NULL){
                            conremap = cMap.get(sap.Condition__c);
                        }
                        
                        if(sap.SalesDeal__c != NULL){
                            if( sap.AgrObjective__c == '06' && userRoleBoolean ){
                                SAP_1stPick = 'No Contract';
                            }
                            else{
                                SAP_1stPick = sap.SalesDeal__c.right(8);
                            }
                            
                        }
                        else{
                            SAP_1stPick = 'No Contract';
                        }
                        
                        String cnum2;
                        // Strip the leading zero's - 06Jul2016 ESC
                        if(sap.Customer__c != NULL){
                            cnum2 = sap.Customer__c.replaceAll('^0+', '');
                        }
                        // Checks to see if the Sales Material Status Exists and if it does we use that, otherwise we default
                        // to the standard Material Status. - 06Jul2016 ESC
                        if(sap.SalesMtrlStatus__c != NULL){
                            mstatus = sap.SalesMtrlStatus__c;
                        }
                        else if(sap.MtrlStatus__c != NULL){
                            mstatus = sap.MtrlStatus__c;
                        }
                        
                        Price_Quote_Line_Item__c prodQuoteLineItem1 = new Price_Quote_Line_Item__c(
                            Price_Quote__c = pq.Id,
                            Material_Name__c = mcheck.Id,
                            Material_Status__c = mstatus,
                            RSM_Price__c = mcheck.RSM_Price__c,
                            Rep_Price__c = mcheck.Rep_Price__c,
                            Director_Price__c = mcheck.Director_Price__c,
                            Floor_Price__c = mcheck.Floor_Price__c,
                            Cost__c = mcheck.Cost_Formula__c,
                            Objective__c = sap.AgrObjective__c,
                            MRP_Group__c = mcheck.MRP_Group__c,
                            CurrencyIsoCode = pq.CurrencyIsoCode
                        );
                        
                        if(lineItemId == NULL){
                            //check for surgical custom product description
                            if(mcheck.Product_Description_Custom__c != NULL){
                                prodQuoteLineItem1.Product_Description__c = mcheck.Product_Description_Custom__c;
                            }
                            else{
                                prodQuoteLineItem1.Product_Description__c = mcheck.Description;
                            }
                            
                            prodQuoteLineItem1.Quantity__c = 1;
                            prodQuoteLineItem1.Row_Order__c = rowOrder;
                        }
                        
                        //check for eligible price = 0
                        if(sap.Price__c != 0.00){
                            if(!refresh){
                                prodQuoteLineItem1.Sales_Price__c = sap.Price__c;
                            }
                            prodQuoteLineItem1.Eligible_Price__c = sap.Price__c;
                            
                            //logic to handle Hospital, Distributor, and Alt Site pricing
                            
                            //start of check for Customer Service Rebate Only
                            if(sapList[0].AgrObjective__c == '06' && userRoleBoolean ){
                                
                                if(soldToType == 'ZA'){
                                    prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                    prodQuoteLineItem1.Sales_Price__c = mcheck.Alt_Site_List__c;
                                    prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                }
                                
                                //Distributor Accounts
                                if(soldToType == 'ZD'){
                                    prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                    prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                    prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                }
                                
                                //Hospital Accounts
                                if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                    prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                    prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                    prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                }
                            }
                            //end of check for Customer Service Rebate Only
                            if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){ 
                                   //add Canada
                                   //Alt Site Accounts
                                   if(soldToType == 'ZA'){
                                       prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                   }
                                   
                                   //Distributor Accounts
                                   if(soldToType == 'ZD'){
                                       prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                   }
                                   
                                   //Hospital Accounts
                                   if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                       prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                   }
                               }
                            else{
                                if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                    prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                }
                                else{
                                    prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                }
                            }
                        }
                        else{
                            if(!refresh){
                                //logic to handle Hospital, Distributor, and Alt Site pricing
                                if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                                       //Alt Site Accounts
                                       if(soldToType == 'ZA'){
                                           if(mcheck.Alt_Site_List__c != 0.00){
                                               prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                               prodQuoteLineItem1.Sales_Price__c = mcheck.Alt_Site_List__c;
                                               prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                           }
                                           else{
                                               prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                               prodQuoteLineItem1.Sales_Price__c = 0.00;
                                               prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                           }
                                       }
                                       
                                       //Distributor Accounts
                                       if(soldToType == 'ZD'){
                                           if(mcheck.Distributor_List__c != 0.00){
                                               prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                               prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                               prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                           }
                                           else{
                                               prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                               prodQuoteLineItem1.Sales_Price__c = 0.00;
                                               prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                           }
                                       }
                                       
                                       //Hospital Accounts
                                       if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                           if(mcheck.List_Price__c != 0.00){
                                               prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                               prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                               prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                           }
                                           else{
                                               prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                               prodQuoteLineItem1.Sales_Price__c = 0.00;
                                               prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                           }
                                       }
                                   }
                                else{
                                    //Start of US6020 ZD Pricing Only
                                    if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                        if(mcheck.Distributor_List__c != 0.00){
                                            prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                            prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                            prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                        }
                                        else{
                                            prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                            prodQuoteLineItem1.Sales_Price__c = 0.00;
                                            prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                        }
                                    }
                                    else{
                                        //All other Sales Orgs
                                        if(mcheck.List_Price__c != 0.00){
                                            prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                            prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                            prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                        }
                                        else{
                                            prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                            prodQuoteLineItem1.Sales_Price__c = 0.00;
                                            prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                        }
                                    }
                                }
                            }
                            else{
                                if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
                                       //Alt Site Accounts
                                       if(soldToType == 'ZA'){
                                           if(mcheck.Alt_Site_List__c != 0.00){
                                               prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                               prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                           }
                                           else{
                                               prodQuoteLineItem1.List_Price__c = mcheck.Alt_Site_List__c;
                                               prodQuoteLineItem1.Sales_Price__c = 0.00;
                                               prodQuoteLineItem1.Eligible_Price__c = mcheck.Alt_Site_List__c;
                                           }
                                       }
                                       
                                       //Distributor Accounts
                                       if(soldToType == 'ZD'){
                                           if(mcheck.Distributor_List__c != 0.00){
                                               prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                               prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                           }
                                           else{
                                               prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                               prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                           }
                                       }
                                       
                                       //Hospital Accounts
                                       if(soldToType == 'ZH' || soldToType == '' || soldToType == NULL){
                                           if(mcheck.List_Price__c != 0.00){
                                               prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                               prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                           }
                                           else{
                                               prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                               prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                           }
                                       }
                                   }
                                else{
                                    //Start of US6020 ZD Pricing Only
                                    if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'Distributor List' ){
                                        if(mcheck.Distributor_List__c != 0.00){
                                            prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                            prodQuoteLineItem1.Sales_Price__c = mcheck.Distributor_List__c;
                                            prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                        }
                                        else{
                                            prodQuoteLineItem1.List_Price__c = mcheck.Distributor_List__c;
                                            prodQuoteLineItem1.Sales_Price__c = 0.00;
                                            prodQuoteLineItem1.Eligible_Price__c = mcheck.Distributor_List__c;
                                        }
                                    }
                                    else{
                                        //All other Sales Orgs
                                        if(mcheck.List_Price__c != 0.00){
                                            prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                            prodQuoteLineItem1.Sales_Price__c = mcheck.List_Price__c;
                                            prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                        }
                                        else{
                                            prodQuoteLineItem1.List_Price__c = mcheck.List_Price__c;
                                            prodQuoteLineItem1.Sales_Price__c = 0.00;
                                            prodQuoteLineItem1.Eligible_Price__c = mcheck.List_Price__c;
                                        }
                                    }
                                }
                            }
                        }
                        
                        //check for SAP Agreement null or blank value
                        
                        prodQuoteLineItem1.Sales_Number__c = SAP_1stPick;
                        IF(SAP_1stPick != null){
                            //customer service rebate only check
                            if(sapList[0].AgrObjective__c == '06' && userRoleBoolean ){
                                prodQuoteLineItem1.Sales_deal_Description__c = NULL;
                            }
                            else{
                                prodQuoteLineItem1.Sales_deal_Description__c = sap.AgrDesc__c;
                            }
                            
                        }
                        else{
                            prodQuoteLineItem1.Sales_deal_Description__c = 'No Contract';
                        }
                        
                        //cross reference check
                        If(crossStr != null && crossStr != 'refresh'){
                            prodQuoteLineItem1.Competetive_Product__c = crossStr;
                        }
                        
                        prodQuoteLineItem1.Condition__c = conremap;
                        
                        If(lineItemId != NULL){
                            prodQuoteLineItem1.Id = lineItemId;
                            prodQuoteLineItem1.Hide_Crossreference__c = false;
                        }
                        
                        qLineItem.add(prodQuoteLineItem1);
                    }
                    
                }
                
                If(qLineItem.size() > 0){
                    if(lineItemId == NULL){
                        insert qLineItem;
                        customMsg = new CustomMessage(ApexPages.Severity.CONFIRM, mcheck.Name + ' added to quote: ' + pq.Price_Quote_Name__c);
                        
                        //conditions below helps with Price Quote and PRF Approval Matrix Routing
                        if(pq.BusinessUnit__c == 'Alternate Care'){
                            lineClassCheck(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Anesthesia'){
                            lineProdCheckAnes(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Interventional Capital' || pq.BusinessUnit__c == 'Cardiac'){
                            lineProdCheckIcap(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Surgical Instruments'){
                            lineClassCheck(quoteId);
                        }
                    }
                    else{
                        update qLineItem;
                        customMsg = new CustomMessage(ApexPages.Severity.CONFIRM, 'Updated ' + mcheck.Name + ' on Price Quote: ' + pq.Price_Quote_Name__c);
                        
                        //conditions below helps with Price Quote and PRF Approval Matrix Routing
                        if(pq.BusinessUnit__c == 'Alternate Care'){
                            lineClassCheck(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Anesthesia'){
                            lineProdCheckAnes(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Interventional Capital' || pq.BusinessUnit__c == 'Cardiac'){
                            lineProdCheckIcap(quoteId);
                        }
                        
                        if(pq.BusinessUnit__c == 'Surgical Instruments'){
                            lineClassCheck(quoteId);
                        }
                    }
                    
                }
                
            }
            catch(Exception e){
                System.debug('*** e getSapPrice *** ' + e);
                customMsg = new CustomMessage(ApexPages.Severity.Error, 'Error detected: ' + e);
            }
        }

        return customMsg;
    }
    
    public class CustomMessage {
        @AuraEnabled
        public String serverity;
        
        @AuraEnabled
        public String message;
    
        public CustomMessage(ApexPages.Severity pageServerity, String message) {
            this.serverity = pageServerity.name();
            this.message = message;
        }
    }
*/



}//end of class