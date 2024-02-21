/*********************************************************************
* Description      : Controller Class for TAM Invoiced Sales Rolling 12 months calculations and populated TAM object fields.
* Test Class       : TAMInvoicedSalesHandler_Test
* VisualForce      : N/A
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
//surya for rolling TAM sales
//initial version work item: W-023184 sprint: 2020.04
**********************************************************************/
public class TAMInvoicedSalesHandler {
    
    /*
* This method is invoked from invoiced_sales__c trigger to calculate rolling 12 months sales for different sub_group__c types.
*/
    public static void rollingInvSalesFrmInvSalTgr(List<ID> ids) {
        
        //initializations
        Map<Id,TAM__c> tamMap = new Map<Id,TAM__c>();
        List<TAM__c> tamUpdateLst = new List<TAM__c>();
        
        //this loop gets all TAM__c instances from the input source and holds in a map.
        for(TAM__c tamObj : [SELECT id, Account_Name__c  FROM TAM__c WHERE Account_Name__c in : ids]){
            tamMap.put(tamObj.Account_Name__c,tamObj);
        }
        
        //this loop calulates aggregate sum of sales for laryngoscopes
        for(AggregateResult arLaryn : [SELECT Account__c, SUM(Sales__c) SumOfSales FROM Invoiced_Sales__c
                                       WHERE (Date__c = Last_N_Months : 11 OR Date__c = THIS_MONTH)
                                       AND Business_Unit__c = 'Anesthesia'
                                       AND Sub_Group__c = 'Laryngoscopes'
                                       AND Account__c in : ids group by Account__c
                                      ])
        {
            //check if this aggregate sum of sales for laryngoscopes exist in main input map source
            //if exist then get, update and add the same object to map
            if(tamMap.containsKey((String)arLaryn.get('Account__c'))) {
                TAM__c modTAMObj = tamMap.get((String)arLaryn.get('Account__c'));
                modTAMObj.Rolling_12_Month_Sales_Laryngoscope__c = (decimal)arLaryn.get('SumOfSales');
                tamMap.put(modTAMObj.Account_Name__c, modTAMObj);
            }
        }
        
        //this loop calulates aggregate sum of sales for ETT/EBT
        for(AggregateResult arETT : [SELECT Account__c, SUM(Sales__c) SumOfSales FROM Invoiced_Sales__c
                                     WHERE (Date__c = Last_N_Months : 11 OR Date__c = THIS_MONTH)
                                     AND Business_Unit__c = 'Anesthesia'
                                     AND (Sub_Group__c='Endotracheal Tubes' OR Sub_Group__c='Bronchial Tubes')
                                     AND Account__c in : ids group by Account__c
                                    ])
        {
            //check if this aggregate sum of sales for ETT/EBT exist in main input map source
            //if exist then get, update and add the same object to map
            if(tamMap.containsKey((String)arETT.get('Account__c'))) {
                TAM__c modTAMObj = tamMap.get((String)arETT.get('Account__c'));
                modTAMObj.Rolling_12_Month_Sales_ETT_EBT__c = (decimal)arETT.get('SumOfSales');
                tamMap.put(modTAMObj.Account_Name__c, modTAMObj);				
                
            }
        }
        
        //this loop calulates aggregate sum of sales for LMA
        for(AggregateResult arLMA : [SELECT Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c
                                     WHERE (Date__c = Last_N_Months : 11 OR Date__c = THIS_MONTH)
                                     AND Business_Unit__c = 'Anesthesia'
                                     AND ( 
                                         Sub_Group__c='LMA Reusable Masks - Gastric Access'
                                         OR Sub_Group__c='LMA Reusable Masks - Intubating'
                                         OR Sub_Group__c='LMA Reusable Masks - Reinforced'
                                         OR Sub_Group__c='LMA Reusable Masks - Standard'
                                         OR Sub_Group__c='LMA Single Use Masks - Gastric Access'
                                         OR Sub_Group__c='LMA Single Use Masks - Intubating'
                                         OR Sub_Group__c='LMA Single Use Masks - Reinforced'
                                         OR Sub_Group__c='LMA Single Use Masks - Standard'   
                                     )
                                     AND Account__c in : ids group by Account__c
                                    ])
        {
            //check if this aggregate sum of sales for LMA exist in main input map source
            //if exist then get, update and add the same object to map
            if(tamMap.containsKey((String)arLMA.get('Account__c'))) {
                TAM__c modTAMObj = tamMap.get((String)arLMA.get('Account__c'));
                modTAMObj.Rolling_12_Month_Sales_LMA__c = (decimal)arLMA.get('SumOfSales');
                tamMap.put(modTAMObj.Account_Name__c, modTAMObj);
            }
        }
        
        //this loop to iterate over the map and add to a list source that needs to be updated
        for(ID tamAccID : tamMap.keySet()){
            tamUpdateLst.add(tamMap.get(tamAccID)); 
        }
        
        //system.debug('tam update list size::'+tamUpdateLst.size());
        
        //DML to update TAM__c object
        Database.update(tamUpdateLst, false);
    }
    
