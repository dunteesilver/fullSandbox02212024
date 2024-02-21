/*********************************************************************
* Description      : Handler class for ContentDocumentLink Trigger 
                     to update Number_Of_Attached_Files on Education_Record__c based on uploaded attached files
* Test Class       : ContentDocumentLinkTriggerHandleTest.apxc
* Author(s)        : Saya Zhangabatyr - saya.zhangabatyr@teleflex.com
* Date         	   : 12/14/2023
* Work Item		   : W-
**********************************************************************/
public class ContentDocumentLinkTriggerHandler {
    
    //fileCountOnEducationRecord method takes ContentDocumentLink as a param, and updates 'Number of Attached Files' field on Education Record
    //based on the count of uploaded files/docs on Education Record
    	public static void fileCountOnEducationRecord(List<ContentDocumentLink> newContentDocumentLinks){
        Set<Id> educationRecordIds = new Set<Id>();
        for(ContentDocumentLink cdl : newContentDocumentLinks){
        //LinkedEntityId is to extract the ID of related record to which a document is linked.    
        educationRecordIds.add(cdl.LinkedEntityId);

        }
        List<Education_Record__c> educationRecordList = [SELECT Id, Number_Of_Attached_files__c,(SELECT Id FROM ContentDocumentLinks) 
                                                         FROM Education_Record__c WHERE Id IN :educationRecordIds];
        for(Education_Record__c educationRecord : educationRecordList){
        educationRecord.Number_Of_Attached_Files__c = educationRecord.ContentDocumentLinks.size();
         System.debug('educationRecord.ContentDocumentLinks.size() '+educationRecord.ContentDocumentLinks.size());
        }
            update educationRecordList;
            
            //when there is a Education record created with ID, and file/document is linked to it, then ContentDocumentLink record will be
            //created with LinkedEntityId and set to the Education Record Id

    }
}