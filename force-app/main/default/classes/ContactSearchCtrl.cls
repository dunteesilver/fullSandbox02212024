/*********************************************************************
* Description      : methods to get contacts based on search term and account id from lwc and flow respectively.
* Test Class       : ContactSearchCtrlTest.apxc
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
* Date         	   : 10/30/
* Work Item		   : W-025981
* LwC			   : contactSrchMultiSelDataTableLwC 
**********************************************************************/
public with sharing class ContactSearchCtrl {
    /*
*Method Name 		  : getContacts
*Method Input Params : String searchTerm=(Lwc Passed), String accountRecId=(flow passed recordId)
*Method Return type  : List<Contact>
*/
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String searchTerm, String accountRecId) {
        Boolean constantBool = FALSE;
        String searchKey = '%' + searchTerm + '%';
        searchKey = searchKey.trim();
        System.debug('amplify searchTerm-----'+searchTerm);
        System.debug('amplify accountRecId--'+accountRecId);
        list<contact> conList = new list<contact>([SELECT Id, Name, Email, Phone, Account_Name__c FROM Contact WHERE AccountId =:accountRecId AND (Name LIKE :searchKey OR Email LIKE :searchKey) ORDER BY Name ASC]);
        System.debug('conList size-----'+conList.size() +' conList-----'+conList);
        return [SELECT Id, Name, Email, Phone, Account_Name__c 
                FROM Contact 
                WHERE AccountId =:accountRecId
                AND IsEmailBounced=:constantBool
                AND (Name LIKE :searchKey 
                     OR Email LIKE :searchKey
                     OR Phone LIKE :searchKey)
                ORDER BY Name ASC
               ];
    }
}