public without sharing class SalesController {
    @AuraEnabled public String strYTD {get; set;}
    @AuraEnabled public String strPYTD {get; set;}
    @AuraEnabled public String graphData {get; set;}
    @AuraEnabled public String ytdgraphData {get; set;}
    @AuraEnabled public String bugraphData {get; set;}
    @AuraEnabled public integer YTD {get; set;}
    @AuraEnabled public integer PYTD {get; set;}
    @AuraEnabled public string thisYear {get{
        return String.valueOf(System.Today().year());
    } set;}
    @AuraEnabled public string lastYear {get{
        return String.valueOf(System.Today().year()-1);
    } set;}
    @AuraEnabled public Map<String, Decimal> salesMap {get; set;}
    @AuraEnabled public List<String> buListFinal {get;set;}
    @AuraEnabled public String bu {get;set;}

    /**************************** Start All Teleflex Top 10 *****************************/
    @AuraEnabled public Map<String, String> prodMap {get; set;}
    @AuraEnabled public Map<String, Decimal> salesMapTop {get; set;}
    @AuraEnabled public List<String> prodKeyList {get; set;}
    /**************************** End All Teleflex Top 10 *****************************/

    @AuraEnabled
    public static SalesController initMethod(Id acctId){
        System.debug('-- Starting the New Sales Summary by BU - Lightning --');
        // This Class creates the BU table as well as the data used for the YOY bar graph - ESC 16JUL2016
        SalesController salesObj = new SalesController();
        salesObj.bu = [SELECT Id, Business_Unit__c FROM User WHERE Id=:userinfo.getuserid() LIMIT 1].business_unit__c;
        System.debug('*** salesObj.bu Lightning *** ' + salesObj.bu);
        salesObj.salesMap = new Map<String, Decimal>();
        salesObj.buListFinal = new List<String>();
        date thisYear;
        decimal sales; // Sales
        decimal ytdTotal = 0; // Store Global Sales Current Year
        decimal pytdTotal = 0; // Store Global Sales Last Year
        string bunit; // Business Unit
        string yearCurrent; // Current Year - String

        list<String> buList = new list<String>(); // Used to store the Business Units - Order Counts so we load Global, Users BU, and then the rest.
        //list<String> buListFinal = new list<String>();

        set<String> buSet = new set<String>(); // Used to store the Business Unit in the Agreegate Loop - sorted in the SOQL, added to the buList afterwards

        // End Variable Setting

        // Set the two BU's Global and User's BU. If the users BU is not set...the system does not throw an error.
        buSet.add('Global'); // Add the Global BU which is the 'Total' BU
        buSet.add(salesObj.bu); // Add the current users 'bu'

        // Set the 'This Year' and 'Last Year'
        // This sets the dates and adds them to a set list so that we can ensure we don't have
        // any null values in our data

        thisYear = Date.today();
        salesObj.YTD = thisYear.year();
        salesObj.PYTD = thisYear.year()-1;
        salesObj.strYTD = String.valueOf(salesObj.YTD);
        salesObj.strPYTD = String.valueOf(salesObj.PYTD);

        System.debug('*** About to Aggregate Data *** ');
        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Business_Unit__c, SUM(Sales__c) Sales
                                  FROM Invoiced_Sales__c
                                  WHERE Account__c = :acctId
                                  Group By CALENDAR_YEAR(Date__c), Business_Unit__c
                                  ORDER BY Business_Unit__c ASC NULLS LAST])
        {
            bunit = (string) ar.get('Business_Unit__c');
            sales = (decimal) ar.get('Sales');
            yearCurrent = String.valueOf(ar.get('Year'));
            System.debug('*** bunit *** ' + bunit);
            System.debug('*** sales *** ' + sales);
            System.debug('*** yearCurrent *** ' + yearCurrent);
            salesObj.salesMap.put(yearCurrent+bunit, sales);

            //system.debug('salesObj.strYTD: ' + salesObj.strYTD + ' - Sales: ' + sales);
            System.debug('*** salesObj.salesMap *** ' + salesObj.salesMap);
            if(yearCurrent == salesObj.strYTD){
                ytdTotal = ytdTotal + sales;
            }
            else if(yearCurrent == salesObj.strPYTD){
                pytdTotal = pytdTotal + sales;
            }

            if(bunit != salesObj.bu){
                buSet.add(bunit);
            }
        }

        // Set up Global Total
        if(ytdTotal > 0){
            salesObj.salesMap.put(salesObj.YTD+'Global', ytdTotal);
        }
        else{
            salesObj.salesMap.put(salesObj.YTD+'Global', 0);
        }
        if(pytdTotal > 0){
            salesObj.salesMap.put(salesObj.PYTD+'Global', pytdTotal);
        }
        else{
            salesObj.salesMap.put(salesObj.PYTD+'Global', 0);
        }

        // This Sets up the YOY Data
        salesObj.ytdgraphData = '{ year: \'' + salesObj.strPYTD + '\', Sales: ' + salesObj.salesMap.get(salesObj.strPYTD+'Global') + ' },';
        salesObj.ytdgraphData = salesObj.ytdgraphData + '{ year: \'' + salesObj.strYTD + '\', Sales: ' + salesObj.salesMap.get(salesObj.strYTD+'Global') + ' }';

        // Convert the Set to the list which drives the order and contruction of the table on the account page
        buList.addAll(buSet);

        system.debug('BU SUmmary: buList: ' + buList);
        system.debug('BU Summary: salesObj.salesMap: ' + salesObj.salesMap);

        integer row = 0;
        // This ensures we don't have any null values in our map...that would be bad.
        for(string s : buList){
            system.debug('BU Cleanup Loop: ' + s + 'salesObj.salesMap.get(strYTD+s):' + salesObj.salesMap.get(salesObj.strYTD+s) + 'salesObj.salesMap.get(strPYTD+s)' + salesObj.salesMap.get(salesObj.strPYTD+s));
            if(salesObj.salesMap.get(salesObj.strYTD+s) == NULL){
                salesObj.salesMap.put(salesObj.strYTD+s,0);
            }
            if(salesObj.salesMap.get(salesObj.strPYTD+s) == NULL){
                salesObj.salesMap.put(salesObj.strPYTD+s,0);
            }
            system.debug('BU Cleanup Loop: ' + s + 'salesMap.get(strYTD+s):' + salesObj.salesMap.get(salesObj.strYTD+s) + 'salesMap.get(strPYTD+s)' + salesObj.salesMap.get(salesObj.strPYTD+s));
            if(salesObj.salesMap.get(salesObj.strPYTD+s) > 0 || salesObj.salesMap.get(salesObj.strYTD+s) > 0){
                salesObj.buListFinal.add(s);
            }
            if(salesObj.bugraphData != NULL){
                salesObj.bugraphData = salesObj.bugraphData + ',\r\n';
            }
            if(s != 'Global'){
                if(salesObj.bugraphData != NULL){
                    salesObj.bugraphData = salesObj.bugraphData + '{ BU: \'' + s + '\', ' + salesObj.strPYTD +': ' + salesObj.salesMap.get(salesObj.strPYTD+s) + ', ' + salesObj.strYTD +': ' + salesObj.salesMap.get(salesObj.strYTD+s) + ' }';
                }
                else{
                    salesObj.bugraphData = '{ BU: \'' + s + '\', ' + salesObj.strPYTD +': ' + salesObj.salesMap.get(salesObj.strPYTD+s) + ', ' + salesObj.strYTD +': ' + salesObj.salesMap.get(salesObj.strYTD+s) + ' }';
                }
            }
            ++row;
        }
        system.debug('salesMap: ' + salesObj.salesMap);
        system.debug('buListFinal: ' + salesObj.buListFinal);
        system.debug('salesObj: ' + salesObj);
        return salesObj ;
    }//end of initMethod

    @AuraEnabled
    public static SalesController buListMethod(List<String> buListFinal){
        SalesController salesObj = new SalesController();
        salesObj.buListFinal = buListFinal;
        return salesObj;
    }

    /**************************** Start All Teleflex Top 10 *****************************/
    @AuraEnabled
    public static SalesController getTop10(Id acctId) {
        system.debug('-- Start the New Sales Summary - getTop10 --');
        string material;
        decimal sales;
        set<Id> pids = new set<Id>();
        List<String> mList = new List<String>();
        /****************** Start All Teleflex Top 10 Variables *************************/
        SalesController salesObjTop = new SalesController();
        salesObjTop.salesMapTop = new Map<String, Decimal>();
        salesObjTop.prodMap = new Map<String, String>();
        salesObjTop.prodKeyList = new List<String>();
        /****************** End All Teleflex Top 10 Variables *************************/

        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Material_Key__c, SUM(Sales__c) Sales
                                  FROM Invoiced_Sales__c
                                  WHERE Account__c = :acctId
                                  AND Date__c = THIS_YEAR
                                  Group By CALENDAR_YEAR(Date__c), Material_Key__c
                                  ORDER BY SUM(Sales__c) DESC NULLS LAST
                                  LIMIT 10])
        {

            material = (string) ar.get('Material_Key__c');
            sales = (decimal) ar.get('Sales');
            salesObjTop.salesMapTop.put('YTDTOP10'+material, sales);
            mList.add(material);
            //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
        }
        system.debug('*** salesObjTop.prodKeyList *** ' + salesObjTop.prodKeyList);
        if(mList.size() > 0){
            for(Product2 p : [SELECT Id, Name, Material_Link__c, SBU__c,
                              Description, Material_Key__c, CurrencyIsoCode
                              FROM Product2
                              WHERE Material_Key__c =:mList])
            {
                salesObjTop.prodMap.put(p.Name, p.Description);
                pids.add(p.Id);
                salesObjTop.prodKeyList.add(p.Name);
            }
            //system.debug('prodMap: ' + prodMap);
            for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Material_Key__c, SUM(Sales__c) Sales
                                      FROM Invoiced_Sales__c
                                      WHERE Account__c = :acctId
                                      AND Product__c =:pids
                                      AND Date__c = LAST_YEAR
                                      Group By CALENDAR_YEAR(Date__c), Material_Key__c
                                      LIMIT 10])
            {

                material = (string) ar.get('Material_Key__c');
                sales = (decimal) ar.get('Sales');
                salesObjTop.salesMapTop.put('PYTDTOP10'+material, sales);
                //system.debug('Sales 2015: ' + salesObj.salesMapTop.get('PYTDTOP10'+material));
                //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
            }
            //system.debug('prodMap.keySet(): ' + prodMap.keySet());
            for(string s : mList){
                if(salesObjTop.salesMapTop.get('PYTDTOP10'+s) == NULL){
                    salesObjTop.salesMapTop.put('PYTDTOP10'+s,0);
                }
                if(salesObjTop.salesMapTop.get('YTDTOP10'+s) == NULL){
                    salesObjTop.salesMapTop.put('YTDTOP10'+s,0);
                }
            }
        } // End mList.size > 0 IF/THEN

        system.debug('salesObjTop.salesMapTop: ' + salesObjTop.salesMapTop);
        system.debug('*** salesObjTop.prodKeyList *** ' + salesObjTop.prodKeyList);
        system.debug('-- Finish the New Sales Summary - getTop10 --');
        return salesObjTop;

    }//end of teleflex top 10
    /**************************** End All Teleflex Top 10 *****************************/
    
    /**************************** Start Teleflex Top 10 BU *****************************/
    @AuraEnabled
    public static SalesController getTop10Bu(Id acctId) {
        system.debug('-- Start the New Sales Summary - getTop10 --');
        string material;
        decimal sales;
        set<Id> pids = new set<Id>();
        List<String> mList = new List<String>();
        /****************** Start All Teleflex Top 10 BU Variables *************************/
        SalesController salesObjTopBu = new SalesController();
        salesObjTopBu.salesMapTop = new Map<String, Decimal>();
        salesObjTopBu.prodMap = new Map<String, String>();
        salesObjTopBu.prodKeyList = new List<String>();
        SalesController salesObj = new SalesController();
        salesObj.bu = [SELECT Id, Business_Unit__c FROM User WHERE Id=:userinfo.getuserid() LIMIT 1].business_unit__c;
        salesObjTopBu.bu = salesObj.bu;
        /****************** End All Teleflex Top 10 BU Variables *************************/

        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Material_Key__c, SUM(Sales__c) Sales
                                  FROM Invoiced_Sales__c
                                  WHERE Account__c = :acctId
                                  AND Date__c = THIS_YEAR
                                  AND Business_Unit__c =:salesObj.bu
                                  Group By CALENDAR_YEAR(Date__c), Material_Key__c
                                  ORDER BY SUM(Sales__c) DESC NULLS LAST
                                  LIMIT 10])
        {

            material = (string) ar.get('Material_Key__c');
            sales = (decimal) ar.get('Sales');
            salesObjTopBu.salesMapTop.put('YTDTOP10'+material, sales);
            mList.add(material);
            //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
        }
        system.debug('*** salesObjTop.prodKeyList *** ' + salesObjTopBu.prodKeyList);
        if(mList.size() > 0){
            for(Product2 p : [SELECT Id, Name, Material_Link__c, SBU__c,
                              Description, Material_Key__c, CurrencyIsoCode
                              FROM Product2
                              WHERE Material_Key__c =:mList])
            {
                salesObjTopBu.prodMap.put(p.Name, p.Description);
                pids.add(p.Id);
                salesObjTopBu.prodKeyList.add(p.Name);
            }
            //system.debug('prodMap: ' + prodMap);
            for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, Material_Key__c, Business_Unit__c, SUM(Sales__c) Sales
                                      FROM Invoiced_Sales__c
                                      WHERE Account__c = :acctId
                                      AND Product__c =:pids
                                      AND Date__c = LAST_YEAR
                                      Group By CALENDAR_YEAR(Date__c), Material_Key__c, Business_Unit__c
                                      LIMIT 10])
            {

                material = (string) ar.get('Material_Key__c');
                sales = (decimal) ar.get('Sales');
                salesObjTopBu.salesMapTop.put('PYTDTOP10'+material, sales);
                //system.debug('Sales 2015: ' + salesObj.salesMapTop.get('PYTDTOP10'+material));
                //system.debug('Previous Year: ' + yearCurrent + ' - Material: ' + material + ' - Sales: ' + sales);
            }
            //system.debug('prodMap.keySet(): ' + prodMap.keySet());
            for(string s : mList){
                if(salesObjTopBu.salesMapTop.get('PYTDTOP10'+s) == NULL){
                    salesObjTopBu.salesMapTop.put('PYTDTOP10'+s,0);
                }
                if(salesObjTopBu.salesMapTop.get('YTDTOP10'+s) == NULL){
                    salesObjTopBu.salesMapTop.put('YTDTOP10'+s,0);
                }
            }
        } // End mList.size > 0 IF/THEN

        system.debug('salesObjTopBu.salesMapTop: ' + salesObjTopBu.salesMapTop);
        system.debug('*** salesObjTopBu.prodKeyList *** ' + salesObjTopBu.prodKeyList);
        system.debug('-- Finish the New Sales Summary - getTop10 --');
        return salesObjTopBu;

    }//end of teleflex top 10 BU
	/**************************** End Teleflex Top 10 BU *****************************/    
}