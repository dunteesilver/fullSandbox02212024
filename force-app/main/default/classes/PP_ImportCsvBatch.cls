//PP_Global_Test_Class (importCsvTest method)
global class PP_ImportCsvBatch implements Database.Batchable<sObject> {
    
    //global final List<Id> toRefresh = new List<Id>();
    global String [] email = new String[]{};//Add here your email address here
    global final String query;
    global string pqSalesOrgKey;
    global string prfSalesOrgKey;
    
    //Variable used in pricing logic to determine list price
    global Map<String,Sales_Orgs__c> soMap {get{
        Map<String,Sales_Orgs__c> soMapNew = new Map<String,Sales_Orgs__c>();
        List<Sales_Orgs__c> soList = [SELECT Id,Name, Sales_Org__c, Distribution_Channel__c, Pricing_Type__c FROM Sales_Orgs__c WHERE Active__c = true];
        
        if(soList.size() > 0){
            for(Sales_Orgs__c curr : soList){
                system.debug('*** curr *** ' + curr);
                soMapNew.put(curr.Name,curr);
            }//end for loop
        }//end if
        return soMapNew;
    }set;}
    
    global PP_ImportCsvBatch(String q) {
        //toRefresh = refreshIds;
        query = q;
        
    }//end of constructor
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //[SELECT Id, Refresh__c FROM Price_Quote_Line_Item__c WHERE Id IN: toRefresh]
        system.debug('batch query = ' + query);
        return Database.getQueryLocator(query);
    }//end of start
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        List<Id> lineItemIdsPq = new List<Id>();
        List<Id> lineItemIdsPrf = new List<Id>();
        List<Price_Quote_Line_Item__c> pqLines = new List<Price_Quote_Line_Item__c>();
        List<PRF_Line_Item__c> prfLines = new List<PRF_Line_Item__c>();
        
        for(sObject obj : scope)
        {
            String type = obj.getSObjectType().getDescribe().getName(); //gets sObject Type
            //Logic to handle either Price_Quote_Line_Item__c or PRF_Line_Item__c
            if(type == 'Price_Quote_Line_Item__c'){
                Price_Quote_Line_Item__c pqliObj = (Price_Quote_Line_Item__c)obj; //type casting from generic sObject to Price_Quote_Line_Item__c
                if(pqliObj.Refresh__c == true){
                    //system.debug('newObj.Refresh__c before = ' + newObj.Refresh__c);
                    pqliObj.Refresh__c = false;
                    //system.debug('newObj.Refresh__c after = ' + newObj.Refresh__c);
                    lineItemIdsPq.add(pqliObj.Id);
                    pqLines.add(pqliObj);
                    pqSalesOrgKey = pqliObj.Price_Quote__r.Sales_Org_Key__c;
                }
            }//end of type if
            else{
                PRF_Line_Item__c prfliObj = (PRF_Line_Item__c)obj; //type casting from generic sObject to PRF_Line_Item__c
                if(prfliObj.Refresh__c == true){
                    //system.debug('newObj.Refresh__c before = ' + newObj.Refresh__c);
                    prfliObj.Refresh__c = false;
                    //system.debug('newObj.Refresh__c after = ' + newObj.Refresh__c);
                    lineItemIdsPrf.add(prfliObj.Id);
                    prfLines.add(prfliObj);
                    prfSalesOrgKey = prfliObj.Prf__r.Sales_Org_Key__c;
                }
            }//end of else
        }//end of for loop
        
        if(lineItemIdsPq.size() > 0){
            system.debug('*** ABOUT TO REFRESH PRICE QUOTE LINES IN BATCH PP_IMPORTCSVBATCH CLASS *** ');
            bulkRefreshPq(lineItemIdsPq);
            if(pqLines.size() > 0){
                update pqLines;
            }
        }
        
        if(lineItemIdsPrf.size() > 0){
            system.debug('*** ABOUT TO REFRESH PRF LINES IN BATCH PP_IMPORTCSVBATCH CLASS *** ');
            bulkRefreshPrf(lineItemIdsPrf);
            if(prfLines.size() > 0){
                update prfLines;
            }
        }
    }//end of execute
    
    global void finish(Database.BatchableContext BC) {
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        String recId;
        String newRecId;
        if(query.containsIgnoreCase('Price_Quote__c')){
            recId = query.split('Price_Quote__c = ')[1];
            system.debug('recId *** ' + recId);
            newRecId = recId.replace('\'','');
            system.debug('newRecId *** ' + newRecId);
        }
        else{
            recId = query.split('Prf__c = ')[1];
            system.debug('recId *** ' + recId);
            newRecId = recId.replace('\'','');
            system.debug('newRecId *** ' + newRecId);
        }
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        system.debug('toAddresses *** ' + toAddresses);
        mail.setToAddresses(toAddresses);
        mail.setSubject('CSV Import Completed ' + a.Status);
        mail.setPlainTextBody
        ('Your CSV import is complete.  The batch Apex job processed with '+ a.NumberOfErrors + ' failures.  Please click link to get to your record ('
        + URL.getSalesforceBaseUrl().toExternalForm() + '/' + newRecId+')');

        if(!test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }//end of finish
    
    //bulk refresh for PQ Line Items
    public void bulkRefreshPq(List<Id> lineIds){
        //start refresh Stuff
        system.debug('*** Starting bulkRefreshPq PP_ImportCsvBatch *** ');
        list<Price_Quote_Line_Item__c> lineItemList = new list<Price_Quote_Line_Item__c>();
        set<String> mstringid = new set<String>();
        list<Price_Quote_Line_Item__c> pqlilist = [Select id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c, Objective_Name__c,
                                                   Objective__c,Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Brand__c, Approval_Flag_Reason__c,
                                                   Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c,
                                                   Product_Description__c, Material_Name__r.Cost__c,Sales_deal_Description__c, Sales_Number__c,
                                                   Row_Order__c, Competetive_Product__r.Competitor_Product_Code__c, Material_Name__r.Name,
                                                   Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Description__c, Material_Name__r.Director_Price__c,
                                                   Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Floor_Price__c,
                                                   Line_Price__c, Material_Name__r.Transfer_Price__c, Material_Status_Description__c, IsBold__c,
                                                   Approval_Flag_Checkbox__c, Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c,
                                                   Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c,
                                                   Owner_Approval_Level__c, Approval_Level__c, Refresh__c,Price_Quote__r.Account_Name__r.SAP_Sold_To__c,
                                                   Price_Quote__r.CurrencyIsoCode, Price_Quote__r.Account_Name__r.Account_Group__c, Price_Quote__r.Sales_Org_Key__c,
                                                   Director_Price__c, Floor_Price__c, Price_Quote__r.Account_Name__r.Price_List_Type__c, Min_Order_Qty__c
                                                   FROM Price_Quote_Line_Item__c
                                                   WHERE Id IN: lineIds AND Material_Name__c != NULL
                                                   LIMIT 75 ];
        system.debug('*** pqlilist.size() bulkRefreshPq *** ' + pqlilist.size() );
        system.debug('*** pqlilist bulkRefreshPq *** ' + pqlilist);
        Price_Quote__c pq = [Select Id, Name, Status__c, Sales_Org_Key__c, Account_Name__r.SAP_Sold_To__c, BusinessUnit__c,
                             Line_Count__c, Account_Name__r.Account_Group__c, CurrencyIsoCode, Account_Name__r.Id, Type__c,
                             Price_Quote_Name__c, InApproval__c, Owner_Business_Unit__c, Account_Name__r.Price_List_Type__c
                             FROM Price_Quote__c
                             WHERE Id =:pqlilist[0].Price_Quote__c limit 1];
        
        if(pqlilist.size() > 0){
            pqSalesOrgKey = pqlilist[0].Price_Quote__r.Sales_Org_Key__c;
        }
        else{
            pqSalesOrgKey = 'US6010';
        }
        system.debug('*** pqSalesOrgKey bulkRefreshPq *** ' + pqSalesOrgKey);
        
        for(Price_Quote_Line_Item__c pqli : pqlilist){
            mstringid.add(pqli.Material_Name__r.Id);
        }
        system.debug('mstringid bulkRefreshPq *** ' + mstringid);
        
        try{
            
            list<Product2> mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c, Floor_Price__c,
                                     List_Price__c, RSM_Price__c, Rep_Price__c, Description, Director_Price__c,
                                     Distributor_List__c, Alt_Site_List__c, MRP_Group__c, Min_Order_Qty__c
                                     FROM Product2
                                     WHERE Id IN:mstringid
                                     AND Duplicate__c = FALSE AND SearchableProducts__c = TRUE];
            system.debug('*** mcheck bulkRefreshPq *** ' + mcheck);
            
            // Create the Product Mapping
            map<String, Product2> prodmap = new map<String, Product2>();
            for(Product2 pmap : mcheck){
                prodmap.put(pmap.Name, pmap);
            }
            system.debug('*** prodmap bulkRefreshPq *** ' + prodmap);
            
            // Determine which SAP Number to use for Lookup
            string pcn = pqlilist[0].Price_Quote__r.Account_Name__r.SAP_Sold_To__c;
            string shipTo ='';
            if(pqlilist[0].Price_Quote__r.Account_Name__r.Account_Group__c == 'Z002'){
                for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                                  FROM Contract_Partnership__c
                                                  WHERE Ship_to__c =:pqlilist[0].Price_Quote__r.Account_Name__r.SAP_Sold_To__c])
                {
                    pcn = cp.Sale_to__c;
                }
                
            }
             shipTo=pcn;
            system.debug('*** pcn (Primary Customer Number) bulkRefreshPq *** ' + pcn);
            
            // Start building the line items
            
            // Prospect Account Process (No SAP) #1
            system.debug('*** pqlilist[0].Price_Quote__r.Account_Name__r.SAP_Sold_To__c *** ' + pqlilist[0].Price_Quote__r.Account_Name__r.SAP_Sold_To__c);
            if(pqlilist[0].Price_Quote__r.Account_Name__r.SAP_Sold_To__c == NULL){
                system.debug('*** Starting getPrice without SAP bulkRefreshPq ***');
                
                for(Price_Quote_Line_Item__c ml : pqlilist){
                    system.debug('*** prodmap.get(ml.Material_Name__r.Name).Id *** ' + prodmap.get(ml.Material_Name__r.Name).Id);
                    system.debug('*** ml *** ' + ml);
                    system.debug('*** ml.Price_Quote__r.CurrencyIsoCode *** ' + ml.Price_Quote__r.CurrencyIsoCode);
                    Price_Quote_Line_Item__c  pqLineItem = new Price_Quote_Line_Item__c (
                        Price_Quote__c = ml.Price_Quote__c,
                        Material_Name__c = prodmap.get(ml.Material_Name__r.Name).Id,
                        CurrencyIsoCode = ml.Price_Quote__r.CurrencyIsoCode,
                        Floor_Price__c = prodmap.get(ml.Material_Name__r.Name).Floor_Price__c,
                        Director_Price__c = prodmap.get(ml.Material_Name__r.Name).Director_Price__c,
                        RSM_Price__c = prodmap.get(ml.Material_Name__r.Name).RSM_Price__c,
                        Rep_Price__c = prodmap.get(ml.Material_Name__r.Name).Rep_Price__c,
                        MRP_Group__c = prodmap.get(ml.Material_Name__r.Name).MRP_Group__c,
                        Product_Description__c = prodmap.get(ml.Material_Name__r.Name).Description,
                        Min_Order_Qty__c = prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c
                        //List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                        //Sales_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                        //Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c
                    );
                    
                    system.debug('*** pqSalesOrgKey *** ' + pqSalesOrgKey);
                    system.debug('*** soMap *** ' + soMap);
                    String soMapStr = soMap.get(pqSalesOrgKey).Pricing_Type__c;
                    system.debug('*** soMapStr *** ' + soMapStr);
                    //logic to handle Hospital, Distributor, and Alt Site pricing
                    if( soMap.get(pqSalesOrgKey).Pricing_Type__c == 'All' ){
                        //Alt Site Accounts
                        if(ml.Price_Quote__r.Account_Name__r.Price_List_Type__c == 'ZA'){
                            if(prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c == NULL){
                                pqLineItem.List_Price__c = 0.00;
                                pqLineItem.Eligible_Price__c = 0.00;
                            }
                            else{
                                pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                            }
                        }
                        
                        //Distributor Accounts
                        if(ml.Price_Quote__r.Account_Name__r.Price_List_Type__c == 'ZD'){
                            if(prodmap.get(ml.Material_Name__r.Name).Distributor_List__c == NULL){
                                pqLineItem.List_Price__c = 0.00;
                                pqLineItem.Eligible_Price__c = 0.00;
                            }
                            else{
                                pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                            }
                        }
                        
                        //Hospital Accounts
                        if(ml.Price_Quote__r.Account_Name__r.Price_List_Type__c == 'ZH' || ml.Price_Quote__r.Account_Name__r.Price_List_Type__c == ''){
                            if(prodmap.get(ml.Material_Name__r.Name).List_Price__c == NULL){
                                pqLineItem.List_Price__c = 0.00;
                                pqLineItem.Eligible_Price__c = 0.00;
                            }
                            else{
                                pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                            }
                        }
                        //end of logic to handle Hospital, Distributor, and Alt Site pricing
                    }//end of if pqSalesOrgKey
                    else if( soMap.get(pqSalesOrgKey).Pricing_Type__c == 'Distributor List' ){
                        if(prodmap.get(ml.Material_Name__r.Name).Distributor_List__c == NULL){
                            pqLineItem.List_Price__c = 0.00;
                            pqLineItem.Eligible_Price__c = 0.00;
                        }
                        else{
                            pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                            pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                        }
                    }
                    else{
                        pqLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                        pqLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                    }//end of else pqSalesOrgKey
                    
                    lineItemList.add(pqLineItem);
                }
            }
            // Customer Account Process #2
            else{
                system.debug('*** Starting getPrice with SAP bulkRefreshPq ***');
                List<SAPRealPriceSet__x> sapList = new List<SAPRealPriceSet__x>();
                //List<string> cnlist = new List<String>();
                //cnlist.add(pq.Account_Name__r.SAP_Sold_To__c);
                
                Map<String, String> cMap = new Map<String, String>();
                for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
                    cMap.put(scm.Name, scm.Mapped_Value__c);
                }
                system.debug('*** cMap bulkRefreshPq *** ' + cMap);
                
                //Start getting SAP info
                for(Price_Quote_Line_Item__c ml : pqlilist)
                {
                    //start new logic
                    if( Test.isRunningTest() ){
                        if(ml.Price_Quote__r.Account_Name__r.SAP_Sold_To__c == '999999'){
                            SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
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
                                Customer__c  = '0000999999'
                            );
                            sapList.add(testSAP);
                        }
                        else{
                            SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
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
                                Customer__c  = '0000999998'
                            );
                            sapList.add(testSAP);
                        }
                    }//end test running check
                    else{
                        System.debug('*** Test Is NOT Running bulkRefreshPq ***');
                        sapList = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c,
                                   ValidFrom__c, ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                   OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                   DistChnl__c,MatDesc__c,Currency__c,ShipTo__c, VAT__c
                                   FROM SAPRealPriceSet__x
                                   WHERE SalesOrg__c =:prodmap.get(ml.Material_Name__r.Name).Sales_Org__c
                                   AND DistChnl__c =:prodmap.get(ml.Material_Name__r.Name).Distribution_Channel__c
                                   AND Customer__c =:pcn
                                   AND ShipTo__c =:shipTo
                                   AND Material__c =:prodmap.get(ml.Material_Name__r.Name).Name
                                   AND EffDate__c =:datetime.now()
                                  ];
                    }//end else
                    //end new logic
                
                    for(SAPRealPriceSet__x sap : sapList)
                    {
                        system.debug('*** sap bulkRefreshPq *** ' + sap);
                        
                        
                        
                        string conremap = sap.Condition__c;
                        if(cMap.get(sap.Condition__c) != NULL){
                            conremap = cMap.get(sap.Condition__c);
                        }
                        system.debug('*** conditionMap bulkRefreshPq *** ' + cMap);
                        
                        string salesDeal;
                        if(sap.SalesDeal__c != NULL){
                            salesDeal = sap.SalesDeal__c.right(8);
                        }
                        system.debug('*** salesDeal bulkRefreshPq *** ' + salesDeal);
                        
                        Price_Quote_Line_Item__c  li = new Price_Quote_Line_Item__c (
                            Price_Quote__c = ml.Price_Quote__c,
                            Material_Name__c = prodmap.get(ml.Material_Name__r.Name).Id,
                            Product_Description__c = prodmap.get(ml.Material_Name__r.Name).Description,
                            Material_Status__c = sap.MtrlStatus__c,
                           // CurrencyIsoCode = ml.Price_Quote__r.CurrencyIsoCode,
                            Floor_Price__c = prodmap.get(ml.Material_Name__r.Name).Floor_Price__c,
                            Director_Price__c = prodmap.get(ml.Material_Name__r.Name).Director_Price__c,
                            //List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                            RSM_Price__c = prodmap.get(ml.Material_Name__r.Name).RSM_Price__c,
                            Rep_Price__c = prodmap.get(ml.Material_Name__r.Name).Rep_Price__c,
                            MRP_Group__c = prodmap.get(ml.Material_Name__r.Name).MRP_Group__c,
                            Condition__c = conremap,
                            Sales_Deal_Description__c = sap.AgrDesc__c,
                            Sales_Number__c = salesDeal,
                            Id = ml.Id,
                            Objective__c = sap.AgrObjective__c,
                            Eligible_Price__c = sap.Price__c,
                            Min_Order_Qty__c = prodmap.get(ml.Material_Name__r.Name).Min_Order_Qty__c
                        );
                        
                         if(pq.Businessunit__c !=NULL && pq.Businessunit__c == 'EMEA'){
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
                       
                            
                            
                    //check for eligible price = 0
                        //System.debug('*** sap.Material__c *** ' + sap.Material__c)
                        System.debug('*** sap.Material__c && sap.Price__c *** ' + sap.Material__c + ' ' + sap.Price__c);
                        if(sap.Price__c != 0.00){
                            System.debug('*** IN if(sap.Price__c != 0.00) ***');
                            System.debug('*** ml.Price_Quote__r.Account_Name__r.Price_List_Type__c *** ' + ml.Price_Quote__r.Account_Name__r.Price_List_Type__c);
                            System.debug('*** ml.Price_Quote__r.Account_Name__r.Sap_Sold_to__c *** ' + ml.Price_Quote__r.Account_Name__r.Sap_Sold_to__c);
                            //li.Sales_Price__c = sap.Price__c;
                            li.Eligible_Price__c = sap.Price__c;
                            
                            //logic to handle Hospital, Distributor, and Alt Site pricing
                            System.debug('*** pqSalesOrgKey in IF *** ' + pqSalesOrgKey);
                            if( soMap.get(pqSalesOrgKey).Pricing_Type__c == 'All' ){
                                System.debug('*** ml.Price_Quote__r.Account_Name__r.Price_List_Type__c *** ' + ml.Price_Quote__r.Account_Name__r.Price_List_Type__c);
                                //Alt Site Accounts
                                if(ml.Price_Quote__r.Account_Name__r.Price_List_Type__c == 'ZA'){
                                    if(prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c == NULL){
                                        System.debug('*** ZA IF *** ');
                                        li.List_Price__c = 0.00;
                                    }
                                    else{
                                        System.debug('*** ZA ELSE *** ');
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                    }
                                }
                                
                                //Distributor Accounts
                                if(ml.Price_Quote__r.Account_Name__r.Price_List_Type__c == 'ZD'){
                                    if(prodmap.get(ml.Material_Name__r.Name).Distributor_List__c == NULL){
                                        System.debug('*** ZD IF *** ');
                                        li.List_Price__c = 0.00;
                                    }
                                    else{
                                        System.debug('*** ZD ELSE *** ');
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                    }
                                }
                                
                                //Hospital Accounts
                                if(ml.Price_Quote__r.Account_Name__r.Price_List_Type__c == 'ZH' || ml.Price_Quote__r.Account_Name__r.Price_List_Type__c == ''){
                                    if(prodmap.get(ml.Material_Name__r.Name).List_Price__c == NULL){
                                        System.debug('*** ZH IF *** ');
                                        li.List_Price__c = 0.00;
                                    }
                                    else{
                                        System.debug('*** ZH ELSE *** ');
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                    }
                                }
                                //end of logic to handle Hospital, Distributor, and Alt Site pricing
                            }//end of if pqSalesOrgKey
                            else{
                                li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                            }//end of else pqSalesOrgKey
                        }//end of if sap.Price__c != 0.00
                        else{
                            System.debug('*** IN ELSE FOR IF(sap.Price__c != 0.00) ***');
                            System.debug('*** ml.Price_Quote__r.Account_Name__r.Price_List_Type__c *** ' + ml.Price_Quote__r.Account_Name__r.Price_List_Type__c);
                            System.debug('*** ml.Price_Quote__r.Account_Name__r.Sap_Sold_to__c *** ' + ml.Price_Quote__r.Account_Name__r.Sap_Sold_to__c);
                            //logic to handle Hospital, Distributor, and Alt Site pricing
                            System.debug('*** pqSalesOrgKey in ELSE *** ' + pqSalesOrgKey);
                            if( soMap.get(pqSalesOrgKey).Pricing_Type__c == 'All' ){
                                System.debug('*** ml.Price_Quote__r.Account_Name__r.Price_List_Type__c *** ' + ml.Price_Quote__r.Account_Name__r.Price_List_Type__c);
                                //Alt Site Accounts
                                if(ml.Price_Quote__r.Account_Name__r.Price_List_Type__c == 'ZA'){
                                    if(prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c == NULL){
                                        System.debug('*** ZA IF *** ');
                                        li.List_Price__c = 0.00;
                                        li.Eligible_Price__c = 0.00;
                                    }
                                    else{
                                        System.debug('*** ZA ELSE *** ');
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                        li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                    }
                                }
                                
                                
                                //Distributor Accounts
                                if(ml.Price_Quote__r.Account_Name__r.Price_List_Type__c == 'ZD'){
                                    if(prodmap.get(ml.Material_Name__r.Name).Distributor_List__c == NULL){
                                        System.debug('*** ZD IF *** ');
                                        li.List_Price__c = 0.00;
                                        li.Eligible_Price__c = 0.00;
                                    }
                                    else{
                                        System.debug('*** ZD ELSE *** ');
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                        li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                    }
                                }
                                
                                //Hospital Accounts
                                if(ml.Price_Quote__r.Account_Name__r.Price_List_Type__c == 'ZH' || ml.Price_Quote__r.Account_Name__r.Price_List_Type__c == ''){
                                    if(prodmap.get(ml.Material_Name__r.Name).List_Price__c == NULL){
                                        System.debug('*** ZH IF *** ');
                                        li.List_Price__c = 0.00;
                                        li.Eligible_Price__c = 0.00;
                                    }
                                    else{
                                        System.debug('*** ZH ELSE *** ');
                                        li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                        li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                    }
                                }
                                //end of logic to handle Hospital, Distributor, and Alt Site pricing
                            }//end of if pqSalesOrgKey
                            else{
                                if(prodmap.get(ml.Material_Name__r.Name).List_Price__c == NULL){
                                    li.List_Price__c = 0.00;
                                    li.Eligible_Price__c = 0.00;
                                }
                                else{
                                    li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                    li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                }
                            }//end of else pqSalesOrgKey
                            
                        }//end of else sap.Price__c != 0.00
                        //add object to list
                        lineItemList.add(li);
                        system.debug('*** lineItemList bulkRefreshPq *** ' + lineItemList);
                    }//end of for(SAPRealPriceSet__x sap
                }
                // DML - Insert Lines
                If(lineItemList.size() > 0){
                    system.debug('*** lineItemList bulkRefreshPq *** ' + lineItemList);
                    update lineItemList;
                }
            }
            //fixString();
        }
        catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
        }
        //end refresh Stuff
        
    }//end of bulkRefreshPq
    
    //bulk refresh for PQ Line Items
    // Bulk Refresh
    public void bulkrefreshPrf(List<Id> lineIds){
        
        list<PRF_Line_Item__c> lineItemList = new list<PRF_Line_Item__c>();
        set<String> mstringid = new set<String>();
        list<PRF_Line_Item__c> prflilist = [SELECT Id, Material_Name__r.Id, Material_Name__r.Name, Material_Name__r.Sales_Org__c,
                                            Material_Name__r.Distribution_Channel__c, PRF__c, Prf__r.Account__r.Price_List_Type__c
                                            FROM PRF_Line_Item__c
                                            WHERE Id IN :lineIds
                                            LIMIT 75];
        system.debug('prflilist: ' + prflilist);
        
        for(PRF_Line_Item__c prfli : prflilist){
            mstringid.add(prfli.Material_Name__r.Id);
        }
        system.debug('mstringid: ' + mstringid);
        
        try{
            
            PRF__c prf = [SELECT Account__r.SAP_Sold_To__c, Account__r.Account_Group__c, Sales_Org_Key__c, Line_Count__c,
                          CurrencyIsoCode, Account__r.Price_List_Type__c
                          FROM PRF__c
                          WHERE Id =: prflilist[0].PRF__c LIMIT 1];
            system.debug('prf ====================== ' + prf);
            
            list<Product2> mcheck = [SELECT Id, Name, Sales_Org__c, Distribution_Channel__c, Floor_Price__c,
                                     List_Price__c, RSM_Price__c, Rep_Price__c, Description, Director_Price__c,
                                     Distributor_List__c, Alt_Site_List__c, MRP_Group__c
                                     FROM Product2
                                     WHERE Id IN:mstringid
                                     AND Duplicate__c = FALSE AND SearchableProducts__c = TRUE];
            system.debug('mcheck ====================== ' + mcheck);
            
            
            // Create the Product Mapping
            map<String, Product2> prodmap = new map<String, Product2>();
            for(Product2 pmap : mcheck){
                prodmap.put(pmap.Name, pmap);
            }
            system.debug('prodmap: ' + prodmap);
            
            // Determine which SAP Number to use for Lookup
            string pcn = prf.Account__r.SAP_Sold_To__c;
            string shipTo ='';
            if(prf.Account__r.Account_Group__c == 'Z002'){
                for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                                  FROM Contract_Partnership__c
                                                  WHERE Ship_to__c =:prf.Account__r.SAP_Sold_To__c])
                {
                    pcn = cp.Sale_to__c;
                }
                shipTo = pcn;
            }
            system.debug('pcn (Primary Customer Number) ================ ' + pcn);
            
            // Start building the line items
            
            // Prospect Account Process (No SAP) #1
            if(prf.Account__r.SAP_Sold_To__c == NULL){
                system.debug('Starting getPrice without SAP');
                
                for(PRF_Line_Item__c ml : prflilist){
                    
                    PRF_Line_Item__c  prfLineItem = new PRF_Line_Item__c (
                        PRF__c = prf.Id,
                        Material_Name__c = prodmap.get(ml.Material_Name__r.Name).Id,
                        Product_Description__c = prodmap.get(ml.Material_Name__r.Name).Description,
                        CurrencyIsoCode = prf.CurrencyIsoCode,
                        Floor_Price__c = prodmap.get(ml.Material_Name__r.Name).Floor_Price__c,
                        Director_Price__c = prodmap.get(ml.Material_Name__r.Name).Director_Price__c,
                        //List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                        RSM_Price__c = prodmap.get(ml.Material_Name__r.Name).RSM_Price__c,
                        Rep_Price__c = prodmap.get(ml.Material_Name__r.Name).Rep_Price__c
                        //MRP_Group__c = prodmap.get(ml.Material_Name__r.Name).MRP_Group__c
                        //Requested_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                        //Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c
                    );
                    
                    //logic to handle Hospital, Distributor, and Alt Site pricing
                    if( soMap.get(prfSalesOrgKey).Pricing_Type__c == 'All' ){
                        //Alt Site Accounts
                        if(prf.Account__r.Price_List_Type__c == 'ZA'){
                            prfLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                            prfLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                        }
                        
                        //Distributor Accounts
                        if(prf.Account__r.Price_List_Type__c == 'ZD'){
                            prfLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                            prfLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                        }
                        
                        //Hospital Accounts
                        if(prf.Account__r.Price_List_Type__c == 'ZH' || prf.Account__r.Price_List_Type__c == ''){
                            prfLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                            prfLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                        }
                        //end of logic to handle Hospital, Distributor, and Alt Site pricing
                    }//end of if prfSalesOrgKey
                    else{
                        prfLineItem.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                        prfLineItem.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                    }//end of else prfSalesOrgKey
                    
                    lineItemList.add(prfLineItem);
                }
            }
            // Customer Account Process #2
            else{
                system.debug('Starting getPrice with SAP');
                List<SAPRealPriceSet__x> sapList = new List<SAPRealPriceSet__x>();
                
                Map<String, String> cMap = new Map<String, String>();
                for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
                    cMap.put(scm.Name, scm.Mapped_Value__c);
                }
                system.debug('cMap ============== ' + cMap);
                
                //Start getting SAP info
                for(PRF_Line_Item__c ml : prflilist)
                {
                    //start new logic
                    if( Test.isRunningTest() ){
                        if(prf.Account__r.SAP_Sold_To__c == '999999'){
                            SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
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
                                Customer__c  = '0000999999'
                            );
                            sapList.add(testSAP);
                        }
                        else{
                            SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
                            SalesDeal__c = '50009064',
                            Price__c = 100.00,
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
                            Customer__c  = '0000999998'
                        );
                        sapList.add(testSAP);
                        }
                        
                    }//end test running check
                    else{
                        System.debug('*** Test Is NOT Running ***');
                        sapList = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c,
                                   ValidFrom__c, ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                   OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                   DistChnl__c, VAT__c, MatDesc__c, ShipTo__c
                                   FROM SAPRealPriceSet__x
                                   WHERE SalesOrg__c =:prodmap.get(ml.Material_Name__r.Name).Sales_Org__c
                                   AND DistChnl__c =:prodmap.get(ml.Material_Name__r.Name).Distribution_Channel__c
                                   AND Customer__c =:pcn
                                   AND ShipTo__C =:shipTo
                                   AND Material__c =:prodmap.get(ml.Material_Name__r.Name).Name
                                   AND EffDate__c =:datetime.now()
                                  ];
                    }//end else
                    //end new logic
                    //
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
                        
                        PRF_Line_Item__c  li = new PRF_Line_Item__c (
                            PRF__c = prf.Id,
                            Material_Name__c = prodmap.get(ml.Material_Name__r.Name).Id,
                            Product_Description__c = prodmap.get(ml.Material_Name__r.Name).Description,
                            Material_Status__c = sap.MtrlStatus__c,
                            CurrencyIsoCode = prf.CurrencyIsoCode,
                            Floor_Price__c = prodmap.get(ml.Material_Name__r.Name).Floor_Price__c,
                            Director_Price__c = prodmap.get(ml.Material_Name__r.Name).Director_Price__c,
                            //List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                            RSM_Price__c = prodmap.get(ml.Material_Name__r.Name).RSM_Price__c,
                            Rep_Price__c = prodmap.get(ml.Material_Name__r.Name).Rep_Price__c,
                            //MRP_Group__c = prodmap.get(ml.Material_Name__r.Name).MRP_Group__c,
                            //Requested_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c,
                            Condition__c = conremap,
                            Sales_Deal_Description__c = sap.AgrDesc__c,
                            Sales_Deal_Num__c = salesDeal,
                            Id = ml.Id,
                            Objective__c = sap.AgrObjective__c,
                            Eligible_Price__c = sap.Price__c
                        );
                        
                        //check for eligible price = 0
                        if(sap.Price__c != 0.00){
                            
                            //li.Requested_Price__c = sap.Price__c;
                            li.Eligible_Price__c = sap.Price__c;
                            
                            //logic to handle Hospital, Distributor, and Alt Site pricing
                            if( soMap!=null && soMap.containsKey(prfSalesOrgKey) && soMap.get(prfSalesOrgKey)!=null && soMap.get(prfSalesOrgKey).Pricing_Type__c == 'All' ){
                                //Alt Site Accounts
                                if(prf.Account__r.Price_List_Type__c == 'ZA'){
                                    li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                }
                                
                                //Distributor Accounts
                                if(prf.Account__r.Price_List_Type__c == 'ZD'){
                                    li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                }
                                
                                //Hospital Accounts
                                if(prf.Account__r.Price_List_Type__c == 'ZH' || prf.Account__r.Price_List_Type__c == ''){
                                    li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                }
                                //end of logic to handle Hospital, Distributor, and Alt Site pricing
                            }//end of if prfSalesOrgKey
                            else{
                                li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                            }//end of else prfSalesOrgKey
                        }//end of if sap.Price__c != 0.00
                        else{
                            //logic to handle Hospital, Distributor, and Alt Site pricing
                            if( soMap!=null && soMap.containsKey(prfSalesOrgKey) && soMap.get(prfSalesOrgKey)!=null && soMap.get(prfSalesOrgKey).Pricing_Type__c == 'All' ){
                                //Alt Site Accounts
                                if(prf.Account__r.Price_List_Type__c == 'ZA'){
                                    li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                    li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Alt_Site_List__c;
                                }
                                
                                //Distributor Accounts
                                if(prf.Account__r.Price_List_Type__c == 'ZD'){
                                    li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                    li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).Distributor_List__c;
                                }
                                
                                //Hospital Accounts
                                if(prf.Account__r.Price_List_Type__c == 'ZH' || prf.Account__r.Price_List_Type__c == ''){
                                    li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                    li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                }
                                //end of logic to handle Hospital, Distributor, and Alt Site pricing
                            }//end of if prfSalesOrgKey
                            else{
                                li.List_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                                li.Eligible_Price__c = prodmap.get(ml.Material_Name__r.Name).List_Price__c;
                            }//end of else prfSalesOrgKey
                            
                        }//end of else sap.Price__c != 0.00
                        
                        //add object to list
                        lineItemList.add(li);
                        system.debug('lineItemList ======================== ' + lineItemList);
                    }
                    
                }
                
                // DML - Insert Lines
                If(lineItemList.size() > 0){
                    system.debug('lineItemList ======================= ' + lineItemList);
                    database.update(lineItemList,false);
                }
            }
            
        }
        catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
        }
        
    }//end of bulkRefreshPrf
    
}//end of class