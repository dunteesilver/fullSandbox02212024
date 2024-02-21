global class territory_Quota_Maintenance_Scheduler Implements Schedulable{
    // Test Class: Invoiced_Global_Test_Class
    
    global void execute(SchedulableContext sc){
        // July 2017 - ESC
        // This Purges Territory Quota records that were not updated
        integer zpsarowcount;
        list<Territory_Quota__c> tqRemoveList = new list<Territory_Quota__c>();
        list<Territory_Quota__c> tqTickleList = new list<Territory_Quota__c>();

        if(test.isRunningTest()){
            zpsarowcount = [SELECT count() FROM Territory_Quota__c LIMIT 10000];
        }
        else{
            zpsarowcount = [SELECT count() FROM Territory_Quota__c WHERE LastModifiedDate != TODAY AND Empty_Quota__c = FALSE LIMIT 25000];
        }
        if(zpsarowcount > 0 && zpsarowcount != 10000){
            // Changed 04Sept2017 - ESC
            // Need to support running the class in Serial so switching from calling the delete batch to deleting the list before tickling the remaining records.
            for(Territory_Quota__c tq : [SELECT Id 
                                         FROM Territory_Quota__c 
                                         WHERE LastModifiedDate != TODAY 
                                         AND Empty_Quota__c = FALSE 
                                         LIMIT 25000])
            {
                tqRemoveList.add(tq);
            }
            /*
            BatchDelete BDel = new BatchDelete();
            BDel.Query = 'SELECT Id From Territory_Quota__c WHERE LastModifiedDate != TODAY AND Empty_Quota__c = FALSE LIMIT 25000';
            BDel.Subject = 'Territory Maintenance Success! - Row Count: ' + zpsarowcount;
            Database.executeBatch(BDel);*/
        }
        if(tqRemoveList.size() > 0){
            DELETE tqRemoveList;
        }
        // Added 04Sept2017 - ESC
        // Ensures that all Territory Quota Files have todays date - Might overlap with the batch delete but not worth worrying about.
        BatchTickle BTickle = new BatchTickle();
        BTickle.query = 'SELECT Id From Territory_Quota__c WHERE LastModifiedDate != TODAY';
        Database.executeBatch(BTickle);
    }
}