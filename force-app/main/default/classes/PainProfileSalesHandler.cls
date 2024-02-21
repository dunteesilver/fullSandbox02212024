/*********************************************************************
* Description      : Controller Class for Pain Invoiced Sales Rolling 12 months,Prior YTD,YTD calculations and populated Pain object fields.
* Test Class       : 
* VisualForce      : N/A
* Author(s)        : Siva Machinieni - siva.machineni@teleflex.com
//Siva for Painprofile sales

**********************************************************************/
public class PainProfileSalesHandler { 
  
    /*
* this method is invoked from Master_Pain_Trigger to calculate rolling 12 months,YTD,Last Year sales for different Group__c types. 
*/
    public static void rollingInvSalesFrmPainTgr(List<Pain_Profile__c> painObjLst) {
        
        //initializations...
        List<ID> accIds = new List<ID>();
        Map<id,Pain_Profile__c> PainMap = new Map<id,Pain_Profile__c>();
        
        //this loop executes the input values from trigger - Trigger.New
        for(Pain_Profile__c painObj: painObjLst){
            //init all calculating fields to zero and then add to list.
            //this initialization helps when we PAIN account changes from one to other in that case it won't retain previous account values.
            if(painObj.Account__c != null) {
                painObj.Rolling_12_Month_Sales_LMA__c = 0;
                painObj.Rolling_12_Month_Sales_Regional_Anes__c	 = 0;
                painobj.Last_Year_Sales_LMA__c=0;
                painobj.Last_Year_Sales_Regional_Anes__c=0;
                painobj.YTD_Sales_LMA__c=0;
                painobj.YTD_Sales_Regional_Anes__c=0;
                accIds.add(painObj.Account__c);
                painMap.put(painObj.Account__c, painObj);
            }
        }
        
        for(AggregateResult arLMApain : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                         WHERE (Date__c = Last_N_Months : 11 or Date__c = THIS_MONTH)
                                         AND Business_Unit__c = 'Anesthesia'
                                         AND Group__c = 'LMA Pain Management'
                                         AND Compensation_Profile__c!='Anesthesia Canada'
                                         AND Account__c in : accIds group by Account__c])
        {
            
            if(painMap.containsKey((String)arLMApain.get('Account__c'))) {
                Pain_Profile__c modpainObj = painMap.get((String)arLMApain.get('Account__c'));
                modpainObj.Rolling_12_Month_Sales_LMA__c = (decimal)arLMApain.get('SumOfSales');  
            }
        }
        
        for(AggregateResult arLMApain : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                         WHERE (Date__c = THIS_YEAR)
                                         AND Business_Unit__c = 'Anesthesia'
                                         AND Group__c = 'LMA Pain Management'
                                         AND Compensation_Profile__c!='Anesthesia Canada'
                                         AND Account__c in : accIds group by Account__c])
        {
            
            if(painMap.containsKey((String)arLMApain.get('Account__c'))) {
                Pain_Profile__c modpainObj = painMap.get((String)arLMApain.get('Account__c'));
                modpainObj.YTD_Sales_LMA__c = (decimal)arLMApain.get('SumOfSales');  
            }
        }
        
        for(AggregateResult arLMApain : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                         WHERE (Date__c = Last_YEAR)
                                         AND Business_Unit__c = 'Anesthesia'
                                         AND Group__c = 'LMA Pain Management'
                                         AND Compensation_Profile__c!='Anesthesia Canada'
                                         AND Account__c in : accIds group by Account__c])
        {
            
            if(painMap.containsKey((String)arLMApain.get('Account__c'))) {
                Pain_Profile__c modpainObj = painMap.get((String)arLMApain.get('Account__c'));
                modpainObj.Last_Year_Sales_LMA__c = (decimal)arLMApain.get('SumOfSales');  
            }
        }
        
        for(AggregateResult arRegAnes : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                         WHERE (Date__c = Last_N_Months : 11 or Date__c = THIS_MONTH)
                                         AND Business_Unit__c = 'Anesthesia'
                                         AND Group__c = 'Regional Anesthesia'
                                         AND Compensation_Profile__c!='Anesthesia Canada'
                                         AND Account__c in : accIds group by Account__c])
        {
            
            if(painMap.containsKey((String)arRegAnes.get('Account__c'))) {
                Pain_Profile__c modpainObj = painMap.get((String)arRegAnes.get('Account__c'));
                modpainObj.Rolling_12_Month_Sales_Regional_Anes__c = (decimal)arRegAnes.get('SumOfSales');  
            }
        }
        
        for(AggregateResult arRegAnes : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                         WHERE (Date__c = THIS_YEAR)
                                         AND Business_Unit__c = 'Anesthesia'
                                         AND Group__c = 'Regional Anesthesia'
                                         AND Compensation_Profile__c!='Anesthesia Canada'
                                         AND Account__c in : accIds group by Account__c])
        {
            
            if(painMap.containsKey((String)arRegAnes.get('Account__c'))) {
                Pain_Profile__c modpainObj = painMap.get((String)arRegAnes.get('Account__c'));
                modpainObj.YTD_Sales_Regional_Anes__c = (decimal)arRegAnes.get('SumOfSales');  
            }
        }
        
        for(AggregateResult arRegAnes : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                         WHERE (Date__c = LAST_YEAR)
                                         AND Business_Unit__c = 'Anesthesia'
                                         AND Group__c = 'Regional Anesthesia'
                                         AND Compensation_Profile__c!='Anesthesia Canada' 
                                         AND Account__c in : accIds group by Account__c])
        {
            
            if(painMap.containsKey((String)arRegAnes.get('Account__c'))) {
                Pain_Profile__c modpainObj = painMap.get((String)arRegAnes.get('Account__c'));
                modpainObj.Last_Year_Sales_Regional_Anes__c = (decimal)arRegAnes.get('SumOfSales');  
            }
        }
        
        
        
        
    }
}