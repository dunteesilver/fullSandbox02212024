public with sharing class RecordTypesController {

    public List<RecordType> recs {get; private set;}

    public RecordTypesController() {
        recs = [SELECT Id, Name, IsActive, SobjectType, DeveloperName FROM RecordType ORDER BY SobjectType ASC];
    }

}