/*********************************************************************
* Description      : Test coverage for Pricing Portal Create Contact
* Coverage         : Classes(PP_Create_Contact)
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
@isTest
private class PP_Create_Contact_Test {
    static testMethod void PP_Create_Contact_UnitTest() {

        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
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
            username='unit.test@unit.teleflex.com',
            Business_Unit__c = 'Australia',
            UserRoleId = roleId
        );
        insert u;

        System.runAs(u){

            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex/Arrow',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Active_Sales_Org_Key__c = 'US6020',
                Active_Currency__c = 'USD'
            );
            insert cu;
            
            Contract_User__c cu2 = new Contract_User__c(
                Name = 'Adam Franks1',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex/Arrow',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Active_Sales_Org_Key__c = 'US103020',
                Active_Currency__c = 'USD'
            );
            insert cu2;

            
            Account accRec = new Account(
                Name= 'TestAccount',
                SAP_Sold_To__c = '102059',
                Description = 'AA-10511-1',
                Account_Group__c = 'Z001'
            );
            insert accRec;
            Contact conRec = TestDataFactory.createContact('TestContact', accRec.Id);
            
            Price_Quote__c PQTest = new Price_Quote__c(
                Account_Name__c = accRec.Id,
                Contact_Name__c = conRec.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US6010'
            );
            insert PQTest;
            
            Price_Quote__c PQTest2 = new Price_Quote__c(
                Account_Name__c = accRec.Id,
                Contact_Name__c = conRec.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US103010'
            );
            insert PQTest2;

            //List<String> prodList = new List<String>();
            Product2 prodTest = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                UOM__c='CS',Each_per_Case__c=5,
                Material_Status__c='MTS',Material_Status_Numeric__c='30',
                Family = 'Hardware',Material__c='AA-10511-1',
                Brand_Name__c='Arrow',Buom__c='EA',
                Class__c='Cardiac Care Specialty',Cost__c=11587.40,
                Cost_Price_Unit__c=1000,Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Group__c='Interventional',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,Sales_Unit__c='CS',
                List_Price__c=380.00,Rep_Price__c=350.00,
                Sales_Org__c = 'US60',Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US6010',RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            insert prodTest;
            
            Product2 prodTest2 = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                UOM__c='CS',Each_per_Case__c=5,
                Material_Status__c='MTS',Material_Status_Numeric__c='30',
                Family = 'Hardware',Material__c='AA-10511-1',
                Brand_Name__c='Arrow',Buom__c='EA',
                Class__c='Cardiac Care Specialty',Cost__c=11587.40,
                Cost_Price_Unit__c=1000,Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Group__c='Interventional',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,Sales_Unit__c='CS',
                List_Price__c=380.00,Rep_Price__c=350.00,
                Sales_Org__c = 'US10',Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US103010',RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            insert prodTest2;

            Cross_Reference__c CRTest = new Cross_Reference__c(
                Competitor_Product_Code__c = '320250',
                Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                Competitor_Name__c ='Jarit/Integra',
                Percent_Match__c=100,
                Product__c = prodTest.Id
            );
            insert CRTest;

            Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
                Price_Quote__c = PQTest.Id,
                Material_Name__c = prodTest.Id,
                Sales_Price__c = 230.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 330.00,
                List_Price__c = 380.00,
                Quantity__c = 1,
                Extended_Price__c = 230.00,
                Competetive_Product__c = CRTest.Id
            );
            insert PQLineItem;

            PRF__c prf = new PRF__c(
                Account__c=accRec.Id,
                Contact__c=conRec.Id,
                Agreement_Type__c='Direct Only Agreement',
                Current_Annual_Purchases__c=10000.00,
                Estimated_Annual_Purchases__c=100000.00,
                Preferred_Start_Date__c = Date.valueOf('2016-04-20'),
                Preferred_End_Date__c = Date.valueOf('2017-03-11'),
                Data_Driven_Justification__c='This is a test.',
                Price_Quote__c=PQTest.Id
            );
            insert prf;

            Test.startTest();
            PageReference pageRefpre = new PageReference('/apex/PP_Create_Contact');
            Test.setCurrentPage(pageRefpre);
            pageRefpre.getParameters().put('PRF', 'yes');
            pageRefpre.getParameters().put('cid', '102059');
            //pageRefpre.getParameters().put('contId', conRec.Id);
            //pageRefpre.getParameters().put('pqId', PQTest.Id);
            pageRefpre.getParameters().put('id', accRec.Id);

            PP_Create_Contact PPCreateContact = new PP_Create_Contact();
            PPCreateContact.contactRec = conRec;
            PPCreateContact.saveMethod();
            PPCreateContact.closePopup();
            PPCreateContact.showPopup();
            PPCreateContact.getMyBuContacts();
            PPCreateContact.getAcctContacts();
            PPCreateContact.processSelectContact();
            PPCreateContact.saveMethod();
            PPCreateContact.doCloning();

            pageRefpre = new PageReference('/apex/PP_Create_Contact');
            Test.setCurrentPage(pageRefpre);
            pageRefpre.getParameters().put('id', accRec.Id);
            pageRefpre.getParameters().put('pqId', PQTest.Id);

            PPCreateContact = new PP_Create_Contact();
            PPCreateContact.contactRec = conRec;
            PPCreateContact.saveMethod();
            PPCreateContact.closePopup();
            PPCreateContact.showPopup();
            PPCreateContact.getMyBuContacts();
            PPCreateContact.getAcctContacts();
            PPCreateContact.processSelectContact();
            PPCreateContact.saveMethod();
            PPCreateContact.doCloning();

            pageRefpre = new PageReference('/apex/PP_Create_Contact');
            Test.setCurrentPage(pageRefpre);
            pageRefpre.getParameters().put('id', accRec.Id);
            pageRefpre.getParameters().put('contId', conRec.Id);

            PPCreateContact = new PP_Create_Contact();
            PPCreateContact.contactRec = conRec;
            PPCreateContact.saveMethod();
            PPCreateContact.closePopup();
            PPCreateContact.showPopup();
            PPCreateContact.getMyBuContacts();
            PPCreateContact.getAcctContacts();
            PPCreateContact.processSelectContact();
            PPCreateContact.saveMethod();
            PPCreateContact.doCloning();

            pageRefpre = new PageReference('/apex/PP_Create_Contact');
            Test.setCurrentPage(pageRefpre);
            pageRefpre.getParameters().put('PRF', 'yes');
            pageRefpre.getParameters().put('cid', '102059');
            pageRefpre.getParameters().put('contId', conRec.Id);
            pageRefpre.getParameters().put('pqId', PQTest.Id);
            pageRefpre.getParameters().put('id', accRec.Id);

            PPCreateContact = new PP_Create_Contact();
            PPCreateContact.contactRec = conRec;
            PPCreateContact.saveMethod();
            PPCreateContact.doCloning();

            Test.stopTest();
        }
    }
    
    static testMethod void PP_Create_Contact_UnitTest_UserBusinessUnit_EMEA() {

        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'uflex76',
            email='unit.test2@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='John',
            lastname='Doe',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p.Id,
            timezonesidkey='Europe/London',
            username='unit.test2@unit.teleflex.com',
            Business_Unit__c = 'Commercial Operations',
            UserRoleId = roleId
        );
        insert u;

        System.runAs(u){

            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex/Arrow',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Active_Sales_Org_Key__c = 'US6020',
                Active_Currency__c = 'USD'
            );
            insert cu;
            
            Contract_User__c cu2 = new Contract_User__c(
                Name = 'Adam Franks1',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex/Arrow',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Active_Sales_Org_Key__c = 'US103020',
                Active_Currency__c = 'USD'
            );
            insert cu2;
            
            Contract_Partnership__c cp = TestDataFactory.createContractPartnership();
            cp.Ship_to__c = '102059';
            cp.Disabled__c = false;
			insert cp;
            
            Account accRec = new Account(
                Name= 'TestAccount',
                SAP_Sold_To__c = '102059',
                Description = 'AA-10511-1',
                Account_Group__c = 'Z002'
            );
            insert accRec;
            
            Contact conRec = TestDataFactory.createContact('TestContact', accRec.Id);
            
            Price_Quote__c PQTest = new Price_Quote__c(
                Account_Name__c = accRec.Id,
                Contact_Name__c = conRec.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US6010'
            );
            insert PQTest;
            
            Price_Quote__c PQTest2 = new Price_Quote__c(
                Account_Name__c = accRec.Id,
                Contact_Name__c = conRec.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US103010'
            );
            insert PQTest2;

            //List<String> prodList = new List<String>();
            Product2 prodTest = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                UOM__c='CS',Each_per_Case__c=5,
                Material_Status__c='MTS',Material_Status_Numeric__c='30',
                Family = 'Hardware',Material__c='AA-10511-1',
                Brand_Name__c='Arrow',Buom__c='EA',
                Class__c='Cardiac Care Specialty',Cost__c=11587.40,
                Cost_Price_Unit__c=1000,Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Group__c='Interventional',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,Sales_Unit__c='CS',
                List_Price__c=380.00,Rep_Price__c=350.00,
                Sales_Org__c = 'US60',Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US6010',RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            insert prodTest;
            
            Product2 prodTest2 = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                UOM__c='CS',Each_per_Case__c=5,
                Material_Status__c='MTS',Material_Status_Numeric__c='30',
                Family = 'Hardware',Material__c='AA-10511-1',
                Brand_Name__c='Arrow',Buom__c='EA',
                Class__c='Cardiac Care Specialty',Cost__c=11587.40,
                Cost_Price_Unit__c=1000,Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Group__c='Interventional',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,Sales_Unit__c='CS',
                List_Price__c=380.00,Rep_Price__c=350.00,
                Sales_Org__c = 'US10',Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US103010',RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            insert prodTest2;

            Cross_Reference__c CRTest = new Cross_Reference__c(
                Competitor_Product_Code__c = '320250',
                Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                Competitor_Name__c ='Jarit/Integra',
                Percent_Match__c=100,
                Product__c = prodTest.Id
            );
            insert CRTest;

            Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
                Price_Quote__c = PQTest.Id,
                Material_Name__c = prodTest.Id,
                Sales_Price__c = 230.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 330.00,
                List_Price__c = 380.00,
                Quantity__c = 1,
                Extended_Price__c = 230.00,
                Competetive_Product__c = CRTest.Id
            );
            insert PQLineItem;

            PRF__c prf = new PRF__c(
                Account__c=accRec.Id,
                Contact__c=conRec.Id,
                Agreement_Type__c='Direct Only Agreement',
                Current_Annual_Purchases__c=10000.00,
                Estimated_Annual_Purchases__c=100000.00,
                Preferred_Start_Date__c = Date.valueOf('2016-04-20'),
                Preferred_End_Date__c = Date.valueOf('2017-03-11'),
                Data_Driven_Justification__c='This is a test.',
                Price_Quote__c=PQTest.Id
            );
            insert prf;

            Test.startTest();
            
            PageReference pageRefpre = new PageReference('/apex/PP_Create_Contact');
            Test.setCurrentPage(pageRefpre);
            pageRefpre.getParameters().put('PRF', 'yes');
            pageRefpre.getParameters().put('cid', '102059');
            pageRefpre.getParameters().put('contId', conRec.Id);
            pageRefpre.getParameters().put('pqId', PQTest.Id);
            pageRefpre.getParameters().put('id', accRec.Id);


            PP_Create_Contact PPCreateContact = new PP_Create_Contact();
            PPCreateContact.contactRec = conRec;
            PPCreateContact.saveMethod();
            PPCreateContact.closePopup();
            PPCreateContact.showPopup();
            PPCreateContact.getMyBuContacts();
            PPCreateContact.getAcctContacts();
            PPCreateContact.processSelectContact();
            PPCreateContact.saveMethod();
            PPCreateContact.doCloning();

            Test.stopTest();
        }
    }
    
    static testMethod void PP_Create_Contact_UnitTest2() {
        
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'uflex76',
            email='unit.test3@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='John',
            lastname='Doe',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p.Id,
            timezonesidkey='Europe/London',
            username='unit.test2@unit.teleflex.com',
            Business_Unit__c = 'EMEA',
            UserRoleId = roleId
        );
        insert u;
        
        System.runAs(u){
            
            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex/Arrow',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Active_Sales_Org_Key__c = 'US6020',
                Active_Currency__c = 'USD'
            );
            insert cu;
            
            Contract_User__c cu2 = new Contract_User__c(
                Name = 'Adam Franks1',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex/Arrow',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Active_Sales_Org_Key__c = 'US103020',
                Active_Currency__c = 'USD'
            );
            insert cu2;
            
            Contract_Partnership__c cp = TestDataFactory.createContractPartnership();
            cp.Ship_to__c = '102059';
            cp.Disabled__c = FALSE;
            insert cp;
            
            Account accRec = new Account(
                Name= 'TestAccount',
                SAP_Sold_To__c = '102059',
                Description = 'AA-10511-1',
                Account_Group__c = 'Z002'
            );
            insert accRec;
            
            Contact conRec = TestDataFactory.createContact('TestContact', accRec.Id);
            
            Price_Quote__c PQTest = new Price_Quote__c(
                Account_Name__c = accRec.Id,
                Contact_Name__c = conRec.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US6010'
            );
            insert PQTest;
            
            Price_Quote__c PQTest2 = new Price_Quote__c(
                Account_Name__c = accRec.Id,
                Contact_Name__c = conRec.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US103010'
            );
            insert PQTest2;
            
            //List<String> prodList = new List<String>();
            Product2 prodTest = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                UOM__c='CS',Each_per_Case__c=5,
                Material_Status__c='MTS',Material_Status_Numeric__c='30',
                Family = 'Hardware',Material__c='AA-10511-1',
                Brand_Name__c='Arrow',Buom__c='EA',
                Class__c='Cardiac Care Specialty',Cost__c=11587.40,
                Cost_Price_Unit__c=1000,Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Group__c='Interventional',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,Sales_Unit__c='CS',
                List_Price__c=380.00,Rep_Price__c=350.00,
                Sales_Org__c = 'US60',Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US6010',RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            insert prodTest;
            
            Product2 prodTest2 = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                UOM__c='CS',Each_per_Case__c=5,
                Material_Status__c='MTS',Material_Status_Numeric__c='30',
                Family = 'Hardware',Material__c='AA-10511-1',
                Brand_Name__c='Arrow',Buom__c='EA',
                Class__c='Cardiac Care Specialty',Cost__c=11587.40,
                Cost_Price_Unit__c=1000,Division__c='60',
                Description='TRANSRADIAL ACCESS TRAY',
                Group__c='Interventional',
                SubGroup__c = 'TransRadial Access',
                Qty_Sales_Unit__c=5,Sales_Unit__c='CS',
                List_Price__c=380.00,Rep_Price__c=350.00,
                Sales_Org__c = 'US10',Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US103010',RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            insert prodTest2;
            
            Cross_Reference__c CRTest = new Cross_Reference__c(
                Competitor_Product_Code__c = '320250',
                Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                Competitor_Name__c ='Jarit/Integra',
                Percent_Match__c=100,
                Product__c = prodTest.Id
            );
            insert CRTest;
            
            Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
                Price_Quote__c = PQTest.Id,
                Material_Name__c = prodTest.Id,
                Sales_Price__c = 230.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 330.00,
                List_Price__c = 380.00,
                Quantity__c = 1,
                Extended_Price__c = 230.00,
                Competetive_Product__c = CRTest.Id
            );
            insert PQLineItem;
            
            PRF__c prf = new PRF__c(
                Account__c=accRec.Id,
                Contact__c=conRec.Id,
                Agreement_Type__c='Direct Only Agreement',
                Current_Annual_Purchases__c=10000.00,
                Estimated_Annual_Purchases__c=100000.00,
                Preferred_Start_Date__c = Date.valueOf('2016-04-20'),
                Preferred_End_Date__c = Date.valueOf('2017-03-11'),
                Data_Driven_Justification__c='This is a test.',
                Price_Quote__c=PQTest.Id
            );
            insert prf;
            
            Test.startTest();
            
            PageReference pageRefpre = new PageReference('/apex/PP_Create_Contact');
            //pageRefpre.getParameters().put('PRF', 'yes');
            pageRefpre.getParameters().put('cid', '102059');
            //pageRefpre.getParameters().put('contId', conRec.Id);
            //pageRefpre.getParameters().put('pqId', PQTest.Id);
            pageRefpre.getParameters().put('id', accRec.Id);
             Test.setCurrentPage(pageRefpre);
            
            PP_Create_Contact PPCreateContact = new PP_Create_Contact();
            //PPCreateContact.contactRec = conRec;
            PPCreateContact.saveMethod();
            PPCreateContact.closePopup();
            PPCreateContact.showPopup();
            PPCreateContact.getMyBuContacts();
            PPCreateContact.getAcctContacts();
            PPCreateContact.processSelectContact();
            //PPCreateContact.saveMethod();
            PPCreateContact.doCloning();
           
            
            Test.stopTest();
        }
    }
}