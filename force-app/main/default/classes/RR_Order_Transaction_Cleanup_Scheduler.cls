global class RR_Order_Transaction_Cleanup_Scheduler Implements Schedulable{
        
    global void execute(SchedulableContext sc){
        integer rowcount = [SELECT count() From LATAM_Order_Transaction__c where LastModifiedDate != Today LIMIT 1000];
        if(rowcount != 1000 && rowcount > 0){
            BatchDelete BDel = new BatchDelete();
            BDel.Query = 'SELECT Id From LATAM_Order_Transaction__c where LastModifiedDate != Today';
            BDel.Subject = 'Maintenance [RR Order Transaction Purge]: Successful! - ';
            BDEL.obj = 'Open_Orders__c';
            Database.executeBatch(BDel);    
        }
        
    }
}