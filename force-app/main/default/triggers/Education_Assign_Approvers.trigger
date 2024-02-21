trigger Education_Assign_Approvers on Education_Record__c (before update, after insert, after update) {
    // This Trigger is not needed anymore - 14Jan2018 - ESC
    // 
    //hold list of Ids in trigger
    List<String> edIds = new List<String>();
    
    //get Ids in Trigger
    for(Education_Record__c ed : Trigger.New){
        edIds.add(ed.Clinical_Educator__c);
    }
    
    List<Education_Record__c> updRecs = new List<Education_Record__c>();
    if( Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('au') )
    {
        List<Education_Record__c> edrecs = [SELECT Id, Name, Sales_Rep__c, Sales_Rep__r.Manager.id, Sales_Rep__r.Manager.CEM__r.id,
                                            Sales_Rep__r.RCEM__r.ID, Sales_Rep__r.CEM__r.ID, RecordType.Name, Clinical_Educator__c
                                            FROM Education_Record__c
                                            WHERE Id IN: Trigger.newMap.keySet()
                                            AND RecordType.name != 'Inservice Record'AND RecordType.name != 'CMA Record'];
        
        //create map of Clinical Educator
        Map<String, Profile__c> clinicalMap = new Map<String, Profile__c>();
        
        //create map of Clinical Educator with Id and Email Address
        for(Profile__c curr : [SELECT Id, FullName__c, E_mail_Address__c FROM Profile__c WHERE Id  IN :edIds]){
            clinicalMap.put(curr.Id,curr);
        }
        
        for (Education_Record__c edrecsUpdate: edrecs){
            
            //get old record values
            //Education_Record__c oldRec = Trigger.oldMap.get(edrecsUpdate.Id);
            
            If(Trigger.oldMap.get(edrecsUpdate.Id).Sales_Rep__c != edrecsUpdate.Sales_Rep__c){
                system.debug('IN IF STATEMENT TO UPDATE');
                // User RCEM = [Select Id, Name, Manager.Id FROM User WHERE id =: edrecsUpdate.Sales_Rep__r.CEM__r.ID];
                edrecsUpdate.RSM__c = edrecsUpdate.Sales_Rep__r.ManagerID;
                edrecsUpdate.CEM__c = edrecsUpdate.Sales_Rep__r.CEM__c;
                // edrecsUpdate.RCEM__c = RCEM.Manager.Id ;
                edrecsUpdate.RCEM__c = edrecsUpdate.Sales_Rep__r.RCEM__c;
                updRecs.add(edrecsUpdate);
                
            }//end of if oldmap check
            else if(Trigger.oldMap.get(edrecsUpdate.Id).Clinical_Educator__c != edrecsUpdate.Clinical_Educator__c){
                edrecsUpdate.Clinical_Educator_Email__c = clinicalMap.get(edrecsUpdate.Clinical_Educator__c).E_mail_Address__c;
                updRecs.add(edrecsUpdate);
            }
            
        } //end of for loop
        update updRecs;
    }//end of if (isUpdate, isAfter)
    else{
        List<Education_Record__c> edrecs = [SELECT Id, Name, Sales_Rep__c, Sales_Rep__r.Manager.id, Sales_Rep__r.Manager.CEM__r.id,
                                            Sales_Rep__r.RCEM__r.ID, Sales_Rep__r.CEM__r.ID, RecordType.Name, Clinical_Educator__c
                                            FROM Education_Record__c
                                            WHERE Id IN: Trigger.newMap.keySet()
                                            AND RecordType.name != 'Inservice Record'AND RecordType.name != 'CMA Record'];
        
        //List<Profile__c> clinicalUsers = [SELECT Id, FullName__c, E_mail_Address__c FROM Profile__c IN :edIds];
        
        //create map of Clinical Educator
        Map<String, Profile__c> clinicalMap = new Map<String, Profile__c>();
        
        //create map of Clinical Educator with Id and Email Address
        for(Profile__c curr : [SELECT Id, FullName__c, E_mail_Address__c FROM Profile__c WHERE Id  IN :edIds]){
            clinicalMap.put(curr.Id,curr);
        }
        
        for (Education_Record__c edrecsUpdate: edrecs){
            
            If( Trigger.isInsert ){
                system.debug('IN IF STATEMENT TO UPDATE');
                // User RCEM = [Select Id, Name, Manager.Id FROM User WHERE id =: edrecsUpdate.Sales_Rep__r.CEM__r.ID];
                edrecsUpdate.RSM__c = edrecsUpdate.Sales_Rep__r.ManagerID;
                edrecsUpdate.CEM__c = edrecsUpdate.Sales_Rep__r.CEM__c;
                // edrecsUpdate.RCEM__c = RCEM.Manager.Id ;
                edrecsUpdate.RCEM__c = edrecsUpdate.Sales_Rep__r.RCEM__c;
                updRecs.add(edrecsUpdate);
                
            }//end of if oldmap check
            
        } //end of for loop
        update updRecs;
    }//End of else
}