    /*
* this method is invoked from Master_TAM_Trigger to calculate rolling 12 months sales for different sub_group__c types. 
*/
    public static void rollingInvSalesFrmTAMTgr(List<TAM__c> tamObjLst) {
        
        //initializations...
        List<ID> accIds = new List<ID>();
        Map<id,TAM__c> tamMap = new Map<id,TAM__c>();
        
        //this loop executes the input values from trigger - Trigger.New
        for(TAM__c tamObj: tamObjLst){
            //init all calculating fields to zero and then add to list.
            //this initialization helps when we TAM account changes from one to other in that case it won't retain previous account values.
            if(tamObj.Account_Name__c != null) {
                tamObj.Rolling_12_Month_Sales_Laryngoscope__c = 0;
                tamObj.Rolling_12_Month_Sales_ETT_EBT__c = 0;
                tamObj.Rolling_12_Month_Sales_LMA__c = 0;
                accIds.add(tamObj.Account_Name__c);
                tamMap.put(tamObj.Account_Name__c, tamObj);
            } 
            //this does not have to occur as account is a mandatory field on TAM, but in future cases if account blanks then we make all sales zero.
            else {
                tamObj.Rolling_12_Month_Sales_Laryngoscope__c = 0;
                tamObj.Rolling_12_Month_Sales_ETT_EBT__c = 0;
                tamObj.Rolling_12_Month_Sales_LMA__c = 0;
            }
        }
        
        for(AggregateResult arLaryn : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                       WHERE (Date__c = Last_N_Months : 11 or Date__c = THIS_MONTH)
                                       AND Business_Unit__c = 'Anesthesia'
                                       AND Sub_Group__c = 'Laryngoscopes'
                                       AND Account__c in : accIds group by Account__c])
        {
            
            if(tamMap.containsKey((String)arLaryn.get('Account__c'))) {
                TAM__c modTAMObj = tamMap.get((String)arLaryn.get('Account__c'));
                modTAMObj.Rolling_12_Month_Sales_Laryngoscope__c = (decimal)arLaryn.get('SumOfSales');  
            }
        }
        
        for(AggregateResult arETT : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                     WHERE (Date__c = Last_N_Months : 11 or Date__c = THIS_MONTH)
                                     AND Business_Unit__c = 'Anesthesia'
                                     AND (Sub_Group__c='Endotracheal Tubes' OR Sub_Group__c='Bronchial Tubes')
                                     AND Account__c in : accIds group by Account__c])
        {
            
            if(tamMap.containsKey((String)arETT.get('Account__c'))) {
                TAM__c modTAMObj = tamMap.get((String)arETT.get('Account__c'));
                modTAMObj.Rolling_12_Month_Sales_ETT_EBT__c = (decimal)arETT.get('SumOfSales');
            }
            
        }
        
        for(AggregateResult arLMA : [select Account__c, SUM(Sales__c) SumOfSales from Invoiced_Sales__c	
                                     WHERE (Date__c = Last_N_Months : 11 or Date__c = THIS_MONTH)
                                     AND Business_Unit__c = 'Anesthesia'
                                     AND ( 
                                         Sub_Group__c='LMA Reusable Masks - Gastric Access'
                                         OR Sub_Group__c='LMA Reusable Masks - Intubating'
                                         OR Sub_Group__c='LMA Reusable Masks - Reinforced'
                                         OR Sub_Group__c='LMA Reusable Masks - Standard'
                                         OR Sub_Group__c='LMA Single Use Masks - Gastric Access'
                                         OR Sub_Group__c='LMA Single Use Masks - Intubating'
                                         OR Sub_Group__c='LMA Single Use Masks - Reinforced'
                                         OR Sub_Group__c='LMA Single Use Masks - Standard'
                                         
                                     )
                                     AND Account__c in : accIds group by Account__c])
        {
            
            if(tamMap.containsKey((String)arLMA.get('Account__c'))) {
                TAM__c modTAMObj = tamMap.get((String)arLMA.get('Account__c'));
                modTAMObj.Rolling_12_Month_Sales_LMA__c = (decimal)arLMA.get('SumOfSales');
            }
            
        }
    }
    
}