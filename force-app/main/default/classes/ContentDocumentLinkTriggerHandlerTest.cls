@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    
    @testSetup
    static void createTestData(){
      List<Education_Record__c> educationRecords = new List<Education_Record__c>();
      List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();

// Create Education records
for (Integer i = 0; i <10; i++) {
    Education_Record__c edu = new Education_Record__c(
        Name = 'Education Record ' + i,
        InserterType__c='Provider',
        Recommended_Hotel_1st_Choice__c='Viva',
        First_City__c='New York', 
        First_Street_Address__c='8318 BroadWay');
        educationRecords.add(edu);
}
// Insert Education records
insert educationRecords;

        //List<Id> contentDocumentIds = new List<Id>{'069Oy000000e7nZIAQ', '069Oy000000eI9VIAU', '069Oy000000eFoMIAU'};//069Oy000000erLlIAI
         //Creating ContentDocument through ContentVersion object
     
      ContentVersion contentVersion= new ContentVersion(
      Title = 'Education Record',
      PathOnClient = 'TrainingChart.jpg',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    
    insert contentVersion;
   // Create ContentDocumentLink records for associated files/documents
 
// Looping through each combination of eduRecordId and contentDocumentId to create ContentDocumentLink
   List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId 
                                     FROM ContentDocument];
        
   for (Education_Record__c eduRecord : educationRecords) {     
    ContentDocumentLink link = new ContentDocumentLink(
        LinkedEntityId = eduRecord.Id,
        ContentDocumentId =documents[0].Id,        
        ShareType = 'V'
    );
    documentLinks.add(link);
    }

// Insert ContentDocumentLink records
insert documentLinks;
      
        
    }

    
    @isTest static void testFileCountOnEducationRecord(){
          Test.startTest();
        //List<ContentDocumentLink> listOfContenDocLinks=[SELECT LinkedEntityId FROM ContentDocumentLink limit 1];
       // ContentDocumentLinkTriggerHandler.fileCountOnEducationRecord(listOfContenDocLinks);
         List<Education_Record__c> listOfEducationRecords=[SELECT Id, Name, Number_Of_Attached_Files__c FROM Education_Record__c];
        Test.stopTest();
        System.debug('File count list Of Education Records '+listOfEducationRecords);
        for(Education_Record__c eduRecord:listOfEducationRecords){
            System.assertEquals(1,eduRecord.Number_Of_Attached_Files__c);
        }
    }
    @isTest static void testDeleteFiles(){
        Test.startTest();
        List<ContentDocument> listOfAttachments=[SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
         System.debug('Printing listOfAttachments '+listOfAttachments);
        List<ContentDocument> listToDelete=new List<ContentDocument>();
        Set<Id> setOfContentDocumentIds=new Set<Id>();
          for(ContentDocument contentDocument:listOfAttachments){
            setOfContentDocumentIds.add(contentDocument.Id);
              listToDelete.add(contentDocument);
          }
         delete listToDelete;
         Test.stopTest();
                
         System.debug('Printing listToDelete '+listToDelete);
        
        List<Education_Record__c> listOfEducationRecords=[SELECT Id, Name, Number_Of_Attached_Files__c 
                                                          FROM Education_Record__c];
        System.debug('Printing listOfEducationRecords '+listOfEducationRecords);
        for(Education_Record__c eduRecord:listOfEducationRecords){
            System.assertEquals(0, eduRecord.Number_Of_Attached_Files__c);
        }
    }
    

}