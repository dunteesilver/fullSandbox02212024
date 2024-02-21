@isTest 
public class Invoiced_Sales_Detail_Global_Test_Cls {
  @testSetup static void dataSetup(){  
      date salesDate = Date.today();
      date salesDateLY = salesDate.addYears(-1);
      list<Account> alist = new list<Account>();

      BaseQuotaException__c bqe = new BaseQuotaException__c(
            Name = 'territory_user_maintenance',
            IsException__c = TRUE
        );
        insert bqe;
      
            Account a = new Account(
                Name = 'Test PP Account', 
                SAP_Sold_To__c ='100123', 
                ShippingStreet='123 Main Street ', 
                ShippingCity='Raleigh',
                ShippingState='NC', 
                ShippingPostalCode='27614',
                Customer_Group__c = '19',
                zBlock__c = '00',
                Account_Group__c = 'Z001',
                ERP_Active__c = FALSE
            );
            master_TriggerHelperClass.runOnce('resetOnceSet');
            alist.add(a);
            //insert a;
            
            Account a2 = new Account(
                Name = 'Test PP Account2', 
                SAP_Sold_To__c ='100555', 
                ShippingStreet='1234 Main Street ', 
                ShippingCity='Raleigh',
                ShippingState='NC', 
                ShippingPostalCode='27613',
                Customer_Group__c = '19',
                Sales_by_BU_Key__c = '123',
                zBlock__c = '01',
                Account_Group__c = 'Z002',
                ERP_Active__c = TRUE
                
            );
            master_TriggerHelperClass.runOnce('resetOnceSet');
            alist.add(a2);
            insert alist;
      
      List<Territory_Master__c> tmList = new List<Territory_Master__c>();
            Territory_Master__c tm = new Territory_Master__c(
                Name = '700123',
                Territory_Number__c = '700123',
                Business_Unit__c = 'Surgical Disposables',
                Compensation_Profile__c = 'Surgical Disposables',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com',
                Manager_Email__c = 'unit.test.manager@unit.teleflex.com',
                Primary_Territory_User_Email__c = 'unit.test@unit.teleflex.com',
                Sharing_Key__c = 'Adam Franks'
                
            );
            tmList.add(tm);
            System.debug('Insert Territory Master-->' + tm);
            
            Territory_Master__c tm2 = new Territory_Master__c(
                Name = '700124',
                Territory_Number__c = '700124',
                Business_Unit__c = 'Vascular',
                Compensation_Profile__c = 'Vascular',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com',
                Manager_Email__c = 'unit.test.manager@unit.teleflex.com',
                Primary_Territory_User_Email__c = 'unit.test@unit.teleflex.com',
                Role__c = 'KAM',
                Sharing_Key__c = 'Adam Franks'
                
            );
            tmList.add(tm2);

            Territory_Master__c tm3 = new Territory_Master__c(
                Name = '700125',
                Territory_Number__c = '700125',
                Business_Unit__c = 'Vascular',
                Compensation_Profile__c = 'Vascular',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com',
                Manager_Email__c = 'unit.test.manager@unit.teleflex.com',
                Primary_Territory_User_Email__c = 'unit.test@unit.teleflex.com',
                Sharing_Key__c = 'Adam Franks'
            );
            tmList.add(tm3);
             
            Territory_Master__c tm4 = new Territory_Master__c(
                Name = '800205',
                Territory_Number__c = '800205',
                Business_Unit__c = 'Vascular',
                Compensation_Profile__c = 'Vascular',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com',
                Manager_Email__c = 'unit.test.manager@unit.teleflex.com',
                Primary_Territory_User_Email__c = 'unit.test@unit.teleflex.com',
                Role__c = 'KAM',
                Sharing_Key__c = 'Adam Franks'
                
            );
            tmList.add(tm4);
            
            Territory_Master__c tm5 = new Territory_Master__c(
                Name = '800321',
                Territory_Number__c = '800321',
                Business_Unit__c = 'Vascular',
                Compensation_Profile__c = 'Vascular',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com',
                Manager_Email__c = 'unit.test.manager@unit.teleflex.com',
                Primary_Territory_User_Email__c = 'unit.test@unit.teleflex.com',
                Role__c = 'ASR'                
            );
            tmList.add(tm5);
            insert tmList;
      
      list<Product2> plist = new list<Product2>();
            
            Product2 prod = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='30', 
                Family = 'Hardware',
                Material__c='AA-10511-1',
                Brand_Name__c='Arrow',
                Buom__c='EA',
                Cost__c=11587.40,
                Cost_Price_Unit__c=1000,
                Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Qty_Sales_Unit__c=5,
                Sales_Unit__c='CS',
                List_Price__c=380.00,
                Rep_Price__c=350.00,
                RSM_Price__c=330.00,
                Material_Key__c = 'AA-10511-1-US30-10',
                Sales_Org_Key__c = 'US103010',
                Sales_Org__c = 'US30',
                Distribution_Channel__c = '10',
                Product_Class__c = '0033',
                Product_Group__c = '00270003',
                Product_Sub_Group__c = '000700010001',
                Product_Line__c = '000700010002000003',
                Class__c = 'Cardiac Care Specialty',
                Group__c  = 'Interventional Access',
                SubGroup__c = 'TransRadial Access',
                Product_Line_Text__c = 'TransRadial Access',
                VPS_Consumable__c = TRUE,
                Valuated_Unrestricted_Use_Stock__c = 10,
                Average_Weekly_Demand__c = 1,
                Surgical_Disposables__c = 'Core'

            );
            plist.add(prod);
            //insert prod;
            
