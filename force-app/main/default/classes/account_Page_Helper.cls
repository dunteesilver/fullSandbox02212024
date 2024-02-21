public without sharing class account_Page_Helper {

    //public map<String, Sales_by_BU__c> buMap;
    //public list<string> buList;
    //public list<Sales_by_BU__c> buSummary;

    private Account acct;

    public String strYTD {get; set;}
    public String strPYTD {get; set;}
    public String graphData {get; set;}
    public String ytdgraphData {get; set;}
    public String bugraphData {get; set;}
    public integer YTD {get; set;}
    public integer PYTD {get; set;}
    public string thisYear {get{
        return String.valueOf(System.Today().year());
    } set;}
    public string lastYear {get{
        return String.valueOf(System.Today().year()-1);
    } set;}

    // New Stuff - 18Jun2017
    Id aid = ApexPages.currentPage().getParameters().get('id');
    public list<Territory_Master__c> ATMlist {get; set;}
    public list<String> tsort {get; set;}

    public map<String, String> tSales {get; set;}
    public map<String, Territory_Master__c> atmMap {get; set;}
    public map<String, String> repMap {get; set;}

    public boolean atmCheck {get; set;}
    // End New

    //public boolean ssbu_check {get; set;} // Drives whether the 'Sales Summary' section is displayed
    //public list<Sales_by_BU__c> SSbu {get; set;} // List that renders the 'Sales Summary'. If the section renders but no lines then it is an object security issue.
    public map<String, Decimal> salesMap {get; set;}
    public map<String, Decimal> smMap {get; set;}
    public map<String, Product2> prodMap {get; set;}
    public map<String, String> prodbuMap {get; set;}
    
    // bu is the users Business Unit defined on the User Record and is used through out the class.
    // Checked/Tested: Doesn't seem to care if Business Unit is not set...page still loads without an error. - ESC 16Jul2016
    string bu = [SELECT Business_Unit__c FROM User WHERE Id=:userinfo.getuserid() LIMIT 1].business_unit__c;
    
    public account_Page_Helper(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
        
        salesMap = new map<String, Decimal>();
        smMap = new map<String, Decimal>();
        prodMap = new map<String, Product2>();
        prodbuMap = new map<String, String>();
        ATMlist = new list<Territory_Master__c>();
        tsort = new list<String>();
        atmMap = new map<String, Territory_Master__c>();
        repMap = new map<String, String>();
        
        // New Stuff - 18Jun2017 ESC
        tSales = new map<String, String>();
        atmCheck = false;
        
        Account a = [SELECT Territory_Key__c FROM Account WHERE Id =:aid LIMIT 1];
        string poiList;
        string poi;

        if(a.Territory_Key__c != NULL){
            poiList = a.Territory_Key__c;
            List<String> sortedvalue = poiList.split(';');
            sortedvalue.sort();
            for(string s : sortedvalue){
                tSales.put(s, '$');
            } 
        }
        
        // New ATMlist
        set<String> tset = new set<String>();
        for(Territory_Assignment__c ta : [SELECT Territory_Number__c 
                                          FROM Territory_Assignment__c
                                          WHERE Account__c =: aid 
                                          AND Territory_Alignment__r.Active__c = TRUE 
                                          ORDER BY Business_Unit__c])
        {
            tset.add(ta.Territory_Number__c);
        }
        
      //Check standard account team memebers and add thier territories to tset
        Set<Id> accountTeamUsersSet = new Set<Id>();
        for(AccountTeamMember atm: [SELECT UserId 
                                          FROM AccountTeamMember
                                          WHERE AccountId =: aid])
        {
            accountTeamUsersSet.add(atm.UserId);
        }
        if(!accountTeamUsersSet.isEmpty()){
            for(Territory_Master__c tmByUser :[SELECT Id, Territory_Number__c
                                     FROM Territory_Master__c 
                                     WHERE Primary_Territory_User__c IN:accountTeamUsersSet OR Sales_Rep__c IN:accountTeamUsersSet])
            {
                 tset.add(tmByUser.Territory_Number__c);
            }
        }

        for(Territory_Master__c tm :[SELECT Id, Name, Role__c, Business_Unit__c, Primary_Territory_User__r.Name, Sales_Rep__r.Name,
                                     Territory_Number__c
                                     FROM Territory_Master__c 
                                     WHERE Territory_Number__c =:tset
                                     ORDER BY Business_Unit__c, Role__c DESC])
        {
            atmCheck = true;
            tsort.add(tm.Territory_Number__c);
            atmMap.put(tm.Territory_Number__c, tm);
            if(tm.Sales_Rep__r.Name != NULL){
                repMap.put(tm.Territory_Number__c, tm.Sales_Rep__r.Name);
            }
            else if(tm.Primary_Territory_User__r.Name != NULL){
                repMap.put(tm.Territory_Number__c, tm.Primary_Territory_User__r.Name);
            }
            else{
                repMap.put(tm.Territory_Number__c, 'Open');
            }
            if(!tSales.containsKey(tm.Territory_Number__c)){
                tSales.put(tm.Territory_Number__c, '-');
            }
        }
        // End new ATM

        //integer salesCheck= database.countQuery('SELECT count() FROM Sales_by_Product__c LIMIT 1');
        //if(salesCheck > 0){
            string material;
            string bumap;

        for(AggregateResult ar : [SELECT Business_Unit__c, Material_Key__c 
                                      FROM Invoiced_Sales__c  
                                      WHERE Account__c = :acct.Id  
                                      Group By Business_Unit__c, Material_Key__c ])
            {
                
                material = (string) ar.get('Material_Key__c');
                bumap = (string) ar.get('Business_Unit__c');
                prodbuMap.put(material, bumap);
            }
            
        //}
        
    }
    
    
    public PageReference shareAccount(){
        System.debug('Sharing account with Sales reps');
        Set<Id> repsWithSales = new Set<Id>();
        for(AggregateResult ar:[SELECT ownerId From Invoiced_sales__c WHERE Account__c = :acct.Id Group By ownerId]){
            Id salesRepId = (Id)ar.get('ownerId');
            repsWithSales.add(salesRepId);
        }
        
        Map<Id, AccountShare> shareRecsMap = new Map<Id, AccountShare>();
        for(AccountShare ac:[SELECT UserOrGroupId, AccountId, AccountAccessLevel 
                             FROM AccountShare
                             WHERE AccountId = :acct.Id AND UserOrGroupId IN:repsWithSales]){
                                 shareRecsMap.put(ac.UserOrGroupId, ac);
                             }
        Set<Id> accTeamMemIds = new Set<Id>();
        for(AccountTeamMember tm:[SELECT UserId, AccountId
                                  FROM AccountTeamMember 
                                  WHERE AccountId = :acct.Id AND UserId IN:repsWithSales]){
                                      accTeamMemIds.add(tm.UserId);
                                  }
        
        List<AccountShare> shareRecsToInsert = new List<AccountShare>();
        List<AccountTeamMember> accTeamMemRecs = new List<AccountTeamMember>();
        for(Id salesRepId : repsWithSales){
            if(accTeamMemIds != null && accTeamMemIds.size()>0 && !accTeamMemIds.contains(salesRepId)){
                AccountTeamMember addATM = new AccountTeamMember(
                    AccountId = acct.Id,
                    TeamMemberRole = 'Sales Rep',
                    UserId = salesRepId
                );
                accTeamMemRecs.add(addATM);
            }
            System.debug('Existing Share Record:-'+shareRecsMap.values());
            if(shareRecsMap != null && shareRecsMap.keySet().size()>0 && ((!shareRecsMap.keySet().contains(salesRepId)) || shareRecsMap.get(salesRepId).AccountAccessLevel == 'Read')){
                AccountShare addAS = new AccountShare(
                    AccountId = acct.Id,
                    OpportunityAccessLevel = 'None',
                    CaseAccessLevel = 'None',
                    AccountAccessLevel = 'Edit',
                    UserOrGroupId = salesRepId
                );
                shareRecsToInsert.add(addAS);
            }
        }
        if(shareRecsToInsert != null && shareRecsToInsert.size()>0){
            system.debug('shareRecsToInsert:'+shareRecsToInsert);
            insert shareRecsToInsert;
        }
        if(accTeamMemRecs != null && accTeamMemRecs.size()>0){
            system.debug('accTeamMemRecs:'+accTeamMemRecs);
            insert accTeamMemRecs;
        }
        return null;
    }
    
    public string getmyBU(){
        return bu;
    }

    public list<Territory_User__c> getATMlist(){
        system.debug('-- Start Account Team getATMlist --');
        
        set<String> tset = new set<String>();
        set<Id> uIds = new set<Id>();
        for(AccountTeamMember atm : [SELECT UserId 
                                     FROM AccountTeamMember 
                                     WHERE AccountId =: acct.Id ])
        {
            uIds.add(atm.UserId); 
        }
        
        for(Territory_Assignment__c ta : [SELECT Territory_Number__c 
                                          FROM Territory_Assignment__c
                                          WHERE Account__c =: acct.Id])
        {
            tset.add(ta.Territory_Number__c);
        }
        //system.debug('List of User Ids: ' + uIds);
        system.debug('-- END Account Team getATMlist --');
        
        return [SELECT User__c, Territory_Master__r.Role__c, Business_Unit__c, Territory_Master__c    
                FROM Territory_User__c
                WHERE User_Active__c = TRUE 
                AND User__r.Id IN :uIds 
                AND Territory_Master__r.Territory_Number__c IN :tset 
                ORDER BY Business_Unit__c, User_Full_Name__c];
    }

    // New Sales Summary
    public List<String> getTop10() {
        system.debug('-- Start the New Sales Summary - getTop10 --');
        string material;
        decimal sales;
        list<String> mList = new list<String>();
        set<Id> pids = new set<Id>();

        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Material_Key__c, SUM(Sales__c) Sales 
                                  FROM Invoiced_Sales__c  
                                  WHERE Account__c = :acct.Id  
                                  AND Date__c = THIS_YEAR 
                                  Group By CALENDAR_YEAR(Date__c), Material_Key__c 
                                  ORDER BY SUM(Sales__c) DESC NULLS LAST 
                                  LIMIT 10])
        {

            material = (string) ar.get('Material_Key__c');
            sales = (decimal) ar.get('Sales');
            salesMap.put('YTDTOP10'+material, sales);
            mList.add(material);
            //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
        }
        system.debug('mList: ' + mList);
        if(mList.size() > 0){
            for(Product2 p : [SELECT Id, Name, Material_Link__c, SBU__c, 
                              Description, Material_Key__c, CurrencyIsoCode  
                              FROM Product2 
                              WHERE Material_Key__c =:mList])
            {
                prodMap.put(p.Material_Key__c, p);
                pids.add(p.Id);
            }
            //system.debug('prodMap: ' + prodMap);
            for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Material_Key__c, SUM(Sales__c) Sales 
                                      FROM Invoiced_Sales__c  
                                      WHERE Account__c = :acct.Id 
                                      AND Product__c =:pids 
                                      AND Date__c = LAST_YEAR 
                                      Group By CALENDAR_YEAR(Date__c), Material_Key__c 
                                      LIMIT 10])
            {
                
                material = (string) ar.get('Material_Key__c');
                sales = (decimal) ar.get('Sales');
                salesMap.put('PYTDTOP10'+material, sales);
                //system.debug('Sales 2015: ' + salesMap.get('PYTDTOP10'+material));
                //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
            }
            //system.debug('prodMap.keySet(): ' + prodMap.keySet());
            for(string s : mList){
                if(salesMap.get('PYTDTOP10'+s) == NULL){
                    salesMap.put('PYTDTOP10'+s,0);
                }
                if(salesMap.get('YTDTOP10'+s) == NULL){
                    salesMap.put('YTDTOP10'+s,0);
                }
            }
            //system.debug('salesMap: ' + salesMap);
        } // End mList.size > 0 IF/THEN

        system.debug('-- Finish the New Sales Summary - getTop10 --');
        return mList;
        
    }
    
    public List<String> getTop10byBU() {
        system.debug('-- Start the New Sales Summary - getTop10byBU --');
        string material;
        decimal sales;
        list<String> mList = new list<String>();
        set<Id> pids = new set<Id>();
        

        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Material_Key__c, SUM(Sales__c) Sales 
                                  FROM Invoiced_Sales__c  
                                  WHERE Account__c = :acct.Id  
                                  AND Date__c = THIS_YEAR 
                                  AND Business_Unit__c =:bu
                                  Group By CALENDAR_YEAR(Date__c), Material_Key__c 
                                  ORDER BY SUM(Sales__c) DESC NULLS LAST 
                                  LIMIT 10])
        {

            material = (string) ar.get('Material_Key__c');
            sales = (decimal) ar.get('Sales');
            salesMap.put('YTDTOP10BU'+material, sales);
            mList.add(material);
            //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
        }
        system.debug('mList: ' + mList);
        if(mList.size() > 0){
            for(Product2 p : [SELECT Id, Name, Material_Link__c, SBU__c, 
                              Description, Material_Key__c, CurrencyIsoCode  
                              FROM Product2 
                              WHERE Material_Key__c =:mList])
            {
                prodMap.put(p.Material_Key__c, p);
                pids.add(p.Id);
            }
            //system.debug('prodMap: ' + prodMap);
            for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Material_Key__c, SUM(Sales__c) Sales 
                                      FROM Invoiced_Sales__c  
                                      WHERE Account__c = :acct.Id 
                                      AND Product__c =:pids 
                                      AND Date__c = LAST_YEAR 
                                      Group By CALENDAR_YEAR(Date__c), Material_Key__c 
                                      LIMIT 10])
            {
                
                material = (string) ar.get('Material_Key__c');
                sales = (decimal) ar.get('Sales');
                salesMap.put('PYTDTOP10BU'+material, sales);
                //system.debug('Sales 2015: ' + salesMap.get('PYTDTOP10'+material));
                //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
            }
            //system.debug('prodMap.keySet(): ' + prodMap.keySet());
            for(string s : mList){
                if(salesMap.get('PYTDTOP10BU'+s) == NULL){
                    salesMap.put('PYTDTOP10BU'+s,0);
                }
                if(salesMap.get('YTDTOP10BU'+s) == NULL){
                    salesMap.put('YTDTOP10BU'+s,0);
                }
            }
            //system.debug('salesMap: ' + salesMap);
        } // End mList.size > 0 IF/THEN

        system.debug('-- Finish the New Sales Summary - getTop10byBU --');
        return mList;
        
    }
    
    public List<String> getAllProductsbyBU() {
        system.debug('-- Start the New Sales Summary - getAllProductsbyBU --');
        string material;
        decimal sales;
        list<String> mList = new list<String>();
        set<Id> pids = new set<Id>();
        

        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Material_Key__c, SUM(Sales__c) Sales 
                                  FROM Invoiced_Sales__c  
                                  WHERE Account__c = :acct.Id  
                                  AND Date__c = THIS_YEAR 
                                  AND Business_Unit__c =:bu
                                  Group By CALENDAR_YEAR(Date__c), Material_Key__c 
                                  ORDER BY SUM(Sales__c) DESC NULLS LAST])
        {

            material = (string) ar.get('Material_Key__c');
            sales = (decimal) ar.get('Sales');
            salesMap.put('YTDALLbyBU'+material, sales);
            mList.add(material);
            //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
        }
        system.debug('mList: ' + mList);
        if(mList.size() > 0){
            for(Product2 p : [SELECT Id, Name, Material_Link__c, SBU__c, 
                              Description, Material_Key__c, CurrencyIsoCode  
                              FROM Product2 
                              WHERE Material_Key__c =:mList])
            {
                prodMap.put(p.Material_Key__c, p);
                pids.add(p.Id);
            }
            //system.debug('prodMap: ' + prodMap);
            for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Material_Key__c, SUM(Sales__c) Sales 
                                      FROM Invoiced_Sales__c  
                                      WHERE Account__c = :acct.Id 
                                      AND Product__c =:pids 
                                      AND Date__c = LAST_YEAR 
                                      Group By CALENDAR_YEAR(Date__c), Material_Key__c])
            {
                
                material = (string) ar.get('Material_Key__c');
                sales = (decimal) ar.get('Sales');
                salesMap.put('PYTDALLbyBU'+material, sales);
                //system.debug('Sales 2015: ' + salesMap.get('PYTDTOP10'+material));
                //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
            }
            //system.debug('prodMap.keySet(): ' + prodMap.keySet());
            for(string s : mList){
                if(salesMap.get('PYTDALLbyBU'+s) == NULL){
                    salesMap.put('PYTDALLbyBU'+s,0);
                }
                if(salesMap.get('YTDALLbyBU'+s) == NULL){
                    salesMap.put('YTDALLbyBU'+s,0);
                }
            }
            //system.debug('salesMap: ' + salesMap);
        } // End mList.size > 0 IF/THEN

        system.debug('-- Finish the New Sales Summary - getAllProductsbyBU --');
        return mList;
        
    }
    
    public List<String> getAllProducts() {
        system.debug('-- Start the New Sales Summary - getAllProducts --');
        string material;
        decimal sales;
        list<String> mList = new list<String>();
        set<Id> pids = new set<Id>();

        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Material_Key__c, SUM(Sales__c) Sales 
                                  FROM Invoiced_Sales__c  
                                  WHERE Account__c = :acct.Id  
                                  AND Date__c = THIS_YEAR 
                                  Group By CALENDAR_YEAR(Date__c), Material_Key__c 
                                  ORDER BY SUM(Sales__c) DESC NULLS LAST])
        {
            material = (string) ar.get('Material_Key__c');
            sales = (decimal) ar.get('Sales');
            salesMap.put('YTDALL'+material, sales);
            mList.add(material);
            //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
        }
        system.debug('mList: ' + mList);
        if(mList.size() > 0){
            for(Product2 p : [SELECT Id, Name, Material_Link__c, SBU__c, 
                              Description, Material_Key__c, CurrencyIsoCode  
                              FROM Product2 
                              WHERE Material_Key__c =:mList])
            {
                prodMap.put(p.Material_Key__c, p);
                pids.add(p.Id);
            }
            //system.debug('prodMap: ' + prodMap);
            for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Material_Key__c, SUM(Sales__c) Sales 
                                      FROM Invoiced_Sales__c  
                                      WHERE Account__c = :acct.Id 
                                      AND Product__c =:pids 
                                      AND Date__c = LAST_YEAR 
                                      Group By CALENDAR_YEAR(Date__c), Material_Key__c])
            {
                
                material = (string) ar.get('Material_Key__c');
                sales = (decimal) ar.get('Sales');
                salesMap.put('PYTDALL'+material, sales);
                //system.debug('Sales 2015: ' + salesMap.get('PYTDTOP10'+material));
                //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
            }
            //system.debug('prodMap.keySet(): ' + prodMap.keySet());
            for(string s : mList){
                if(salesMap.get('PYTDALL'+s) == NULL){
                    salesMap.put('PYTDALL'+s,0);
                }
                if(salesMap.get('YTDALL'+s) == NULL){
                    salesMap.put('YTDALL'+s,0);
                }
            }
            system.debug('salesMap: ' + salesMap);
        } // End mList.size > 0 IF/THEN

        system.debug('-- Finish the New Sales Summary - getAllProducts --');
        return mList;
        
    }
    
    public List<String> getSalesSummaryByBU() {
        system.debug('-- Starting the New Sales Summary by BU - getAllProductsbyBU --');
        // This Class creates the BU table as well as the data used for the YOY bar graph - ESC 16JUL2016

        date thisYear;
        decimal sales; // Sales
        decimal ytdTotal = 0; // Store Global Sales Current Year 
        decimal pytdTotal = 0; // Store Global Sales Last Year
        string bunit; // Business Unit
        string yearCurrent; // Current Year - String

        list<String> buList = new list<String>(); // Used to store the Business Units - Order Counts so we load Global, Users BU, and then the rest.
        list<String> buListFinal = new list<String>(); 

        set<String> buSet = new set<String>(); // Used to store the Business Unit in the Agreegate Loop - sorted in the SOQL, added to the buList afterwards
        
        // End Variable Setting
        
        // Set the two BU's Global and User's BU. If the users BU is not set...the system does not throw an error.
        buSet.add('Global'); // Add the Global BU which is the 'Total' BU
        buSet.add(bu); // Add the current users 'bu'
        
        // Set the 'This Year' and 'Last Year'
        // This sets the dates and adds them to a set list so that we can ensure we don't have
        // any null values in our data
        
        thisYear = Date.today();
        YTD = thisYear.year();
        PYTD = thisYear.year()-1;
        strYTD = String.valueOf(YTD);
        strPYTD = String.valueOf(PYTD);
        
        
        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Business_Unit__c, SUM(Sales__c) Sales 
                                  FROM Invoiced_Sales__c  
                                  WHERE Account__c = :acct.Id 
                                  Group By CALENDAR_YEAR(Date__c), Business_Unit__c 
                                  ORDER BY Business_Unit__c ASC NULLS LAST])
        {
            bunit = (string) ar.get('Business_Unit__c');
            sales = (decimal) ar.get('Sales');
            yearCurrent = String.valueOf(ar.get('Year'));
            salesMap.put(yearCurrent+bunit, sales);
            
            system.debug('strYTD: ' + strYTD + ' - Sales: ' + sales);
            
            if(yearCurrent == strYTD){
                ytdTotal = ytdTotal + sales;
            }
            else if(yearCurrent == strPYTD){
                pytdTotal = pytdTotal + sales;                
            }
            
            if(bunit != bu){
                buSet.add(bunit);
            }
        }
        
        // Set up Global Total
        if(ytdTotal > 0){
            salesMap.put(YTD+'Global', ytdTotal);
        }
        else{
            salesMap.put(YTD+'Global', 0);
        }
        if(pytdTotal > 0){
            salesMap.put(PYTD+'Global', pytdTotal);
        }
        else{
            salesMap.put(PYTD+'Global', 0);
        }
        
        // This Sets up the YOY Data
        ytdgraphData = '{ year: \'' + strPYTD + '\', Sales: ' + salesMap.get(strPYTD+'Global') + ' },';
        ytdgraphData = ytdgraphData + '{ year: \'' + strYTD + '\', Sales: ' + salesMap.get(strYTD+'Global') + ' }';
        
        // Convert the Set to the list which drives the order and contruction of the table on the account page
        buList.addAll(buSet);
        
        system.debug('BU SUmmary: buList: ' + buList);
        system.debug('BU Summary: salesMap: ' + salesMap);
        
        integer row = 0;
        // This ensures we don't have any null values in our map...that would be bad.
        for(string s : buList){
            system.debug('BU Cleanup Loop: ' + s + 'salesMap.get(strYTD+s):' + salesMap.get(strYTD+s) + 'salesMap.get(strPYTD+s)' + salesMap.get(strPYTD+s));
            if(salesMap.get(strYTD+s) == NULL){
                salesMap.put(strYTD+s,0);
            }
            if(salesMap.get(strPYTD+s) == NULL){
                salesMap.put(strPYTD+s,0);
            }
            system.debug('BU Cleanup Loop: ' + s + 'salesMap.get(strYTD+s):' + salesMap.get(strYTD+s) + 'salesMap.get(strPYTD+s)' + salesMap.get(strPYTD+s));
            if(salesMap.get(strPYTD+s) > 0 || salesMap.get(strYTD+s) > 0){
                buListFinal.add(s);
            }
            if(bugraphData != NULL){
                bugraphData = bugraphData + ',\r\n';
            }
            if(s != 'Global'){
                if(bugraphData != NULL){
                    bugraphData = bugraphData + '{ BU: \'' + s + '\', ' + strPYTD +': ' + salesMap.get(strPYTD+s) + ', ' + strYTD +': ' + salesMap.get(strYTD+s) + ' }';
                }
                else{
                    bugraphData = '{ BU: \'' + s + '\', ' + strPYTD +': ' + salesMap.get(strPYTD+s) + ', ' + strYTD +': ' + salesMap.get(strYTD+s) + ' }';
                }
            }
            ++row;
        }
        system.debug('buListFinal: ' + buListFinal);
        return buListFinal;
    }
    
    public string getGraph() {
        
        //string salesMonth;
        decimal sales;
        date thisMonth = Date.today();
        thisMonth = Date.newInstance(thisMonth.year(),thisMonth.month(),1);
        date salesMonth;
        string salesMonth2;
        date mcheck;
        string strmcheck;
        list<integer> monthList = new list<integer>();
        list<String> dlist = new list<String>();
        list<String> dlistcheck = new list<String>();
        
        map<String, String> monthMap = new map<String, String>();
        monthMap.put('1', 'January');
        monthMap.put('2', 'February');
        monthMap.put('3', 'March');
        monthMap.put('4', 'April');
        monthMap.put('5', 'May');
        monthMap.put('6', 'June');
        monthMap.put('7', 'July');
        monthMap.put('8', 'August');
        monthMap.put('9', 'September');
        monthMap.put('10', 'October');
        monthMap.put('11', 'November');
        monthMap.put('12', 'December');
        
        list<String> dateCompare = new list<String>();
        // Create list of 12 months of string dates in the 2016/07/01 format to fill in the gaps.
        // https://teleflex--sandbox--c.cs42.visual.force.com/apex/account?id=001E000001GM11e&nooverride=1 
        thisMonth = thisMonth.addYears(-1);
        thisMonth = thisMonth.addMonths(1);
        for (Integer i = 0; i < 12; i++) {
            mcheck = thisMonth.addMonths(i);
            strmcheck = mcheck.format();
            dlistcheck.add(strmcheck);
        }
        system.debug('dlistcheck: ' + dlistcheck);
            
        for(AggregateResult ar : [SELECT Date__c Month, SUM(Sales__c) Sales 
                                  FROM Invoiced_Sales__c  
                                  WHERE Account__c = :acct.Id 
                                  AND date__c = LAST_N_DAYS:365 
                                  Group By Date__c  
                                  ORDER BY Date__c])
        {
            
            salesMonth = (date) ar.get('Month');
            salesMonth2 = salesMonth.format();
            sales = (decimal) ar.get('Sales');
            smMap.put(salesMonth2, sales);
            dlist.add(salesMonth2);
            
//             string datetimestr  salesMonth = Date.format('MMM dd, yyyy');
//            system.debug('salesMonth: ' + salesMonth
        }
        for(String s : dlistcheck){
            if(smMap.get(s) == NULL){
                smMap.put(s,0);
            }
        }

        string mstr;
        for(String i : dlistcheck){
            system.debug('Month: ' + i);
            mstr = i;
            mstr = monthMap.get(mstr.substringBefore('/')) + ' ' + mstr.substringAfterLast('/');
            if(graphData != NULL){
                graphData = graphData + ',\r\n';
            }
            if(smMap.get(i) != NULL){
                if(graphData != NULL){
                    graphData = graphData + '{ month: \'' + mstr + '\', YTD: ' + smMap.get(i) + ' }';
                }
                else{
                    graphData = '{ month: \'' + mstr + '\', YTD: ' + smMap.get(i) + ' }';
                }
                
            }
            else{
                if(graphData != NULL){
                    graphData = graphData + '{ month: \'' + mstr + '\', YTD: 0 }';
                }
                else{
                    graphData = '{ month: \'' + mstr + '\', YTD: 0 }';
                }
                
            }
        }
        system.debug('graphData: ' + graphData);
        // salesMonth. 

        return graphData;

    }
    /*
    public void generateSBY(Account acct) {
        string bu;
        string year;
        string acctId;
        string aString;
        string splitPeas;

        string yearCurrent = '2016';
        string yearPrevious = '2015';
        string material;
        decimal sales;
        
        Id aid = acct.Id;
        
        set<String> yearSet = new set<String>();
        set<String> buSet = new set<String>();

        list<Sales_by_Product_by_Year__c> SBP = new list<Sales_by_Product_by_Year__c>();
        list<String> mList = new list<String>();

        map<String, Decimal> salesMap = new map<String, Decimal>();
        map<String, String> mbuMap = new map<String, String>();
        map<String, Id> mMap = new map<String, Id>();


        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Account__c, Business_Unit__c, Material_Name__c, SUM(Sales__c) Sales 
                                  FROM Sales_by_Product__c 
                                  WHERE Account__c = :aid 
                                  Group By CALENDAR_YEAR(Date__c), Account__c, Business_Unit__c, Material_Name__c])
        {
            bu = (string) ar.get('Business_Unit__c');
            yearCurrent = String.valueOf(ar.get('Year'));
            material = (string) ar.get('Material_Name__c');
            sales = (decimal) ar.get('Sales');
            aString = (string) ar.get('Account__c');
            salesMap.put(yearCurrent+material, sales);
            mbuMap.put(material, bu+','+aString);
            mList.add(material);
            //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
        }
        
        for(Product2 p : [SELECT Id, Name FROM Product2 WHERE Name =:mList]){
            mMap.put(p.Name, p.Id);
        }
        //system.debug('mMap: ' + mMap);

        for(String s : mList){
            if(mbuMap.get(s) != NULL){
                splitPeas = mbuMap.get(s);
                for(String bl : splitPeas.split(',')){
                    if(bu == NULL){
                        bu = bl;
                    }
                    else{
                        acctId = bl;
                    }
                }
                Sales_by_Product_by_Year__c  newSBP = new Sales_by_Product_by_Year__c (
                    Account__c = acctId,
                    Business_Unit__c = bu,
                    Material_Name__c = s,
                    Product__c = mMap.get(s)
                );
                if(salesMap.get(yearCurrent+s) != NULL){
                    newSBP.Sales_YTD__c = salesMap.get(yearCurrent+s);
                }
                else{
                    newSBP.Sales_YTD__c = 0;
                }
                if(salesMap.get(yearPrevious+s) != NULL){
                    newSBP.Sales_Prior_Year__c = salesMap.get(yearPrevious+s);
                }
                else{
                    newSBP.Sales_Prior_Year__c = 0;
                }
                SBP.add(newSBP);
                system.debug('newSBP: ' + newSBP);
            }
            
        }
        //return SBP;
        if(SBP.size() > 0){
            system.debug('Insert #' + SBP.size() + 'Rows of Data!');
            insert SBP;
        }
    }*/
    /*
    public List<Sales_by_Product__c> getmyT10BU() {
        
        return [SELECT Product__r.Material_Link__c, Product__r.Description, Business_Unit__c, 
                Sales_YTD__c, Sales_Prior_Year__c, Growth__c 
                FROM Sales_by_Product__c 
                WHERE Account__c=:acct.id 
                AND Business_Unit__c=:bu 
                ORDER BY Sales_YTD__c DESC NULLS LAST
                LIMIT 10];
    }*/
    
    public List<Contact> getMyContacts() {
        return [SELECT Id, Salutation, Name, Title, Position_Job_Title__c, 
                email, phone 
                FROM Contact 
                WHERE AccountId=:acct.id 
                AND Contact.Business_Unit1__c INCLUDES (:bu) 
                ORDER BY Name ASC NULLS LAST];
        
    }
    
    public List<Contact> getContacts() {
        return [SELECT Id, Salutation, Name, Title, Position_Job_Title__c, 
                email, phone 
                FROM Contact 
                WHERE AccountId=:acct.id 
                //AND Contact.Business_Unit1__c != :bu 
                AND Contact.Business_Unit1__c EXCLUDES (:bu) 
                ORDER BY Name ASC NULLS LAST];
    }
}