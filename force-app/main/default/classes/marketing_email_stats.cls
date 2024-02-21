public class marketing_email_stats {
    
    string mp {get; set;}
    string pid {get; set;}
    string maction {get; set;}
    string url {get; set;}
    
    public pagereference redirect(){
        
	//tfx.force.com/apex/tiny?m= MC-0001309&L1001023&a=dc&http://www.somestuff.com
	// Marketing Email Stats

        // URL/Destination Link = Address to forward client to
        // mp = Marketing Program Number
        // Action = Web Link / Download / Unsubscribe
        // Person ID = Contact or Lead unique Autonumber ID (not record ID)
        // Example URL: tfx.force.com/apex/tiny?m=MC-0001309&pid=L1001023&a=dc&http://www.google.com
        // https://teleflex--sandbox--c.cs14.visual.force.com/apex/tiny?m=MC-0001309&id=L1001023&a=dc&url=http://www.google.com
        
        mp = ApexPages.currentPage().getParameters().get('m');
        pid = ApexPages.currentPage().getParameters().get('id');
        maction = ApexPages.currentPage().getParameters().get('a');
        url = ApexPages.currentPage().getParameters().get('url');
        
       
        
        system.debug('mp:' + mp + ' pid:' + pid);
        
        if(mp != NULL && pid != NULL && maction != NULL && url != NULL){
            list<Marketing_Email_Stats__c> newMES = new list<Marketing_Email_Stats__c>();
            Marketing_Email_Stats__c mes = new Marketing_Email_Stats__c (
                Marketing_Program__c = mp, 
                Action__c = maction,
                Person_ID__c = pid,
                Destination_Link__c  = url
            );
            if(pid.left(3) == '00Q'){
                mes.Lead__c = pid;
            }
            if(pid.left(3) == '003'){
                mes.Contact__c = pid;
            }
            newMES.add(mes);
            if(newMES.size() > 0){
                insert newMES;    
            }    
        }
        
        if(url == NULL){
            url = 'http://www.teleflex.com';
        }
        url = url.replace('%40','@');
        //url = EncodingUtil.URLDECODE(url,'UTF-8');
        system.debug('url: ' + url);
        PageReference tiny_redirect = New Pagereference(url);
        tiny_redirect.setRedirect(true); 
        return tiny_redirect;
    }

}