            Product2 prod2 = new Product2(
                Name = 'AA-10511-11',
                Material_Key__c = 'AA-10511-11-US30-11',
                Sales_Org_Key__c = 'US103010',
                Sales_Org__c = 'US30',
                Distribution_Channel__c = '10',
                Product_Class__c = '1',
                Product_Group__c = '2',
                Product_Sub_Group__c = '3',
                Product_Line__c = '4',
                Valuated_Unrestricted_Use_Stock__c = 300,
                Average_Weekly_Demand__c = 3,
                Surgical_Disposables__c = 'Core'
                
            );
            plist.add(prod2);
            //insert prod3;
            
            Product2 prod3 = new Product2(
                Name = 'AA-10511-12',
                Material_Key__c = 'AA-10511-12-US30-12',
                Sales_Org_Key__c = 'US103010',
                Sales_Org__c = 'US30',
                Distribution_Channel__c = '10',
                Product_Class__c = '1',
                Product_Group__c = '2',
                Product_Sub_Group__c = '3',
                Product_Line__c = '4',
                Valuated_Unrestricted_Use_Stock__c = 200,
                Average_Weekly_Demand__c = 2,
                Surgical_Disposables__c = 'Core'
                
            );
            plist.add(prod3);
            //insert prod3;
            
            Product2 prod4 = new Product2(
                Name = 'AA-10511-13',
                Material_Key__c = 'AA-10511-13-US30-13',
                Sales_Org_Key__c = 'US103010',
                Sales_Org__c = 'US30',
                Distribution_Channel__c = '10',
                Product_Class__c = '1',
                Product_Group__c = '2',
                Product_Sub_Group__c = '3',
                Product_Line__c = '4',
                Valuated_Unrestricted_Use_Stock__c = 100,
                Average_Weekly_Demand__c = 3,
                Surgical_Disposables__c = 'Not Applicable'
            );
            plist.add(prod4);
            //insert prod4;
            
            insert plist;
      
    Contract_Header__c chTest = new Contract_Header__c(
                Name = '50009064',
                Agreement_Number__c = '50009064',
                Description__c = 'Test Description',
                Owner__c = '123310',
                GPO_Contract_Ref__c = '',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 45
            );
            insert chTest;  
      
