//Created by Siva, Schedulable Batch class to update rolling sales for ANZ Target Profiles.
global class ANZTargetProfileRollingSalesBatch implements Database.Batchable<sObject>, Schedulable{
    //Start method of the batch
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String queryStr = 'SELECT Id,Account_Name__c,X12M_CVC_Rolling_Sales_eaches__c,X12M_Needle_Rolling_Sales_eaches__c,';
        queryStr = queryStr + '	X12M_Needle_Rolling_Sales__c,X12M_CVC_Rolling_Sales__c, YTD_Sales_all__c FROM ANZ_Target_Profiles__c';
        
        return Database.getQueryLocator(queryStr);
    }
    //Executemethod of the Batch
    
    global void execute (Database.BatchableContext BC, List<ANZ_Target_Profiles__c> scope)
    {
        Map<String, ANZ_CVC_SKUs__c> ANZ_CVC_SKUs_Map =ANZ_CVC_SKUs__c.getAll();
        Map<String, ANZ_Needle_SKUs__c> ANZ_Needle_SKUs_Map =ANZ_Needle_SKUs__c.getAll();
        Map<String, ANZ_YTD_SKUs__c> ANZ_YTD_SKUs_Map =ANZ_YTD_SKUs__c.getAll();
        
        SET<String> ANZ_CVC_SKU = ANZ_CVC_SKUs_Map.keySet();
        SET<String> ANZ_Needle_SKU = ANZ_Needle_SKUs_Map.keySet();
        SET<String> ANZ_YTD_SKU = ANZ_YTD_SKUs_Map.keySet();
        
        Map<Id, List<ANZ_Target_Profiles__c>> accTPMap = new Map<Id, List<ANZ_Target_Profiles__c>>();
        for(ANZ_Target_Profiles__c atp : scope)
        {
            if(accTPMap.containsKey(atp.Account_Name__c)){
                accTPMap.get(atp.Account_Name__c).add(atp);
            }
            else{
                accTPMap.put(atp.Account_Name__c, new List<ANZ_Target_Profiles__c>{atp});
            }
        } 
        Set<Id> accs = accTPMap.keySet();
        String queryStr = 'SELECT Material_Name__c, SUM(Sales__c) Sales, SUM(Quantity__c) Eaches, Account__c, Date__c FROM Invoiced_Sales__c';
        queryStr = queryStr + ' WHERE Account__c IN:accs AND (Material_Name__c IN: ANZ_CVC_SKU OR Material_Name__c IN: ANZ_Needle_SKU OR Material_Name__c IN: ANZ_YTD_SKU)';
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
        
        List<ANZ_Target_Profiles__c> atpToUpdate = new List<ANZ_Target_Profiles__c>();
        for(Id accountId:accTPMap.keySet()){
            for(ANZ_Target_Profiles__c sourceatp: accTPMap.get(accountId)){
                List<AggregateResult> salesRecords = accSalesmap.get(accountId);
                if(salesRecords != null && salesRecords.size()>0){
                    //Boolean isHospitalRT = sourcetp.RecordTypeId == HospitalRecTypeId ? true : false;
                    // system.debug('*** TargetProfileId *** ' + sourcetp.Id +'*** isHospitalRT *** ' + isHospitalRT);
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
                        
                        
                        Boolean thisYearSale = (system.today().year() == ((date)ar.get('Date__c')).year())? true : false;
                        if(ANZ_YTD_SKU.contains(material) && thisYearSale ){
                            ytdSales = (decimal) ar.get('Sales');
                            totalYtdSales = totalYtdSales + ((ytdSales!= null)?ytdSales:0);
                        }
                    }
                    
                    system.debug('*** ANZTargetProfileId *** ' + sourceatp.Id +' *** totalSales *** ' + totalSales + ' *** totalEaches *** ' + totalEaches);
                    system.debug('*** ANZTargetProfileId *** ' + sourceatp.Id +'*** totalSalesCVC *** ' + totalSalesCVC + ' *** totalEachesCVC *** ' + totalEachesCVC);
                    system.debug('*** ANZTargetProfileId *** ' + sourceatp.Id +'*** totalYtdSales *** ' + totalYtdSales);
                    sourceatp.X12M_Needle_Rolling_Sales__c = totalSales;
                    sourceatp.X12M_Needle_Rolling_Sales_eaches__c  = totalEaches;
                    sourceatp.X12M_CVC_Rolling_Sales__c = totalSalesCVC;
                    sourceatp.X12M_CVC_Rolling_Sales_eaches__c = totalEachesCVC;
                    sourceatp.YTD_Sales_all__c = totalYtdSales;
                    atpToUpdate.add(sourceatp);
                    
                }
            }
        }
        Update atpToUpdate;
    }
    //Finish method of the batch
    global void finish(Database.BatchableContext BC)
    {
        system.debug('ANZTargetProfileRollingSalesBatch completed!');
    }
    
    global void execute(SchedulableContext sc)
    {
        ANZTargetProfileRollingSalesBatch b = new ANZTargetProfileRollingSalesBatch ();
        
        database.executebatch(b,75);
    }
    
}