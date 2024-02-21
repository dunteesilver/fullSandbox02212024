/*********************************************************************
* Description      : Controller Class for Pricing Portal GPO Matrix.
* Test Class       : PP_GPO_Matrix_Test
* VisualForce      : PP_GPO_Matrix
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
public with sharing class PP_GPO_Matrix {

    //cUser holds user's pricing portal access data
    public string salesOrgPrefix;
    Public Boolean emeaUserFlag {get; set;}
    
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
    
    public Contract_User__c cUser{
        get{
            try{
                return cUserTemp;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                return null;
            }
        }
        set;
    }

    //fethces GPO Accounts for EMEA Region
    Public Integer size{get;set;}
    Public Integer noOfRecords{get; set;}
    //Public String rowIndex;
    public List<SelectOption> paginationSizeOptions{get;set;}

    //start of constructor
    public PP_GPO_Matrix(){
        //rowIndex = ApexPages.currentPage().getParameters().get('rowIndex');
        size=10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));

        salesOrgPrefix = cUser.Active_Sales_Org_Key__c.left(2);
        Sales_Orgs__c  srkey = Sales_Orgs__c.getInstance(cUser.Active_Sales_Org_Key__c);
        emeaUserFlag = false;
        if(srkey?.Region__c !='' && srkey?.Region__c =='EMEA'){
            emeaUserFlag = true;

        }else{
            emeaUserFlag = false;
        }
        
        
    }//end constructor

    //get paginated record list
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, Name, Sap_Sold_To__c, Account_Name_2__c
                    FROM Account 
                    WHERE ERP_Active__c = TRUE 
                    AND Sales_Org_Key__c = :cUser.Active_Sales_Org_Key__c
                    AND Sap_Sold_To__c LIKE :(salesOrgPrefix + '%')
                    ORDER BY Name]));
                setCon.setPageSize(size);  
                noOfRecords = setCon.getResultSize();
            }            
            return setCon;
        }
        set;
    }

    //Changes the size of pagination
    public PageReference refreshPageSize() {
        try{
            setCon.setPageSize(size);
            return null;
        }
        catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'Error detected: ' + e));
            return null;
        }
    }

    //get paginated records
    public List<Account> getEmeaGpos(){
        return (List<Account>)setCon.getRecords();
    }//end getEmeaGpos

    public boolean oid(){
        boolean oid;
        if(ApexPages.currentPage().getParameters().get('oid') != NULL){
            oid = true;
        }
        else{
            oid = false;
        }
        return oid;
    }
    public String ownerName {
        get {
            String owner_name = '';
            try{
                if(ApexPages.currentPage().getParameters().get('oid') != NULL){
                    owner_name = [Select Owner_Name__c FROM Contract_Header__c WHERE Owner__c = :ApexPages.currentPage().getParameters().get('oid') AND GPO_Contract_Ref__c <> NULL AND Active__c = TRUE LIMIT 1].Owner_Name__c;
                }
                return owner_name;
            }
            catch(Exception e){
                system.debug('Exception: ' + e);
                return NULL;
            }

        }
        set; }

    public String ownerID {
        get {
            string owner_id;
            if(ApexPages.currentPage().getParameters().get('oid') != NULL){
                owner_id = ApexPages.currentPage().getParameters().get('oid');
            }
            return owner_id;
        }
        set; }


    public integer td1 {get; set;}
    public string td2 {get; set;}
    public string td3 {get; set;}
    public string cd {get; set;}
    public map<String, String> htmlMap {get; set;}
    public map<String, String> Tiers;


    public list<Contract_Header__c> getCheckCH(){
        try{
            return [Select Id, Name, Owner_Name__c, Owner__c
                    FROM Contract_Header__c
                    WHERE Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                    AND GPO_Contract_Ref__c <> NULL
                    AND Active__c <> FALSE
                    LIMIT 1];
        }
        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }


    public List<GPO_PickList__c> getItems() {
        try{
            return [SELECT Key__c, Name, Active__c FROM GPO_PickList__c WHERE Active__c = TRUE AND Sales_Org_Key__c = :salesOrgPrefix ORDER BY Name];

        }
        catch (Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }

    public map<String, String> getTiers(){
        td1 = null;
        td2 = null;

        // Group the Contract Tiers by the GPO reference
        map<String, String> htmlMap = new map<String, String>();
        for(Contract_Header__c c : [Select GPO_Contract_Ref__c, Owner__c, Description__c, Contract_Detail__c, Valid_From__c, Valid_To__c
                                    FROM Contract_Header__c
                                    WHERE Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                                    AND GPO_Contract_Ref__c != NULL
                                    AND Active__c = TRUE
                                    ORDER BY GPO_Contract_Ref__c, Description__c ASC])
        {
            //system.debug('GPO Reference: ' + c.GPO_Contract_Ref__c + ' Description: ' + c.Description__c);
            if(c.Contract_Detail__c == NULL){
                cd = '';
            }
            else {
                cd = c.Contract_Detail__c;
            }

            if(!htmlMap.containsKey(c.GPO_Contract_Ref__c)){
                td1 = 1;
                td2 = '<td class="col-md-3">' + c.Description__c + '</td><td class="col-md-3">' + cd + '</td><td class="col-md-1">' + c.Valid_From__c.format() + '</td><td class="col-md-1">' + c.Valid_To__c.format() + '</td></tr>';
            }
            else {
                ++td1;
                td2 = td2 + '<tr><td>' + c.Description__c + '</td><td>' + cd + '</td><td>' + c.Valid_From__c.format() + '</td><td>' + c.Valid_To__c.format() + '</td></tr>';
            }
            td3 = '<tr><td rowspan=' + td1 + ' class="col-md-1"><h4><a href="/apex/PP_Contract_Detail?oid=' + c.Owner__c+'&gporef=' + c.GPO_Contract_Ref__c + '">' + c.GPO_Contract_Ref__c + '</a></h4></td>' + td2;
            htmlMap.put(c.GPO_Contract_Ref__c, td3);
        }
        try{
            return htmlMap;
        }

        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }//end getTiers

    //method to redirect page back to current page
    public PageReference backToGpoMatrix(){
        return null;
        //return new Pagereference('/apex/PP_GPO_Matrix?oid=' + ApexPages.currentPage().getParameters().get('oid') ).setRedirect(True);
    }

    //Everything below is for EMEA Pricing Portal Users (GPOs/IDNs)
    public list<Contract_Header__c> getCheckChEmea(){
        try{
            return [Select Id, Name, Owner_Name__c, Owner__c
                    FROM Contract_Header__c
                    WHERE Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                    AND Active__c <> FALSE
                    LIMIT 1];
        }
        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }
    
    //get tiers EMEA
    public map<String, String> getTiersEmea(){
        td1 = null;
        td2 = null;

        // Group the Contract Tiers by the GPO reference
        map<String, String> htmlMap = new map<String, String>();
        for(Contract_Header__c c : [Select Name, GPO_Contract_Ref__c, Owner__c, Description__c, Contract_Detail__c, Valid_From__c, Valid_To__c
                                    FROM Contract_Header__c
                                    WHERE Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                                    AND Active__c = TRUE
                                    ORDER BY GPO_Contract_Ref__c, Description__c ASC])
        {
            //system.debug('GPO Reference: ' + c.GPO_Contract_Ref__c + ' Description: ' + c.Description__c);
            if(c.Contract_Detail__c == NULL){
                cd = '';
            }
            else {
                cd = c.Contract_Detail__c;
            }

            if(!htmlMap.containsKey(c.Owner__c)){
                td1 = 1;
                td2 = '<td class="col-md-3"><a href="/apex/PP_Agreement_Detail?aid=' + c.Name + '">' + c.Name + ' - ' + c.Description__c + '</a></td><td class="col-md-3">' + cd + '</td><td class="col-md-1">' + c.Valid_From__c.format() + '</td><td class="col-md-1">' + c.Valid_To__c.format() + '</td></tr>';
            }
            else {
                ++td1;
                td2 = td2 + '<tr><td><a href="/apex/PP_Agreement_Detail?aid=' + c.Name + '">' + c.Name + ' - ' + c.Description__c + '</a></td><td>' + cd + '</td><td>' + c.Valid_From__c.format() + '</td><td>' + c.Valid_To__c.format() + '</td></tr>';
            }
            td3 = '<tr><td rowspan=' + td1 + ' class="col-md-1"><h4><a href="/apex/PP_Contract_Detail?oid=' + c.Owner__c+'&gporef=' + '' + '">' + c.Owner__c + '</a></h4></td>' + td2;
            htmlMap.put(c.Owner__c, td3);
        }
        try{
            return htmlMap;
        }

        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }//end getTiersEmea

}//end of PP_GPO_Matrix Class