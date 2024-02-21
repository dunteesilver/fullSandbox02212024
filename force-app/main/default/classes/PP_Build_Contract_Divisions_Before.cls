public class PP_Build_Contract_Divisions_Before {
    
    /*
    public static void buildDivisions(List<Contract_Header__c> newTrigger){
        if(master_TriggerHelperClass.qd('buildDivisions')){
            map<string, Id> mMap = new map<string, Id>();

            list<Contract_Header__c> chList = new list<Contract_Header__c>();
            for(Contract_Header__c ch : newTrigger){
                if(!ch.Alt_UI__c){
                    chList.add(ch);    
                }
            }
            
            // Bruteforce builds a unique map of Division to Contract Header record
            for(Contract_Material__c m : [SELECT Agreement__c, Material_Division__c 
                                          FROM Contract_Material__c 
                                          WHERE Agreement__c =:chList])
            {
                mMap.put(m.Material_Division__c, m.Agreement__c);
            }          
            for(Contract_Header__c ch : chList){
                
                // Set all divisions found in the material to division map - If none found the contract header will have no divisions selected
                if(mMap.get('10') == ch.Id) ch.Division_10__c = TRUE;
                if(mMap.get('20') == ch.Id) ch.Division_20__c = TRUE;
                if(mMap.get('30') == ch.Id) ch.Division_30__c = TRUE;
                if(mMap.get('40') == ch.Id) ch.Division_40__c = TRUE;
                if(mMap.get('50') == ch.Id) ch.Division_50__c = TRUE;
                if(mMap.get('60') == ch.Id) ch.Division_60__c = TRUE;
            }  
        }
    }     */
}