public class Product_Tracking_Helper_Class {
    
    public static void addAccount(List<Product_Tracking__c> newTrigger){
        // Test Class: account_Page_Helper_Test
        set<String> sapSet = new set<String>();
        map<String, Id> sapMap = new map<String, Id>();
        
        for(Product_Tracking__c pt : newTrigger){
            if(pt.SAP_Code__c != NULL){
                sapSet.add(pt.SAP_Code__c);
            }
        }
        
        if(sapSet.size() > 0){
            for(Account a : [SELECT Id, SAP_Sold_To__c 
                             FROM Account 
                             WHERE SAP_Sold_To__c =:sapSet])
            {
                sapMap.put(a.SAP_Sold_To__c , a.Id);
            }
            for(Product_Tracking__c pt : newTrigger){
                if(sapMap.get(pt.SAP_Code__c) != NULL){
                    pt.Account__c = sapMap.get(pt.SAP_Code__c);
                }
            }
        }
    }
    // Added Support for Global Picklist - Archana 20Jun2017
    public static void setProductOfInterest(List<Product_Tracking__c> newTrigger, Map<Id,Product_Tracking__c> oldTrigger,String type){        
        // Test Class: account_Page_Helper_Test 
        list<Product_Tracking__c> updateProductTracking = new list<Product_Tracking__c>();
        string poiList;
        string poi;
        boolean upd;
        
        for(Product_Tracking__c P : newTrigger){
            
            system.debug('Starting Product of Interest Class');
            upd = FALSE;
            if(type == 'insert' && (P.Product_of_Interest__c != NULL || P.Product_of_Interest_GPL__c != NULL)){
                upd = TRUE;
            }
            // Check to see if the automation has never run or the values have changed.
            else if( 
                type == 'update' &&
                P.Product_of_Interest_GPL__c != NULL &&
                (oldTrigger.get(P.Id).Product_of_Interest_GPL__c != P.Product_of_Interest_GPL__c
                 || P.Product_of_Interest_Sort__c == NULL))
            {
                upd = TRUE;
                system.debug('Lets update!');
            }
            else if(
                type == 'update' &&
                P.Product_of_Interest__c != NULL &&
                (oldTrigger.get(P.Id).Product_of_Interest__c != P.Product_of_Interest__c
                 || P.Product_of_Interest_Sort__c == NULL))
            {
                upd = TRUE;
                system.debug('Lets update!');
            }
            if(upd){
                // Prioritize the New Field over the old
                if(P.Product_of_Interest_GPL__c != NULL){
                    Product_Tracking__c uPOI = new Product_Tracking__c(
                        Id = P.Id,
                        Product_of_Interest_Sort__c = P.Product_of_Interest_GPL__c
                    );
                    updateProductTracking.add(uPOI);
                }
                else{
                    // Let's Alphabitize
                    poiList = P.Product_of_Interest__c;
                    List<String> sortedvalue = poiList.split(';');
                    sortedvalue.sort();
                    
                    poi = '';
                    for(string s : sortedvalue){
                        if(poi == ''){
                            poi = s;
                        }
                        else{
                            poi = poi + ', ' + s;
                        }
                    }
                    // Make sure it will fit...
                    poi = poi.left(255);
                    
                    // DML
                    Product_Tracking__c uPOI = new Product_Tracking__c(
                        Id = P.Id,
                        Product_of_Interest_Sort__c = poi
                    );
                    updateProductTracking.add(uPOI);
                }
                
            }//end of if(upd)
            
            if(updateProductTracking.size() > 0){
                system.debug('Updating Product of Interest Sort!');
                
                try {
                    update updateProductTracking;
                }
                catch (Exception e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
                
            }//end of if updateProductTracking.size
            
            
        }//end of for loop
        system.debug('END Product of Interest Class');
    }//End of setProductOfInterest - Archana
    
}//End of class