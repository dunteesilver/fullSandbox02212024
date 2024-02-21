trigger master_Latam_Sales_Transactions on Latam_Sales_Transactions__c (before insert, before update, before delete, after insert, after update) {
    if(
        (Trigger.isUpdate || Trigger.isInsert) &&
        Trigger.isBefore
    ){
        String triggerType = 'Update';
        if(Trigger.isInsert){
            triggerType = 'Insert';
        }
        System.debug('[1] ' + triggerType + ' - BEFORE trigger -------');
        for(Latam_Sales_Transactions__c lst : trigger.new){
            if(lst.Product_Family1__c <> lst.Product_Family_Map__c)
                lst.Product_Family1__c = lst.Product_Family_Map__c;
        }
    }
}