/*********************************************************************
* Description      : Controller Class for account_Active_Flag_Batch.
* Test Class       : account_Active_Flag_Batch_Test
* VisualForce      : N/A
* Author(s)        : Eric Clay
**********************************************************************/
global class account_Active_Flag_Batch Implements Schedulable{

    global void execute(SchedulableContext sc){
        accountActiveFlag();
    }

    public void accountActiveFlag(){
        // Scheduled class designed to flip accounts 'ERP Active' flag to FALSE when not updated
        // by the daily import process to.
        // Eric Clay / March 2016

        string body_str;
        string subject_str;
        list<Account> sanityCheck = [SELECT ID
                                     FROM Account
                                     WHERE ERP_Active__c = TRUE
                                     AND Last_SAP_Update__c = TODAY
                                     AND Last_SAP_Update__c != NULL
                                     LIMIT 10000];
        list<Account> updateAccount = [SELECT ID
                                       FROM Account
                                       WHERE zBlock__c = '00'
                                       AND Last_SAP_Update__c != NULL
                                       AND Last_SAP_Update__c != TODAY
                                       LIMIT 5000];
        
        if(updateAccount.size() <= 5000 && (sanityCheck.size() == 10000 || sanityCheck.size() == 1)){
            for(Account a : updateAccount){
                a.ERP_Active__c = FALSE;
                a.zBlock__c = 'Z1';
            }
            UPDATE updateAccount;

            subject_str = 'Active Account Flag - Success!!! - ';
            body_str = 'Account ERP Active Change Sucessful. Size of the list: ';

        }
        else{
            subject_str = 'Active Account Flag - Failure - ';
            body_str = 'Account ERP Active Change Failed. Size of the list: ';
        }
        string body = body_str + updateAccount.size() + '. ';
        body += 'If 50,000 then the import might have failed.\n\n';
        string toAddress = 'eric.clay@teleflex.com';

        String[] toAddresses = new String[] {'eric.clay@teleflex.com'};
            Messaging.SingleEmailMessage outbound = new Messaging.SingleEmailMessage();
        outbound.setSenderDisplayName('Apex Automation Error Handler');
        outbound.setToAddresses(toAddresses);
        outbound.setSubject(subject_str + updateAccount.size());
        outbound.setUseSignature(false);
        outbound.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {outbound});
    }

}