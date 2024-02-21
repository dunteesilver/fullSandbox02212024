/*********************************************************************
* Description      : Trigger prevents dupe records for rep VPS request.
* Test Class       : dupeRepTest
* Author(s)        : Dun Silver
**********************************************************************/
 trigger dupeRep on Request_Demo_Unit__c (before insert, before update) {

    //list to hold Ids
    List<Id> repId = new List<Id>();
    Map<Id,String> repMap = new Map<Id,String>();

    for(Request_Demo_Unit__c r : Trigger.new){
        //collect new rep Ids
        repId.add(r.User__c);
        //repMap.put(r.User__c,r.Choose_Unit__c);
        repMap.put(r.User__c,r.Trainings__c);
    }//end of for(Request_Demo_Unit__c r : Trigger.new)

    //map rep lookup UserId to existing User record Ids
    Map<Id, User> mapUser = new Map<Id, User>([Select Name From User Where Id IN :repId ]);

    requestDemoDupeCheck dupes = new requestDemoDupeCheck();
    Boolean dupeList = dupes.dupeCheck(repMap);
    //Boolean dupeList = dupes.dupeCheck1(repMap);
    System.debug('*** dupeList *** ' + dupeList);
    //check if any dupes in list
    if(dupeList){
        System.debug('*** IN if dupeList.size() Check ***');
        String errorMessage = '';

        for(Request_Demo_Unit__c rep : Trigger.new){
            errorMessage = 'Duplicate record found! You cannot create two records with the same user and unit combination...';
            rep.addError(errorMessage);
        }
        //get record ids for existing reps
    }
    else{
        for(Request_Demo_Unit__c rep : Trigger.new){
          //set user name and owner
          rep.Name = mapUser.get(rep.User__c).Name;
          rep.OwnerId = mapUser.get(rep.User__c).Id;
        }

    }//end else

}