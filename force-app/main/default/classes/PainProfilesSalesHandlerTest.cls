@istest public class PainProfilesSalesHandlerTest {
    @testsetup
    static void createTestData(){
        
        Account acc = new Account();
        acc.Name = 'Testacc';
        insert acc;
        
        List<Product2> products = new List<Product2>();
        products.add(new Product2(
            Name = 'ASK-05560-TG1',
            ProductCode= 'ASK-05560-TG1',
            Group__c = 'Regional Anesthesia',
            Product_Class__c = '0014 ',
            Product_Group__c = '00140004 ',
            Product_Sub_Group__c = '001400040003 ',
            Product_Line__c = '001400040003000001 '
        ));
        products.add(new Product2(
            Name = 'MT2060L-CPNB',
            ProductCode= 'MT2060L-CPNB',
            Group__c = 'LMA Pain Management',
            Product_Class__c = '0014',
            Product_Group__c = '00140012',
            Product_Sub_Group__c = '001400120001',
            Product_Line__c = '001400120001000001'
        ));
        products.add(new Product2(
            Name = '100382020',
            ProductCode= '100382020',
            Group__c = 'Airway',
            Product_Class__c = '0014',
            Product_Group__c = '00140002',
            Product_Sub_Group__c = '001400020005',
            Product_Line__c = '001400020005000004'
        ));
        products.add(new Product2(
            Name = 'MAD301',
            ProductCode= 'MAD301',
            Group__c = 'LMA Atomization',
            Product_Class__c = '0014',
            Product_Group__c = '00140006',
            Product_Sub_Group__c = '001400060001',
            Product_Line__c = '001400060001000010'
        ));
        insert products;
        
        BaseQuotaException__c bqe = new BaseQuotaException__c(
            Name = 'territory_user_maintenance',
            IsException__c = TRUE
        );
        insert bqe;
        
        List<Invoiced_Sales__c> sales = new List<Invoiced_Sales__c>();
        Invoiced_Sales__c is1 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today() - 30,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 100000,
            Quantity__c = 10,
            Product__c = products[0].ID
        );
        sales.add(is1);
        
        Invoiced_Sales__c is2 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today() - 30,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 200000,
            Quantity__c = 20,
            Product__c = products[1].ID
        );
        sales.add(is2);
        
        Invoiced_Sales__c is3 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today() - 30,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = 'AK-47702-CDC',
            Sales__c = 400000,
            Quantity__c = 40,
            Product__c = products[2].ID
        );
        sales.add(is3);
        
        Invoiced_Sales__c is4 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today() - 30,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079-VC-005',
            Sales__c = 825.0,
            Quantity__c = 5.0,
            Product__c = products[3].ID 
        );
        sales.add(is4);
        
        Invoiced_Sales__c is5 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today().addYears(-1),
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 100000,
            Quantity__c = 10,
            Product__c = products[0].ID
        );
        sales.add(is5);
        
        Invoiced_Sales__c is6 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today().addYears(-1),
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 200000,
            Quantity__c = 20,
            Product__c = products[1].ID
        );
        sales.add(is6);
        
        Invoiced_Sales__c is7 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today().addYears(-1),
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = 'AK-47702-CDC',
            Sales__c = 400000,
            Quantity__c = 40,
            Product__c = products[2].ID
        );
        sales.add(is7);
        
        Invoiced_Sales__c is8 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today().addYears(-1),
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079-VC-005',
            Sales__c = 825.0,
            Quantity__c = 5.0,
            Product__c = products[3].ID 
        );
        sales.add(is8);
        
        Invoiced_Sales__c is11 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today() - 30,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 100000,
            Quantity__c = 10,
            Compensation_Profile__c ='Anesthesia Canada',
            Product__c = products[0].ID
        );
        sales.add(is11);
        
        Invoiced_Sales__c is12 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today() - 30,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 200000,
            Quantity__c = 20,
            Compensation_Profile__c ='Anesthesia Canada',
            Product__c = products[1].ID
        );
        sales.add(is12);
        
        Invoiced_Sales__c is13 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today() - 30,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = 'AK-47702-CDC',
            Sales__c = 400000,
            Quantity__c = 40,
            Compensation_Profile__c ='Anesthesia Canada',
            Product__c = products[2].ID
        );
        sales.add(is13);
        
        Invoiced_Sales__c is14 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today() - 30,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079-VC-005',
            Sales__c = 825.0,
            Quantity__c = 5.0,
            Compensation_Profile__c ='Anesthesia Canada',
            Product__c = products[3].ID 
        );
        sales.add(is14);
        
        Invoiced_Sales__c is15 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today().addYears(-1),
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 100000,
            Quantity__c = 10,
            Compensation_Profile__c ='Anesthesia Canada',
            Product__c = products[0].ID
        );
        sales.add(is15);
        
        Invoiced_Sales__c is16 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today().addYears(-1),
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 200000,
            Quantity__c = 20,
            Compensation_Profile__c ='Anesthesia Canada',
            Product__c = products[1].ID
        );
        sales.add(is16);
        
        Invoiced_Sales__c is17 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today().addYears(-1),
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = 'AK-47702-CDC', 
            Sales__c = 400000,
            Quantity__c = 40,
            Compensation_Profile__c ='Anesthesia Canada',
            Product__c = products[2].ID
        );
        sales.add(is17);
        
        Invoiced_Sales__c is18 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today().addYears(-1),
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079-VC-005',
            Sales__c = 825.0,
            Quantity__c = 5.0,
            Compensation_Profile__c ='Anesthesia Canada',
            Product__c = products[3].ID 
        );
        sales.add(is18);
        insert sales;
    }//end of createData
    
    @isTest static void tstinsalfrmtrg() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account];
        List<Pain_Profile__c> painProfs = new List<Pain_Profile__c>();        
        painProfs.add(new Pain_Profile__c(Account__c = acc.Id));       
        insert painProfs;        
        Test.stopTest();
    }
}