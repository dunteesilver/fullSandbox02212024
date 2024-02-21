public without sharing class updateRollingSales {
    /**************************** Start Target Profile Rolling 12 Months *****************************/
    //Added By Siva on Mar 22, 2019 to provide sales data to component
    @AuraEnabled
    public static List<wrapperClass> updateRollingSales(Id targetId){
        Map<string, CVC_SKUs__c> CVC_SKU_Map = CVC_SKUs__c.getAll();
        Map<string, Needle_SKUs__c> Needle_SKU_Map = Needle_SKUs__c.getAll();
        Map<string, TP_SKUs__c> TP_SKU_Map = TP_SKUs__c.getAll();
        
        SET<String> CVC_SKU = CVC_SKU_Map.keySet();
        SET<String> Needle_SKU = Needle_SKU_Map.keySet();
        SET<String> TP_SKU = TP_SKU_Map.keySet();

        system.debug('-- Start the Needle & CVC Sales - updateRollingSales --');
        system.debug('*** targetId *** ' + targetId);
        system.debug('*** CVC_SKU *** ' + CVC_SKU);
        system.debug('*** Needle_SKU *** ' + Needle_SKU);
        system.debug('*** TP_SKU *** ' + TP_SKU);
        Id HospitalRecTypeId = Schema.getGlobalDescribe().get('Target_Profile__c').getDescribe().getRecordTypeInfosByName().get('Hospital').getRecordTypeId();
        
		Target_Profile__c sourcetp = [SELECT Id, Account__c, RecordTypeId, X12_Month_Rolling_Sales__c, X12_Month_Rolling_Sales_eaches__c,
                                       X12_Month_CVC_Rolling_Sales__c, X12_Month_CVC_Rolling_Sales_eaches__c, YTD_Sales__c 
                                FROM Target_Profile__c
                                WHERE Id =:targetId];
        Boolean isHospitalRT = sourcetp.RecordTypeId == HospitalRecTypeId ? true : false;
        system.debug('*** isHospitalRT *** ' + isHospitalRT);
        
        Map<String, wrapperClass> rollingSalesMap = new Map<String, wrapperClass>();
        if(sourcetp != null){
            String accountId = sourcetp.Account__c;
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
            
            if(isHospitalRT){
                //queryStr = queryStr + ' AND Material_Name__c IN: CVC_SKU';
               queryStr = queryStr + ' AND (Material_Name__c IN: CVC_SKU';
               queryStr = queryStr + ' OR Material_Name__c IN: Needle_SKU OR Material_Name__c IN: TP_SKU)';
               //queryStr = queryStr + ' AND Material_Name__c IN: Needle_SKU';
            }
            else{
               queryStr = queryStr + ' AND (Material_Name__c IN: Needle_SKU OR Material_Name__c IN: TP_SKU)';
            }
            queryStr = queryStr + ' AND (Date__c = LAST_N_MONTHS:11 OR Date__c = THIS_MONTH) Group By Material_Name__c, Date__c'; 
            system.debug('*** queryStr *** ' + queryStr);
            for(AggregateResult ar : Database.query(queryStr))
            {
                material = (string) ar.get('Material_Name__c');
                if((isHospitalRT && CVC_SKU_Map.containsKey(material) && CVC_SKU_Map.get(material).Exempted__c) || (!isHospitalRT && Needle_SKU_Map.containsKey(material) && Needle_SKU_Map.get(material).Exempted__c)){
                    system.debug('Exempted SKU:'+material);
                }
                else{
                    system.debug('Non-Exempted SKU:'+material);
                    if(Needle_SKU.contains(material)){
                        sales = (decimal) ar.get('Sales');
                        eaches = (decimal) ar.get('Eaches');
                        totalSales = totalSales + ((sales!= null)?sales:0);
                        totalEaches = totalEaches + ((eaches!= null)?eaches:0);
                    }
                    else{
                        salesCVC = (decimal) ar.get('Sales');
                        eachesCVC = (decimal) ar.get('Eaches');
                        totalSalesCVC = totalSalesCVC + ((salesCVC!= null)?salesCVC:0);
                        totalEachesCVC = totalEachesCVC + ((eachesCVC!= null)?eachesCVC:0);
                    }
                }
                If(material == '9058'|| Needle_SKU_Map.containsKey(material) 
                   || !(TP_SKU_Map.containsKey(material) || CVC_SKU_Map.containsKey(material)) 
                   || (CVC_SKU_Map.containsKey(material) && CVC_SKU_Map.get(material).Exempted__c)){
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
                if(TP_SKU_Map.containsKey(material) && thisYearSale ){
                    system.debug('YTD SKU:'+material);
                    ytdSales = (decimal) ar.get('Sales');
                    totalYtdSales = totalYtdSales + ((ytdSales!= null)?ytdSales:0);
                }
                
            }
            system.debug('*** totalSales *** ' + totalSales + ' *** totalEaches *** ' + totalEaches);
            system.debug('*** totalSalesCVC *** ' + totalSalesCVC + ' *** totalEachesCVC *** ' + totalEachesCVC);
            system.debug('*** totalYtdSales *** ' + totalYtdSales);
                    
            Target_Profile__c tp = new Target_Profile__c(
                Id = targetId, X12_Month_Rolling_Sales__c = totalSales, X12_Month_Rolling_Sales_eaches__c  = totalEaches,
                X12_Month_CVC_Rolling_Sales__c = totalSalesCVC, X12_Month_CVC_Rolling_Sales_eaches__c = totalEachesCVC,
                YTD_Sales__c = totalYtdSales
            );
            
            Database.update(tp,false);
        }
        //return rollingSales;
        return rollingSalesMap.values();
    }//end of updateRollingSalesMethod
    /**************************** End Target Profile Rolling 12 Months *****************************/
    
    
    /**************************** Start Target Profile Specific Year Needle Sales Called from Trigger *****************************/
    public void getNeedleSales(List<Target_Profile__c> triggerNew){
        system.debug('*** Start the Needle Sales - specificYearNeedleSales ***');
        Id HospitalRecTypeId = Schema.getGlobalDescribe().get('Target_Profile__c').getDescribe().getRecordTypeInfosByName().get('Hospital').getRecordTypeId();
        //loop thru and pass Ids
        for(Target_Profile__c curr : triggerNew){
            if(curr.Do_Not_Run_Trigger__c == FALSE && curr.Account__c != Null){
                updateRollingSales.specificYearNeedleSales(curr.Id);
                if(curr.RecordTypeId == HospitalRecTypeId){
                    updateRollingSales.specificYearCVCSales(curr.Id);
                }
            }//end if
        }//end of for loop 
        
    }
    /**************************** End Target Profile Specific Year Needle Sales Called from Trigger *****************************/
    
    /**************************** Start Target Profile Specific Year Needle Sales *****************************/
    //Added By Dun Silver on Jan 28, 2019 to provide update sales button
    public static void specificYearNeedleSales(Id targetId){
        Map<string, Needle_SKUs__c> Needle_SKU_Map = Needle_SKUs__c.getAll();
        SET<String> Needle_SKU = Needle_SKU_Map.keySet();
        
        system.debug('*** Start the Needle Sales - specificYearNeedleSales ***');
        system.debug('*** targetId *** ' + targetId);
        Integer currentYear = System.Today().year();
        Integer previousYear = currentYear -1;
        Integer previous2Year = currentYear - 2;
        Map<String,Target_Profile__c> taMap = new Map<String,Target_Profile__c>();
        List<Target_Profile__c> listToUpdate = new List<Target_Profile__c>();
        List<Id> acctIds = new List<Id>();
        //system.debug('*** targetId *** ' + targetId);
        //system.debug('*** accountId *** ' + accountId);
        Target_Profile__c sourcetp = [SELECT Id, Account__c
                                      FROM Target_Profile__c
                                      WHERE Id = :targetId];
        
        List<AggregateResult> rollingSalesList = new List<AggregateResult>();
        if(sourcetp != NULL ){
            //String accountId = sourcetp.Account__c;
            String material;
            String acctId = sourcetp.Account__c;
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
                                      And (Material_Name__c IN: Needle_SKU) 
                                      AND CALENDAR_YEAR(Date__c) = :previous2year
                                      Group By Material_Name__c])
            {
                material = (string) ar.get('Material_Name__c');
                if(Needle_SKU_Map.containsKey(material) && Needle_SKU_Map.get(material).Exempted__c){
                    system.debug('Exempted SKU:'+material);
                }
                else{
                    if( (decimal) ar.get('Sales') != NULL ){
                        sales2 = (decimal) ar.get('Sales');
                        totalSales2 = totalSales2 + sales2;
                    }
                    
                    if( (decimal) ar.get('Eaches') != NULL ){
                        eaches2 = (decimal) ar.get('Eaches');
                        totalEaches2 = totalEaches2 + eaches2;
                    }
                }
                
            }
            system.debug('*** totalSales2 *** ' + totalSales2 + ' *** totalEaches2 *** ' + totalEaches2);
            //system.debug('*** salesObjTop.prodKeyList *** ' + salesObjTop.prodKeyList);
            
            //Database.update(tp,false);
            for(AggregateResult ar : [SELECT Material_Name__c, SUM(Sales__c) Sales, SUM(Quantity__c) Eaches
                                      FROM Invoiced_Sales__c
                                      WHERE Account__c = :acctId
                                      And (Material_Name__c IN: Needle_SKU) 
                                      AND CALENDAR_YEAR(Date__c) = :previousYear
                                      Group By Material_Name__c])
            {
                material = (string) ar.get('Material_Name__c');
                if(Needle_SKU_Map.containsKey(material) && Needle_SKU_Map.get(material).Exempted__c){
                    system.debug('Exempted SKU:'+material);
                }
                else{
                    if( (decimal) ar.get('Sales') != NULL ){
                        sales = (decimal) ar.get('Sales');
                        totalSales = totalSales + sales;
                    }
                    
                    if( (decimal) ar.get('Eaches') != NULL ){
                        eaches = (decimal) ar.get('Eaches');
                        totalEaches = totalEaches + eaches;
                    }
                }
            }
            system.debug('*** totalSales *** ' + totalSales + ' *** totalEaches *** ' + totalEaches);
            
            Target_Profile__c tp = new Target_Profile__c(
                Id = targetId, Sales_2_Years_Ago__c = totalSales2, Eaches_2_Years_Ago__c  = totalEaches2,
                Last_Year_Sales__c = totalSales, Last_Year_Eaches__c = totalEaches, Do_Not_Run_Trigger__c = TRUE
            );
            listToUpdate.add(tp);
        }
        //return rollingSales;
        system.debug('*** listToUpdate.size() *** ' + listToUpdate.size() );
        system.debug('*** listToUpdate *** ' + listToUpdate );
        if( listToUpdate.size() > 0 ){
            Database.update(listToUpdate,FALSE);
        }
        
    }//end of updateRollingSalesMethod
    /**************************** End Target Profile Specific Year Needle Sales *****************************/
    
    /**************************** Start Target Profile Specific Year CVC Sales *****************************/
    //Added By Siva on Mar 20, 2019 to provide update sales button
    public static void specificYearCVCSales(Id targetId){
        Map<string, CVC_SKUs__c> CVC_SKU_Map = CVC_SKUs__c.getAll();
        SET<String> CVC_SKU = CVC_SKU_Map.keySet();
        
        system.debug('*** Start the Needle Sales - specificYearNeedleSales ***');
        system.debug('*** targetId *** ' + targetId);
        Integer currentYear = System.Today().year();
        Integer previousYear = currentYear -1;
        Integer previous2Year = currentYear - 2;
        Map<String,Target_Profile__c> taMap = new Map<String,Target_Profile__c>();
        List<Target_Profile__c> listToUpdate = new List<Target_Profile__c>();
        List<Id> acctIds = new List<Id>();
        //system.debug('*** targetId *** ' + targetId);
        //system.debug('*** accountId *** ' + accountId);
        Target_Profile__c sourcetp = [SELECT Id, Account__c
                                      FROM Target_Profile__c
                                      WHERE Id = :targetId];
        
        List<AggregateResult> rollingSalesList = new List<AggregateResult>();
        if(sourcetp != NULL ){
            //String accountId = sourcetp.Account__c;
            String material;
            String acctId = sourcetp.Account__c;
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
                                      And (Material_Name__c IN: CVC_SKU) 
                                      AND CALENDAR_YEAR(Date__c) = :previous2year
                                      Group By Material_Name__c])
            {
                material = (string) ar.get('Material_Name__c');
                if(CVC_SKU_Map.containsKey(material) && CVC_SKU_Map.get(material).Exempted__c){
                    system.debug('Exempted SKU:'+material);
                }
                else{
                    if( (decimal) ar.get('Sales') != NULL ){
                        sales2 = (decimal) ar.get('Sales');
                        totalSales2 = totalSales2 + sales2;
                    }
                    
                    if( (decimal) ar.get('Eaches') != NULL ){
                        eaches2 = (decimal) ar.get('Eaches');
                        totalEaches2 = totalEaches2 + eaches2;
                    }
                }
                
            }
            system.debug('*** totalSales2 *** ' + totalSales2 + ' *** totalEaches2 *** ' + totalEaches2);
            //system.debug('*** salesObjTop.prodKeyList *** ' + salesObjTop.prodKeyList);
            
            //Database.update(tp,false);
            for(AggregateResult ar : [SELECT Material_Name__c, SUM(Sales__c) Sales, SUM(Quantity__c) Eaches
                                      FROM Invoiced_Sales__c
                                      WHERE Account__c = :acctId
                                      And (Material_Name__c IN: CVC_SKU) 
                                      AND CALENDAR_YEAR(Date__c) = :previousYear
                                      Group By Material_Name__c])
            {
                material = (string) ar.get('Material_Name__c');
                if(CVC_SKU_Map.containsKey(material) && CVC_SKU_Map.get(material).Exempted__c){
                    system.debug('Exempted SKU:'+material);
                }
                else{
                    if( (decimal) ar.get('Sales') != NULL ){
                        sales = (decimal) ar.get('Sales');
                        totalSales = totalSales + sales;
                    }
                    
                    if( (decimal) ar.get('Eaches') != NULL ){
                        eaches = (decimal) ar.get('Eaches');
                        totalEaches = totalEaches + eaches;
                    }
                }
                
            }
            system.debug('*** totalSales *** ' + totalSales + ' *** totalEaches *** ' + totalEaches);
            
            Target_Profile__c tp = new Target_Profile__c(
                Id = targetId, Sales_2_Years_Ago_CVC__c  = totalSales2, Eaches_2_Years_Ago_CVC__c  = totalEaches2,
                Last_Year_Sales_CVC__c = totalSales, Last_Year_Eaches_CVC__c  = totalEaches, Do_Not_Run_Trigger__c = TRUE
            );
            listToUpdate.add(tp);
        }
        //return rollingSales;
        system.debug('*** listToUpdate.size() *** ' + listToUpdate.size() );
        system.debug('*** listToUpdate *** ' + listToUpdate );
        if( listToUpdate.size() > 0 ){
            Database.update(listToUpdate,FALSE);
        }
        
    }//end of updateRollingSalesMethod
    /**************************** End Target Profile Specific Year CVC Sales *****************************/
    
    // wrapper or Inner class with @AuraEnabled {get;set;} properties*    
    public class wrapperClass{
        @AuraEnabled public String MaterialName{get;set;}
        @AuraEnabled public Decimal Sales {get;set;}
        @AuraEnabled public Decimal Eaches {get;set;}
    } 
}