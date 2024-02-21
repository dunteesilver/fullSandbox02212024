/*********************************************************************
* Description     : Controller Class for PP_Price_QuoteRB Page
* Test Class      : PP_Price_QuoteRB_Test
* VisualForce     : PP_Price_QuoteRB
* Author          : Dun Silver
**********************************************************************/

Public with sharing class PP_Price_QuoteRB{
    
    public String strMats{get;set;}
    public String strProdSearch{get;set{strProdSearch = value;}}
    public String strCrossSearch{get;set{strCrossSearch = value;}}
    //public String strQtyChange{get;set{strQtyChange = value;}}
    public String strQtyChange{get;set;}
    public String strQuoteId{get;set;}
    public String pqlid{get;set{pqlid = value;}}
    public String delId{get;set;}
    public ApexPages.StandardController c;
    public Price_Quote__c pq {get;set;}
    public List<Price_Quote_Line_Item__c> lineItems;
    public String boolVal {get;set;}
    
    //start of sales deal stuff
    public String selectedValue {get;set;}
    public String lineItemId {get;set;}
    public String matValue {get;set;}
    public String rowId {get;set;}
    
    //Variable used in pricing logic to determine list price
    Public Map<String,Sales_Orgs__c> soMap {get{
        Map<String,Sales_Orgs__c> soMapNew = new Map<String,Sales_Orgs__c>();
        List<Sales_Orgs__c> soList = [SELECT Id,Name, Sales_Org__c, Distribution_Channel__c, Pricing_Type__c FROM Sales_Orgs__c WHERE Active__c = true];
        
        if(soList.size() > 0){
            for(Sales_Orgs__c curr : soList){
                soMapNew.put(curr.Name,curr);
            }//end for loop
        }//end if
        return soMapNew;
    }set;}
    
    //boolean for re-rendering button to red to go through approval process
    public Boolean subButton {get{
        List<Price_Quote__c> pQuote = [Select Id, Approval_Flag_Rollup__c, One_Time_Purchase__c FROM Price_Quote__c
                                       WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        if(pQuote[0].Approval_Flag_Rollup__c >= 1 && pQuote[0].One_Time_Purchase__c){
            return true;
        }else{
            return false;
        }
        
    }set;}
    
    //boolean for re-rendering button to blue to skip through approval process
    public Boolean comButton {get{
        List<Price_Quote__c> pQuote1 = [Select Id, Approval_Flag_Rollup__c, One_Time_Purchase__c FROM Price_Quote__c
                                        WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        if(pQuote1[0].Approval_Flag_Rollup__c < 1){
            return true;
        }else{
            return false;
        }
        
    }set;}
    
    public Decimal lineCount {get{
        
        List<Price_Quote__c> lcounter = [Select Id, Line_Count__c FROM Price_Quote__c WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        if(lcounter.size() > 0){
            lineCount = lcounter[0].Line_Count__c;
            return lineCount;
        }else{
            lineCount = 0;
            return lineCount;
        }
        
    }set;}
    
    //boolean for re-rendering button to blue to skip through approval process
    public Boolean reviseButton {get{
        List<Price_Quote__c> lCount = [Select Id, Line_Count__c FROM Price_Quote__c WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        if(lCount[0].Line_Count__c > 0){
            return true;
        }else{
            return false;
        }
    }set;}
    
    public Decimal grandTotal {get{
        List<Price_Quote__c> total = [Select Id, Grand_Total__c FROM Price_Quote__c WHERE Id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        grandTotal = total[0].Grand_Total__c;
        return grandTotal;
    }set;}
    
    //get count of Line Items with Cross Reference
    public Boolean hasCrossRef {get{
        Integer crossCount = [SELECT count() FROM Price_Quote_Line_Item__c WHERE Price_Quote__c =:ApexPages.currentPage().getParameters().get('pqid') AND Competetive_Product__c != null];
        if(crossCount > 0){
            return true;
        }else{
            return false;
        }
    }set;}
    
    //start of constructor
    public PP_Price_QuoteRB(ApexPages.StandardController controller) {
        strQuoteId = ApexPages.currentPage().getParameters().get('pqid');
        pq = (strQuoteId == null) ? new Price_Quote__c() :
        [Select Id, Name,Opportunity__r.Name, Opportunity__c, Price_Quote_Name__c, Status__c, Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Internal_Comments_Only__c,
         Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity, Account_Name__r.BillingState,
         Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c,Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c,
         Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Owner_Cell__c, Owner_Phone__c, Owner_Email__c, Contact_Name__r.name,
         Business_Unit__c, Contact_Name__r.id, Contact_Name__r.phone, Contact_Name__r.email, LastModifiedById, CreatedById, InApproval__c,
         Territory__r.Territory_Name__c, Territory__r.Territory_Number__c,Approval_Flag_Rollup__c,CurrencyIsoCode,Owner_Business_Unit__c,
         Sales_Org_Key__c,Line_Count__c,One_Time_Purchase__c,PRF__c,(SELECT Id,Name,Quantity__c FROM Price_Quote_Line_Items__r)
         FROM Price_Quote__c WHERE id = :strQuoteId];
             //(Price_Quote__c)controller.getRecord();
             system.debug('pq ===================================== ' + pq);
        c = controller;
        
    }//end of constructor
    
    public boolean hasError { get; set; }
    
    //method to get quote info
    public Price_Quote__c getpq(){
        Price_Quote__c pq = new Price_Quote__c();
        Price_Quote__c plist = [Select Id, Name, Status__c, Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Internal_Comments_Only__c,
                                Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity, Account_Name__r.BillingState,
                                Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c,Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c,
                                Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Owner_Cell__c, Owner_Phone__c, Owner_Email__c, Contact_Name__r.name,
                                Business_Unit__c, Contact_Name__r.id, Contact_Name__r.phone, Contact_Name__r.email, LastModifiedById, CreatedById, PRF__c,
                                CurrencyIsoCode,Sales_Org_Key__c, Line_Count__c,Owner_Business_Unit__c, InApproval__c,One_Time_Purchase__c FROM Price_Quote__c
                                WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        system.debug('plist ============================== ' + plist);
        if(plist != null){
            grandTotal = plist.Grand_Total__c;
            pq = plist;
        }
        return pq;
    }
    //end of method to get quote info
    
    //start of method to get line items
    public List<Price_Quote_Line_Item__c> getLineItems(){
        strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
        List<Price_Quote_Line_Item__c> lineItems = [Select id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c,Objective_Name__c,Objective__c,
                                                    Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c, Product_Description__c,
                                                    Sales_deal_Description__c, Sales_Number__c, Row_Order__c, Competetive_Product__r.Competitor_Product_Code__c, Material_Name__r.Name,
                                                    Description__c,Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Rep_Price__c, List_Price__c, Line_Price__c,
                                                    Material_Status_Description__c, IsBold__c, Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, MRP_Group__c,
                                                    Hide_Crossreference__c, Material_Name__r.Brand_Name__c FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c=: strQuoteId
                                                    ORDER BY Row_Order__c NULLS LAST];
        
        system.debug('lineItems: ' + lineItems);
        
        return lineItems;
    }
    //end of method to get line items
    
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
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a valid quantity...'));
            return null;
        }
        else{
            Integer qty = Integer.valueOf(strQtyChange);
            system.debug('qty ============================================= ' + qty);
            List<Price_Quote_Line_Item__c> updItems = new List<Price_Quote_Line_Item__c>();
            //List<Price_Quote_Line_Item__c> lineItems = [Select id,Sales_Price__c,Quantity__c,List_Price__c
            //From Price_Quote_Line_Item__c Where Price_Quote__c=: strQuoteId];
            
            for(Price_Quote_Line_Item__c curr : [Select id,Sales_Price__c,Quantity__c,List_Price__c
                                                 From Price_Quote_Line_Item__c Where Price_Quote__c=: strQuoteId
                                                 AND Material_Name__c != NULL]){
                                                     curr.Quantity__c = qty;
                                                     curr.Extended_Price__c = curr.List_Price__c * qty;
                                                     updItems.add(curr);
                                                 }
            
            try{
                database.update(updItems, false);
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
            
            return null;
        }
    }
    
    //mass delete line items
    public PageReference massDelItems(){
        //strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
        delId = apexpages.currentpage().getparameters().get('delId');
        system.debug('delId =============================== ' + delId);
        List<Price_Quote_Line_Item__c> delLine = [Select Id,Price_Quote__c From Price_Quote_Line_Item__c WHERE Price_Quote__c =:delId];
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
        pqlid = apexpages.currentpage().getparameters().get('itemId');
        //strQuoteId = apexpages.currentpage().getparameters().get('pqId');
        system.debug('pqlid =============================== ' + pqlid);
        //system.debug('strQuoteId=============================== ' + strQuoteId);
        system.debug('IN REMOVINGROW METHOD!!!!!!!!!!!!!!!');
        List<Price_Quote_Line_Item__c> delLine = [Select Id From Price_Quote_Line_Item__c WHERE id =:pqlid];
        system.debug('delLine =============================== ' + delLine);
        //delete delLine;
        
        try{
            delete delLine;
            sort();
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
                id=lineId,Sales_Price__c=myRSMPrice,
                Extended_Price__c=myRSMPrice * myLineQty,
                Requested_Pricing__c = NULL
            );
            
            Database.update(mypql, false);
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
            lineItems = [Select id,Sales_Price__c,Quantity__c,RSM_Price__c,Extended_Price__c
                         From Price_Quote_Line_Item__c Where id=: lineId LIMIT 1];
            Price_Quote_Line_Item__c mypql = new Price_Quote_Line_Item__c(
                id=lineId,Sales_Price__c=myrepPrice,
                Extended_Price__c=myrepPrice * myLineQty,
                Requested_Pricing__c = NULL
            );
            
            Database.update(mypql, false);
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
                id=lineId,Sales_Price__c=myListPrice,
                Extended_Price__c=myListPrice * myLineQty,
                Requested_Pricing__c = NULL
            );
            
            Database.update(mypql, false);
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
                id=lineId,Sales_Price__c=myEligiblePrice,
                Extended_Price__c=myEligiblePrice * myLineQty,
                Requested_Pricing__c = NULL
            );
            
            database.update(mypql, false);
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
            
            for(Price_Quote_Line_Item__c curr : [Select id,Sales_Price__c,Quantity__c,List_Price__c,Extended_Price__c
                                                 From Price_Quote_Line_Item__c Where Price_Quote__c=: strQuoteId
                                                 AND Material_Name__c != NULL]){
                                                     curr.Sales_price__c = curr.List_Price__c;
                                                     curr.Extended_Price__c = curr.Sales_Price__c * curr.Quantity__c;
                                                     curr.Requested_Pricing__c = NULL;
                                                     updItems.add(curr);
                                                 }
            
            Database.update(updItems, false);
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
    //mass RSM Price update
    public PageReference massUpdRSM(){
        try{
            strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
            List<Price_Quote_Line_Item__c> updItems = new List<Price_Quote_Line_Item__c>();
            
            for(Price_Quote_Line_Item__c curr : [Select id,Sales_Price__c,Quantity__c,RSM_Price__c,Extended_Price__c
                                                 From Price_Quote_Line_Item__c Where Price_Quote__c=: strQuoteId
                                                 AND Material_Name__c != NULL]){
                                                     curr.Sales_price__c = curr.RSM_Price__c;
                                                     curr.Extended_Price__c = curr.Sales_Price__c * curr.Quantity__c;
                                                     curr.Requested_Pricing__c = NULL;
                                                     updItems.add(curr);
                                                 }
            
            database.update(updItems, false);
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
            
            for(Price_Quote_Line_Item__c curr : [Select id,Sales_Price__c,Quantity__c,Rep_Price__c,Extended_Price__c
                                                 From Price_Quote_Line_Item__c Where Price_Quote__c=: strQuoteId
                                                 AND Material_Name__c != NULL]){
                                                     curr.Sales_price__c = curr.Rep_Price__c;
                                                     curr.Extended_Price__c = curr.Sales_Price__c * curr.Quantity__c;
                                                     curr.Requested_Pricing__c = NULL;
                                                     updItems.add(curr);
                                                 }
            Database.update(updItems,false);
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
            
            for(Price_Quote_Line_Item__c curr : [Select id,Sales_Price__c,Quantity__c,Eligible_Price__c,Extended_Price__c
                                                 From Price_Quote_Line_Item__c Where Price_Quote__c=: strQuoteId
                                                 AND Material_Name__c != NULL]){
                                                     curr.Sales_price__c = curr.Eligible_Price__c;
                                                     curr.Extended_Price__c = curr.Sales_Price__c * curr.Quantity__c;
                                                     curr.Requested_Pricing__c = NULL;
                                                     updItems.add(curr);
                                                 }
            
            Database.update(updItems, false);
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
    public static string isNewLine(String value){
        return value;
    }
    
    //method to get SAP Price
    public PageReference sapPrice(){
        List<String> prods = new List<String>();
        List<Product2> currProd = [Select Id,Name From Product2 Where Name =:strProdSearch AND ASK_Custom_Kit__c = FALSE LIMIT 1];
        if(pq.Status__c == 'Approved'){
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sorry, cannot add line items to an approved quote..'));
            return null;
        }
        else if(currProd.size()<1){
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a valid material..'));
            return null;
        }
        else{
            system.debug('strProdSearch ================== ' + strProdSearch);
            system.debug('pq.Sales_Org_Key__c: ' + pq.Sales_Org_Key__c);
            
            for(Product2 curr : [Select Id
                                 FROM Product2
                                 WHERE Name =:strProdSearch
                                 AND Sales_Org_Key__c =:pq.Sales_Org_Key__c
                                 AND Duplicate__c = FALSE
                                 ORDER BY List_Price__c DESC LIMIT 1]){
                                     prods.add(curr.Id);
                                 }
            system.debug('prods ================== ' + prods);
            
            PP_SAP_Price sapPrice = new PP_SAP_Price();
            sapPrice.getSapPrice(prods,null,null,pq.Id);
            
            boolVal = PP_Price_QuoteRB.isNewLine('true');
            return NULL;
        }
    }
    //end of SAP Price Method
    
    // Alternate Bulk Insert
    public void bulkInsert2(){
        //strMats
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
    
    public static void checkSalesOrg(list<Price_Quote__c> newTrigger){
        system.debug('-- Starting the Check Sales Org (checkSalesOrg) --');
        set<id> uid = new set<id>();
        map<id, string> soMap = new map<id, string>();
        for(Price_Quote__c pq : newTrigger){
            if(pq.Sales_Org_Key__c == NULL){
                uid.add(pq.CreatedById);
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
        
        for(Price_Quote__c pq : newTrigger){
            if(pq.Sales_Org_Key__c == NULL){
                pq.Sales_Org_Key__c = soMap.get(pq.CreatedById);
                system.debug('Fixed the Key! ' + soMap.get(pq.CreatedById));
            }
        }
    }
    
    public void updateFlag() {
        String rowId = Apexpages.currentpage().getParameters().get('trId');
        system.debug('rowId =============== ' + rowId);
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
        system.debug('materialId ====================== ' + materialId);
        system.debug('lineItemId ====================== ' + lineItemId);
        
        PP_SAP_Price sapPrice = new PP_SAP_Price();
        
        If(pq.Status__c == 'Approved'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Cannot add Material to an Approved Quote, please create a new quote and then try again or click Revise/Clone and try again.'));
            return null;
        }
        else{
            List<String> matId = new List<String>();
            matId.add(materialId);
            sapPrice.getSAPprice(matId,NULL,lineItemId,pq.Id);
            Return NULL;
        }
    }
    
    // Bulk Refresh
    public void bulkrefresh(){
        
        String pqId = ApexPages.currentPage().getParameters().get('pqId');
        String soldToType; //Variable to hold Sold To Price List Type
        
        list<Price_Quote_Line_Item__c> lineItemList = new list<Price_Quote_Line_Item__c>();
        set<String> mstringid = new set<String>();
        list<Price_Quote_Line_Item__c> pqlilist = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c, MRP_Group__c, CurrencyIsoCode
                                                   FROM Price_Quote_Line_Item__c
                                                   WHERE Price_Quote__r.Id = :pqid AND Material_Name__c != NULL
                                                   LIMIT 75];
        system.debug('pqlilist: ' + pqlilist);
        
        for(Price_Quote_Line_Item__c pqli : pqlilist){
            mstringid.add(pqli.Material_Name__r.Id);
        }
        system.debug('mstringid: ' + mstringid);
        
        try{
            Price_Quote__c pq = [SELECT Account_Name__r.SAP_Sold_To__c, Account_Name__r.Account_Group__c, Sales_Org_Key__c, Line_Count__c,
                                 CurrencyIsoCode, Account_Name__r.Price_List_Type__c
                                 FROM Price_Quote__c
                                 WHERE Id =: pqId LIMIT 1];
            system.debug('pq ====================== ' + pq);
            
            list<Product2> mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c,
                                     List_Price__c, RSM_Price__c, Rep_Price__c, MRP_Group__c, CurrencyIsoCode,
                                     Distributor_List__c, Alt_Site_List__c
                                     FROM Product2
                                     WHERE Id IN:mstringid
                                     AND Duplicate__c = FALSE];
            system.debug('mcheck ====================== ' + mcheck);
            
            // Create the Product Mapping
            map<String, Product2> prodmap = new map<String, Product2>();
            for(Product2 pmap : mcheck){
                prodmap.put(pmap.Name, pmap);
            }
            system.debug('prodmap: ' + prodmap);
            
            // Determine which SAP Number to use for Lookup
            string pcn = pq.Account_Name__r.SAP_Sold_To__c;
            if(pq.Account_Name__r.Account_Group__c == 'Z002'){
                for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                                  FROM Contract_Partnership__c
                                                  WHERE Ship_to__c =:pq.Account_Name__r.SAP_Sold_To__c])
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
            if(pq.Account_Name__r.SAP_Sold_To__c == NULL){
                system.debug('Starting getPrice without SAP');
                
                for(Price_Quote_Line_Item__c ml : pqlilist){
                    Price_Quote_Line_Item__c  pqLineItem = new Price_Quote_Line_Item__c (
                        Price_Quote__c = pq.Id,
                        Material_Name__c = prodmap.get(ml.Material_Name__r.Name).Id,
                        CurrencyIsoCode = pq.CurrencyIsoCode,
                        //List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                        RSM_Price__c = prodmap.get(ml.Material_Name__r.Name).RSM_Price__c,
                        Rep_Price__c = prodmap.get(ml.Material_Name__r.Name).Rep_Price__c,
                        MRP_Group__c = prodmap.get(ml.Material_Name__r.Name).MRP_Group__c
                        //Sales_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                        //Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c
                    );
                    
                    if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' )
                    {
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
                    }//end if pq Sales_Org_Key__c check
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
                    }//end else to if pq Sales_Org_Key__c check
                    
                    lineItemList.add(pqLineItem);
                    
                }//end for loop for(Price_Quote_Line_Item__c ml : pqlilist)
                
            }//end if(pq.Account_Name__r.SAP_Sold_To__c == NULL)
            else{
                System.debug('Starting getPrice with SAP');
                
                
                Map<String, String> cMap = new Map<String, String>();
                for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
                    cMap.put(scm.Name, scm.Mapped_Value__c);
                }
                system.debug('cMap ============== ' + cMap);
                
                //Start getting SAP info
                for(Price_Quote_Line_Item__c ml : pqlilist)
                {
                    SAPRealPriceSet__x sap = new SAPRealPriceSet__x();
                    
                    if(Test.isRunningTest()){
                        system.debug('Test Is Running ============== ' + Test.isRunningTest() );
                        if(pq.Account_Name__r.SAP_Sold_To__c == '999999'){
                            System.debug('*** Test Is Running and SAP Code 999999 ***');
                            sap = new SAPRealPriceSet__x(
                                SalesDeal__c = '50009064',
                                Price__c = 0.00,
                                Material__c = ml.Material_Name__r.name,
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
                            //sapList.add(testSAP);
                        }//end if sap code check
                        else if(Test.isRunningTest() && pq.Account_Name__r.SAP_Sold_To__c != '999999'){
                            System.debug('*** Test Is Running and SAP Code != 999999 ***');
                            sap = new SAPRealPriceSet__x(
                                SalesDeal__c = '50009064',
                                Price__c = 123.00,
                                Material__c = ml.Material_Name__r.name,
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
                            //sapList.add(testSAP); 
                        }//end sap code check
                    }//end (Test.isRunningTest())
                    else{
                       sap = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c,
                           ValidFrom__c, ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                           OwnerName__c, Owner__c, AgrObjective__c, Customer__c
                           FROM SAPRealPriceSet__x
                           WHERE SalesOrg__c =:ml.Material_Name__r.Sales_Org__c
                           AND DistChnl__c =:ml.Material_Name__r.Distribution_Channel__c
                           AND Customer__c =:pcn
                           AND Material__c =:ml.Material_Name__r.Name
                           AND EffDate__c =:datetime.now()
                          ];
                    }
                                        
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
                    
                    Price_Quote_Line_Item__c  li = new Price_Quote_Line_Item__c (
                        Price_Quote__c = pq.Id,
                        Material_Name__c = prodmap.get(ml.Material_Name__r.Name).Id,
                        Material_Status__c = sap.MtrlStatus__c,
                        CurrencyIsoCode = pq.CurrencyIsoCode,
                        //List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                        RSM_Price__c = prodmap.get(ml.Material_Name__r.Name).RSM_Price__c,
                        Rep_Price__c = prodmap.get(ml.Material_Name__r.Name).Rep_Price__c,
                        Condition__c = conremap,
                        Sales_Deal_Description__c = sap.AgrDesc__c,
                        Sales_Number__c = salesDeal,
                        Id = ml.Id,
                        Objective__c = sap.AgrObjective__c,
                        MRP_Group__c = prodmap.get(ml.Material_Name__r.Name).MRP_Group__c
                    );
                    
                    //check for eligible price = 0
                    if(sap.Price__c != 0.00){
                        //li.Sales_Price__c = sap.Price__c;
                        li.Eligible_Price__c = sap.Price__c;
                        
                        //logic to handle Hospital, Distributor, and Alt Site pricing
                        if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' ){
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
                        else{
                            li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                        }//end of else pq.Sales_Org_Key__c
                    }//end if sap.Price__c != 0.00
                    else{
                        if( soMap.get(pq.Sales_Org_Key__c).Pricing_Type__c == 'All' )
                        {
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
                        }//end if pq Sales_Org_Key__c check
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
                        }//end else to if pq Sales_Org_Key__c check
                        
                    }//end else to if sap.Price__c != 0.00
                    lineItemList.add(li);
                    System.debug('lineItemList ======================== ' + lineItemList); 
                }//end for loop for(Price_Quote_Line_Item__c ml : pqlilist)
                
            }//end else to if(pq.Account_Name__r.SAP_Sold_To__c == NULL)
            
            If(lineItemList.size() > 0){
                system.debug('lineItemList ======================= ' + lineItemList);
                system.debug('lineItemList ======================= ' + lineItemList);
                database.update(lineItemList,false);
                
                //conditions below helps with Price Quote and PRF Approval Matrix Routing
                if(pq.Owner_Business_Unit__c == 'Alternate Care'){
                    PP_SAP_Price sapPrice = new PP_SAP_Price();
                    sapPrice.lineClassCheck(pqId);
                }
                
                if(pq.Owner_Business_Unit__c == 'Anesthesia'){
                    PP_SAP_Price sapPrice = new PP_SAP_Price();
                    sapPrice.lineProdCheckAnes(pqId);
                }
                
                if(pq.Owner_Business_Unit__c == 'Interventional Capital' || pq.Owner_Business_Unit__c == 'Cardiac'){
                    PP_SAP_Price sapPrice = new PP_SAP_Price();
                    sapPrice.lineProdCheckIcap(pqId);
                }
                
            }//end if lineItemList.size() > 0
        }//end try
        catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
        }//end catch
        
    }//end method bulkRefresh
    
    //method to get gpo picklist
    public List<Rep_Bids_Contracts__c> getRepBids(){
        try{
            return [SELECT Name, Contract_Description__c
                    FROM Rep_Bids_Contracts__c
                    WHERE Active__c = TRUE ORDER BY Contract_Description__c];
        }
        catch (Exception ex){
            return NULL;
        }
    }
    
    // This is what updates the 'GPO Picklist value'
    public PageReference updateDeal() {
        //selectedGPO = selectedValue;
        String selectedValue = ApexPages.currentPage().getParameters().get('sValue');
        system.debug('*** selectedValue *** ' + selectedValue);
        List<String> materials = new List<String>();
        List<String> show = new List<String>();
        List<Contract_Material__c> conMat = new List<Contract_Material__c>();
        List<Price_Quote_Line_Item__c> updSales = new List<Price_Quote_Line_Item__c>();
        Map<String,Contract_Material__c> conMap = new Map<String,Contract_Material__c>();
        
        for(Price_Quote_Line_Item__c curr : [SELECT Id, Material_Name__r.Name FROM Price_Quote_Line_Item__c WHERE Price_Quote__c =:pq.Id]){
            materials.add(curr.Material_Name__r.Name);
        }
        
        conMat = [SELECT Id, Agreement__c, Agreement__r.Agreement_Number__c, Agreement__r.Description__c,
                  Agreement__r.GPO_Contract_Ref__c, Agreement__r.Objective_Name__c, Agreement__r.Owner__c,
                  Agreement__r.Owner_Name__c, Valid_From__c, Valid_To__c, Material_Name__c, Price__c, CurrencyIsoCode
                  FROM Contract_Material__c WHERE Agreement__r.Agreement_Number__c =:selectedValue AND Material_Name__c IN :materials
                  AND Active_Future__c = TRUE ORDER BY Agreement__r.Owner_Name__c, Agreement__r.Description__c];
        system.debug('*** conMat *** ' + conMat);
        
        if( conMat.size() > 0 ){
            try{
                
                for(Contract_Material__c curr : conMat){
                    conMap.put(curr.Material_Name__c,curr);
                }
                
                if(conMat.size() > 0 ){
                    for(Price_Quote_Line_Item__c curr : [SELECT Id, Material_Name__r.Name FROM Price_Quote_Line_Item__c WHERE Price_Quote__c =:pq.Id
                                                         AND Material_Name__r.Name IN :conMap.keySet() AND Material_Name__c != NULL]){
                                                             
                                                             curr.Sales_Deal_Description__c = '[*] ' + conMap.get(curr.Material_Name__r.Name).Agreement__r.Description__c;
                                                             curr.Sales_Price__c = conMap.get(curr.Material_Name__r.Name).Price__c;
                                                             curr.Eligible_Price__c = conMap.get(curr.Material_Name__r.Name).Price__c;
                                                             curr.Sales_Number__c = conMap.get(curr.Material_Name__r.Name).Agreement__r.Agreement_Number__c;
                                                             curr.Manually_Selected_Contract__c = true;
                                                             updSales.add(curr);
                                                             show.add(curr.Material_Name__r.Name);
                                                         }
                    String outputString = String.join(show, ', ');
                    
                    Database.update(updSales,false);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Contract(s) updated for the following materials... ' + outputString));
                    //return null;
                }
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No price for any materials for the contract selected...'));
                //return null;
            }
        }//end of outter if
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No price for any materials for the contract selected...'));
            //return null;
        }//end of outter else
        
        
        return null;
    }
    //end of mass update Sales Deal
    
    //add blank row
    public void blankRow(){
        system.debug('lineCount ***** ' + lineCount);
        Price_Quote_Line_Item__c li = new Price_Quote_Line_Item__c(Price_Quote__c=pq.Id,IsBold__c=true,Row_Order__c=lineCount+1);
        insert li;
    }
    
    //add blank row for Cross Ref Entry
    public void addCrossBlank(){
        system.debug('lineCount ***** ' + lineCount);
        Price_Quote_Line_Item__c li = new Price_Quote_Line_Item__c(Price_Quote__c=pq.Id,Row_Order__c=lineCount+1,Hide_Crossreference__c=true,Quantity__c=1);
        insert li;
    }
    
    //method to add product from cross reference
    public PageReference setMat(){
        system.debug('matValue ***** ' + matValue);
        system.debug('rowId ***** ' + rowId);
        
        List<String> prods = new List<String>();
        
        Product2 prodList = [Select Id FROM Product2 WHERE Name =:matValue AND Sales_Org_Key__c =:pq.Sales_Org_Key__c
                             AND Duplicate__c = FALSE
                             ORDER BY List_Price__c DESC];
        
        prods.add(prodlist.Id);
        PP_SAP_Price sap = new PP_SAP_Price();
        sap.getSapPrice(prods,null,rowId,pq.Id);
        return null;
    }
    
    //method to add single line Cross Reference
    public PageReference addCross(){
        system.debug('strProdSearch ***** ' + strProdSearch);
        if(strProdSearch == null || strProdSearch == ''){
            system.debug('Should be here ');
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a valid Cross Reference...'));
            return null;
        }
        else{
            List<Cross_Reference__c> comp = [SELECT Id, Competitor_Product_Code__c,Competitor_Product_Description__c,TFX_Product__c, Product__c,Competitor_Name__c,
                                             Percent_Match__c,Name,Product__r.List_Price__c,Product__r.Rep_Price__c,Product__r.RSM_price__c,Product__r.Sales_Org__c,
                                             Product__r.Distribution_Channel__c, Product__r.Name FROM Cross_Reference__c WHERE Competitor_Product_Code__c =:strProdSearch
                                             ORDER BY Percent_Match__c DESC];
            
            if(pq.Status__c == 'Approved'){
                apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sorry, cannot add line items to an approved quote...'));
                return null;
            }
            else if(comp.size()<1){
                apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a valid cross reference/No Material found to match Cross Reference...'));
                return null;
            }
            else{
                List<String> prods = new List<String>();
                prods.add(comp[0].Product__c);
                PP_SAP_Price sapPrice = new PP_SAP_Price();
                sapPrice.getSapPrice(prods,comp[0].Id,null,pq.Id);
                return null;
            }
            
            
        }
    }
    //end of single line Cross Reference
    
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
                    if((x.length() >= 4 || (x == 'SET' || x == 'LAB' || x == 'BONE' || x == 'KIT' || x == 'FOR' || x == 'JAW'
                                            || x == 'CUT' || x == 'EYE' || x == 'ART' || x == 'MED')) && x.substring(0,1).isAlpha() ){
                                                matString += x.substring(0,1).toUpperCase() + x.substring(1,x.length()).toLowerCase() + ' ';
                                            }
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
    
    //Bulk Insert Cross Reference
    public void bulkInsertCross(){
        system.debug('DOING BULK INSERT OF CROSS REFERENCE *****');
        //strMats
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
        system.debug('PASSING TO SAP PRICE CLASS getCrossBulk *****');
        sapPrice.getCrossBulk(bulkMatList,pqId);
        
    }
    
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
    public static Price_Quote_Line_Item__c updatePrice(id lineId, decimal price){
        system.debug('In updatePrice Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Price_Quote_Line_Item__c li = new Price_Quote_Line_Item__c(Id=lineId,Sales_Price__c=price);
        update li;
        return li;
    }
    
    @RemoteAction
    public static Price_Quote_Line_Item__c updateOrder(id lineId, integer row){
        system.debug('In updateOrder Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Price_Quote_Line_Item__c li = new Price_Quote_Line_Item__c(Id=lineId,Row_Order__c=row);
        update li;
        return li;
    }
    
    @RemoteAction
    public static Price_Quote_Line_Item__c updateContract(id lineId, string contract){
        Price_Quote_Line_Item__c curr = [SELECT Id, Material_Name__r.Name FROM Price_Quote_Line_Item__c WHERE Id =:lineId];
        
        try{
            system.debug('In Try of updateContract');
            Contract_Material__c conMat = [SELECT Id, Agreement__c, Agreement__r.Agreement_Number__c, Agreement__r.Description__c,
                                           Agreement__r.GPO_Contract_Ref__c, Agreement__r.Objective_Name__c, Agreement__r.Owner__c ,
                                           Agreement__r.Owner_Name__c, Valid_From__c, Valid_To__c, Material_Name__c, Price__c, CurrencyIsoCode
                                           FROM Contract_Material__c WHERE Agreement__r.Agreement_Number__c =:contract
                                           AND Material_Name__c = :curr.Material_Name__r.Name
                                           AND Active_Future__c = TRUE ORDER BY Agreement__r.Owner_Name__c, Agreement__r.Description__c LIMIT 1];
            
            system.debug('conMat ***** ' + conMat);
            if(conMat != NULL){
                Price_Quote_Line_Item__c updLineItem = new Price_Quote_Line_Item__c(Id=lineId,
                                                                                    Sales_Deal_Description__c = '[*] ' + conMat.Agreement__r.Description__c,
                                                                                    Sales_Price__c = conMat.Price__c,
                                                                                    Eligible_Price__c = conMat.Price__c,
                                                                                    Sales_Number__c = conMat.Agreement__r.Agreement_Number__c,
                                                                                    Manually_Selected_Contract__c = true);
                //updLineItem.Sales_Deal_Description__c = conMat.Agreement__r.Description__c;
                //updLineItem.Sales_Price__c = conMat.Price__c;
                //updLineItem.Eligible_Price__c = conMat.Price__c;
                //updLineItem.Sales_Number__c = conMat.Agreement__r.Agreement_Number__c;
                //updSales.add(curr);
                
                update updLineItem;
                //contract = 'None';
                return updLineItem;
            }
        }catch(Exception e){
            system.debug('In Catch of updateContract');
            Price_Quote_Line_Item__c updLineItem = new Price_Quote_Line_Item__c(Id=lineId,Product_Description__c='Error message');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No price for item '+ curr.Material_Name__r.Name + ' for the contract selected...'));
            return updLineItem;
        }
        return null;
    }
    
    @RemoteAction
    public static Price_Quote_Line_Item__c updateDesc(id lineId, string prodDesc){
        system.debug('In updateDesc Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Price_Quote_Line_Item__c li = new Price_Quote_Line_Item__c(Id=lineId,Product_Description__c=prodDesc);
        update li;
        return li;
    }
    
    @RemoteAction
    public static List<Cross_Reference__c> updateCompProd(id lineId, string compProd, string salesOrgkey){
        system.debug('In updateCompProd Remote Action!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        system.debug('compProd ***** ' + compProd);
        //String compProd1 = '%' +compProd+ '%'
        String compSearch = '%' +compProd+ '%';
        //String compSearch = [SELECT Competitor_Product_Code__c FROM Cross_Reference__c WHERE Competitor_Product_Code__c LIKE :compProd1].Id;
        
        List<Cross_Reference__c> comp = [SELECT Id, Competitor_Product_Code__c,Competitor_Product_Description__c,TFX_Product__c, Product__c,Competitor_Name__c,
                                         Percent_Match__c,Name,Product__r.List_Price__c,Product__r.Rep_Price__c,Product__r.RSM_price__c,Product__r.Sales_Org__c,
                                         Product__r.Distribution_Channel__c, Product__r.Sales_Org_Key__c, Product__r.Brand_Name__c
                                         FROM Cross_Reference__c WHERE Competitor_Product_Code__c =:compProd
                                         AND Product__r.Sales_Org_Key__c =:salesOrgKey ORDER BY Percent_Match__c DESC];
        
        system.debug('comp.size() ***** ' + comp.size());
        if(comp.size()>0){
            Price_Quote_Line_Item__c li = new Price_Quote_Line_Item__c(Id=lineId,Competetive_Product__c=comp[0].Id);
            update li;
        }
        
        return comp;
    }
}//end of class