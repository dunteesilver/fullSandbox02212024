@isTest
public class PP_Price_Quote_Test {
    
    @testSetup static void dataSetup(){
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name LIKE '%EMEA%' LIMIT 1].Id;
        Profile p = [select id from profile where name='System Administrator'];
        
        User u2 = new User(
            alias = 'uflex76',
            email='unit2.test@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Dun',
            lastname='Silver',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid = p.Id,
            timezonesidkey='America/New_York',
            username='unit2.test@unit.teleflex.com',
            Business_Unit__c = 'Anesthesia'
        );
        insert u2;
  
        User u = new User(
            alias = 'uflex76',
            email='unit.test@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Adam',
            lastname='Franks',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid = p.Id,
            timezonesidkey='America/New_York',
            username='unit.test@unit.teleflex.com',
            Business_Unit__c = 'Anesthesia',
            UserRoleId = roleId,
            ManagerId = u2.Id
        );
        insert u;


        //User updateUser = new User(Id=u.Id, ManagerId=u2.Id);
        //update updateUser;
        //List<User> userInsert = new List<User>();
        /*
        for(Integer i = 0; i < 10; i++){
            Integer y =i/2;
            Integer z=y*2;
            if(z==i){
                u = new User(
                    alias = 'uflex'+i,
                    email='unit.test'+i+'@unit.teleflex.com',
                    emailencodingkey='UTF-8',
                    firstname='Adam'+i,
                    lastname='Franks'+i,
                    languagelocalekey='en_US',
                    localesidkey='en_GB',
                    profileid = p.Id,
                    timezonesidkey='Europe/London',
                    username='unit.test'+i+'@unit.teleflex.com',
                    Business_Unit__c = 'Anesthesia'
                );
                userInsert.add(u);
            }//end if
            else{
                u = new User(
                    alias = 'uflex'+i,
                    email='unit.test'+i+'@unit.teleflex.com',
                    emailencodingkey='UTF-8',
                    firstname='Adam'+i,
                    lastname='Franks'+i,
                    languagelocalekey='en_US',
                    localesidkey='en_GB',
                    profileid = p.Id,
                    timezonesidkey='Europe/London',
                    username='unit.test'+i+'@unit.teleflex.com',
                    Business_Unit__c = 'Alternate Care'
                );
                userInsert.add(u);
            }//end else
            
            if(z==i){
                u1 = new User(
                    alias = 'uflex'+i,
                    email='unit.test'+i+'@unit.teleflex.com',
                    emailencodingkey='UTF-8',
                    firstname='Stan'+i,
                    lastname='Silver'+i,
                    languagelocalekey='en_US',
                    localesidkey='en_GB',
                    profileid = p.Id,
                    timezonesidkey='Europe/London',
                    username='unit.test'+i+'@unit.teleflex.com',
                    Business_Unit__c = 'Interventional Capital'
                );
                userInsert.add(u1);
            }//end if
            else{
                u1 = new User(
                    alias = 'uflex'+i,
                    email='unit.test'+i+'@unit.teleflex.com',
                    emailencodingkey='UTF-8',
                    firstname='Stan'+i,
                    lastname='Silver'+i,
                    languagelocalekey='en_US',
                    localesidkey='en_GB',
                    profileid = p.Id,
                    timezonesidkey='Europe/London',
                    username='unit.test'+i+'@unit.teleflex.com',
                    Business_Unit__c = 'Surgical Instruments'
                );
                userInsert.add(u1);
            }//end else
            User updateUser = new User(Id=u.Id, ManagerId=u2.Id);
            for(User curr : userInsert){
                if( > 0){
                    
                }//end if
            }//end for loop to update user
            User updateUser = new User(Id=u.Id, ManagerId=u2.Id);
        	update updateUser;
		
        }//end for loop of user creation
        */
        //User updateUser = new User(Id=u.Id, ManagerId=u2.Id);
        //update updateUser;

        list<Group> glist = new list<Group>();
        integer gnum;
        for(Integer x=0; x<6;x++){
            gnum = x + 1;
            group newGroup = new Group(
                Name = 'US Division ' + gnum + '0',
                DeveloperName = 'Division_' + gnum + '0'
            );
            system.debug('newGroup: ' + newGroup);
            glist.add(newGroup);
        }

        Group pp = new Group(
            Name = 'Pricing Portal',
            DeveloperName = 'Pricing_Portal'
        );
        glist.add(pp);

        
        System.runAs(u){
            
            Quote_Logos__c quotelogo = new Quote_Logos__c(
            Name = 'Surgical Instruments',
            Quote_Page__c = 'PP_Print_Quote',
            URL__c = 'test',
            Footer__c = 'test'
        );
        insert quotelogo;

        //insert glist;

        list<Business_Unit__c> buList = new list<Business_Unit__c>();
        Business_Unit__c newBU = new Business_Unit__c(
            Name = 'Vascular',
            Key__c = 'VASC'
        );
        buList.add(newBU);

        newBU = new Business_Unit__c(
            Name = 'Surgical Disposables',
            Active__c = TRUE,
            Page__c = 'account',
            Key__c = 'SDIS'
        );
        buList.add(newBU);
        
        newBU = new Business_Unit__c(
            Name = 'Anesthesia',
            Active__c = TRUE,
            Page__c = 'account',
            Key__c = 'ANES',
            Auto_Create_Opportunity__c = TRUE
        );
        buList.add(newBU);
        //insert bu2;                
        insert buList;

            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Division_10__c = TRUE,
                Division_20__c = TRUE,
                Division_30__c = TRUE,
                Division_40__c = TRUE,
                Division_50__c = TRUE,
                Division_60__c = TRUE,
                Active_Sales_Org_Key__c = 'US6010',
                Active_Currency__c = 'USD',
                Pricing_Tier_Access__c = 1
            );
            
            Contract_User__c cu2 = new Contract_User__c(
                Name = 'Dun Silver',
                User__c = u2.id,
                Active_Region__c = 'US - Teleflex/Arrow',
                US_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Division_10__c = TRUE,
                Division_20__c = TRUE,
                Division_30__c = TRUE,
                Division_40__c = TRUE,
                Division_50__c = TRUE,
                Division_60__c = TRUE,
                Active_Sales_Org_Key__c = 'US103010',
                Active_Currency__c = 'USD',
                Pricing_Tier_Access__c = 1
            );
            Test.startTest();
            insert cu;
            insert cu2;
            Test.stopTest();
            system.debug('CU:' + cu);

            /*
            Map<String,RecordType> recordTypeMap = new Map<String,RecordType>(); //holds map of recordtype name and object
            List<RecordType> recTypes = [Select Name, Id, SobjectType, DeveloperName From RecordType Where sObjectType='Account'];
            //loop to create map of account recordtypes
            for(RecordType curr : recTypes){
                recordTypeMap.put(curr.Name,curr);
            }
            */
            
            Account accTest = new Account(
                Name = 'TestAccount',
                SAP_Sold_To__c = '102059',
                Account_Group__c = 'Z002',
                Customer_Group__c = '16',
                zBlock__c = '00',
                ERP_Active__c = TRUE,
                Sales_Org__c = 'US60',
                Exclusion_type__c = 'ZB01'
            );
            insert accTest;

            Account accTest2 = new Account(
                Name = 'NewAccount',
                SAP_Sold_To__c = '110069',
                Account_Group__c = 'Z001',
                Customer_Group__c = '01',
                zBlock__c = '00',
                ERP_Active__c = FALSE,
                Sales_Org__c = 'US60',
                Exclusion_type__c = 'ZB01'
            );
            insert accTest2;
            
			/*
            Account accTest5 = new Account(
                Name = 'TestAccount5',
                zBlock__c = '00',
                ERP_Active__c = FALSE
            );
            insert accTest5;

            Account accTest6 = new Account(
                Name = 'TestAccount6',
                SAP_Sold_To__c = '150322',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '01',
                ERP_Active__c = TRUE
            );
            insert accTest6;
            
            Account accTest7 = new Account(
                Name = 'TestAccount7',
                SAP_Sold_To__c = 'IDN-001',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '00',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IDN Account').getRecordTypeId()
            );
            insert accTest7;
            
            Account accTest8 = new Account(
                Name = 'TestAccount8',
                SAP_Sold_To__c = 'GPO-001',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '00',
                Sales_Org__c = 'US60',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GPO Account').getRecordTypeId()
            );
            insert accTest8;
            
            Account accTest9 = new Account(
                Name = 'TestAccount9',
                SAP_Sold_To__c = '123456',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '01',
                Sales_Org__c = 'AU10',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ANZ Customer').getRecordTypeId()
            );
            insert accTest9;

            Account accTest10 = new Account(
                Name = 'TestAccount10',
                SAP_Sold_To__c = '123457',
                Account_Group__c = 'Z001',
                Customer_Group__c = '03',
                zBlock__c = '01',
                Sales_Org__c = 'CO10',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
            );
            insert accTest10;
            //System.assertEquals(accTest10.RecordTypeId, Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId());
			*/  
            
            Contact conTest = new Contact(
                FirstName ='Test',
                email = 'abc@123.com',
                LastName = 'TestContact',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                AccountId = accTest.Id
            );
            insert conTest;

            Contact conTest2 = new Contact(
                FirstName ='Test',
                email = 'abc@12345.com', 
                LastName = 'TestContact',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                AccountId = accTest2.Id
            );
            insert conTest2;

            Pricebook2 pb = new pricebook2(
                Name='Pricing Portal US',
                IsActive = TRUE
            );
            insert pb;
            system.debug('pb: ' + pb);

            string pbid = pb.Id;
            pbid = pbid.left(15);

