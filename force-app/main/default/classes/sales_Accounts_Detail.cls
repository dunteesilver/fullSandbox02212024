public class sales_Accounts_Detail {
    
    public map<String, Decimal> salesMap {get; set;}
    public map<String, Decimal> qtyMap {get; set;}
    public map<String, String> monthMap {get; set;}
    public map<String, Product2> prodMap {get; set;}
    public map<Id, Decimal> ooMap {get; set;}
    public map<Id, Decimal> roMap {get; set;}
    public map<String, String> compMap {get; set;}
    
    public list<String> mList {get; set;}
    public list<String> yList {get; set;}
    public list<String> pList {get; set;}
    
    public Account acct {get; set;}
    
    public decimal ytdTotal {get; set;}
    public decimal pytdTotal {get; set;}
    
    public boolean recentOrders {get; set;}
    public boolean openOrders {get; set;}
    public integer monthsLeft {get; set;}
    public string tid {get; set;}    
    public string aid {get; set;}    
    public string thisYear {get; set;}
    public string thisMonth {get; set;}
    public string thisMonthName {get; set;}    
    public string lastYear {get; set;}
    public string tnumber {get; set;}
    
    public sales_Accounts_Detail(){
        
        monthMap = new map<String, String>();
        compMap = new map<String, String>();
        prodMap = new map<String, Product2>();
        pList = new list<String>();
        acct = new Account();
        
        mList = new list<String>{'1','2','3','4','5','6','7','8','9','10','11','12'};
            
            monthMap.put('1', 'Jan');
            monthMap.put('2', 'Feb');
        monthMap.put('3', 'Mar');
        monthMap.put('4', 'Apr');
        monthMap.put('5', 'May');
        monthMap.put('6', 'June');
        monthMap.put('7', 'July');
        monthMap.put('8', 'Aug');
        monthMap.put('9', 'Sept');
        monthMap.put('10', 'Oct');
        monthMap.put('11', 'Nov');
        monthMap.put('12', 'Dec');

        yList = new list<String>();
        salesMap = new map<String, Decimal>();
        qtyMap = new map<String, Decimal>();
        ytdTotal = 0;
        pytdTotal = 0;
        
        // Product Variables
        string prod;

        ooMap = new map<Id, Decimal>();
        roMap = new map<Id, Decimal>();
        recentOrders = FALSE;
        openOrders = FALSE;

        
        tid = ApexPages.currentPage().getParameters().get('id');
        aid = ApexPages.currentPage().getParameters().get('aid');
        
        acct = [SELECT Name, SAP_Code__c FROM Account WHERE Id =:aid];
        tnumber = [SELECT Territory_Number__c FROM Territory_Master__c where Id =:tid].Territory_Number__c;            
        
        decimal count;
        string account;
        
        //Recent Orders
        for(AggregateResult ar : [SELECT sum(Sales__c ) cnt, Account__c acct 
                                  FROM Invoiced_Sales_Detail__c  
                                  WHERE Account__c =:aid 
                                  AND Territory__c =:tid 
                                  GROUP BY Account__c])
        {
            count = (decimal) ar.get('cnt');
            account = (string) ar.get('acct');
            roMap.put(account, count);
            
            recentOrders = TRUE;
        }
        
        // Open Orders
        for(AggregateResult ar : [SELECT sum(Order_Total__c) cnt, Account__c acct 
                                  FROM Open_Orders__c 
                                  WHERE Account__c =:aid
                                  GROUP BY Account__c])
        {
            count = (decimal) ar.get('cnt');
            account = (string) ar.get('acct');
            ooMap.put(account, count);
            openOrders = TRUE;
        }
        
        system.debug('tid: ' + tid);
        decimal sales; // Sales
        decimal qty; // Quantity
        string yearCurrent; 
        string monthCurrent;
        string comp;

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
            }
        }
        
        
        
        // Account Sales
        // Main Aggregate
        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, CALENDAR_MONTH(Date__c) Month, Compensation_Type__c, 
                                  Material_Key__c, SUM(Quantity__c) qty, SUM(Sales__c) Sales
                                  FROM Invoiced_Sales__c 
                                  WHERE Territory__c = :tid 
                                  AND Account__c = :aid 
                                  AND (Date__c = THIS_YEAR OR Date__c = LAST_YEAR) 
                                  GROUP BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c), Compensation_Type__c, Material_Key__c
                                  ORDER BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c), Material_Key__c])
        {
            sales = (decimal) ar.get('Sales');
            qty = (decimal) ar.get('qty');
            prod = (string) ar.get('Material_Key__c');
            comp = (string) ar.get('Compensation_Type__c');
            monthCurrent = String.valueOf(ar.get('Month'));
            yearCurrent = String.valueOf(ar.get('Year'));

            prodSet.add(prod);
            if(comp != NULL){
                compMap.put(prod, comp);                
            }
            else{
                compMap.put(prod, '-');
            }

            
            // Account Sales Map
            salesMap.put(yearCurrent + monthCurrent + prod, sales);
            
            // Sales Totals
            if(salesMap.get(yearCurrent+prod+'prodSalesTotal') != NULL){
                salesMap.put(yearCurrent + prod + 'prodSalesTotal', (sales+salesMap.get(yearCurrent+prod+'prodSalesTotal')));                    
            }
            else{
                salesMap.put(yearCurrent + prod + 'prodSalesTotal', sales);
            }
            
            // Quantity Map
            qtyMap.put(yearCurrent + monthCurrent + prod, qty);
            
            // Quantity Totals
            if(qtyMap.get(yearCurrent+prod+'prodQtyTotal') != NULL){
                qtyMap.put(yearCurrent + prod + 'prodQtyTotal', (qty+qtyMap.get(yearCurrent+prod+'prodQtyTotal')));                    
            }
            else{
                qtyMap.put(yearCurrent + acct.SAP_Code__c + 'prodQtyTotal', qty);
            }
        }
        
        // Account Quantity
        /* - Consolidated these in to one aggregate query
        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, CALENDAR_MONTH(Date__c) Month, Compensation_Type__c, Material_Key__c, SUM(Quantity__c) qty 
                                  FROM Invoiced_Sales__c 
                                  WHERE Territory__c = :tid 
                                  AND Account__c = :aid 
                                  GROUP BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c), Compensation_Type__c, Material_Key__c
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
                qtyMap.put(yearCurrent + acct.SAP_Code__c + 'prodQtyTotal', qty);
            }
        }*/
        
        for(Product2 p : [SELECT Id, Name, Description, Material_Key__c   
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