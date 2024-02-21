@IsTest
public class InvoicedSalesAccountShareBatchTest {
    
    @testSetup
    static void createData() {
        Territory_Master__c tm = new Territory_Master__c(
            Name = '800123',
            Territory_Number__c = '800123',
            Business_Unit__c = 'EMS',
            Role__c = 'Sales Rep'
        );
        insert tm;
        System.debug('Insert Territory Master-->' + tm);
        
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
            username='unit.test@unit.teleflex.com'
        );
        insert u;
        
        Territory_User__c tu = new Territory_User__c(
            Territory_Master__c = tm.Id,
            User__c = u.id
        );
        insert tu;
        System.debug('Insert Territory User-->' + tu);
        
        Territory_Alignment__c tarsap = new Territory_Alignment__c(
            Key__c	= '999999-800123',
            SAP_Code__c	= '999999',
            Account_Name__c	= 'Test',
            Territory__c = '800123',
            Territory_Name__c = '800123',
            Territory2__c = '800123',
            Territory_2_Name__c = '800123',
            Territory3__c = '',
            Territory_3_Name__c = '',
            Territory4__c = '',
            Territory_4_Name__c = '',
            ZPSA_Table__c = 'A681',
            Filter_Key__c = '999999-A681',
            Active__c = TRUE,
            Territory_Master__c = tm.Id,
            Business_Unit__c = 'EMS'
        );
        insert tarsap;
        
        Territory_Alignment__c tarstate = new Territory_Alignment__c(
            Key__c	= 'NC-800123',
            Region__c = 'NC',
            Territory__c = '800123',
            Territory_Name__c = '800123',
            Territory2__c = '800124',
            Territory_2_Name__c = '800124',
            Territory3__c = '',
            Territory_3_Name__c = '',
            Territory4__c = '',
            Territory_4_Name__c = '',
            ZPSA_Table__c = 'A659',
            Filter_Key__c = 'NC-A659',
            Active__c = TRUE,
            Territory_Master__c = tm.Id,
            Business_Unit__c = 'EMS'
        );
        insert tarstate;
        
        Territory_Alignment__c tarzip = new Territory_Alignment__c(
            Key__c	= '27614-800123',
            Zip10__c = '27614',
            Territory__c = '800123',
            Territory_Name__c = '800123',
            Territory2__c = '800125',
            Territory_2_Name__c = '800125',
            Territory3__c = '',
            Territory_3_Name__c = '',
            Territory4__c = '',
            Territory_4_Name__c = '',
            ZPSA_Table__c = 'A626',
            Filter_Key__c = '27614-A626',
            Active__c = TRUE,
            Territory_Master__c = tm.Id,
            Business_Unit__c = 'EMS'
        );
        insert tarzip;
        
        Territory_Alignment__c tarbc = new Territory_Alignment__c(
            Key__c = '276-02-800123',
            Zip3__c = '276',
            Customer_Group__c = '02',
            Customer_Group_Name__c = 'Dist/Dlr Emg Med Svc',
            Territory__c = '800123',
            Territory_Name__c = '800123',
            Territory2__c = '800126',
            Territory_2_Name__c = '800126',
            Territory3__c = '',
            Territory_3_Name__c = '',
            Territory4__c = '',
            Territory_4_Name__c = '',
            ZPSA_Table__c = 'A672',
            Filter_Key__c = '27602-A672',
            Active__c = TRUE,
            Territory_Master__c = tm.Id,
            Business_Unit__c = 'EMS'
        );
        insert tarbc;
        
        master_TriggerHelperClass.runOnce('resetOnceSet');
        Account acc = new account(
            Name = 'Test',
            SAP_Sold_To__c = '999999',
            BillingState = 'NC',
            BillingPostalCode = '27614',
            BillingCountry = 'US',
            Customer_Group__c = '02',
            Territory_Key__c = '800123'
        );
        insert acc;
        
        tm.Sales_Rep__c  = u.id;
        tm.Sales_Rep_Email__c ='unit.test@unit.teleflex.com';
        
        
        update tm;        
        
        
        
        
        
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
            Product__c = products[0].ID,
            Territory__c = tm.Id
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
        
        
        
    }
    
    
    
    
    @IsTest 
    static void InvoicedSalesAccountShareBatch (){
        Test.startTest();
        InvoicedSalesAccountShareBatch b = new  InvoicedSalesAccountShareBatch ();
        database.executebatch(b,200);
        String sch='0 0 0 ? * * *';
        String jobId = System.schedule('InvoicedSalesAccountShareBatch', sch , b);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        List<Invoiced_Sales__c> InvSal = [SELECT Id,Account__c,territory__c from Invoiced_Sales__c];
        system.assertEquals(16, InvSal.size());
        
    }
    
    
    
}