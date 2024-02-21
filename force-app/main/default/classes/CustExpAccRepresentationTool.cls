/*********************************************************************
* Description      : Controller class to fetch data from given account and sent account team contact details for business units with $ sales.
* Test Class       : CustExpAccRepresentationTool_Test
* VisualForce      : N/A
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com

//initial version work item: W-023175 sprint: 2020.05
**********************************************************************/
public class CustExpAccRepresentationTool {
    
    @AuraEnabled
    public static Contact fetchContact(Id conId) {
        return [SELECT Id, Name, Email, AccountId, Account.Name from Contact where Id =: conId];
    }
    
    @AuraEnabled
    public static String sendCXAccRepEmailTemp2Con(Contact conObj){
        
        OrgWideEmailAddress orgEm = [select Id, Address from OrgWideEmailAddress WHERE Address='cx@teleflex.com'];
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(conObj.Id); 
        message.setOrgWideEmailAddressId(orgEm.Id);
        message.setReplyTo('cs@teleflex.com');
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'CE Account Representation'];
        message.setTemplateID(emailTemplate.Id); 
        message.setWhatId(conObj.AccountId); //This is important for the merge fields in template to work
        message.toAddresses = new String[] { conObj.email};
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) 
        {
            return 'The email was sent successfully.'; } else { return 'The email failed to send: ' +  results[0].errors[0].message; }
    }
    
    
    
    /*    @AuraEnabled
public static List < account > fetchAccount(String searchKeyWord) {
String searchKey = searchKeyWord + '%';
List < Account > returnList = new List < Account > ();
List < Account > lstOfAccount = [select id, Name from account where Name LIKE: searchKey];

for (Account acc: lstOfAccount) {
returnList.add(acc);
}
return returnList;
}
*/    
    public Account relatedTo {get; set;}
    public List<Territory_Assignment__c> taObjLst {get; set;}
    
    
    public CustExpAccRepresentationTool(){
        
        if(ApexPages.currentPage().getParameters().get('id') != NULL){
            relatedTo = [SELECT Id, Name, ShippingStreet, ShippingCity, ShippingState, Terms__c,
                         ShippingPostalCode, ShippingCountry, SAP_Sold_To__c,
                         Territory_Key__c,
                         Account.Territory__c
                         FROM Account
                         WHERE id = :ApexPages.currentPage().getParameters().get('id')
                         ];
            
            taObjLst = [SELECT Territory_Number__c, Business_Unit__c, 
                        Territory__r.Territory_Number__c,
                        Territory__r.Sales_Rep__r.Name,
                        Territory__r.Sales_Rep__r.Email,
                        Territory__r.Sales_Rep__r.Phone,
                        Territory__r.Primary_Territory_User__r.Name,
                        Territory__r.Primary_Territory_User__r.Email,
                        Territory__r.Primary_Territory_User__r.Phone
                        FROM Territory_Assignment__c
                        WHERE Account__c =:ApexPages.currentPage().getParameters().get('id')
                       ];  
            
        }
        
    }
    
}