    list<Invoiced_Sales_Detail__c> isdList = new list<Invoiced_Sales_Detail__c>();
            Invoiced_Sales_Detail__c isd_cmr = new Invoiced_Sales_Detail__c(
                Account__c = a2.Id,
                Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1a',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Sales_Deal__c = chTest.Name,
                Sales_Org__c = 'US10',
                Sales__c = 321.00,
                Sales_Order_Key__c='111-10-AAA',
                Date__c = salesDateLY,
                SAP_Code__c = '10170226',
                Parent_Account_Key__c = '10170226',
                Territory_Number__c = '700123',
                Commissionable_Date__c = salesDate,
                Order_Number__c = '3139447',
                Line_Item_Number__c = 10,
                Maintenance_Key__c = '123',
                Invoice_Order_Number__c = 'AAA',
                Sales_Order_Number__c = '111'
            );
            isdList.add(isd_cmr);
            Invoiced_Sales_Detail__c isd1 = new Invoiced_Sales_Detail__c(
                Account__c = a2.Id,
                Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1123421',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Product__c = prod.Id,
                Sales_Deal__c = chTest.Name,
                Sales_Org__c = 'US10',
                Sales__c = 321.00,
                Sales_Order_Key__c='111-10-AAA',
                Date__c = salesDateLY,
                SAP_Code__c = '100123',
                Territory__c = tm.Id,
                Territory_Number__c = '700123',
                Commissionable_Date__c = salesDate,
                Order_Number__c = '3139447',
                Line_Item_Number__c = 10,
                Maintenance_Key__c = '234',
                Invoice_Order_Number__c = 'BBB',
                Sales_Order_Number__c = '222'
            );
            isdList.add(isd1);
            Invoiced_Sales_Detail__c isd2 = new Invoiced_Sales_Detail__c(
                Account__c = a.Id,
                Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '10',
                Key__c = '100123-AA-10511-1122212111',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Product__c = prod.Id,
                Sales_Deal__c = chTest.Name,
                Sales_Org__c = 'US10',
                Sales__c = 321.00,
                Date__c = Date.today(),
                SAP_Code__c = '100123',
                Territory__c = tm.Id,
                Territory_Number__c = '700123',
                Commissionable_Date__c = Date.today(),
                Order_Number__c = '3139446',
                Line_Item_Number__c = 10,
                Maintenance_Key__c = '123'

            );
            isdList.add(isd2);
            insert isdList;
        //inserting custom setting for Invoiced Sales Tracking Class
        Invoiced_Sales_Tracking_Class_CS__c  customSettingIstClass =new Invoiced_Sales_Tracking_Class_CS__c();
        customSettingIstClass.Execute__c=true;
        customSettingIstClass.Name='addShipping';
        insert customSettingIstClass;
      
      //inserting Invoice Sales Tracking related to Invoiced Detail
      list<Invoiced_Sales_Tracking__c> invSalesTrackList=new list<Invoiced_Sales_Tracking__c>();
     Invoiced_Sales_Tracking__c invSalesTrack1= new Invoiced_Sales_Tracking__c(
         Key__c=isd_cmr.Id,
      Sales_Order_Key__c='111-10-AAA',
      Tracking_Number__c='1Z6069230376727116',
      Delivery_Priority__c='UPS');
      invSalesTrackList.add(invSalesTrack1);
       insert invSalesTrackList;
      
      //Inserting Invoiced Sales
       List<Invoiced_Sales__c> listSObject=new List<Invoiced_Sales__c>();
       Invoiced_Sales__c invSales1 = new Invoiced_Sales__c(
                Distribution_Channel__c = '10',
                Material_Name__c = '5571',
                Material_Key__c = '5571-US60-10',
                Sales_Org__c = 'US60',
                Date__c =date.today() ,
                CurrencyIsoCode = 'USD',
                 Product_Class__c = '0030',
                Product_Group__c = '00300011',
                Product_Sub_Group__c = '003000110002',
                Product_Line__c = '003000110002000001'
            );
        
