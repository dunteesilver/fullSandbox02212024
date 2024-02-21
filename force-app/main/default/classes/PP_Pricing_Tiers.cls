global without sharing class PP_Pricing_Tiers {

    //global list<String> tierHeaderList {get; set;} // Used to store the final list of pricing levels in order: REP1, REP2, RSM1, etc.
    //global set<String> tierHeaderNames2 {get; set;} // Stores the major header names: REP, RSM, DIR
    //global map<String, Integer> tierLevels {get; set;} // Used to store how many levels REP, RSM, DIR go in order to span columns appropriately

    //public string testSub {get { return 'Hi'; } set;}
    //global static string salesOrg {get; set;}
    //tierHeaderNames = new set<String>();
    //tierLevels = new map<String, Integer>();
    /*
    list<String> rankSortOrder = new list<String>();
    rankSortOrder.add('REP');
    rankSortOrder.add('RSM');
    rankSortOrder.add('DIR');*/

    //get active sales org key of User
    public String myActiveSalesOrg { get{
      try{
        myActiveSalesOrg = [SELECT Active_Sales_Org_Key__c
                          FROM Contract_User__c
                          WHERE User__c = :UserInfo.getUserId()
                          LIMIT 1].Active_Sales_Org_Key__c;

        if(myActiveSalesOrg == '' || myActiveSalesOrg == NULL){
            myActiveSalesOrg = 'US6010';
        }
      }
      catch(Exception e){
        System.debug('*** Exception occured in PP_Pricing_Tiers myActiveSalesOrg: ' + e);
      }

      return myActiveSalesOrg;
    } set;}
    
    public String pqSalesOrgKey { get{
      try{
          System.debug('*** ApexPages.currentPage().getParameters().get(pqid) *** ' + ApexPages.currentPage().getParameters().get('pqid'));
          if(ApexPages.currentPage().getParameters().get('pqid') != null && ApexPages.currentPage().getParameters().get('pqid') != ''){
              System.debug('*** Setting pqSalesOrgKey using PQ ID in PP_Pricing_Tiers class ***');
              pqSalesOrgKey = [SELECT Id, Sales_Org_Key__c
                               FROM Price_Quote__c
                               WHERE Id = :ApexPages.currentPage().getParameters().get('pqid')
                               LIMIT 1].Sales_Org_Key__c;
          }
          else if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != ''){
                  System.debug('*** Setting pqSalesOrgKey using PRF ID in PP_Pricing_Tiers class ***');
                  pqSalesOrgKey = [SELECT Id, Sales_Org_Key__c
                                   FROM PRF__c
                                   WHERE Id = :ApexPages.currentPage().getParameters().get('id')
                                   LIMIT 1].Sales_Org_Key__c;
              }
          else if(ApexPages.currentPage().getParameters().get('pqid') != ''){
              System.debug('*** Setting pqSalesOrgKey to user active key PP_Pricing_Tiers class ***');
              pqSalesOrgKey = [SELECT Active_Sales_Org_Key__c
                          FROM Contract_User__c
                          WHERE User__c = :UserInfo.getUserId()
                          LIMIT 1].Active_Sales_Org_Key__c;
          }
          else{
              if(ApexPages.currentPage().getParameters().get('pqid') == '' || ApexPages.currentPage().getParameters().get('pqid') == null){
                  System.debug('*** Setting pqSalesOrgKey to US6010 in PP_Pricing_Tiers class ***');
                  pqSalesOrgKey = 'US6010';
              }
          }
          System.debug('*** pqSalesOrgKey PP_Pricing_Tiers class *** ' + pqSalesOrgKey);
          
      }
      catch(Exception e){
        System.debug('*** Exception occured in PP_Pricing_Tiers class pqSalesOrgKey: ' + e);
      }

      return pqSalesOrgKey;
    } set;}
    
    public without sharing class tiers{
        public string Name {get; set;} // Agreement Number
        public string chDesc {get; set;} // Contract Description
        public string chGPORef {get; set;} // Contract GPO Ref

        // Contract Price
        public decimal Price {get; set;} // Contract Price
        public id chId {get; set;} // Contract Header id
        public id cmId {get; set;} // Contract Material id

        public string TierHeaderNames {get; set;} // REP, RSM, DIR
        public string TierName {get; set;} // REP1, REP2, RSM1, etc.
        public decimal TierLevel {get; set;} // 1,2,3
        public string Product_Name {get; set;} // Product Name

        public string chKey {get; set;} // Parent Contract Description - Name of the Contract minus the level (-R1, -R2, -M1, etc.)

    }
    //Product Id's
    /*
    public list<String> getTierHeaderNames(map<String, tiers> tMap){
        
        System.debug('*** Starting getTierHeaderNames ***');
        list<String> returnList = new list<String>();
        list<String> rankSortOrder = new list<String>();
        rankSortOrder.add('REP');
        rankSortOrder.add('RSM');
        rankSortOrder.add('DIR');
        map<String, Boolean> mapCheck = new map<String, Boolean>();
        for(tiers t : tMap.values()){
            mapCheck.put(t.TierHeaderNames, TRUE);
        }


        for(String s : rankSortOrder){
            if(mapCheck.containsKey(s)){
                returnList.add(s);
            }
            for (Integer i = 0; i < 5; i++) { // Should only be 3 but just in case we do 5 passes
                if(buildHeaders.contains(s+string.valueOf(i))){
                    tierHeaderNames.add(s);
                    if(tierLevels.containsKey(s)){
                        tierLevels.put(s, 1+tierLevels.get(s));
                    }
                    else{
                        tierLevels.put(s, 1);
                    }
                    tierHeaderList.add(s+string.valueOf(i));
                }
                //system.debug('tierLevels: ' + tierLevels);
            }
        }

        System.debug('*** Starting getTierHeaderNames ***');
        System.debug('*** returnList *** ' + returnList);
        return returnList;
    }
	*/
    public list<String> getTierHeaderLevels(map<String, tiers> tMap){
        System.debug('*** Starting getTierHeaderLevels ***');
        list<String> returnList = new list<String>();
        set<String> buildHeaders = new set<String>();
        list<String> rankSortOrder = new list<String>();
        rankSortOrder.add('National Tier');
        rankSortOrder.add('REP');
        rankSortOrder.add('RSM');
        rankSortOrder.add('DIR');
        rankSortOrder.add('VP');
		
        map<String, Boolean> mapCheck = new map<String, Boolean>();
        for(tiers t : tMap.values()){
            mapCheck.put(t.TierName, TRUE);
            System.debug('*** t *** ' + t);
        }

        for(String s : rankSortOrder){
            for (Integer i = 0; i <= mapCheck.size(); i++) { // Should only be 3 but just in case we do 5 passes
                if(mapCheck.containsKey(s+string.valueOf(i))){
                    returnList.add(s+string.valueOf(i));
                }
            }
        }
        return returnList;
    }

    public map<String, tiers> getTiers(list<product2> plist, integer level){
      System.debug('*** Starting getTiers ***');
      //System.debug('*** pqid *** ' + ApexPages.currentPage().getParameters().get('pqid')); 
      System.debug('*** level *** ' + level);  
        system.debug('*** plist Count: *** ' + plist.size());
        system.debug('*** plist *** ' + plist );
        system.debug('*** pqSalesOrgKey IN getTiers PP_Pricing_Tiers class *** ' + pqSalesOrgKey );
        //null value check
        if(pqSalesOrgKey == null || pqSalesOrgKey == 'null'){
            system.debug('*** Setting pqSalesOrgKey IN getTiers PP_Pricing_Tiers class 2nd null check *** ');
            pqSalesOrgKey = 'US6010';
        }
        
        string strPlist = '';
        if(plist.size() > 0){
            strPlist = plist[0].id;
        }
        map<String, tiers> tierMap = new map<String, tiers>();
        set<String> buildHeaders = new set<String>(); // Temporary list of pricing levels - Used to build tierHeaderList
        map<String, Integer> tierLevels = new map<String, Integer>();
        integer tierLevel = 1;
        integer debugLoop = 1;
        string tierRankName;
        string prevTierName;
        string prevMaterialName;

        string salesOrg = pqSalesOrgKey.left(4);
        System.debug('*** salesOrg *** ' + salesOrg);  
        for(Contract_Material__c cm : [SELECT Id, Level__c, Material_Name__c, Price__c, Product__c,
                                       Agreement_Number_Text__c, Tier_Level_Name__c, Agreement__c,
                                       Agreement__r.Description__c, Agreement__r.Parent_Contract_Name__c,
                                       Agreement__r.GPO_Contract_Ref__c
                                       FROM Contract_Material__c
                                       WHERE Product__c IN :plist
                                       AND Active__c = TRUE
                                       AND Agreement__r.Pricing_Tier__c = TRUE
                                       AND Level__c <= :level
                                       AND Sales_Org__c =:salesOrg
                                       ORDER BY Material_Name__c, Level__c ASC, Price__c DESC])
        {
            //system.debug('Starting CM [' + debugLoop + ']');
            // Determine what tier and level
            System.debug('*** cm *** ' + cm);
            if(
                prevTierName == NULL || // First Record
                prevMaterialName != cm.Material_Name__c || // Material Changed
                prevTierName != cm.Tier_Level_Name__c // Tier Changed
            ){
                tierLevel = 1;
            }
            // Set the Tier Name to something like 'REP1' or 'RSM2', etc.
            tierRankName = cm.Tier_Level_Name__c + string.valueOf(tierLevel);

            // Add to the Tiers Map - Will have to re-order to ensure that the order is REP, RSM, DIR, VP
            buildHeaders.add(tierRankName);

            // Create the abstract record
            tiers newTier = new tiers();

            newTier.Name = cm.Agreement_Number_Text__c; // Agreement Number
            newTier.chId = cm.Agreement__c; // Contract Header ID
            newTier.chDesc = cm.Agreement__r.Description__c; // Contract Description
            newTier.cmId = cm.Id; // Contract Material ID
            newTier.TierLevel = cm.Level__c; // 1,2,3
            newTier.TierName = tierRankName; // REP1, RSM2, etc.
            newTier.Price = cm.Price__c; // Price
            newTier.Product_Name = cm.Material_Name__c;
            newTier.chKey = cm.Agreement__r.Parent_Contract_Name__c; // Name of the Contract minus the level (-R1, -R2, -M1, etc.)
            //Below if statement fixes Out of Range error when searching for products
            if(cm.Tier_Level_Name__c != 'Out of Range'){
                System.debug('*** Out of Range *** ');
                newTier.TierHeaderNames = cm.Tier_Level_Name__c;
            }
             // REP, RSM, DIR
            newTier.chGPORef = cm.Agreement__r.GPO_Contract_Ref__c; // GPO Reference
            system.debug('*** cm.Tier_Level_Name__c *** ' + cm.Tier_Level_Name__c);
            system.debug('*** newTier[' + debugLoop + ']: *** ' + newTier);
            
            // Add to the Map
            tierMap.put(tierRankName + '-' + cm.Material_Name__c,newTier);

            // Cleanup for the next loop
            prevMaterialName = cm.Material_Name__c;
            prevTierName = cm.Tier_Level_Name__c;
            ++tierLevel;

            // Debug
            ++debugLoop;

        }
        //plist
        //if(plist.size() > 0){
            // Re-Order the headers so that REP, RSM, and DIR go in order and not the order that the data added to the set.
            // Otherwise you might get REP1, RSM1, RSM2, REP2, REP3
            list<String> tierHeaderList = new list<String>();
            list<String> rankSortOrder = new list<String>();
        	rankSortOrder.add('National Tier');
            rankSortOrder.add('REP');
            rankSortOrder.add('RSM');
            rankSortOrder.add('DIR');
        	rankSortOrder.add('VP');
			
            for(String s : rankSortOrder){
                for (Integer i = 0; i <= buildHeaders.size(); i++) { // Should only be 3 but just in case we do 5 passes
                    if(buildHeaders.contains(s+string.valueOf(i))){
                        /*
                        tierHeaderNames.add(s);
                        if(tierLevels.containsKey(s)){
                            tierLevels.put(s, 1+tierLevels.get(s));
                        }
                        else{
                            tierLevels.put(s, 1);
                        }*/
                        tierHeaderList.add(s+string.valueOf(i));
                    }//end if buildHeaders
                }
            }
			System.debug('*** tierHeaderList.size() *** ' + tierHeaderList.size() );
        	System.debug('*** tierHeaderList *** ' + tierHeaderList);
            // Ensure that each level of pricing has a value even if it is zero so that there are no nulls in the map when iterating/looping
            for(product2 p : plist){
                for(String s : tierHeaderList){
                    // Logic that when a value is not present a zero price value is inserted. In the VF we will replace the zero (0) with a dash (-)
                    System.debug('*** s *** ' + s);
                    System.debug('*** s.left(3) *** ' + s.left(3) ); 
                    if(!tierMap.containsKey(s + '-' + p.Name)){
						System.debug('*** INSIDE !tierMap.containsKey(s) ***'); 
                        system.debug('*** p.Name: ' + p.Name);
                        tiers newTier = new tiers();
                        newTier.TierName = s + '-' + p.Name;
                        newTier.Price = 0;
                        newTier.Name = 'None'; // Agreement Number
                        newTier.Product_Name = p.Name;
                        newTier.chDesc = 'None'; // Contract Description
                        newTier.TierLevel = decimal.valueOf(s.right(1)); // 1,2,3
                        newTier.TierName = s; // REP1, RSM2, etc.
                        newTier.chKey = 'None'; // Name of the Contract minus the level (-R1, -R2, -M1, etc.)
                        if(s.containsIgnoreCase('National Tier') || s == 'VP'){
                            newTier.TierHeaderNames = s; // National Tier, VP
                        }
                        else{
                            newTier.TierHeaderNames = s.left(3); // REP, RSM, DIR
                        }
                        newTier.chGPORef = 'None'; // GPO Reference
                        system.debug('*** newTier: ' + newTier);
                        tierMap.put(s + '-' + p.Name, newTier);
                    }
                }
            }
        //}
        System.debug('*** tierMap.size() *** ' + tierMap.size() );
        System.debug('*** tierMap *** ' + tierMap);
        System.debug('*** Ending getTiers ***');
        return tierMap;
    }
}