global class BatchVidacareMerge implements Database.Batchable<sObject> {

global Database.querylocator start(Database.BatchableContext BC){
    String query = 'SELECT Id, Name, Account__c, ERP_Code__c FROM ERP_Codes__c WHERE ERP_System__c = \'Vidacare\'';
    return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){

    for(sObject s : scope){
        ERP_Codes__c temp = (ERP_Codes__c) s;
        system.debug(temp.Name);
        List<Account> master = [SELECT Id FROM Account WHERE Id = :temp.Account__c];
        List<Account> acct = [SELECT Id from Account WHERE BP__c = :temp.ERP_Code__c];
        
        if (acct.size() > 0){
            Integer count = 0;
            While(count < acct.size()){
                merge master[0] acct[count];
                count += 1;
            }
        }
    }
    
}

global void finish(Database.BatchableContext BC){
}


}