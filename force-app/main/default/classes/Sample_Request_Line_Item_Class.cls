/*********************************************************************
* Test Class Coverage: Invoiced_Sales_Tracking_Class_Test
* Author(s)          : Dunte'e Silver
**********************************************************************/
public class Sample_Request_Line_Item_Class {
    /* Method use to lockdown a Purchase Order record after it has been unlocked after full approval.
    Using apex because a validation rule can be tricked by passing another value along w/ the allowed values. */
    public static void manuallyLockSampleRequestLineItems(List<Sample_Request_Line_Item__c> newTrigger,List<Sample_Request_Line_Item__c> oldTrigger){
        //system.debug('*** EXECUTING manuallyLockPo method ***');
        //Custom setting value that controls execution of this method
        Sample_Request_Line_Item_Class_CS__c   customSettingSrliClass = Sample_Request_Line_Item_Class_CS__c.getValues('manuallyLockSampleRequestLineItems');
        //System.debug('*** customSettingSrliClass.Execute__c *** ' + customSettingSrliClass.Execute__c);
        //start if control method
        if(customSettingSrliClass!=null && customSettingSrliClass.Execute__c!=null && customSettingSrliClass.Execute__c){
            system.debug('*** IN Sample_Request_Line_Item_Class ***');
            system.debug('*** EXECUTING Sample_Request_Line_Item_Class method ***');
            Set<String> allowedFields = new Set<String>{'Id','LastmodifiedbyId','LastModifieddate','SystemModstamp','Transferred_To__c',
                'Transferred_To__c', 'Confirm_Transfer_of_Stock__c', 'Shipping_Tracking_Numbers__c', 'Shipping_Tracking__c', 'Shipping_Date__c',
                'Shipping_Carrier__c','Shipping_Priority__c','Shipping_Tracking_Number_Count__c',' Shipping_Info__c'
                };

            for(Integer index = 0; index < newTrigger.size(); index++) {
                if(oldTrigger[index].Sample_Request_Status__c  == 'Ready' && newTrigger[index].Sample_Request_Status__c  == 'Ready') {
                    //compare old values vs new values to see what fields changed
                    sObject beforeRecord = oldTrigger[index].clone(true, false, false, false);
                    sObject afterRecord = newTrigger[index].clone(true, false, false, false);
                    Map<String, Object> oldValues = beforeRecord.getPopulatedFieldsAsMap();
                    Map<String, Object> newValues = afterRecord.getPopulatedFieldsAsMap();
                    system.debug('*** oldValues1 *** ' + oldValues);
                    system.debug('*** newValues1 *** ' + newValues);
                    oldValues.keySet().removeAll(allowedFields);
                    newValues.keySet().removeAll(allowedFields);
                    if(oldTrigger[index] != newTrigger[index]){
                        system.debug('*** oldTrigger *** ' + oldTrigger[index]);
                        system.debug('*** newTrigger *** ' + newTrigger[index]);
                    }//end if
                    //Error is any field other than allowed fields are modified.
                    if(oldValues != newValues){
                        Trigger.new[index].addError('Only specific fields can be modified when a Sample Request has been approved.  ' +
                                                    'Fields related to tracking information and transfer of stock.');
                    }//end oldValues != newValues   
                }//end of if oldTrigger
            }//end of outter for loop
        }
        //end if control method
        
    }//end manuallyLockSampleRequestLineItems
    
}//end of Sample_Request_Line_Item_Class