        listSObject.add(invSales1);
        insert listSObject;
  
   
  }
      
    
    @isTest static void testScheduleClasses2() {
        Test.startTest();
        date salesDate = Date.today();
        date salesDateLY = salesDate.addYears(-1);
        salesDate = salesDate.addMonths(-2);
        List<Account> acc = [SELECT Id FROM Account WHERE Name = 'Test PP Account'];
        List<Product2> prod = [SELECT Id FROM Product2 WHERE Name IN ('AA-10511-1', 'AA-10511-13') ];
        list<Open_Orders__c> oList = new list<Open_Orders__c>();
            Open_Orders__c openOrder = new Open_Orders__c(
                Account__c = acc[0].Id,
                Territory_Number__c = '700123',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Order_Number__c = '3139447',
                Line_Item_Number__c = '10',
                Product__c = prod[0].Id,
                Product_Class__c = '0033',
                Order_Date__c = salesDate,
                Scheduled_Ship_Date__c = salesDate,
                Maintenance_Key__c = '123',
                PO_Number__c = 'abc123',
                Open_Order_Qty__c = 3,
                Open_Order_Total__c = 123
            );
            oList.add(openOrder);
            
            Open_Orders__c openOrder2 = new Open_Orders__c(
                Account__c = acc[0].Id,
                Territory_Number__c = '700123',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Order_Number__c = '3139446',
                Line_Item_Number__c = '10',
                Product__c = prod[0].Id,
                Product_Class__c = '0033',
                Order_Date__c = salesDate,
                SAP_Code__c = '10170226',
                Parent_Account_Key__c = '10170226',
                Scheduled_Ship_Date__c = salesDate,
                Maintenance_Key__c = '234',
                PO_Number__c = 'abc123',
                Open_Order_Qty__c = 3,
                Open_Order_Total__c = 123
            );
            oList.add(openOrder2);
            
            Open_Orders__c openOrder3 = new Open_Orders__c(
                Account__c = acc[0].Id,
                Territory_Number__c = '700125',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Order_Number__c = '3139446',
                Line_Item_Number__c = '10',
                Product__c = prod[0].Id,
                Product_Class__c = '0033',
                Order_Date__c = salesDate,
                SAP_Code__c = '10170226',
                Parent_Account_Key__c = '10170226',
                Scheduled_Ship_Date__c = salesDate,
                Maintenance_Key__c = '123',
                Back_Ordered__c = TRUE,
                PO_Number__c = 'abc123',
                Open_Order_Qty__c = 3,
                Open_Order_Total__c = 123
            );
            oList.add(openOrder3);
            
            Open_Orders__c openOrder4 = new Open_Orders__c(
                Account__c = acc[0].Id,
                Territory_Number__c = '700125',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Order_Number__c = '3139446',
                Line_Item_Number__c = '10',
                Product__c = prod[0].Id,
                Product_Class__c = '0033',
                Order_Date__c = salesDate,
                SAP_Code__c = '10170226',
                Parent_Account_Key__c = '10170226',
                Scheduled_Ship_Date__c = salesDate,
                Maintenance_Key__c = '123',
                Back_Ordered__c = TRUE,
                PO_Number__c = 'abc123',
                Open_Order_Qty__c = 3,
                Open_Order_Total__c = 123,
                Manual_Sub_Values__c = true,
                Sub_1__c = prod[1].Id
            );
            oList.add(openOrder4);
           insert oList;
        //String CRON_EXP = '0 0 0 15 3 ? 2022';
        //String jobId;
        
        //jobId = System.schedule('Open_Orders_Maintenance_Scheduler', CRON_EXP, new Open_Orders_Maintenance_Scheduler());
        //jobId = System.schedule('Invoiced_Sales_Detail_Maintenance_Sch', CRON_EXP, new Invoiced_Sales_Detail_Maintenance_Sch());
        //jobId = System.schedule('Open_Orders_Maintenance_Scheduler', CRON_EXP, new Open_Orders_Maintenance_Scheduler());
        /*
        Build_Product_Sales_Batch bpsb = new Build_Product_Sales_Batch();
        Database.executeBatch(bpsb);*/
        
        Territory_Master__c tm = new Territory_Master__c(
                Name = '701123',
                Territory_Number__c = '701123',
                Business_Unit__c = 'Surgical Disposables',
                Compensation_Profile__c = 'Surgical Disposables',
                Sales_Rep_Email__c = 'unit.test@unit.teleflex.com',
                Manager_Email__c = 'unit.test.manager@unit.teleflex.com',
                Primary_Territory_User_Email__c = 'unit.test@unit.teleflex.com',
                Sharing_Key__c = 'Adam Franks'
                
            );
        insert tm;
        
        Contract_Header__c chTest = new Contract_Header__c(
                Name = '50009065',
                Agreement_Number__c = '50009065',
                Description__c = 'Test Desc',
                Owner__c = '123300',
                GPO_Contract_Ref__c = '',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 45
            );
            insert chTest;  
            
        list<Invoiced_Sales_Detail__c> isdList = new list<Invoiced_Sales_Detail__c>();
        Invoiced_Sales_Detail__c isd1 = new Invoiced_Sales_Detail__c(
                Account__c = acc[0].Id,
                Business_Unit__c = 'Surgical Disposables',
                Distribution_Channel__c = '60',
                Key__c = '100123-AA-10511-1123422',
                Material_Name__c = 'AA-10511-2',
                Material_Key__c = 'AA-10511-1-US60-60',
                Product__c = prod[0].Id,
                Sales_Deal__c = chTest.Name,
                Sales_Org__c = 'US60',
                Sales__c = 420.00,
                Date__c = salesDateLY,
                SAP_Code__c = '100124',
                Territory__c = tm.Id,
                Territory_Number__c = '701123',
                Commissionable_Date__c = salesDate,
                Order_Number__c = '3139448',
                Line_Item_Number__c = 10,
                Maintenance_Key__c = '345',
                Invoice_Order_Number__c = 'TEST',
                Sales_Order_Number__c = '111'
            );
            isdList.add(isd1);
        Invoiced_Sales_Detail__c isd2 = new Invoiced_Sales_Detail__c(
                Account__c = acc[0].Id,
                Business_Unit__c = 'Surgical',
                Distribution_Channel__c = '20',
                Key__c = '100123-AA-10511-1123423',
                Material_Name__c = 'AA-10511-3',
                Material_Key__c = 'AA-10511-1-US20-20',
                Product__c = prod[1].Id,
                Sales_Deal__c = chTest.Name,
                Sales_Org__c = 'US20',
                Sales__c = 520.00,
                Date__c = salesDateLY,
                SAP_Code__c = '100125',
                Territory__c = tm.Id,
                Territory_Number__c = '701124',
                Commissionable_Date__c = salesDate,
                Order_Number__c = '3139450',
                Line_Item_Number__c = 10,
                Maintenance_Key__c = '567',
                Invoice_Order_Number__c = 'TEST1',
                Sales_Order_Number__c = '000'
            );
		isdList.add(isd2);
        insert isdList;
        
        Open_Orders_Maintenance_Batch oomb = new Open_Orders_Maintenance_Batch();
        oomb.chainMaintenance = FALSE;
        Database.executeBatch(oomb);
        
        Invoiced_Sales_Detail_Maintenance_Batch isdm = new Invoiced_Sales_Detail_Maintenance_Batch();
        isdm.chainMaintenance = FALSE;
        Database.executeBatch(isdm);
        
        Test.stopTest();
    }
    
    //add test to test addShipping method
	@isTest static void testInvoicedSalesHelperClass() {
        Test.startTest();
        List<Invoiced_Sales_Detail__c> isdList = [SELECT Id, Account__c,Business_Unit__c, Distribution_Channel__c, Key__c,
                                                  Material_Name__c, Material_Key__c, Product__c, Sales_Deal__c, Sales_Org__c, 
                                                  Sales__c, Date__c, SAP_Code__c, Territory__c, Territory_Number__c, Sales_Order_Key__c,
                                                  Commissionable_Date__c, Order_Number__c, Line_Item_Number__c, Maintenance_Key__c
                                                  FROM Invoiced_Sales_Detail__c 
                                                  ];
       
                
        Invoiced_Sales_Helper_Class isdHelper = new Invoiced_Sales_Helper_Class();
        string mKey = isdHelper.getMaintenanceKey('Invoiced_Sales_Detail__c');
        Invoiced_Sales_Helper_Class.randomKey();
             
                
        Test.stopTest();
    }  
    
    @isTest static void testAddShipping(){
        
        Test.startTest();
             
        
       List<Invoiced_Sales_Detail__c> invSalesDetList = [SELECT Id, Account__c,Business_Unit__c, Distribution_Channel__c, Key__c,
                                                  Material_Name__c, Material_Key__c, Product__c, Sales_Deal__c, Sales_Org__c, 
                                                  Sales__c, Date__c, Territory_Number__c, Sales_Order_Key__c
                                                  FROM Invoiced_Sales_Detail__c WHERE Sales_Order_Key__c='111-10-AAA'
                                                  ];
            
        System.debug('size of the list '+invSalesDetList.size());
        System.debug('***Printing isdlist*** queried Invoice detail '+invSalesDetList);
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
       List<Invoiced_Sales_Tracking__c> trackingUPS=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
        //Fedex scenario
        List<Invoiced_Sales_Tracking__c> updateToFedex=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackFed:trackingUPS){
            if(trackFed.Delivery_Priority__c!=NULL){
               trackFed.Delivery_Priority__c='Fed';
            }
           updateToFedex.add(trackFed);
        }
        update updateToFedex;
         
       
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Fedex tracking records*** '+updateToFedex);
       
        //Purolator scenario
        List<Invoiced_Sales_Tracking__c> trackingPur=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
        List<Invoiced_Sales_Tracking__c> updateToPur=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackPur:trackingPur){
            if(trackPur.Delivery_Priority__c!=NULL){
                trackPur.Delivery_Priority__c='Pur';
            }
            updateToPur.add(trackPur);
        }
        update updateToPur;
        
      
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Puralator tracking records*** '+updateToPur);
       
        //YRC Freight scenario
        List<Invoiced_Sales_Tracking__c> trackingYRC=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
        List<Invoiced_Sales_Tracking__c> updateToYRC=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackYRC:trackingYRC){
            if(trackYRC.Delivery_Priority__c!=NULL){
                trackYRC.Delivery_Priority__c='YRC';
            }
            updateToYRC.add(trackYRC);
        }
        update updateToYRC;
        
       Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
       System.debug('***Printing YRC Freight tracking records*** '+updateToYRC);

       
        
        //AAA Cooper
          List<Invoiced_Sales_Tracking__c> trackingAAA=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
        List<Invoiced_Sales_Tracking__c> updateToAAA=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackAAA:trackingAAA){
            if(trackAAA.Delivery_Priority__c!=NULL){
                trackAAA.Delivery_Priority__c='AAA';
            }
            updateToAAA.add(trackAAA);
        }
        update updateToAAA;
        
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing AAA cooper tracking records*** '+updateToAAA);
        
        //Air Freight
        List<Invoiced_Sales_Tracking__c> trackingAir=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
         List<Invoiced_Sales_Tracking__c> updateToAir=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackAir:trackingAir){
            if(trackAir.Delivery_Priority__c!=NULL){
                trackAir.Delivery_Priority__c='Air';
            }
            updateToAAA.add(trackAir);
        }
        update updateToAir;
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Air Freight tracking records*** '+updateToAir);

        //Roa Runner
        List<Invoiced_Sales_Tracking__c> trackingRoa=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
         List<Invoiced_Sales_Tracking__c> updateToRoa=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackRoa:trackingRoa){
            if(trackRoa.Delivery_Priority__c!=NULL){
                trackRoa.Delivery_Priority__c='Roa';
            }
            updateToRoa.add(trackRoa);
        }
        update updateToRoa;
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Roa Runner tracking records*** '+updateToRoa);
        
        //Sea Freight
        List<Invoiced_Sales_Tracking__c> trackingSea=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
         List<Invoiced_Sales_Tracking__c> updateToSea=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackSea:trackingSea){
            if(trackSea.Delivery_Priority__c!=NULL){
                trackSea.Delivery_Priority__c='Sea';
            }
            updateToSea.add(trackSea);
        }
        update updateToSea;
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Sea Freight tracking records*** '+updateToSea);
        
       //Old Dominion
        List<Invoiced_Sales_Tracking__c> trackingOld=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
         List<Invoiced_Sales_Tracking__c> updateToOld=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackOld:trackingOld){
            if(trackOld.Delivery_Priority__c!=NULL){
                trackOld.Delivery_Priority__c='Old';
            }
            updateToOld.add(trackOld);
        }
        update updateToOld;
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Old Dominion tracking records*** '+updateToOld);
        
        //Holland
         List<Invoiced_Sales_Tracking__c> trackingHol=[SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c 
                                                   FROM Invoiced_Sales_Tracking__c
                                                   WHERE Sales_Order_Key__c='111-10-AAA'
                                                    ];
         List<Invoiced_Sales_Tracking__c> updateToHol=new List<Invoiced_Sales_Tracking__c>();
        for(Invoiced_Sales_Tracking__c trackHol:trackingHol){
            if(trackHol.Delivery_Priority__c!=NULL){
                trackHol.Delivery_Priority__c='Hol';
            }
            updateToHol.add(trackHol);
        }
        update updateToHol;
        Invoiced_Sales_Helper_Class.addShipping(invSalesDetList);
        System.debug('***Printing Holland tracking records*** '+updateToHol);
        
        Test.stopTest();
    }
    
   @isTest static void testCheckProduct(){
        //Test data for the Sobject
       List<Invoiced_Sales__c> listInvSales=[SELECT  Material_Key__c, Material_Name__c, CurrencyIsoCode, Product__c 
                                              FROM Invoiced_Sales__c 
                                              WHERE Material_Name__c='5571' ];
            
        Test.startTest();
        Invoiced_Sales_Helper_Class.checkProduct(listInvSales);
        
        Test.stopTest();
        
        
        
    }
    
    @isTest static void testCurrency(){
        
        List<Invoiced_Sales__c> listInvSales1=[SELECT  Material_Key__c, Material_Name__c, CurrencyIsoCode 
                                              FROM Invoiced_Sales__c 
                                              WHERE Material_Name__c='5571' ];
        List<Invoiced_Sales__c> updateCurrency=new List<Invoiced_Sales__c> ();
        for(Invoiced_Sales__c invSale:listInvSales1){
            if(invSale.CurrencyIsoCode!=null){
                invSale.CurrencyIsoCode='AUD';
            }
            updateCurrency.add(invSale);
        }
        update updateCurrency;
        
         List<Invoiced_Sales__c> updateToAUD=[SELECT  Material_Key__c, Material_Name__c, CurrencyIsoCode 
                                              FROM Invoiced_Sales__c 
                                              WHERE Material_Name__c='5571' ];
        Invoiced_Sales_Helper_Class.currencyReset(updateToAUD);
        System.debug('Printing NZD currency List '+updateToAUD);
        
        List<Invoiced_Sales__c> updateNZD=new List<Invoiced_Sales__c> ();
        for(Invoiced_Sales__c invSale:listInvSales1){
            if(invSale.CurrencyIsoCode!=null){
                invSale.CurrencyIsoCode='NZD';
            }
            updateNZD.add(invSale);
        }
        update updateNZD;
        List<Invoiced_Sales__c> updateToNZD=[SELECT  Material_Key__c, Material_Name__c, CurrencyIsoCode 
                                              FROM Invoiced_Sales__c 
                                              WHERE Material_Name__c='5571' ];
        Invoiced_Sales_Helper_Class.currencyReset(updateToNZD);
        System.debug('Printing NZD currency List '+updateToNZD);
    }
  @isTest static void testBackupAlternatives(){
       
        date salesDate = Date.today();
        date salesDateLY = salesDate.addYears(-1);
        salesDate = salesDate.addMonths(-2);
        List<Account> acc = [SELECT Id FROM Account WHERE Name = 'Test PP Account'];
        List<Product2> prod = [SELECT Id FROM Product2 WHERE Name IN ('AA-10511-1', 'AA-10511-13') ];
        
       //Test data for Open Orders
        list<Open_Orders__c> oList = new list<Open_Orders__c>();
            Open_Orders__c openOrder = new Open_Orders__c(
                Account__c = acc[0].Id,
                Territory_Number__c = '700123',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Order_Number__c = '3139447',
                Business_Unit__c='Surgical Disposables',
                Line_Item_Number__c = '10',
                Product__c = prod[0].Id,
                Product_Class__c = '0033',
                Order_Date__c = salesDate,
                Scheduled_Ship_Date__c = salesDate,
                Maintenance_Key__c = '123',
                PO_Number__c = 'abc123',
                Open_Order_Qty__c = 3,
                Open_Order_Total__c = 123
            );
            oList.add(openOrder);
      
            
            Open_Orders__c openOrder2 = new Open_Orders__c(
                Account__c = acc[0].Id,
                Territory_Number__c = '700123',
                Material_Name__c = 'AA-10511-1',
                Material_Key__c = 'AA-10511-1-US30-10',
                Order_Number__c = '3139446',
                Business_Unit__c='Surgical Disposables',
                Line_Item_Number__c = '10',
                Product__c = prod[0].Id,
                Product_Class__c = '0033',
                Order_Date__c = salesDate,
                SAP_Code__c = '10170226',
                Parent_Account_Key__c = '10170226',
                Scheduled_Ship_Date__c = salesDate,
                Maintenance_Key__c = '234',
                PO_Number__c = 'abc123',
                Open_Order_Qty__c = 3,
                Open_Order_Total__c = 123
            );
            oList.add(openOrder2);
     
            insert oList;
      //Test data for Backorder Replacement Matrix records
      Backorder_Replacement_Matrix__c matrixRecord =new Backorder_Replacement_Matrix__c(
      Alt_Product_1__c='AA-10511-1',
      Alt_Product_2__c='AA-10511-1',
      Alt_Product_3__c='AA-10511-13',          
      Material_Key__c='AA-10511-1-US30-10', 
      Product__c=prod[0].Id, 
      Distribution_Channel__c='10', 
      Sales_Org__c='US30');
      insert matrixRecord;
        
        Test.startTest();
        Invoiced_Sales_Helper_Class.backupAlternatives(oList);
        List<Open_Orders__c> updatedRecords =[SELECT Sub_1__c,Sub_1_Stock__c,Sub_1_Status__c, Subs_1_Product_on_Hand__c, Material_Key__c FROM Open_Orders__c WHERE Id IN:oList];
      for(Open_Orders__c opOrder :updatedRecords){
          System.debug('Sub_1 ' +opOrder.Sub_1__c+' Sub_1_Stock__c '+opOrder.Sub_1_Stock__c+' Sub_1_Status__c '+opOrder.Sub_1_Status__c+' Subs_1_Product_on_Hand__c '+opOrder.Subs_1_Product_on_Hand__c);
      }
      
                  
     System.debug('Printing updatedRecords '+updatedRecords);
        Test.stopTest();
        
    }
    
    @isTest static void testCompPOC() {
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/compensation_Export?id=Surgical_Disposables__c');
        Test.setCurrentPage(pageRef);
        
        compensation_POC cPOC = new compensation_POC();
        cPOC.refreshing();
        Invoiced_Sales_Helper_Class.randomKey();
        Invoiced_Sales_Helper_Class check = new Invoiced_Sales_Helper_Class();
        string mKey = check.getMaintenanceKey('Invoiced_Sales_Detail__c');
        Test.stopTest();
    }
    
   
}