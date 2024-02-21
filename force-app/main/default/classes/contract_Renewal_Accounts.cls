/*********************************************************************
* Description      : Class provides detail analysis of Accounts/Contracts.
* Test Class       : Contract_Renewal_Test
* VisualForce      : contract_Renewal_Accounts
* Author(s)        : Eric Clay
**********************************************************************/
public class contract_Renewal_Accounts {

    public Contract_Renewal__c cr {get; set;}
    public list<Contract_Customer__c> alist {get; set;}
    public string fname {get; set;}
    public string cid {get; set;}

    public contract_Renewal_Accounts(){
        //Agreement_Number__c = :Apexpages.currentPage().getParameters().get('id')
        cr = new Contract_Renewal__c();
        alist = new list<Contract_Customer__c>();

        if(Apexpages.currentPage().getParameters().get('Id') != NULL){
            cid = Apexpages.currentPage().getParameters().get('Id');
            cr = [SELECT Contract_Header__r.Agreement_Number__c, Contract_Header__r.Description__c
                  FROM Contract_Renewal__c
                  WHERE Id =:cid];
            System.debug('*** cr *** ' + cr);
            //fname = cr.Contract_Header__r.Agreement_Number__c + '-' + cr.Contract_Header__r.Description__c + '-';
            fname = cr.Contract_Header__r.Agreement_Number__c + '-Customers-';
            fname += datetime.now().format('MM-dd-yyyy');

            for(Contract_Customer__c cc : [SELECT Account__r.Id, Account__r.name, Account__r.SAP_Sold_To__c, Condition__c, Account__r.BillingStreet,
                                           Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingPostalCode,
                                           Customer_Group__c, Customer_Group_Name__c, Account__r.SAP_Account_Status__c, Account__r.Type,
                                           Account__r.Secondary_GPO__c, Account__r.Main_GPO__c, Sales__c
                                           FROM Contract_Customer__c
                                           WHERE Active__c = TRUE
                                           AND Agreement_Number__c = :cr.Contract_Header__r.Agreement_Number__c
                                           ORDER BY Account__r.name])
            {
                alist.add(cc);
            }
            System.debug('*** alist *** ' + alist);
        }


    }

}