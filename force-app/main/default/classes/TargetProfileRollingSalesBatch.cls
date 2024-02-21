//Created by Siva, Schedulable Batch class to update rolling sales for Target Profile.
global class TargetProfileRollingSalesBatch implements Database.Batchable<sObject>, Schedulable
{
    //Start method of the batch
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String queryStr = 'SELECT Id, Account__c, RecordTypeId, X12_Month_Rolling_Sales__c, X12_Month_Rolling_Sales_eaches__c,';
        queryStr = queryStr + 'X12_Month_CVC_Rolling_Sales__c, X12_Month_CVC_Rolling_Sales_eaches__c, YTD_Sales__c FROM Target_Profile__c';
        
        return Database.getQueryLocator(queryStr);
    }
    
    //Execute method of the batch
    global void execute(Database.BatchableContext BC, List<Target_Profile__c> scope)
    {
        Map<string, CVC_SKUs__c> CVC_SKU_Map = CVC_SKUs__c.getAll();
        Map<string, Needle_SKUs__c> Needle_SKU_Map = Needle_SKUs__c.getAll();
        Map<string, TP_SKUs__c> TP_SKU_Map = TP_SKUs__c.getAll();
        
        SET<String> CVC_SKU = CVC_SKU_Map.keySet();
        SET<String> Needle_SKU = Needle_SKU_Map.keySet();
        SET<String> TP_SKU = TP_SKU_Map.keySet();
        
        Id HospitalRecTypeId = Schema.getGlobalDescribe().get('Target_Profile__c').getDescribe().getRecordTypeInfosByName().get('Hospital').getRecordTypeId();
        
        Map<Id, List<Target_Profile__c>> accTPMap = new Map<Id, List<Target_Profile__c>>();
        for(Target_Profile__c tp : scope)
        {
            if(accTPMap.containsKey(tp.Account__c)){
                accTPMap.get(tp.Account__c).add(tp);
            }
            else{
                accTPMap.put(tp.Account__c, new List<Target_Profile__c>{tp});
            }
        } 
        Set<Id> accs = accTPMap.keySet();
        
        String queryStr = 'SELECT Material_Name__c, SUM(Sales__c) Sales, SUM(Quantity__c) Eaches, Account__c, Date__c FROM Invoiced_Sales__c';
        queryStr = queryStr + ' WHERE Account__c IN:accs AND (Material_Name__c IN: Needle_SKU OR Material_Name__c IN: CVC_SKU OR Material_Name__c IN: TP_SKU)';
        queryStr = queryStr + ' AND (Date__c = LAST_N_MONTHS:11 OR Date__c = THIS_MONTH) Group By Account__c,Material_Name__c,Date__c'; 
        
        Map<Id, List<AggregateResult>> accSalesmap = new Map<Id, List<AggregateResult>>();
        for(AggregateResult ar : Database.query(queryStr))
        {
            Id accId = (id) ar.get('Account__c');
            if(accSalesmap.containsKey(accId)){
                accSalesmap.get(accId).add(ar);
            }
            else{
                accSalesmap.put(accId, new List<AggregateResult>{ar});
            }
        }
        List<Target_Profile__c> tpToUpdate = new List<Target_Profile__c>();
        for(Id accountId:accTPMap.keySet()){
            for(Target_Profile__c sourcetp: accTPMap.get(accountId)){
                List<AggregateResult> salesRecords = accSalesmap.get(accountId);
                if(salesRecords != null && salesRecords.size()>0){
                    Boolean isHospitalRT = sourcetp.RecordTypeId == HospitalRecTypeId ? true : false;
                    system.debug('*** TargetProfileId *** ' + sourcetp.Id +'*** isHospitalRT *** ' + isHospitalRT);
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
                    for(AggregateResult ar : salesRecords){
                        material = (string) ar.get('Material_Name__c');
                        if(!isHospitalRT && !Needle_SKU_Map.containsKey(material)){
                            system.debug('CVC SKU not applicable for Pre-Hospital: '+material);
                        }
                        else{
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
                        }
                        Boolean thisYearSale = (system.today().year() == ((date)ar.get('Date__c')).year())? true : false;
                        if(TP_SKU_Map.containsKey(material) && thisYearSale ){
                            ytdSales = (decimal) ar.get('Sales');
                            totalYtdSales = totalYtdSales + ((ytdSales!= null)?ytdSales:0);
                        }
                    }
                    
                    system.debug('*** TargetProfileId *** ' + sourcetp.Id +' *** totalSales *** ' + totalSales + ' *** totalEaches *** ' + totalEaches);
                    system.debug('*** TargetProfileId *** ' + sourcetp.Id +'*** totalSalesCVC *** ' + totalSalesCVC + ' *** totalEachesCVC *** ' + totalEachesCVC);
                    system.debug('*** TargetProfileId *** ' + sourcetp.Id +'*** totalYtdSales *** ' + totalYtdSales);
                    sourcetp.X12_Month_Rolling_Sales__c = totalSales;
                    sourcetp.X12_Month_Rolling_Sales_eaches__c  = totalEaches;
                    sourcetp.X12_Month_CVC_Rolling_Sales__c = totalSalesCVC;
                    sourcetp.X12_Month_CVC_Rolling_Sales_eaches__c = totalEachesCVC;
                    sourcetp.YTD_Sales__c = totalYtdSales;
                    tpToUpdate.add(sourcetp);
                }
            }
        }
        Update tpToUpdate;
    }
    
    //Finish method of the batch
    global void finish(Database.BatchableContext BC)
    {
        system.debug('TargetProfileRollingSalesBatch completed!');
    }
    
    //Execute method of the Schedulable class
    global void execute(SchedulableContext sc)
    {
        TargetProfileRollingSalesBatch b = new TargetProfileRollingSalesBatch ();
        
        database.executebatch(b,15);
    }
}