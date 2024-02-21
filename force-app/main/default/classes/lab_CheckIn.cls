public class lab_CheckIn {
    // Test Class: formStack_test
    public Lab_Participant__c createLP {get; set;}
    public boolean isHemorrhage {get; set;}
    public boolean isEZIO {get; set;}
    public boolean isInterventional {get; set;}
    
    public boolean timeslot2 {get{
        integer cnt = [SELECT count()
                       FROM Lab_Participant__c 
                       WHERE Lab__r.Id = :ApexPages.currentPage().getParameters().get('id') 
                       AND Lab_Time_2__c != NULL];
        if(cnt > 0){
            return TRUE;            
        }
        else{
            return FALSE;
        }
    } set;}
    public boolean timeslot3 {get{
        integer cnt = [SELECT count()
                       FROM Lab_Participant__c 
                       WHERE Lab__r.Id = :ApexPages.currentPage().getParameters().get('id') 
                       AND Hemorrhage_Track__c != NULL];
        if(cnt > 0){
            return TRUE;            
        }
        else{
            return FALSE;
        }
    } set;}
    public boolean timeslot4 {get{
        integer cnt = [SELECT count()
                       FROM Lab_Participant__c 
                       WHERE Lab__r.Id = :ApexPages.currentPage().getParameters().get('id') 
                       AND Interventional_Track__c != NULL];
        if(cnt > 0){
            return TRUE;            
        }
        else{
            return FALSE;
        }
    } set;}
    
    public lab_CheckIn(){
        isHemorrhage = false;
        isEZIO = false;
        isInterventional = false;
        Lab__c labRec = [SELECT Name FROM Lab__c WHERE Id=:ApexPages.currentPage().getParameters().get('id')];
        if(labRec.Name.toLowerCase().contains('oncontrol')){
            isInterventional = true;
        }
        
        else if(labRec.Name.toLowerCase().contains('procedural') || labRec.Name.toLowerCase().contains('hemorrhage')){
            isHemorrhage = true;
            isEZIO = true;
        }
        else{
            isEZIO = true;
        }
        createLP = new Lab_Participant__c();
    }
    
    
    public Lab__c getLabDetails(){
        return [SELECT Id, Name    
                FROM Lab__c 
                WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }
    
    public list<Lab_Participant__c> getlplist(){
        return [SELECT Id, Lab_Time__c, Lab_Time_2__c, Full_Name__c, Email__c, Title__c, 
                Hospital_Agency__c, Attended__c, Attended_EZIO__c, Attended_Hemorrhage__c, Hemorrhage_Track__c, Atteneded_Interventional__c, Interventional_Track__c
                FROM Lab_Participant__c 
                WHERE Lab__r.Id = :ApexPages.currentPage().getParameters().get('id') 
                AND Full_Name__c != NULL 
                ORDER By Full_Name__c];
    }
    
    public set<string> getShortCuts(){
        set<string> initial = new set<string>();
        for(Lab_Participant__c lp : [SELECT Full_Name__c 
                                     FROM Lab_Participant__c 
                                     WHERE Lab__r.Id = :ApexPages.currentPage().getParameters().get('id')
                                     ORDER By Full_Name__c])
        {
            if(lp.Full_Name__c != NULL){
                initial.add(lp.Full_Name__c.left(1));                
            }            
        }
        system.debug('initial: ' + initial);
        return initial;
    }
    
    public pagereference checkin(){
        string lpid = ApexPages.currentPage().getParameters().get('lpid');
        string lid = ApexPages.currentPage().getParameters().get('id');
        string cstatus = ApexPages.currentPage().getParameters().get('cstatus');
        string cfield = ApexPages.currentPage().getParameters().get('cfield');
        boolean attended;
        
        if(cstatus == 'FALSE'){
            attended = TRUE;
        }
        else{
            attended = FALSE;
        }
        
        if(lpid != NULL && lid != NULL){
            Lab_Participant__c updateLP = new Lab_Participant__c(
                Id = lpid
            );
            if(string.isNotEmpty(cfield)){
                updateLP.put(cfield, attended);
            }
            
            if(attended){
                switch on cfield {
                    when 'Attended__c' {
                        updateLP.Status__c = 'Attended';
                    }	
                    when 'Attended_Hemorrhage__c' {
                        updateLP.Status_for_Hemorrhage__c = 'Attended';
                    }
                    when 'Atteneded_Interventional__c' {
                        updateLP.Status_for_Interventional__c = 'Attended';
                    }
                    when 'Attended_EZIO__c' {
                        updateLP.Status_for_EZIO__c = 'Attended';
                    }
                    when else {
                        // Do Nothing
                    }
                }
            }
            else{
                switch on cfield {
                    when 'Attended__c' {
                        updateLP.Status__c = 'Approved';
                    }	
                    when 'Attended_Hemorrhage__c' {
                        updateLP.Status_for_Hemorrhage__c = 'Approved';
                    }
                    when 'Atteneded_Interventional__c' {
                        updateLP.Status_for_Interventional__c = 'Approved';
                    }
                    when 'Attended_EZIO__c' {
                        updateLP.Status_for_EZIO__c = 'Approved';
                    }
                    when else {
                        // Do Nothing
                    }
                }
                
            }
            system.debug(updateLP);
            update updateLP;
        }
        
        PageReference redir = New Pagereference('/apex/lab_checkin?id=' + ApexPages.currentPage().getParameters().get('id'));
        redir.setRedirect(true);
        return redir;
    }
    
    public pagereference save(){
        string labId = ApexPages.currentPage().getParameters().get('id');
        string fullName = createLP.First_Name__c + ' ' + createLP.Last_Name__c;
        string email = createLP.Email__c;
        createLP.Name = fullName;
        createLP.Full_Name__c = fullName;
        createLP.Email__c = email;
        createLP.Lab__c = labId;
        createLP.Status__c = 'Attended';
        createLP.Status_for_EZIO__c = 'Attended';
        createLP.Attended__c = TRUE;
        
        insert createLP;
        
        PageReference redir = New Pagereference('/apex/lab_checkin?id=' + labId);
        redir.setRedirect(true);
        return redir;
    }
    
    public pagereference cancel(){
        PageReference redir = New Pagereference('/apex/lab_checkin?id=' + ApexPages.currentPage().getParameters().get('id'));
        redir.setRedirect(true);
        return redir;
    }
    
    public List<SelectOption> getTimeList() {
        // 22Feb2016 - ESC
        system.debug('-- Starting getTimeList --');
        list<SelectOption> timeList = new list<SelectOption>();
        
        set<String> labTimes = new set<String>();
        for(Lab_Participant__c lp : [SELECT Lab_Time__c   
                                     FROM Lab_Participant__c 
                                     WHERE Lab__r.Id = :ApexPages.currentPage().getParameters().get('id') 
                                     AND Lab_Time__c != NULL])
        {
            system.debug('lp.Lab_Time__c: ' + lp.Lab_Time__c);
            labTimes.add(lp.Lab_Time__c);
        }
        system.debug('labTimes: ' + labTimes);
        // Need a set so that you only get one option per Lab Time
        for(String labTime : labTimes){
            timeList.add(new SelectOption(labTime,labTime));            
        }
        system.debug('timeList: ' + timeList);  
        try{
            return timeList;
        }
        catch(Exception e) {
            return NULL;
        }
        
    }
    public List<SelectOption> getTimeList2() {
        // 22Feb2016 - ESC
        system.debug('-- Starting getTimeList --');
        list<SelectOption> timeList = new list<SelectOption>();
        
        set<String> labTimes = new set<String>();
        for(Lab_Participant__c lp : [SELECT Lab_Time_2__c   
                                     FROM Lab_Participant__c 
                                     WHERE Lab__r.Id = :ApexPages.currentPage().getParameters().get('id') 
                                     AND Lab_Time_2__c != NULL])
        {
            system.debug('lp.Lab_Time_2__c: ' + lp.Lab_Time_2__c);
            labTimes.add(lp.Lab_Time_2__c);
        }
        system.debug('labTimes: ' + labTimes);
        // Need a set so that you only get one option per Lab Time
        for(String labTime : labTimes){
            timeList.add(new SelectOption(labTime,labTime));            
        }
        system.debug('timeList: ' + timeList);  
        try{
            return timeList;
        }
        catch(Exception e) {
            return NULL;
        }
        
    }
    public List<SelectOption> getTimeList3() {
        // 22Feb2016 - ESC
        system.debug('-- Starting getTimeList --');
        list<SelectOption> timeList = new list<SelectOption>();
        
        set<String> labTimes = new set<String>();
        for(Lab_Participant__c lp : [SELECT Hemorrhage_Track__c   
                                     FROM Lab_Participant__c 
                                     WHERE Lab__r.Id = :ApexPages.currentPage().getParameters().get('id') 
                                     AND Hemorrhage_Track__c != NULL])
        {
            system.debug('lp.Hemorrhage_Track__c: ' + lp.Hemorrhage_Track__c);
            labTimes.add(lp.Hemorrhage_Track__c);
        }
        system.debug('labTimes: ' + labTimes);
        // Need a set so that you only get one option per Lab Time
        for(String labTime : labTimes){
            timeList.add(new SelectOption(labTime,labTime));            
        }
        system.debug('timeList: ' + timeList);  
        try{
            return timeList;
        }
        catch(Exception e) {
            return NULL;
        }
        
    }
    public List<SelectOption> getTimeList4() {
        // 22Feb2016 - ESC
        system.debug('-- Starting getTimeList --');
        list<SelectOption> timeList = new list<SelectOption>();
        
        set<String> labTimes = new set<String>();
        for(Lab_Participant__c lp : [SELECT Interventional_Track__c   
                                     FROM Lab_Participant__c 
                                     WHERE Lab__r.Id = :ApexPages.currentPage().getParameters().get('id') 
                                     AND Interventional_Track__c != NULL])
        {
            system.debug('lp.Interventional_Track__c: ' + lp.Interventional_Track__c);
            labTimes.add(lp.Interventional_Track__c);
        }
        system.debug('labTimes: ' + labTimes);
        // Need a set so that you only get one option per Lab Time
        for(String labTime : labTimes){
            timeList.add(new SelectOption(labTime,labTime));            
        }
        system.debug('timeList: ' + timeList);  
        try{
            return timeList;
        }
        catch(Exception e) {
            return NULL;
        }
        
    }
    
}