global class scheduledBatchContactBU implements Schedulable{
   global void execute(SchedulableContext sc) {
      BatchContactBU b = new BatchContactBU(); 
      database.executebatch(b);
   }
}