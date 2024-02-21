trigger customAssign on Lead (Before Update) {
    Map<String,Id> assignMap = new Map<String,Id>();
    Map<Id,Id> userMap = new Map<Id,Id>();
    Map<String,Id> finalMap = new Map<String,Id>();
    List<String> criteria = new List<String>();
    String fieldList = '';
    Custom_IDs_for_Lead_Assignment__c customIds = Custom_IDs_for_Lead_Assignment__c.getInstance();
    List<Lead> finalList = new List<Lead>();
    
    if(trigger.isBefore && trigger.isUpdate){
        Map<String, Schema.SObjectField> caFields = Schema.SObjectType.Custom_Assignment__c.fields.getMap();
        for(String s: caFields.KeySet()){
            if(s.contains('territory')){
                if(fieldList.length() <= 0){
                    fieldList = s;
                } else {
                    fieldList += ', ' + s;
                }
            }   
        }
        for(Lead l: trigger.new){
            if(l.PostalCode != null){
                String trimmedZip;
                if(l.PostalCode.length() > 5){
                    trimmedZip = l.PostalCode.substring(0,5);
                    system.debug(trimmedZip);
                } else {
                    trimmedZip = l.PostalCode;
                }
                criteria.add(trimmedZip);
            }
        }
        for(Custom_Assignment__c ca: Database.Query('SELECT ' + fieldList + ', Criteria__c FROM Custom_Assignment__c WHERE criteria__c IN :criteria')){
            assignMap.put(ca.Criteria__c,ca.IA_Territory__c);
        }
        for(Territory_User__c tu: [SELECT Id,Territory_Master__c, User__c FROM Territory_User__c WHERE Territory_Master__c IN :assignMap.values()]){
            userMap.put(tu.Territory_Master__c,tu.User__c);
        }
        for(String am:assignMap.keySet()){
            finalMap.put(am,usermap.get(assignMap.get(am)));
        }
        for(Lead l: trigger.new){
            if(l.recordTypeId == customIds.IA_Lead__c && l.LeadSource != 'Self Generated' && l.Reassign_using_lead_assignment_rules__c == true){
                String trimmedZip;
                if(l.PostalCode != null){
                    if( l.PostalCode.length() > 5){
                        trimmedZip = l.PostalCode.substring(0,5);
                    } else {
                        trimmedZip = l.PostalCode;
                    }
                }
                if(finalMap.get(trimmedZip) != null){
                    l.OwnerId=finalMap.get(trimmedZip);
                }else{
                    l.OwnerId='00GE0000001xTwz'; //IA Lead Assignment Queue 
                }
                l.Reassign_using_lead_assignment_rules__c = false;
            }
        }
    }
}