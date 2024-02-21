/*********************************************************************
* Description      : Trigger prevents overlap of assignment of VPS units.
* Test Class       : demoAssignedTest
* Author(s)        : Dun Silver
**********************************************************************/
trigger demoAssigned on Demo__c (before insert,before update) {

    //list to hold Ids
    List<Id> vpsId = new List<Id>();
    List<Id> demoId = new List<Id>();
    //list to hold matching demos
    List<Demo__c> match = new List<Demo__c>();

    for (Demo__c d : Trigger.new){
        //collect new VPS Ids
        vpsId.add(d.VPS_Console__c);
        //collect Demo Ids
        demoId.add(d.Id);
    }


    if(Trigger.isUpdate){
        //list of VPS Units tied to demos and not the same demo Id
        match = [Select VPS_Console__c, Name, Start_Date__c, End_Date__c From Demo__c Where VPS_Console__c  =:vpsId AND Id !=:demoId ];
    }else{
        //list of VPS Units tied to demos
        match = [Select VPS_Console__c, Name, Start_Date__c, End_Date__c From Demo__c Where VPS_Console__c  =:vpsId];
    }

    String errormessage;
    for(Demo__c curr : Trigger.new){
        for(Demo__c ex : match){
            //logic to check for overlapping dates
            if((curr.Start_Date__c >= ex.Start_Date__c && curr.Start_Date__c <= ex.End_Date__c)
               || (curr.End_Date__c >= ex.Start_Date__c && curr.End_Date__c <= ex.End_Date__c ) ||
               (curr.Start_Date__c <= ex.Start_Date__c && curr.End_Date__c >= ex.End_Date__c) ){
                   String sDate = String.valueOf(ex.Start_Date__c);
                   String eDate = String.valueOf(ex.End_Date__c);
                   sDate = sDate.substring(6,10) + '-' + sDate.substring(0,4);
                   eDate = eDate.substring(6,10) + '-' + eDate.substring(0,4);
                   errormessage = 'Date range overlap! Please see demo record ' + ex.Name + ' to check conflicting dates of ' +
                       sDate + ' to ' + eDate + '.';
                   if(errormessage != null){curr.addError(errormessage);}
               }
        }

    }
}