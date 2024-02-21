public class Global_Maintenance {

    public void dailyMaintenance(String type){
        // New Logic 25Aug2018 ESC
        // Custom Settings do not take a SOQL hit
        
        string obj;
        string mKey;
        string emailSubj;
        string mCheck;
        integer ccCount;
        integer rowLimit = 0;
        integer mLimit = 0;

        for(Maintenance_Objects__c mos : Maintenance_Objects__c.getall().values()){
            if(mos.Type__c == type){
                mLimit = 0;
                obj = mos.Name;
                rowLimit = integer.valueOf(mos.Limit__c);
                list<String> emailList = getEmailList(obj);

                mKey = getMaintenanceKey(obj);
                if(mKey != NULL){
                    
                    Map<String,Maintenance_Objects__c> moMap = Maintenance_Objects__c.getAll();
                    
                    // Set the limit from the Custom Setting
                    if(moMap.get(obj).Limit__c != NULL){
                        mLimit = integer.valueOf(moMap.get(obj).Limit__c);
                    }
                    
                    // Pull the count from the object
                    string setQuery = 'SELECT count() FROM ' + obj + ' WHERE Maintenance_Key__c != \'' + mKey + '\' LIMIT ' + mLimit;
                    integer dbcount = database.countQuery(setQuery);
                    
                    // Determine if maintenance can proceed
                    if(dbcount == 0){
                        mCheck = 'Database Maintenance: 0 Records to Purge. This is ok for Invoiced Sales Detail - all other objects start troubleshooting why.';
                    }
                    else if(dbcount >= mLimit){
                        mCheck = 'Database Maintenance: ' + mLimit + ' - Set Object Limit Hit. Run the maintenance report and then check timing, that the upload is not still running, or that the files generated completely (disk space).';
                    }
                    else{
                        mCheck = 'Ready';
                    }
                    
                    system.debug('mCheck: ' + mCheck);
                    if(mCheck == 'Ready'){
                        BatchDelete BDel = new BatchDelete();
                        BDel.Query = 'SELECT Id From ' + mos.Name + ' WHERE Maintenance_Key__c != \'' + mkey + '\'';
                        BDel.Subject = 'Maintenance [' + mos.Pretty_Name__c + ']: Purge Success! - ' + dbcount + ' - ';
                        BDEL.obj = obj;
                        Database.executeBatch(BDel);
                    }
                    else{
                        // Error Happened! - Fire off email
                        if(emailList.size() > 0){
                            system.debug('Sending Email Now!');
                            if(mCheck.contains('Set Object Limit Hit')){
                                emailSubj = 'Maintenance [' + mos.Pretty_Name__c + ']: - Error - ' + dbcount + ' over the ' + rowLimit + ' Limit!';  
                            }
                            else{
                                emailSubj = 'Maintenance [' + mos.Pretty_Name__c + ']: - No Records Found!';                                       
                            }
                            
                            string emailBody = mCheck;
                            if(mos.Report_Id__c != NULL){
                                emailBody = emailBody + '<br/><br/>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + mos.Report_Id__c;
                            }
                            sendEmailHelper(emailSubj,emailBody,emailList);
                        } // Error Email 
                    } // ELSE
                } // MKEY Exists
            } // Type Match
        } // For LOOP
    }

    public string getMaintenanceKey(string obj){
        string setQuery = 'SELECT Maintenance_Key__c FROM ' + obj + ' ORDER BY CreatedDate DESC LIMIT 1';
        string mKey;
        for(sObject s : database.query(setQuery)){
            mKey = (String) s.get('Maintenance_Key__c');
        }
        return mKey;
    }
    /*
    public boolean checkObj(string obj){
        boolean quickCheck = FALSE;
        for(Maintenance_Objects__c mo : Maintenance_Objects__c.getall().values()){
            if(mo.Name == obj){
                quickCheck = TRUE;
            }
        }
        return quickCheck;
    }*/
    
    public list<String> getEmailList(string obj){
        list<String> emailList = new list<String>();
        if(obj != NULL){
            for(SObject mea : Maintenance_Email_Addresses__c.getall().values()){
                if((Boolean) mea.get(obj) == TRUE){
                    emailList.add((String) mea.get('Email__c'));
                    if((String) mea.get('SMS_Notification__c') != NULL){
                        emailList.add((String) mea.get('SMS_Notification__c'));
                        system.debug('SMS Email Added: ' + (String) mea.get('SMS_Notification__c'));
                    }
                    system.debug('Email Added: ' + (String) mea.get('Email__c'));
                }
            }
        }
        
        return emailList;
    }
    /*
    public string getMaintenanceCheck(string obj, string key){
        // Created: 20Aug2018 - ESC
        string sizeCheck;
        integer mLimit = 0;
        
        Map<String,Maintenance_Objects__c> moMap = Maintenance_Objects__c.getAll();
        
        // Set the limit from the Custom Setting
        if(moMap.get(obj).Limit__c != NULL){
            mLimit = integer.valueOf(moMap.get(obj).Limit__c);
        }
        
        // Pull the count from the object
        string setQuery = 'SELECT count() FROM ' + obj + ' WHERE Maintenance_Key__c != \'' + key + '\' LIMIT ' + mLimit;
        integer dbcount = database.countQuery(setQuery);

        // Determine if maintenance can proceed
        if(dbcount == 0){
            sizeCheck = 'Database Maintenance: 0 Records to Purge. This is ok for Invoiced Sales Detail - all other objects start troubleshooting why.';
        }
        else if(dbcount >= mLimit){
            sizeCheck = 'Database Maintenance: ' + mLimit + ' - Set Object Limit Hit. Run the maintenance report and then check timing, that the upload is not still running, or that the files generated completely (disk space).';
        }
        else{
            sizeCheck = 'Ready';
        }
        system.debug('sizeCheck: ' + sizeCheck);
        return sizeCheck;
    }*/
    
    public void sendEmailHelper(string emailSubj, string emailBody, list<String> emailList){
        Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
        newEmail.setToAddresses(emailList);
        newEmail.setSubject(emailSubj);
        newEmail.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { newEmail });
    }
    
}