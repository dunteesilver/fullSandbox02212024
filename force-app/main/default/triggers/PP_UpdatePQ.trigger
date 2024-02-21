trigger PP_UpdatePQ on PRF__c (after update) {
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('---- UPDATE and AFTER Trigger (PP_UpdatePQ) ----');

        List<PRF__c> appPRF = new List<PRF__c>();
        List<String> prfIds = new List<String>();

        for(PRF__c curr : Trigger.New){

            if( (curr.Status__c == 'Approved'
               && Trigger.oldMap.get(curr.Id).Status__c != 'Approved'
               && curr.Price_Quote__c != NULL) || (curr.Status__c == 'Rejected'
                  && Trigger.oldMap.get(curr.Id).Status__c != 'Rejected'
                  && curr.Price_Quote__c != NULL) )
            {
                //appPRF.add(curr);
                prfIds.add(curr.Id);
            }

        }//end for loop
        if(prfIds.size() > 0){
            PP_CreateRecord co = new PP_CreateRecord();
            //co.updatePQ(appPRF);
            co.updatePQ(prfIds);
        }

    }//end first If
}//end of Trigger