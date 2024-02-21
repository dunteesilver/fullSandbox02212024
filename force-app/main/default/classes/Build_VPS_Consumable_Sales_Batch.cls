global class Build_VPS_Consumable_Sales_Batch Implements Database.Batchable<sObject> {
    // 06Nov2016 - ESC
    // This Class basically looks at VPS Contracts, the related Account and copies over related Invoiced Sales records with products that
    // have VPS_Consumable__c = TRUE and creates records on the 'VPS Consumables' object.
    // Run with smaller batches: 
    // Build_VPS_Consumable_Sales_Batch bvps = new Build_VPS_Consumable_Sales_Batch(); 
    // ID batchprocessid = Database.executeBatch(bvps,25);
    // 
    // Test Class: account_Page_Helper_Test  
    //   
    //DateTime dt = System.Now();
    //Long i = dt.getTime();
    public String mkey;
    
    //static string mkey2 = territory_master_maintenance.randomKey();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        
        query = 'SELECT Id, Account__c, SAP__c, RecordType.DeveloperName FROM VPS__c WHERE Active__c = TRUE';
        
        system.debug('Starting Batch: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        // Create set of Account ID's
        // Create Aggregate Map of Sales
        // Iterate over the Map to create the list of records
        // 
        // Validate record doesn't already exist
        // Clean up Old Months
        
        list<VPS__c> vpsList = (list<VPS__c>)scope;
        list<VPS_Consumables__c> newVPS = new list<VPS_Consumables__c>();
        list<VPS_Consumables__c> updateVPS = new list<VPS_Consumables__c>();
        
        map<Id, list<Invoiced_Sales__c>> isMap = new map<ID, list<Invoiced_Sales__c>>();
        map<Id, list<Invoiced_Sales__c>> isHeaterMap = new map<ID, list<Invoiced_Sales__c>>();
        map<Id, list<Invoiced_Sales__c>> isVPSMap = new map<ID, list<Invoiced_Sales__c>>();
        map<String, Id> isCheck = new map<String, Id>();
        
        set<Id> acctSet = new set<Id>();
        
        boolean secondStage = FALSE;
        //string mkey = '12345';
        
        for(VPS__c v : vpsList){
            acctSet.add(v.Account__c);
        }
        system.debug('acctSet: ' + acctSet.size());

        for(VPS_Consumables__c v : [SELECT Id, Key__c   
                                    FROM VPS_Consumables__c  
                                    WHERE Account__c =:acctSet])
        {
            isCheck.put(v.Key__c, v.Id);
        }
        //system.debug('isCheck: ' + isCheck.size());
        //system.debug('isCheck: ' + isCheck);
        
        integer rows = 0;
        /*
        list<Invoiced_Sales__c> isales = [SELECT Id, Name, Sales__c, Quantity__c,  Product__c, 
                                          Product__r.Heater_Consumables__c, Product__r.Heater_Contracts_Maxtec__c,
                                          Product__r.VPS_Consumable__c, Date__c, Account__c 
                                          FROM Invoiced_Sales__c 
                                          WHERE Account__c =:acctSet 
                                          AND (
                                              Product__r.Heater_Consumables__c = TRUE 
                                              OR Product__r.Heater_Contracts_Maxtec__c = TRUE
                                              OR Product__r.VPS_Consumable__c = TRUE
                                          ) 
                                          AND Date__c = LAST_N_MONTHS:12];*/
        for(Invoiced_Sales__c is : [SELECT Id, Name, Sales__c, Quantity__c,  Product__c, Date__c, Account__c, 
                                    Product__r.Heater_Consumables__c, Product__r.Heater_Contracts_Maxtec__c,
                                    Product__r.VPS_Consumable__c 
                                    FROM Invoiced_Sales__c 
                                    WHERE Account__c =:acctSet 
                                    AND (
                                        Product__r.Heater_Consumables__c = TRUE 
                                        OR Product__r.Heater_Contracts_Maxtec__c = TRUE
                                        OR Product__r.VPS_Consumable__c = TRUE
                                    ) ])
                                    //AND Date__c = LAST_N_MONTHS:12
        {
            //Heater_Consumables__c
            //Heater_Contracts_Maxtec__c
            //VPS_Consumable__c
            if(is.Product__r.VPS_Consumable__c){
                if(isVPSMap.containsKey(is.Account__c)){
                    isVPSMap.get(is.Account__c).add(is);
                }
                else{
                    isVPSMap.put(is.Account__c, new list<Invoiced_Sales__c>{is});    
                }
            }
            else{
                if(isHeaterMap.containsKey(is.Account__c)){
                    isHeaterMap.get(is.Account__c).add(is);
                }
                else{
                    isHeaterMap.put(is.Account__c, new list<Invoiced_Sales__c>{is});    
                }
            }
            ++rows;
            secondStage = TRUE;
        }
        system.debug('isMap: ' + isMap.size());
        system.debug('rows: ' + rows);
        
        list<Invoiced_Sales__c> isList = new list<Invoiced_Sales__c>();
        // Let's check to make sure there's Sales in the Sales Data Map
        if(secondStage){
            system.debug('Starting Loop');
            
            map<String, Boolean> upCheck = new map<String, Boolean>();
            
            rows = 0;
            for(VPS__c v : vpsList){ // Start looping through the VPS Contracts
                //isList = new list<Invoiced_Sales__c>();
                if(v.RecordType.DeveloperName == 'Heater_Contracts' && isHeaterMap.containsKey(v.Account__c)){
                    for(Invoiced_Sales__c is : isHeaterMap.get(v.Account__c)){ // Loop to load the relates Sales to the VPS Contract via VPS Consumables object
                        
                        ++rows;
                        VPS_Consumables__c newC = new VPS_Consumables__c(
                            VPS_Contract__c = v.Id,
                            Sales__c = is.Sales__c,
                            Quantity__c = is.Quantity__c,
                            Product__c = is.Product__c,
                            Date__c = is.Date__c, 
                            Account__c = is.Account__c,
                            Maintenance_Key__c = mkey,
                            Invoiced_Sales_Name__c = is.Name,
                            Key__c = v.Id + '-' + is.Id,
                            //Invoiced_Sales_ID__c = v.Id + '-' + is.Id + '-' + v.RecordType.Id // This is the key that we use to make sure the record doesn't already exist
                            Invoiced_Sales_ID__c = is.Id // This is the key that we use to make sure the record doesn't already exist
                        );
                        //if(!isCheck.containsKey(v.Id + '-' + is.Id + '-' + v.RecordType.Id)){ // Validate that this Sales record doesn't already exist
                        if(isCheck.containsKey(v.Id + '-' + is.Id)){ // Validate that this Sales record doesn't already exist
                            // Update the VPS Consumables Record
                            newC.Id = isCheck.get(v.Id + '-' + is.Id);
                            updateVPS.add(newC);
                            
                        }
                        else{
                            // Create the VPS Consumables Record
                            newVPS.add(newC);
                        }
                    }
                }
                else if(v.RecordType.DeveloperName == 'VPS_Contracts' && isVPSMap.containsKey(v.Account__c)){
                    for(Invoiced_Sales__c is : isVPSMap.get(v.Account__c)){ // Loop to load the relates Sales to the VPS Contract via VPS Consumables object
                        ++rows;
                        
                        // Create the VPS Consumables Record
                        VPS_Consumables__c newC = new VPS_Consumables__c(
                            VPS_Contract__c = v.Id,
                            Sales__c = is.Sales__c,
                            Quantity__c = is.Quantity__c,
                            Product__c = is.Product__c,
                            Date__c = is.Date__c, 
                            Account__c = is.Account__c,
                            Maintenance_Key__c = mkey,
                            Invoiced_Sales_Name__c = is.Name,
                            Key__c = v.Id + '-' + is.Id,
                            Invoiced_Sales_ID__c = is.Id // This is the key that we use to make sure the record doesn't already exist
                        );
                        if(isCheck.containsKey(v.Id + '-' + is.Id)){ // Validate that this Sales record doesn't already exist
                            // Update the VPS Consumables Record
                            newC.Id = isCheck.get(v.Id + '-' + is.Id);
                            updateVPS.add(newC);
                            
                        }
                        else{
                            // Create the VPS Consumables Record
                            newVPS.add(newC);
                        }
                        
                    }
                }
            }
            system.debug('rows: ' + rows);
            if(updateVPS.size() > 0){
                system.debug('-- Updating ' + updateVPS.size() + 'Records --');
                update updateVPS;                
            }
            /*
            else{
                system.debug('Exiting Update - Nothing to do! -- newVPS Size == 0');
            }*/
            if(newVPS.size() > 0){
                system.debug('-- Inserting ' + newVPS.size() + 'Records --');
                insert newVPS;
            }
            /*
            else{
                system.debug('Exiting Insert - Nothing to do! -- newVPS Size == 0');
            }*/
            
            // Clean up time!
            //for(VPS_Consumables__c v : ){
                // all sales isCheck
                // 
            //}
        }
        /*
        else{
            system.debug('Exiting - Nothing to do! -- isMap size == 0');
        }*/
    }
    
    
    global void finish(Database.BatchableContext BC){
        //UserInfo.getUserEmail();
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Build VPS Consumables Finished: ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.JobItemsProcessed +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}