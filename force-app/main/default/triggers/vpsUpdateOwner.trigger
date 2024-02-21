/*********************************************************************
* Description      : Trigger updates owner to the requested user.
* Test Class       : vpsUpdateOwnerTest
* Author(s)        : Dun Silver
**********************************************************************/
trigger vpsUpdateOwner on VPS_Console__c (before insert, before update) {

    //list to hold Ids
    List<Id> listId = new List<Id>();
    for (VPS_Console__c curr : Trigger.new){
        //collect new rep Ids
        listId.add(curr.Approved_Rep__c);
    }

    //map rep lookup UserId to existing User record Ids
    Map<Id, Request_Demo_Unit__c> match = new Map<Id, Request_Demo_Unit__c>([SELECT User__c FROM Request_Demo_Unit__c WHERE Id = :listId]);

    for (VPS_Console__c own : Trigger.new){
        //get owner ID  from User record and set to Owner field
        if(match.size() > 0){
            own.OwnerId = match.get(own.Approved_Rep__c).User__c;
        }

    }
}