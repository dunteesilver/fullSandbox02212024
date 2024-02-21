public class sales_Cockpit_Account {
    
    public map<String, Decimal> salesMap {get; set;}
    public map<String, Decimal> qtyMap {get; set;}
    public map<String, Decimal> quotaMap {get; set;}
    public map<String, Decimal> quotaMonthlyMap {get; set;}
    public map<String, String> monthMap {get; set;}
    public map<String, Product2> prodMap {get; set;}
    public list<String> monthList {get; set;}
    public list<String> salesKey {get; set;}
    public list<String> mList {get; set;}
    public list<String> yList {get; set;}
    public list<String> acctList {get; set;}
    public decimal ytdTotal {get; set;}
    public decimal pytdTotal {get; set;}
    public decimal quotaytdTotal {get; set;}
    public decimal ytdTotalPercent {get; set;}
    public decimal annualizedTotal {get; set;}
    public decimal annualizedPercent {get; set;}
    
    public list<String> pList {get; set;}
    
    //public decimal oppAmountThisMonth {get; set;}

    public decimal thisYearTotal {get; set;}
    public decimal lastYearTotal {get; set;}

    public string tid {get; set;}    
    public string sap {get; set;}    
    public string thisYear {get; set;}
    public string thisMonth {get; set;}
    public integer monthsLeft {get; set;}
    public string thisMonthName {get; set;}    
    public string lastYear {get; set;}
    public string ytdGraph {get; set;}
    public string cumulativeGraph {get; set;}
    
    public sales_Cockpit_Account(){
        
        monthList = new list<String>();
        monthMap = new map<String, String>();
        acctList = new list<String>();
        prodMap = new map<String, Product2>();
        pList = new list<String>();
        
        mList = new list<String>{'1','2','3','4','5','6','7','8','9','10','11','12'};
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

        salesKey = new list<String>();
        yList = new list<String>();
        salesMap = new map<String, Decimal>();
        qtyMap = new map<String, Decimal>();
        quotaMap = new map<String, Decimal>();
        quotaMonthlyMap = new map<String, Decimal>();
        thisYearTotal = 0;
        lastYearTotal = 0;
        ytdTotal = 0;
        pytdTotal = 0;
        
        // Product Variables
        string prod;        
        
        tid = ApexPages.currentPage().getParameters().get('id');
        sap = ApexPages.currentPage().getParameters().get('sap');
        system.debug('tid: ' + tid);
        decimal sales; // Sales
        decimal qty; // Quantity
        string yearCurrent; 
        string monthCurrent;

        set<String> prodSet = new set<String>();
        decimal cumulative;

        thisYear = String.valueOf(System.Today().year());
        lastYear = String.valueOf(System.Today().year()-1);
        thisMonth = String.valueOf(System.Today().month());
        if(System.Today().month() == 12){
            monthsLeft = 1;
        }
        else{
            monthsLeft = 12 - System.Today().month();
        }
        
        Datetime tempDT = Datetime.now();
        thisMonthName = tempDT.format('MMMM');
        yList.add(lastYear);
        yList.add(thisYear);

        // Sets up the map with zero's to ensure against empty map errors.
        for(string yr : yList){
            for(string m : mList){
                salesMap.put(yr + m, 0);
                qtyMap.put(yr + m, 0);
                salesMap.put(yr + m + 'cumulativeTotal', 0);
            }
        }
        
        
        
        // Account Sales
        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, CALENDAR_MONTH(Date__c) Month, Material_Key__c, SUM(Sales__c) Sales 
                                  FROM Invoiced_Sales__c 
                                  WHERE Territory_Number__c = :tid 
                                  AND SAP_Code__c = :sap 
                                  GROUP BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c), Material_Key__c
                                  ORDER BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c), Material_Key__c])
        {
            sales = (decimal) ar.get('Sales');
            prod = (string) ar.get('Material_Key__c');
            monthCurrent = String.valueOf(ar.get('Month'));
            yearCurrent = String.valueOf(ar.get('Year'));
            prodSet.add(prod);
            
            // Account Sales Map
            salesMap.put(yearCurrent + monthCurrent + prod, sales);
            
            // Totals
            if(salesMap.get(yearCurrent+prod+'prodSalesTotal') != NULL){
                salesMap.put(yearCurrent + prod + 'prodSalesTotal', (sales+salesMap.get(yearCurrent+prod+'prodSalesTotal')));                    
            }
            else{
                salesMap.put(yearCurrent + prod + 'prodSalesTotal', sales);
            }
        }
        
        // Account Quantity
        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, CALENDAR_MONTH(Date__c) Month, Material_Key__c, SUM(Quantity__c) qty 
                                  FROM Invoiced_Sales__c 
                                  WHERE Territory_Number__c = :tid 
                                  AND SAP_Code__c = :sap 
                                  GROUP BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c), Material_Key__c
                                  ORDER BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c), Material_Key__c])
        {
            
            qty = (decimal) ar.get('qty');
            prod = (string) ar.get('Material_Key__c');
            monthCurrent = String.valueOf(ar.get('Month'));
            yearCurrent = String.valueOf(ar.get('Year'));
            
            // Quantity Map
            qtyMap.put(yearCurrent + monthCurrent + prod, qty);
            
            // Quantity Totals
            if(qtyMap.get(yearCurrent+prod+'prodQtyTotal') != NULL){
                qtyMap.put(yearCurrent + prod + 'prodQtyTotal', (qty+qtyMap.get(yearCurrent+prod+'prodQtyTotal')));                    
            }
            else{
                qtyMap.put(yearCurrent + sap + 'prodQtyTotal', qty);
            }
        }
        
        for(Product2 p : [SELECT Id, Name, Material_Key__c   
                         FROM Product2 
                         WHERE Material_Key__c =:prodSet
                         ORDER BY Name])
        {
            pList.add(p.Material_Key__c);
            prodMap.put(p.Material_Key__c, p);
        }
        
        // Sets up the map with zero's to ensure against empty map errors.
        for(string p : prodMap.keyset()){
            for(string yr : yList){
                if(salesMap.get(yr+p+'prodSalesTotal') == NULL){
                    salesMap.put(yr+p+'prodSalesTotal', 0);
                }
                if(qtyMap.get(yr+p+'prodQtyTotal') == NULL){
                    qtyMap.put(yr+p+'prodQtyTotal', 0);
                }
                for(string m : mList){
                    if(salesMap.get(yr+m+p) == NULL){
                        salesMap.put(yr+m+p, 0);
                    }
                    if(qtyMap.get(yr+m+p) == NULL){
                        qtyMap.put(yr+m+p, 0);
                    }
                }
            }
        }
        
    }

}