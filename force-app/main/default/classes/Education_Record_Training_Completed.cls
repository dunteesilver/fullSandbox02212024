global class Education_Record_Training_Completed implements Schedulable{
    global void execute(SchedulableContext SC) {

        List<Education_Record__c> updateER = new List<Education_Record__c>();
        string query;
        if(test.isRunningTest()){
            query = 'SELECT Id, Stage__c FROM Education_Record__c WHERE Ending_Date__c = THIS_WEEK AND Stage__c = \'Confirmed\' AND Legacy_Confirmed_Educator_Check__c = FALSE';
        }
        else{
            query = 'SELECT Id, Stage__c FROM Education_Record__c WHERE Ending_Date__c = Today AND Stage__c = \'Confirmed\' AND Legacy_Confirmed_Educator_Check__c = FALSE';            
        }

        
        for(Education_Record__c er: database.query(query))
        {
            er.stage__c = 'Training Completed';
            updateER.add(er);
        }
        if(updateER.size() > 0){
            Database.update(updateER,false);
        }
        
        
        /* Old Class - Creation of the CRF/Expense records is now handled with the trigger as is changing the status from New to Save.
         * 14Jan2018 - ESC
List<Education_Record__c> edrecUpdate = new List<Education_Record__c>();
        List<CE_Reimbursement_Expense__c> crfcmaUpdate = new List<CE_Reimbursement_Expense__c>();
        String educErrors = '';
        String crfErrors = '';

        List<Education_Record__c> edrec = [Select Id, Name, Stage__c, Copy_RecordType__c, OwnerId, Clinical_Educator__r.Hourly_Rate__c
                                            From Education_Record__c
                                            Where Ending_Date__c=Today AND Stage__c ='Confirmed' AND Clinical_Educator__r.Hourly_Rate__c != null
                                            AND (Copy_RecordType__c ='Live Education Program Request' OR Copy_RecordType__c ='Inservice Record'
                                            OR Copy_RecordType__c ='Strategic Marketing Education Program Request')];

        for(Education_Record__c er: edrec){
            //if(er.Stage__c == 'Confirmed' && (er.Copy_RecordType__c =='Live Education Program Request' || er.Copy_RecordType__c =='Inservice Record' ||) )
            er.stage__c = 'Training Completed';
            edrecUpdate.add(er);
        }

        Database.update(edrecUpdate,false);
        //update edrecUpdate;
        System.debug(JSON.serializePretty(edrecUpdate));

        List<CE_Reimbursement_Expense__c> crfcma = [Select Id, Name, Education_Record__r.Stage__c, Education_Record__r.Ending_Date__c, Status__c, Education_Record__r.Copy_RecordType__c
                                                    From CE_Reimbursement_Expense__c
                                                    Where Education_Record__r.Ending_Date__c=Today AND Education_Record__r.Stage__c ='Confirmed'
                                                    AND (Education_Record__r.Copy_RecordType__c ='CMA Record'
                                                    OR Education_Record__r.Copy_RecordType__c ='CMA Record MEG'
                                                    OR Education_Record__r.Copy_RecordType__c ='CMA Procedural Lab'
                                                    OR Education_Record__r.Copy_RecordType__c ='CMA Speaking Engagement') AND Status__c = 'Save'];

        for(CE_Reimbursement_Expense__c ercma: crfcma){
            ercma.status__c = 'New';
            crfcmaUpdate.add(ercma);
        }

        Database.update(crfcmaUpdate,false);
        //update crfcmaUpdate;
        System.debug(JSON.serializePretty(crfcmaUpdate));*/

    }//end of schedulable method

}//end of class