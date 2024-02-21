/*********************************************************************
* Description         : Controller Test class for SAP Connection and Send/Receive xml responses.
* MockHTTPCallout cls : SAPMockHttpSoapStubTest.apxc
* Author(s)           : Saya Zhangabatyr
* Date         	      : 7/24/2023
* Work Item		      : W-025980
**********************************************************************/
@isTest
private class SAPSoapStubControllerTest {
    //Helper method to query Product_Mapping__mdt records
    @TestVisible
    private static List<Product_Mapping__mdt> getProductMappingList(){
        return [SELECT Product_Category_Code__c, Product_Category_Name__c, Product_Area_Name__c, Product_Area_Code__c 
                FROM Product_Mapping__mdt];
    }
    @isTest static void testConnect2GetSalesRepLookupInfoFromSAP(){
        //set test data
        Account acc1= new Account( Name='Test Account2', SAP_Sold_To__c='SAP456', Sales_Org__c='AU10');
        insert acc1;
        String accId=String.valueOf(acc1.Id);
        Product2 prodTest = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='40',
                Family = 'Hardware',
                Material__c='AA-10511-1',
                Brand_Name__c='Arrow',
                Buom__c='EA',
                Class__c='Cardiac Care Specialty',
                Cost__c=11587.40,
                Cost_Price_Unit__c=1000,
                Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Group__c='Interventional',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,
                Sales_Unit__c='CS',
                List_Price__c=380.00,
                Rep_Price__c=350.00,
                RSM_Price__c=330.00,
                Distribution_Channel__c='10',
                Sales_Org_Key__c='US6010',
                Single_Use_Demo__c = TRUE
            );
            insert prodTest;
        //Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SAPMockHttpSoapStubTest(false));
        //call method to test
        Test.startTest();
        Map<String, String> prodInfoMap=new Map<String, String>();
        prodInfoMap.put('accSfId', accId);
        prodInfoMap.put('ItemNumber', prodTest.Id);
        List<Product_Mapping__mdt> testProductList = getProductMappingList();
        for(Product_Mapping__mdt eachProduct:testProductList){
            prodInfoMap.put(eachProduct.Product_Category_Name__c, eachProduct.Product_Category_Code__c);
            prodInfoMap.put(eachProduct.Product_Area_Name__c, eachProduct.Product_Area_Code__c);
        }
        System.debug('Printing prodInfoMap in test class: '+prodInfoMap);
        List<SAPSoapWrapperHub.SAPSalesRepInfoWrapper> salesrepinfoLst = SAPSoapStubController.connect2GetSalesRepLookupInfoFromSAP(prodInfoMap);
        Test.stopTest();
        String fname='Rob';
        String lname='Haffey';
        String email='robert.haffey@teleflex.com';
        String phone='111-111-1111';
        String message=null;
        //verify response received contains expected values
        for(SAPSoapWrapperHub.SAPSalesRepInfoWrapper salesRepInfo : salesrepinfoLst){
            System.assertEquals(fname, salesRepInfo.fname);
            System.assertEquals(lname, salesRepInfo.lname);
            System.assertEquals(email, salesRepInfo.email); 
            System.assertEquals(phone, salesRepInfo.phone);
            System.assertEquals(message, salesRepInfo.message);
        } 
    }   
    @isTest static void testGetProductsDetailsInternal(){
        //Test data for Product_Mapping__mdt records
        List<Product_Mapping__mdt> testProductList=getProductMappingList();
        Set<String> prodCatSet = new Set<String>();
        for(Product_Mapping__mdt eachProd:testProductList){
            prodCatSet.add(eachProd.Product_Category_Name__c);
        }
        //Call the method to be tested 
        Test.startTest();
        List<String> listOfProducts=SAPSoapStubController.getProductsDetailsInternal();
        Test.stopTest();
        //Verify expected output
        System.assertEquals(prodCatSet.size(), listOfProducts.size());
        System.debug(' printing testProduct set '+prodCatSet);
        System.debug(' listOfProducts '+listOfProducts);
    }
    @isTest static void testGetProductAreaVals(){
        String productCategoryName ='Vascular Access';
        Test.startTest();
        List<String> listOfProductAreas=SAPSoapStubController.getProductAreaVals(productCategoryName);
        List<Product_Mapping__mdt> testProductList=getProductMappingList();
        List<String> testMap= new List <String>();
        for(Product_Mapping__mdt product:testProductList){
            if(product.Product_Category_Name__c.equals(productCategoryName)){
                testMap.add(product.Product_Area_Code__c);
            }
        }
        Test.stopTest();
        //Verify expected result
        System.assertEquals(listOfProductAreas.size(),testMap.size());        
    }
    @isTest static void testGetCustCodeByAccId(){
        //set test data
        Account acc1= new Account( Name='Test Account1', SAP_Sold_To__c='SAP123', Sales_Org__c='US60');
        insert acc1;
        String accId=String.valueOf(acc1.ID);
        //Call the method 
        Test.startTest();
        Account retAccObj=SAPSoapStubController.getAccDetailsById(acc1.Id);
        Test.stopTest();
        //assert outcome
        System.assertEquals(acc1.SAP_Sold_To__c, retAccObj.SAP_Sold_To__c);
        System.assertEquals(acc1.Sales_Org__c, retAccObj.Sales_Org__c);
    }
    @isTest static void testConnect2GetOrderHistoryInfoFromSAP(){
        //set test data
        Account acc1= new Account( Name='Test Account2', SAP_Sold_To__c='1014431', Sales_Org__c='US60');
        insert acc1;
         Map<String, String> orderReqMap=new Map<String, String>();
        orderReqMap.put('accCustCode',acc1.SAP_Sold_To__c);
        orderReqMap.put('salesOrg', acc1.Sales_Org__c);
        orderReqMap.put('fromDate', '2023-02-20');
        orderReqMap.put('toDate', '2023-09-20');
         //Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SAPMockHttpSoapStubTest(false));
         //Call the method to be tested 
        Test.startTest();
        List<SAPSoapWrapperHub.SAPOrderHistoryWrapper> listOfOrders=SAPSoapStubController.connect2GetOrderHistoryInfoFromSAP(orderReqMap);
        Test.stopTest();
        //assert outcome
        System.assertEquals(listOfOrders.size(),3);         
      }
    
    @isTest static void testConnect2GetOrderDetailsFromSAP(){
        //set test data
        Account acc1= new Account( Name='Test Account3', SAP_Sold_To__c='1014431', Sales_Org__c='US60');
        insert acc1;
        Map<String, String> orderReqMap=new Map<String, String>();
        orderReqMap.put('accCustCode',acc1.SAP_Sold_To__c);
        orderReqMap.put('orderNum', '10019819');
        
         //Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SAPMockHttpSoapStubTest(false));
         //Call the method to be tested 
        Test.startTest();
        List<SAPSoapWrapperHub.SAPOrderDetailsWrapper> listOfOrderDetails=SAPSoapStubController.connect2GetOrderDetailsFromSAP(orderReqMap);
        Test.stopTest();
        //assert outcome
        System.assertEquals(listOfOrderDetails[0].items.size(),3);
    }
    
    @isTest static void testFaultResponse(){
          //set test data
        Account acc1= new Account( Name='Test Account3', SAP_Sold_To__c='101445', Sales_Org__c='US60');
        insert acc1;
        Map<String, String> orderReqMap=new Map<String, String>();
        orderReqMap.put('accCustCode',acc1.SAP_Sold_To__c);
        orderReqMap.put('orderNum', '463677');
        //Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SAPMockHttpSoapStubTest(true));
        //Call the method to be tested 
        Test.startTest();
        List<SAPSoapWrapperHub.SAPOrderDetailsWrapper> listOfOrderDetails=SAPSoapStubController.connect2GetOrderDetailsFromSAP(orderReqMap);
        
        Test.stopTest();
        
    }   
    
}