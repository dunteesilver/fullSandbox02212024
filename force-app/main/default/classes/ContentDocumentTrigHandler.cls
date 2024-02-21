/*********************************************************************
* Description      : Handler class for ContentDocument Trigger 
                     to update Number_Of_Attached_Files on Education_Record__c based on 
                     deletion of its attached files
* Test Class       : ContentDocumentLinkTriggerHandlerTest.apxc
* Author(s)        : Saya Zhangabatyr - saya.zhangabatyr@teleflex.com
* Date         	   : 12/14/2023
* Work Item		   : W-
**********************************************************************/
public class ContentDocumentTrigHandler {
    public static void beforeDeleteHandler(List<ContentDocument> contentDocList){
        deleteFiles(contentDocList);
    }

    //deleteFiles method takes List of ContentDocuments as a param
    //below method grabs a Set of ContentDocument IDs in trigger.old, 
    // then queries ContentDocumentLinks with ContentDocumentIDs matching with those in list
    public static void deleteFiles(List<ContentDocument> contentDocList){
        Set<Id> contentDocumentIds=new Set<Id>();
        for(ContentDocument contentDocument:contentDocList){
            contentDocumentIds.add(contentDocument.Id);
        }
        
        List<ContentDocumentLink> contentDocLinks = [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIds];
        Set<Id> educationRecordIds=new Set<Id>();
        for(ContentDocumentLink contentDocLink:contentDocLinks){
            educationRecordIds.add(contentDocLink.LinkedEntityId);
        }
        //a method is being called to update Education Records after deleting linked files to it
        educationRecordAttachmentDeleteUpdate(educationRecordIds);
    }
    
    @future
    public static void educationRecordAttachmentDeleteUpdate(Set<Id>educationRecordIds){
        // quering for Education Records with IDs that match the LinkedEntityId from the ContentDocumentLink records in the query
        List<Education_Record__c> educationRecordList=[SELECT Id, (SELECT Id FROM ContentDocumentLinks)
                                                       FROM Education_Record__c
                                                      WHERE Id IN:educationRecordIds];
        System.debug('Education Records List=> '+educationRecordList);
         System.debug('Education Records List Size=> '+educationRecordList.size());
        
         for(Education_Record__c educationRecord : educationRecordList){
        educationRecord.Number_Of_Attached_Files__c = educationRecord.ContentDocumentLinks.size();

        }
            update educationRecordList;
    }
}