/*********************************************************************
* Description      : Class handles printing of PRFs
* Coverage         : Classes(PP_Global_Test_Class) 
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
public class PP_PRF_Export {
    public PRF__c getPRF(){
        return [SELECT Name, Account__r.Name, Status__c, Account__r.SAP_Sold_To__c, Requisition_Date__c,
                Agreement_Type__c, Account__r.BillingStreet, Eligible_Distributor__c,  Account__r.BillingCity,
                Account__r.BillingState, Account__r.BillingPostalCode, Current_Annual_Purchases__c, Contact__r.name,
                Estimated_Annual_Purchases__c, Contact__r.email, Preferred_Start_Date__c, Owner_Full_Name__c,
                Preferred_End_Date__c, Owner_Business_Unit__c, Data_Driven_Justification__c, Additional_Accounts__c,
                Territory__r.Territory_Number__c, Territory__r.Territory_Name__c, GPO_Affiliation__c, Sales_Org_Key__c
                FROM PRF__c
                WHERE id = :ApexPages.currentPage().getParameters().get('id')
                LIMIT 1];
    }

    public list<PRF_Line_Item__c> getPLI(){
        return [SELECT Material_Name__r.Name, Material_Name__r.Description, Sales_Deal_Num__c, Sales_Deal_Description__c,
                Condition__c, CurrencyIsoCode, List_Price__c, Rep_Price__c, RSM_Price__c, Requested_Price__c,
                Eligible_Price__c, Objective_Name__c, Approval_Flag_Reason__c, Approval_Flag_Checkbox__c, Product_Description__c
                FROM PRF_Line_Item__c
                WHERE PRF__c = :ApexPages.currentPage().getParameters().get('id')];
    }


    public String rxls {
        get {
            string temp_name;
            PRF__c prf;
            prf = [Select PRF_Name__c, Sales_Org_Key__c FROM PRF__c WHERE id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];
            if(ApexPages.currentPage().getParameters().get('id') != NULL){
                temp_name = 'PRF - ' + prf.PRF_Name__c;
                //temp_name += [Select PRF_Name__c, Sales_Org_Key__c FROM PRF__c WHERE id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1].PRF_Name__c;
                if(prf.Sales_Org_Key__c == 'AU1010' || prf.Sales_Org_Key__c == 'NZ1010'){
                    temp_name += ' - ' + datetime.now().format('dd-MM-yyyy');
                }
                else{
                    temp_name += ' - ' + datetime.now().format('MM-dd-yyyy');
                }
                //temp_name += ' - ' + datetime.now().format('MM-dd-yyyy');
                temp_name = temp_name.replaceAll(',', '');
                temp_name += 'application/vnd.ms-excel#' + temp_name + '.xls';
            }
            return temp_name;
        }
        set; }

    //get approval history info
    public List<ProcessInstanceStep> getApprovalInfo(){

      //list to hold Records
      List<ProcessInstanceStep> appInfo = new List<ProcessInstanceStep>();
      /*
      appInfo = [SELECT Id,TargetObjectid, Status, CreatedDate,
               (SELECT Id, Actor.Name FROM Workitems),
               (SELECT Id, StepStatus, Comments, Actor.Name, OriginalActor.Name, CreatedDate FROM Steps ORDER BY CreatedDate ASC)
               FROM ProcessInstance WHERE TargetObjectId =:ApexPages.currentPage().getParameters().get('id')];
      */
      appInfo = [SELECT Id, StepStatus, Comments, Actor.Name, OriginalActor.Name, CreatedDate,
               ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate
               FROM ProcessInstanceStep
               WHERE ProcessInstance.TargetObjectId =:ApexPages.currentPage().getParameters().get('id')
               ORDER BY CreatedDate ASC];

      return appInfo;
    }

}