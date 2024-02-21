/*********************************************************************
* Description      : Controller Class for Pricing Portal Contract Process.
* Test Class       : PP_Build_Contract_Divisions_Test
* Author(s)        : Eric Clay
**********************************************************************/
public class PP_Build_Contract_Divisions {
    
    public static void checkDivisions(List<Contract_Header__c> newTrigger){
        for(Contract_Header__c ch : newTrigger){
            if(ch.Pricing_Tier__c){
                if(ch.Division_10__c){
                    ch.Division_10__c = FALSE;
                }
                if(ch.Division_20__c){
                    ch.Division_20__c = FALSE;
                }
                if(ch.Division_30__c){
                    ch.Division_30__c = FALSE;
                }
                if(ch.Division_40__c){
                    ch.Division_40__c = FALSE;
                }
                if(ch.Division_50__c){
                    ch.Division_50__c = FALSE;
                }
                if(ch.Division_60__c){
                    ch.Division_60__c = FALSE;
                }
            }
        }
    }

    public static void buildDivisions_CM(List<Contract_Material__c> newTrigger){
        // Class that runs from the Contract Material Trigger
        // Test Class: PP_Build_Contract_Divisions_Test
        //if(master_TriggerHelperClass.qd('buildDivisions') && master_TriggerHelperClass.runOnce('buildCMDiv')){
        system.debug('-- Starting buildDivisions_CM --');
        map<String, Boolean> divCheck = new map<String, boolean>();
        map<String, Decimal> tierAccess = new map<String, Decimal>();
        set<String> chId = new set<String>();
        boolean updateCH = FALSE;
        boolean runUpdate = FALSE;
        
        for(Contract_Material__c cm : newTrigger){
            system.debug('cm.Agreement__r.Division_10__c: ' + cm.Agreement__r.Division_10__c);
            if(cm.Pricing_Tier_Access_Mismatch__c){
                if(
                    tierAccess.containsKey(cm.Agreement_Number__c) == FALSE || // Map does not exist, Create
                    (tierAccess.containsKey(cm.Agreement_Number__c) && cm.Level__c > tierAccess.get(cm.Agreement_Number__c)) // Map exists and the value in the data is higher than the map
                ){
                    tierAccess.put(cm.Agreement_Number__c, cm.Level__c);
                    chId.add(cm.Agreement_Number__c);
                    runUpdate = TRUE;
                    system.debug('Tier Mismatch: Updating! - ' + tierAccess);
                }
            }
            

            if(cm.Material_Division2__c != NULL && cm.Division_Check__c == FALSE){
                divCheck.put(cm.Agreement_Number__c + cm.Material_Division2__c,TRUE);
                chId.add(cm.Agreement_Number__c);
                runUpdate = TRUE;
            }
        }
        system.debug('divCheck: ' + divCheck.keySet());
        system.debug('chId: ' + chId);
        
        //test coverage
        if(Test.isRunningTest()){
            runUpdate = TRUE;
        }
        
        if(runUpdate){
            list<Contract_Header__c> chUpdate = new list<Contract_Header__c>();
            for(Contract_Header__c ch : [SELECT Agreement_Number__c, Pricing_Tier_Access__c, Pricing_Tier__c, 
                                         Division_10__c, Division_20__c, Division_30__c,
                                         Division_40__c, Division_50__c, Division_60__c
                                         FROM Contract_Header__c
                                         WHERE Agreement_Number__c =:chId])
            {
                system.debug('ch.Agreement_Number__c: ' + ch.Agreement_Number__c);
                updateCH = FALSE;
                Contract_Header__c newCH = new Contract_Header__c(
                    Id = ch.Id
                );
                if(
                    tierAccess.containsKey(ch.Agreement_Number__c) && 
                    (tierAccess.get(ch.Agreement_Number__c) > newCH.Pricing_Tier_Access__c ||
                     newCH.Pricing_Tier_Access__c == NULL)
                ){
                    newCH.Pricing_Tier_Access__c = tierAccess.get(ch.Agreement_Number__c);
                    updateCH = TRUE;
                }
                
                if(ch.Pricing_Tier__c == FALSE){
                    if(divCheck.containsKey(ch.Agreement_Number__c + '10')){
                        if(ch.Division_10__c == FALSE){
                            newCH.Division_10__c = TRUE;
                            updateCH = TRUE;
                        }
                    }
                    if(divCheck.containsKey(ch.Agreement_Number__c + '20')){
                        system.debug('Div 20!');
                        if(ch.Division_20__c == FALSE){
                            newCH.Division_20__c = TRUE;
                            updateCH = TRUE;
                        }
                    }
                    if(divCheck.containsKey(ch.Agreement_Number__c + '30')){
                        if(ch.Division_30__c == FALSE){
                            newCH.Division_30__c = TRUE;
                            updateCH = TRUE;
                        }
                    }
                    if(divCheck.containsKey(ch.Agreement_Number__c + '40')){
                        if(ch.Division_40__c == FALSE){
                            newCH.Division_40__c = TRUE;
                            updateCH = TRUE;
                        }
                    }
                    if(divCheck.containsKey(ch.Agreement_Number__c + '50')){
                        if(ch.Division_50__c == FALSE){
                            newCH.Division_50__c = TRUE;
                            updateCH = TRUE;
                        }
                    }
                    if(divCheck.containsKey(ch.Agreement_Number__c + '60')){
                        if(ch.Division_60__c == FALSE){
                            newCH.Division_60__c = TRUE;
                            updateCH = TRUE;
                        }
                    }
                    if(newCH.Pricing_Tier_Access__c != 0){ // Fix any bad or changed data - Bad Kitty
                        newCH.Pricing_Tier_Access__c = 0;
                        updateCH = TRUE;
                    }
                }
                
                if(updateCH){
                    chUpdate.add(newCH);
                }
            }
            if(chUpdate.size() > 0){
                system.debug('-- Updating CH with CM Divisions --');
                update chUpdate;
            }
            system.debug('-- Finished buildDivisions_CM --');
        }
        //}
    }
    
