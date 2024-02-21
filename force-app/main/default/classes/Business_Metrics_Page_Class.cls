public class Business_Metrics_Page_Class {
    
    public map<String, list<Business_Metrics__c>> megaMap {get; set;}
    public list<String> buList {get; set;}
    
    public Business_Metrics_Page_Class(){
        megaMap = new map<String, list<Business_Metrics__c>>();
        buList = new list<String>();
        set<String> buSet = new set<String>();
        Id userId = UserInfo.getUserId();
        String buKey;
        for(User u : [SELECT Business_Unit_Key__c 
                     FROM User
                     WHERE Id = :UserInfo.getUserId()])
        {
            buKey = u.Business_Unit_Key__c;
        }
        
        for(Business_Metrics__c BMX : [SELECT Id, Name, Section__c, Link__c, Business_Unit_Key__c 
                                      FROM Business_Metrics__c 
                                      WHERE (Business_Unit_Key__c like :'%'+buKey+'%' OR Business_Unit_Key__c like 'All')
                                      ORDER BY Section__c, Sorting_Order__c])
        {
            system.debug('Business_Unit_Key__c: ' + BMX.Business_Unit_Key__c);
            if(megaMap.containsKey(BMX.Section__c)){
                megaMap.get(BMX.Section__c).add(BMX);
            }
            else{
                megaMap.put(BMX.Section__c, new list<Business_Metrics__c>{BMX});
            }
            buSet.add(BMX.Section__c);
        }
        buList.addAll(buSet);
        /*
         if(isVPSMap.containsKey(is.Account__c)){
                    isVPSMap.get(is.Account__c).add(is);
                }
                else{
                    isVPSMap.put(is.Account__c, new list<Invoiced_Sales__c>{is});    
                }*/
        
    }

}