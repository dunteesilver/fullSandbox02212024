/*********************************************************************
* Description      : Test coverage for Pricing Portal Agreement Details.
* Coverage         : Classes(PP_Agreement_Detail)
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
@isTest
private class PP_Agreement_Detail_Test {
    static testMethod void PP_Create_Quote_UnitTest() {
        /*Product2 prodObj = TestDataFactory.createProduct('AA-10511-1');
insert prodObj;

Contract_Header__c conHeaderObj = TestDataFactory.createContractHeader('Test Agg');
insert conHeaderObj;

Contract_Material__c contractMat = TestDataFactory.createContractMat(prodObj,conHeaderObj);
insert contractMat;
system.debug('contractMat: ' + contractMat);

Account accObj = TestDataFactory.createAccount('Test Account');
Contact conObj = TestDataFactory.createContact('Test Contact', accObj.id);

Price_Quote__c  quoteObj = TestDataFactory.createPriceQuote(accObj.id, conObj.id);

*/
        Account accTest = new Account(
            Name = 'TestAccount',
            SAP_Sold_To__c = '102059',
            Account_Group__c = 'Z002'
        );
        insert accTest;
        Contact conTest = new Contact(FirstName ='Test',
                                      email = 'abc@123.com',LastName = 'TestContact',Position_Job_Title__c='Administrator',
                                      Credentials__c='RN',
                                      Preferred_language__c='English (American)', AccountId = accTest.Id);
        insert conTest;
        
        Product2 prodTest = new Product2(
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
            Sales_Org_Key__c = 'US6010',
            Material_Key__c = 'AA-10511-1-US60-10'
        );
        //prodList.add(prodTest.Name);
        insert prodTest;
        
        Product2 prodTest2 = new Product2(
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
            Sales_Org_Key__c = 'US103010',
            Material_Key__c = 'AA-10511-1-US30-10'
        );
        //prodList.add(prodTest.Name);
        insert prodTest2;
        
        Territory_Master__c tm = new Territory_Master__c(
            Name = '700123',
            Territory_Number__c = '700123',
            Business_Unit__c = 'Surgical'
        );
        insert tm;
        System.debug('Insert Territory Master-->' + tm);
        
        Sales_by_Product__c ssp = new Sales_by_Product__c(
            Account__c = accTest.Id,
            Business_Unit__c = 'Surgical',
            Distribution_Channel__c = '10',
            Key__c = '100123-AA-10511-1',
            Material_Key__c = 'AA-10511-1-US60-10',
            Product__c = prodTest.Id,
            Sales_Org__c = 'US60',
            Sales_Prior_Year__c = 123.00,
            Sales_YTD__c = 321.00,
            SAP_Code__c = '100123',
            Territory__c = tm.Id,
            Territory_Number__c = '700123'
        );
        insert ssp;
        
        Sales_by_Product__c ssp2 = new Sales_by_Product__c(
            Account__c = accTest.Id,
            Business_Unit__c = 'Surgical',
            Distribution_Channel__c = '10',
            Key__c = '100123-AA-10511-1',
            Material_Key__c = 'AA-10511-1-US10-10',
            Product__c = prodTest2.Id,
            Sales_Org__c = 'US10',
            Sales_Prior_Year__c = 123.00,
            Sales_YTD__c = 321.00,
            SAP_Code__c = '100123',
            Territory__c = tm.Id,
            Territory_Number__c = '700123'
        );
        insert ssp2;
        
        Contract_Header__c chTest = new Contract_Header__c(
            Name = '50000000',
            Agreement_Number__c = '50000000',
            Description__c = 'Test Description',
            Contract_Detail__c = '',
            Owner__c = 'SAPcode101',
            GPO_Contract_Ref__c = 'MEDANRET',
            Valid_From__c = Date.Today() - 1,
            Valid_To__c = Date.Today() + 1000,
            Alt_UI__c = false
        );
        insert chTest;
        
        Contract_Customer__c ccTest = new Contract_Customer__c(
            Name = '50000000',
            Agreement__c = chTest.Id,
            Account__c = accTest.Id,
            SAP_Code__c = 'SAPcode101',
            Sales_Org__c = 'US60',
            Valid_From__c = Date.Today(),
            Valid_To__c = Date.Today() + 1000,
            Distribution_Channel__c = '10'
        );
        insert ccTest;
        
        Contract_Customer__c ccTest2 = new Contract_Customer__c(
            Name = '50000000',
            Agreement__c = chTest.Id,
            Account__c = accTest.Id,
            SAP_Code__c = 'SAPcode101',
            Sales_Org__c = 'US10',
            Valid_From__c = Date.Today(),
            Valid_To__c = Date.Today() + 1000,
            Distribution_Channel__c = '10'
        );
        insert ccTest2;
        
        Contract_Material__c cmTest = new Contract_Material__c(
            Name = '50000000',
            Agreement__c = chTest.Id,
            Material_Name__c = 'AA-10511-1',
            Product__c = prodTest.Id,
            Sales_Org__c = 'US60',
            Valid_From__c = Date.Today(),
            Valid_To__c = Date.Today() + 1000,
            Material_Division__c = '10',
            Price__c = 380.00
        );
        insert cmTest;
        
        Contract_Material__c cmTest2 = new Contract_Material__c(
            Name = '50000000',
            Agreement__c = chTest.Id,
            Material_Name__c = 'AA-10511-1',
            Product__c = prodTest2.Id,
            Sales_Org__c = 'US10',
            Valid_From__c = Date.Today(),
            Valid_To__c = Date.Today() + 1000,
            Material_Division__c = '10',
            Price__c = 380.00
        );
        insert cmTest2;
        
        Price_Quote__c PQTest = new Price_Quote__c(
            Account_Name__c = accTest.Id,
            Contact_Name__c = conTest.Id,
            Status__c = 'In Progress',
            Expiration_Date__c = Date.today() + 90,
            Sales_Org_Key__c = 'US6010'
        );
        insert PQTest;
        
        Test.startTest();
        PageReference pageRef2 = Page.PP_Agreement_Detail;
        Test.setCurrentPage(pageRef2);
        pageRef2.getParameters().put('aid', '50000000');
        pageRef2.getParameters().put('materialStr', 'AA-10511-1');
        pageRef2.getParameters().put('pqid', PQTest.id);
        pageRef2.getParameters().put('rs', 'xls');
        PP_Agreement_Detail agDetailObj = new PP_Agreement_Detail();
        agDetailObj.getplist();
        agDetailObj.getad();
        agDetailObj.getaltui();
        agDetailObj.getPRF();
        System.assertEquals(false,agDetailObj.getaltui());
        chTest.Alt_UI__c = true;
        UPDATE chTest;
        agDetailObj.getaltui();
        System.assertEquals(true,agDetailObj.getaltui());
        agDetailObj.addQuoteLine();
        agDetailObj.getbigreport();
        agDetailObj.filename = 'x';
        System.assertEquals(PQTest.Id,agDetailObj.pqid);
        String s = agDetailObj.filename;
        agDetailObj.rxls = 'x';
        String s1 = agDetailObj.rxls;
        agDetailObj.rpdf = 'x';
        String s2 = agDetailObj.rpdf;
        agDetailObj.aid = 'x';
        String s3 = agDetailObj.aid;
        PP_Agreement_Detail.htmlList('50000000');
        
        //Test for Null Contract Header, Contract Material
        PageReference pageRef3 = Page.PP_Agreement_Detail;
        Test.setCurrentPage(pageRef3);
        PP_Agreement_Detail agDetailObj1 = new PP_Agreement_Detail();
        //DELETE chTest;
        System.assertEquals(NULL,agDetailObj1.getad());
        System.assertEquals(NULL,agDetailObj1.getplist());
        agDetailObj1.getplist2();
        //agDetailObj1.addQuoteLine();
        //System.assertEquals(NULL,agDetailObj.getplist2());
        string xox = agDetailObj1.rxls;
        DELETE chTest;
        
        //Test for Null pqid
        PageReference pageRef4 = Page.PP_Agreement_Detail;
        Test.setCurrentPage(pageRef4);
        System.currentPageReference().getParameters().put('pqid', NULL);
        PP_Agreement_Detail agDetailObj2 = new PP_Agreement_Detail();
        DELETE PQTest;
        agDetailObj2.pqid = NULL;
        System.assertEquals(NULL,agDetailObj2.pqid);
        //agDetailObj.addQuoteLine();
        //System.assertEquals(NULL,agDetailObj.addQuoteLine());
        xox = agDetailObj2.rxls;
        
        //https://teleflex--sandbox--c.cs42.visual.force.com/apex/PP_Agreement_Detail_Export?aid=50005741&rs=xls
        Test.stopTest();
    }
}