/*********************************************************************
* Description      : Controller Class for Pricing Portal Header Menu.
* Test Class       : PP_Menu
* VisualForce      : PP_Menu
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
global with sharing class PP_Menu {
	//Trying to solve too many SOQL
	public static Contract_User__c cUserTemp;
    static{
        cUserTemp = [SELECT Id,Name,Active_Currency__c,Active_Price_Quote__c,Active_Quote__c,Active_Region__c,Active_Sales_Org_Key__c,
                     Active_Sales_Org__c, AT_Material__c,AU_Material__c,BE_Material__c,BR_Material__c,Business_Unit__c,CA_Material__c,
                     CH_Material__c,CL_Material__c,CO_Material__c,Create_Quotes__c,CurrencyIsoCode,Currency_Preference__c,
                     CZ_Material__c,DE_Material__c,ES_Material__c,FR_Material__c,GR_Material__c, User__r.UserRole.Name,
                     IE_Material__c,IT_Material__c,LA_Material__c,MX_Material__c,NL_Material__c,NZ_Material__c,OwnerId,PL_Material__c,
                     Pricing_Portal_Access__c,Pricing_Tier_Access__c,PT_Material__c,SA_Material__c,SK_Material__c,
                     Stationary_Preference__c,UK_Material__c,Update_Type__c,Users_Email__c,User_Active__c,User_Administration__c,
                     User_ID__c,User__c,US_Material__c,View_Margin__c
                     FROM Contract_User__c
                     WHERE User__c = :UserInfo.getUserId()
                     LIMIT 1];
    }
    public string searchStr {get; set;}
    public string srch {get {
        return ApexPages.currentPage().getParameters().get('srch');
    } set;}

    public boolean checksrch {get {
        if(ApexPages.currentPage().getParameters().get('srch') != NULL){
            return TRUE;
        }
        else{
            return FALSE;
        }
    } set;}

    global static string salesOrg {get; set;}
    global static string salesOrgKey {get; set;}
    global static string salesCurrency {get; set;}
    global static string salesPrefix {get; set;}
    global static Contract_User__c supercu {get; set;}
    public String iframeSource { get; set; }
    public boolean adminAccess {get; set;}
    public boolean marginAccess {get; set;}
    public List<SelectOption> salesOrgList;

    //new variables
    public List<SelectOption> checkboxOptions;
    public Map<String,Sales_Orgs__c> salesOrgMap;
    //get user language
    public String userLang{get{
        return UserInfo.getLanguage();
    }set;}
    //get user's active Pricing Portal User record
    global Contract_User__c cUser {get{
        try{
            /*cUser = [SELECT Id,Name,Active_Currency__c,Active_Price_Quote__c,Active_Quote__c,Active_Region__c,Active_Sales_Org_Key__c,
                     Active_Sales_Org__c, AT_Material__c,AU_Material__c,BE_Material__c,BR_Material__c,Business_Unit__c,CA_Material__c,
                     CH_Material__c,CL_Material__c,CO_Material__c,Create_Quotes__c,CurrencyIsoCode,Currency_Preference__c,
                     CZ_Material__c,DE_Material__c,ES_Material__c,FR_Material__c,GR_Material__c, User__r.UserRole.Name,
                     IE_Material__c,IT_Material__c,LA_Material__c,MX_Material__c,NL_Material__c,NZ_Material__c,OwnerId,PL_Material__c,
                     Pricing_Portal_Access__c,Pricing_Tier_Access__c,PT_Material__c,SA_Material__c,SK_Material__c,
                     Stationary_Preference__c,UK_Material__c,Update_Type__c,Users_Email__c,User_Active__c,User_Administration__c,
                     User_ID__c,User__c,US_Material__c,View_Margin__c
                     FROM Contract_User__c
                     WHERE User__c = :UserInfo.getUserId()
                     LIMIT 1];
			
            return cUser; */
            return cUserTemp;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }

    }
        set;
    }
    
    //get active user's list of recent PQs
    public List<Price_Quote__c> getQuoteList(){
        try {
            return [SELECT Price_Quote_Name__c, Price_Quote_Name_Alt__c, Sales_Org_Key__c
                    FROM Price_Quote__c
                    WHERE LastViewedDate != NULL
                    AND Sales_Org_Key__c =: cUser.Active_Sales_Org_Key__c
                    ORDER BY LastViewedDate DESC limit 10];
        }
        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }
    
    //get active user's list of recent PRFs
    public List<PRF__c> getPRFList(){
        try {
            return [SELECT PRF_Name__c, PRF_Name_ALT__c, Sales_Org_Key__c
                    FROM PRF__c
                    WHERE LastViewedDate != NULL
                    AND Sales_Org_Key__c =: cUser.Active_Sales_Org_Key__c
                    ORDER BY LastViewedDate DESC limit 10];
        }
        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }

    //get active user's list of recent Sample Requests
	public List<Sample_Request__c> getSampleRequestList(){
        try {
            return [SELECT Name, Type__c, Territory_Number__c, Status__c, Sales_Org_Key__c
                    FROM Sample_Request__c
                    WHERE LastViewedDate != NULL
                    AND Sales_Org_Key__c =: cUser.Active_Sales_Org_Key__c
                    ORDER BY LastViewedDate DESC limit 10];
        }
        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }
    
    //get active user's active quote
    public Price_Quote__c getActiveQuote(){
        try {
            return [SELECT Id, Price_Quote_Name__c, Price_Quote_Name_Alt__c
                    FROM Price_Quote__c
                    WHERE LastViewedDate != NULL
                    AND Sales_Org_Key__c =: cUser.Active_Sales_Org_Key__c
                    ORDER BY LastViewedDate DESC limit 1];
        }
        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }
    
    public List<ProcessInstanceWorkitem> numberOfApprovals{get;set;}
    public PP_Menu() {
        /*
        salesOrgMap = new Map<String,Sales_Orgs__c>();
        
        for( Sales_Orgs__c curr: [SELECT Id, Name, Active_Region__c,Active__c,CurrencyIsoCode,
                    Distribution_Channel__c, Pricing_Type__c, Sales_Org__c, Material_Region__c
                    FROM Sales_Orgs__c] ){
            salesOrgMap.put(curr.Material_Region__c,curr);
        }//end for loop
        */
        // Used to set Security based on the Pricing Portal User record
        iframeSource = '/apex/PP_Update_Sales_Org';
        System.debug('*** cUser *** ' + cUser);
		
        adminAccess = cUser.User_Administration__c;
        marginAccess = cUser.View_Margin__c;

        salesOrg = cUser.Active_Region__c;
        salesPrefix = cUser.Active_Region__c.left(2);
        String userRoleName = cuser.User__r.UserRole.Name;
        
        /*
        checkboxOptions = new List<SelectOption>();
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.Contract_User__c.fields.getMap();
        
        for (String fieldName : fields.keySet() ){
            if (fields.get(fieldName).getDescribe().getType() == Schema.DisplayType.Boolean && fieldName.containsIgnoreCase('Material')) {
                system.debug('*** fieldName *** ' + fieldName);
                system.debug('*** fields.get(fieldName).getDescribe().getType() *** ' + fields.get(fieldName).getDescribe().getType());
                system.debug('*** salesOrgMap.get(fieldName).Active_Region__c *** ' + salesOrgMap.get(fieldName).Active_Region__c);
                // Get the value of the checkbox field on the current Contract_User record
                Boolean fieldValue = (Boolean)cUser.get(fieldName);
                system.debug('*** fieldValue *** ' + fieldValue);
                // Check if the checkbox value is true and add it to the selectOption list
                if (fieldValue) {
                    checkboxOptions.add(new SelectOption(salesOrgMap.get(fieldName).Active_Region__c, salesOrgMap.get(fieldName).Active_Region__c));
                }
            }//end if
        }//end for loop
		*/                
		numberOfApprovals = [SELECT Id FROM ProcessInstanceWorkitem WHERE ActorId =:UserInfo.getUserId() OR OriginalActorId =: UserInfo.getUserId()];
    }// PP_Menu()
    
    /*
    public List<SelectOption> getSOMap(){
        system.debug('*** In getSOMap ***');
        checkboxOptions = new List<SelectOption>();
        salesOrgMap = new Map<String,Sales_Orgs__c>();
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.Contract_User__c.fields.getMap();
        
        for (String fieldName : fields.keySet() ){
            if (fields.get(fieldName).getDescribe().getType() == Schema.DisplayType.Boolean && fieldName.containsIgnoreCase('Material')) {
                system.debug('*** fieldName *** ' + fieldName);
                system.debug('*** fields.get(fieldName).getDescribe().getType() *** ' + fields.get(fieldName).getDescribe().getType());
                system.debug('*** salesOrgMap.get(fieldName).Active_Region__c *** ' + salesOrgMap.get(fieldName).Active_Region__c);
                // Get the value of the checkbox field on the current Contract_User record
                Boolean fieldValue = (Boolean)cUser.get(fieldName);
                
                // Check if the checkbox value is true and add it to the selectOption list
                if (fieldValue) {
                    checkboxOptions.add(new SelectOption(salesOrgMap.get(fieldName).Active_Region__c, salesOrgMap.get(fieldName).Active_Region__c));
                }
            }//end if
        }//end for loop
        
        return checkBoxOptions;
    }//end of getSalesOrgMap
    */
    
    //get Sales Org dropdown list
    public List<SelectOption> getSOlist() {
        system.debug('*** In getSOlist ***');
        salesOrgList = new list<SelectOption>();
		
        if(cUser.US_Material__c == TRUE){
            salesOrgList.add(new SelectOption('US - Teleflex','US - Teleflex'));
        }
        
        if(cUser.CA_Material__c == TRUE){
            salesOrgList.add(new SelectOption('CA - Canada','CA - Canada'));
        }
        
        if(cUser.LA_Material__c == TRUE){
            salesOrgList.add(new SelectOption('LA - Latin America','LA - Latin America'));
        }
        
        if(cUser.MX_Material__c == TRUE){
            salesOrgList.add(new SelectOption('MX - Mexico','MX - Mexico'));
        }
        
        if(cUser.CL_Material__c == TRUE){
            salesOrgList.add(new SelectOption('CL - Chile','CL - Chile'));
        }
        
        if(cUser.CO_Material__c == TRUE){
            salesOrgList.add(new SelectOption('CO - Colombia','CO - Colombia'));
        }
        
        if(cUser.AU_Material__c == TRUE){
            salesOrgList.add(new SelectOption('AU - Australia','AU - Australia'));
        }
        
        if(cUser.NZ_Material__c == TRUE){
            salesOrgList.add(new SelectOption('NZ - New Zealand','NZ - New Zealand'));
        }
        
        if(cUser.BR_Material__c == TRUE){
            salesOrgList.add(new SelectOption('BR - Brazil','BR - Brazil'));
        }

        if(cUser.DE_Material__c == TRUE){
            salesOrgList.add(new SelectOption('DE - Germany','DE - Germany'));
        }

        if(cUser.UK_Material__c == TRUE){
            salesOrgList.add(new SelectOption('UK - United Kingdom','UK - United Kingdom'));
        }
        
        if(cUser.AT_Material__c  == TRUE){
            salesOrgList.add(new SelectOption('AT - Austria','AT - Austria'));
        }
        
        if(cUser.BE_Material__c == TRUE){
            salesOrgList.add(new SelectOption('BE - Belgium','BE - Belgium'));
        }
        
        if(cUser.CH_Material__c == TRUE){
            salesOrgList.add(new SelectOption('CH - Switzerland','CH - Switzerland'));
        }
        
        if(cUser.CZ_Material__c == TRUE){
            salesOrgList.add(new SelectOption('CZ - Czech','CZ - Czech'));
        }
        
        if(cUser.ES_Material__c == TRUE){
            salesOrgList.add(new SelectOption('ES - Spain','ES - Spain'));
        }
        
        if(cUser.FR_Material__c == TRUE){
            salesOrgList.add(new SelectOption('FR - France','FR - France'));
        }
        
        if(cUser.GR_Material__c == TRUE){
            salesOrgList.add(new SelectOption('GR - Greece','GR - Greece'));
        }
        
        if(cUser.IT_Material__c == TRUE){
            salesOrgList.add(new SelectOption('IT - Italy','IT - Italy'));
        }
        
        if(cUser.NL_Material__c == TRUE){
            salesOrgList.add(new SelectOption('NL - Netherlands','NL - Netherlands'));
        }
        
        if(cUser.PL_Material__c == TRUE){
            salesOrgList.add(new SelectOption('PL - Poland','PL - Poland'));
        }
        
        if(cUser.SK_Material__c == TRUE){
            salesOrgList.add(new SelectOption('SK - Slovakia','SK - Slovakia'));
        }
        
        if(cUser.PT_Material__c == TRUE){
            salesOrgList.add(new SelectOption('PT - Portugal','PT - Portugal'));
        }
        
        if(cUser.IE_Material__c == TRUE){
            salesOrgList.add(new SelectOption('IE - Ireland','IE - Ireland'));
        }
        
        if(cUser.SA_Material__c == TRUE){
            salesOrgList.add(new SelectOption('SA - South Africa','SA - South Africa'));
        }
        system.debug('salesOrgList: ' + salesOrgList);

        return salesOrgList;
    }
    
    //used to toggle global search input
    public boolean gs {
        get {
            if(ApexPages.currentPage().getParameters().get('gs') == 'off'){
                return FALSE;
            }
            else{
                return TRUE;
            }
        }
        set; }

    public List<GPO_PickList__c> getgpodropdown() {
        try{
            return [SELECT Key__c, Name, Active__c FROM GPO_PickList__c WHERE Active__c = TRUE AND Sales_Org_Key__c = :salesPrefix ORDER BY Name];
        }
        catch (Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }
    
    public List<IDN_PickList__c> getidndropdown() {
        try{
            return [SELECT Key__c, Name, Active__c FROM IDN_PickList__c WHERE Active__c = TRUE AND Sales_Org_Key__c = :salesPrefix ORDER BY Name];
        }
        catch (Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }
    
    public pagereference getURL(){
            PageReference globalSearch = New Pagereference('/apex/PP_Global_Search?srch=' + searchStr);
            globalSearch.setRedirect(true);
            return globalSearch;
    }
    
    // This is what updates the 'Active Sales Org'
    public PageReference reloadIframe() {
        
        if(salesOrg.left(2) == 'US'){
            salesCurrency = 'USD';
            salesOrgKey = 'US6010';
        }
        else if(salesOrg.left(2) == 'CA'){
            salesCurrency = 'CAD';
            salesOrgKey = 'CA1010';
        }
        else if(salesOrg.left(2) == 'LA'){
            salesCurrency = 'USD';
            salesOrgKey = 'US6020';
        }
        else if(salesOrg.left(2) == 'MX'){
            salesCurrency = 'MXN';
            salesOrgKey = 'MX4010';
        }
        else if(salesOrg.left(2) == 'CL'){
            salesCurrency = 'CLP';
            salesOrgKey = 'CL1010';
        }
        else if(salesOrg.left(2) == 'CO'){
            salesCurrency = 'COP';
            salesOrgKey = 'CO1010';
        }
        else if(salesOrg.left(2) == 'AU'){
            salesCurrency = 'AUD';
            salesOrgKey = 'AU1010';
        }
        else if(salesOrg.left(2) == 'NZ'){
            salesCurrency = 'NZD';
            salesOrgKey = 'NZ1010';
        }
        else if(salesOrg.left(2) == 'BR'){
            salesCurrency = 'BRL';
            salesOrgKey = 'BR1010';
        }
        else if(salesOrg.left(2) == 'DE'){
            salesCurrency = 'EUR';
            salesOrgKey = 'DE1010';
        }
        else if(salesOrg.left(2) == 'UK'){
            salesCurrency = 'GBP';
            salesOrgKey = 'UK1010';
        }
        else if(salesOrg.left(2) == 'AT'){
            salesCurrency = 'EUR';
            salesOrgKey = 'AT1010';
        }
        else if(salesOrg.left(2) == 'BE'){
            salesCurrency = 'EUR';
            salesOrgKey = 'BE1010';
        }
        else if(salesOrg.left(2) == 'CH'){
            salesCurrency = 'EUR';
            salesOrgKey = 'CH1010';
        }
        else if(salesOrg.left(2) == 'CZ'){
            salesCurrency = 'EUR';
            salesOrgKey = 'CZ1010';
        }
        else if(salesOrg.left(2) == 'ES'){
            salesCurrency = 'EUR';
            salesOrgKey = 'ES1010';
        }
        else if(salesOrg.left(2) == 'FR'){
            salesCurrency = 'EUR';
            salesOrgKey = 'FR1010';
        }
        else if(salesOrg.left(2) == 'GR'){
            salesCurrency = 'EUR';
            salesOrgKey = 'GR1010';
        }
        else if(salesOrg.left(2) == 'IT'){
            salesCurrency = 'EUR';
            salesOrgKey = 'IT1020';
        }
        else if(salesOrg.left(2) == 'NL'){
            salesCurrency = 'EUR';
            salesOrgKey = 'NL1010';
        }
        else if(salesOrg.left(2) == 'PL'){
            salesCurrency = 'EUR';
            salesOrgKey = 'PL1010';
        }
        else if(salesOrg.left(2) == 'SK'){
            salesCurrency = 'EUR';
            salesOrgKey = 'SK1010';
        }
        else if(salesOrg.left(2) == 'PT'){
            salesCurrency = 'EUR';
            salesOrgKey = 'PT1010';
        }
        else if(salesOrg.left(2) == 'IE'){
            salesCurrency = 'EUR';
            salesOrgKey = 'IE2010';
        }
        else if(salesOrg.left(2) == 'SA'){
            salesCurrency = 'EUR';
            salesOrgKey = 'SA1010';
        }
        else{
            salesOrgKey = 'US6010';
            salesCurrency = 'USD';
        }

        Contract_User__c updateCC = new Contract_User__c(
            Id = cUser.Id,
            Active_Region__c = salesOrg,
            Active_Currency__c = salesCurrency,
            Active_Sales_Org_Key__c = salesOrgKey,
            Update_Type__c = 'updateSO'
        );
        try {
            update updateCC;
        }
        catch(DmlException e){
            system.debug('Exception: ' + e);
        }
        system.debug('updateCC: ' + updateCC);
        //}
        PageReference refreshPage = new Pagereference('/apex/PP_GPO_Matrix').setRedirect(true);
        return refreshPage;
        //return null;
    }

    //method to get available languages for Pricing Portal
    public List<selectoption> getAvailableLanguages(){
        
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('en_US','English'));
        options.add(new selectOption('de','German'));
        options.add(new selectOption('es','Spanish'));
        options.add(new selectOption('fr','French'));
        options.add(new selectOption('it','Italian'));
        
        options.add(new selectOption('ja','Japanese'));
        options.add(new selectOption('sv','Swedish'));
        options.add(new selectOption('ko','Korean'));
        options.add(new selectOption('zh_TW','Chinese (Traditional)'));
        options.add(new selectOption('zh_CN','Chinese (Simplified)'));
        options.add(new selectOption('pt_BR','Portuguese (Brazil)'));
        
        options.add(new selectOption('nl_NL','Dutch'));
        options.add(new selectOption('da','Danish'));
        options.add(new selectOption('th','Thai'));
        options.add(new selectOption('fi','Finnish'));
        options.add(new selectOption('fr','French'));
        options.add(new selectOption('ru','Russian'));
        
        options.add(new selectOption('es_MX','Spanish (Mexico)'));
        options.add(new selectOption('no','Norwegian'));
        options.add(new selectOption('pl','Polish'));
        options.add(new selectOption('cs','Czech'));
        options.add(new selectOption('tr','Turkish'));
        options.add(new selectOption('in','Indonesian'));
        
        options.add(new selectOption('uk','Ukrainian'));
        options.add(new selectOption('iw','Hebrew'));
        options.add(new selectOption('el','Greek'));
        options.add(new selectOption('en_GB','English (UK)'));
        options.add(new selectOption('ar','Arabic'));
        options.add(new selectOption('in','Indonesian'));
        
        return options;
    }
    //end language selection
}