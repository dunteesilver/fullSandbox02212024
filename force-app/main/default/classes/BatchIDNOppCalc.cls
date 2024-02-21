global class BatchIDNOppCalc implements Database.Batchable<sObject> {

global Database.querylocator start(Database.BatchableContext BC){
    String IDNRecType = '012M00000004a8s';
    String query = 'SELECT Id FROM Opportunity WHERE RecordTypeID=:IDNRecType';
    return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){
/*
    for(sObject s : scope){
        Double totalAmt = 0;
        Double totalIA = 0;
        Double totalVascular = 0;
        Double totalAR = 0;
        Double totalSurgical = 0;
        Opportunity opp = (Opportunity) s;
        
        for(Opportunity childOpp : [SELECT Id, Amount, RecordTypeId FROM Opportunity WHERE IDN_Parent_Opportunity__c = :opp.Id]){
            totalAmt += childOpp.Amount;
            if(childOpp.RecordTypeId=='012E0000000RGuR'){
                totalIA += childOpp.Amount;
            }
            if(childOpp.RecordTypeId=='012E0000000PQUt' || childOpp.RecordTypeId=='012E0000000PS2q' || childOpp.RecordTypeId=='012E0000000QHTO'){
                totalVascular += childOpp.Amount;
            }
            if(childOpp.RecordTypeId=='012E0000000R4Cz'){
                totalAR += childOpp.Amount;
            }
            if(childOpp.RecordTypeId=='012E0000000R4kk'){
                totalSurgical += childOpp.Amount;
            }
        }
        
          opp.Amount = totalAmt;
          opp.Total_Interventional__c = totalIA;
          opp.Total_Vascular__c = totalVascular;
          opp.Total_AR__c = totalAR;
          opp.Total_Surgical__c = totalSurgical;
          Update opp;
    }
*/    
}

global void finish(Database.BatchableContext BC){

}


}