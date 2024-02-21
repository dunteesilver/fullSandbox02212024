public class Business_Metrics_Helper_Class {
    
    public static void setBUKey(List<Business_Metrics__c> newTrigger){
        
        String buKeyList;
        String buKey;
        String buSet;
        Map<String,Business_Unit__c> buMap = Business_Unit__c.getAll();
        for(Business_Metrics__c bmx : newTrigger){
            buKey = NULL;
            if(bmx.Business_Unit__c != NULL){
                buKeyList = bmx.Business_Unit__c;
                List<String> buValues = buKeyList.split(';');

                for(string s : buValues){
                    if(s == 'All'){
                        buSet = 'All';
                    }
                    else if(buMap.containsKey(s)){
                        buSet = buMap.get(s).Key__c;
                    }
                    else{
                        buSet = NULL;
                    }
                    //system.debug('s: ' + s);
                    if(buSet != NULL){
                        if(buKey == NULL){
                            buKey = buSet;
                        }
                        else{
                            buKey = buKey + ', ' + buSet;
                        } 
                    }
                    
                }
                bmx.Business_Unit_Key__c = buKey;
            }
        }
    }
    
    public static void setReportURL(List<Business_Metrics__c> newTrigger){

        set<String> reportSet = new set<String>();
        for(Business_Metrics__c bmx : newTrigger){
            if(bmx.Report_Label_Name__c != NULL){
                reportSet.add(bmx.Report_Label_Name__c);                
            }
        }
        if(reportSet.size() > 0){
            map<String, Id> reportMap = new map<String, Id>();
            for(Report r : [SELECT Id, DeveloperName 
                            FROM Report 
                            WHERE DeveloperName = :reportSet])
            {
                reportMap.put(r.DeveloperName, r.Id);
            }
            for(Business_Metrics__c bmx : newTrigger){
                if(reportMap.containsKey(bmx.Report_Label_Name__c)){
                    bmx.Report_Id__c = reportMap.get(bmx.Report_Label_Name__c);
                }
                else{
                    bmx.Report_Id__c = NULL;
                }
            }
        }
    }

}