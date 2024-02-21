/*********************************************************************
* Description      : Controller Class for Pricing Portal PP_Update_Sales_Org.
* Test Class       : PP_Update_Sales_Org_Test
* VisualForce      : PP_Update_Sales_Org
* Author(s)        : Eric Clay
**********************************************************************/
public class PP_Update_Sales_Org {
    public void updateSalesOrg3() {
        if(ApexPages.currentPage().getParameters().get('so') != NULL){
            for(Contract_User__c cc : [SELECT Id, Active_Region__c
                                       FROM Contract_User__c
                                       WHERE User__c = :UserInfo.getUserId()
                                       LIMIT 1])
            {
                string so = ApexPages.currentPage().getParameters().get('so');
                string salesCurrency;
                string salesOrgKey;
                if(so.left(2) == 'US'){
                    salesCurrency = 'USD';
                    salesOrgKey = 'US103010';
                }
                else if(so.left(2) == 'CA'){
                    salesCurrency = 'CAD';
                    salesOrgKey = 'CA1010';
                }
                else if(so.left(2) == 'LA'){
                    salesCurrency = 'USD';
                    salesOrgKey = 'US103020';
                }
                else if(so.left(2) == 'MX'){
                    salesCurrency = 'MXN';
                    salesOrgKey = 'MX4010';
                }
                else if(so.left(2) == 'CL'){
                    salesCurrency = 'CLP';
                    salesOrgKey = 'CL1010';
                }
                else if(so.left(2) == 'CO'){
                    salesCurrency = 'COP';
                    salesOrgKey = 'CO1010';
                }
                Contract_User__c updateCC = new Contract_User__c(
                    Id = cc.Id,
                    Active_Region__c = so,
                    Active_Currency__c = salesCurrency,
                    Active_Sales_Org_Key__c = salesOrgKey,
                    Update_Type__c = 'updateSO'
                );
                try {
                    update updateCC;
                }
                catch(DmlException e){
                    system.debug('Exception: ' + e);
                }
                system.debug('updateCC: ' + updateCC);
            }

        }

    }
}