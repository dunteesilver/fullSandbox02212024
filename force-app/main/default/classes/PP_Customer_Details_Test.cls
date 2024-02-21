/*********************************************************************
* Description      : Test coverage for Pricing Portal Customer Details.
* Coverage         : Classes(PP_Customer_Details)
* Author(s)        : Dun Silver
**********************************************************************/
@isTest
public class PP_Customer_Details_Test {


    //start test for constructor code
    static testmethod void PP_Customer_Details_UnitTest(){
        //create Account test record
        Account accTest = new Account(
            Name='PP Test Account TFX',
            SAP_Sold_To__c = '102059',
            Description = 'AA-10511-1',
            ShippingStreet = '123',
            ShippingCity = 'Raleigh',
            ShippingState = 'NC',
            ShippingPostalCode = '27610',
            Territory_Key__c ='800095',
            ShippingCountry = 'US'
        );
        insert accTest;

        Account accTest1 = new Account(
            Name='PP Test Account TFX',
            SAP_Sold_To__c = '102058',
            Description = 'AA-10511-1',
            ShippingStreet = '123',
            ShippingCity = 'Raleigh',
            ShippingState = 'NC',
            ShippingPostalCode = '27610',
            Territory_Key__c ='800314',
            ShippingCountry = 'US'
        );
        insert accTest1;

        Contract_Partnership__c cp = new Contract_Partnership__c(
            Sale_to__c = '102058',
            Ship_to__c = '102059'
        );
        insert cp;

        //create Contact test record
        Contact conTest = new Contact(
            LastName = 'PPlastName',
            Email='abc@123.com',
            AccountId = accTest.Id,
            FirstName = 'PPfirstName',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)'

        );
        insert conTest;

        //Price Quote Test Record
        Price_Quote__c PQTest = new Price_Quote__c(
            Account_Name__c = accTest.Id,
            Contact_Name__c = conTest.Id,
            Status__c = 'In Progress',
            Expiration_Date__c = Date.today() + 90
        );
        insert PQTest;

        //Product Test Record
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
            Description = 'AA-10511-1',
            Group__c='Interventional',
            SubGroup__c = 'TransRadial Access',
            Qty_Sales_Unit__c=5,
            Sales_Unit__c='CS',
            List_Price__c=380.00,
            Rep_Price__c=350.00,
            RSM_Price__c=330.00
        );
        insert prodTest;

        //Cross Reference Test Record
        Cross_Reference__c CRTest = new Cross_Reference__c(
            Competitor_Product_Code__c = '320250',
            Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
            Competitor_Name__c ='Jarit/Integra',
            Percent_Match__c=100,
            Product__c = prodTest.Id
        );
        insert CRTest;

        //Price Quote Line Item Test Record
        Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
            Price_Quote__c = PQTest.Id,
            Material_Name__c = prodTest.Id,
            Sales_Price__c = 230.00,
            Quantity__c=1,
            Extended_Price__c = 230.00,
            Competetive_Product__c = CRTest.Id
        );
        insert PQLineItem;

        //Contract Header Test Records
        Contract_Header__c conHead = new Contract_Header__c(
        Name = 'Test CH',
            Description__c = 'AA-10511-1',
            Agreement_Number__c = 'TestId',
            GPO_Contract_Ref__c = 'TestRef',
            Valid_From__c = System.Today().addMonths(-1),
            Valid_To__c = System.Today().addMonths(1),
            Owner_Name__c = 'Novation',
            Owner__c = 'GPO-008'
        );
        insert conHead;

        //Contract Material Test Record
        Contract_Material__c cmObj = new Contract_Material__c();
        cmObj.Name = 'TestId';
        cmObj.Product__c = prodTest.id;
        cmObj.Agreement__c = conHead.id;
        cmObj.Sales_Org__c = 'US10';
        insert cmObj;
        
        Contract_Material__c cmObj2 = new Contract_Material__c();
        cmObj2.Name = 'TestId';
        cmObj2.Product__c = prodTest.id;
        cmObj2.Agreement__c = conHead.id;
        cmObj2.Sales_Org__c = 'US60';
        insert cmObj2;

        //Contract Partner Test Record
        Contract_Partnership__c cpTest = new Contract_Partnership__c();
        cpTest.Sale_to__c = '112136';
        cpTest.Ship_to__c = '102059';
        insert cpTest;

        cpTest = new Contract_Partnership__c();
        cpTest.Sale_to__c = '123136';
        cpTest.Ship_to__c = '102059';
        insert cpTest;

        //Contract Customer Test Record
        Contract_Customer__c conCus = new Contract_Customer__c();
        conCus.Account__c = accTest.Id;
        conCus.Agreement__c = conHead.Id;
        conCus.Name = '50010878';
        conCus.SAP_Code__c= '102059';
        conCus.Customer_Group__c = '34';
        conCus.Condition_Record__c ='0015600849';
        insert conCus;

        Test.startTest();
        PageReference cd = Page.PP_Customer_Details;
        cd.getParameters().put('cid',accTest.SAP_Sold_To__c);
        Test.setCurrentPage(cd);

        PP_Customer_Details cdController = new PP_Customer_Details();
		    cdController.getURL();
        cdController.checkSecurity();
        cdController.getcustomerreport();
        set<String> cnlist = cdController.cnlist;
        string cid = cdController.cid;

        Test.setCurrentPageReference(cd);
        cd.getParameters().put('cid','');
        cdController.strCust = '';
        cdController.getURL();

        Test.setCurrentPageReference(cd);
        cd.getParameters().put('cid','  ');
        cdController.strCust = ' ';
        cdController.getURL();

        PageReference cd1 = Page.PP_Customer_Details;
        cd1.getParameters().put('id',accTest.Id);
        Test.setCurrentPage(cd1);

        PP_Customer_Details cdController1 = new PP_Customer_Details();
        cdController1.strCust = accTest.SAP_Sold_To__c;
		    cdController1.getURL();
        Test.stopTest();
    }//end test for constructor code

}//end test class