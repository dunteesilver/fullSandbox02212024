/*********************************************************************
* Description      : Controller Class for Contract Details.
* Test Class       : PP_Global_Test_Class
* VisualForce      : PP_Price_Lookup
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
public with sharing class PP_Price_Lookup {
    public string cnumber {get; set;} //string to get URL parameter (customer number)
    public string pnumber {get; set;} //string to get URL parameter (material number)
    public Boolean priceTable {get;set;} //Boolean for rendering table on VF
    public Boolean errorTable {get;set;} //Boolean for rendering table on VF
    public Boolean AcctProdTable {get;set;}
    public string salesCurrency {get; set;}
    public string salesOrgKey {get; set;}
    public integer pricingTierAccessLevel {get;set;}
    public string status{get;set;}
    public Product2 prod {get; set;}
    public Decimal salesytd {get; set;}
    //public List<Contract_Partnership__c> soldToAcct {get;set;}
    public List<Contract_Partnership__c> shipToAcct {get;set;}
    public Map<Id,String> formatSalesPrice {get;set;}
    public String userLocale {get;set;}

    // Start New Pricing Tier Variables - May 22 ESC
    public list<String> tierHeaderList {get; set;}
    public map<String, PP_Pricing_Tiers.tiers> tierMap {get; set;}
    public list<product2> plist {get; set;}
    // End New Pricing Tier Variables

    public PP_Price_Lookup(){
      userLocale = UserInfo.getLocale();
      formatSalesPrice = new Map<Id,String>();
        string sapSoldTo = ApexPages.currentPage().getParameters().get('cid');
        string searchMaterials = ApexPages.currentPage().getParameters().get('pid');

        if(sapSoldTo == '' && searchMaterials == ''){
            errorTable = true;
            AcctProdTable = false;
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a Customer or Material Number...'));
        }
        else{
            if(sapSoldTo == '' || searchMaterials == ''){
                if(sapSoldTo == ''){
                    errorTable = true;
                    AcctProdTable = false;
                    apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a Customer Number...'));
                }

                if(searchMaterials == ''){
                    errorTable = true;
                    AcctProdTable = false;
                    apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a Material Number...'));
                }
            }
        }
		
        for(Contract_User__c cu : [SELECT Active_Currency__c, Active_Sales_Org_Key__c, Pricing_Tier_Access__c
                                   FROM Contract_User__c
                                   WHERE User__c = :UserInfo.getUserId()
                                   LIMIT 1])
        {
            salesCurrency = cu.Active_Currency__c;
            salesOrgKey = cu.Active_Sales_Org_Key__c;
            pricingTierAccessLevel = Integer.valueOf(cu.Pricing_Tier_Access__c);
        }

        try{
          prod = [SELECT Id, Name, Sales_Org__c , List_Price__c, Description,
                  Sales_unit__c, Qty_sales_unit__c, Rep_Price__c, RSM_Price__c,
                  Distribution_Channel__c, CurrencyIsoCode, Sales__c,
                  Distributor_List__c, Alt_Site_List__c, MRP_Group__c,Min_Order_Qty__c
                  FROM PRODUCT2
                  WHERE Name = :ApexPages.currentPage().getParameters().get('pid')
                  AND Sales_Org_Key__c = :salesOrgKey
                  AND Duplicate__c = FALSE
                  AND SearchableProducts__c = TRUE
                  ORDER BY Sales_Org__c ASC
                  LIMIT 1];
        }
        catch(Exception e){
            system.debug('Exceptions' + e);
        }

        salesytd = 0.00;
        try{
            salesytd = [SELECT Sales_YTD__c
                        FROM Sales_by_Product__c
                        WHERE SAP_Code__c =:sapSoldTo
                        AND Product__c =:prod.Id
                        LIMIT 1].Sales_YTD__c;
        }
        catch(Exception e){
            system.debug('Exceptions' + e);
        }

        if(prod != NULL){
          formatSalesPrice = getFormatSalesPrice(prod);
        }

        // New Pricing Tiers - May 22 2018 - ESC
        // Stage 1 - Set the Variables/Environment
        if(prod != NULL){
            tierMap = new map<String, PP_Pricing_Tiers.tiers>(); // Major map used to store the pricing matrix
            tierHeaderList = new list<String>(); // Used to store the final list of pricing levels in order: REP1, REP2, RSM1, etc.
            plist = new list<product2>(); // Holds the list of products
            //set<Id> pids = new set<Id>(); // Holds the set of product id's

            // Stage 2 - Ready the Lists/Sets
            plist.add(prod); // List of Products to use to build the Pricing Tiers Table
            //pids.add(prod.Id); // Set of Id's to Pass to the Pricing Tier Map Method
            System.debug('*** plist.size() *** ' + plist.size() );
            // Stage 3 - Putting it all together
            PP_Pricing_Tiers newPT = new PP_Pricing_Tiers();
            tierMap =  newPT.getTiers(plist,pricingTierAccessLevel); // Pulls the map using a set of products
            //tierHeaderList = newPT.getTierHeaderNames(tierMap);
            tierHeaderList = newPT.getTierHeaderLevels(tierMap); // REP1, REP2, RSM1, etc.
            System.debug('*** tierHeaderList.size() *** ' + tierHeaderList.size() );
            System.debug('*** tierMap *** ' + tierMap );
        }
        //End New Pricing Tiers
    }//end of constructor PP_Price_Lookup

    public String cid {
        get {
            return ApexPages.currentPage().getParameters().get('cid');
        }
        set;
    }//end of String cid

    public String pid {
        get {
            try{

            }
            catch(Exception e){

            }
            return ApexPages.currentPage().getParameters().get('pid');
        }
        set;
    }//end of String pid

    public List<Account> soldToAcct {
      get{
        try{
          List<Account> soldToAcctList = new List<Account>();
          System.debug('*** In Try Block soldToAcct *** ');
            //SOQL to check for Sold To Account
            String currAcctGroup = [SELECT ERP_Active__c, SAP_Sold_To__c, Account_Group__c
                    FROM Account
                    WHERE SAP_Sold_To__c != NULL
                    AND SAP_Sold_To__c = :ApexPages.currentPage().getParameters().get('cid')
                    AND ERP_Active__c = TRUE
                    LIMIT 1].Account_Group__c;

            if(currAcctGroup == 'Z002'){
              System.debug('*** In Try Block soldToAcct IF *** ');
                String soldToAcctString = [SELECT Sale_to__c, Ship_to__c FROM Contract_Partnership__c WHERE Ship_to__c =: ApexPages.currentPage().getParameters().get('cid') LIMIT 1].Sale_to__c;
                soldToAcctList = [SELECT Name, SAP_Sold_To__c, ShippingStreet, ShippingCity,
                                  ShippingState, ShippingPostalCode, ShippingCountry, Price_List_Type__c
                                  FROM Account
                                  WHERE SAP_Sold_To__c != NULL
                                  AND SAP_Sold_To__c = :soldToAcctString
                                  AND ERP_Active__c = TRUE
                                  LIMIT 1];

                if(soldToAcctList.size() ==  0){
                  soldToAcctList = [SELECT Name, SAP_Sold_To__c, ShippingStreet, ShippingCity,
                                    ShippingState, ShippingPostalCode, ShippingCountry, Price_List_Type__c
                                    FROM Account
                                    WHERE SAP_Sold_To__c != NULL
                                    AND SAP_Sold_To__c = :soldToAcctString
                                    LIMIT 1];
                }
                System.debug('*** soldToAcctList.size() if *** ' + soldToAcctList.size() );
                System.debug('*** soldToAcctList if *** ' + soldToAcctList );
                if(soldToAcctList.size() == 0){
                    return null;
                }
                else{
                    return soldToAcctList;
                }
            }
            else{
              System.debug('*** In Try Block soldToAcct ELSE *** ');
              String soldToAcctString = [SELECT Sale_to__c, Ship_to__c FROM Contract_Partnership__c WHERE Ship_to__c =: ApexPages.currentPage().getParameters().get('cid') LIMIT 1].Sale_to__c;
                soldToAcctList = [SELECT Name, SAP_Sold_To__c, ShippingStreet, ShippingCity,
                                  ShippingState, ShippingPostalCode, ShippingCountry, Price_List_Type__c
                                  FROM Account
                                  WHERE SAP_Sold_To__c != NULL
                                  AND SAP_Sold_To__c = :soldToAcctString
                                  LIMIT 1];

                System.debug('*** soldToAcctList.size() else *** ' + soldToAcctList.size() );
                System.debug('*** soldToAcctList else *** ' + soldToAcctList );
                if(soldToAcctList.size() == 0){
                    return null;
                }
                else{
                    return soldToAcctList;
                }
            }
        }//end of Try
        catch(Exception e){
            system.debug('Exceptions' + e);
            return NULL;
        }
      }
      set;
    }//end of soldToAcct



    public pagereference getURL(){
        System.debug('*** IN getURL Method PP_Price_Lookup Class ***');
        string cnum = cnumber;
        string pnum = pnumber;
        if(cnum != NULL) cnum = cnum.trim();
        if(pnum != NULL) pnum = pnum.trim();

        //Start Account Access Check for Sold-To
        Set<String> aCheckSet = new Set<String>();
        Set<String> cnListSet = new Set<String>();

        try{
            Account acheck = [SELECT Id, Account_Group__c, Sap_Sold_To__c
                          FROM Account
                          WHERE ERP_Active__c = TRUE
                          AND SAP_Sold_To__c = :cnum LIMIT 1];

            System.debug('*** acheck *** ' + acheck);
            if(acheck.Account_Group__c == 'Z002'){
               for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                                 FROM Contract_Partnership__c
                                                 WHERE Ship_to__c = :cnum])
               {
                   cnListSet.add(cp.Sale_to__c);
               }

            }//end if
            else{
                System.debug('In else');
            }

            aCheckSet.add(acheck.SAP_Sold_To__c);
            cnListSet.add(acheck.SAP_Sold_To__c);
            System.debug('*** aCheckSet *** ' + aCheckSet);
            System.debug('*** cnListSet *** ' + cnListSet);
            PP_Customer_Detail_Helper custHelp = new PP_Customer_Detail_Helper();
            custHelp.checkSecurity(cnListSet, aCheckSet);
            //End Account Access Check for Sold-To

            PageReference priceLookup = New Pagereference('/apex/PP_Price_Lookup?cid=' + cnum + '&pid='+ pnum);
            priceLookup.setRedirect(true);
            return priceLookup;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            PageReference priceLookup = New Pagereference('/apex/PP_Price_Lookup?cid=' + cnum + '&pid='+ pnum);
            priceLookup.setRedirect(true);
            return priceLookup;
        }
    }//end of getURL

    public pagereference getSample(){
        PageReference sample = New Pagereference('/apex/PP_Price_Lookup?cid=102059&pid=000-11');
        sample.setRedirect(true);
        return sample;
    }//end of getSample

    public List<Account> getAccts(){
        try{

            return [SELECT Name, SAP_Sold_To__c, ShippingStreet, ShippingCity, Account_Group__c,
                    ShippingState, ShippingPostalCode, ShippingCountry, Price_List_Type__c
                    FROM Account
                    WHERE SAP_Sold_To__c != NULL
                    AND SAP_Sold_To__c = :ApexPages.currentPage().getParameters().get('cid')
                    AND ERP_Active__c = TRUE
                    LIMIT 1];

        }//end of Try
        catch(Exception e){
            system.debug('Exceptions' + e);
            return NULL;
        }

    }//end of getAccts

    public Product2 getp(){
        try{
            return [SELECT Id, Name, Sales_Org__c , List_Price__c, Description,
                    Sales_unit__c, Qty_sales_unit__c, Rep_Price__c, RSM_Price__c,
                    Distribution_Channel__c, CurrencyIsoCode,
                    Distributor_List__c, Alt_Site_List__c, MRP_Group__c
                    FROM PRODUCT2
                    WHERE Name = :ApexPages.currentPage().getParameters().get('pid')
                    AND Sales_Org_Key__c = :PP_Menu.salesOrgKey
                    AND Duplicate__c = FALSE
                    AND SearchableProducts__c = TRUE
                    ORDER BY Sales_Org__c ASC
                    LIMIT 1];
        }
        catch(Exception e){
            system.debug('Exceptions' + e);
            return NULL;
        }

    }//end of getp

    public list<SAPRealPriceSet__x> getPrice(){
        List<SAPRealPriceSet__x> listSAP = new List<SAPRealPriceSet__x>();

        String soldToType; //Variable to hold Sold To Price List Type
        String shipTo; //variable to hold ship to code
        if(ApexPages.currentPage().getParameters().get('cid') != NULL
           && ApexPages.currentPage().getParameters().get('pid') != NULL){
               // Step 1
               // a. Set up our Variables
               string sapSoldTo = ApexPages.currentPage().getParameters().get('cid');
               shipTo = ApexPages.currentPage().getParameters().get('cid');
               string searchMaterials = ApexPages.currentPage().getParameters().get('pid');
               String salesOrg;
               String SAP_1stPick = '00000000';

               Account acheck;
               Product2 mcheck;

               // Used to return the Text Status. Example: 40 = Saleable (40)
               PP_General_Helper_Class ghc = new PP_General_Helper_Class();
               map<String, String> mstatMap = ghc.mstatus();

               // Used to 'fix' SAP Conditions when they return something other than (XIND, XPRI, XSEC, X)
               Map<String, String> cMap = new Map<String, String>();
               for(Sales_Condition_Mapping__c scm : [SELECT Name, Mapped_Value__c FROM Sales_Condition_Mapping__c]){
                   cMap.put(scm.Name, scm.Mapped_Value__c);
               }

               // Used to create a Objective Mapping in english instead of numbers
               Map<String, String> obMap = new Map<String, String>();
               obMap.put('01', 'Direct/Rebate');
               obMap.put('02', 'Direct');
               obMap.put('03', 'Distributor Netbill');
               obMap.put('04', 'Specialty Market');
               obMap.put('05', 'Strategic Accounts');
               obMap.put('06', 'Rebate Only');


               // b. Check to see if the Account and Product are valid
               try{
                   salesOrg = [SELECT Active_Sales_Org_Key__c
                               FROM Contract_User__c
                               WHERE User__c = :UserInfo.getUserId()
                               LIMIT 1].Active_Sales_Org_Key__c;
                   if(salesOrg == NULL){
                       salesOrg = 'US6010'; // Set a default of US just in case the user doesn't have Portal User - ESC 06Jul2016
                   }
                   acheck = [SELECT Id, Account_Group__c, Sap_Sold_To__c
                             FROM Account
                             WHERE ERP_Active__c = TRUE
                             AND SAP_Sold_To__c = :sapSoldTo LIMIT 1];
                   mcheck = [SELECT Id, Sales_Org__c, Distribution_Channel__c
                             FROM PRODUCT2
                             WHERE Name = :searchMaterials
                             //AND Sales_Org_Key__c = :PP_Menu.salesOrgKey
                             AND Sales_Org_Key__c = :salesOrg
                             AND Duplicate__c = FALSE
                             AND SearchableProducts__c = TRUE
                             LIMIT 1];

               }
               catch(Exception e){
                   system.debug('Exception: ' + e);
               }
               system.debug('mcheck: ' + mcheck);
               system.debug('acheck: ' + acheck);

               // c. Create our list of Sold-to/Ship-to relationships
               if(mcheck != NULL && acheck != NULL){
                   system.debug('Starting getPrice');
                   list<string> cnlist = new list<String>();
                   Set<String> cnListSet = new Set<String>();

                   // Primary Customer Number (pcn) to the current account and if we are a 'Ship-To' account and there is a valid
                   // 'Sold-to' relationship in the 'Contract Partnership' table then we reset that to the Last Sold-to in the table.
                   // There is supposed to be only one to one but you can have as many as 3-4 hits on rare occasion.
                   string pcn = sapSoldTo;
                   // Customer Number List (cnlist) is the list of Customer numbers we will use to generate our list of 'Contract Customers'
                   cnlist.add(sapSoldTo);
                   if(acheck.Account_Group__c == 'Z002'){
                       for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                                         FROM Contract_Partnership__c
                                                         WHERE Ship_to__c = :sapSoldTo])
                       {
                           cnlist.add(cp.Sale_to__c);
                           cnListSet.add(cp.Sale_to__c);
                           pcn = cp.Sale_to__c;
                       }

                       //Query to get Price List Type of SAP Sold To Account
                       soldToType = [SELECT Price_List_Type__c FROM Account WHERE SAP_Sold_To__c = :pcn LIMIT 1].Price_List_Type__c;
                   }
                   system.debug('second check' + pcn + ' - ' + cnlist);


                   // Contract Customer Agreement List (ccaList) is used to filter our Contract Materials
                   list<String> ccaList = new list<String>();
                   for(Contract_Customer__c cc : [SELECT Agreement__r.Agreement_Number__c
                                                  FROM Contract_Customer__c
                                                  WHERE Account__r.SAP_Sold_To__c IN :cnlist
                                                  AND Active__c = TRUE])
                   {
                       ccaList.add(cc.Agreement__r.Agreement_Number__c);
                   }
                   system.debug('ccalist:' + ccaList);

                   // Contract Material List - Used to filter the Contract Customers
                   list<String> cmList = new list<String>();
                   // Material Map - Used to filter...
                   map<String, String> matMap = new map<String, String>();
                   for(Contract_Material__c cm : [SELECT Product__r.Name, Agreement__r.Agreement_Number__c, Agreement__r.Sales_Org__c, Price__c
                                                  FROM Contract_Material__c
                                                  WHERE Product__c = :mcheck.Id
                                                  AND Agreement_Number__c IN :ccaList
                                                  AND Active__c = TRUE
                                                  ORDER BY Price__c])
                   {
                       cmList.add(cm.Agreement__r.Agreement_Number__c);
                       matMap.put(cm.Agreement__r.Agreement_Number__c, cm.Product__r.Name);
                   }
                   system.debug('cmList.size: ' + cmList.size());

                   // Step Asks SAP for the Eligible Price
                   list<SAPRealPriceSet__x> sapList = new list<SAPRealPriceSet__x>();
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
                           Condition__c = 'XIND',
                           OwnerName__c = 'Duke Univ Health System',
                           Owner__c = 'IDN-032',
                           AgrObjective__c = '01',
                           Customer__c  = '102059'
                       );
                       sapList.add(testSAP);
                   }//end if(Test.isRunningTest())
                   else{
                        system.debug('*** mcheck.Sales_Org__c *** ' + mcheck.Sales_Org__c);
                        system.debug('*** mcheck.Distribution_Channel__c *** ' + mcheck.Distribution_Channel__c);
                        system.debug('*** pcn *** ' + pcn);
                        system.debug('*** searchMaterials *** ' + searchMaterials);
                        system.debug('*** shipTo *** ' + shipTo);
                       sapList = [SELECT SalesDeal__c, Price__c, Material__c, MtrlStatus__c,
                                  ValidFrom__c, ValidTo__c, Agreement__c, AgrDesc__c, Condition__c,
                                  OwnerName__c, Owner__c, AgrObjective__c, Customer__c, SalesMtrlStatus__c,
                                  DistChnl__c,MatDesc__c,vat__c,Currency__c,ShipTo__c
                                  FROM SAPRealPriceSet__x
                                  where SalesOrg__c = :mcheck.Sales_Org__c
                                  AND DistChnl__c = :mcheck.Distribution_Channel__c
                                  AND Customer__c = :pcn
                                  AND Material__c = :searchMaterials
                                  AND ShipTo__c = :shipTo
                                  AND EffDate__c = :datetime.now()
                                  LIMIT 1 ];
                   }//end else


                   for(SAPRealPriceSet__x sap : sapList)
                   {
                       system.debug('*** sap 1st loop *** ' + sap);

                       string objname;
                       string mstatus;
                       string cnum2;
                       string ostr;

                       if(obMap.get(sap.AgrObjective__c) != NULL){
                           objname = obMap.get(sap.AgrObjective__c);
                       }
                       else{
                           objname = sap.AgrObjective__c;
                       }

                       string conremap = sap.Condition__c;
                       if(cMap.get(sap.Condition__c) != NULL){
                           conremap = cMap.get(sap.Condition__c);
                       }
                       system.debug('conditionMap: ' + cMap);


                       if(sap.SalesMtrlStatus__c != NULL){
                           mstatus = sap.SalesMtrlStatus__c;
                       }
                       else if(sap.MtrlStatus__c != NULL){
                           mstatus = sap.MtrlStatus__c;
                       }
                       else{
                           mstatus = '';
                       }
                       // Strip the leading zero's
                       system.debug('sap.Customer__c: ' + sap.Customer__c);
                       if(sap.Customer__c != NULL){
                           cnum2 = sap.Customer__c.replaceAll('^0+', '');
                       }
                       if(sap.Owner__c != NULL){
                           ostr = sap.Owner__c.replaceAll('^0+', '');
                       }

                       SAPRealPriceSet__x newSAP = new SAPRealPriceSet__x(
                           SalesDeal__c = sap.SalesDeal__c,
                           Price__c = sap.Price__c,
                           Material__c = sap.Material__c,
                           MtrlStatus__c = mstatus,
                           ValidFrom__c = sap.ValidFrom__c,
                           ValidTo__c = sap.ValidTo__c,
                           AgrDesc__c = sap.AgrDesc__c,
                           Condition__c = conremap,
                           OwnerName__c = sap.OwnerName__c,
                           Owner__c = ostr,
                           AgrObjective__c = objname,
                           Customer__c  = cnum2,
                           SalesMtrlStatus__c = sap.SalesMtrlStatus__c,
                           Currency__c = sap.Currency__c
                       );

                       system.debug('*** newSAP 1st *** ' + newSAP);

                       if(sap.SalesDeal__c != NULL){
                           SAP_1stPick = sap.SalesDeal__c.replaceAll('^0+', '');
                       }

                       // This is now in the helper class so that we can use this across objects if needed.
                       // Also fixes the test coverage issue. - 05Jul2016 ESC
                       if(mstatMap.get(mstatus) != NULL){
                           status = mstatMap.get(mstatus);
                       }
                       else{
                           status = 'None';
                       }

                       listSAP.add(newSAP);
                       system.debug('Catch!: ' + newSAP);
                   }

                   // Starts a loop through the list of Contracts in Salesforce.com
                   for(Contract_Customer__c cc : [SELECT Agreement__r.Agreement_Number__c, Account__r.SAP_Sold_To__c, Condition__c
                                                  FROM Contract_Customer__c
                                                  WHERE Agreement__r.Agreement_Number__c IN :cmList
                                                  AND Account__r.SAP_Sold_To__c IN :cnlist
                                                  AND Active__c = TRUE
                                                  order by Condition_Rank__c
                                                  LIMIT 10])
                   {
                       system.debug('Agreement_Number__c.right(8)' + cc.Agreement__r.Agreement_Number__c.right(8));
                       if (Test.isRunningTest()) {
                           SAPRealPriceSet__x testSAP = new SAPRealPriceSet__x(
                               SalesDeal__c = '50009064',
                               Price__c = 123.00,
                               Material__c = '353535',
                               MtrlStatus__c = '40',
                               SalesMtrlStatus__c = '40',
                               ValidFrom__c = Date.Today(),
                               ValidTo__c = Date.Today() + 1000,
                               AgrDesc__c = 'Duke University SURGR',
                               Condition__c = 'XIND',
                               OwnerName__c = 'Duke Univ Health System',
                               Owner__c = 'IDN-032',
                               AgrObjective__c = '01',
                               Customer__c  = '102059'
                           );
                           sapList.add(testSAP);
                       }
                       else{
                        system.debug('*** mcheck.Sales_Org__c *** ' + mcheck.Sales_Org__c);
                        system.debug('*** mcheck.Distribution_Channel__c *** ' + mcheck.Distribution_Channel__c);
                        system.debug('*** cc.Agreement__r.Agreement_Number__c *** ' + cc.Agreement__r.Agreement_Number__c);
                        system.debug('*** cc.Account__r.SAP_Sold_To__c *** ' + cc.Account__r.SAP_Sold_To__c);
                        system.debug('*** matMap.get(cc.Agreement__r.Agreement_Number__c) *** ' + matMap.get(cc.Agreement__r.Agreement_Number__c));
                        system.debug('*** shipTo *** ' + shipTo);
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
                       }


                       // Looking to exclude the Contract that we got from SAP
                       if(SAP_1stPick != cc.Agreement__r.Agreement_Number__c.right(8)){
                           for(SAPRealPriceSet__x sap : sapList)
                           {
                                system.debug('*** sap 2nd loop *** ' + sap);
                               if(sap.SalesDeal__c != NULL){

                                   string objname;
                                   string mstatus;
                                   string cnum;
                                   string ostr;

                                   if(obMap.get(sap.AgrObjective__c) != NULL){
                                       objname = obMap.get(sap.AgrObjective__c);
                                   }
                                   else{
                                       objname = sap.AgrObjective__c;
                                   }


                                   if(sap.SalesMtrlStatus__c != NULL){
                                       mstatus = sap.SalesMtrlStatus__c;
                                   }
                                   else if(sap.MtrlStatus__c != NULL){
                                       mstatus = sap.MtrlStatus__c;
                                   }
                                   else{
                                       mstatus = '';
                                   }

                                   if(sap.Customer__c != NULL){
                                       cnum = sap.Customer__c.replaceAll('^0+', '');
                                   }
                                   if(sap.Owner__c != NULL){
                                       ostr = sap.Owner__c.replaceAll('^0+', '');
                                   }

                                   SAPRealPriceSet__x newSAP = new SAPRealPriceSet__x(
                                       SalesDeal__c = sap.SalesDeal__c,
                                       Price__c = sap.Price__c,
                                       Material__c = sap.Material__c,
                                       MtrlStatus__c = mstatus,
                                       ValidFrom__c = sap.ValidFrom__c,
                                       ValidTo__c = sap.ValidTo__c,
                                       Agreement__c = sap.Agreement__c,
                                       AgrDesc__c = sap.AgrDesc__c,
                                       Condition__c = cc.Condition__c,
                                       OwnerName__c = sap.OwnerName__c,
                                       Owner__c = ostr,
                                       AgrObjective__c = objname,
                                       Customer__c = cnum,
                                       Currency__c = sap.Currency__c
                                   );

                                   system.debug('*** newSAP 2nd *** ' + newSAP);
                                   // Start Status Routine.
                                   // This is now in the helper class so that we can use this across objects if needed.
                                   // Also fixes the test coverage issue. - 05Jul2016 ESC

                                   if(mstatMap.get(mstatus) != NULL){
                                       status = mstatMap.get(mstatus);
                                   }
                                   else{
                                       status = 'None';
                                   }
                                   // End Status Routine

                                   listSAP.add(newSAP);
                               }//end of if(sap.SalesDeal__c != NULL)

                           }//end of for(SAPRealPriceSet__x sap : sapList)

                       }//end of if(SAP_1stPick != cc.Agreement__r.Agreement_Number__c.right(8))
                   }
               }
               return listSAP;
           }

        else{
            return listSAP;
        }
    }

    public Map<Id,String> getFormatSalesPrice(Product2 prod ){
      System.debug('*** IN getFormatListPrices *** ');
      //System.debug('*** getProduct2 *** ' + getProduct2);
        Decimal formDec;
        String newDec;
        //for(Product2 curr : prodList ){
          System.debug('*** prod.Id *** ' + prod.Id);
          System.debug('*** prod.Sales__c *** ' + prod.Sales__c);
            if(userLocale != 'en_US'){
                System.debug('*** userLocale *** ' + userLocale);
                if(prod.Sales__c == NULL){
                  prod.Sales__c = 0;
                  formDec = prod.Sales__c;
                }
                else{
                  formDec = prod.Sales__c;
                }
                System.debug('*** formDec *** ' + formDec);
                newDec = formDec.format();
                System.debug('*** newDec *** ' + newDec);
                formatSalesPrice.put(prod.Id,newDec);
            }
            else{
              if(prod.Sales__c == NULL){
                prod.Sales__c = 0;
              }
                System.debug('*** formDec *** ' + formDec);
                newDec = String.valueOf(prod.Sales__c);
                System.debug('*** newDec *** ' + newDec);
                formatSalesPrice.put(prod.Id,newDec);
            }
        //}
        System.debug('*** formatSalesPrice *** ' + formatSalesPrice);
        return formatSalesPrice;
    }//end of getFormatListPrices

}//end of class