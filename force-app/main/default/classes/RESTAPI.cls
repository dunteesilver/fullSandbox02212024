@RestResource(urlMapping='/api/Contact/EMEA/*')
global with sharing class RESTAPI {

    @HttpGet
    global static List<Contact> doGet(){
        RestRequest req=RestContext.request;
        RestResponse res=RestContext.response;
        
        List<Contact> result =[SELECT Name, Account_Name__c, Email, Account_Sales_Org__c, Business_Unit1__c 
                        FROM Contact 
                        WHERE Business_Unit1__c='EMEA' limit 3];

    if(result!=null && !result.isEmpty()){
        //Serialize the list of contacts to json
       // RestContext.response.addHeader('Context-Type', 'application/json');
       // String jsonResponse=JSON.serialize(result);
         
        
        // System.debug('Printing list of EMEA Contacts '+result);
       
    
    }
    return result;
   
}
}