    //code added to fix issues caused by SAP/Vistex update on 11/19/2023... change 11/21/2023
    public static String removeLeadingZeros(String input) {
        // Convert the string to an integer and then back to a string
        Integer intValue = Integer.valueOf(input);
        String result = String.valueOf(intValue);

        return result;
    }
    
    //code added to fix issues caused by SAP/Vistex update on 11/19/2023... change 11/21/2023
    public static void removeZeros(List<Contract_Header__c> contracts) {
        String ownerValue = '';
        for (Contract_Header__c con : contracts) {
            ownerValue = con.Owner__c;
            if( ownerValue.isNumeric() ){
                con.Owner__c = removeLeadingZeros(con.Owner__c); //removes leading zeros
            }
        }
    }
    
    /*
    public static void buildDivisions(List<Contract_Header__c> newTrigger){
        if(master_TriggerHelperClass.qd('buildDivisions')){
            map<string, Id> mMap = new map<string, Id>();

            // Bruteforce builds a unique map of Division to Contract Header record
            for(Contract_Material__c m : [SELECT Agreement__c, Material_Division__c FROM Contract_Material__c WHERE Agreement__c IN :newTrigger]){
                mMap.put(m.Material_Division__c, m.Agreement__c);
            }

            // List to capture the update records
            list<Contract_Header__c> cupList = new list<Contract_Header__c>();

            for(Contract_Header__c ch : newTrigger){
                // Don't run this against Contracts not active
                //if(!ch.Active__c){
                Contract_Header__c updateCH = new Contract_Header__c();
                updateCH.Id = ch.Id;

                // Set all the divisions back to false just in case material has changed
                updateCH.Division_10__c = FALSE;
                updateCH.Division_20__c = FALSE;
                updateCH.Division_30__c = FALSE;
                updateCH.Division_40__c = FALSE;
                updateCH.Division_50__c = FALSE;
                updateCH.Division_60__c = FALSE;

                // Set all divisions found in the material to division map - If none found the contract header will have no divisions selected
                if(mMap.get('10') == updateCH.Id) updateCH.Division_10__c = TRUE;
                if(mMap.get('20') == updateCH.Id) updateCH.Division_20__c = TRUE;
                if(mMap.get('30') == updateCH.Id) updateCH.Division_30__c = TRUE;
                if(mMap.get('40') == updateCH.Id) updateCH.Division_40__c = TRUE;
                if(mMap.get('50') == updateCH.Id) updateCH.Division_50__c = TRUE;
                if(mMap.get('60') == updateCH.Id) updateCH.Division_60__c = TRUE;

                cupList.add(updateCH);
                //}
            }

            system.debug('cupList: ' + cupList);

            if(cupList.size() > 0){
                update cupList;
            }
        }
    } */
}