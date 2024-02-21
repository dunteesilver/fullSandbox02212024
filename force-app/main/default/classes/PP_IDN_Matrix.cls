/*********************************************************************
* Description      : Controller Class for Pricing Portal IDN Matrix.
* Test Class       : PP_IDN_Matrix_Test
* VisualForce      : PP_IDN_Matrix
* Author(s)        : Eric Clay
**********************************************************************/
public with sharing class PP_IDN_Matrix {

    public list<Contract_Header__c> getIDNlist(){
        try {
            return [Select Owner__c, Owner_Name__c, Agreement_Number__c, Description__c, Group_Name__c,
                    Division_10__c, Division_20__c, Division_30__c, Division_40__c, Division_50__c,
                    Division_60__c, Material_Count__c, Account_Count__c, Valid_From__c, Valid_To__c
                    FROM Contract_Header__c
                    WHERE Active__c = TRUE
                    AND Owner__c = :ApexPages.currentPage().getParameters().get('oid')];
        }
        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }

    public List<IDN_PickList__c> getItems() {
        try {
            return [SELECT Key__c, Name, Active__c FROM IDN_PickList__c WHERE Active__c = TRUE AND Sales_Org_Key__c = :PP_Menu.salesPrefix ORDER BY Name];
        }
        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }

    public String ownerName {
        get {
            String owner_name = '';
            try{
                if(ApexPages.currentPage().getParameters().get('oid') != NULL){
                    owner_name = [Select Owner_Name__c
                                  FROM Contract_Header__c
                                  WHERE Owner_Name__c != NULL
                                  AND Active__c = TRUE
                                  AND Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                                  LIMIT 1].Owner_Name__c;
                }
                return owner_name;
            }
            catch(Exception e){
                system.debug('Exception: ' + e);
                return NULL;
            }
        }
        set; }

    public String ownerID {
        get {
            string owner_id;
            if(ApexPages.currentPage().getParameters().get('oid') != NULL){
                owner_id = ApexPages.currentPage().getParameters().get('oid');
            }
            return owner_id;
        }
        set; }

}