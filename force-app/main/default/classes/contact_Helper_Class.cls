public class contact_Helper_Class {
    
    public static void eloquaContactBU(list<Contact> newTrigger, map<Id, Contact> oldTrigger, string triggerType){
        // Test Class: account_Page_Helper_Test (c2)
        
        list<Contact> updateCont = new list<Contact>();
        string poiList;
        string poi;
        boolean upd;
        boolean ins;
        integer bucount;
        
        for(Contact c : newTrigger){
            upd = FALSE;
            ins = FALSE;
            if(triggerType == 'insert' && c.Business_Unit1__c  != NULL){
                upd = TRUE;
                ins = TRUE;
            }
            else if(
                triggerType == 'update' && 
                c.Business_Unit1__c  != NULL &&
                (oldTrigger.get(c.Id).Business_Unit1__c  != c.Business_Unit1__c  
                 || c.Eloqua_Business_Unit__c == NULL
                 || c.Eloqua_Business_Unit_Reset__c == TRUE))
            {
                upd = TRUE;  
                system.debug('Lets update!');
            }
            if(upd){
                
                // Let's Alphabitize 
                poiList = c.Business_Unit1__c ;
                List<String> sortedvalue = poiList.split(';');
                sortedvalue.sort();
                
                
                poi = '';
                bucount = 0;
                for(string s : sortedvalue){
                    if(poi == ''){
                        poi = s;                        
                    }
                    else{
                        poi = poi + '::' + s;                        
                    }
                    ++bucount;
                }
                // Make sure it will fit...
                poi = poi.left(255);
                
                // DML
                c.Eloqua_Business_Unit__c = poi;
                c.Eloqua_Business_Unit_Reset__c = FALSE;
                c.Business_Unit_Count__c = bucount;
            }
        }
    }
    
    public static void getSalesRepForMANTACon(list<Contact> newTrigger){
        
        Set<String> accIdSet = new Set<String>();
        Set<String> salesRepOrMgrId = new Set<String>();
        Set<String> tset = new Set<String>();
        
        for(Contact con : newTrigger){
            accIdSet.add(con.AccountId);
        }
        
		List<Account> accLst = [select id, Territory_Key__c from Account where Id in : accIdSet];
        
        for(Account acc : accLst){
            Map<String, String> tSales = new Map<String, String>();
            List<String> sortedvalue = new List<String>(); 
            if(acc.Territory_Key__c != NULL){
                string poiList = acc.Territory_Key__c;
                sortedvalue = poiList.split(';');
                sortedvalue.sort();
                tset.addAll(sortedvalue);
            }
        }     
        
        for(Territory_Master__c tm :[SELECT Id, Name, Role__c, Business_Unit__c, Primary_Territory_User__c, Sales_Rep__c, Manager__c,
                                     Territory_Number__c
                                     FROM Territory_Master__c 
                                     WHERE Territory_Number__c IN : tset
                                     AND Business_Unit__c = 'Interventional'
                                     AND Role__c = 'Sales Rep'
                                     ORDER BY Business_Unit__c, Role__c DESC
                                     ])
        {
System.debug(tm);
            
            if(tset.contains(tm.Territory_Number__c)){
            for(Contact c : newTrigger){

                if(tm.Sales_Rep__c != NULL){
                    c.MANTA_Physician_s_Sales_Rep__c=  tm.Sales_Rep__c;
                }
                else if(tm.Primary_Territory_User__c != NULL){
                    c.MANTA_Physician_s_Sales_Rep__c = tm.Primary_Territory_User__c;
                }
                else{
                    c.MANTA_Physician_s_Sales_Rep__c = tm.Manager__c;
                }
            }
        }
        }  
        
        
        
        
    }
    
}