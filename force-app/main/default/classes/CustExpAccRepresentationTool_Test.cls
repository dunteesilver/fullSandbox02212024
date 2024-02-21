/*********************************************************************
* Description      : Test class for CustExpAccRepresentationTool
* Test Class       : CustExpAccRepresentationTool_Test
* VisualForce      : N/A
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com

//initial version work item: W-023175 sprint: 2020.05
**********************************************************************/
@isTest public class CustExpAccRepresentationTool_Test {
    
    
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
        
        public SalesRepAccWarpper(
                                  String salesRepName
                                  )
        {

            this.salesRepName = salesRepName;
        }
        
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
    
    static testmethod void cxTestMethod(){
        
        Account acc = new Account();
        acc.Name = 'CXTestAcc';
        acc.SAP_Sold_To__c = '123456';
        acc.SAP_Code__c='123456';
        insert acc;
        
        Contact conTest = new Contact(
            LastName = 'CXlstNme',
            Email='cx@123.com',
            AccountId = acc.Id,
            FirstName = 'CXFstNme',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)'
            
        );
        insert conTest;
        
        Contact conTest1 = new Contact(
            LastName = 'CXlstNme1',
            Email='cx1@123.com',
            FirstName = 'CXFstNme1',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)'
            
        );
        insert conTest1;
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'uflex76',
            email='unit.test@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Adam',
            lastname='Franks',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p.Id,
            timezonesidkey='Europe/London',
            username='unit.test@unit.teleflex.com',
            Business_Unit__c='BU'
        );
        insert u;
        
        Map<Id,Set<Id>> srVsAccsMapFinal = new Map<Id,Set<Id>>();
        Set<Id> accIdsSet = new Set<Id>();
        
        accIdsSet.add(acc.Id);
        srVsAccsMapFinal.put(u.id, accIdsSet);
        
        CX_Sales_Rep_Feedback__c cxfdbkObj = new CX_Sales_Rep_Feedback__c();
        cxfdbkObj.Sales_Rep__c = u.Id;
        cxfdbkObj.Survey_Key__c = 'SK-2020-06-17';
        insert cxfdbkObj;
        
        CX_Sales_Rep_Account__c cxSalRepObj = new CX_Sales_Rep_Account__c();
        cxSalRepObj.id = cxSalRepObj.id;
        cxSalRepObj.CX_Sales_Rep_Feedback__c = cxfdbkObj.Id;
        cxSalRepObj.Sales_Rep_Customer__c = acc.Id;
        cxSalRepObj.Yes__c = true;
        cxSalRepObj.No__c = true;
        cxSalRepObj.If_no_then_do_you_know_who__c = 'Surya Arvan';
        insert cxSalRepObj;
        
         SalesRepAccWarpper salesRepAccWarpperObj = new SalesRepAccWarpper(
                                                                cxSalRepObj.ID
                                                                , cxSalRepObj.CX_Sales_Rep_Feedback__c
                                                                , cxSalRepObj.CX_Sales_Rep_Feedback__r.Business_Unit__c
                                                                , cxSalRepObj.Sales_Rep_Customer__r.SAP_Sold_To__c
                                                                , cxSalRepObj.Sales_Rep_Customer__r.Name
                                                                , cxSalRepObj.CX_Sales_Rep_Feedback__r.Sales_Rep__r.Name
                                                                , cxSalRepObj.Yes__c
                                                                , cxSalRepObj.No__c
                                                                , cxSalRepObj.If_no_then_do_you_know_who__c
                                                            );
        
        List<SalesRepAccWarpper> salesRepAccWarpperObjLst = new List<SalesRepAccWarpper>();
        salesRepAccWarpperObjLst.add(salesRepAccWarpperObj);
        
        String updStr = JSON.serialize(salesRepAccWarpperObjLst);
        
        String surveykey = 'SK-2020-06-17';
        
        Test.StartTest(); 
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acc.Id));
        String s = ApexPages.currentPage().getParameters().get('id');
        CustExpAccRepresentationTool  custExpConstructorObj = new CustExpAccRepresentationTool();
        CustExpAccRepresentationTool.fetchContact(conTest.Id);
        CustExpAccRepresentationTool.sendCXAccRepEmailTemp2Con(conTest);
        
        //SalesRepAccDetails.saveData(srVsAccsMapFinal);
        SalesRepAccDetails.saveSalesRepFeedbackDetails(updStr);
        
        System.runAs(u){
                  SalesRepAccDetails.getSalesRepAccDetailsWithSales(surveykey);  
        }
        
        Test.StopTest();
          
    }
}