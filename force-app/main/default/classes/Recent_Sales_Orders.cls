public class Recent_Sales_Orders {
    
    public list<Invoiced_Sales_Detail__c> roList {get; set;}
    public set<String> tSet {get; set;}
    public Account acct {get; set;}
    public Territory_Master__c tmaster {get; set;}
    public map<Id, Decimal> ooMap {get; set;}
    
    public Id tid {get; set;}
    public Id aid {get; set;}
    public string tnumber {get; set;}
    public String pname {get; set;}
    public boolean openOrders {get; set;}

    public Recent_Sales_Orders(){
        roList = new list<Invoiced_Sales_Detail__c>();
        tmaster = new Territory_Master__c();
        
        tid = ApexPages.currentPage().getParameters().get('id');
        tnumber = [SELECT Territory_Number__c FROM Territory_Master__c where Id =:tid].Territory_Number__c;
        tmaster = [SELECT Business_Unit__c FROM Territory_Master__c where Id =:tid];
        tSet = new set<String>();
        acct = new Account();
        ooMap = new map<Id, Decimal>();

        boolean comp = FALSE;
        string query;
        
        if(tid != NULL){

            if(ApexPages.currentPage().getParameters().get('aid') != NULL){
                aid = ApexPages.currentPage().getParameters().get('aid');

                acct = [SELECT Name, SAP_Code__c FROM Account WHERE Id =:aid];
                
                decimal count;
                string account;
                
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
                
                query = 'SELECT Id, Account__r.SAP_Code__c, Account__r.Name, Account__c, Business_Unit__c, Date__c, Fiscal_Period_Date__c, ';
                query += 'Line_Item_Number__c, Commissionable_Date__c, Fiscal_Period__c, Order_Date__c, ';
                query += 'Order_Number__c, PO_Number__c, Product__c, Product__r.Name, Product__r.Description, Quantity__c, Sales__c, SAP_Code__c, ';
                query += 'Territory__c, Territory_Number__c ';
                query += 'FROM Invoiced_Sales_Detail__c ';
                query += 'WHERE Territory__c =:tid ';
                query += 'AND Account__c =:aid ';
                if(comp){
                    query += 'AND Compensatory__c = TRUE ';
                     
                }
                else{
                    query += 'AND Compensatory__c = FALSE ';
                }
                query += 'ORDER BY Commissionable_Date__c desc';
                system.debug('query: ' + query);
                roList = database.query(query);
                
                for(Invoiced_Sales_Detail__c  ro : roList)
                {
                    tSet.add(ro.Territory_Number__c);
                }  
            }
            else{
                for(Invoiced_Sales_Detail__c  ro : [SELECT Id, Account__r.SAP_Code__c, Account__r.Name, Account__c, Business_Unit__c, Date__c, Fiscal_Period_Date__c, 
                                                    Line_Item_Number__c, Commissionable_Date__c, Fiscal_Period__c, Order_Date__c, 
                                                    Order_Number__c, PO_Number__c, Product__c, Product__r.Name, Product__r.Description, Quantity__c, Sales__c, SAP_Code__c, 
                                                    Territory__c, Territory_Number__c 
                                                    FROM Invoiced_Sales_Detail__c 
                                                    WHERE Territory__c =:tid
                                                    ORDER BY Commissionable_Date__c desc
                                                    LIMIT 10000])
                {
                    roList.add(ro);
                    tSet.add(ro.Territory_Number__c);
                }  
            }
        }
        if(tnumber != NULL){
            pname = 'Recent-Orders-' + tnumber;
        }
        else{
            pname = 'Recent-Orders';
        }
    }
}