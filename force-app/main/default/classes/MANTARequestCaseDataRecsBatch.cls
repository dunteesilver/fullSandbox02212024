global class MANTARequestCaseDataRecsBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    private List<MANTA_Proctorship_Request__c> notifyTrainersToAddCaseDataRecsLst = new List<MANTA_Proctorship_Request__c>();
    
    /*constructor
    public batchExample(String passedString) {
        System.debug('- Constructor: Begin -');
        System.debug('- Constructor: End -');
    }
	*/
    
    //the "start" method is called at the beginning of a batch Apex job
    //use this method to collect the records (of objects) to be passed to the "execute" method for processing
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('- start: Begin -');
        System.debug('notifyTrainersToAddCaseDataRecsLst.size(): '+notifyTrainersToAddCaseDataRecsLst.size());
        System.debug('- start: End -');
        return Database.getQueryLocator('select id, isReqHaveCaseRecs__c, is5daysPastCaseDate__c, Proctor__c, Proctor__r.Name, Hospital__c, Hospital__r.Name, Case_Date__c, Case_Initiator__r.Name ,Physician__c, Physician__r.Name, Region__c  from MANTA_Proctorship_Request__c where isReqHaveCaseRecs__c=0 and is5daysPastCaseDate__c=true and status__c=\'Accepted\' and isArchived__c=false '); //return the query locator
    }
    

                                        																												
    
    //the "execute" method is called after the "start" method has been invoked and passed a batch of records
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('- execute: Begin -');
        for (SObject s : scope) { //for all sObjects in the batch
            MANTA_Proctorship_Request__c m = (MANTA_Proctorship_Request__c)s; //cast the MANTA_Proctorship_Request__c object from the scope
            if(!String.isBlank(m.Proctor__c)){notifyTrainersToAddCaseDataRecsLst.add(m);}
            System.debug('notifyTrainersToAddCaseDataRecsLst.size(): '+notifyTrainersToAddCaseDataRecsLst.size());
        }
        System.debug('- execute: End -');
    }
    
    //the "finish" method is called once all the batches are processed
    public void finish(Database.BatchableContext bc) {
        System.debug('- finish: Begin -');
        System.debug('notifyTrainersToAddCaseDataRecsLst: '+notifyTrainersToAddCaseDataRecsLst);
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        
        OrgWideEmailAddress orgEm = [select Id, Address from OrgWideEmailAddress WHERE Address='manta@teleflex.com'];
        User admUsr = [select id from user where name like '%Surya Arvan%'];
        
        for (MANTA_Proctorship_Request__c mantaObj : notifyTrainersToAddCaseDataRecsLst) {
        
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            message.setToAddresses(new String[] {mantaObj.Proctor__c});
            message.setBccAddresses(new String[] {admUsr.Id});
            message.setOrgWideEmailAddressId(orgEm.Id);   
            message.setReplyTo('manta@teleflex.com');
            message.optOutPolicy = 'SEND';
            message.subject = 'Case Data Records not entered yet';
            message.htmlbody = 'Hello '+ mantaObj.Proctor__r.Name+',<br/><br/>'
                +'You are being notified that your Hospital request is pending to be added with Case Data Records.<br/> '
                +'Hospital:'+ mantaObj.Hospital__r.Name+' <br/>'
                +'Region:' + mantaObj.Region__c+' <br/>'
                +'Case Date:' + mantaObj.Case_Date__c+' <br/>'
                +'Physician:' + mantaObj.Physician__r.Name+' <br/>'
                +'Case Initiator:' + mantaObj.Case_Initiator__r.Name+' <br/>';
            
        messages.add(message);
        
        }
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                             + results[0].errors[0].message);
            }
        
        
        System.debug('- finish: End -');
    }
    
    global void execute(SchedulableContext sc)
    {
        MANTARequestCaseDataRecsBatch btch = new MANTARequestCaseDataRecsBatch();
		Database.executeBatch(btch);
    }

}