            insert new Price_Books__c(
                Name = 'US6010',
                Id__c = pbid,
                Price_Book_Name__c = 'Pricing Portal US'
            );

            
            //List<String> prodList = new List<String>();
            Product2 prodTest = new Product2(
                Name = '353535',
                ProductCode= '353535',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='30',
                Family = 'Hardware',
                Material__c='353535',
                Brand_Name__c='Arrow',
                Buom__c='EA',
                Class__c='Anesthesia',
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
                Transfer_Price__c = 1000.00,
                Sales_Org__c = 'US60',
                Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US6010',
                Material_Key__c = '353535-US60-10',
                RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            master_TriggerHelperClass.runOnce('resetOnceSet');
            insert prodTest;
            system.debug('prodTest: ' + prodTest);

            Product2 prodTest2 = new Product2(
                Name = '000-11',
                ProductCode= '000-11',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='30',
                Family = 'Hardware',
                Material__c='000-11',
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
                Transfer_Price__c = 1000.00,
                Sales_Org__c = 'US10',
                Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US103010',
                Material_Key__c = '00011-US30-10',
                RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            insert prodTest2;

            Product2 prodTest3 = new Product2(
                Name = '000-40',
                ProductCode= '000-40',
                UOM__c='CS',
                Each_per_Case__c=5,
                Material_Status__c='MTS',
                Material_Status_Numeric__c='30',
                Family = 'Hardware',
                Material__c='000-40',
                Brand_Name__c='Arrow',
                Buom__c='EA',
                Class__c='Respiratory',
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
                Transfer_Price__c = 1000.00,
                Sales_Org__c = 'US10',
                Distribution_Channel__c = '10',
                Sales_Org_Key__c = 'US103010',
                Material_Key__c = '00040-US30-10',
                RSM_Price__c=330.00
            );
            //prodList.add(prodTest.Name);
            insert prodTest3;

            Cross_Reference__c CRTest = new Cross_Reference__c(
                Competitor_Product_Code__c = '320250',
                Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                Competitor_Name__c ='Jarit/Integra',
                Percent_Match__c=100,
                Product__c = prodTest.Id);
            insert CRTest;
            List<String> crossRef = new List<String>();
            crossRef.add(CRTest.Competitor_Product_Code__c);

            Contract_Partnership__c cp = new Contract_Partnership__c(
                Sale_to__c = '102059',
                Ship_to__c = '102059',
                Disabled__c = false
            );
            insert cp;

            Contract_Partnership__c cp1 = new Contract_Partnership__c(
                Sale_to__c = '150322',
                Ship_to__c = '110069',
                Disabled__c = false
            );
            insert cp1;

            Contract_Header__c chTest = new Contract_Header__c(
                Name = '50009064',
                Agreement_Number__c = '50009064',
                Description__c = 'Test Description',
                Owner__c = '123310',
                GPO_Contract_Ref__c = '',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000
            );
            
            insert chTest;

            GPO_PickList__c gpoPickList = new GPO_PickList__c(
                Name = 'Vizient Inc.',
                Sales_Org_Key__c = 'US',
                Active__c = TRUE,
                Key__c = 'GPO-008'
            );
            insert gpoPickList;

            list<Contract_Header__c> chList = new list<Contract_Header__c>();
            list<Contract_Material__c> cmList = new list<Contract_Material__c>();
            
            Contract_Header__c chTest2 = new Contract_Header__c(
                Name = '50010864',
                Agreement_Number__c = '50010864',
                Description__c = 'Test Description',
                Owner__c = 'GPO-008',
                GPO_Contract_Ref__c = 'MS0217B',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000
            );
            insert chTest2;
            
            // Tier 1
            Contract_Header__c chTier1 = new Contract_Header__c(
                Name = '50010001',
                Agreement_Number__c = '50010001',
                Description__c = 'Test Description',
                Owner__c = '123310',
                GPO_Contract_Ref__c = 'MS0217B-R',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Sub_Group__c = '8'
            );
            insert chTier1;
            
            Contract_Material__c cmTier1 = new Contract_Material__c(
                Name = '50010001',
                Agreement__c = chTier1.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US60',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '10',
                Price__c = 375.00,
                Maintenance_Key__c = '123'
            );
            insert cmTier1;
            
            Contract_Customer__c ccTier1 = new Contract_Customer__c(
                Name = '50010001',
                Agreement__c = chTier1.Id,
                Account__c = accTest.Id,
                SAP_Code__c = '102059',
                Sales_Org__c = 'US60',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10',
                Condition__c = 'XNAF',
                Maintenance_Key__c = '123'
            );
            insert ccTier1;

            // Tier 2
            Contract_Header__c chTier2 = new Contract_Header__c(
                Name = '50010002',
                Agreement_Number__c = '50010002',
                Description__c = 'Test Description',
                Owner__c = '123310',
                GPO_Contract_Ref__c = 'MS0217B-R',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Sub_Group__c = '8'
            );
            insert chTier2;
            
            Contract_Material__c cmTier2 = new Contract_Material__c(
                Name = '50010001',
                Agreement__c = chTier2.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '10',
                Price__c = 370.00,
                Maintenance_Key__c = '123'
            );
            insert cmTier2;
            
            Contract_Customer__c ccTier2 = new Contract_Customer__c(
                Name = '50010002',
                Agreement__c = chTier2.Id,
                Account__c = accTest.Id,
                SAP_Code__c = '102059',
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10',
                Condition__c = 'XNAF',
                Maintenance_Key__c = '123'
            );
            insert ccTier2;
            
            // Tier 3
            Contract_Header__c chTier3 = new Contract_Header__c(
                Name = '50010003',
                Agreement_Number__c = '50010003',
                Description__c = 'Test Description',
                Owner__c = '123310',
                GPO_Contract_Ref__c = 'MS0217B-R',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Sub_Group__c = '8'
            );
            insert chTier3;
            
            Contract_Material__c cmTier3 = new Contract_Material__c(
                Name = '50010001',
                Agreement__c = chTier3.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '10',
                Price__c = 365.00,
                Maintenance_Key__c = '123'
            );
            insert cmTier3;
            
            Contract_Customer__c ccTier3 = new Contract_Customer__c(
                Name = '50010003',
                Agreement__c = chTier3.Id,
                Account__c = accTest.Id,
                SAP_Code__c = '102059',
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10',
                Condition__c = 'XNAF',
                Maintenance_Key__c = '123'
            );
            insert ccTier3;

            Contract_Customer__c ccTest = new Contract_Customer__c(
                Name = '50009064',
                Agreement__c = chTest.Id,
                Account__c = accTest.Id,
                SAP_Code__c = '102059',
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10',
                Condition__c = 'XNAF',
                Maintenance_Key__c = '123'
            );
            insert ccTest;

            Contract_Customer__c ccTest2 = new Contract_Customer__c(
                Name = '50010864',
                Agreement__c = chTest2.Id,
                Account__c = accTest.Id,
                SAP_Code__c = '102059',
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Distribution_Channel__c = '10',
                Condition__c = 'XPRI'
            );
            insert ccTest2;

            Contract_Material__c cmTest = new Contract_Material__c(
                Name = '50009064',
                Agreement__c = chTest.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '10',
                Price__c = 380.00,
                Maintenance_Key__c = '123'
            );
            insert cmTest;

            Contract_Material__c cmTest2 = new Contract_Material__c(
                Name = '50010864',
                Agreement__c = chTest2.Id,
                Material_Name__c = '353535',
                Product__c = prodTest.Id,
                Sales_Org__c = 'US10',
                Valid_From__c = Date.Today(),
                Valid_To__c = Date.Today() + 1000,
                Material_Division__c = '10',
                Price__c = 350.00
            );
            insert cmTest2;
            
            // Price Quotes
            Price_Quote__c PQTest = new Price_Quote__c(
                Account_Name__c = accTest.Id,
                Contact_Name__c = conTest.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US103010',
                One_Time_Purchase__c = TRUE,
                BusinessUnit__c = 'Anesthesia'
            );
            insert PQTest;

            Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
                Price_Quote__c = PQTest.Id,
                Material_Name__c = prodTest.Id,
                Sales_Price__c = 1.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 330.00,
                List_Price__c = 380.00,
                Quantity__c = 1,
                Extended_Price__c = 230.00,
                Sales_Deal_Description__c = 'test',
                Sales_Number__c = '50009064',
                Competetive_Product__c = CRTest.Id,
                Product_Description__c='Test Description'
            );
            insert PQLineItem;

            // Price Quotes
            Price_Quote__c PQTest2 = new Price_Quote__c(
                Account_Name__c = accTest2.Id,
                Contact_Name__c = conTest2.Id,
                Status__c = 'In Progress',
                Expiration_Date__c = Date.today() + 90,
                Sales_Org_Key__c = 'US6010',
                One_Time_Purchase__c = TRUE,
                BusinessUnit__c = 'Anesthesia'
            );
            insert PQTest2;

            Price_Quote_Line_Item__c PQLineItem2 = new Price_Quote_Line_Item__c(
                Price_Quote__c = PQTest2.Id,
                Material_Name__c = prodTest.Id,
                Sales_Price__c = 1.00,
                Eligible_Price__c = 230.00,
                Rep_Price__c = 350.00,
                RSM_Price__c = 330.00,
                List_Price__c = 380.00,
                Quantity__c = 1,
                Extended_Price__c = 230.00,
                Sales_Deal_Description__c = 'test',
                Sales_Number__c = '50009064',
                //Competetive_Product__c = CRTest.Id,
                Product_Description__c='Test Description'
            );
            insert PQLineItem2;
            
            String pbEntryId = [SELECT Id
                                FROM PriceBookEntry
                                WHERE Product2Id =:prodTest.Id
                                AND Pricebook2Id =:pb.Id LIMIT 1].Id;

 
        }//end of System.RunAs(u)

    }//end of testdata setup method
    
    
    @isTest static void priceQuoteTest() {
        
        User mUser = [select id, name from User where email = 'unit.test@unit.teleflex.com'];
        
        System.runAs(mUser){
            
            system.debug('-- Starting priceQuoteTest --');
            
            Price_Quote__c pqid = [SELECT Id
                                   FROM Price_Quote__c
                                   WHERE Line_Count__c > 0
                                   and Sales_Org_Key__c = 'US103010'
                                   LIMIT 1];
            system.debug('pqid: ' + pqid);
            
            string pqstrID = pqid.Id;
            pqstrID = pqstrID.left(15);
            
            string pqliID = [SELECT ID FROM Price_Quote_Line_Item__c LIMIT 1].Id;
            list<Price_Quote_Line_Item__c> pqliList = [SELECT Id, Material_Name__c, Sales_Price__c,
                                                       Eligible_Price__c, Sales_Deal_Description__c,
                                                       Material_Name__r.Cost__c, Material_Name__r.Transfer_Price__c,
                                                       Material_Name__r.Floor_Price__c, Material_Name__r.Director_Price__c,
                                                       RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Distributor_List__c,
                                                       Material_Name__r.Qty_Sales_Unit__c, Opportunity_Products_Line_ID__c, Line_Price__c
                                                       FROM Price_Quote_Line_Item__c WHERE Price_Quote__c =: pqstrID];
            system.debug('pqliList: ' + pqliList);
            
            User u = [SELECT Id, Name, Business_Unit__c FROM User WHERE Name = 'Adam Franks' LIMIT 1];
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqstrID);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqid);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            
            Test.startTest();
            pqt.strQtyChange = '1';
            pqt.pqlid = pqstrID;
            pqt.strMats = '353535';
            pqt.strProdSearch = '353535';
            pqt.userId = u.Id;
            pqt.userBU = u.Business_Unit__c;
            System.assertEquals(pqt.userId, u.Id);
            
            pqt.soldToAcct = '102059';
            //System.assertEquals('102059', pqt.soldToAcct);
            pqt.soldToAcctType = 'ZH';
            System.assertEquals('ZH',pqt.soldToAcctType);
            
            //pqt.exclusionType = 'ZB01';
            System.debug('*** pqt.exclusionType *** ' + pqt.exclusionType);
            System.assertEquals('ZB01',pqt.exclusionType );
            
            pqt.userBu = 'Anesthesia';
            System.assertEquals('Anesthesia',pqt.userBu );
            
            pqt.lang = '&lang=en';
            System.assertEquals('&lang=en',pqt.lang);
            
            pqt.strQuoteId = pqstrID;
            pqt.sendReport();
            pqt.cancel();
            pqt.createPRF();
            pqt.cpProcess();
            pqt.getcpDropDown();
            pqt.helperMethod();
            pqt.pickListValuesList = pqt.getPickListValuesIntoList();
            
            pqt.buValue = 'Anesthesia';
            pqt.setBu();
            //pqt.cardiacFavorites();
            pqt.bulkInsert2();
            pqt.bulkrefresh();
            pqt.updateOwner();
            pqt.doUpdateAccountValue();
            pqt.getpq();
            pqt.getLineItems();
            
            
            pqt.setPriceToggle();
            pqt.priceToggle = false;
            
            //Added to increase test coverage ***************************************************
            //pqt.userApprovalLevel = true;
            pqt.isApprover = false;
            pqt.getPickListValuesIntoList();
            pqt.doUpdateOwnerValue();
            pqt.setBuHeader(pqt.buValue);
            pqt.blankRow();
            PP_Price_Quote.recall(pqstrID);
            pqt.recall2();
            //Added to increase test coverage ***************************************************
            
            pqt.setPriceToggle();
            pqt.requestHigherTierAccess();
            pqt.getCheckInit();
            pqt.initCube();
            pqt.massUpdateTiers();
            pqt.updateTierPrice();
            PP_Price_Quote.updateBlank(pqliID,'Test');
            
            pqt.massQtyChange();
            pqt.Reject();
            pqt.Approve();
            pqt.massDelItems();
            pqt.removingRow();
            
            Test.stopTest();  
        }
    }//end of priceQuoteTest
    
    
    @isTest static void priceQuoteTest2() {
        
        User mUser = [select id, name from User where email = 'unit.test@unit.teleflex.com'];
        
        System.runAs(mUser){
            
            system.debug('-- Starting priceQuoteTest --');
            
            Price_Quote__c pqid = [SELECT Id
                                   FROM Price_Quote__c
                                   WHERE Line_Count__c > 0
                                   LIMIT 1];
            system.debug('pqid: ' + pqid);
            
            string pqstrID = pqid.Id;
            pqstrID = pqstrID.left(15);
            
            string pqliID = [SELECT ID FROM Price_Quote_Line_Item__c LIMIT 1].Id;
            list<Price_Quote_Line_Item__c> pqliList = [SELECT Id, Material_Name__c, Sales_Price__c, Price_Quote__c,
                                                       Eligible_Price__c, Sales_Deal_Description__c,
                                                       Material_Name__r.Cost__c, Material_Name__r.Transfer_Price__c,
                                                       Material_Name__r.Floor_Price__c, Material_Name__r.Director_Price__c,
                                                       RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Distributor_List__c,
                                                       Material_Name__r.Qty_Sales_Unit__c, Opportunity_Products_Line_ID__c, Line_Price__c
                                                       FROM Price_Quote_Line_Item__c WHERE Price_Quote__r.Account_Name__r.Name = 'TestAccount'];
            system.debug('pqliList: ' + pqliList);
            
            User u = [SELECT Id, Name, Business_Unit__c FROM User WHERE Name = 'Adam Franks' LIMIT 1];
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqstrID);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqid);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            
            pqt.soldToAcct = '102059';
            //System.assertEquals('102059',pqt.soldToAcct);
            
            Test.startTest();
            pqt.strQtyChange = '1';
            pqt.pqlid = pqliList[0].Price_Quote__c;
            pqt.strMats = '353535';
            pqt.strProdSearch = '353535';
            pqt.userId = u.Id;
            pqt.userBU = u.Business_Unit__c;
            Boolean needApproval = pqt.needsApproval;
            Boolean isApprover = pqt.isApprover;
            Boolean hasCross = pqt.hasCrossRef;
            Boolean userApp = pqt.userApprovalLevel;
            System.assertEquals(true, needApproval);
            System.assertEquals(false, isApprover);
            System.assertEquals(false, isApprover);
            System.assertEquals(true, hasCross);
            System.assertEquals(false, userApp);
            System.assertEquals(pqt.userId, u.Id);
            Test.stopTest(); 
        }
    }//end of priceQuoteTest2
    
    
    @isTest static void priceQuoteTest3() {
        
        User mUser = [select id, name from User where email = 'unit.test@unit.teleflex.com'];
        
        System.runAs(mUser){
            
            system.debug('-- Starting priceQuoteTest --');
            
            Price_Quote__c pqid = [SELECT Id
                                   FROM Price_Quote__c
                                   WHERE Line_Count__c > 0
                                   LIMIT 1];
            system.debug('pqid: ' + pqid);
            
            string pqstrID = pqid.Id;
            pqstrID = pqstrID.left(15);
            
            string pqliID = [SELECT ID FROM Price_Quote_Line_Item__c LIMIT 1].Id;
            list<Price_Quote_Line_Item__c> pqliList = [SELECT Id, Material_Name__c, Sales_Price__c, Price_Quote__c,
                                                       Eligible_Price__c, Sales_Deal_Description__c,
                                                       Material_Name__r.Cost__c, Material_Name__r.Transfer_Price__c,
                                                       Material_Name__r.Floor_Price__c, Material_Name__r.Director_Price__c,
                                                       RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Distributor_List__c,
                                                       Material_Name__r.Qty_Sales_Unit__c, Opportunity_Products_Line_ID__c, Line_Price__c
                                                       FROM Price_Quote_Line_Item__c WHERE Price_Quote__r.Account_Name__r.Name = 'NewAccount'];
            system.debug('pqliList: ' + pqliList);
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqstrID);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqid);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            
            Test.startTest();
            pqt.getFormatEligiblePrices(pqliList);
            pqt.getFormatListPrices(pqliList);
            pqt.getFormatLinePrices(pqliList);
            pqt.getFormatRsmPrices(pqliList);
            pqt.getFormatRepPrices(pqliList);
            pqt.getFormatSalesPrices(pqliList);
            pqt.getFormatTotalPrices(pqstrID);
            Test.stopTest();
        }
        
    }//end of priceQuoteTest3
    
    @isTest static void priceQuoteTest4() { 
        User mUser = [select id, name from User where email = 'unit.test@unit.teleflex.com'];
        
        System.runAs(mUser){
            
            system.debug('-- Starting priceQuoteTest4 --');
            
            Price_Quote__c pqid = [SELECT Id
                                   FROM Price_Quote__c
                                   WHERE Line_Count__c > 0
                                   LIMIT 1];
            system.debug('pqid: ' + pqid);
            
            string pqstrID = pqid.Id;
            pqstrID = pqstrID.left(15);
            
            string pqliID = [SELECT ID FROM Price_Quote_Line_Item__c LIMIT 1].Id;
            list<Price_Quote_Line_Item__c> pqliList = [SELECT Id, Material_Name__c, Sales_Price__c, Price_Quote__c,
                                                       Eligible_Price__c, Sales_Deal_Description__c,
                                                       Material_Name__r.Cost__c, Material_Name__r.Transfer_Price__c,
                                                       Material_Name__r.Floor_Price__c, Material_Name__r.Director_Price__c,
                                                       RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Distributor_List__c,
                                                       Material_Name__r.Qty_Sales_Unit__c, Opportunity_Products_Line_ID__c, Line_Price__c
                                                       FROM Price_Quote_Line_Item__c WHERE Price_Quote__r.Account_Name__r.Name = 'NewAccount'];
            system.debug('pqliList: ' + pqliList);
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqstrID);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqid);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            
            Test.startTest();
            pqt.getFormatEligiblePrices(pqliList);
            pqt.getFormatListPrices(pqliList);
            pqt.getFormatLinePrices(pqliList);
            pqt.getFormatRsmPrices(pqliList);
            pqt.getFormatRepPrices(pqliList);
            pqt.getFormatSalesPrices(pqliList);
            pqt.getFormatTotalPrices(pqstrID);
            Test.stopTest();
        }

    }//end of priceQuoteTest4
    
    
    @isTest static void priceQuoteTest5() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman101', 'User101', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US01', 'User01', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US02', 'User02', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;

        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser1){
            //Setup Pricing Portal User records
            Test.startTest();
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser1.Name, usUser1.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','03');
            insert usACC;
            
            Account usAcc1 = testDataFactoryPP.createAccount('TestAcount US1', 'US60','100002','03');
            insert usAcc1;
            usAcc1.Customer_Group__c = '03';
            update usAcc1;
            
            //create Account with no SAP Code
            /*
            Account noSap = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '17',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
			*/
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            insert con2;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            insert usProd3;
			update usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US60');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US60');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US60');
            insert ch4;
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009068', 'GPO-999','D','US60');
            insert ch5;
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;

            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterial(ch5.Id, ch5.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm5;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
            
            Contract_Customer__c cc5 = testDataFactoryPP.createContractCustomer(ch5.Id, ch5.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc5;
            
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            List<Price_Quote_Line_Item__c> pqliList = new List<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            pqliList.add(pqliUs);
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            pqliList.add(pqliUs1);
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            pqliList.add(pqliUs2);
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            pqliList.add(pqliUs3);
            
            Database.insert(pqliList,false);
            //PQ after line item insert
            /*
            Price_Quote__c pqUs2 = [Select Id, Name, Opportunity__r.Name, Opportunity__c, Price_Quote_Name__c, Status__c, Shipping__c, Product_Class_Count__c, Discounted_Total__c,
                                     Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Tax__c, Current_Approver__c, Account_Name__r.Price_List_Type__c,
                                     Internal_Comments_Only__c, Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity,
                                     Account_Name__r.BillingState, Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c, Account_Name__r.ERP_Active__c,
                                     Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c, Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Stationary__c, Discount_Type__c,
                                     Owner_Cell__c, Owner_Phone__c, Owner_Approval_Role__c, Workflow_Owner_Approval_Level__c, Courtesy_Pricing__c, Courtesy_Pricing_Type__c, Quote_Template__c, Discount__c,
                                     Owner_Email__c, Contact_Name__r.Name, Business_Unit__c, Contact_Name__r.id, Contact_Name__r.Phone, Contact_Name__r.Email, LastModifiedById,
                                     CreatedById, InApproval__c, Territory__r.Territory_Name__c, Territory__r.Territory_Number__c,Approval_Flag_Rollup__c, CurrencyIsoCode, How_Created__c,
                                     Owner_Business_Unit__c, Sales_Org_Key__c,Line_Count__c,One_Time_Purchase__c,PRF__c, IsActive__c, Opportunity_Closed__c, Account_Name__r.Customer_Group__c,
                                     RsmRepToggle__c, BusinessUnit__c, OwnerId, Owner.Name, Type__c, Account_Name__r.Exclusion_Type__c,
                                     (SELECT Id, Name,Quantity__c, Price_Quote__r.BusinessUnit__c FROM Price_Quote_Line_Items__r)
                                     FROM Price_Quote__c WHERE id = :pqUs.Id];
            System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Price_Quote_Line_Item__c> lineItems = [Select id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c, Objective_Name__c,Requested_Pricing__r.Agreement_Number__c,
                                                    Objective__c,Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Brand__c, Approval_Flag_Reason__c,
                                                    Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c,Sales_Deal__r.Agreement_Number__c,
                                                    Product_Description__c, Material_Name__r.Cost__c,Sales_deal_Description__c, Sales_Number__c,Material_Name__r.List_Price__c,
                                                    Row_Order__c, Competetive_Product__r.Competitor_Product_Code__c, Material_Name__r.Name, Cost__c, Requested_Pricing__c, Requested_Price__c,
                                                    Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Description__c, Material_Name__r.Director_Price__c, Requested_Pricing_CM__c,
                                                    Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Floor_Price__c, Material_Name__r.SubGroup__c,
                                                    Line_Price__c, Material_Name__r.Transfer_Price__c, Material_Status_Description__c, IsBold__c, Price_Quote__r.Account_Name__r.Price_List_Type__c,
                                                    Approval_Flag_Checkbox__c, Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c,Material_Name_Text__c,
                                                    Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c, MRP_Group__c,
                                                    Owner_Approval_Level__c, Approval_Level__c, Refresh__c, Director_Price__c, Material_Name__r.Class__c, Material_Name__r.MRP_Group__c,
                                                    Material_Name__r.Cost_Price_Unit__c, Price_Quote__r.Owner_Business_Unit__c, Floor_Price__c, Material_Name__r.Cost_Formula__c,
                                                    Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Requested_Pricing__r.Parent_Contract_Name__c, Total_Price_Per_Each__c,
                                                    Sales_Deal__r.Pricing_Tier__c, Requested_Pricing__r.Description__c, Material_Name__r.VP_Price__c, Price_Quote__r.BusinessUnit__c, Price_Per_Each__c
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c=: pqUs2.Id
                                                    ORDER BY Row_Order__c NULLS LAST];
			*/
            //System.debug('*** pqUs2.Line_count__c first *** ' + pqUs.Line_count__c);
            //System.debug('*** lineItems *** ' + lineItems);

			PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);

            pqt.doUpdateOwnerValue();
            String exclusionType = pqt.exclusionType;
            System.assertEquals('ZB01', pqt.exclusionType);
            
            Boolean userApp = pqt.userApprovalLevel;
            Boolean needApproval = pqt.needsApproval;
            Boolean isApprover = pqt.isApprover;
            Boolean hasCross = pqt.hasCrossRef;
            System.assertEquals(false, userApp);
            System.assertEquals(false, needApproval);
            System.assertEquals(false, isApprover);
            System.assertEquals(false, hasCross);
            
            pqt.bulkrefresh();
            pqt.setBuHeader('Anesthesia');
            pqt.strQtyChange = 'aaa';
            pqt.massQtyChange();
            /*
            pqt.getFormatEligiblePrices(lineItems);
            pqt.getFormatListPrices(lineItems);
            pqt.getFormatLinePrices(lineItems);
            pqt.getFormatRsmPrices(lineItems);
            pqt.getFormatRepPrices(lineItems);
            pqt.getFormatSalesPrices(lineItems);
            pqt.getFormatTotalPrices(pqUs2.Id);
			*/
            pqt.blankRow();
            pqt.Approve();
            pqt.recall2();
            pqt.Approve();
            PP_Price_Quote.recall(pqUs.Id);
            Test.stopTest();
        }//end of system run

	}//end of priceQuoteTest5 test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void priceQuoteTest6() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman05', 'User05', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US05', 'User05', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US06', 'User06', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;

        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser1){
            //Setup Pricing Portal User records
            Test.startTest();
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser1.Name, usUser1.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            //create Account with no SAP Code
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '11',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            insert usAcc;
            
            Account usAcc1 = new Account(Name = 'No Sap Code 1',Account_Group__c = 'Z001',Customer_Group__c = '11',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            insert usAcc1;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            insert con2;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            insert usProd3;
			update usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            //Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            //insert cp;
            
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US60');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US60');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US60');
            insert ch4;
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009068', 'GPO-999','D','US60');
            insert ch5;
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterial(ch5.Id, ch5.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm5;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
            
            Contract_Customer__c cc5 = testDataFactoryPP.createContractCustomer(ch5.Id, ch5.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc5;
            
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            List<Price_Quote_Line_Item__c> pqliList = new List<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            pqliList.add(pqliUs);
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            pqliList.add(pqliUs1);
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            pqliList.add(pqliUs2);
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            pqliList.add(pqliUs3);
            
            Database.insert(pqliList,false);

            //PQ after line item insert
            Price_Quote__c pqUs2 = [Select Id, Name, Opportunity__r.Name, Opportunity__c, Price_Quote_Name__c, Status__c, Shipping__c, Product_Class_Count__c, Discounted_Total__c,
                                     Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Tax__c, Current_Approver__c, Account_Name__r.Price_List_Type__c,
                                     Internal_Comments_Only__c, Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity,
                                     Account_Name__r.BillingState, Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c, Account_Name__r.ERP_Active__c,
                                     Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c, Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Stationary__c, Discount_Type__c,
                                     Owner_Cell__c, Owner_Phone__c, Owner_Approval_Role__c, Workflow_Owner_Approval_Level__c, Courtesy_Pricing__c, Courtesy_Pricing_Type__c, Quote_Template__c, Discount__c,
                                     Owner_Email__c, Contact_Name__r.Name, Business_Unit__c, Contact_Name__r.id, Contact_Name__r.Phone, Contact_Name__r.Email, LastModifiedById,
                                     CreatedById, InApproval__c, Territory__r.Territory_Name__c, Territory__r.Territory_Number__c,Approval_Flag_Rollup__c, CurrencyIsoCode, How_Created__c,
                                     Owner_Business_Unit__c, Sales_Org_Key__c,Line_Count__c,One_Time_Purchase__c,PRF__c, IsActive__c, Opportunity_Closed__c, Account_Name__r.Customer_Group__c,
                                     RsmRepToggle__c, BusinessUnit__c, OwnerId, Owner.Name, Type__c, Account_Name__r.Exclusion_Type__c,
                                     (SELECT Id, Name,Quantity__c, Price_Quote__r.BusinessUnit__c FROM Price_Quote_Line_Items__r)
                                     FROM Price_Quote__c WHERE id = :pqUs.Id];
            System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Price_Quote_Line_Item__c> lineItems = [Select id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c, Objective_Name__c,Requested_Pricing__r.Agreement_Number__c,
                                                    Objective__c,Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Brand__c, Approval_Flag_Reason__c,
                                                    Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c,Sales_Deal__r.Agreement_Number__c,
                                                    Product_Description__c, Material_Name__r.Cost__c,Sales_deal_Description__c, Sales_Number__c,Material_Name__r.List_Price__c,
                                                    Row_Order__c, Competetive_Product__r.Competitor_Product_Code__c, Material_Name__r.Name, Cost__c, Requested_Pricing__c, Requested_Price__c,
                                                    Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Description__c, Material_Name__r.Director_Price__c, Requested_Pricing_CM__c,
                                                    Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Floor_Price__c, Material_Name__r.SubGroup__c,
                                                    Line_Price__c, Material_Name__r.Transfer_Price__c, Material_Status_Description__c, IsBold__c, Price_Quote__r.Account_Name__r.Price_List_Type__c,
                                                    Approval_Flag_Checkbox__c, Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c,Material_Name_Text__c,
                                                    Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c, MRP_Group__c,
                                                    Owner_Approval_Level__c, Approval_Level__c, Refresh__c, Director_Price__c, Material_Name__r.Class__c, Material_Name__r.MRP_Group__c,
                                                    Material_Name__r.Cost_Price_Unit__c, Price_Quote__r.Owner_Business_Unit__c, Floor_Price__c, Material_Name__r.Cost_Formula__c,
                                                    Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Requested_Pricing__r.Parent_Contract_Name__c, Total_Price_Per_Each__c,
                                                    Sales_Deal__r.Pricing_Tier__c, Requested_Pricing__r.Description__c, Material_Name__r.VP_Price__c, Price_Quote__r.BusinessUnit__c, Price_Per_Each__c
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c=: pqUs2.Id
                                                    ORDER BY Row_Order__c NULLS LAST];
            System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            System.debug('*** lineItems *** ' + lineItems);

			PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs2.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs2);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);

            pqt.doUpdateOwnerValue();
            System.assertEquals(NULL, pqUs2.Account_Name__r.SAP_Sold_To__c);
            Boolean userApp = pqt.userApprovalLevel;
            Boolean needApproval = pqt.needsApproval;
            Boolean isApprover = pqt.isApprover;
            Boolean hasCross = pqt.hasCrossRef;
            System.assertEquals(false, userApp);
            System.assertEquals(false, needApproval);
            System.assertEquals(false, isApprover);
            System.assertEquals(false, hasCross);
            
            pqt.bulkrefresh();
            pqt.setBuHeader('Anesthesia');
            pqt.getFormatEligiblePrices(lineItems);
            pqt.getFormatListPrices(lineItems);
            pqt.getFormatLinePrices(lineItems);
            pqt.getFormatRsmPrices(lineItems);
            pqt.getFormatRepPrices(lineItems);
            pqt.getFormatSalesPrices(lineItems);
            pqt.getFormatTotalPrices(pqUs2.Id);
            pqt.blankRow();
            pqt.Approve();
            pqt.recall2();
            pqt.Approve();
            PP_Price_Quote.recall(pqUs2.Id);
            Test.stopTest();
        }//end of system run

	}//end of priceQuoteTest6 test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void priceQuoteTest7() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman06', 'User06', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US06', 'User06', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US07', 'User07', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;

        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser1){
            Test.startTest();
            Sales_Condition_Mapping__c conMap1 = new Sales_Condition_Mapping__c(
                name = 'ND', Mapped_Value__c = 'XNAF'
            );
            insert conMap1;
            
            Sales_Condition_Mapping__c conMap2 = new Sales_Condition_Mapping__c(
                name = 'PR', Mapped_Value__c = 'XPRI'
            );
            insert conMap2;
            
            Sales_Condition_Mapping__c conMap3 = new Sales_Condition_Mapping__c(
                name = 'SE', Mapped_Value__c = 'XSEC'
            );
            insert conMap3;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser1.Name, usUser1.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            
            //create Account with no SAP Code
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '17',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            insert usAcc;
            
            Account usAcc1 = new Account(Name = 'No Sap Code 1',Account_Group__c = 'Z001',Customer_Group__c = '17',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            insert usAcc1;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            insert con2;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            insert usProd3;
			update usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            //Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            //insert cp;
            
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US60');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US60');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US60');
            insert ch4;
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009068', 'GPO-999','D','US60');
            insert ch5;
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterial(ch5.Id, ch5.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm5;
            
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
            
            Contract_Customer__c cc5 = testDataFactoryPP.createContractCustomer(ch5.Id, ch5.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc5;
            
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            List<Price_Quote_Line_Item__c> pqliList = new List<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            pqliList.add(pqliUs);
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            pqliList.add(pqliUs1);
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            pqliList.add(pqliUs2);
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            pqliList.add(pqliUs3);
            
            Database.insert(pqliList,false);

            //PQ after line item insert
            Price_Quote__c pqUs2 = [Select Id, Name, Opportunity__r.Name, Opportunity__c, Price_Quote_Name__c, Status__c, Shipping__c, Product_Class_Count__c, Discounted_Total__c,
                                     Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Tax__c, Current_Approver__c, Account_Name__r.Price_List_Type__c,
                                     Internal_Comments_Only__c, Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity,
                                     Account_Name__r.BillingState, Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c, Account_Name__r.ERP_Active__c,
                                     Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c, Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Stationary__c, Discount_Type__c,
                                     Owner_Cell__c, Owner_Phone__c, Owner_Approval_Role__c, Workflow_Owner_Approval_Level__c, Courtesy_Pricing__c, Courtesy_Pricing_Type__c, Quote_Template__c, Discount__c,
                                     Owner_Email__c, Contact_Name__r.Name, Business_Unit__c, Contact_Name__r.id, Contact_Name__r.Phone, Contact_Name__r.Email, LastModifiedById,
                                     CreatedById, InApproval__c, Territory__r.Territory_Name__c, Territory__r.Territory_Number__c,Approval_Flag_Rollup__c, CurrencyIsoCode, How_Created__c,
                                     Owner_Business_Unit__c, Sales_Org_Key__c,Line_Count__c,One_Time_Purchase__c,PRF__c, IsActive__c, Opportunity_Closed__c, Account_Name__r.Customer_Group__c,
                                     RsmRepToggle__c, BusinessUnit__c, OwnerId, Owner.Name, Type__c, Account_Name__r.Exclusion_Type__c,
                                     (SELECT Id, Name,Quantity__c, Price_Quote__r.BusinessUnit__c FROM Price_Quote_Line_Items__r)
                                     FROM Price_Quote__c WHERE id = :pqUs.Id];
            System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Price_Quote_Line_Item__c> lineItems = [Select id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c, Objective_Name__c,Requested_Pricing__r.Agreement_Number__c,
                                                    Objective__c,Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Brand__c, Approval_Flag_Reason__c,
                                                    Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c,Sales_Deal__r.Agreement_Number__c,
                                                    Product_Description__c, Material_Name__r.Cost__c,Sales_deal_Description__c, Sales_Number__c,Material_Name__r.List_Price__c,
                                                    Row_Order__c, Competetive_Product__r.Competitor_Product_Code__c, Material_Name__r.Name, Cost__c, Requested_Pricing__c, Requested_Price__c,
                                                    Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Description__c, Material_Name__r.Director_Price__c, Requested_Pricing_CM__c,
                                                    Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Floor_Price__c, Material_Name__r.SubGroup__c,
                                                    Line_Price__c, Material_Name__r.Transfer_Price__c, Material_Status_Description__c, IsBold__c, Price_Quote__r.Account_Name__r.Price_List_Type__c,
                                                    Approval_Flag_Checkbox__c, Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c,Material_Name_Text__c,
                                                    Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c, MRP_Group__c,
                                                    Owner_Approval_Level__c, Approval_Level__c, Refresh__c, Director_Price__c, Material_Name__r.Class__c, Material_Name__r.MRP_Group__c,
                                                    Material_Name__r.Cost_Price_Unit__c, Price_Quote__r.Owner_Business_Unit__c, Floor_Price__c, Material_Name__r.Cost_Formula__c,
                                                    Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Requested_Pricing__r.Parent_Contract_Name__c, Total_Price_Per_Each__c,
                                                    Sales_Deal__r.Pricing_Tier__c, Requested_Pricing__r.Description__c, Material_Name__r.VP_Price__c, Price_Quote__r.BusinessUnit__c, Price_Per_Each__c
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c=: pqUs2.Id
                                                    ORDER BY Row_Order__c NULLS LAST];
            System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            System.debug('*** lineItems *** ' + lineItems);

			PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs2.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs2);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);

            pqt.doUpdateOwnerValue();
            System.assertEquals(NULL, pqUs2.Account_Name__r.SAP_Sold_To__c);
            Boolean userApp = pqt.userApprovalLevel;
            Boolean needApproval = pqt.needsApproval;
            Boolean isApprover = pqt.isApprover;
            Boolean hasCross = pqt.hasCrossRef;
            System.assertEquals(false, userApp);
            System.assertEquals(false, needApproval);
            System.assertEquals(false, isApprover);
            System.assertEquals(false, hasCross);
            
            pqt.bulkrefresh();
            pqt.setBuHeader('Anesthesia');
            pqt.getFormatEligiblePrices(lineItems);
            pqt.getFormatListPrices(lineItems);
            pqt.getFormatLinePrices(lineItems);
            pqt.getFormatRsmPrices(lineItems);
            pqt.getFormatRepPrices(lineItems);
            pqt.getFormatSalesPrices(lineItems);
            pqt.getFormatTotalPrices(pqUs2.Id);
            pqt.blankRow();
            pqt.Approve();
            pqt.recall2();
            pqt.Approve();
            PP_Price_Quote.recall(pqUs2.Id);
            Test.stopTest();
        }//end of system run

	}//end of priceQuoteTest7 test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void priceQuoteTest8() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman07', 'User07', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US07', 'User07', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US08', 'User08', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;

        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser1){
            Test.startTest();
            Sales_Condition_Mapping__c conMap1 = new Sales_Condition_Mapping__c(
                name = 'ND', Mapped_Value__c = 'XNAF'
            );
            insert conMap1;
            
            Sales_Condition_Mapping__c conMap2 = new Sales_Condition_Mapping__c(
                name = 'PR', Mapped_Value__c = 'XPRI'
            );
            insert conMap2;
            
            Sales_Condition_Mapping__c conMap3 = new Sales_Condition_Mapping__c(
                name = 'SE', Mapped_Value__c = 'XSEC'
            );
            insert conMap3;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser1.Name, usUser1.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','100001','11');
            insert usACC;
            usAcc.Customer_Group__c = '11';
            //usACC.Account_Group__c = 'z002';
            update usACC;
            
            Account usAcc1 = testDataFactoryPP.createAccount('TestAcount US1', 'US60','100002','11');
            insert usAcc1;
            usAcc1.Customer_Group__c = '11';
            update usAcc1;
            
            //create Account with no SAP Code
            /*
            Account noSap = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '17',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
			*/
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            insert con2;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            insert usProd3;
			update usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            insert cp;
            
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US60');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US60');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US60');
            insert ch4;
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009068', 'GPO-999','D','US60');
            insert ch5;
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterial(ch5.Id, ch5.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm5;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
            
            Contract_Customer__c cc5 = testDataFactoryPP.createContractCustomer(ch5.Id, ch5.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc5;
            
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            List<Price_Quote_Line_Item__c> pqliList = new List<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            pqliList.add(pqliUs);
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            pqliList.add(pqliUs1);
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            pqliList.add(pqliUs2);
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            pqliList.add(pqliUs3);
            
            Database.insert(pqliList,false);

            //PQ after line item insert
            /*
            Price_Quote__c pqUs2 = [Select Id, Name, Opportunity__r.Name, Opportunity__c, Price_Quote_Name__c, Status__c, Shipping__c, Product_Class_Count__c, Discounted_Total__c,
                                     Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Tax__c, Current_Approver__c, Account_Name__r.Price_List_Type__c,
                                     Internal_Comments_Only__c, Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity,
                                     Account_Name__r.BillingState, Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c, Account_Name__r.ERP_Active__c,
                                     Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c, Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Stationary__c, Discount_Type__c,
                                     Owner_Cell__c, Owner_Phone__c, Owner_Approval_Role__c, Workflow_Owner_Approval_Level__c, Courtesy_Pricing__c, Courtesy_Pricing_Type__c, Quote_Template__c, Discount__c,
                                     Owner_Email__c, Contact_Name__r.Name, Business_Unit__c, Contact_Name__r.id, Contact_Name__r.Phone, Contact_Name__r.Email, LastModifiedById,
                                     CreatedById, InApproval__c, Territory__r.Territory_Name__c, Territory__r.Territory_Number__c,Approval_Flag_Rollup__c, CurrencyIsoCode, How_Created__c,
                                     Owner_Business_Unit__c, Sales_Org_Key__c,Line_Count__c,One_Time_Purchase__c,PRF__c, IsActive__c, Opportunity_Closed__c, Account_Name__r.Customer_Group__c,
                                     RsmRepToggle__c, BusinessUnit__c, OwnerId, Owner.Name, Type__c, Account_Name__r.Exclusion_Type__c,
                                     (SELECT Id, Name,Quantity__c, Price_Quote__r.BusinessUnit__c FROM Price_Quote_Line_Items__r)
                                     FROM Price_Quote__c WHERE id = :pqUs.Id];
            System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Price_Quote_Line_Item__c> lineItems = [Select id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c, Objective_Name__c,Requested_Pricing__r.Agreement_Number__c,
                                                    Objective__c,Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Brand__c, Approval_Flag_Reason__c,
                                                    Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c,Sales_Deal__r.Agreement_Number__c,
                                                    Product_Description__c, Material_Name__r.Cost__c,Sales_deal_Description__c, Sales_Number__c,Material_Name__r.List_Price__c,
                                                    Row_Order__c, Competetive_Product__r.Competitor_Product_Code__c, Material_Name__r.Name, Cost__c, Requested_Pricing__c, Requested_Price__c,
                                                    Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Description__c, Material_Name__r.Director_Price__c, Requested_Pricing_CM__c,
                                                    Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Floor_Price__c, Material_Name__r.SubGroup__c,
                                                    Line_Price__c, Material_Name__r.Transfer_Price__c, Material_Status_Description__c, IsBold__c, Price_Quote__r.Account_Name__r.Price_List_Type__c,
                                                    Approval_Flag_Checkbox__c, Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c,Material_Name_Text__c,
                                                    Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c, MRP_Group__c,
                                                    Owner_Approval_Level__c, Approval_Level__c, Refresh__c, Director_Price__c, Material_Name__r.Class__c, Material_Name__r.MRP_Group__c,
                                                    Material_Name__r.Cost_Price_Unit__c, Price_Quote__r.Owner_Business_Unit__c, Floor_Price__c, Material_Name__r.Cost_Formula__c,
                                                    Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Requested_Pricing__r.Parent_Contract_Name__c, Total_Price_Per_Each__c,
                                                    Sales_Deal__r.Pricing_Tier__c, Requested_Pricing__r.Description__c, Material_Name__r.VP_Price__c, Price_Quote__r.BusinessUnit__c, Price_Per_Each__c
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c=: pqUs2.Id
                                                    ORDER BY Row_Order__c NULLS LAST];
			*/
            //System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            //System.debug('*** lineItems *** ' + lineItems);

			PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);

            pqt.doUpdateOwnerValue();
            String exclusionType = pqt.exclusionType;
            System.assertEquals('ZB01', pqt.exclusionType);
            
            Boolean userApp = pqt.userApprovalLevel;
            Boolean needApproval = pqt.needsApproval;
            Boolean isApprover = pqt.isApprover;
            Boolean hasCross = pqt.hasCrossRef;
            System.assertEquals(false, userApp);
            System.assertEquals(false, needApproval);
            System.assertEquals(false, isApprover);
            System.assertEquals(false, hasCross);
            
            pqt.bulkrefresh();
            pqt.setBuHeader('Anesthesia');
            /*
            pqt.getFormatEligiblePrices(lineItems);
            pqt.getFormatListPrices(lineItems);
            pqt.getFormatLinePrices(lineItems);
            pqt.getFormatRsmPrices(lineItems);
            pqt.getFormatRepPrices(lineItems);
            pqt.getFormatSalesPrices(lineItems);
            pqt.getFormatTotalPrices(pqUs2.Id);
			*/
            pqt.blankRow();
            pqt.Approve();
            pqt.recall2();
            pqt.Approve();
            PP_Price_Quote.recall(pqUs.Id);
            Test.stopTest();
        }//end of system run

	}//end of priceQuoteTest8 test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void priceQuoteTest9() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman08', 'User08', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US09', 'User09', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US10', 'User10', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;

        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser1){
            Test.startTest();
            Sales_Condition_Mapping__c conMap1 = new Sales_Condition_Mapping__c(
                name = 'ND', Mapped_Value__c = 'XNAF'
            );
            insert conMap1;
            
            Sales_Condition_Mapping__c conMap2 = new Sales_Condition_Mapping__c(
                name = 'PR', Mapped_Value__c = 'XPRI'
            );
            insert conMap2;
            
            Sales_Condition_Mapping__c conMap3 = new Sales_Condition_Mapping__c(
                name = 'SE', Mapped_Value__c = 'XSEC'
            );
            insert conMap3;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser1.Name, usUser1.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            Account usAcc = testDataFactoryPP.createAccount('TestAcount US', 'US60','999999','17');
            insert usACC;
            
            Account usAcc1 = testDataFactoryPP.createAccount('TestAcount US1', 'US60','100002','17');
            insert usAcc1;
            
            //create Account with no SAP Code
            /*
            Account noSap = new Account(Name = 'No Sap Code',Account_Group__c = 'Z002',Customer_Group__c = '17',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
			*/
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            insert con2;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            insert usProd3;
			update usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            //Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            //insert cp;
            
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US60');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US60');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US60');
            insert ch4;
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009068', 'GPO-999','D','US60');
            insert ch5;
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
             
            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterial(ch5.Id, ch5.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm5;
            
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
             
            Contract_Customer__c cc5 = testDataFactoryPP.createContractCustomer(ch5.Id, ch5.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc5;
            
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            List<Price_Quote_Line_Item__c> pqliList = new List<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            pqliList.add(pqliUs);
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            pqliList.add(pqliUs1);
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            pqliList.add(pqliUs2);
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            pqliList.add(pqliUs3);
            
            Database.insert(pqliList,false);

            //PQ after line item insert
            Price_Quote__c pqUs2 = [Select Id, Name, Opportunity__r.Name, Opportunity__c, Price_Quote_Name__c, Status__c, Shipping__c, Product_Class_Count__c, Discounted_Total__c,
                                     Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Tax__c, Current_Approver__c, Account_Name__r.Price_List_Type__c,
                                     Internal_Comments_Only__c, Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity,
                                     Account_Name__r.BillingState, Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c, Account_Name__r.ERP_Active__c,
                                     Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c, Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Stationary__c, Discount_Type__c,
                                     Owner_Cell__c, Owner_Phone__c, Owner_Approval_Role__c, Workflow_Owner_Approval_Level__c, Courtesy_Pricing__c, Courtesy_Pricing_Type__c, Quote_Template__c, Discount__c,
                                     Owner_Email__c, Contact_Name__r.Name, Business_Unit__c, Contact_Name__r.id, Contact_Name__r.Phone, Contact_Name__r.Email, LastModifiedById,
                                     CreatedById, InApproval__c, Territory__r.Territory_Name__c, Territory__r.Territory_Number__c,Approval_Flag_Rollup__c, CurrencyIsoCode, How_Created__c,
                                     Owner_Business_Unit__c, Sales_Org_Key__c,Line_Count__c,One_Time_Purchase__c,PRF__c, IsActive__c, Opportunity_Closed__c, Account_Name__r.Customer_Group__c,
                                     RsmRepToggle__c, BusinessUnit__c, OwnerId, Owner.Name, Type__c, Account_Name__r.Exclusion_Type__c,
                                     (SELECT Id, Name,Quantity__c, Price_Quote__r.BusinessUnit__c FROM Price_Quote_Line_Items__r)
                                     FROM Price_Quote__c WHERE id = :pqUs.Id];
            System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Price_Quote_Line_Item__c> lineItems = [Select id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c, Objective_Name__c,Requested_Pricing__r.Agreement_Number__c,
                                                    Objective__c,Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Brand__c, Approval_Flag_Reason__c,
                                                    Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c,Sales_Deal__r.Agreement_Number__c,
                                                    Product_Description__c, Material_Name__r.Cost__c,Sales_deal_Description__c, Sales_Number__c,Material_Name__r.List_Price__c,
                                                    Row_Order__c, Competetive_Product__r.Competitor_Product_Code__c, Material_Name__r.Name, Cost__c, Requested_Pricing__c, Requested_Price__c,
                                                    Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Description__c, Material_Name__r.Director_Price__c, Requested_Pricing_CM__c,
                                                    Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Floor_Price__c, Material_Name__r.SubGroup__c,
                                                    Line_Price__c, Material_Name__r.Transfer_Price__c, Material_Status_Description__c, IsBold__c, Price_Quote__r.Account_Name__r.Price_List_Type__c,
                                                    Approval_Flag_Checkbox__c, Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c,Material_Name_Text__c,
                                                    Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c, MRP_Group__c,
                                                    Owner_Approval_Level__c, Approval_Level__c, Refresh__c, Director_Price__c, Material_Name__r.Class__c, Material_Name__r.MRP_Group__c,
                                                    Material_Name__r.Cost_Price_Unit__c, Price_Quote__r.Owner_Business_Unit__c, Floor_Price__c, Material_Name__r.Cost_Formula__c,
                                                    Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Requested_Pricing__r.Parent_Contract_Name__c, Total_Price_Per_Each__c,
                                                    Sales_Deal__r.Pricing_Tier__c, Requested_Pricing__r.Description__c, Material_Name__r.VP_Price__c, Price_Quote__r.BusinessUnit__c, Price_Per_Each__c
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c=: pqUs2.Id
                                                    ORDER BY Row_Order__c NULLS LAST];
            System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            System.debug('*** lineItems *** ' + lineItems);

			PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs2.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs2);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);

            pqt.doUpdateOwnerValue();
            String exclusionType = pqt.exclusionType;
            System.assertEquals('ZB01', pqt.exclusionType);
            
            Boolean userApp = pqt.userApprovalLevel;
            Boolean needApproval = pqt.needsApproval;
            Boolean isApprover = pqt.isApprover;
            Boolean hasCross = pqt.hasCrossRef;
            System.assertEquals(false, userApp);
            System.assertEquals(false, needApproval);
            System.assertEquals(false, isApprover);
            System.assertEquals(false, hasCross);
            
            pqt.bulkrefresh();
            pqt.setBuHeader('Anesthesia');
            pqt.getFormatEligiblePrices(lineItems);
            pqt.getFormatListPrices(lineItems);
            pqt.getFormatLinePrices(lineItems);
            pqt.getFormatRsmPrices(lineItems);
            pqt.getFormatRepPrices(lineItems);
            pqt.getFormatSalesPrices(lineItems);
            pqt.getFormatTotalPrices(pqUs2.Id);
            pqt.blankRow();
            pqt.Approve();
            pqt.recall2();
            pqt.Approve();
            PP_Price_Quote.recall(pqUs2.Id);
            Test.stopTest();
        }//end of system run

	}//end of priceQuoteTest9 test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void priceQuoteTest10() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman3', 'User3', 'Sales Manager', 'Anesthesia');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US3', 'User3', 'Sales Rep', 'Anesthesia');
        insert usUser;
        
        User usUser1 = testDataFactoryPP.createUser('US4', 'User4', 'Sales Rep', 'Anesthesia');
        insert usUser1;
        usUser1.ManagerId = usUserMan.Id;
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        usUser1.UserRoleId = roleId;
        update usUser1;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        usUser.ManagerId = usUserMan.Id;
        update usUser;

        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);

		System.runAs(usUser1){
            Test.startTest();
            Sales_Condition_Mapping__c conMap1 = new Sales_Condition_Mapping__c(
                name = 'ND', Mapped_Value__c = 'XNAF'
            );
            insert conMap1;
            
            Sales_Condition_Mapping__c conMap2 = new Sales_Condition_Mapping__c(
                name = 'PR', Mapped_Value__c = 'XPRI'
            );
            insert conMap2;
            
            Sales_Condition_Mapping__c conMap3 = new Sales_Condition_Mapping__c(
                name = 'SE', Mapped_Value__c = 'XSEC'
            );
            insert conMap3;
            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser1.Name, usUser1.Id, 'US - Teleflex', 'US6010', 4);
            ppUsers.add(cuUs);
            
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            
            //create Account with no SAP Code
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '03',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            insert usAcc;
            
            Account usAcc1 = new Account(Name = 'No Sap Code1',Account_Group__c = 'Z001',Customer_Group__c = '03',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
            );
            insert usAcc1;
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            insert con1;
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            insert con2;
            
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '10', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            insert usProd;
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '10', '40');
            insert usProd1;
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            update usProd1;
            
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '10', '40');
            insert usProd2;
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            update usProd2;
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '10', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            insert usProd3;
			update usProd3;
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            insert usCrossProd;
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            insert usCrossProd1;
            
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            insert usCrossProd2;
            
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            insert usCrossProd3;
            
            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            //Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            //insert cp;
            
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
            insert ch1;
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US60');
            insert ch2;
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US60');
            insert ch3;
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US60');
            insert ch4;
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('5009068', 'GPO-999','D','US60');
            insert ch5;
            
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            insert cm1;
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm2;
            
            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterial(ch5.Id, ch5.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            insert cm5;

            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc1;
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc2;
            
            Contract_Customer__c cc5 = testDataFactoryPP.createContractCustomer(ch5.Id, ch5.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            insert cc5;
            
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6010', false, 'Anesthesia');
            insert pqUS;
            pqUS.OwnerId = usUser1.Id;
            update pqUS;
            
            //set language for PQ
            pqUs.Language__c = 'English';
            update pqUs;

            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            List<Price_Quote_Line_Item__c> pqliList = new List<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            pqliList.add(pqliUs);
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            pqliList.add(pqliUs1);
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            pqliList.add(pqliUs2);
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            pqliList.add(pqliUs3);
            
            Database.insert(pqliList,false);

            //PQ after line item insert
            Price_Quote__c pqUs2 = [Select Id, Name, Opportunity__r.Name, Opportunity__c, Price_Quote_Name__c, Status__c, Shipping__c, Product_Class_Count__c, Discounted_Total__c,
                                     Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Tax__c, Current_Approver__c, Account_Name__r.Price_List_Type__c,
                                     Internal_Comments_Only__c, Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity,
                                     Account_Name__r.BillingState, Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c, Account_Name__r.ERP_Active__c,
                                     Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c, Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Stationary__c, Discount_Type__c,
                                     Owner_Cell__c, Owner_Phone__c, Owner_Approval_Role__c, Workflow_Owner_Approval_Level__c, Courtesy_Pricing__c, Courtesy_Pricing_Type__c, Quote_Template__c, Discount__c,
                                     Owner_Email__c, Contact_Name__r.Name, Business_Unit__c, Contact_Name__r.id, Contact_Name__r.Phone, Contact_Name__r.Email, LastModifiedById,
                                     CreatedById, InApproval__c, Territory__r.Territory_Name__c, Territory__r.Territory_Number__c,Approval_Flag_Rollup__c, CurrencyIsoCode, How_Created__c,
                                     Owner_Business_Unit__c, Sales_Org_Key__c,Line_Count__c,One_Time_Purchase__c,PRF__c, IsActive__c, Opportunity_Closed__c, Account_Name__r.Customer_Group__c,
                                     RsmRepToggle__c, BusinessUnit__c, OwnerId, Owner.Name, Type__c, Account_Name__r.Exclusion_Type__c,
                                     (SELECT Id, Name,Quantity__c, Price_Quote__r.BusinessUnit__c FROM Price_Quote_Line_Items__r)
                                     FROM Price_Quote__c WHERE id = :pqUs.Id];
            System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Price_Quote_Line_Item__c> lineItems = [Select id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c, Objective_Name__c,Requested_Pricing__r.Agreement_Number__c,
                                                    Objective__c,Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Brand__c, Approval_Flag_Reason__c,
                                                    Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c,Sales_Deal__r.Agreement_Number__c,
                                                    Product_Description__c, Material_Name__r.Cost__c,Sales_deal_Description__c, Sales_Number__c,Material_Name__r.List_Price__c,
                                                    Row_Order__c, Competetive_Product__r.Competitor_Product_Code__c, Material_Name__r.Name, Cost__c, Requested_Pricing__c, Requested_Price__c,
                                                    Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Description__c, Material_Name__r.Director_Price__c, Requested_Pricing_CM__c,
                                                    Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Floor_Price__c, Material_Name__r.SubGroup__c,
                                                    Line_Price__c, Material_Name__r.Transfer_Price__c, Material_Status_Description__c, IsBold__c, Price_Quote__r.Account_Name__r.Price_List_Type__c,
                                                    Approval_Flag_Checkbox__c, Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c,Material_Name_Text__c,
                                                    Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c, MRP_Group__c,
                                                    Owner_Approval_Level__c, Approval_Level__c, Refresh__c, Director_Price__c, Material_Name__r.Class__c, Material_Name__r.MRP_Group__c,
                                                    Material_Name__r.Cost_Price_Unit__c, Price_Quote__r.Owner_Business_Unit__c, Floor_Price__c, Material_Name__r.Cost_Formula__c,
                                                    Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Requested_Pricing__r.Parent_Contract_Name__c, Total_Price_Per_Each__c,
                                                    Sales_Deal__r.Pricing_Tier__c, Requested_Pricing__r.Description__c, Material_Name__r.VP_Price__c, Price_Quote__r.BusinessUnit__c, Price_Per_Each__c
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c=: pqUs2.Id
                                                    ORDER BY Row_Order__c NULLS LAST];
            System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            System.debug('*** lineItems *** ' + lineItems);

			PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs2.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs2);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);

            pqt.doUpdateOwnerValue();
               
            Boolean userApp = pqt.userApprovalLevel;
            Boolean needApproval = pqt.needsApproval;
            Boolean isApprover = pqt.isApprover;
            Boolean hasCross = pqt.hasCrossRef;
            System.assertEquals(false, userApp);
            System.assertEquals(false, needApproval);
            System.assertEquals(false, isApprover);
            System.assertEquals(false, hasCross);
            
            pqt.bulkrefresh();
            pqt.setBuHeader('Anesthesia');
            pqt.getFormatEligiblePrices(lineItems);
            pqt.getFormatListPrices(lineItems);
            pqt.getFormatLinePrices(lineItems);
            pqt.getFormatRsmPrices(lineItems);
            pqt.getFormatRepPrices(lineItems);
            pqt.getFormatSalesPrices(lineItems);
            pqt.getFormatTotalPrices(pqUs2.Id);
            pqt.blankRow();
            pqt.Approve();
            pqt.recall2();
            pqt.Approve();
            PP_Price_Quote.recall(pqUs2.Id);
            Test.stopTest();
        }//end of system run

	}//end of priceQuoteTest10 test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
    @isTest static void priceQuoteTest11() {
		/*
		 * Implement test code
		 * create test users
		 * createUser(String firstName, String lastName, String approvalRole, String bu)
		 * Approval Role values: (Sales Rep, Sales Manager, Sales Director, Sales VP, Contracts, Marketing, Marketing Manager, Marketing Director, Marketing VP)
		 * bu values: (Alternate Care, Anesthesia, Canada, Interventional Capital, Commercial Operations, EMS, Interventional, Latin America, Respiratory, Surgical,
		 * Surgical Disposables, Surgical Instruments, Urology, Vascular, Customer Service)
		*/
        
        //Create Test manager user for approval process testing
        User usUserMan = testDataFactoryPP.createUser('USman111', 'User111', 'Sales Manager', 'Latin America');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US11', 'User11', 'Sales Rep', 'Latin America');
        usUser.ManagerId = usUserMan.Id;
        insert usUser;
        
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;

        User usUser1 = testDataFactoryPP.createUser('US22', 'User22', 'Sales Rep', 'Latin America');
        usUser1.ManagerId = usUserMan.Id;
        usUser1.UserRoleId = roleId;
        insert usUser1;
        //usUser1.ManagerId = usUserMan.Id;
        //String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;
        //usUser1.UserRoleId = roleId;
        //update usUser1;
        
        //usUser = (Id = usUser.Id, ManagerId = usUserMan.Id);
        //usUser.ManagerId = usUserMan.Id;
        //update usUser;

        //Create Public groups for Contract Sharing
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
		System.runAs(usUser1){
            List<Sales_Condition_Mapping__c> scmList = new List<Sales_Condition_Mapping__c>();
            
            Sales_Condition_Mapping__c conMap1 = new Sales_Condition_Mapping__c(
                name = 'ND', Mapped_Value__c = 'XNAF'
            );
            //insert conMap1;
            scmList.add(conMap1);
            
            Sales_Condition_Mapping__c conMap2 = new Sales_Condition_Mapping__c(
                name = 'PR', Mapped_Value__c = 'XPRI'
            );
            //insert conMap2;
            scmList.add(conMap2);
            
            Sales_Condition_Mapping__c conMap3 = new Sales_Condition_Mapping__c(
                name = 'SE', Mapped_Value__c = 'XSEC'
            );
            //nsert conMap3;
            scmList.add(conMap3);
            
            insert scmList;

            
            //Setup Pricing Portal User records
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            //createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser1.Name, usUser1.Id, 'LA - Latin America', 'US6020', 4);
            ppUsers.add(cuUs);
            database.insert(ppUsers,FALSE);
            
            //Setup Pricing Portal Account records
            List<Account> ppAccs = new List<Account>();
            //createAccount(String accName, String salesOrg, String sapCode, String custGrp )
            
            //create Account with no SAP Code
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '03',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
            );
            //insert usAcc;
            ppAccs.add(usAcc);

            Account usAcc1 = new Account(Name = 'No Sap Code1',Account_Group__c = 'Z001',Customer_Group__c = '03',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
            );
            //insert usAcc1;
            ppAccs.add(usAcc1);
            
            insert ppAccs;
            
            //Setup Pricing Portal Contact records
            //createContact(String firstName, String lastName, Id accId)
            List<Contact> consList = new List<Contact>();
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            //ppCons.add(con1);
            //insert con1;
            consList.add(con1);
            
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            //insert con2;
            consList.add(con2);
           
            insert consList;
            
            
            List<Product2> prodList = new List<Product2>();
            //Setup product data
            //createProduct(String prodName, String salesOrg, String distChan, String matStatus)
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '20', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            //insert usProd;
            prodList.add(usProd);
            
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '20', '40');
            //insert usProd1;
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            //insert usProd1;
            //update usProd1;
            prodList.add(usProd1);

            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '20', '40');
            //insert usProd2;
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            //insert usProd2;
            //update usProd2;
            prodList.add(usProd2);
            
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '20', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            //insert usProd3;
			//update usProd3;
            prodList.add(usProd3);
            
            insert prodList;
            
            
            List<Cross_Reference__c> crList = new List<Cross_Reference__c>();
            
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            //insert usCrossProd;
            crList.add(usCrossProd);
            
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            //insert usCrossProd1;
            crList.add(usCrossProd1);

            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            //insert usCrossProd2;
            crList.add(usCrossProd2);

            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            //insert usCrossProd3;
            crList.add(usCrossProd3);
            
            insert crList;

            //Setup Contract Partnerships between Accounts
            //createContractPartnership(String saleTo, String shipTo)
            //Contract_Partnership__c cp = testDataFactoryPP.createContractPartnership('100002','100001');
            //insert cp;
            
            List<Contract_Header__c> chList = new List<Contract_Header__c>();
            //Setup Contract Headers
            //createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg)
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
            //insert ch1;
            chList.add(ch1);
            
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US60');
            //insert ch2;
            chList.add(ch2);
            
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US60');
            //insert ch3;
            chList.add(ch3);
            
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US60');
            //insert ch4;
            chList.add(ch4);
            
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009068', 'GPO-999','D','US60');
            //insert ch5;
            chList.add(ch5);
            
            insert chList;

            
            List<Contract_Material__c> cmList = new List<Contract_Material__c>();
            //Setup Contract Materials
            //createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, String prodId, String salesOrg, String div, String distChannel)
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            //insert cm1;
            cmList.add(cm1);
            
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            //insert cm2;
            cmList.add(cm2);
            
            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterial(ch5.Id, ch5.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            //insert cm5;
            cmList.add(cm5);

            insert cmList;
            
            
            List<Contract_Customer__c> ccList = new List<Contract_Customer__c>();
            //Setup Contract Customers
            //createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, String accId, String sapCode, String distChannel)
            Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            //insert cc1;
            ccList.add(cc1);
            
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            //insert cc2;
            ccList.add(cc2);
            
            Contract_Customer__c cc5 = testDataFactoryPP.createContractCustomer(ch5.Id, ch5.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            //insert cc5;
            ccList.add(cc5);

            insert ccList;
            
            
            //Setup PQ data
            //createPriceQuote(String accId, String conId, String salesOrgKey, Boolean oneTime, String bu)
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6020', false, 'Latin America');
            pqUS.OwnerId = usUser1.Id;
            pqUs.Language__c = 'English';
            insert pqUS;
            //update pqUS;
            
            //set language for PQ
            //update pqUs;

            
            
            //Setup PQ Line Item data
            //createPriceQLineItem(String pqId,String prodId,String crId)
            List<Price_Quote_Line_Item__c> pqliList = new List<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            pqliList.add(pqliUs);
			
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            pqliList.add(pqliUs1);
            
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            pqliList.add(pqliUs2);
            
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            pqliList.add(pqliUs3);
            
            Database.insert(pqliList,false);
            
            //PQ after line item insert
            Price_Quote__c pqUs2 = [Select Id, Name, Opportunity__r.Name, Opportunity__c, Price_Quote_Name__c, Status__c, Shipping__c, Product_Class_Count__c, Discounted_Total__c,
                                     Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Tax__c, Current_Approver__c, Account_Name__r.Price_List_Type__c,
                                     Internal_Comments_Only__c, Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity,
                                     Account_Name__r.BillingState, Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c, Account_Name__r.ERP_Active__c,
                                     Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c, Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Stationary__c, Discount_Type__c,
                                     Owner_Cell__c, Owner_Phone__c, Owner_Approval_Role__c, Workflow_Owner_Approval_Level__c, Courtesy_Pricing__c, Courtesy_Pricing_Type__c, Quote_Template__c, Discount__c,
                                     Owner_Email__c, Contact_Name__r.Name, Business_Unit__c, Contact_Name__r.id, Contact_Name__r.Phone, Contact_Name__r.Email, LastModifiedById,
                                     CreatedById, InApproval__c, Territory__r.Territory_Name__c, Territory__r.Territory_Number__c,Approval_Flag_Rollup__c, CurrencyIsoCode, How_Created__c,
                                     Owner_Business_Unit__c, Sales_Org_Key__c,Line_Count__c,One_Time_Purchase__c,PRF__c, IsActive__c, Opportunity_Closed__c, Account_Name__r.Customer_Group__c,
                                     RsmRepToggle__c, BusinessUnit__c, OwnerId, Owner.Name, Type__c, Account_Name__r.Exclusion_Type__c,
                                     (SELECT Id, Name,Quantity__c, Price_Quote__r.BusinessUnit__c FROM Price_Quote_Line_Items__r)
                                     FROM Price_Quote__c WHERE id = :pqUs.Id];
            System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            System.assertEquals(4.0, pqUs2.Line_count__c);
            
            List<Price_Quote_Line_Item__c> lineItems = [Select id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c, Objective_Name__c,Requested_Pricing__r.Agreement_Number__c,
                                                    Objective__c,Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Brand__c, Approval_Flag_Reason__c,
                                                    Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c,Sales_Deal__r.Agreement_Number__c,
                                                    Product_Description__c, Material_Name__r.Cost__c,Sales_deal_Description__c, Sales_Number__c,Material_Name__r.List_Price__c,
                                                    Row_Order__c, Competetive_Product__r.Competitor_Product_Code__c, Material_Name__r.Name, Cost__c, Requested_Pricing__c, Requested_Price__c,
                                                    Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Description__c, Material_Name__r.Director_Price__c, Requested_Pricing_CM__c,
                                                    Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Floor_Price__c, Material_Name__r.SubGroup__c,
                                                    Line_Price__c, Material_Name__r.Transfer_Price__c, Material_Status_Description__c, IsBold__c, Price_Quote__r.Account_Name__r.Price_List_Type__c,
                                                    Approval_Flag_Checkbox__c, Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c,Material_Name_Text__c,
                                                    Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c, MRP_Group__c,
                                                    Owner_Approval_Level__c, Approval_Level__c, Refresh__c, Director_Price__c, Material_Name__r.Class__c, Material_Name__r.MRP_Group__c,
                                                    Material_Name__r.Cost_Price_Unit__c, Price_Quote__r.Owner_Business_Unit__c, Floor_Price__c, Material_Name__r.Cost_Formula__c,
                                                    Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Requested_Pricing__r.Parent_Contract_Name__c, Total_Price_Per_Each__c,
                                                    Sales_Deal__r.Pricing_Tier__c, Requested_Pricing__r.Description__c, Material_Name__r.VP_Price__c, Price_Quote__r.BusinessUnit__c, Price_Per_Each__c
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c=: pqUs2.Id
                                                    ORDER BY Row_Order__c NULLS LAST];
            System.debug('*** pqUs2.Line_count__c first *** ' + pqUs2.Line_count__c);
            System.debug('*** lineItems *** ' + lineItems);

			PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs2.Id);
            system.debug('Price Quote Page' + pageRefpre);
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs2);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            Test.startTest();
            pqt.doUpdateOwnerValue();
               
            Boolean userApp = pqt.userApprovalLevel;
            Boolean needApproval = pqt.needsApproval;
            Boolean isApprover = pqt.isApprover;
            Boolean hasCross = pqt.hasCrossRef;
            System.assertEquals(false, userApp);
            System.assertEquals(false, needApproval);
            System.assertEquals(false, isApprover);
            System.assertEquals(false, hasCross);
            
            pqt.bulkrefresh();
            pqt.setBuHeader('Latin America');
            pqt.getFormatEligiblePrices(lineItems);
            pqt.getFormatListPrices(lineItems);
            pqt.getFormatLinePrices(lineItems);
            pqt.getFormatRsmPrices(lineItems);
            pqt.getFormatRepPrices(lineItems);
            pqt.getFormatSalesPrices(lineItems);
            pqt.getFormatTotalPrices(pqUs2.Id);
            pqt.blankRow();
            pqt.Approve();
            pqt.recall2();
            pqt.Approve();
            PP_Price_Quote.recall(pqUs2.Id);
            Test.stopTest();
        }//end of system run

	}//end of priceQuoteTest11 test method

    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    /*********************************************************************************************************************/
    
	@isTest static void priceQuoteTest12() {
	    User usUserMan = testDataFactoryPP.createUser('USman111', 'User111', 'Sales Manager', 'Latin America');
        insert usUserMan;
        
        //Create US user
		User usUser = testDataFactoryPP.createUser('US11', 'User11', 'Sales Rep', 'Latin America');
        usUser.ManagerId = usUserMan.Id;
        insert usUser;
        
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'Customer Service Rep'].Id;

        User usUser1 = testDataFactoryPP.createUser('US22', 'User22', 'Sales Rep', 'Latin America');
        usUser1.ManagerId = usUserMan.Id;
        usUser1.UserRoleId = roleId;
        insert usUser1;
      
        List<Group> ppPublicGroups = testDataFactoryPP.createPublicGroups();
        database.insert(ppPublicGroups,FALSE);
        
		System.runAs(usUser1){
            List<Sales_Condition_Mapping__c> scmList = new List<Sales_Condition_Mapping__c>();
            
            Sales_Condition_Mapping__c conMap1 = new Sales_Condition_Mapping__c(
                name = 'ND', Mapped_Value__c = 'XNAF'
            );
            scmList.add(conMap1);
            
            Sales_Condition_Mapping__c conMap2 = new Sales_Condition_Mapping__c(
                name = 'PR', Mapped_Value__c = 'XPRI'
            );
            scmList.add(conMap2);
            
            Sales_Condition_Mapping__c conMap3 = new Sales_Condition_Mapping__c(
                name = 'SE', Mapped_Value__c = 'XSEC'
            );
            scmList.add(conMap3);
            
            insert scmList;

            
            List<Contract_User__c> ppUsers = new List<Contract_User__c>();
            Contract_User__c cuUs = testDataFactoryPP.createPricingPortalUser(usUser1.Name, usUser1.Id, 'LA - Latin America', 'US6020', 4);
            ppUsers.add(cuUs);
            database.insert(ppUsers,FALSE);
            
            List<Account> ppAccs = new List<Account>();
            Account usAcc = new Account(Name = 'No Sap Code',Account_Group__c = 'Z001',Customer_Group__c = '03',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
            );
            ppAccs.add(usAcc);
            Account usAcc1 = new Account(Name = 'No Sap Code1',Account_Group__c = 'Z001',Customer_Group__c = '03',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LatAm Customer').getRecordTypeId()
            );
            ppAccs.add(usAcc1);
            
            insert ppAccs;
         
            List<Contact> consList = new List<Contact>();
            Contact con1 = testDataFactoryPP.createContact('US', 'Contact', usAcc.Id);
            consList.add(con1);
            Contact con2 = testDataFactoryPP.createContact('US1', 'Contact1', usAcc1.Id);
            consList.add(con2);
            insert consList;
            
            
            List<Product2> prodList = new List<Product2>();
            Product2 usProd = testDataFactoryPP.createProduct('usProd', 'US60', '20', '40');
            usProd.Alt_Site_List__c = 0.00;
            usProd.Distributor_List__c = 0.00;
            prodList.add(usProd);
            Product2 usProd1 = testDataFactoryPP.createProduct('usProd1', 'US60', '20', '40');
            usProd1.List_Price__c = 0.00;
            usProd1.Alt_Site_List__c = 380.00;
            usProd1.SubGroup__c = 'LMA Atomizers';
            prodList.add(usProd1);
            Product2 usProd2 = testDataFactoryPP.createProduct('usProd2', 'US60', '20', '40');
            usProd2.Alt_Site_List__c = 0.00;
            usProd2.Distributor_List__c = 380.00;
            usProd2.List_Price__c = 0.00;
            usProd2.Description = 'ISO-GARD';
            usProd2.Brand_Name__c = 'Hudson RCI';
            prodList.add(usProd2);
            Product2 usProd3 = testDataFactoryPP.createProduct('usProd3', 'US60', '20', '40');
            usProd3.Distributor_List__c = 380.00;
            usProd3.List_Price__c = 380.00;
            prodList.add(usProd3);
            insert prodList;
            
            
            List<Cross_Reference__c> crList = new List<Cross_Reference__c>();
            Cross_Reference__c usCrossProd = testDataFactoryPP.createCrossRef(usProd.Id);
            crList.add(usCrossProd);
            Cross_Reference__c usCrossProd1 = testDataFactoryPP.createCrossRef(usProd1.Id);
            crList.add(usCrossProd1);
            Cross_Reference__c usCrossProd2 = testDataFactoryPP.createCrossRef(usProd2.Id);
            crList.add(usCrossProd2);
            Cross_Reference__c usCrossProd3 = testDataFactoryPP.createCrossRef(usProd3.Id);
            crList.add(usCrossProd3);
            insert crList;

            List<Contract_Header__c> chList = new List<Contract_Header__c>();
            Contract_Header__c ch1 = testDataFactoryPP.createContractHeader('50009064', '123310','R','US60');
            chList.add(ch1);
            Contract_Header__c ch2 = testDataFactoryPP.createContractHeader('50009065', '123310','R','US60');
            chList.add(ch2);
            Contract_Header__c ch3 = testDataFactoryPP.createContractHeader('50009066', '123310','M','US60');
            chList.add(ch3);
            Contract_Header__c ch4 = testDataFactoryPP.createContractHeader('50009067', '123310','D','US60');
            chList.add(ch4);
            Contract_Header__c ch5 = testDataFactoryPP.createContractHeader('50009068', 'GPO-999','D','US60');
            chList.add(ch5);
            insert chList;

            
            List<Contract_Material__c> cmList = new List<Contract_Material__c>();
            Contract_Material__c cm1 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd.Id, usProd.Sales_Org__c, '10', usProd.Distribution_Channel__c);
            cmList.add(cm1);
            Contract_Material__c cm2 = testDataFactoryPP.createContractMaterial(ch1.Id, ch1.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            cmList.add(cm2);
            Contract_Material__c cm5 = testDataFactoryPP.createContractMaterial(ch5.Id, ch5.Agreement_Number__c, usProd.Name, usProd1.Id, usProd.Sales_Org__c, '20', usProd.Distribution_Channel__c);
            cmList.add(cm5);
            insert cmList;
            
            
            List<Contract_Customer__c> ccList = new List<Contract_Customer__c>();
             Contract_Customer__c cc1 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            ccList.add(cc1);
            Contract_Customer__c cc2 = testDataFactoryPP.createContractCustomer(ch1.Id, ch1.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            ccList.add(cc2);
            Contract_Customer__c cc5 = testDataFactoryPP.createContractCustomer(ch5.Id, ch5.Agreement_Number__c, usAcc.Sales_Org__c, usAcc.Id, usAcc.SAP_Sold_To__c, usAcc.Distribution_Channel__c);
            ccList.add(cc5);
            insert ccList;
            
            Price_Quote__c pqUs = testDataFactoryPP.createPriceQuote(usAcc.Id, con1.Id, 'US6020', false, 'Latin America');
            pqUS.OwnerId = usUser1.Id;
            pqUs.Language__c = 'English';
            pqUs.BusinessUnit__c = 'EMEA';
            //pqUs.Approval_Flag_Rollup__c = 1;
            pqUs.One_Time_Purchase__c = true;
            //pqUs.Material_Status_Check__c = 1;
            insert pqUS;
            
            List<Price_Quote_Line_Item__c> pqliList = new List<Price_Quote_Line_Item__c>();
            Price_Quote_Line_Item__c pqliUs = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd.Id);
            pqliUs.Product_Description__c = 'Trade-in Discount';
            pqliList.add(pqliUs);
            Price_Quote_Line_Item__c pqliUs1 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd1.Id);
            pqliUs1.Product_Description__c = 'Trade-in Discount';
            pqliList.add(pqliUs1);
            Price_Quote_Line_Item__c pqliUs2 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd2.Id);
            pqliUs2.Product_Description__c = 'Trade-in Discount';
            pqliList.add(pqliUs2);
            Price_Quote_Line_Item__c pqliUs3 = testDataFactoryPP.createPriceQLineItem(pqUs.Id, usProd3.Id);
            pqliUs3.Product_Description__c = 'Trade-in Discount';
            pqliList.add(pqliUs3);
            Database.insert(pqliList,false);
            
            Price_Quote__c pqUs2 = [Select Id, Name, Opportunity__r.Name, Opportunity__c, Price_Quote_Name__c, Status__c, Shipping__c, Product_Class_Count__c, Discounted_Total__c,
                                     Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Tax__c, Current_Approver__c, Account_Name__r.Price_List_Type__c,
                                     Internal_Comments_Only__c, Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity,
                                     Account_Name__r.BillingState, Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c, Account_Name__r.ERP_Active__c,
                                     Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c, Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Stationary__c, Discount_Type__c,
                                     Owner_Cell__c, Owner_Phone__c, Owner_Approval_Role__c, Workflow_Owner_Approval_Level__c, Courtesy_Pricing__c, Courtesy_Pricing_Type__c, Quote_Template__c, Discount__c,
                                     Owner_Email__c, Contact_Name__r.Name, Business_Unit__c, Contact_Name__r.id, Contact_Name__r.Phone, Contact_Name__r.Email, LastModifiedById,
                                     CreatedById, InApproval__c, Territory__r.Territory_Name__c, Territory__r.Territory_Number__c,Approval_Flag_Rollup__c, CurrencyIsoCode, How_Created__c,
                                     Owner_Business_Unit__c, Sales_Org_Key__c,Line_Count__c,One_Time_Purchase__c,PRF__c, IsActive__c, Opportunity_Closed__c, Account_Name__r.Customer_Group__c,
                                     RsmRepToggle__c, BusinessUnit__c, OwnerId, Owner.Name, Type__c, Account_Name__r.Exclusion_Type__c,
                                     (SELECT Id, Name,Quantity__c, Price_Quote__r.BusinessUnit__c FROM Price_Quote_Line_Items__r)
                                     FROM Price_Quote__c WHERE id = :pqUs.Id];
            
            List<Price_Quote_Line_Item__c> lineItems = [Select id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c, Objective_Name__c,Requested_Pricing__r.Agreement_Number__c,
                                                    Objective__c,Material_Name__r.Qty_Sales_Unit__c, Material_Name__r.Brand__c, Approval_Flag_Reason__c,
                                                    Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c,Sales_Deal__r.Agreement_Number__c,
                                                    Product_Description__c, Material_Name__r.Cost__c,Sales_deal_Description__c, Sales_Number__c,Material_Name__r.List_Price__c,
                                                    Row_Order__c, Competetive_Product__r.Competitor_Product_Code__c, Material_Name__r.Name, Cost__c, Requested_Pricing__c, Requested_Price__c,
                                                    Material_Name__r.SBU__c, Material_Name__r.Brand_Name__c, Description__c, Material_Name__r.Director_Price__c, Requested_Pricing_CM__c,
                                                    Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Rep_Price__c, List_Price__c, Material_Name__r.Floor_Price__c, Material_Name__r.SubGroup__c,
                                                    Line_Price__c, Material_Name__r.Transfer_Price__c, Material_Status_Description__c, IsBold__c, Price_Quote__r.Account_Name__r.Price_List_Type__c,
                                                    Approval_Flag_Checkbox__c, Material_Name__r.Sales_Org__c, Material_Name__r.Distribution_Channel__c,Material_Name_Text__c,
                                                    Material_Name__r.Last_Year_ASP__c, Material_Name__r.Last_Year_Sales__c, Material_Name__r.Distributor_List__c, MRP_Group__c,
                                                    Owner_Approval_Level__c, Approval_Level__c, Refresh__c, Director_Price__c, Material_Name__r.Class__c, Material_Name__r.MRP_Group__c,
                                                    Material_Name__r.Cost_Price_Unit__c, Price_Quote__r.Owner_Business_Unit__c, Floor_Price__c, Material_Name__r.Cost_Formula__c,
                                                    Requested_Pricing_Description__c, Sales_Deal__r.Parent_Contract_Name__c, Requested_Pricing__r.Parent_Contract_Name__c, Total_Price_Per_Each__c,
                                                    Sales_Deal__r.Pricing_Tier__c, Requested_Pricing__r.Description__c, Material_Name__r.VP_Price__c, Price_Quote__r.BusinessUnit__c, Price_Per_Each__c
                                                    FROM Price_Quote_Line_Item__c
                                                    WHERE Price_Quote__c=: pqUs2.Id
                                                    ORDER BY Row_Order__c NULLS LAST];

            
            String key = '1-'+lineItems[0].Material_Name_Text__c;
            PP_Pricing_Tiers.tiers newTier = new PP_Pricing_Tiers.tiers();
			newTier.Name = cm1.Agreement_Number_Text__c; // Agreement Number
            newTier.chId = cm1.Agreement__c; // Contract Header ID
            newTier.chDesc = cm1.Agreement__r.Description__c; // Contract Description
            newTier.cmId = cm1.Id; // Contract Material ID
            newTier.TierLevel = cm1.Level__c; // 1,2,3
            newTier.TierName = cm1.Tier_Level_Name__c + string.valueOf(1); // REP1, RSM2, etc.
            newTier.Price = cm1.Price__c; // Price
            newTier.Product_Name = cm1.Material_Name__c;
            newTier.chKey = cm1.Agreement__r.Parent_Contract_Name__c; // Name of the Contract minus the level (-R1, -R2, -M1, etc.)
            
            map<String, PP_Pricing_Tiers.tiers> tierMap = new map<String, PP_Pricing_Tiers.tiers>();
            tierMap.put(key, newTier);
            
            Boolean testBoolean = true;
            String testString = '';
            
            Test.startTest();
            
            PageReference pageRefpre = new PageReference('/apex/PP_Price_Quote?pqid=' + pqUs2.Id + '&trId=' +lineItems[0].Id);
            //system.debug('Price Quote Page' + pageRefpre);
            //System.currentPageReference().getParameters().put('pqid', pqUs2.Id); 
            //System.currentPageReference().getParameters().put('trId', lineItems[0].Id); 
            System.currentPageReference().getParameters().put('tierLevel', '1'); 
            System.currentPageReference().getParameters().put('key', key); 
            System.currentPageReference().getParameters().put('lineId', lineItems[0].Id); 
            Test.setCurrentPage(pageRefpre);
            
            ApexPages.StandardController ctlr = new ApexPages.StandardController(pqUs2);
            PP_Price_Quote pqt = new PP_Price_Quote(ctlr);
            pqt.tierMap = tierMap;
          
            testString = pqt.userLang;
            testBoolean = pqt.disableButton;
            testBoolean = pqt.subButton;
            testBoolean = pqt.comButton;
            testBoolean = pqt.prfButton;
            testBoolean = pqt.reviseButton;
            testString = pqt.wrkId;
            pqt.checkRollupSummaryValue();
            pqt.massUpdateTiers();
            pqt.updateTierPrice();
            pqt.editpq();
            pqt.printpq();
            pqt.getActiveQuoteIdStr();
            pqt.saveRecord();
            pqt.saveOneTime();
            pqt.updateRSMprice();
            pqt.updateRepPrice();
            pqt.updateListPrice();
            pqt.updateEligiblePrice();
            pqt.massUpdList();
            pqt.massUpdRSM();
            pqt.massUpdRep();
            pqt.massUpdEligible();
            pqt.sapPrice();
            pqt.cardiacFavorites();
            pqt.cardiacFavorites700();
            pqt.vascularBundlesWithUltra4yr();
            pqt.vascularBundlesWithUltra2yr();
            pqt.vascularBundlesWithoutUltra4yr();
            pqt.vascularBundlesWithoutUltra2yr();
            pqt.vascularBundlesDlxProbe4yr();
            pqt.vascularBundlesDlxProbe2yr();
            pqt.vascularBundlesRhythm3yr();
            pqt.vascularBundlesRhythm1yr();
            pqt.vascularBundlesRhythmRefurb3yr();
            pqt.vascularBundlesRhythmRefurb1yr();
            pqt.vascularBundlesG42yr();
            pqt.vascularBundlesG4refurb2yr();
            pqt.vascularTradeIn();
            pqt.doCloning();
            pqt.updateFlag();
            pqt.Refresh();
            pqt.fixString();
            pqt.newCreateOpp();
            pqt.makeActivePQ();
            pqt.getMargins(lineItems);
            pqt.AutoApprove();
            PP_Price_Quote.updateQuantity(lineItems[0].Id, 10);
            PP_Price_Quote.updatePrice(lineItems[0].Id, 10);
            PP_Price_Quote.updateOrder(lineItems[0].Id, 1);
            
            /*pqt.doUpdateOwnerValue();
               
            Boolean userApp = pqt.userApprovalLevel;
            Boolean needApproval = pqt.needsApproval;
            Boolean isApprover = pqt.isApprover;
            Boolean hasCross = pqt.hasCrossRef;
            System.assertEquals(false, userApp);
            System.assertEquals(false, needApproval);
            System.assertEquals(false, isApprover);
            System.assertEquals(false, hasCross);
            
            pqt.bulkrefresh();
            pqt.setBuHeader('Latin America');
            pqt.getFormatEligiblePrices(lineItems);
            pqt.getFormatListPrices(lineItems);
            pqt.getFormatLinePrices(lineItems);
            pqt.getFormatRsmPrices(lineItems);
            pqt.getFormatRepPrices(lineItems);
            pqt.getFormatSalesPrices(lineItems);
            pqt.getFormatTotalPrices(pqUs2.Id);
            pqt.blankRow();
            pqt.Approve();
            pqt.recall2();
            pqt.Approve();
            PP_Price_Quote.recall(pqUs2.Id);*/
            
            Test.stopTest();
        }

	}
    
}//end of PP_Price_Quote_Test class