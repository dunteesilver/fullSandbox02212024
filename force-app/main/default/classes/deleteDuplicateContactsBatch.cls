global class deleteDuplicateContactsBatch implements Database.Batchable<sObject> {
	global Database.querylocator start(Database.BatchableContext BC){
	    return Database.getQueryLocator('Select Id from Duplicate_Contact__c');
	}
	
	global void execute(Database.BatchableContext BC, List<Duplicate_Contact__c> scope){
		delete scope;
		database.emptyRecycleBin(scope);
	    
	}
	global void finish(Database.BatchableContext BC){
	  		database.executeBatch(new findDuplicateContactsBatch());
	}
}