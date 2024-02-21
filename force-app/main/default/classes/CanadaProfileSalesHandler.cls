public class CanadaProfileSalesHandler {
   /*
* this method is invoked from Master_Canada_Trigger to calculate rolling 12 months,YTD,Last Year sales for different Group__c types. 
*/
    public static void rollingInvSalesFrmCanTgr(List<Canada_Profile__c> canObjLst) {
        
        //initializations...
        List<ID> accIds = new List<ID>();
        Map<id,Canada_Profile__c> canMap = new Map<id,Canada_Profile__c>(); 
        for(Canada_Profile__c canObj: canObjLst){
            //init all calculating fields to zero and then add to list.
            //this initialization helps when we PAIN account changes from one to other in that case it won't retain previous account values.
            if(canObj.Account__c != null) {
                canObj.Rolling_12_mos_Airway__c=0;
                canObj.Rolling_12_mos_Emergency_Medicine__c=0;
                canObj.Rolling_12_mos_Regional_Anes__c=0;
                canObj.Last_Year_Sales__c=0;
                canObj.YTD_Sales__c=0;    

                accIds.add(canObj.Account__c);
                CanMap.put(canObj.Account__c, canObj);
            }
        }
       for(AggregateResult arRegAnes : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                         WHERE (Date__c = Last_N_Months : 11 or Date__c = THIS_MONTH)
                                         AND Business_Unit__c = 'Anesthesia'
                                         AND Group__c = 'Regional Anesthesia'
                                         AND Compensation_Profile__c='Anesthesia Canada'
                                         AND Account__c in : accIds group by Account__c])
        {
            
            if(canMap.containsKey((String)arRegAnes.get('Account__c'))) {
                Canada_Profile__c modcanObj = canMap.get((String)arRegAnes.get('Account__c'));
                modcanObj.Rolling_12_mos_Regional_Anes__c = (decimal)arRegAnes.get('SumOfSales');  
            }
        }
        
    for(AggregateResult arEmPba : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                         WHERE (Date__c = Last_N_Months : 11 or Date__c = THIS_MONTH)
                                         AND Business_Unit__c = 'Anesthesia'
                                         AND (  Group__c = 'Emergency Medicine'
                                              OR Group__c='Powered Bone Access' )
                                         AND Compensation_Profile__c='Anesthesia Canada'
                                         AND Account__c in : accIds group by Account__c])
        {
            
            if(canMap.containsKey((String)arEmPba.get('Account__c'))) {
                Canada_Profile__c modcanObj = canMap.get((String)arEmPba.get('Account__c'));
                modcanObj.Rolling_12_mos_Emergency_Medicine__c = (decimal)arEmPba.get('SumOfSales');  
            }
        }
        
  for(AggregateResult arAirway : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                         WHERE (Date__c = Last_N_Months : 11 or Date__c = THIS_MONTH)
                                         AND Business_Unit__c = 'Anesthesia'
                                         AND (  Group__c = 'Airway'
                                              OR Group__c='LMA Atomization' 
                                              OR Group__c='LMA Laryngeal Mask Airways' )
                                         AND Compensation_Profile__c='Anesthesia Canada'
                                         AND Account__c in : accIds group by Account__c])
        {
            
            if(canMap.containsKey((String)arAirway.get('Account__c'))) {
                Canada_Profile__c modcanObj = canMap.get((String)arAirway.get('Account__c'));
                modcanObj.Rolling_12_mos_Airway__c = (decimal)arAirway.get('SumOfSales');  
            }
        }
                   
    for(AggregateResult arYtdSal : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                         WHERE (Date__c = THIS_YEAR)
                                         AND Business_Unit__c = 'Anesthesia'
                                         AND (  Group__c ='Airway'
                                              OR Group__c='LMA Atomization' 
                                              OR Group__c='LMA Laryngeal Mask Airways' 
                                              OR Group__c='Powered Bone Access'
                                              OR Group__c='Regional Anesthesia'
                                              OR Group__c='Emergency Medicine')
                                         AND Compensation_Profile__c='Anesthesia Canada'
                                         AND Account__c in : accIds group by Account__c])
        {
            
            if(canMap.containsKey((String)arYtdSal.get('Account__c'))) {
                Canada_Profile__c modcanObj = canMap.get((String)arYtdSal.get('Account__c'));
                modcanObj.YTD_Sales__c = (decimal)arYtdSal.get('SumOfSales');  
            }
        }
                   
    for(AggregateResult arPYtdSal : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                         WHERE (Date__c = LAST_YEAR)
                                         AND Business_Unit__c = 'Anesthesia'
                                         AND (  Group__c ='Airway'
                                              OR Group__c='LMA Atomization' 
                                              OR Group__c='LMA Laryngeal Mask Airways' 
                                              OR Group__c='Powered Bone Access'
                                              OR Group__c='Regional Anesthesia'
                                              OR Group__c='Emergency Medicine')
                                         AND Compensation_Profile__c='Anesthesia Canada'
                                         AND Account__c in : accIds group by Account__c])
        {
            
            if(canMap.containsKey((String)arPYtdSal.get('Account__c'))) {
                Canada_Profile__c modcanObj = canMap.get((String)arPYtdSal.get('Account__c'));
                modcanObj.Last_Year_Sales__c = (decimal)arPYtdSal.get('SumOfSales');  
            }
        }
                   
 
        
}
}