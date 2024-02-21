public class UpdateANZRollingSales {
    /**************************** Start Target Profile Rolling 12 Months *****************************/
    //Added By Siva on Mar 22, 2019 to provide sales data to component
    @AuraEnabled
public static List<wrapperClass> updateANZRollingSales(Id ANZtargetId){
Map<string, ANZ_CVC_SKUs__c> 	ANZ_CVC_SKU_Map = ANZ_CVC_SKUs__c.getAll();
Map<string, ANZ_Needle_SKUs__c> ANZ_Needle_SKU_Map = ANZ_Needle_SKUs__c.getAll();
Map<string, ANZ_YTD_SKUs__c> ANZ_YTD_SKU_Map = ANZ_YTD_SKUs__c.getAll();

SET<String> ANZ_CVC_SKU = ANZ_CVC_SKU_Map.keySet();
SET<String> ANZ_Needle_SKU = ANZ_Needle_SKU_Map.keySet();
SET<String> ANZ_YTD_SKU = ANZ_YTD_SKU_Map.keySet();

system.debug('-- Start the Needle & CVC Sales - updateRollingSales --');
system.debug('*** ANZtargetId *** ' + ANZtargetId);
system.debug('*** CVC_SKU *** ' + ANZ_CVC_SKU);
system.debug('*** Needle_SKU *** ' + ANZ_Needle_SKU);
system.debug('*** YTD_SKU *** ' + ANZ_YTD_SKU);
//Id HospitalRecTypeId = Schema.getGlobalDescribe().get('Target_Profile__c').getDescribe().getRecordTypeInfosByName().get('Hospital').getRecordTypeId();

ANZ_Target_Profiles__c sourceatp = [SELECT Id, Account_Name__c,X12M_CVC_Rolling_Sales_eaches__c,X12M_CVC_Rolling_Sales__c, X12M_Needle_Rolling_Sales__c,
X12M_Needle_Rolling_Sales_eaches__c, YTD_Sales_all__c 
FROM ANZ_Target_Profiles__c
WHERE Id =:ANZtargetId];
//Boolean isHospitalRT = sourcetp.RecordTypeId == HospitalRecTypeId ? true : false;
//system.debug('*** isHospitalRT *** ' + isHospitalRT);

Map<String, wrapperClass> rollingSalesMap = new Map<String, wrapperClass>();
if(sourceatp != null){
String accountId = sourceatp.Account_Name__c;
String material;
Decimal sales = 0;
Decimal eaches = 0;
Decimal totalSales = 0;
Decimal totalEaches = 0;
Decimal salesCVC = 0;
Decimal eachesCVC = 0;
Decimal totalSalesCVC = 0;
Decimal totalEachesCVC = 0;
Decimal ytdSales = 0;
Decimal totalYtdSales = 0;

String queryStr = 'SELECT Material_Name__c, SUM(Sales__c) Sales, SUM(Quantity__c) Eaches, Date__c FROM Invoiced_Sales__c';
queryStr = queryStr + ' WHERE Account__c =:accountId';


queryStr = queryStr + ' AND (Material_Name__c IN: ANZ_CVC_SKU';
queryStr = queryStr + ' OR Material_Name__c IN: ANZ_Needle_SKU OR Material_Name__c IN: ANZ_YTD_SKU)';



queryStr = queryStr + ' AND (Date__c = LAST_N_MONTHS:11 OR Date__c = THIS_MONTH) Group By Material_Name__c, Date__c'; 
system.debug('*** queryStr *** ' + queryStr);
for(AggregateResult ar : Database.query(queryStr))
{
material = (string) ar.get('Material_Name__c');


if(ANZ_Needle_SKU.contains(material)){
sales = (decimal) ar.get('Sales');
eaches = (decimal) ar.get('Eaches');
totalSales = totalSales + ((sales!= null)?sales:0);
totalEaches = totalEaches + ((eaches!= null)?eaches:0);
}
else if(ANZ_CVC_SKU.contains(material)){
salesCVC = (decimal) ar.get('Sales');
eachesCVC = (decimal) ar.get('Eaches');
totalSalesCVC = totalSalesCVC + ((salesCVC!= null)?salesCVC:0);
totalEachesCVC = totalEachesCVC + ((eachesCVC!= null)?eachesCVC:0);
}

If( ANZ_Needle_SKU_Map.containsKey(material) || ANZ_CVC_SKU_Map.containsKey(material)){
wrapperClass data;
if(rollingSalesMap.containsKey(material)){
data = rollingSalesMap.get(material);
data.Sales += (decimal) ar.get('Sales');
data.Eaches += (decimal) ar.get('Eaches');
}
else{
data = new wrapperClass();
data.MaterialName = material;
data.Sales = (decimal) ar.get('Sales');
data.Eaches = (decimal) ar.get('Eaches');
}
rollingSalesMap.put(material, data);
}

Boolean thisYearSale = (system.today().year() == ((date)ar.get('Date__c')).year())? true : false;
if(ANZ_YTD_SKU_Map.containsKey(material) && thisYearSale ){
system.debug('YTD SKU:'+material);
ytdSales = (decimal) ar.get('Sales');
totalYtdSales = totalYtdSales + ((ytdSales!= null)?ytdSales:0);
}

}
system.debug('*** totalSales *** ' + totalSales + ' *** totalEaches *** ' + totalEaches);
system.debug('*** totalSalesCVC *** ' + totalSalesCVC + ' *** totalEachesCVC *** ' + totalEachesCVC);
system.debug('*** totalYtdSales *** ' + totalYtdSales);

ANZ_Target_Profiles__c atp = new ANZ_Target_Profiles__c(
Id = ANZtargetId, X12M_Needle_Rolling_Sales__c = totalSales, X12M_Needle_Rolling_Sales_eaches__c  = totalEaches,X12M_CVC_Rolling_Sales__c = totalSalesCVC,
X12M_CVC_Rolling_Sales_eaches__c = totalEachesCVC,YTD_Sales_all__c = totalYtdSales

);

Database.update(atp,false);
}
//return rollingSales;
return rollingSalesMap.values();
}//end of updateRollingSalesMethod
    /**************************** End Target Profile Rolling 12 Months *****************************/
    
   /**************************** Start Target Profile Specific Year Needle Sales Called from Trigger *****************************/
    public void getNeedleSales(List<ANZ_Target_Profiles__c> triggerNew){
        system.debug('*** Start the Needle Sales - specificYearNeedleSales ***');
        
        //loop thru and pass Ids
        
        for(ANZ_Target_Profiles__c curr : triggerNew){
            if(curr.Do_Not_Run_Trigger__c == FALSE && curr.Account_Name__c != Null){
                
                {
                    
                    updateANZRollingSales.specificYearNeedleSales(curr.Id);
                    updateANZRollingSales.specificYearCVCSales(curr.Id);
                }
                
                
                
            }//end if
        }//end of for loop 
        
    }
    
    
    /**************************** Start Target Profile Specific Year Needle Sales *****************************/
    
    public static void specificYearNeedleSales(Id ANZTargetId){
        Map<string, ANZ_Needle_SKUs__c> ANZ_Needle_SKU_Map = ANZ_Needle_SKUs__c.getAll();
        SET<String> ANZ_Needle_SKU = ANZ_Needle_SKU_Map.keySet();
        
        system.debug('*** Start the Needle Sales - specificYearNeedleSales ***');
        system.debug('*** ANZtargetId *** ' + ANZTargetId);
        Integer currentYear = System.Today().year();
        Integer previousYear = currentYear -1;
        Integer previous2Year = currentYear - 2;
        Map<String,ANZ_Target_Profiles__c> ataMap = new Map<String,ANZ_Target_Profiles__c>();
        List<ANZ_Target_Profiles__c> listToUpdate = new List<ANZ_Target_Profiles__c>();
        List<Id> acctIds = new List<Id>();
        //system.debug('*** ANZtargetId *** ' + ANZtargetId);
        //system.debug('*** accountId *** ' + accountId);
        ANZ_Target_Profiles__c sourceatp = [SELECT Id, Account_Name__c
                                            FROM ANZ_Target_Profiles__c
                                            WHERE Id = :ANZTargetId];
        
        
        List<AggregateResult> rollingSalesList = new List<AggregateResult>();
        if(sourceatp != NULL ){
            //String accountId = sourcetp.Account_Name__c;
            String material;
            String acctId = sourceatp.Account_Name__c;
            Decimal sales = 0;
            Decimal eaches = 0;
            Decimal totalSales = 0;
            Decimal totalEaches = 0;
            
            Decimal sales2 = 0;
            Decimal eaches2 = 0;
            Decimal totalSales2 = 0;
            Decimal totalEaches2 = 0;
            
            
            for(AggregateResult ar : [SELECT Material_Name__c, SUM(Sales__c) Sales, SUM(Quantity__c) Eaches
                                      FROM Invoiced_Sales__c
                                      WHERE Account__c = :acctId
                                      And (Material_Name__c IN: ANZ_Needle_SKU) 
                                      AND CALENDAR_YEAR(Date__c) = :previous2year
                                      Group By Material_Name__c])
                
            {
                {
                    
                    if( (decimal) ar.get('Sales') != NULL ){
                        sales2 = (decimal) ar.get('Sales');
                        totalSales2 = totalSales2 + sales2;
                    }
                    
                    if( (decimal) ar.get('Eaches') != NULL ){
                        eaches2 = (decimal) ar.get('Eaches');
                        totalEaches2 = totalEaches2 + eaches2;
                    }
                    
                    
                }
                system.debug('*** totalSales2 *** ' + totalSales2 + ' *** totalEaches2 *** ' + totalEaches2);
            }
            
            for(AggregateResult ar : [SELECT Material_Name__c, SUM(Sales__c) Sales, SUM(Quantity__c) Eaches
                                      FROM Invoiced_Sales__c
                                      WHERE Account__c = :acctId
                                      And (Material_Name__c IN: ANZ_Needle_SKU) 
                                      AND CALENDAR_YEAR(Date__c) = :previousYear
                                      Group By Material_Name__c])
            {
                
                if( (decimal) ar.get('Sales') != NULL ){
                    sales = (decimal) ar.get('Sales');
                    totalSales = totalSales + sales;
                }
                
                if( (decimal) ar.get('Eaches') != NULL ){
                    eaches = (decimal) ar.get('Eaches');
                    totalEaches = totalEaches + eaches ;
                }
                
            }
            system.debug('*** totalSales *** ' + totalSales + ' *** totalEaches *** ' + totalEaches);       
            ANZ_Target_Profiles__c atp = new ANZ_Target_Profiles__c(
                Id = ANZtargetId, 	Sales_2_Years_Ago_Needles__c = totalSales2, Eaches_2_Years_Ago_Needles__c  = totalEaches2,
                Last_Year_Sales_Needles__c = totalSales, 	Last_Year_Eaches_Needles__c = totalEaches,Do_Not_Run_Trigger__c = TRUE
            );
            listToUpdate.add(atp);
        }
        //return rollingSales;
        system.debug('*** listToUpdate.size() *** ' + listToUpdate.size() );
        system.debug('*** listToUpdate *** ' + listToUpdate );
        if( listToUpdate.size() > 0 ){
            Database.update(listToUpdate,FALSE);
        }      
        
        
    }
    /**************************** Start Target Profile Specific Year CVC Sales *****************************/
    
    public static void specificYearCVCSales(Id ANZTargetId){
        Map<string, ANZ_CVC_SKUs__c> ANZ_CVC_SKU_Map = ANZ_CVC_SKUs__c.getAll();
        SET<String> ANZ_CVC_SKU = ANZ_CVC_SKU_Map.keySet();
        
        system.debug('*** Start the Needle Sales - specificYearNeedleSales ***');
        system.debug('*** ANZtargetId *** ' + ANZTargetId);
        Integer currentYear = System.Today().year();
        Integer previousYear = currentYear -1;
        Integer previous2Year = currentYear - 2;
        Map<String,ANZ_Target_Profiles__c> ataMap = new Map<String,ANZ_Target_Profiles__c>();
        List<ANZ_Target_Profiles__c> listToUpdate = new List<ANZ_Target_Profiles__c>();
        List<Id> acctIds = new List<Id>();
        //system.debug('*** ANZtargetId *** ' + ANZtargetId);
        //system.debug('*** accountId *** ' + accountId);
        ANZ_Target_Profiles__c sourceatp = [SELECT Id, Account_Name__c
                                            FROM ANZ_Target_Profiles__c
                                            WHERE Id = :ANZTargetId];
        
        
        List<AggregateResult> rollingSalesList = new List<AggregateResult>();
        if(sourceatp != NULL ){
            //String accountId = sourcetp.Account_Name__c;
            String material;
            String acctId = sourceatp.Account_Name__c;
            Decimal sales = 0;
            Decimal eaches = 0;
            Decimal totalSales = 0;
            Decimal totalEaches = 0;
            
            Decimal sales2 = 0;
            Decimal eaches2 = 0;
            Decimal totalSales2 = 0;
            Decimal totalEaches2 = 0;
            
            
            for(AggregateResult ar : [SELECT Material_Name__c, SUM(Sales__c) Sales, SUM(Quantity__c) Eaches
                                      FROM Invoiced_Sales__c
                                      WHERE Account__c = :acctId
                                      And (Material_Name__c IN: ANZ_CVC_SKU) 
                                      AND CALENDAR_YEAR(Date__c) = :previous2year
                                      Group By Material_Name__c])
                
            {
                
                if( (decimal) ar.get('Sales') != NULL ){
                    sales2 = (decimal) ar.get('Sales');
                    totalSales2 = totalSales2 + sales2;
                }
                
                if( (decimal) ar.get('Eaches') != NULL ){
                    eaches2 = (decimal) ar.get('Eaches');
                    totalEaches2 = totalEaches2 + eaches2;
                }
                
                
            }
            system.debug('*** totalSales2 *** ' + totalSales2 + ' *** totalEaches2 *** ' + totalEaches2);
            
            
            for(AggregateResult ar : [SELECT Material_Name__c, SUM(Sales__c) Sales, SUM(Quantity__c) Eaches
                                      FROM Invoiced_Sales__c
                                      WHERE Account__c = :acctId
                                      And (Material_Name__c IN: ANZ_CVC_SKU) 
                                      AND CALENDAR_YEAR(Date__c) = :previousYear
                                      Group By Material_Name__c])
            {
                
                if( (decimal) ar.get('Sales') != NULL ){
                    sales = (decimal) ar.get('Sales');
                    totalSales = totalSales + sales;
                }
                
                if( (decimal) ar.get('Eaches') != NULL ){
                    eaches = (decimal) ar.get('Eaches');
                    totalEaches = totalEaches + eaches;
                }
                
            }
            system.debug('*** totalSales *** ' + totalSales + ' *** totalEaches *** ' + totalEaches);       
            ANZ_Target_Profiles__c atp = new ANZ_Target_Profiles__c(
                Id = ANZtargetId, 	Sales_2_Years_Ago_CVC__c=totalSales2,Eaches_2_Years_Ago_CVC__c=totalEaches2,	
                Last_Year_Eaches_CVC__c = totalEaches,Last_Year_Sales_CVC__c = totalSales,Do_Not_Run_Trigger__c = TRUE
            );
            listToUpdate.add(atp);
        }
        //return rollingSales;
        system.debug('*** listToUpdate.size() *** ' + listToUpdate.size() );
        system.debug('*** listToUpdate *** ' + listToUpdate );
        if( listToUpdate.size() > 0 ){
            Database.update(listToUpdate,FALSE);
        }      
        
        
    } 
    // wrapper or Inner class with @AuraEnabled {get;set;} properties*    
    public class wrapperClass{
        @AuraEnabled public String MaterialName{get;set;}
        @AuraEnabled public Decimal Sales {get;set;}
        @AuraEnabled public Decimal Eaches {get;set;}
    }  
    
}