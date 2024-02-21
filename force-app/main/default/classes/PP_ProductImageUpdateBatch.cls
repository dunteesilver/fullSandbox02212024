//created by Dun Silver
global class PP_ProductImageUpdateBatch implements Schedulable,Database.AllowsCallouts,Database.Batchable<sObject> {
    //Schedulable section
    global String query = '';

    //constructor w/ option to pass query
    public PP_ProductImageUpdateBatch(String q){
        query = q;
    }

    //constructor w/ option to pass query
    public PP_ProductImageUpdateBatch(){
    }
    
    //schedulable method
    global void Schedule()
    {
        PP_ProductImageUpdateBatch toSchedule = new PP_ProductImageUpdateBatch(query);
        string sch = '0 0 12 * * *';//Seconds,Mins,Hrs,Day of Month,Month,Day of Week, Year(Optional)
        System.schedule('ProductImageUpdateBatch', sch, toSchedule);
    }//end of void schedule

    //Batch Section
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //check if query has value
        System.debug('*** query *** ' + query);
        if(query == ''){
            System.debug('*** query empty ***');
            query = 'SELECT Id FROM Product2 WHERE IsActive = true';
        }
        return Database.getQueryLocator(query);
    }//end of start

    //execute method for schedulable
    global void execute(SchedulableContext sc)
    {
        //Start the batch, limit it to 10 to avoid callout governor limit.
        Database.executeBatch(new PP_ProductImageUpdateBatch(query),10);
    }//end of void execute

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Id> productIds = new List<Id>();
        for(sObject obj : scope)
        {
            productIds.add(obj.Id);
        }
        //PP_ProductImageFetcher.UpdateProductImageBatch(productIds);
        PP_ProductImageFetcher.UpdateProductImageBatchNew(productIds);
    }

    //finish method (another process can be started here or email results)
    global void finish(Database.BatchableContext BC){
       // Get the ID of the AsyncApexJob representing this batch job
       // from Database.BatchableContext.
       // Query the AsyncApexJob object to retrieve the current job's information.
       String emailSubject;
       String emailBody;
       String[] toAddresses;

       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                        FROM AsyncApexJob WHERE Id =
                        :BC.getJobId()];
       // Send an email to the Apex job's submitter notifying of job completion.
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       toAddresses = new String[] {a.CreatedBy.Email};
       emailSubject = 'Batch Product Image Update Complete: ' + a.Status;
       emailBody = 'The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.';

       //call global email method
       Global_Maintenance gb = new Global_Maintenance();
       gb.sendEmailHelper(emailSubject, emailBody, toAddresses);
    }//end of void finish
   

}