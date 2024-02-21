public class Invoiced_Sales_Tracking_Class {

    //start of addShipping
    public static void addShipping(List<Invoiced_Sales_Tracking__c> newTrigger){
        System.debug('*** Starting addShipping in Invoiced_Sales_Tracking_Class ***');
        //Custom setting value that controls execution of this method
        Invoiced_Sales_Tracking_Class_CS__c  customSettingIstClass = Invoiced_Sales_Tracking_Class_CS__c.getValues('addShipping');
        System.debug('*** customSettingIstClass.Execute__c *** ' + customSettingIstClass.Execute__c);
        //start if control method
        if(customSettingIstClass.Execute__c){
            set<String> sKey = new set<String>();
            map<String, Invoiced_Sales_Tracking__c > istMap = new map<String, Invoiced_Sales_Tracking__c>();
            list<Sample_Request_Line_Item__c> sampleList = new list<Sample_Request_Line_Item__c>();
            list<Sample_Request_Line_Item__c> sampleListUpdate = new list<Sample_Request_Line_Item__c>();
            string sampleKey = '';
            
            String poNumber = '';
            String poNumberSplit = '';
            //loop to create key
            for(Invoiced_Sales_Tracking__c curr : newTrigger){
                //create key to pull Sample Request records
                if(curr.PO_Number__c != NULL){
                    poNumber = curr.PO_Number__c;
                    poNumberSplit = poNumber.substringBefore(' ');
                    sampleKey = curr.Material_Name__c + '-' + poNumberSplit;
                    sKey.add(sampleKey);
                    istMap.put(sampleKey,curr);  
                }//end if 
            }//end for loop
            
            system.debug('*** sKey *** ' + sKey);
            system.debug('*** istMap *** ' + istMap);
            //pull Sample Request Line Item records using skey
            sampleList = [SELECT Id, Key__c FROM Sample_Request_Line_Item__c WHERE Key__c IN: sKey AND Sample_Request__r.Status__c = 'Ready'];
            
            //sampleList size check for adding tracking
            if( sampleList.size() > 0 ){
                string stURL = NULL;
                string stAddTracking = NULL;
                string stCarrier = NULL;
                string stNumbers = NULL;
                //string shippingPriority;
                //Date shippingDate;
                //Decimal shippingTrackingCount;
                
                system.debug('*** sampleList.size() *** ' + sampleList.size());
                Sample_Request_Line_Item__c sampleRec = new Sample_Request_Line_Item__c(); //initialize Sample Request Line Item object
                
                //loop thru Sample Request Line Items to update with tracking
                for(Sample_Request_Line_Item__c curr : sampleList){
                    
                    sampleRec = Invoiced_Sales_Tracking_Class.sampleLineItemRec(stCarrier,curr,istMap);
                    system.debug('*** sampleRec *** ' + sampleRec);
                    sampleListUpdate.add(sampleRec);
                }//end of for loop
                
            }//end if sampleList size check
            
            if( sampleListUpdate.size() > 0 ){
                database.update(sampleListUpdate, false);
            }//end if check size of sampleListUpdate
        }//end if(customSettingIstClass.Execute__c)
        
    }
    //end of addShipping
    
    //method to return proper tracking URL
    public static Sample_Request_Line_Item__c sampleLineItemRec(string stCarrier, Sample_Request_Line_Item__c curr,  map<String, Invoiced_Sales_Tracking__c > istMap ){
        string stURL = NULL;
        string stAddTracking = NULL;
        //string stCarrier = NULL;
        string stNumbers = NULL;
        
        Sample_Request_Line_Item__c sampleRec = new Sample_Request_Line_Item__c();
        
        if(istMap.get(curr.Key__c).Delivery_Priority__c != NULL){
            stCarrier = istMap.get(curr.Key__c).Delivery_Priority__c;
            stCarrier = stCarrier.left(3);
        }//end if Delivery_Priority__c check
        
        if( stCarrier != NULL && istMap.get(curr.Key__c).Tracking_Number__c != NULL &&
           (stNumbers == NULL || stNumbers.contains(istMap.get(curr.Key__c).Tracking_Number__c) == FALSE)){
               
               if(stCarrier == 'UPS'){
                   if(stURL == NULL){
                       stURL = 'https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=' + istMap.get(curr.Key__c).Tracking_Number__c;
                   }//end if stURL
                   else if( stURL.contains(istMap.get(curr.Key__c).Tracking_Number__c) == FALSE ){
                       stAddTracking = istMap.get(curr.Key__c).Tracking_Number__c;
                       if(stAddTracking.length() + stURL.length() < 255){
                           stURL = stURL + '%0D' + istMap.get(curr.Key__c).Tracking_Number__c;
                       }
                   }//end else if
               }//end if stCarrier UPS
               else if(stCarrier == 'Fed'){
                   stCarrier = 'FedEx';
                   if(stURL == NULL){
                       stURL = 'https://www.fedex.com/apps/fedextrack/?action=track&cntry_code=us&trackingnumber=' + istMap.get(curr.Key__c).Tracking_Number__c;
                   }
                   else if(stURL.contains(istMap.get(curr.Key__c).Tracking_Number__c) == FALSE){
                       stAddTracking = istMap.get(curr.Key__c).Tracking_Number__c;
                       if(stAddTracking.length() + stURL.length() < 255){
                           stURL = stURL + ',' + istMap.get(curr.Key__c).Tracking_Number__c;
                       }
                       
                   }
               }//end else if Fed
               else if(stCarrier == 'Pur'){
                   stCarrier = 'Purolator';
                   if(stURL == NULL){
                       stURL = 'https://www.purolator.com/purolator/ship-track/tracking-summary.page?pin=' + istMap.get(curr.Key__c).Tracking_Number__c;
                   }
                   else if(stURL.contains(istMap.get(curr.Key__c).Tracking_Number__c) == FALSE){
                       stAddTracking = istMap.get(curr.Key__c).Tracking_Number__c;
                       if(stAddTracking.length() + stURL.length() < 255){
                           stURL = stURL + ',' + istMap.get(curr.Key__c).Tracking_Number__c;
                       }
                       
                   }
               }//end else if Pur
               else if(stCarrier == 'YRC'){
                   stCarrier = 'YRC Freight';
                   if(stURL == NULL){
                       stURL = 'https://my.yrc.com/tools/track/shipments?referenceNumber=' + istMap.get(curr.Key__c).Tracking_Number__c;
                   }
                   else if(stURL.contains(istMap.get(curr.Key__c).Tracking_Number__c) == FALSE){
                       stAddTracking = istMap.get(curr.Key__c).Tracking_Number__c;
                       if(stAddTracking.length() + stURL.length() < 255){
                           stURL = stURL + ',' + istMap.get(curr.Key__c).Tracking_Number__c;
                       }
                       
                   }
               }//end else if YRC
               else if(stCarrier == 'AAA'){
                   stCarrier = 'AAA Cooper';
               }//end else if AAA
               else if(stCarrier == 'Air'){
                   stCarrier = 'Air Freight';
               }//end else if Air Freight
               else if(stCarrier == 'Roa'){
                   stCarrier = 'Road Runner';
                   if(stURL == NULL){
                       stURL = 'https://my.yrc.com/tools/track/shipments?referenceNumber=' + istMap.get(curr.Key__c).Tracking_Number__c;
                   }
                   else{
                       stAddTracking = istMap.get(curr.Key__c).Tracking_Number__c;
                       if(stAddTracking.length() + stURL.length() < 255){
                           stURL = stURL + ',' + istMap.get(curr.Key__c).Tracking_Number__c;
                       }
                   }//end else
               }//end else if Roa
               else if(stCarrier == 'Sea'){
                   stCarrier = 'Sea Freight';
               }//end else if Sea
               else if(stCarrier == 'Old'){
                   stCarrier = 'Old Dominion';
               }//end else if Old
               else if(stCarrier == 'Hol'){
                   stCarrier = 'Holland';
               }//end else if Hol
               
               if(stNumbers == NULL){
                   stNumbers = istMap.get(curr.Key__c).Tracking_Number__c;
               }
               else{
                   stNumbers = stNumbers + ', ' + istMap.get(curr.Key__c).Tracking_Number__c;
               }
               
               //curr.Shipping_Date__c = istMap.get(curr.Key__c).Ship_Date__c;
               //curr.Shipping_Carrier__c = stCarrier;
               //curr.Shipping_Priority__c = istMap.get(curr.Key__c).Delivery_Priority__c;
               
               //shippingDate = istMap.get(curr.Key__c).Ship_Date__c;
               //shippingPriority = istMap.get(curr.Key__c).Delivery_Priority__c;
               
               if(stURL != NULL){
                   stURL = stURL.left(255);
                   //curr.Shipping_Tracking__c = stURL;
               }
               if(stNumbers != NULL){
                   //curr.Shipping_Tracking_Numbers__c = stNumbers;
               }
               
               //add tracking information
               List<String> stNumbersList = stNumbers.split(',');
               sampleRec = new Sample_Request_Line_Item__c(
                   Id = curr.Id,
                   Shipping_Tracking_Numbers__c = stNumbers,
                   Shipping_Tracking__c = stURL,
                   Shipping_Date__c = istMap.get(curr.Key__c).Ship_Date__c,
                   Shipping_Carrier__c = stCarrier,
                   Shipping_Priority__c = istMap.get(curr.Key__c).Delivery_Priority__c,
                   Shipping_Tracking_Number_Count__c = stNumbersList.size()
               );
               
               //sampleListUpdate.add(sampleRec);
           }        
        return sampleRec;
    }
    //end of sampleLineItemRec
    
}//end of class