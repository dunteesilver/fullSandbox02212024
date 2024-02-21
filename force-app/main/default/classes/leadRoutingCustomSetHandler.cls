public with sharing class leadRoutingCustomSetHandler {
  
    public static String getLeadSource(String leadSource){
            String custSetldSource='';
             if(leadSource!=null){
           Lead_Settings__c lds=Lead_Settings__c.getValues(leadSource);
              custSetldSource =lds.LeadSource__c;
            
        }
        return custSetldSource;
    }
        public static String getQuequeId(String leadSource){
            String leadQId='';
           if(leadSource!=null)  {     
            Lead_Settings__c lds=Lead_Settings__c.getInstance(leadSource);
            leadQId =lds.LeadQuequeId__c;
            }
                   
            return leadQId;
        }
    
}