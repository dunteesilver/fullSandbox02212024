public class open_Orders {
    
    public list<Sales_Accounts__c> saList {get; set;}
    public list<Open_Orders__c> ooList {get; set;}
    public map<Id, Decimal> roMap {get; set;}
    public Account acct {get; set;}
    public Territory_Master__c tmaster {get; set;}
    public Id tid {get; set;}
    public string tnumber {get; set;}
    public Id aid {get; set;}
    public String oname {get; set;}
    public boolean recentOrders {get; set;}
    
    public open_Orders(){
        saList = new list<Sales_Accounts__c>();
        ooList = new list<Open_Orders__c>();
        roMap = new map<Id, Decimal>();
        acct = new Account();
        tmaster = new Territory_Master__c();
        set<Id> aSet = new set<Id>();
        recentOrders = FALSE;
        
        if(ApexPages.currentPage().getParameters().get('id') != NULL){
            tid = ApexPages.currentPage().getParameters().get('id');
            tnumber = [SELECT Territory_Number__c FROM Territory_Master__c where Id =:tid].Territory_Number__c;
            tmaster = [SELECT Business_Unit__c FROM Territory_Master__c where Id =:tid];

            if(ApexPages.currentPage().getParameters().get('aid') != NULL){
                aid = ApexPages.currentPage().getParameters().get('aid');
                
                decimal count;
                string account;
                
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

                acct = [SELECT Id, Name, SAP_Code__c FROM Account WHERE Id =:aid]; 

                for(Sales_Accounts__c sa : [SELECT Account__c  
                                            FROM Sales_Accounts__c 
                                            WHERE Territory__c =:tid
                                            AND Account__c =:aid])
                {
                    aSet.add(sa.Account__c);
                }
            }
            else{
                for(Sales_Accounts__c sa : [SELECT Account__c  
                                            FROM Sales_Accounts__c 
                                            WHERE Territory__c =:tid])
                {
                    aSet.add(sa.Account__c);
                } 
            }
            
            
            for(Open_Orders__c oo : [SELECT Id, Account__r.Name, Account__r.SAP_Code__c, PO_Number__c, Order_Number__c, Order_Date__c, 
                                     Back_Order_Qty__c, Back_Order_Total__c, Back_Ordered__c, Future_Order_Qty__c, Future_Order_Total__c, 
                                     Open_Order_Total__c, Open_Order_Qty__c, Product__r.Name, Product__r.Description, Product__c, 
                                     Scheduled_Ship_Date__c, Territory_Number__c, Territory__c, Line_Item_Number__c  
                                     FROM Open_Orders__c 
                                     WHERE Account__c =:aSet])
            {
                ooList.add(oo);
            }
        }
        else{
            for(Open_Orders__c oo : [SELECT Id, Account__r.Name, Account__r.SAP_Code__c, PO_Number__c, Order_Number__c, Order_Date__c, 
                                     Back_Order_Qty__c, Back_Order_Total__c, Back_Ordered__c, Future_Order_Qty__c, Future_Order_Total__c, 
                                     Open_Order_Total__c, Open_Order_Qty__c, Product__r.Name, Product__r.Description, Product__c, 
                                     Scheduled_Ship_Date__c, Territory_Number__c, Territory__c, Line_Item_Number__c     
                                     FROM Open_Orders__c WHERE Back_Ordered__c = TRUE 
                                     LIMIT 10000])
            {
                ooList.add(oo);
            }
        }
        if(tnumber != NULL && acct.SAP_Code__c != NULL){
            oname = 'Open-Orders-' + tnumber + '-' + acct.SAP_Code__c;
        }
        else if(tnumber != NULL){
            oname = 'Open-Orders-' + tnumber;
        }
        else{
            oname = 'Open-Orders';
        }
        
    }

}