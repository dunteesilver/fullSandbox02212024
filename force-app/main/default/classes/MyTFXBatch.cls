global class MyTFXBatch implements Database.Batchable<sObject>,   Database.AllowsCallouts {
    
    public String query = 'Select ID, Name from Account';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<Account> records) {         
        String endpoint_uri = Label.CPI_ECC_MYTFX_CUSTOMERS_NMD_CRED_ENV;        
            try {                  
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                // Set values to Params
                String dtTmStr = '2022-01-07T18:05:23.87';
                String formattedDtTmStr = '\''+ dtTmStr + '\'';
                req.setEndpoint('callout:'+endpoint_uri);
                req.setMethod('GET');
                req.setHeader('Accept', '*/*'); 
                req.setHeader('$expand', 'defaultB2BUnit,site');
                req.setHeader('$filter', 'creationtime ge datetime'+formattedDtTmStr);
                if (!Test.isRunningTest()) {      
                    res = http.send(req);
                    String sJson = res.getBody();
                    System.debug('Str:' + res.getBody());
                }             
                // now do what u want to with response.               
            }
            catch (Exception e) {         
                System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() );           
            }
    }   
    
    global void finish(Database.BatchableContext BC){    
    }
}