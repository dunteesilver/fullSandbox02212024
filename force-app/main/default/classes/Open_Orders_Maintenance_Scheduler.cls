global class Open_Orders_Maintenance_Scheduler Implements Schedulable{
    
    global void execute(SchedulableContext sc){
        
        // New 20Aug2018 - ESC
        Global_Maintenance newGM = new Global_Maintenance();
        newGM.dailyMaintenance('Sales');
        
        /*
        Global_Maintenance check = new Global_Maintenance();
        string obj;
        string emailSubj;
        
        for(Maintenance_Objects__c mos : Maintenance_Objects__c.getall().values()){
            if(mos.Type__c == 'Sales'){
                obj = mos.Name;
                string mKey = check.getMaintenanceKey(obj);
                
                if(mKey != NULL){
                    system.debug('mKey: ' + mKey);
                    string mCheck = check.getMaintenanceCheck(obj,mKey);
                    system.debug('mCheck: ' + mCheck);
                    if(mCheck == 'Ready'){
                        if(mos.Name == 'Open_Orders__c'){
                            Open_Orders_Maintenance_Batch purgeSales = new Open_Orders_Maintenance_Batch();
                            purgeSales.mKey = mKey;
                            Database.executeBatch(purgeSales);
                        }
                        if(mos.Name == 'Invoiced_Sales_Detail__c'){
                            Invoiced_Sales_Detail_Maintenance_Batch purgeSales = new Invoiced_Sales_Detail_Maintenance_Batch();
                            purgeSales.mKey = mKey;
                            Database.executeBatch(purgeSales);
                        }
                        if(mos.Name == 'Invoiced_Sales__c'){
                            Invoiced_Sales_Maintenance_Batch purgeSales = new Invoiced_Sales_Maintenance_Batch();
                            purgeSales.mKey = mKey;
                            Database.executeBatch(purgeSales);
                        }
                    }
                    else{
                        // Fire off email
                        list<String> emailList = check.getEmailList(obj);
                        if(emailList.size() > 0){
                            system.debug('Sending Email Now!');
                            if(mCheck.contains('Set Object Limit Hit')){
                                emailSubj = 'Maintenance [' + mos.Pretty_Name__c + ']: - Error - ' + mos.Limit__c + ' Limit Reached!';  
                            }
                            else{
                                if(mos.Name == 'Invoiced_Sales_Detail__c'){
                                    emailSubj = 'Maintenance [' + mos.Pretty_Name__c + ']: - Maintenance Completed (0/0)';   
                                }
                                else{
                                    emailSubj = 'Maintenance [' + mos.Pretty_Name__c + ']: - No Records Found!';                                       
                                }
                            }
                            string emailBody = mCheck;
                            check.sendEmailHelper(emailSubj,emailBody,emailList);
                        }
                    }
                } // mkey != NULL
            } // Type == Sales
        } // Maintenance Object For/Loop

        // End New

        /*
         * //boolean checkOpen = check.checkOpenOrders();
        // Used to manage the row counts of each object
        integer newRowCount = 0;
        integer oldRowCount = 0;
        boolean runTest = FALSE;
        
        // Open Orders - Should never have more than 15k orders to purge
        if(test.isRunningTest()){
            runTest = TRUE;
        }
        else{
            oldRowCount = [SELECT count() FROM Open_Orders__c WHERE LastModifiedDate != TODAY LIMIT 15000];
            newRowCount = [SELECT count() FROM Open_Orders__c WHERE CreatedDate = TODAY LIMIT 15000];
        }

        if(
            (newRowCount > 0 && oldRowCount != 15000)
            || runTest == TRUE
        ){
            Open_Orders_Maintenance_Batch purgeSales = new Open_Orders_Maintenance_Batch();
            Database.executeBatch(purgeSales);
        }
        else{
            // Used to manage the row counts of each object
            newRowCount = 0;
            oldRowCount = 0;
            runTest = FALSE;
            
            // Open Orders - Should never have more than 15k orders to purge
            if(test.isRunningTest()){
                runTest = TRUE;
            }
            else{
                oldRowCount = [SELECT count() FROM Invoiced_Sales_Detail__c WHERE LastModifiedDate != TODAY LIMIT 50000];
                newRowCount = [SELECT count() FROM Invoiced_Sales_Detail__c WHERE CreatedDate = TODAY LIMIT 50000];
            }
            
            if(
                (newRowCount > 0 && oldRowCount != 50000)
                || runTest == TRUE
            ){
                Invoiced_Sales_Detail_Maintenance_Batch isdm = new Invoiced_Sales_Detail_Maintenance_Batch();
                Database.executeBatch(isdm);
            }
            else{
                newRowCount = 0;
                oldRowCount = 0;
                runTest = FALSE;
                
                // Open Orders - Should never have more than 15k orders to purge
                if(test.isRunningTest()){
                    runTest = TRUE;
                }
                else{
                    oldRowCount = [SELECT count() FROM Invoiced_Sales__c WHERE LastModifiedDate != TODAY LIMIT 50000];
                    newRowCount = [SELECT count() FROM Invoiced_Sales__c WHERE CreatedDate = TODAY LIMIT 50000];
                }
                
                if(
                    (newRowCount > 0 && oldRowCount != 50000)
                    || runTest == TRUE
                ){
                    Invoiced_Sales_Maintenance_Batch isms = new Invoiced_Sales_Maintenance_Batch();
                    Database.executeBatch(isms);
                }
            }
        }
*/
    } // Class END

}