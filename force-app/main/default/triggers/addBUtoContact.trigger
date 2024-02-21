trigger addBUtoContact on Contact (before insert, before update) {
    String userBU = [SELECT Business_Unit__c FROM User WHERE Id=:userinfo.getUserId()].Business_Unit__c;
    String userProfile = [SELECT Name FROM PROFILE WHERE Id=:userinfo.getProfileId()].Name;

    for(contact c : trigger.new){
        if(c.Business_Unit1__c == NULL && userBU  != NULL && userProfile != 'TFX System Administrator'){
            c.Business_Unit1__c = userBU;
        }
    }
}