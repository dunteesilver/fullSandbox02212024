trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert ) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ContentDocumentLinkTriggerHandler.fileCountOnEducationRecord(Trigger.new);
        }
    }

}