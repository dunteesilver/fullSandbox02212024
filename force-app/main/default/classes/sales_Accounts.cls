public class sales_Accounts {
    
    public Territory_Master__c tmaster {get; set;}
    public list<Sales_Accounts__c> saList {get; set;}
    public map<String, Decimal> tsp {get; set;}
    public map<Id, Decimal> ooMap {get; set;}
    public map<Id, Decimal> roMap {get; set;}
    public decimal totalSales {get; set;}
    public decimal totalOO {get; set;}
    public decimal totalRO {get; set;}
    public boolean redir {get; set;}
    public boolean comp {get{ RETURN ApexPages.currentPage().getParameters().get('showcomp') == 'yes'; } set;}
    public string tnumber {get; set;}
    public String oname {get; set;}
    public Id tid {get; set;}
    public string thisYear {get{return String.valueOf(System.Today().year());} set;}
    public string lastYear {get{return String.valueOf(System.Today().year()-1);} set;}
    
    public sales_Accounts(){
        saList = new list<Sales_Accounts__c>();
        tsp = new map<String, Decimal>();
        ooMap = new map<Id, Decimal>();
        roMap = new map<Id, Decimal>();
        tmaster = new Territory_Master__c();
        string account;
        string query;
        decimal count;
        redir = FALSE;
        
        set<Id> aSet = new set<Id>();
        
        totalSales = 0;
        totalOO = 0;
        totalRO = 0;
        
        if(ApexPages.currentPage().getParameters().get('id') != NULL){
            for(Territory_User__c tu : [SELECT Territory_Master__c, Territory_Number__c  
                                        FROM Territory_User__c 
                                        WHERE Territory_Number__c =:ApexPages.currentPage().getParameters().get('id')])
            {
                tid = tu.Territory_Master__c;
                tnumber = tu.Territory_Number__c;
            }
        }
        else{
            for(Territory_User__c tu : [SELECT Territory_Master__c, Territory_Number__c  
                                        FROM Territory_User__c 
                                        WHERE User__c =:UserInfo.getUserId() 
                                        AND Primary__c = TRUE])
            {
                tid = tu.Territory_Master__c;
                tnumber = tu.Territory_Number__c;
            }
        }
        //saList
        if(tid != NULL){
            decimal tspPercent;
            tmaster = [SELECT Business_Unit__c FROM Territory_Master__c where Id =:tid];
            
            // Start New
            query = 'SELECT Account__r.Name, Account__r.SAP_Code__c, Account__r.SAP_Account_Status__c, ';
            query += 'Sales_YTD__c, Sales_PYTD__c, Sales_PY__c, YOY_Percent__c, Territory__c, Last_Order_Date__c, Days_Since_Last_Order__c ';
            query += 'FROM Sales_Accounts__c ';
            query += 'WHERE Territory__c =:tid ';
            if(comp){
                query += 'AND Compensatory__c = TRUE ';
            }
            query += 'ORDER BY Account__r.Name ';
            system.debug('query: ' + query);
            saList = database.query(query);

            // Sales Account List
            for(Sales_Accounts__c sa : saList)
            {
                aSet.add(sa.Account__c);
                roMap.put(sa.Account__c, 0);
                ooMap.put(sa.Account__c, 0);
                if(sa.Sales_YTD__c != 0){
                    totalSales += sa.Sales_YTD__c;
                    tspPercent = sa.Sales_YTD__c/totalSales*100;
                    tspPercent = tspPercent.setscale(2);
                    tsp.put(sa.Account__r.SAP_Code__c, tspPercent);
                }
                else{
                    tsp.put(sa.Account__r.SAP_Code__c, 0);
                }
            }
            // Open Orders
            for(AggregateResult ar : [SELECT sum(Order_Total__c) cnt, Account__c acct 
                                     FROM Open_Orders__c 
                                     WHERE Account__c =:aSet
                                     GROUP BY Account__c])
            {
                count = (decimal) ar.get('cnt');
                account = (string) ar.get('acct');
                ooMap.put(account, count);
            }
            // Recent Orders
            for(AggregateResult ar : [SELECT sum(Sales__c ) cnt, Account__c acct 
                                      FROM Invoiced_Sales_Detail__c  
                                      WHERE Account__c =:aSet 
                                      AND Territory__c =:tid 
                                      GROUP BY Account__c])
            {
                count = (decimal) ar.get('cnt');
                account = (string) ar.get('acct');
                roMap.put(account, count);
            }

        }
        else{
           redir = TRUE; 
        }
        if(tnumber != NULL){
            oname = 'Sales-Accounts-' + tnumber;
        }
        else{
            oname = 'Sales-Accounts';
        }
    }
    
    public pagereference redirect(){
        if(redir == TRUE){
            string url = '/apex/sales_rosters';
            PageReference redirect = New Pagereference(url);
            redirect.setRedirect(true); 
            return redirect;
        }
        else{
            return NULL;
        }
	
    }

}