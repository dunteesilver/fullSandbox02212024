trigger ContentDocumentTrigger on ContentDocument (before delete) {
    
    if(Trigger.isBefore){
        if(Trigger.isDelete){
              // Delete Triggers only run on ContentDocument and NOT on ContentDocumentLink
            ContentDocumentTrigHandler.beforeDeleteHandler(Trigger.old);
        }
    }

}