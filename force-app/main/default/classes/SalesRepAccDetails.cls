/*********************************************************************
* Description      : Controller class to save sales rep customer details form lightning tab /lightning/n/Sales_Rep_Customer_Details.
* Test Class       : CustExpAccRepresentationTool_Test
* VisualForce      : N/A
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com

//initial version work item: W-023175 sprint: 2020.05
**********************************************************************/
public class SalesRepAccDetails {

    @AuraEnabled
    public static List<CX_Sales_Rep_Account__c> saveSalesRepFeedbackDetails(String updSalRepAccLst){
        
        List<CX_Sales_Rep_Account__c> cxSalRepAccLst = new List<CX_Sales_Rep_Account__c>();
        if(!String.isBlank(updSalRepAccLst)){
            List<SalesRepAccWarpper> salesRepAccWarpperObjLst = (List<SalesRepAccWarpper>)JSON.deserialize(updSalRepAccLst, List<SalesRepAccWarpper>.class);
            for(SalesRepAccWarpper salesRepAccWarpperObj : salesRepAccWarpperObjLst){
                CX_Sales_Rep_Account__c cxSalesRepAccountObj = new CX_Sales_Rep_Account__c();
                cxSalesRepAccountObj.Id = salesRepAccWarpperObj.cxsrAccId;
                if(!String.isBlank(String.valueOf(salesRepAccWarpperObj.yesChk)))cxSalesRepAccountObj.Yes__c = salesRepAccWarpperObj.yesChk;
                if(!String.isBlank(String.valueOf(salesRepAccWarpperObj.noChk)))cxSalesRepAccountObj.No__c = salesRepAccWarpperObj.noChk;
                cxSalesRepAccountObj.If_no_then_do_you_know_who__c = salesRepAccWarpperObj.if_no_then_do_you_know_who;
                cxSalRepAccLst.add(cxSalesRepAccountObj);
            } 
            
            update cxSalRepAccLst;
        }
        return cxSalRepAccLst;
    }
    
    @AuraEnabled
    public static List<SalesRepAccWarpper> getSalesRepAccDetailsWithSales(String surveykey){
        
        List<SalesRepAccWarpper> retList = new List<SalesRepAccWarpper>();
        //Kelly Thomas'005E0000000PhToIAK';//Ethan Curry'0052S000009Tuq4QAC'; //John DeVito --'00544000008eXZTAA2';//Jason Supper --'005E0000007XGNfIAO';   //Kristie --'005440000099AIMAA2';
        Id currUsr = UserInfo.getUserId();
        
        List<CX_Sales_Rep_Feedback__c> salesRepFdbckObjLst = [select Id, Sales_Rep__r.Name from CX_Sales_Rep_Feedback__c where Sales_Rep__r.Id =: currUsr and Survey_Key__c =: surveykey];
        
        
        if(salesRepFdbckObjLst.size() > 0){
            for(CX_Sales_Rep_Account__c salRepAccObj : [select ID
                                                        , Sales_Rep_Customer__r.Name
                                                        , Sales_Rep_Customer__r.SAP_Sold_To__c
                                                        , CX_Sales_Rep_Feedback__c
                                                        , CX_Sales_Rep_Feedback__r.Business_Unit__c
                                                        , CX_Sales_Rep_Feedback__r.Sales_Rep__r.Name 
                                                        , Yes__c
                                                        , No__c
                                                        , If_no_then_do_you_know_who__c
                                                        from CX_Sales_Rep_Account__c where CX_Sales_Rep_Feedback__c =: salesRepFdbckObjLst.get(0).Id]){
                                                            
                                                            SalesRepAccWarpper salesRepAccWarpperObj = new SalesRepAccWarpper(
                                                                salRepAccObj.ID
                                                                , salRepAccObj.CX_Sales_Rep_Feedback__c
                                                                , salRepAccObj.CX_Sales_Rep_Feedback__r.Business_Unit__c
                                                                , salRepAccObj.Sales_Rep_Customer__r.SAP_Sold_To__c
                                                                , salRepAccObj.Sales_Rep_Customer__r.Name
                                                                , salRepAccObj.CX_Sales_Rep_Feedback__r.Sales_Rep__r.Name
                                                                , salRepAccObj.Yes__c
                                                                , salRepAccObj.No__c
                                                                , salRepAccObj.If_no_then_do_you_know_who__c
                                                            );  
                                                            retList.add(salesRepAccWarpperObj); 
                                                        }
        }
        return retList; 
    }
    
    public class SalesRepAccWarpper {
        
        @AuraEnabled public String cxsrAccId {get;set;}
        @AuraEnabled public String cxsrFdbkId {get;set;}
        @AuraEnabled public String businessUnit {get;set;}
        @AuraEnabled public String custCode {get;set;}
        @AuraEnabled public String accName {get;set;}
        @AuraEnabled public String salesRepName {get;set;}
        @AuraEnabled public Boolean yesChk {get;set;}
        @AuraEnabled public Boolean noChk {get;set;}
        @AuraEnabled public String if_no_then_do_you_know_who {get;set;}
        
        public SalesRepAccWarpper(String cxsrAccId, 
                                  String cxsrFdbkId, 
                                  String businessUnit, 
                                  String custCode, 
                                  String accName,
                                  String salesRepName, 
                                  Boolean yesChk, 
                                  Boolean noChk, 
                                  String if_no_then_do_you_know_who)
        {
            this.cxsrAccId = cxsrAccId;
            this.cxsrFdbkId = cxsrFdbkId;
            this.businessUnit = businessUnit;
            this.custCode = custCode;
            this.accName = accName;
            this.salesRepName = salesRepName;
            this.yesChk = yesChk;
            this.noChk = noChk;
            this.if_no_then_do_you_know_who = if_no_then_do_you_know_who;
        }
        
    }
    
}