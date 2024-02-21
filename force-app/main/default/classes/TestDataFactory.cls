@isTest
public class TestDataFactory {
    public static Account createAccount(String accName){
        Account accTest = new Account(
            Name=accName,
            SAP_Sold_To__c = '102059',
            Description = 'AA-10511-1'
        );
        insert accTest;
        return accTest;
    }
    public static Contact createContact(String conName, Id accId){
        Contact conTest = new Contact(
            LastName = conName,
            AccountId = accId,
            FirstName = 'FirstName',
            Email='abc@123.com',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
            Title = 'Admin',
            Business_Unit1__c = 'Anesthesia'
        );
        insert conTest;
        return conTest;
    }
    public static Price_Quote__c createPriceQuote(Id accId,Id conId){
        Price_Quote__c PQTest = new Price_Quote__c(
            Account_Name__c = accId,
            Contact_Name__c = conId,
            Status__c = 'In Progress',
            Expiration_Date__c = Date.today() + 90
        );
        insert PQTest;
        return PQTest;
    }
    public static Product2 createProduct(String prodName) {
        Product2 prodTest = new Product2(
            Name = prodName,
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
            RSM_Price__c=330.00);
        return prodTest;
    }
    public static Cross_Reference__c createCrossRef(Id prdId){
        Cross_Reference__c CRTest = new Cross_Reference__c(
            Competitor_Product_Code__c = '320250',
            Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
            Competitor_Name__c ='Jarit/Integra',
            Percent_Match__c=100,
            Product__c = prdId
        );
        insert CRTest;
        return CRTest;
    }

    public static Price_Quote_Line_Item__c createPriceQLineItem(Id pqId,Id prdId,Id crId) {
        Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
            Price_Quote__c = pqId,
            Material_Name__c = prdId,
            Sales_Price__c = 230.00,
            Quantity__c=1,
            Extended_Price__c = 230.00,
            Competetive_Product__c = crId
        );
        insert PQLineItem;
        return PQLineItem;
    }

    public static Contract_Header__c createContractHeader(String chName) {
        Contract_Header__c conHead = new Contract_Header__c();
        conHead.Name = chName;
        //conHead.CurrencyIsoCode = 'USD - U.S. Dollar';
        conHead.Description__c = 'AA-10511-1';
        conHead.Agreement_Number__c = 'TestId';
        conHead.GPO_Contract_Ref__c = 'TestRef';
        conHead.Alt_UI__c = True;
        conHead.Valid_From__c = System.Today().addMonths(-1);
        conHead.Valid_To__c = System.Today().addMonths(1);
        conHead.Owner_Name__c = 'Novation';
        conHead.Owner__c = 'GPO-008';

        //conHead.Active__c = false;
        return conHead;
    }

    public static Contract_Material__c createContractMat( Product2 prodObj, Contract_Header__c contHeader ) {
        Contract_Material__c cmObj = new Contract_Material__c();
        cmObj.Name = 'TestId';
        cmObj.Product__c = prodObj.id;
        cmObj.Agreement__c = contHeader.id;
        cmObj.Sales_Org__c = 'US10';
        cmObj.Valid_From__c = System.Today().addMonths(-1);
        cmObj.Valid_To__c = System.Today().addMonths(1);

        return cmObj;
    }

    public static Contract_Partnership__c createContractPartnership(){
        Contract_Partnership__c cpTest = new Contract_Partnership__c();
        cpTest.Sale_to__c = '112136';
        cpTest.Ship_to__c = '102059';
        return cpTest;
    }

    public static Contract_Customer__c createContractCustomer(Id accId,Id conHeadId){
        Contract_Customer__c conCus = new Contract_Customer__c();
        conCus.Account__c = accId;
        conCus.Agreement__c = conHeadId;
        conCus.Name = '50010878';
        conCus.SAP_Code__c= '102059';
        conCus.Customer_Group__c = '34';
        conCus.Condition_Record__c ='0015600849';
        return conCus;
    }
}