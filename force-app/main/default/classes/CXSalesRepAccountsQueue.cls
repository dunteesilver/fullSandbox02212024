public class CXSalesRepAccountsQueue implements Queueable {
    
    //public static set<Id> usrWoAccs = new set<Id>();
    public static set<Id> usrWoTerrNum = new set<Id>();
    
    
    public integer queueLmt = 50;
    public set<Id> accIds = new set<Id>();
    public List<Id> SalesRepIDs = new List<Id>();
    public map<Id,Set<Id>> SRvsAccsMap = new map<Id,Set<Id>>();
    public map<Id,Set<Id>> SRvsAccsMapFinal = new map<Id,Set<Id>>();
    public static integer lmt = 100;
    public static integer queueDept=1;
    public Boolean hasMoreRecs;
    public Boolean StartNewTransaction;
    public Id hasMoreRecsLmtID;
    public Integer recsCnt = 0;
    
    
    public CXSalesRepAccountsQueue(List<Id> SalesRepIDs){
        this.SalesRepIDs = SalesRepIDs;
        this.hasMoreRecs=false;
        this.StartNewTransaction = false;
    }
    
    public CXSalesRepAccountsQueue(set<Id> accIds, 
                                   List<Id> SalesRepIDs, 
                                   map<Id,Set<Id>> SRvsAccsMap, 
                                   map<Id,Set<Id>> SRvsAccsMapFinal, 
                                   Boolean hasMoreRecs, 
                                   Boolean StartNewTransaction,
                                   Id hasMoreRecsLmtID, 
                                   Integer recsCnt
                                   
                                   //,set<Id> usrWoAccs
                                  ){
                                      this.accIds = accIds;
                                      this.SalesRepIDs = SalesRepIDs;
                                      this.SRvsAccsMap = SRvsAccsMap;
                                      this.SRvsAccsMapFinal = SRvsAccsMapFinal;
                                      this.hasMoreRecs = hasMoreRecs;
                                      this.StartNewTransaction = StartNewTransaction;
                                      this.hasMoreRecsLmtID = hasMoreRecsLmtID;
                                      this.recsCnt = recsCnt;
                                  }
    
    public void execute(QueueableContext context) {
        
        if(System.test.isRunningTest()) queueLmt = 1;
        
        if(SalesRepIDs.size()>0){
            //system.debug('SRvsAccsMap.size()-->'+SRvsAccsMap.size());
            for(integer i=0; i<queueLmt;i++) {
                //system.debug('SRvsAccsMap.size()-->'+SRvsAccsMap.size());
                if(SalesRepIDs.size()>0 && (!StartNewTransaction || i==0)){
                    //system.debug('inside if');
                    //system.debug('iter i-->'+i);
                    //system.debug('SalesRepIDs[0] -->'+SalesRepIDs[0]);
                    getAllSalesRepsToEmail(SalesRepIDs[0]);
                    if(!hasMoreRecs){SalesRepIDs.remove(0);} } else break;
            }
            //system.debug('usrWoTerrNum.size-->'+usrWoTerrNum.size());
        }
        if(SalesRepIDs.size()>0) { if(queueDept < 50) {System.enqueueJob(new CXSalesRepAccountsQueue(accIds, SalesRepIDs, SRvsAccsMap, SRvsAccsMapFinal, hasMoreRecs, StartNewTransaction, hasMoreRecsLmtID, recsCnt));}
                                  else{
                                      /*                System.debug('Max Queue Limit Dept reached !! Please resubmit job with following users');
for(Id remUsrs : SalesRepIDs){
System.debug('remUsrs-->'+remUsrs);
}
*/
                                  }
                                 }
        else {
            
            /*for(Id usrId:SRvsAccsMap.Keyset()) {
system.debug('ORIGINAL-usrId-->'+usrId);
system.debug('ORIGINAL-total Accounts-->'+SRvsAccsMap.get(usrId).size());
for(Id accId : SRvsAccsMap.get(usrId)){
System.debug('ORIGINAL-accId-->'+accId);
}
}*/
            system.debug('SRvsAccsMap.size-->'+SRvsAccsMap.size());           
            system.debug('accIds.size-->'+accIds.size());
            
            //here we handle segregation of having 100 random accs
            SegregateAccounts();
            
/*for(Id usrId:SRvsAccsMapFinal.Keyset()) {
system.debug('FINAL-usrId-->'+usrId);               
system.debug('FINAL-total Accounts-->'+SRvsAccsMapFinal.get(usrId).size());
for(Id accId : SRvsAccsMapFinal.get(usrId)){
System.debug('FINAL-accId-->'+accId);
}
}*/
            system.debug('SRvsAccsMapFinal.size-->'+SRvsAccsMapFinal.size());
            //system.debug('usrWoTerrNum.size-->'+usrWoTerrNum.size());
            
            //for(Id idn:SRvsAccsMap.KeySet()) if(!SRvsAccsMapFinal.containsKey(idn)) system.debug('idn missing-->'+idn);
            //for(Id idn:SalesRepIDs) if(!SRvsAccsMap.containsKey(idn)) system.debug('idn2 missing-->'+idn);
            
            
            
            
            if(SRvsAccsMapFinal.size() > 0) saveData(SRvsAccsMapFinal); 
            
        }
    }
    
     public void saveData(Map<Id,Set<Id>> SRvsAccsMapFinal){
        
        String surveyKey = 'SK-' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd'));
        
        List<CX_Sales_Rep_Feedback__c> cxFdbkUpdLst = new List<CX_Sales_Rep_Feedback__c>();
        List<CX_Sales_Rep_Account__c> cxSalRepAccLst = new List<CX_Sales_Rep_Account__c>();
        Map<Integer,Set<Id>> cxfdbkAccUpdMap = new Map<Integer,Set<Id>>();
        Integer insrtCnt=0;
        
            for(Id cxSrFdbkObjId : SRvsAccsMapFinal.Keyset()){
                CX_Sales_Rep_Feedback__c cxfdbkObj = new CX_Sales_Rep_Feedback__c();
                cxfdbkObj.Sales_Rep__c = cxSrFdbkObjId;
                cxfdbkObj.Survey_Key__c = surveyKey;
                cxFdbkUpdLst.add(cxfdbkObj);
                cxfdbkAccUpdMap.put(insrtCnt,SRvsAccsMapFinal.get(cxSrFdbkObjId));
                insrtCnt++;
            }
        
            insert cxFdbkUpdLst;
            
            
            for(Integer currUpdMapIndex : cxfdbkAccUpdMap.keySet()){
                for(Id cxSalRepUpdObjId : cxfdbkAccUpdMap.get(currUpdMapIndex)){
                    CX_Sales_Rep_Account__c cxSalRepObj = new CX_Sales_Rep_Account__c();
                    cxSalRepObj.CX_Sales_Rep_Feedback__c = cxFdbkUpdLst[currUpdMapIndex].Id;
                    cxSalRepObj.Sales_Rep_Customer__c = cxSalRepUpdObjId;
                    cxSalRepAccLst.add(cxSalRepObj);
                } 
            }
            insert cxSalRepAccLst;
         
         //sendEmail
         sendEmail(SRvsAccsMapFinal, surveyKey);
         sendEmailToAdmin(SRvsAccsMapFinal, surveyKey);
         
    }
    
    public void sendEmail(Map<Id,Set<Id>> SRvsAccsMapFinal, String surveyKey){
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        
        OrgWideEmailAddress orgEm = [select Id, Address from OrgWideEmailAddress WHERE Address='cx@teleflex.com'];
        User admUsr = [select id from user where name like '%Surya Arvan%'];
        
        for(Id u : SRvsAccsMapFinal.keySet() ){
            
System.debug('sending email to sales rep'+u);
            
            String templateLnk = 'https://teleflex--c.na100.visual.force.com/apex/CXSalesRepLookup?id='+new List<Id>((SRvsAccsMapFinal.get(u)))[0];
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            message.setToAddresses(new String[] {u});
            message.setBccAddresses(new String[] {admUsr.Id});
            message.setOrgWideEmailAddressId(orgEm.Id);   
            message.setReplyTo('cx@teleflex.com');
            message.optOutPolicy = 'SEND';
            message.subject = 'Help Improve Customer Experience – Verify Your Accounts';
            message.htmlbody = ' Sales Teams<br/><br/>'
                +' A project is underway to provide an important service to all of Teleflex on behalf of our customers. Customers are often looking for their sales reps to support them in their interactions with Teleflex.'
                +' In doing so, they may reach out to someone like Customer Service or another rep to find out who their sales rep is.'
                +' What we’ve found is that sometimes customers are passed multiple times from person to person before getting to the right rep.'
                +' So, we’ve built a tool that we hope will make it easier to find a customer’s full list of reps and provide them with a clean “cheat sheet” (see attached example) to keep for any future.<br/>'
                +' But first - <b>We need your help! <u>BEFORE JULY 3</u><sup>rd</sup></b> Follow the steps below and/or watch this <a href="https://web.microsoftstream.com/video/7aa735e6-8591-40a8-acd9-d90c38eda0e3">video</a> to step you through it. <br/> <br/>'
                +' 1. Login to SalesForce.com using this link https://teleflex.lightning.force.com/lightning/n/Sales_Rep_Customer_Details?c__surveykey='+surveyKey+'<br/> '
                +' 2. You will be given a list of customers that we believe are currently assigned to you – Go through each line, confirming YES or NO <br/> '
                +' 3. If you happen to choose NO, provide the name of the correct rep if you know it.  If you don’t know, keep moving down the list. <br/> '
                +' 4. Once you respond to each line, Click Save at the bottom. <br/><br/>'
                +' This exercise is to confirm that our data is correct and accurate before attempting to release the tool to Teleflex personnel.'
                +' Once we know it is ready, this tool will be available in SalesForce.com for Sales reps and Customer Service reps to use in order to help customers find the right people to help them.'
                +' We also hope to make it easier to share contact information without the need to draft extensive emails or do too much copy and paste.'
                +' In the future, we also hope to use what we’ve built here to send automated updates to customers when their reps change (<a href="'+templateLnk+'">Sample Template Link</a>).'
                +' Thank you in advance for your support.  Your input will help solve a major pain point in the Teleflex Customer Experience.<br/><br/><br/>'
                +' <b><u>Jon Crain, Sr. Manager</u></b><br/>'
                +' <b>Customer Experience</b>, Insights<br/>'
                +' P: 919-361-3956 |  M: 919.302.6259<br/>'
                +' E: jon.crain@teleflex.com<br/>'
                +' <b>Teleflex</b><br/>'
                +' 3015 Carrington Mills Blvd | Morrisville, NC 27560 |  USA<br/>'
                +' teleflex.com<br/>'
                +' Arrow®  |  Deknatel®  |  Hudson RCI®  |  LMA®  |  Pilling®  |  Rüsch®  |  Weck®<br/>'
                +' <i>We are looking for ways to improve the customer experience.  Submit your ideas to cx@teleflex.com.</i><br/><br/><br/>'; 
            
            messages.add(message);
            
        }
        
         Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                             + results[0].errors[0].message);
            }
        
        
    }
    
    public void sendEmailToAdmin(Map<Id,Set<Id>> SRvsAccsMapFinal, String surveyKey){

         Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        
        OrgWideEmailAddress oId = [select Id, Address from OrgWideEmailAddress WHERE Address='cx@teleflex.com'];
        
        for(User u : [select id, email from user where name like '%Surya Arvan%']){
            
System.debug('sending email to admin'+u.Id);

             String htmBdy = '***Sales Rep and associated customer details***<br/><br/><br/>';
            for(Id usrId:SRvsAccsMapFinal.Keyset()) {
                htmBdy += 'usrID-->'+usrId+'<br/>';              
                htmBdy += 'usr accs size-->'+SRvsAccsMapFinal.get(usrId).size()+'<br/>';
                for(Id accId : SRvsAccsMapFinal.get(usrId)){
                    htmBdy += 'accId-->'+accId+'<br/>';
                }
            }
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            message.toAddresses = new String[] { u.email};
            message.setOrgWideEmailAddressId(oId.Id);   
            message.setReplyTo('cx@teleflex.com');
            message.optOutPolicy = 'SEND';
            message.subject = 'Help Improve Customer Experience – Verify Your Accounts';
            message.htmlbody = htmBdy;
            
           messages.add(message);
                   
        }
        
         Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                             + results[0].errors[0].message);
            }
        
        
    }
    
    public void SegregateAccounts(){
        set<Id> newSet = new set<Id>();
        for(id SR:SRvsAccsMap.KeySet()){
            newSet = new set<Id>();
            boolean validSR = false;
            for(ID AcId:SRvsAccsMap.get(SR)) {
                if(accIds.contains(AcId)){ validSR = true; break;}
            }
            if(validSR) {
                if(SRvsAccsMap.get(SR).size()<=100) newSet.addAll(SRvsAccsMap.get(SR));
                else{
                    //for new accounts 
                    for(Id tmpId:SRvsAccsMap.get(SR)){
                        if(accIds.contains(tmpId)) newSet.add(tmpId); }
                    //for remaining accounts
                    for(Id tmpId:SRvsAccsMap.get(SR)){
                        if(newSet.size() < 100) { if(!accIds.contains(tmpId)) newSet.add(tmpId); } else break;
                    }
                }
            }
            
            if(validSR) SRvsAccsMapFinal.put(SR,newSet);
        }
    }
    
    public void getAllSalesRepsToEmail(Id currUsr){
        
        /*System.debug('currUsr-->'+currUsr);
System.debug('limit getQueryRows-->'+Limits.getQueryRows() );
System.debug('getLimitQueryRows-->'+Limits.getLimitQueryRows());
System.debug('SRvsAccsMap-->'+SRvsAccsMap.size());*/
        
        set<Id> accIdSet = new set<Id>();     
        
        String cntQry = 'select Territory_Number__c, count(Id)'+
            ' from Territory_Assignment__c'+
            ' where (Territory__r.Sales_Rep__r.Id != null or Territory__r.Primary_Territory_User__r.Id != null)'+
            ' and Territory__r.Sales_Rep__r.Id =: currUsr'+
            ' and Account__r.Territory_Key__c != null'+
            ' and Account__c != null'+
            ' group by Territory_Number__c';
        
        AggregateResult[] conRes =  Database.query(cntQry);
        
        for(AggregateResult ar:conRes){ this.recsCnt = Integer.valueOf(ar.get('expr0')); }
        
        if(this.recsCnt == null){ this.recsCnt = 0; }
        
        if(this.recsCnt > 50000){ this.recsCnt = 50000; }
        
        if(Limits.getQueryRows() + this.recsCnt > Limits.getLimitQueryRows()){ this.StartNewTransaction = true; }
        else if(this.recsCnt == 0){
            //do ntng 
        }
        else{
            String qry = 'select Id, Territory_Number__c, Account__r.ID, Account__r.Territory_Key__c'+
                ' from Territory_Assignment__c'+
                ' where (Territory__r.Sales_Rep__r.Id != null or Territory__r.Primary_Territory_User__r.Id != null)'+
                ' and Territory__r.Sales_Rep__r.Id =:currUsr'+
                ' and Account__r.Territory_Key__c != null'+
                ' and Account__c != null'+
                ' order by Id asc'+
                ' limit 50000';
            
            if(hasMoreRecs && hasMoreRecsLmtID!= null){
                qry = 'select Id, Territory_Number__c, Account__r.ID, Account__r.Territory_Key__c'+
                    ' from Territory_Assignment__c'+
                    ' where (Territory__r.Sales_Rep__r.Id != null or Territory__r.Primary_Territory_User__r.Id != null)'+
                    ' and Territory__r.Sales_Rep__r.Id =:currUsr'+
                    ' and Account__r.Territory_Key__c != null'+
                    ' and Account__c != null'+
                    ' and id > :hasMoreRecsLmtID'+
                    ' order by Id asc'+
                    ' limit 50000'; 
                
                hasMoreRecs = false;
                hasMoreRecsLmtID = null;
            }
            
            List<Territory_Assignment__c> tassignLst =  new List<Territory_Assignment__c>();
            tassignLst = Database.query(qry);
            
            Id maxId;
            
            for(Territory_Assignment__c taObj : tassignLst) 
            {
                List<String> spltLst = taObj.Account__r.Territory_Key__c.split(';');
                if(spltLst.Contains(taObj.Territory_Number__c)){
                    accIdSet.add(taObj.Account__r.Id);
                    
                    if(accIds.size() < lmt) accIds.add(taObj.Account__r.Id);
                    
                    usrWoTerrNum.add(currUsr);
                }else{
                }
                maxId = taObj.Id;
            }
            
            if(tassignLst.size() == 50000){ hasMoreRecs = true; hasMoreRecsLmtID = maxId; StartNewTransaction = true; }
            
            if(!SRvsAccsMap.containsKey(currUsr)){ SRvsAccsMap.put(currUsr,accIdSet);  } 
            else {
                Set<Id> tempSet = new Set<Id>();
                tempSet = SRvsAccsMap.get(currUsr);
                accIdSet.addAll(tempSet);
                SRvsAccsMap.remove(currUsr);
                SRvsAccsMap.put(currUsr,accIdSet);
            }
        }
    }
}