/*********************************************************************
* Description      : Controller Class for Pricing Portal Select Account.
* Test Class       : PP_SelectAccount
* VisualForce      : PP_SelectAccount
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
Public with sharing class PP_SelectAccount{

    Public String strCust{get; set;}
    public String prf {
        get {
            if(ApexPages.currentPage().getParameters().get('prf') != NULL){
                return '&prf=' + ApexPages.currentPage().getParameters().get('prf');
            }
            return NULL;
        }
        set;
    }

    public String pq {
        get {
            if(ApexPages.currentPage().getParameters().get('pqId') != NULL){
                return '&pqId=' + ApexPages.currentPage().getParameters().get('pqId');
            }
            return NULL;
        }
        set;
    }

    //method to get URL paraments and redirect
    public pagereference getURL(){

        String quoteId = ApexPages.currentPage().getParameters().get('pqID');
        string search = strCust;
        if(search != NULL){
            search = search.trim();

            if(prf != NULL) search += prf;

            if(pq != NULL) search += pq;


            PageReference getCustomer = New Pagereference('/apex/PP_SelectAccount?gs=off&cid=' + search);
            getCustomer.setRedirect(true);
            System.debug('search in Cust Details GET URL ===================================== ' + search);
            return getCustomer;

        }
        else{
            return NULL;
        }


    }

    public string currSalesOrgKey{get;set;}
    public list<Account> getSearch(){
        //Get parameter from URL and assign to string variable
        if(ApexPages.currentPage().getParameters().get('cid') != NULL){
            string cid = ApexPages.currentPage().getParameters().get('cid');
            cid = cid.trim();
            system.debug('cid: ' + cid);


            if(cid.length() < 2){
                apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.label.EMEA_Search_Terms_must_be_longer_than_one_character));
                return NULL;
            }
            else{
                currSalesOrgKey = PP_Menu.cUserTemp.Active_Sales_Org_Key__c;
                System.debug('****PP_Menu.cUserTemp.Active_Sales_Org_Key__c**** ' + currSalesOrgKey);
                transient String searchQuery = 'FIND \'' + cid + '\' IN ALL FIELDS RETURNING Account(SAP_Sold_To__c,Name,Account_Name_2__c,ShippingStreet,ShippingCity,' +
                    'ShippingState,ShippingPostalCode, Account_Group__c, Customer_Group__c, Customer_Group_Name__c, ERP_Active__c, Main_GPO__c, Secondary_GPO__c ' +
                    'WHERE Sales_Org_Key__c = \'' + currSalesOrgKey + '\' AND (Account_Group__c = \'Z001\' OR Account_Group__c = \'Z002\' OR Account_Group__c = \'ZREB\'))';

                //add searchQuery to a lists
                List<List <sObject>> searchList = search.query(searchQuery);
                list<Account> accountInfo = ((List<Account>)searchList[0]);
                System.debug('accountInfo ===================================== ' + accountInfo);

                //error check for empty list returns
                if(accountInfo.size() == 0){
                    apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.label.EMEA_Sorry_no_results_returned_with_matching_string));
                    return NULL;
                }
                else{
                    return accountInfo;
                }
            }

        }
        else{
            return NULL;
        }
    }

    //Get Recent Accounts for current user
    public list<Account> getAccs(){
        return [SELECT Id, Name, SAP_Sold_To__c, ERP_Active__c, Account_Name_2__c,
                ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Main_GPO__c, Secondary_GPO__c
                FROM Account
                WHERE LastViewedDate != NULL
                ORDER BY LastViewedDate DESC limit 10];
    }

    //Get Recent Quotes for current user
    public list<Price_Quote__c> getPqs(){
        return [SELECT Id, Name, Contact_Name__r.Name, Account_Name__r.Name
                FROM Price_Quote__c
                WHERE LastViewedDate != NULL
                ORDER BY LastViewedDate DESC limit 10];
    }

}