trigger master_Contract_Customer on Contract_Customer__c (before insert, before update, after insert, after update) {
    master_TriggerHelperClass.recursiveBlockSet('Account');
}