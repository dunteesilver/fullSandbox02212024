@isTest
public class ANZTargetProfileRollingSalesBatch_Test {
@testSetup
    static void createData() {
        Account acc = new Account();
        acc.Name = 'Testacc';
        insert acc;
        
        insert new ANZ_CVC_SKUs__c(Name='CA-11142-A');
        insert new ANZ_Needle_SKUs__c(Name='9001P-EU-005');
        insert new ANZ_YTD_SKUs__c(Name='1051-16-1');
        
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
            Material_Name__c = 'CA-11142-A',
            Sales__c = 100000,
            Quantity__c = 10
        );
        sales.add(is1);
        Invoiced_Sales__c is2 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '1051-16-1',
            Sales__c = 200000,
            Quantity__c = 20
        );
        sales.add(is2);
        Invoiced_Sales__c is3 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Surgical Disposables',
            Date__c = Date.Today() - 300,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9001P-EU-005',
            Sales__c = 400000,
            Quantity__c = 40
        );
        sales.add(is3);
        insert sales;
        
        List<ANZ_Target_Profiles__c> tps = new List<ANZ_Target_Profiles__c>();
        ANZ_Target_Profiles__c tp = new ANZ_Target_Profiles__c();
        //tp.RecordTypeId = PreHospitalRecTypeId;
        tp.Account_Name__c = acc.Id;
        tps.add(tp);
        
        ANZ_Target_Profiles__c tpH = new ANZ_Target_Profiles__c();
        //tpH.RecordTypeId = HospitalRecTypeId;
        tpH.Account_Name__c = acc.Id;
        tps.add(tpH);
        
        insert tps;
    }//end of createData
     //start testing updateRollingSales
    @isTest
    static void ANZTargetProfileRollingSalesBatch() {
        Test.startTest();
        ANZTargetProfileRollingSalesBatch b = new ANZTargetProfileRollingSalesBatch ();
        database.executebatch(b,75);
        
        String sch='0 0 0 ? * * *';
        String jobId = System.schedule('ANZTargetProfileRollingSalesBatch Schedule', sch , b);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        Test.stopTest();
        System.assertEquals(0, ct.TimesTriggered);
        
        
        List<ANZ_Target_Profiles__c> tp = [SELECT Id,Account_Name__c,X12M_CVC_Rolling_Sales_eaches__c,X12M_Needle_Rolling_Sales_eaches__c,
                                      X12M_Needle_Rolling_Sales__c,X12M_CVC_Rolling_Sales__c, YTD_Sales_all__c FROM ANZ_Target_Profiles__c];
        
       
         // for(ANZ_Target_Profiles__c t:tp)      
               
                //system.assertEquals(300000, t.X12M_Needle_Rolling_Sales__c);
                //system.assertEquals(30, t.X12M_Needle_Rolling_Sales_eaches__c);
               //system.assertEquals(400000, t.X12M_CVC_Rolling_Sales__c);
                //system.assertEquals(40, t.X12M_CVC_Rolling_Sales_eaches__c);
            
        
        
              }
}