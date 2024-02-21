public class adminController{
    public void batchDeleteT10(){
        BatchDelete BDel = new BatchDelete();
        BDel.query = 'SELECT Id FROM Top_10_Selling_Products__c';
        ID batchprocessid = Database.executeBatch(BDel);
        System.debug('Returned batch process ID: ' + batchProcessId);
    }
}