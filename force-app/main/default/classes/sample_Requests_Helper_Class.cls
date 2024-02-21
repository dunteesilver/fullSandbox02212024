public class sample_Requests_Helper_Class {
    public static void fixSalesOrg(List<Sample_Request__c> newTrigger){
        // Should only happen if the record is created from the mobile?
        set<Id> oIds = new set<Id>();
        for(Sample_Request__c sr : newTrigger){
            if(sr.Sales_Org_Key__c == NULL){
                oIds.add(sr.OwnerId);
            }
        }
        if(oIds.size() > 0){
            map<Id, String> oMap = new map<Id, String>();
            for(Contract_User__c cu : [SELECT User__c, Active_Sales_Org_Key__c
                                       FROM Contract_User__c
                                       WHERE User__c = :oIds])
            {
                if(cu.Active_Sales_Org_Key__c != NULL){
                    oMap.put(cu.User__c, cu.Active_Sales_Org_Key__c);
                }
            }
            if(oMap.size() > 0){
                for(Sample_Request__c sr : newTrigger){
                    if(sr.Sales_Org_Key__c == NULL && oMap.containsKey(sr.OwnerId)){
                        sr.Sales_Org_Key__c = oMap.get(sr.OwnerId);
                    }
                }
            }
        }
    }

    //method to reassign approver
    public static void assignToTerritoryManager(Sample_Request__c sr){
      System.debug('*** Starting assignToTerritoryManager in sample_Requests_Helper_Class ***');
      //hold manager Id for approval
      Id approverId = null;
      List<User> userRec = new List<User>();
      List<User> updateUser = new List<User>();

      approverId = sr.TerritoryManager__c;

      userRec = [SELECT Id, RCEM__c FROM User WHERE Id =: sr.OwnerId LIMIT 1];

      //check is userRec retrieved
      if(userRec.size() > 0 ){
        //Set RCEM User Record
        User u = new User(
          Id = userRec[0].RCEM__c,
          RCEM__c = sr.TerritoryManager__c
        );
        updateUser.add(u);

        try{
          update updateUser;
        }catch(Exception e){
          System.debug('*** Error e *** ' + e);
        }//end try/catch block

      }else{
        System.debug('*** userRec.size NOT > 0 *** ');
      }//end else

    }//end assignToTerritoryManager

    //method to reassign approver
    public static void removeTerritoryManager(Sample_Request__c sr){
      System.debug('*** Starting assignToTerritoryManager in sample_Requests_Helper_Class ***');
      //hold manager Id for approval
      Id approverId = null;
      List<User> userRec = new List<User>();
      List<User> updateUser = new List<User>();

      approverId = sr.TerritoryManager__c;

      userRec = [SELECT Id, RCEM__c FROM User WHERE Id =: sr.OwnerId LIMIT 1];

      //check is userRec retrieved
      if(userRec.size() > 0 ){
        //Set RCEM User Record
        User u = new User(
          Id = userRec[0].RCEM__c,
          RCEM__c = NULL
        );
        updateUser.add(u);

        try{
          update updateUser;
        }catch(Exception e){
          System.debug('*** Error e *** ' + e);
        }//end try/catch block

      }else{
        System.debug('*** userRec.size NOT > 0 *** ');
      }//end else

    }//end assignToTerritoryManager

}