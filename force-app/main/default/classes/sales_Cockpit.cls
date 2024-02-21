public class sales_Cockpit {
    
    public map<String, Decimal> salesMap {get; set;}
    public map<String, Decimal> qtyMap {get; set;}
    public map<String, Decimal> quotaMap {get; set;}
    public map<String, Decimal> quotaMonthlyMap {get; set;}
    public map<String, String> monthMap {get; set;}
    public map<String, Account> sapMap {get; set;}
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
    
    //public decimal oppAmountThisMonth {get; set;}

    public decimal thisYearTotal {get; set;}
    public decimal lastYearTotal {get; set;}

    public string tid {get; set;}    
    public string thisYear {get; set;}
    public string thisMonth {get; set;}
    public integer monthsLeft {get; set;}
    public string thisMonthName {get; set;}    
    public string lastYear {get; set;}
    public string ytdGraph {get; set;}
    public string cumulativeGraph {get; set;}
    
    public sales_Cockpit(){
        monthList = new list<String>();
        monthMap = new map<String, String>();
        acctList = new list<String>();
        sapMap = new map<String, Account>();
        
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
        quotaytdTotal = 0;
        
        quotaMap.put('1', 47279);
        quotaMap.put('2', 92195);
        quotaMap.put('3', 137110);
        quotaMap.put('4', 196210);
        quotaMap.put('5', 243489);
        quotaMap.put('6', 288405);
        quotaMap.put('7', 345140);
        quotaMap.put('8', 392419);
        quotaMap.put('9', 437335);
        quotaMap.put('10', 496434);
        quotaMap.put('11', 538986);
        quotaMap.put('12', 590993);
        
        quotaMonthlyMap.put('1', 47279);
        quotaMonthlyMap.put('2', 44915);
        quotaMonthlyMap.put('3', 44915);
        quotaMonthlyMap.put('4', 59099);
        quotaMonthlyMap.put('5', 47279);
        quotaMonthlyMap.put('6', 44915);
        quotaMonthlyMap.put('7', 56735);
        quotaMonthlyMap.put('8', 47279);
        quotaMonthlyMap.put('9', 44915);
        quotaMonthlyMap.put('10', 59099);
        quotaMonthlyMap.put('11', 42551);
        quotaMonthlyMap.put('12', 52007);
        
        tid = ApexPages.currentPage().getParameters().get('id');
        system.debug('tid: ' + tid);
        decimal sales; // Sales
        decimal qty; // Quantity
        string yearCurrent; 
        string monthCurrent;
        string sap;
        set<String> sapSet = new set<String>();
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
         
        // Sales
        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, CALENDAR_MONTH(Date__c) Month, SUM(Sales__c) Sales
                                  FROM Invoiced_Sales__c
                                  WHERE Territory_Number__c = :tid
                                  //AND Date__c = LAST_YEAR
                                  GROUP BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c) 
                                  ORDER BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c)])
        {
            sales = (decimal) ar.get('Sales');
            monthCurrent = String.valueOf(ar.get('Month'));
            yearCurrent = String.valueOf(ar.get('Year'));
            
            // Sales Map
            salesMap.put(yearCurrent + monthCurrent, sales);
            //system.debug('Sales: ' + sales + ' Month: ' + monthCurrent);
            
            if(yearCurrent == thisYear){
                thisYearTotal = thisYearTotal + sales;
                salesMap.put(yearCurrent + monthCurrent + 'cumulativeTotal', thisYearTotal);
                //quotaytdTotal += quotaMap.get(monthCurrent);
            }
            else{
                lastYearTotal = lastYearTotal + sales;
                salesMap.put(yearCurrent + monthCurrent + 'cumulativeTotal', lastYearTotal);
            }
            //system.debug('Sales: ' + sales + ' Month: ' + monthCurrent + ' and Year: ' + yearCurrent);
            
            // Cumulative Totals
/*
            cumulative = salesMap.get(yearCurrent+monthCurrent+'cumulativeTotal');
            cumulative = sales + cumulative;
            system.debug('Year: ' + yearCurrent + ' Month: ' + monthCurrent + ' cumulative: ' + cumulative);
            salesMap.put(yearCurrent + monthCurrent + 'cumulativeTotal', (cumulative));
*/
        }
        
        // Quantity
        for(AggregateResult ar : [SELECT CALENDAR_YEAR(Date__c) Year, CALENDAR_MONTH(Date__c) Month, SUM(Quantity__c) qty
                                  FROM Invoiced_Sales__c 
                                  WHERE Territory_Number__c = :tid 
                                  GROUP BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c) 
                                  ORDER BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c)])
        {
            qty = (decimal) ar.get('qty');
            monthCurrent = String.valueOf(ar.get('Month'));
            yearCurrent = String.valueOf(ar.get('Year'));
            
            // Quantity Map
            qtyMap.put(yearCurrent + monthCurrent, qty);
            
            //system.debug('Sales: ' + sales + ' Month: ' + monthCurrent + ' and Year: ' + yearCurrent);
        }
        
        // Account Sales
        for(AggregateResult ar : [SELECT SAP_Code__c SAP, CALENDAR_YEAR(Date__c) Year, CALENDAR_MONTH(Date__c) Month, SUM(Sales__c) Sales 
                                  FROM Invoiced_Sales__c 
                                  WHERE Territory_Number__c = :tid 
                                  GROUP BY SAP_Code__c, CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c) 
                                  ORDER BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c)])
        {
            sales = (decimal) ar.get('Sales');
            sap = (string) ar.get('SAP');
            monthCurrent = String.valueOf(ar.get('Month'));
            yearCurrent = String.valueOf(ar.get('Year'));
            sapSet.add(sap);

            // Account Sales Map
            salesMap.put(yearCurrent + monthCurrent + sap, sales);
            
            // Totals
            if(salesMap.get(yearCurrent+sap+'currentYearTotal') != NULL){
                salesMap.put(yearCurrent + sap + 'currentYearTotal', (sales+salesMap.get(yearCurrent+sap+'currentYearTotal')));                    
            }
            else{
                salesMap.put(yearCurrent + sap + 'currentYearTotal', sales);
            }
            
            // Growth Totals
            if(monthCurrent <= thisMonth){
                if(salesMap.get(yearCurrent+sap+'compareSAPYOY') != NULL){
                    salesMap.put(yearCurrent + sap + 'compareSAPYOY', (sales+salesMap.get(yearCurrent+sap+'compareSAPYOY')));                    
                }
                else{
                    salesMap.put(yearCurrent + sap + 'compareSAPYOY', sales);
                } 
            }
            
        }
        
        // Account Quantity
        for(AggregateResult ar : [SELECT SAP_Code__c SAP, CALENDAR_YEAR(Date__c) Year, CALENDAR_MONTH(Date__c) Month, SUM(Quantity__c) qty 
                                  FROM Invoiced_Sales__c 
                                  WHERE Territory_Number__c = :tid 
                                  GROUP BY SAP_Code__c, CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c) 
                                  ORDER BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c)])
        {
            qty = (decimal) ar.get('qty');
            sap = (string) ar.get('SAP');
            monthCurrent = String.valueOf(ar.get('Month'));
            yearCurrent = String.valueOf(ar.get('Year'));
            
            // Quantity Map
            qtyMap.put(yearCurrent + monthCurrent + sap, qty);
            
            // Quantity Totals
            if(qtyMap.get(yearCurrent+sap+'currentYearQTYTotal') != NULL){
                qtyMap.put(yearCurrent + sap + 'currentYearQTYTotal', (qty+qtyMap.get(yearCurrent+sap+'currentYearQTYTotal')));                    
            }
            else{
                qtyMap.put(yearCurrent + sap + 'currentYearQTYTotal', qty);
            }
        }
        
        for(Account a : [SELECT Id, Name, SAP_Sold_To__c 
                         FROM Account
                         WHERE SAP_Sold_To__c =:sapSet
                         ORDER BY Name])
        {
            sapMap.put(a.SAP_Sold_To__c, a);
            acctList.add(a.SAP_Sold_To__c);
        }
        
        // Sets up the map with zero's to ensure against empty map errors.
        for(string a : sapMap.keyset()){
            for(string yr : yList){
                if(salesMap.get(yr+a+'currentYearTotal') == NULL){
                    salesMap.put(yr + a + 'currentYearTotal', 0);
                }
                if(qtyMap.get(yr+a+'currentYearQTYTotal') == NULL){
                    qtyMap.put(yr + a + 'currentYearQTYTotal', 0);
                }
                if(salesMap.get(yr+a+'compareSAPYOY') == NULL){
                    salesMap.put(yr+a+'compareSAPYOY', 0);
                }
                
                for(string m : mList){
                    if(salesMap.get(yr + m + a) == NULL){
                        salesMap.put(yr + m + a, 0);
                    }
                }
            }
        }

        // Get the default business hours
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        
        // Create Date on Year/Month/Day
        Date targetTime = Date.newInstance(Integer.valueOf(thisYear), 1, 1);
        Date endDate = Date.newInstance(Integer.valueOf(thisYear), Integer.valueOf(System.Today().month()), Integer.valueOf(System.Today().Day()));
        //date endDate = Date.today();
        //Date.newInstance(thisMonth.year(),thisMonth.month(),1);

        // Find whether the time is within the default business hours
        //Boolean isWithin= BusinessHours.isWithin(bh.id, targetTime, endDate);
        Long bizDays = BusinessHours.diff(bh.id, targetTime, endDate);
        bizDays = bizDays / 1000; //milliseconds
        bizDays /= 60; //seconds
        bizDays /= 60; //minutes
        bizDays /= 24; //hours
        system.debug('targetTime: ' + targetTime + ' / endDate: ' + endDate);
        system.debug('Totals Days: ' + bizDays);
        system.debug('To count TODAY in the total you have to put the endDate time to end of the current day or add a day. - ESC 27Jul2016');
        
        if(thisYearTotal != 0){
            ytdTotal = thisYearTotal;
            pytdTotal = (lastYearTotal / 250) * bizDays;
            pytdTotal = pytdTotal.setScale(2);
            
            if(ytdTotal != 0){
                ytdTotalPercent = (1-pytdTotal / ytdTotal) * 100;
                ytdTotalPercent = ytdTotalPercent.setScale(2);                
            }
            else{
                ytdTotalPercent = 0;
            }
            if(bizDays != 0){
                annualizedTotal = (ytdTotal / bizDays) * 250;
                annualizedTotal = annualizedTotal.setScale(2);
            }
            else{
                annualizedTotal = 0;
            }

            if(annualizedTotal != 0){
                annualizedPercent = (1-lastYearTotal / annualizedTotal) * 100;
                annualizedPercent = annualizedPercent.setScale(2);
            }
            else{
                annualizedPercent = 0;
            }
        }
        
        
        // Build out the ytdGraph Data
        for(string m : mList){
            string thisYearNull;

            if(salesMap.get(thisYear + m) == 0){
                thisYearNull = 'null';
            }
            else{
                thisYearNull = string.valueOf(salesMap.get(thisYear + m));
            }
            
            if(ytdGraph != NULL){
                ytdGraph = ytdGraph + ',\r\n';
                ytdGraph += '{ month: \'' + monthMap.get(m) + '\', ' + lastYear + ': ' + salesMap.get(lastYear + m) + ', ' + thisYear + ': ' + thisYearNull + ' }';
            }
            else{
                ytdGraph = '{ month: \'' + monthMap.get(m) + '\', ' + lastYear + ': ' + salesMap.get(lastYear + m) + ', ' + thisYear + ': ' + thisYearNull + ' }';
            }
            
            if(salesMap.get(thisYear+m+'cumulativeTotal') == 0){
                thisYearNull = 'null';
            }
            else{
                thisYearNull = string.valueOf(salesMap.get(thisYear+m+'cumulativeTotal'));
            }
            
            if(cumulativeGraph != NULL){
                cumulativeGraph = cumulativeGraph + ',\r\n';
                cumulativeGraph += '{ month: \'' + monthMap.get(m) + '\', ' + lastYear + ': ' + salesMap.get(lastYear+m+'cumulativeTotal') + ', ' + thisYear + ': ' + thisYearNull + ', Quota: ' + quotaMap.get(m) + ' }';
            }
            else{
                cumulativeGraph = '{ month: \'' + monthMap.get(m) + '\', ' + lastYear + ': ' + salesMap.get(lastYear+m+'cumulativeTotal') + ', ' + thisYear + ': ' + thisYearNull + ', Quota: ' + quotaMap.get(m) + ' }';
            }
            
        }
        

    }

    public Decimal getOppsThisMonth(){
        
        decimal amountSum;
        for(AggregateResult ar : [SELECT Sum(Amount) amt
                                  FROM Opportunity 
                                  WHERE OwnerId =:UserInfo.getUserId() 
                                  AND CloseDate = THIS_MONTH])
        {
            amountSum = (decimal) ar.get('amt');
        }
        
        return amountSum;
        
    }
    
    public Decimal getPiplineThisYear(){
        
        decimal amountSum;
        for(AggregateResult ar : [SELECT Sum(Amount) amt
                                  FROM Opportunity 
                                  WHERE OwnerId =:UserInfo.getUserId() 
                                  AND CloseDate = THIS_YEAR
                                  AND IsClosed = FALSE 
                                  AND CloseDate > THIS_MONTH])
        {
            amountSum = (decimal) ar.get('amt');
        }
        
        return amountSum;
        
    }
}