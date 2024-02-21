@isTest
private class Latam_rr_test {
    static testmethod void myUnitTest() {

        LATAM_RR_Regions__c newLATAM_RR_Region = new LATAM_RR_Regions__c(
            Name = 'Brazil'
        );
        insert newLATAM_RR_Region;
        
        LATAM_RR_Products__c newLATAM_RR_Product = new LATAM_RR_Products__c(
            Name = 'Anesthesia'
        );
        insert newLATAM_RR_Product;
        
        Account a = new Account(
            Name = 'Test Latam__RR Account',
            SAP_Sold_To__c ='111111',
            Sales_Region__c ='Brazil',
            BillingCountry = 'BR'
        );
        insert a;
        system.debug('a:' + a);

        date yearDate = date.today().addDays(-365);//setting as 2018
        string yearStr = string.valueOf(yearDate.year());
        
        LATAM_Target__c lgt = new LATAM_Target__c (
            Account__c = a.id,
            Account_Name__c = a.Name,
            Account_ID__c = a.id,
            Sales_Region__c ='Brazil',
            Product_Family__c = 'Anesthesia',
            Target_Amount__c = 10000,
            Year__c = yearStr
        );
        insert lgt;
        system.debug('lgt:' + lgt);

        Latam_Sales_Transactions__c lst = new Latam_Sales_Transactions__c (
            Account__c = a.id,
            Account_ID__c = a.id,
            Account_Name__c = a.Name,
            Sales_Region__c ='Brazil',
            Product_Family1__c = 'Anesthesia',
            Transaction_Amount__c = 2000,
            Transaction_Date__c = System.Today().addDays(-365),//setting as 2018
            SAP_Code__c = a.SAP_Sold_to__c,
            Quarter1__c = 'Q1'
        );
        insert lst;
        system.debug('lst:' + lst);

        LATAM_Order_Transaction__c  lot = new  LATAM_Order_Transaction__c (
            Account__c = a.id,
            Account_ID__c = a.id,
            Account_Name__c = a.Name,
            Sales_Region__c ='Brazil',
            Product_Family1__c = 'Anesthesia',
            Transaction_Amount__c = 3000,
            Required_Date__c = System.Today().addDays(-365),//setting as 2018
            Quarter1__c = 'Q1'
        );
        insert lot;
        system.debug('lot:' + lot);

        // Start Test
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/Latam_rr');
        Test.setCurrentPage(pageRef);
        Test.setReadOnlyApplicationMode(true);

        LATAM_RR testcontroller = new LATAM_RR();

        testcontroller.getmegamap();
        testcontroller.getaccts();
        testcontroller.getpgs();
        testcontroller.getRegions();


        PageReference pageRef1 = new PageReference('/apex/Latam_rr_Outlook');
        Test.setCurrentPage(pageRef1);
        Test.setReadOnlyApplicationMode(true);

        LATAM_RR_Outlook testcontroller1 = new LATAM_RR_Outlook();
        testcontroller1.getmegamap();
        testcontroller1.getaccts();
        testcontroller1.getpgq();
        testcontroller1.getpgs();
        testcontroller1.getRegions();
        Test.stopTest();

    }
}