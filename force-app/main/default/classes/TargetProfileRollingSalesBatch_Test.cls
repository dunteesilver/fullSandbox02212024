@isTest
public class TargetProfileRollingSalesBatch_Test {
    public static Id HospitalRecTypeId = Schema.getGlobalDescribe().get('Target_Profile__c').getDescribe().getRecordTypeInfosByName().get('Hospital').getRecordTypeId();
    public static Id PreHospitalRecTypeId = Schema.getGlobalDescribe().get('Target_Profile__c').getDescribe().getRecordTypeInfosByName().get('Pre-Hospital').getRecordTypeId();
    
    @testSetup
    static void createData() {
        Account acc = new Account();
        acc.Name = 'Testacc';
        insert acc;
        
        insert new Needle_SKUs__c(Name='9079P-VC-005');
        insert new CVC_SKUs__c(Name='AK-47702-CDC');
        
        BaseQuotaException__c bqe = new BaseQuotaException__c(
            Name = 'territory_user_maintenance',
            IsException__c = TRUE
        );
        insert bqe;
        
        List<Invoiced_Sales__c> sales = new List<Invoiced_Sales__c>();
        Invoiced_Sales__c is1 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 100000,
            Quantity__c = 10
        );
        sales.add(is1);
        Invoiced_Sales__c is2 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 200000,
            Quantity__c = 20
        );
        sales.add(is2);
        Invoiced_Sales__c is3 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = 'AK-47702-CDC',
            Sales__c = 400000,
            Quantity__c = 40
        );
        sales.add(is3);
        insert sales;
        
        List<Target_Profile__c> tps = new List<Target_Profile__c>();
        Target_Profile__c tp = new Target_Profile__c();
        tp.RecordTypeId = PreHospitalRecTypeId;
        tp.Account__c = acc.Id;
        tps.add(tp);
        
        Target_Profile__c tpH = new Target_Profile__c();
        tpH.RecordTypeId = HospitalRecTypeId;
        tpH.Account__c = acc.Id;
        tps.add(tpH);
        
        insert tps;
    }//end of createData
    
    //start testing updateRollingSales
    @isTest
    static void test_updateRollingSales() {
        Test.startTest();
        TargetProfileRollingSalesBatch b = new TargetProfileRollingSalesBatch ();
        database.executebatch(b,115);
        
        String sch='0 0 0 ? * * *';
        String jobId = System.schedule('TargetProfileRollingSalesBatch Schedule', sch , b);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        Test.stopTest();
        System.assertEquals(0, ct.TimesTriggered);
        
        
        List<Target_Profile__c> tp = [SELECT Id, Account__c, RecordTypeId, X12_Month_Rolling_Sales__c, X12_Month_Rolling_Sales_eaches__c,
                                      X12_Month_CVC_Rolling_Sales__c, X12_Month_CVC_Rolling_Sales_eaches__c
                                      FROM Target_Profile__c];
        
        for(Target_Profile__c t:tp){
            if(t.RecordTypeId == HospitalRecTypeId){
                system.assertEquals(300000, t.X12_Month_Rolling_Sales__c);
                system.assertEquals(30, t.X12_Month_Rolling_Sales_eaches__c);
                //system.assertEquals(400000, t.X12_Month_CVC_Rolling_Sales__c);
                //system.assertEquals(40, t.X12_Month_CVC_Rolling_Sales_eaches__c);
            }
            else{
                system.assertEquals(300000, t.X12_Month_Rolling_Sales__c);
                system.assertEquals(30, t.X12_Month_Rolling_Sales_eaches__c);
            }
        }
        
    }
}