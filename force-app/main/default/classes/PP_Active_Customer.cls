/*********************************************************************
* Description      : Controller Class for Pricing Portal PP_Active_Customer.
* Test Class       : PP_Active_Customer_Test
* VisualForce      : PP_Active_Customer
* Author(s)        : Eric Clay
**********************************************************************/
public with sharing class PP_Active_Customer{

    public String getfilename(){
        string temp_name;
        for(Contract_Header__c ch : [SELECT Agreement_Number__c, Description__c FROM Contract_Header__c WHERE Active__c = TRUE AND Agreement_Number__c = :Apexpages.currentPage().getParameters().get('aid')]){
            temp_name = ch.Agreement_Number__c + ' - ' + ch.Description__c + ' - ';
            temp_name += datetime.now().format('MM-dd-yyyy');
        }
        return temp_name;
    }
    public Contract_Header__c getCH(){
        return [SELECT Agreement_Number__c, Description__c
                FROM Contract_Header__c
                WHERE Active__c = TRUE
                AND Agreement_Number__c = :Apexpages.currentPage().getParameters().get('aid')];
    }

    public list<Contract_Customer__c> getActiveCustomers(){
        return [SELECT Account__r.name ,Account__r.SAP_Sold_To__c, Condition__c, Account__r.BillingStreet,
                Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingPostalCode,
                Customer_Group__c, Customer_Group_Name__c
                FROM Contract_Customer__c
                WHERE Active__c = TRUE
                AND Agreement_Number__c = :Apexpages.currentPage().getParameters().get('aid')];
    }


}