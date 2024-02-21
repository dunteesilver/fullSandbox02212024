public class PP_Print_Quote {

    public Id OrgId {get{ return UserInfo.getOrganizationId();} set;}

    public string r {

        get {
            string rend;
            if(ApexPages.currentPage().getParameters().get('r') == 'pdf') rend = 'pdf';

            return rend;
        }
        set;
      }

    //get user Region to determine address in header
    public String userRegion{
      get{
        try {
            return [SELECT Id, Region__c FROM User
                    WHERE Id = :UserInfo.getUserId()].Region__c;
        }
        catch(Exception e) {
            system.debug('Exception: ' + e);
            return NULL;
        }
      }//end get    
    }//end String userRegion

    public Standard_Text__c quoteStandardText{get;set;}
    public Price_Quote__c pqRec {get;set;}

    public Price_Quote__c pq { get{
        Try {
            return [Select Name, Commit_Date__c, Grand_Total__c, Stationary__c, CreatedDate, BusinessUnit__c, Business_Unit__c, 
                    Show_Images__c, Show_List_Price__c, Account_Name__r.Name, Account_Name__r.BillingStreet,
                    Account_Name__r.BillingCity, Account_Name__r.BillingState, Account_Name__r.BillingPostalCode,
                    Account_Name__r.BillingCountry, Account_Name__r.ShippingStreet,
                    Account_Name__r.ShippingCity, Account_Name__r.ShippingState, Account_Name__r.ShippingPostalCode,
                    Account_Name__r.ShippingCountry,Account_Name__r.SAP_Sold_To__c, Quote_Description__c,
                    Customer_comments__c, Expiration_Date__c, Owner_Full_Name__c, Owner_Cell__c, CurrencyIsoCode,
                    Owner_Phone__c, Owner_Email__c, Contact_Name__r.name, Contact_Name__r.phone, Contact_Name__r.email,
                    Contact_Name__r.salutation, Line_Count__c, Template__c, Tax__c, Shipping__c, Quote_Template__c, Discount__c,
                    Discounted_Total__c, Discount_Type__c, Sales_Org_Key__c, Type__c, Total_Without_Trade_Ins__c, Sold_To__c,
                    Language__c, Account_Name__r.Incoterms_1__c, Account_Name__r.Incoterms_2__c, Account_Name__r.CurrencyIsoCode,
                    Account_Name__r.Terms__c, Account_Name__r.Account_Name_2__c, Language_Formula__c
                    FROM Price_Quote__c
                    WHERE id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];
        }
        catch(Exception e) {
            system.debug('Exception: ' + e);
            return NULL;
        }
    } set; }

    //Eligible_Price__c, List_Price__c, Rep_Price__c, RSM_Price__c, Sales_Number__c, Sales_Deal_Description__c, Condition__c

    public list<Price_Quote_Line_Item__c> getpqli(){
        try {
            return [Select Material_Name__r.name, Material_Name__r.Low_Res_Image__c, Material_Name__r.Hi_Res_Image__c,
                    Material_Name__r.Brand_Name__c, Description__c, Material_Name__r.Qty_Sales_Unit__c,
                    Material_Name__r.Sales_Unit__c, Quantity__c, Sales_Price__c, Extended_Price__c,
                    IsBold__c, Material_Name__r.List_Price__c, Row_Order__c, Product_Description__c,
                    Material_Name__r.Cardiac_Complimentary__c, Eligible_Price__c, Sales_Unit_Qty__c,
                    Sales_Deal__r.Owner_Name__c, Sales_Deal__r.GPO_Contract_Ref__c, Sales_Deal_Tier__c,
                    Do_Not_Show_Zero_Pricing__c, Material_Name__r.Sales_Org__c, Price_per_each__c, Total_Price_Per_Each__c,
                    Line_Price__c, VAT__c, Material_Description__c, Total__c, Material_Name__r.Material_key__c, Sales_Number__c
                    FROM Price_Quote_Line_Item__c
                    WHERE Price_Quote__c = :ApexPages.currentPage().getParameters().get('id') ORDER BY Row_Order__c];
        }
        catch(Exception e) {
            system.debug('Exception: ' + e);
            return NULL;
        }
    }

    //method to return contract materials to add validity dates to the export
    public List<Contract_Material__c> getConMatList(){
        List<String> prodKeyList = new List<String>(); //list to hold material keys on pqli
        List<String> salesDealList = new List<String>(); //list to hold material keys on pqli
        List<Price_Quote_Line_Item__c> pqliRecList = getpqli(); //get pqli records
        //Map<String,Price_Quote_Line_Item__c> dealMatMap = new Map<String,Price_Quote_Line_Item__c>(); //create map of sales deal and material

        //loop through price quote line items to get product keys
        for (Price_Quote_Line_Item__c curr : pqliRecList) {
            String prodKey = curr.Material_Name__r.Material_key__c;  // Replace with the actual field name
            prodKeyList.add(prodKey);
            //check if sales number is not null
            if(curr.Sales_Number__c != NULL){
                String dealMatKey = curr.Material_Name__r.Material_key__c +'-'+ curr.Sales_Number__c;
                salesDealList.add(curr.Sales_Number__c);
                //dealMatMap.put(dealMatKey,curr);
            }
        }

        try{
            return [
                SELECT Id, Agreement_Number__c,Material_Lookup_Key__c,Material_Name__c,Valid_From__c,Valid_To__c 
                FROM Contract_Material__c 
                WHERE Agreement_Number__c IN :salesDealList AND Active__c = true AND Material_Lookup_Key__c IN :prodKeyList
            ];
        }catch (Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }//end contract material list
    
    public list<Price_Quote_Line_Item__c> getpqli_export(){
        try {
            return [Select Material_Name__r.name, Material_Name__r.Brand_Name__c, Description__c,
                    Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Sales_Unit__c, Quantity__c, Row_Order__c,
                    Sales_Price__c, Extended_Price__c, Eligible_Price__c, List_Price__c, Rep_Price__c, Line_Price__c,
                    RSM_Price__c, Sales_Number__c, Sales_Deal_Description__c, Condition__c, Product_Description__c,
                    Do_Not_Show_Zero_Pricing__c, Material_Name__r.Sales_Org__c, Price_per_each__c, Total_Price_Per_Each__c,
                    VAT__c, Material_Description__c
                    FROM Price_Quote_Line_Item__c
                    WHERE Price_Quote__c = :ApexPages.currentPage().getParameters().get('id')  ORDER BY Row_Order__c];
        }
        catch(Exception e) {
            system.debug('Exception: ' + e);
            return NULL;
        }
    }
    
    //Get Current User's Timezone Settings
    Public User objUser= [SELECT timezonesidkey FROM user WHERE Id =:UserInfo.getUserId()];
    public Map<String,String> formatDate {get;set;} //map to get formatted date on VF page
    //Get list of approvers for Export for LATAM
    public list<ProcessInstanceStep> getApproversList(){
        Datetime dtDateTime;
        String strDateTime;
        String pqId = ApexPages.currentPage().getParameters().get('id');
        formatDate = new Map<String,String>();
        List<ProcessInstanceStep> appList = new List<ProcessInstanceStep>();
        List<ProcessInstanceStep> timeFixList = new List<ProcessInstanceStep>();
        try {
            appList = [SELECT Actor.Name, Comments, CreatedDate, Id, OriginalActor.Name, StepStatus,ProcessInstance.TargetObjectId 
            FROM ProcessInstanceStep 
            WHERE ProcessInstance.TargetObjectId =:ApexPages.currentPage().getParameters().get('id') 
            ORDER BY CreatedDate ASC];
            
            for(ProcessInstanceStep curr : appList){
                dtDateTime = curr.CreatedDate;
                //strDateTime = dtDateTime.format('MM/dd/yyyy HH:mm:ss', objUser.timezonesidkey );
                //curr.CreatedDate = dtDateTime.format('MM/dd/yyyy HH:mm:ss', UserInfo.getTimeZone() );
                if(pq.Sales_Org_Key__c == 'AU1010' || pq.Sales_Org_Key__c == 'NZ1010'){
                    //Set date/time format for ANZ
                    strDateTime = dtDateTime.format('dd/MM/yyyy HH:mm:ss a', UserInfo.getTimeZone().toString() );
                }
                else{
                    //Set date/time format for all except ANZ
                    strDateTime = dtDateTime.format('MM/dd/yyyy HH:mm:ss a', UserInfo.getTimeZone().toString() );
                }
                //strDateTime = dtDateTime.format('MM/dd/yyyy HH:mm:ss a', UserInfo.getTimeZone().toString() );
                System.debug('strDateTime: ' + strDateTime);
                formatDate.put(curr.Id,strDateTime);
                //timeFixList.add(curr);
            }
            System.debug('formatDate: ' + formatDate);
            //System.debug('User Timezone: ' + UserInfo.getTimeZone().toString());
            //System.debug('timeFixList: ' + timeFixList);
            return appList;
        }
        catch(Exception e) {
            system.debug('Exception: ' + e);
            return NULL;
        }
        
    }//end of getApproversList
    
    public map<string, Quote_Logos__c> getsm(){

        map<string, Quote_Logos__c> sMap = new map<string, Quote_Logos__c>();
        //sMap.put('', 'Test');
        for(Quote_Logos__c ql : Quote_Logos__c.getAll().values()){
            sMap.put(ql.name, ql);
        }
        system.debug('Mapping:' + sMap);
        return sMap;
    }
    public String rxls {
        get {
            string temp_name;
            if(ApexPages.currentPage().getParameters().get('rs') == 'xls'){
                temp_name = 'Price Quote - ';
                temp_name += [Select Price_Quote_Name__c FROM Price_Quote__c WHERE id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1].Price_Quote_Name__c;
                if(pq.Sales_Org_Key__c == 'AU1010' || pq.Sales_Org_Key__c == 'NZ1010'){
                    //Set date/time format for ANZ
                    temp_name += ' - ' + datetime.now().format('dd-MM-yyyy');
                }
                else{
                    //Set date/time format for all except ANZ
                    temp_name += ' - ' + datetime.now().format('MM-dd-yyyy');
                }
                //temp_name += ' - ' + datetime.now().format('MM-dd-yyyy');
                temp_name += 'application/vnd.ms-excel#' + temp_name + '.xls';
            }
            return temp_name;
        }
        set; }

    public String pdfFileName {
        get {
            string temp_name;
            if(ApexPages.currentPage().getParameters().get('r') == 'pdf'){
                temp_name = 'Price Quote - ';
                temp_name += [Select Price_Quote_Name__c FROM Price_Quote__c WHERE id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1].Price_Quote_Name__c;
                if(pq.Sales_Org_Key__c == 'AU1010' || pq.Sales_Org_Key__c == 'NZ1010'){
                    //Set date/time format for ANZ
                    temp_name += ' - ' + datetime.now().format('dd-MM-yyyy');
                }
                else{
                    //Set date/time format for all except ANZ
                    temp_name += ' - ' + datetime.now().format('MM-dd-yyyy');
                }
                //temp_name += ' - ' + datetime.now().format('MM-dd-yyyy');
                temp_name += 'application/x-pdf#' + temp_name + '.pdf';
            }
            return temp_name;
        }
        set; }

    public String qURL { get{
        Map<String, Quote_Logos__c> buMap = Quote_Logos__c.getAll();
        if(buMap.get(pq.Stationary__c) != NULL){
            return buMap.get(pq.Stationary__c).Quote_Page__c;
        }
        else{
            return 'PP_Print_Quote_TFX';
        }
    } set; }
    
    //public static Document document1 {get;set;}
    //public static Document document2 {get;set;}
    public StaticResource att {
        get {
            if (att == null) {
                att = [SELECT Description,Id,Name, ContentType, Body FROM StaticResource WHERE Name = 'CardiacGeneralTerms1'];
            }
            return att;
        }
        private set;
    }
    public String pdf {
        get {
            return EncodingUtil.Base64Encode(att.body);
        }
    }

    public string custLang{get;set;}
    public string languageCode{get;set;}
    public Decimal calculateVatTotal{get;set;}
    public decimal totalWithoutTradeins{get;set;} //used to calculate total for ANES/EMS Tradein
    public Map<String,String> labelsMap{get;set;}
    public PP_Print_Quote(){
        //document1 = [Select Id,name From Document Where Name like 'Cardiac General%'];
        //document2 = [Select Id,name From Document Where Name like 'Cardiac General%'];
        calculateVatTotal = 0;
        totalWithoutTradeins = 0;
        String salesOrgKey = pq.Sales_Org_Key__c;
        String salesOrg = salesOrgKey.left(4);
        labelsMap = new Map<String,String>();
        //PP_Print_Center pcStandardTexts = new PP_Print_Center();
        if(pq.BusinessUnit__c == 'EMEA'){
            emeaStandardTexts(salesOrg);

        }
        
        //set template language to ShipTo customer
        //$CurrentPage.parameters.lang
        switch on pq.Language_formula__c {
            when 'English' {    // when block 1
                custLang = 'en_US';
            }  
            when 'French' {    // when block 2
                custLang = 'fr';
            }
            when 'Spanish' {    // when block 3
                custLang = 'es';
            }
            when 'German' {    // when block 4
                custLang = 'de';
            }
            when 'Dutch' {    // when block 5
                custLang = 'nl';
            }
            when 'Czech' {    // when block 6
                custLang = 'cs';
            }
            when 'Slovak' {    // when block 7
                custLang = 'sk';
            }
            when 'Slovakian' {    // when block 7
                custLang = 'sk';
            }
            when 'Portuguese' {    // when block 6
                custLang = 'pt_PT';
            }
            when 'Polish' {    // when block 7
                custLang = 'pl';
            }
            when 'Italian' {    // when block 7
                custLang = 'it';
            }
            when else {      // default block, optional
                custLang = 'en_US';
            }
        }//end switch
        /*
        String userLanguageCode = UserInfo.getLanguage();
        String pqLanguage;
        
        if(pq.Language__c != NULL){
            pqLanguage = pq.Language__c;
        }else{
            pqLanguage = 'en_US';
        }
        */

        //Get label translations
        List<Label_Translation__c> langTransList = [SELECT Id, Name, Label_Name__c, Translated_Value__c,
                                                    Sales_Org__c, Sales_Org_Key__c, Language_Code__c
                                                    FROM Label_Translation__c
                                                    WHERE Sales_Org_Key__c =:pq.Sales_Org_Key__c];

        //passing language translations to map
        if(langTransList.size() > 0){
            labelsMap = getlabelsMap(langTransList);
            languageCode = langTransList[0].Language_Code__c;
        }
    }//end PP_Print_Quote constructor
    
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

    //Standard Texts for EMEA PQs to hold supplier/banking information
    public Standard_Text__c emeaStandardTexts(String salesOrg){
        quoteStandardText = new Standard_Text__c();
        if(salesOrg != NULL){
            List<Standard_Text__c> standardTestList = [SELECT Bank_Name__c,Country_Specific_1__c,Country_Specific_2__c,Country_Specific_3__c,Country_Specific_4__c,
                                                       Country__c,CurrencyIsoCode,Email__c,Fax__c,IBAN__c,Id,Name,Other_Bank_Name__c,Other_Email__c,Other_IBAN__c,
                                                       Other_Phone__c,Other_SWIFT_Code__c,OwnerId,Phone__c,Sales_Org__c,Street__c,SWIFT_Code__c,VAT_Number__c,Zip_City__c 
                                                       FROM Standard_Text__c 
                                                       WHERE Sales_Org__c =:salesOrg LIMIT 1];
            if(standardTestList.size() > 0){
                quoteStandardText = standardTestList[0];
            }
        }
        
        System.debug('*** quoteStandardText.Description 1 *** ' + quoteStandardText);
        return quoteStandardText;
    }

    //pulls information for Sold To Account on PQ... Added for EMEA Quote Template
    public Account getSoldToAccount(){
        try{
            if(pq.Sold_To__c != NULL){
                return [SELECT Id, Name, SAP_Sold_To__c, ERP_Active__c,
                        ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,
                        ShippingCountry, Description,
                        Incoterms_1__c, Incoterms_2__c, Terms__c, Account_Name_2__c
                        FROM Account
                        WHERE SAP_Sold_To__c =: pq.Sold_To__c
                        LIMIT 1];
            }
            else{
                return [SELECT Id, Name, SAP_Sold_To__c, ERP_Active__c,
                        ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,
                        ShippingCountry, Description,
                        Incoterms_1__c, Incoterms_2__c, Terms__c, Account_Name_2__c
                        FROM Account
                        WHERE SAP_Sold_To__c =: pq.Account_Name__r.SAP_Sold_To__c
                        LIMIT 1];
            }
        }
        catch(Exception e) {
            system.debug('Exception: ' + e);
            return NULL;
        }
    }//end of getSoldToAccount

    //Wrapper class used in getGroupedLineItemsMap method
    public class VatEntryWrapper {
        public Decimal vatPercentage { get; set; }
        public List<Price_Quote_Line_Item__c> lineItems { get; set; }
        public Decimal total { get; set; }
        public Decimal vatAmount {get;set;}
        public Decimal subTotal { get; set; }
    }

    //Method is used to aggregate the line items by VAT percentage for EMEA quote template (PP_Print_Quote_EMEA)
    public List<VatEntryWrapper> getGroupedLineItemsMap(){
        //map to store VAT% with line item
        Map<Decimal, List<Price_Quote_Line_Item__c>> groupedLineItemsMap = new Map<Decimal, List<Price_Quote_Line_Item__c>>();
        List<VatEntryWrapper> vatEntryWrappers = new List<VatEntryWrapper>();
        List<Price_Quote_Line_Item__c> lineItems = [Select Material_Name__r.name, Material_Name__r.Low_Res_Image__c, Material_Name__r.Hi_Res_Image__c,
                        Material_Name__r.Brand_Name__c, Description__c, Material_Name__r.Qty_Sales_Unit__c, Name,
                        Material_Name__r.Sales_Unit__c, Quantity__c, Sales_Price__c, Extended_Price__c,
                        IsBold__c, Material_Name__r.List_Price__c, Row_Order__c, Product_Description__c,
                        Material_Name__r.Cardiac_Complimentary__c, Eligible_Price__c, Sales_Unit_Qty__c,
                        Sales_Deal__r.Owner_Name__c, Sales_Deal__r.GPO_Contract_Ref__c, Sales_Deal_Tier__c,
                        Do_Not_Show_Zero_Pricing__c, Material_Name__r.Sales_Org__c, Price_per_each__c, Total_Price_Per_Each__c,
                        Line_Price__c, VAT__c, Material_Description__c, Total__c, VAT_Amount__c
                        FROM Price_Quote_Line_Item__c
                        WHERE Price_Quote__c = :ApexPages.currentPage().getParameters().get('id')];

        //loop through lineitems to create a map using VAT% as the key
        for (Price_Quote_Line_Item__c lineItem : lineItems) {
            Decimal vatPercentage;
            //VAT% can be null so adding a check to avoid NULL POINTER EXCEPTION ERROR
            if(lineItem.VAT__c != NULL){
                vatPercentage = lineItem.VAT__c; 
            }
            
            //check for VAT if already exist in map
            if (groupedLineItemsMap.containsKey(vatPercentage)) {
                groupedLineItemsMap.get(vatPercentage).add(lineItem);
            } else {
                List<Price_Quote_Line_Item__c> newList = new List<Price_Quote_Line_Item__c>();
                newList.add(lineItem);
                groupedLineItemsMap.put(vatPercentage, newList);
            }
        }
    
        if(lineItems.size()>0){
            calculateVatTotal = getCalculateVatTotal(lineItems);
            totalWithoutTradeins = getTotalWithoutTradeins(lineItems);
        }//end if for lineitem check

        //loop totals the value fields to aggregate data on the quote template
        for (Decimal key : groupedLineItemsMap.keySet()) {
            VatEntryWrapper wrapper = new VatEntryWrapper();
            wrapper.vatPercentage = key;
            wrapper.lineItems = groupedLineItemsMap.get(key);
            Decimal total = 0;
            Decimal vatAmount = 0;
            Decimal subTotal = 0;
            for (Price_Quote_Line_Item__c lineItem : wrapper.lineItems) {
                total += lineItem.Total__c;
                vatAmount += lineItem.VAT_Amount__c;
                subTotal += lineItem.Line_Price__c;
            }
            wrapper.total = total;
            wrapper.vatAmount = vatAmount;
            wrapper.subTotal = subTotal;
            vatEntryWrappers.add(wrapper);
        }//end for loop
    
        return vatEntryWrappers;
    }//end of getPriceQuoteLineItems

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
    
    //method calculates total without tradeins for ANES/EMS
    public decimal getTotalWithoutTradeins(List<Price_Quote_Line_Item__c> lineItems){
        totalWithoutTradeins = 0;
        system.debug('****lineItems.size()**** ' + lineItems);
        for (Price_Quote_Line_Item__c curr : lineItems) {
            //skip negative values
            if(curr.Total__c > 0){
                totalWithoutTradeins += curr.Total__c;
            }//end if
        }
        system.debug('****totalWithoutTradeins**** ' + totalWithoutTradeins);
        return totalWithoutTradeins;
    }//end of getPriceQuoteLineItems

}