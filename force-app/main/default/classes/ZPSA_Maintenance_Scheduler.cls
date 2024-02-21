global class ZPSA_Maintenance_Scheduler Implements Schedulable{
    
    global void execute(SchedulableContext sc){
        // July 2017 - ESC
        // This Purges ZPSA from Territory Alignment Rulerecords that were not updated.
        // Test Class: territory_Account_Shares_TEST
        integer zpsarowcount;
        string q;
        if(test.isRunningTest()){
            zpsarowcount = [SELECT count() FROM Territory_Alignment__c LIMIT 50000];            
        }
        else{
            zpsarowcount = [SELECT count() FROM Territory_Alignment__c WHERE LastModifiedDate != TODAY LIMIT 50000];
        }
        if(zpsarowcount > 0 && zpsarowcount != 50000){
            if(test.isRunningTest()){
                q = 'SELECT Id FROM Territory_Alignment__c LIMIT 50000';
            }
            else{
                q = 'SELECT Id FROM Territory_Alignment__c WHERE LastModifiedDate != TODAY LIMIT 50000';
            }
            BatchDelete BDel = new BatchDelete();
            BDel.Query = 'SELECT Id FROM Territory_Alignment__c WHERE Active__c = FALSE';
            BDel.Subject = 'Maintenance [Weekly ZPSA Inactive Rule Purge]: Success! - Purge Row Count: ' + zpsarowcount;
            BDel.obj = 'Account__c';
            Database.executeBatch(BDel);

            ZPSA_Maintenance_Batch zpsaMB = new ZPSA_Maintenance_Batch();
            zpsaMB.Query = q;
            Database.executeBatch(zpsaMB);
        }
    }
}