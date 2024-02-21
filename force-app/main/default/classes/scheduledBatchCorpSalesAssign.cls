global class scheduledBatchCorpSalesAssign implements Schedulable{
   global void execute(SchedulableContext sc) {
      BatchCorpSalesAssign ba = new BatchCorpSalesAssign(); 
      database.executebatch(ba,50);
      
      BatchIDNOppCalc childOpp = new BatchIDNOppCalc(); 
      database.executebatch(childOpp,50);
   }
}