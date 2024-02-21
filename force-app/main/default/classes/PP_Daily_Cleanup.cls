/*********************************************************************
* Description      : Schedulable Class for Contract Details.
* Test Class       : PP_Daily_Cleanup_Test
* Author(s)        : Eric Clay
**********************************************************************/
global class PP_Daily_Cleanup Implements Schedulable{

    global void execute(SchedulableContext sc){
        Global_Maintenance newGM = new Global_Maintenance();
        newGM.dailyMaintenance('PP');
        //ContractClean();
    }
/*
    public void ContractClean(){
        // Class designed to clean up the Contract Customer and Contract Material records that are changed in the system
        // and are no longer active. Usually between 1000-25000 on average. If the count is below 30000 we will auto purge those
        // records. If the count is above we send an email to alert the admin that something is wrong and to check the
        // report to make sure the automatic data load didn't fail and/or to handle a large change. Use the following to purge
        // those records using the Developer Console and the 'Open Excute Anonymous Window' under the Debug drop down:
        // BatchDelete BDel = new BatchDelete();
        // BDel.query = 'SELECT Name FROM Contract_Material__c WHERE Active__c = TRUE and LASTMODIFIEDDATE <> TODAY';
        // ID batchprocessid = Database.executeBatch(BDel,50);
        // Eric Clay / 09Oct2015
        //

        // New Logic 25Aug2018 ESC
        // Custom Settings do not take a SOQL hit
        
        Invoiced_Sales_Helper_Class check = new Invoiced_Sales_Helper_Class();
        string obj;
        string mKey;
        string emailSubj;
        integer ccCount;
        integer rowLimit = 0;

        for(Maintenance_Objects__c mos : Maintenance_Objects__c.getall().values()){
            if(mos.Type__c == 'PP'){
                obj = mos.Name;
                mKey = check.getMaintenanceKey(obj);
                rowLimit = integer.valueOf(mos.Limit__c);
                list<String> emailList = check.getEmailList(obj);
                
                if(mKey != NULL){
                    system.debug('mKey: ' + mKey);
                    string mCheck = check.getMaintenanceCheck(obj,mKey);
                    
                    system.debug('mCheck: ' + mCheck);
                    if(mCheck == 'Ready'){
                        ccCount = database.countQuery('SELECT count() From ' + mos.Name + ' WHERE Maintenance_Key__c != \'' + mkey + '\'');
                        BatchDelete BDel = new BatchDelete();
                        BDel.Query = 'SELECT Id From ' + mos.Name + ' WHERE Maintenance_Key__c != \'' + mkey + '\'';
                        BDel.Subject = 'Maintenance [' + mos.Pretty_Name__c + ']: Purge Success! - ' + ccCount + ' - ';
                        BDEL.emailList = emailList;
                        Database.executeBatch(BDel);
                    }
                    else{
                        // Error Happened! - Fire off email
                        if(emailList.size() > 0){
                            system.debug('Sending Email Now!');
                            if(mCheck.contains('Set Object Limit Hit')){
                                ccCount = database.countQuery('SELECT count() From ' + mos.Name + ' WHERE Maintenance_Key__c != \'' + mkey + '\'');
                                emailSubj = 'Maintenance [' + mos.Pretty_Name__c + ']: - Error - ' + ccCount + ' over the ' + rowLimit + ' Limit!';  
                            }
                            else{
                                emailSubj = 'Maintenance [' + mos.Pretty_Name__c + ']: - No Records Found!';                                       
                            }
                            
                            string emailBody = mCheck;
                            if(mos.Report_Id__c != NULL){
                                emailBody = emailBody + '        ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + mos.Report_Id__c;
                            }
                            check.sendEmailHelper(emailSubj,emailBody,emailList);
                        }
                    }
                }
            }
        }
        
        // End New Logic
        // 
        /* Old Logic
        // New Logic - Use the Maintenance Key to purge out the old records.
        list<String> toAddresses = new list<String>{'eric.clay@teleflex.com'};
        string body;
        string toAddress = 'eric.clay@teleflex.com';
        string mkey = '123';
        integer ccCount;

        try{
            mkey = [SELECT Maintenance_Key__c FROM Contract_Customer__c ORDER BY Id DESC LIMIT 1].Maintenance_Key__c;
            ccCount = [SELECT count() FROM Contract_Customer__c WHERE Maintenance_Key__c != :mkey LIMIT 40000];
        }
        catch (Exception e) {
        }

        if(ccCount < 40000 && ccCount > 0 && mkey != '123'){
            BatchDelete BDel = new BatchDelete();
            BDel.Query = 'SELECT Id From Contract_Customer__c WHERE Maintenance_Key__c != \'' + mkey + '\'';
            BDel.Subject = 'Contract Customer Purge Success! - ' + ccCount + ' - ';
            Database.executeBatch(BDel);
        }
        else{
            body = 'Contract Customer Auto Purge Failed. Size of the list: ' + ccCount + '. ';
            body += 'If 50,000 then the import might have failed.\n\n';
            body += 'Use this Report to check: https://teleflex.my.salesforce.com/00OE0000003BCJO \n';

            //toAddresses.add('eric.clay@teleflex.com');
            //String[] toAddresses = new String[] {'eric.clay@teleflex.com'};
            Messaging.SingleEmailMessage outbound = new Messaging.SingleEmailMessage();
            outbound.setSenderDisplayName('Apex Automation Error Handler');
            outbound.setToAddresses(toAddresses);
            outbound.setSubject('Contract Customer Purge Error! - ' + ccCount);
            outbound.setUseSignature(false);
            outbound.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {outbound});
        }

        // Reset
        mkey = '123';
        ccCount = 0;

        // Contract Material Start
        try{
            mkey = [SELECT Maintenance_Key__c FROM Contract_Material__c ORDER BY Id DESC LIMIT 1].Maintenance_Key__c;
            ccCount = [SELECT count() FROM Contract_Material__c WHERE Maintenance_Key__c != :mkey LIMIT 40000];
        }
        catch (Exception e) {
        }


        if(ccCount < 40000 && ccCount > 0 && mkey != '123'){
            BatchDelete BDel = new BatchDelete();
            BDel.Query = 'SELECT Id From Contract_Material__c WHERE Maintenance_Key__c != \'' + mkey + '\'';
            BDel.Subject = 'Contract Material Purge Success! - ' + ccCount + ' - ';
            Database.executeBatch(BDel);
        }
        else{
            body = 'Contract Material Auto Purge Failed. Size of the list: ' + ccCount + '. ';
            body += 'If 50,000 then the import might have failed.\n\n';
            body += 'Use this Report to check: https://teleflex.my.salesforce.com/00OE0000003BCJO \n';

            //toAddresses.add('eric.clay@teleflex.com');
            //String[] toAddresses = new String[] {'eric.clay@teleflex.com'};
            Messaging.SingleEmailMessage outbound = new Messaging.SingleEmailMessage();
            outbound.setSenderDisplayName('Apex Automation Error Handler');
            outbound.setToAddresses(toAddresses);
            outbound.setSubject('Contract Material Purge Error! - ' + ccCount + ' - ');
            outbound.setUseSignature(false);
            outbound.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {outbound});
        }
    }*/
}