global class Invoiced_Sales_Detail_Maintenance_Batch Implements Database.Batchable<sObject> {
    // Step 1. Invoiced_Sales_Maintenance_Batch - Purges old out of date 'Invoice Sales' files
    // Step 2. Invoiced_Sales_Detail_Maintenance_Batch - Purges Invoiced Sales Detail Records not updated today
    // Step 3. Open_Orders_Maintenance_Batch - Purges Open Orders records not updated today
    // Step 4. account_Active_Sales - Associates the BU and Territory number to the account that drives 'Territory Key', 'Active Sales', and 'Active Sales My BU'
    // Step 5. Build_Sales_Accounts_Batch - Builds the 'Sales Account' records relating the Account and Territory.

    public String mKey;
    public Boolean chainMaintenance = TRUE;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        if(mKey == NULL){
            Global_Maintenance check = new Global_Maintenance();
            mkey = check.getMaintenanceKey('Invoiced_Sales_Detail__c');
        }
        
        if(mKey != NULL){
            String query = 'SELECT Id FROM Invoiced_Sales_Detail__c WHERE Maintenance_Key__c <> \'' + mKey + '\'';
            
            system.debug('Starting Batch: ' + query);
            return Database.getQueryLocator(query);
        }
        else{
            return NULL;
        }
        /* Old Style
        String query;
        query = 'SELECT Id FROM Invoiced_Sales_Detail__c WHERE LastModifiedDate <> Today';
        
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);*/
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        delete scope;
        DataBase.emptyRecycleBin(scope);
    }
    
    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [SELECT Status, NumberOfErrors, JobItemsProcessed 
                          FROM AsyncApexJob 
                          WHERE Id = :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[] {a.CreatedBy.Email};
            //mail.setToAddresses(toAddresses);
        //mail.setSubject('Maintenance [2] Invoiced Sales Detail: ' + a.Status + ' (' + a.JobItemsProcessed + '/' + a.NumberOfErrors + ')');
        //mail.setPlainTextBody ('The batch Apex job processed ' + a.JobItemsProcessed + ' batches with '+ a.NumberOfErrors + ' failures.');
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        // New Stuff - 23Aug2018 - ESC
        string emailSubj = 'Maintenance [Invoiced Sales Detail]: ' + a.Status + ' (' + a.JobItemsProcessed + '/' + a.NumberOfErrors + ')';
        string emailBody = 'The batch Apex job processed ' + a.JobItemsProcessed + ' batches with '+ a.NumberOfErrors + ' failures.';
        
        String obj = 'Invoiced_Sales_Detail__c';
        Global_Maintenance check = new Global_Maintenance();
        list<String> emailList = check.getEmailList(obj);
        if(emailList.size() > 0){
            system.debug('Sending Email Now!');
            check.sendEmailHelper(emailSubj,emailBody,emailList);
        }
        /*
        if(chainMaintenance){
            
            mKey = check.getMaintenanceKey(obj);
            system.debug('mKey: ' + mKey);
            
            if(mKey != NULL){

                string mCheck = check.getMaintenanceCheck(obj,mKey);
                system.debug('mCheck: ' + mCheck);

                if(mCheck == 'Ready'){
                    Invoiced_Sales_Maintenance_Batch isms = new Invoiced_Sales_Maintenance_Batch();
                    isms.mKey = mKey;
                    Database.executeBatch(isms);
                }
                else{
                    // Fire off email
                    emailList = check.getEmailList(obj);
                    if(emailList.size() > 0){
                        system.debug('Sending Email Now!');
                        emailSubj = 'Invoiced Sales Detail - Maintenance Check Failed!';       
                        emailBody = mCheck;
                        check.sendEmailHelper(emailSubj,emailBody,emailList);
                    }
                }
            }
        }*/
        
        //AsyncApexJob batchJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        //sendEmail( batchJob.CreatedBy.Email );

        // New Stuff
        // Get the number of apex jobs currently running 
        
        /*
        Integer jobs = [Select count() From AsyncApexJob Where JobType = 'BatchApex' and ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )];
        
        if(jobs < 4){
            // New Class Logic 20Nov2017 - ESC
            Invoiced_Sales_Helper_Class check = new Invoiced_Sales_Helper_Class();
            string mKey = check.getMaintenanceKey('Invoiced_Sales__c');
            
            if(mKey != NULL){
                Invoiced_Sales_Maintenance_Batch isms = new Invoiced_Sales_Maintenance_Batch();
                isms.mKey = mKey;
                Database.executeBatch(isms);
            }

            
        }
        else
        {
            // Used to schedule jobs 3 minutes in the future
            Datetime sysTime = System.now().addSeconds(180);
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();

            Invoiced_Sales_Maintenance_Scheduler isms = new Invoiced_Sales_Maintenance_Scheduler();
            System.schedule( 'Invoiced_Sales_Maintenance_Scheduler' + sysTime, chronExpression, isms );               
        }*/
        
        // Old Stuff
        /*
        Integer jobs = [Select count() From AsyncApexJob Where JobType = 'BatchApex' and ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )];
        if( jobs > 4 )
        {
           // try again in a minute
            Datetime sysTime = System.now().addSeconds( 60 );
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();

            Invoiced_Sales_Maintenance_Scheduler isms = new Invoiced_Sales_Maintenance_Scheduler();
            System.schedule( 'Invoiced_Sales_Maintenance_Scheduler' + sysTime, chronExpression, isms );                
        }
        else
        {
            Invoiced_Sales_Maintenance_Batch isms = new Invoiced_Sales_Maintenance_Batch();
            Database.executeBatch(isms);
        }*/
    }


}