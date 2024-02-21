trigger riskUpdater on Risk__c (Before Insert, Before Update) {

    List<Risk__c> tmpRisk=trigger.new;
    
    for(Risk__c r:tmpRisk){
        String key = r.Likelihood_of_Occurrence__c+r.Impact_of_Risk__c;
        List<Risk_Lookup__c> tmpLookup = [SELECT Rating__c, Traffic_Light__c FROM Risk_Lookup__c WHERE Name = :key];
        if(tmpLookup.size() > 0){
            r.Current_Risk_Level__c = tmpLookup[0].Traffic_Light__c;
            r.Risk_Rating__c = tmpLookup[0].Rating__c;
        }
    }
}