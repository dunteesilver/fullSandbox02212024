public class sales_Rosters {

    public string bu {get; set;}
    public set<String> buList {get; set;}
    public map<String, Territory_User__c> repMap {get; set;}
    
    public sales_Rosters(){
        
        if(ApexPages.currentPage().getParameters().get('bu') != NULL){
            bu = ApexPages.currentPage().getParameters().get('bu');
            repMap = new map<String, Territory_User__c>();
            
            set<Id> repSet = new set<Id>();
            // RSM -> REP
            // Territory, Territory Name, Rep Name, Role, Primary, Quota, Sales YTD, 
            for(Territory_Master__c tm : [SELECT Id, Business_Unit__c, Territory_Number__c  
                                          FROM Territory_Master__c 
                                          WHERE Business_Unit__c =:bu 
                                          ORDER BY Territory_Number__c ])
            {
                repSet.add(tm.Id);
                //repMap.put(tm.Territory_Number__c, tm);
            }
            
            for(Territory_User__c tm : [SELECT Business_Unit__c, Full_Name__c, Primary__c , Role__c, Territory_Number__c, 
                                        Territory_Master__r.Territory_Name__c, User__r.Title 
                                        FROM Territory_User__c  
                                        WHERE Territory_Master__c =:repSet 
                                        ORDER BY Territory_Number__c ])
            {
                repMap.put(tm.Territory_Number__c, tm);
            }
            
        }
        else{
            buList = new set<String>();
            for(Territory_Master__c tm : [SELECT Business_Unit__c 
                                          FROM Territory_Master__c 
                                          WHERE Business_Unit__c != NULL
                                          ORDER BY Business_Unit__c])
            {
                buList.add(tm.Business_Unit__c);
            }
        }
        
    }

}