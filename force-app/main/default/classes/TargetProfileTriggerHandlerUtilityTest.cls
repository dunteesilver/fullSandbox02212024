@isTest
public class TargetProfileTriggerHandlerUtilityTest {
    public static Id HospitalRecTypeId = Schema.getGlobalDescribe().get('Target_Profile__c').getDescribe().getRecordTypeInfosByName().get('Hospital').getRecordTypeId();
    public static Id PreHospitalRecTypeId = Schema.getGlobalDescribe().get('Target_Profile__c').getDescribe().getRecordTypeInfosByName().get('Pre-Hospital').getRecordTypeId();
    public static Id otherRecordTypeID = Schema.getGlobalDescribe().get('Target_Profile__c').getDescribe().getRecordTypeInfosByName().get('Other').getRecordTypeId();    
        
    @testSetup
    static void createData() {
        Account acc = new Account();
        acc.Name = 'TestaccHosp';
        insert acc;
        
        Account acc0 = new Account();
        acc0.Name = 'TestaccHosp';
        insert acc0;
        
        Account acc00 = new Account();
        acc00.Name = 'TestaccHosp';
        insert acc00;
        
        Account acc1 = new Account();
        acc1.Name = 'TestaccPreHosp';
        insert acc1;
        
        Account acc11 = new Account();
        acc11.Name = 'TestaccPreHosp';
        insert acc11;
        
        Account acc111 = new Account();
        acc111.Name = 'TestaccPreHosp';
        insert acc111;
        
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
        Invoiced_Sales__c is10 = new Invoiced_Sales__c(
            Account__c = acc0.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 100000,
            Quantity__c = 5
        );
        sales.add(is10);
        Invoiced_Sales__c is20 = new Invoiced_Sales__c(
            Account__c = acc0.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 200000,
            Quantity__c = 10
        );
        sales.add(is20);
        Invoiced_Sales__c is100 = new Invoiced_Sales__c(
            Account__c = acc00.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 100000,
            Quantity__c = 2
        );
        sales.add(is100);
        Invoiced_Sales__c is11 = new Invoiced_Sales__c(
            Account__c = acc1.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 100000,
            Quantity__c = 10
        );
        sales.add(is11);
        Invoiced_Sales__c is21 = new Invoiced_Sales__c(
            Account__c = acc1.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 200000,
            Quantity__c = 20
        );
        sales.add(is21);
        Invoiced_Sales__c is31 = new Invoiced_Sales__c(
            Account__c = acc1.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = 'AK-47702-CDC',
            Sales__c = 400000,
            Quantity__c = 40
        );
        sales.add(is31);
        Invoiced_Sales__c is111 = new Invoiced_Sales__c(
            Account__c = acc11.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 100000,
            Quantity__c = 5
        );
        sales.add(is111);
        Invoiced_Sales__c is211 = new Invoiced_Sales__c(
            Account__c = acc11.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 200000,
            Quantity__c = 10
        );
        sales.add(is211);
        Invoiced_Sales__c is1111 = new Invoiced_Sales__c(
            Account__c = acc111.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 100000,
            Quantity__c = 2
        );
        sales.add(is1111);
        insert sales;
        
        List<Target_Profile__c> tps = new List<Target_Profile__c>();
        Target_Profile__c tp = new Target_Profile__c();
        tp.RecordTypeId = PreHospitalRecTypeId;
        tp.Account__c = acc.Id;
        tp.X911_Calls_actual__c = 900;
        tp.X12_Month_Rolling_Sales_eaches__c = 700;
        tp.Actual_IO_Potential_Number__c  = 7;
        tp.Actual_IO_Potential_Number__c  = 241;
        tps.add(tp);
        
        Target_Profile__c tp1 = new Target_Profile__c();
        tp1.RecordTypeId = PreHospitalRecTypeId;
        tp1.Account__c = acc.Id;
        tp1.X911_Calls_actual__c = 900;
        tp1.X12_Month_Rolling_Sales_eaches__c = 700;
        tp1.Actual_IO_Potential_Number__c  = 7;
        tp1.Actual_IO_Potential_Number__c  = 141;
        tps.add(tp1);
        
        Target_Profile__c tp2 = new Target_Profile__c();
        tp2.RecordTypeId = PreHospitalRecTypeId;
        tp2.Account__c = acc.Id;
        tp2.X911_Calls_actual__c = 900;
        tp2.X12_Month_Rolling_Sales_eaches__c = 700;
        tp2.Actual_IO_Potential_Number__c  = 7;
        tp2.Actual_IO_Potential_Number__c  = 60;
        tps.add(tp2);
        
        Target_Profile__c tp3 = new Target_Profile__c();
        tp3.RecordTypeId = PreHospitalRecTypeId;
        tp3.Account__c = acc.Id;
        tp3.X911_Calls_actual__c = 900;
        tp3.X12_Month_Rolling_Sales_eaches__c = 700;
        tp3.Actual_IO_Potential_Number__c  = 7;
        tp3.Actual_IO_Potential_Number__c  = 50;
        tps.add(tp3);
        
        Target_Profile__c tpH = new Target_Profile__c();
        tpH.RecordTypeId = HospitalRecTypeId;
        tpH.Account__c = acc1.Id;
        tpH.X911_Calls_actual__c = 900;
        tpH.X12_Month_Rolling_Sales_eaches__c = 700;
        tpH.Cardiac_Arrest_Calls_actual__c    = 7;
        tpH.Adult_Trauma_Center_Level__c = '4';
        tpH.Pediatric_Trauma_Center_Level__c = '4';
        tpH.Last_Year_Eaches_CVC__c = 250;
        tpH.Actual_IO_Potential_Number__c  = 250;
        tps.add(tpH);
        
        Target_Profile__c tpH1 = new Target_Profile__c();
        tpH1.RecordTypeId = HospitalRecTypeId;
        tpH1.Account__c = acc1.Id;
        tpH1.X911_Calls_actual__c = 900;
        tpH1.X12_Month_Rolling_Sales_eaches__c = 700;
        tpH1.Cardiac_Arrest_Calls_actual__c    = 7;
        tpH1.Adult_Trauma_Center_Level__c = '4';
        tpH1.Pediatric_Trauma_Center_Level__c = '4';
        tpH1.Last_Year_Eaches_CVC__c = 180;
        tps.add(tpH1);

        Target_Profile__c tpH2 = new Target_Profile__c();
        tpH2.RecordTypeId = HospitalRecTypeId;
        tpH2.Account__c = acc1.Id;
        tpH2.X911_Calls_actual__c = 900;
        tpH2.X12_Month_Rolling_Sales_eaches__c = 700;
        tpH2.Cardiac_Arrest_Calls_actual__c    = 7;
        tpH2.Adult_Trauma_Center_Level__c = '4';
        tpH2.Pediatric_Trauma_Center_Level__c = '4';
        tpH2.Last_Year_Eaches_CVC__c = 120;
        tps.add(tpH2);

        Target_Profile__c tpH3 = new Target_Profile__c();
        tpH3.RecordTypeId = HospitalRecTypeId;
        tpH3.Account__c = acc1.Id;
        tpH3.X911_Calls_actual__c = 900;
        tpH3.X12_Month_Rolling_Sales_eaches__c = 700;
        tpH3.Cardiac_Arrest_Calls_actual__c    = 7;
        tpH3.Adult_Trauma_Center_Level__c = '4';
        tpH3.Pediatric_Trauma_Center_Level__c = '4';
        tpH3.Last_Year_Eaches_CVC__c = 80;
        tps.add(tpH3);
        
        Target_Profile__c tpH4 = new Target_Profile__c();
        tpH4.RecordTypeId = otherRecordTypeID;
        tpH4.Account__c = acc1.Id;
        tpH4.X911_Calls_actual__c = 900;
        tpH4.X12_Month_Rolling_Sales_eaches__c = 700;
        tpH4.Cardiac_Arrest_Calls_actual__c    = 7;
        tpH4.Adult_Trauma_Center_Level__c = '4';
        tpH4.Pediatric_Trauma_Center_Level__c = '4';
        tpH4.Last_Year_Eaches_CVC__c = 30;
        tps.add(tpH4);
        
        insert tps;
    }
    //start testing updateRollingSales
    @isTest
    static void test_updateRollingSales() {
    }
    
}