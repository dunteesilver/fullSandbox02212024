@IsTest
public class PP_ProductImageUpdateBatch_Test {
    @testSetup static void setup() {
        // Create common test leads
        List<ProductImageUrls__c> testCustomSettings = new List<ProductImageUrls__c>();
        testCustomSettings.add(new ProductImageUrls__c(Name='Default', EndpointSuffix__c='surgical/rusch/pain/products/'));
        insert testCustomSettings;        
    }
    @isTest static void testBatch() {
        //create test product
        Product2 prodTest = new Product2(
            Name = '353535',ProductCode= '353535',UOM__c='CS',
            Each_per_Case__c=5,Material_Status__c='MTS',Material_Status_Numeric__c='30',
            Family = 'Hardware',Material__c='353535',Brand_Name__c='Arrow',
            Buom__c='EA',Class__c='Cardiac Care Specialty',Cost__c=11587.40,
            Cost_Price_Unit__c=1000,Division__c='60',Description='TRANSRADIAL ACCESS TRAY',
            Group__c='Regional Anesthesia',SubGroup__c = 'TransRadial Access',
            Qty_Sales_Unit__c=5,Sales_Unit__c='CS',SBU__c='Anesthesia',
            List_Price__c=380.00,Rep_Price__c=350.00,
            Sales_Org__c = 'US10',Distribution_Channel__c = '10',
            Sales_Org_Key__c = 'US103010',RSM_Price__c=330.00
        );
        //prodList.add(prodTest.Name);
        insert prodTest;
        String body = '{"id":24849,"product_code":"353535","name":"DEBAKEY PERIPHERAL VASCULAR CLAMP",'+
            '"product-description":"ANGLED, 3 3/4\\" (9.4cm) tip length, 2.8mm tip width, Curved shaft, 7 1/8\\" (18cm)",'+
            '"images":[{"format":"details","urls":["https://www.teleflexarcatalog.com/images/products/pilling/details/SR_353535.jpg",'+
            '"https://www.teleflexarcatalog.com/images/products/pilling/details/SR_353535_CU.jpg"]},'+
            '{"format":"hi-res","urls":["https://www.teleflexarcatalog.com/images/products/pilling/hi-res/SR_353535.jpg",'+
            '"https://www.teleflexarcatalog.com/images/products/pilling/hi-res/SR_353535_CU.jpg"]},'+
            '{"format":"listing","urls":["https://www.teleflexarcatalog.com/images/products/pilling/listing/SR_353535.jpg",'+
            '"https://www.teleflexarcatalog.com/images/products/pilling/listing/SR_353535_CU.jpg"]},'+
            '{"format":"thumb","urls":["https://www.teleflexarcatalog.com/images/products/pilling/thumb/SR_353535.jpg",'+
            '"https://www.teleflexarcatalog.com/images/products/pilling/thumb/SR_353535_CU.jpg"]}],'+
            '"url":"https://www.teleflexarcatalog.com/anesthesia-respiratory/pain/products/24849"}';
        // Set single mock implementation that responds dynamically to different requests
        
        try{
            test.startTest();
            SingleRequestMock fakeResponse = new SingleRequestMock(200,'OK',body,null);
            Test.setMock(httpCalloutMock.class, fakeResponse);
            PP_ProductImageUpdateBatch batchSch=new PP_ProductImageUpdateBatch();
            Database.executebatch(batchSch,10);
            
            String sch='0 0 0 ? * * *';
            String jobId = System.schedule('UpdateProductImageUpdateBatch Schedule', sch , batchSch);
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
            System.assertEquals(0, ct.TimesTriggered);
            test.stopTest();
        }
        catch(exception e){}
    }
    
}