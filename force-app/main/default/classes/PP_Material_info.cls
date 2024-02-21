/*********************************************************************
* Description      : Controller Class for Pricing Portal Material Details.
* Test Class       : PP_Material_info_Test
* VisualForce      : PP_Material_info
* Author(s)        : Dun Silver
**********************************************************************/
public with sharing class PP_Material_info {

    public product2 prod {get; set;}
    public string status {get; set;}

    //get user language
    public String userLang{get{
        return UserInfo.getLanguage();
    }set;}
    
    //get active sales org key of User
    public String myActiveSalesOrg { get{
      myActiveSalesOrg = [SELECT Active_Sales_Org_Key__c
                        FROM Contract_User__c
                        WHERE User__c = :UserInfo.getUserId()
                        LIMIT 1].Active_Sales_Org_Key__c;

      return myActiveSalesOrg;
    } set;}
    
    //get active sales org key of User
    public Decimal myPricingTierAccessLevel { get{
      myPricingTierAccessLevel = [SELECT Pricing_Tier_Access__c
                        FROM Contract_User__c
                        WHERE User__c = :UserInfo.getUserId()
                        LIMIT 1].Pricing_Tier_Access__c;

      return myPricingTierAccessLevel;
    } set;}

    // Start New Pricing Tier Variables - May 22 ESC
    public list<String> tierHeaderList {get; set;}
    public map<String, PP_Pricing_Tiers.tiers> tierMap {get; set;}
    public list<product2> plist {get; set;}
    // End New Pricing Tier Variables
    
    public PP_Material_info(){
        System.debug('%%%%% pid: '+ApexPages.currentPage().getParameters().get('pid'));
        System.debug('%%%%% id: '+ApexPages.currentPage().getParameters().get('id'));
        System.debug('%%%%% myActiveSalesOrg: ' + myActiveSalesOrg);
        
        prod = new Product2();

        if(ApexPages.currentPage().getParameters().get('pid') != NULL){
            prod = [SELECT Id, Name,Brand_Name__c, Description,Class__c, Sales_Unit__c, Material_Status_Numeric__c,
                    Qty_Sales_Unit__c,Group__c, RSM_Price__c, Rep_Price__c, DChain_Material_Status__c,
                    List_Price__c,SubGroup__c, Hi_Res_Image__c, Low_Res_Image__c, Image_URL__c, Product_Line_Text__c, 
                    CurrencyIsoCode, Sales_Org__c, Distribution_Channel__c, Material_Status_Description__c,
                    Distributor_List__c, Alt_Site_List__c, MRP_Group__c, ASK_Custom_Kit__c, SearchableProducts__c,
                    Min_Order_Qty__c
                    FROM Product2
                    WHERE Name = :ApexPages.currentPage().getParameters().get('pid')
                    AND Sales_Org_Key__c =:myActiveSalesOrg
                    LIMIT 1];
        }
        else if(ApexPages.currentPage().getParameters().get('id') != NULL){
            prod = [SELECT Id, Name,Brand_Name__c, Description,Class__c, Sales_Unit__c, Product_Line_Text__c, 
                    Qty_Sales_Unit__c,Group__c, RSM_Price__c, Rep_Price__c, DChain_Material_Status__c,
                    List_Price__c,SubGroup__c, Hi_Res_Image__c, Low_Res_Image__c, Image_URL__c, Material_Status_Numeric__c,
                    CurrencyIsoCode, Sales_Org__c, Distribution_Channel__c, Material_Status_Description__c,
                    Distributor_List__c, Alt_Site_List__c, MRP_Group__c, ASK_Custom_Kit__c, SearchableProducts__c,
                    Min_Order_Qty__c
                    FROM Product2
                    WHERE Id = :ApexPages.currentPage().getParameters().get('id')
                    LIMIT 1]; //AND Sales_Org_Key__c =:myActiveSalesOrg
        }
        
        if(prod != NULL){

            if(prod.DChain_Material_Status__c != NULL){
                system.debug('*** prod.DChain_Material_Status__c *** ' + prod.DChain_Material_Status__c);
                status = prod.DChain_Material_Status__c;
            }
            else if(prod.Material_Status_Numeric__c != NULL){
                system.debug('*** prod.Material_Status_Numeric__c *** ' + prod.Material_Status_Numeric__c);
                status = prod.Material_Status_Numeric__c;
            }

            /*
            for(SAPRealPriceSet__x sap : [SELECT MtrlStatus__c, SalesMtrlStatus__c
                                          FROM SAPRealPriceSet__x
                                          WHERE SalesOrg__c = :prod.Sales_Org__c
                                          AND DistChnl__c = :prod.Distribution_Channel__c
                                          AND Material__c = :prod.Name
                                          AND EffDate__c = TODAY
                                          LIMIT 1])
            {
                if(sap.SalesMtrlStatus__c != NULL){
                    system.debug('Using Sales Material Status(1): ' + sap.SalesMtrlStatus__c);
                    status = sap.SalesMtrlStatus__c;
                }
                else if(sap.MtrlStatus__c != NULL){
                    system.debug('Using Material Status(2): ' + sap.MtrlStatus__c);
                    status = sap.MtrlStatus__c;
                }
            }
            */
            if(status != NULL){
                // Used to return the Text Status. Example: 40 = Saleable (40)
                PP_General_Helper_Class ghc = new PP_General_Helper_Class();
                map<String, String> mstatMap = ghc.mstatus();

                if(mstatMap.get(status) != NULL){
                    status = mstatMap.get(status);
                }
            }
        }
        
        // New Pricing Tiers - May 22 2018 - ESC
        // Stage 1 - Set the Variables/Environment
        tierMap = new map<String, PP_Pricing_Tiers.tiers>(); // Major map used to store the pricing matrix
        tierHeaderList = new list<String>(); // Used to store the final list of pricing levels in order: REP1, REP2, RSM1, etc.
        plist = new list<product2>(); // Holds the list of products
        //set<Id> pids = new set<Id>(); // Holds the set of product id's
        
        // Stage 2 - Ready the Lists/Sets
        plist.add(prod); // List of Products to use to build the Pricing Tiers Table
        //pids.add(prod.Id); // Set of Id's to Pass to the Pricing Tier Map Method
        
        // Stage 3 - Putting it all together
        PP_Pricing_Tiers newPT = new PP_Pricing_Tiers();
        //convert myPricingTierAccessLevel to Integer
        Integer myLevel=0;
        if(myPricingTierAccessLevel !=null)
            myLevel = myPricingTierAccessLevel.intValue();
        tierMap =  newPT.getTiers(plist,myLevel); // Pulls the map using a set of products
        //tierHeaderList = newPT.getTierHeaderNames(tierMap);
        tierHeaderList = newPT.getTierHeaderLevels(tierMap); // REP1, REP2, RSM1, etc.
        //End New Pricing Tiers
        //
        System.debug('\n tierMap:' + JSON.serialize(tierMap)
                     + '\n tierHeaderList:' + JSON.serialize(tierHeaderList));
    }

    public String strMats {get;set;}

    public String pqId {get{

        try{
            return [SELECT Name,sales_org_key__c
                    FROM Price_Quote__c
                    WHERE LastViewedDate != NULL 
                    AND sales_org_key__c= :myActiveSalesOrg
                    
                    ORDER BY LastViewedDate DESC limit 1].Name;
        }
        catch(Exception e){
            system.debug('Catch Exception: ' + e);
            return NULL;
        }

    } set;}

    public PageReference addQuoteLine() {
        string pqid;
        if(ApexPages.currentPage().getParameters().get('pqid') != NULL){
            pqid = ApexPages.currentPage().getParameters().get('pqid');
        }
        else{
            try{
                pqid = [SELECT Id
                        FROM Price_Quote__c
                        WHERE LastViewedDate != NULL
                        OR CreatedDate != NULL
                        ORDER BY LastViewedDate,CreatedDate DESC limit 1].Id;
                system.debug('pqid: ' + pqid);
            }
            catch(Exception e){
                system.debug('Catch Exception: ' + e);
            }
        }

        String pageMaterialId = ApexPages.currentPage().getParameters().get('materialId');
        list<String> mlist = new list<String>();
        mlist.add(pageMaterialId);

        PP_SAP_Price sapPrice = new PP_SAP_Price();
        system.debug('*** mlist PP_Material_info *** ' + mlist);
        system.debug('*** pqid PP_Material_info *** ' + pqid);
        sapPrice.getSAPprice(mlist,NULL,NULL,pqid);
       // sapPrice.savePriceQuoteItems(pqid, mlist, false, null, null, false);

        return NULL;

    }
    //Added By Siva on 27th Nov 2018 to provide update image button in this section
    public PageReference updateImageUrl() {
        String pageId = ApexPages.currentPage().getParameters().get('id');

        list<Id> mlist = new list<Id>();
        mlist.add(pageId);
        
        //System.debug('---Product-----'+mlist);

        PP_ProductImageFetcher.UpdateProductImageBatchNew(mlist);

        return NULL;

    }

    // Creates the Contract List
    public list<Contract_Material__c> getCM(){
        System.debug('*** myActiveSalesOrg getCM() *** ' + myActiveSalesOrg);
        // Harding Coding the Sales Org in case the user doesn't have a Pricing Portal User Record. - ESC
        String salesOrg = myActiveSalesOrg.left(4);
        
        //System.debug('*** salesOrg getCM() *** ' + salesOrg);
        Set<String> gpoList = new Set<String>();
        Set<String> idnList = new Set<String>();
        for(GPO_Picklist__c gpo : [SELECT Key__c
                                   FROM GPO_Picklist__c
                                   WHERE Active__c = TRUE
                                   ORDER BY Name]){
            gpoList.add(gpo.Key__c);
        }
        
        for(IDN_Picklist__c idn : [SELECT Key__c
                                   FROM IDN_Picklist__c
                                   WHERE Active__c = TRUE
                                   ORDER BY Name]){
            idnList.add(idn.Key__c);
        }
        
        try{
            if(ApexPages.currentPage().getParameters().get('pid') != NULL){
                System.debug('$$$$: '+myActiveSalesOrg);
                if(myActiveSalesOrg == 'US6020'){
                    return [SELECT Id, Agreement__c, Agreement__r.Agreement_Number__c, Agreement__r.Description__c,
                            Agreement__r.GPO_Contract_Ref__c, Agreement__r.Objective_Name__c, Agreement__r.Owner__c ,
                            Agreement__r.Owner_Name__c, Valid_From__c, Valid_To__c, Material_Name__c, Price__c, CurrencyIsoCode
                            FROM Contract_Material__c
                            WHERE Material_Name__c  = :ApexPages.currentPage().getParameters().get('pid')
                            AND Material_Name__c != NULL
                            //AND Agreement__r.Objective__c = '01'
                            AND Active_Future__c = TRUE
                            AND Sales_Org__c =:salesOrg
                            ORDER BY Agreement__r.Owner_Name__c, Agreement__r.Description__c];
                }
                else if(myActiveSalesOrg == 'CA1010'){
                    return [SELECT Id, Agreement__c, Agreement__r.Agreement_Number__c, Agreement__r.Description__c,
                            Agreement__r.GPO_Contract_Ref__c, Agreement__r.Objective_Name__c, Agreement__r.Owner__c ,
                            Agreement__r.Owner_Name__c, Valid_From__c, Valid_To__c, Material_Name__c, Price__c, CurrencyIsoCode
                            FROM Contract_Material__c
                            WHERE (Agreement__r.Owner__c IN :gpoList OR Agreement__r.Owner__c IN :idnList)
                            AND Material_Name__c  = :ApexPages.currentPage().getParameters().get('pid')
                            AND Material_Name__c != NULL
                            AND Active_Future__c = TRUE
                            AND Sales_Org__c =:salesOrg
                            ORDER BY Agreement__r.Owner_Name__c, Agreement__r.Description__c];
                }
                else{
                    return [SELECT Id, Agreement__c, Agreement__r.Agreement_Number__c, Agreement__r.Description__c,
                            Agreement__r.GPO_Contract_Ref__c, Agreement__r.Objective_Name__c, Agreement__r.Owner__c ,
                            Agreement__r.Owner_Name__c, Valid_From__c, Valid_To__c, Material_Name__c, Price__c, CurrencyIsoCode
                            FROM Contract_Material__c
                            WHERE Agreement__r.Owner__c IN :gpoList
                            AND Material_Name__c  = :ApexPages.currentPage().getParameters().get('pid')
                            AND Material_Name__c != NULL
                            AND Active_Future__c = TRUE
                            AND Sales_Org__c =:salesOrg
                            ORDER BY Agreement__r.Owner_Name__c, Agreement__r.Description__c];
                }

            }
            else{
                if(salesOrg == 'US6020'){
                    return [SELECT Id, Agreement__c, Agreement__r.Agreement_Number__c, Agreement__r.Description__c,Active_Future__c,
                            Agreement__r.GPO_Contract_Ref__c, Agreement__r.Objective_Name__c, Agreement__r.Owner__c ,Active__c,
                            Agreement__r.Owner_Name__c, Valid_From__c, Valid_To__c, Material_Name__c, Price__c, CurrencyIsoCode
                            FROM Contract_Material__c
                            WHERE Product__r.Id  = :ApexPages.currentPage().getParameters().get('id')
                            //AND Agreement__r.Objective__c = '01'
                            AND Active_Future__c = TRUE
                            AND Sales_Org__c =:salesOrg
                            ORDER BY Agreement__r.Owner_Name__c, Agreement__r.Description__c];
                }
                else if(myActiveSalesOrg == 'CA1010'){
                    return [SELECT Id, Agreement__c, Agreement__r.Agreement_Number__c, Agreement__r.Description__c,Active_Future__c,
                            Agreement__r.GPO_Contract_Ref__c, Agreement__r.Objective_Name__c, Agreement__r.Owner__c ,Active__c,
                            Agreement__r.Owner_Name__c, Valid_From__c, Valid_To__c, Material_Name__c, Price__c, CurrencyIsoCode
                            FROM Contract_Material__c
                            WHERE (Agreement__r.Owner__c IN :gpoList OR Agreement__r.Owner__c IN :idnList)
                            AND Product__r.Id  = :ApexPages.currentPage().getParameters().get('id')
                            AND Active_Future__c = TRUE
                            AND Sales_Org__c =:salesOrg
                            ORDER BY Agreement__r.Owner_Name__c, Agreement__r.Description__c];
                }
                else{
                    return [SELECT Id, Agreement__c, Agreement__r.Agreement_Number__c, Agreement__r.Description__c,Active_Future__c,
                            Agreement__r.GPO_Contract_Ref__c, Agreement__r.Objective_Name__c, Agreement__r.Owner__c ,Active__c,
                            Agreement__r.Owner_Name__c, Valid_From__c, Valid_To__c, Material_Name__c, Price__c, CurrencyIsoCode
                            FROM Contract_Material__c
                            WHERE Agreement__r.Owner__c IN :gpoList
                            AND Product__r.Id  = :ApexPages.currentPage().getParameters().get('id')
                            AND Active_Future__c = TRUE
                            AND Sales_Org__c =:salesOrg
                            ORDER BY Agreement__r.Owner_Name__c, Agreement__r.Description__c];
                }

            }
        }
        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }

    // Catch 'Lookup Customer' and redirect back
    public pagereference getURL(){
        System.debug('strMats ============================== ' + strMats);

        string search = strMats;
        if(search != NULL){
            search = search.trim();
            string matCheck;
            try{
                matCheck = [SELECT Id 
                            FROM Product2 
                            WHERE Name  = :search 
                            AND Sales_Org_Key__c =:myActiveSalesOrg 
                            AND Duplicate__c = FALSE 
                            ORDER BY Sales_Org__c ASC LIMIT 1].id;
            }
            catch(Exception e) {
            }
            if(matCheck != NULL){
                system.debug('search: ' + search);
                PageReference getMats = New Pagereference('/apex/PP_Material_info?id='+matCheck+
                                                          '&pqid='+ApexPages.currentPage().getParameters().get('pqid'));
                getMats.setRedirect(true);
                return getMats;
            }
            else{
                apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Not a valid Material Number...'));
                return NULL;
            }

        }
        else{
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a Material Number...'));
            return NULL;
        }
    }

}