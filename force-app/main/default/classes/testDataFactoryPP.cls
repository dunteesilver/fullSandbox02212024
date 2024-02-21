@isTest
public class testDataFactoryPP {
    
    public static User createUser(String firstName, String lastName, String approvalRole, String bu){
        Profile p = [select id from profile where name='System Administrator' LIMIT 1];
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name LIKE '%Global%' LIMIT 1].Id;
        String fn = firstname.left(2);
        string ln = lastname.left(2);
        User testUser = new User(
            alias = fn+ln,email= firstName+lastName+'@unittest.teleflex.com',
            emailencodingkey = 'UTF-8',firstname = firstName,
            lastname = lastName, languagelocalekey='en_US',
            localesidkey='en_US',profileid = p.Id,
            timezonesidkey='America/New_York',
            username = firstName+lastName+'@unittest.teleflex.com',
            Business_Unit__c = bu,
            Approval_Role__c = 'Sales Rep',
            UserRoleId = roleId
        );
        
        return testUser;
    }
    
    public static User createUserMan(String firstName, String lastName, String approvalRole, String bu, String managerId){
        Profile p = [select id from profile where name='System Administrator' LIMIT 1];
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name LIKE '%Global%' LIMIT 1].Id;
        String fn = firstname.left(2);
        string ln = lastname.left(2);
        User testUser = new User(
            alias = fn+ln,email= firstName+lastName+'@unittest.teleflex.com',
            emailencodingkey = 'UTF-8',firstname = firstName,
            lastname = lastName, languagelocalekey='en_US',
            localesidkey='en_US',profileid = p.Id,
            timezonesidkey='America/New_York',
            username = firstName+lastName+'@unittest.teleflex.com',
            Business_Unit__c = bu,
            Approval_Role__c = 'Sales Rep',
            UserRoleId = roleId,
            ManagerId = managerId
        );
        
        return testUser;
    }
    
    public static User createUserAu(String firstName, String lastName, String approvalRole, String bu){
        Profile p = [select id from profile where name='System Administrator' LIMIT 1];
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name LIKE '%Global%' LIMIT 1].Id;
        String fn = firstname.left(2);
        string ln = lastname.left(2);
        User testUser = new User(
            alias = fn+ln,email= firstName+lastName+'@unittest.teleflex.com',
            emailencodingkey = 'UTF-8',firstname = firstName,
            lastname = lastName, languagelocalekey='en_US',
            localesidkey='en_AU',profileid = p.Id,
            timezonesidkey='Australia/Sydney',
            username = firstName+lastName+'@unittest.teleflex.com',
            Business_Unit__c = bu,
            Approval_Role__c = 'Sales Rep',
            UserRoleId = roleId
        );
        return testUser;
    }
    
    public static User createUserGb(String firstName, String lastName, String approvalRole, String bu){
        Profile p = [select id from profile where name='System Administrator' LIMIT 1];
        String roleId = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name LIKE '%Global%' LIMIT 1].Id;
        String fn = firstname.left(2);
        string ln = lastname.left(2);
        User testUser = new User(
            alias = fn+ln,email= firstName+lastName+'@unittest.teleflex.com',
            emailencodingkey = 'UTF-8',firstname = firstName,
            lastname = lastName, languagelocalekey='en_US',
            localesidkey='en_GB',profileid = p.Id,
            timezonesidkey='Europe/London',
            username = firstName+lastName+'@unittest.teleflex.com',
            Business_Unit__c = bu,
            Approval_Role__c = 'Sales Rep',
            UserRoleId = roleId
        );
        return testUser;
    }
    
    //Custom Setting is named by class and methods to turn on/off
    public static Invoiced_Sales_Tracking_Class_CS__c createCsClass(String methodName, Boolean executeValue){
        Invoiced_Sales_Tracking_Class_CS__c csTest = new Invoiced_Sales_Tracking_Class_CS__c(
            Name = methodName,
            Execute__c = executeValue
        );
        
        return csTest;
    }
    
    //Custom Setting controls number of active Sales Orgs/Sales Org Keys
    public static Sales_Orgs__c  createSalesOrg(String salesOrgKey, Boolean isActive, String pricingType, String salesOrg, String distrChannel){
        Sales_Orgs__c soTest = new Sales_Orgs__c(
            Name = salesOrgKey,
            Active__c  = isActive,
            Pricing_Type__c = pricingType, //values (All, Hospital List, Distributor List, Alt Site List)
            Sales_Org__c = salesOrg,
            Distribution_Channel__c = distrChannel
        );
        
        return soTest;
    }
    
    //Custom Setting controls number of active Sales Orgs/Sales Org Keys
    public static List<Sales_Orgs__c> createSalesOrgsAll(){
        Set<Sales_Orgs__c> newSalesOrgsSet = new Set<Sales_Orgs__c>();
        Sales_Orgs__c salesOrgUs = testDataFactoryPP.createSalesOrg('US6010',true,'All','US60','10');
        newSalesOrgsSet.add(salesOrgUs);
        Sales_Orgs__c salesOrgCan = testDataFactoryPP.createSalesOrg('CA1010',true,'All','CA10','10');
        newSalesOrgsSet.add(salesOrgCan);
        Sales_Orgs__c salesOrgLatamExp = testDataFactoryPP.createSalesOrg('US6020',true,'Distributor List','US60','20');
        newSalesOrgsSet.add(salesOrgLatamExp);
        Sales_Orgs__c salesOrgMx = testDataFactoryPP.createSalesOrg('MX4010',true,'All','MX40','10');
        newSalesOrgsSet.add(salesOrgMx);
        Sales_Orgs__c salesOrgCl = testDataFactoryPP.createSalesOrg('CL1010',true,'All','CL10','10');
        newSalesOrgsSet.add(salesOrgCl);
        Sales_Orgs__c salesOrgCo = testDataFactoryPP.createSalesOrg('CO10',true,'All','CO10','10');
        newSalesOrgsSet.add(salesOrgCo);
        Sales_Orgs__c salesOrgUsOld = testDataFactoryPP.createSalesOrg('US103010',true,'All','US10','10');
        newSalesOrgsSet.add(salesOrgUsOld);
        Sales_Orgs__c salesOrgLaOld = testDataFactoryPP.createSalesOrg('US103020',true,'Distributor List','US10','20');
        newSalesOrgsSet.add(salesOrgLaOld);
        Sales_Orgs__c salesOrgBr = testDataFactoryPP.createSalesOrg('BR1010',true,'All','BR10','10');
        newSalesOrgsSet.add(salesOrgBr);
        Sales_Orgs__c salesOrgAu = testDataFactoryPP.createSalesOrg('AU1010',true,'All','AU10','10');
        newSalesOrgsSet.add(salesOrgAu);
        Sales_Orgs__c salesOrgNz = testDataFactoryPP.createSalesOrg('NZ1010',true,'All','NZ10','10');
        newSalesOrgsSet.add(salesOrgNz);
        List<Sales_Orgs__c> newSalesOrgs = new List<Sales_Orgs__c>(newSalesOrgsSet);        
        return newSalesOrgs;
    }

    //Custom Setting is named by class and methods to turn on/off
    public static Sample_Request_Line_Item_Class_CS__c createCsClass1(String methodName, Boolean executeValue){
        Sample_Request_Line_Item_Class_CS__c csTest = new Sample_Request_Line_Item_Class_CS__c(
            Name = methodName,
            Execute__c = executeValue
        );
        
        return csTest;
    }
    
    public static Account createAccount(String accName, String salesOrg, String sapCode, String custGrp ){
        Account accTest = new Account(
            Name = accName,
            SAP_Sold_To__c = sapCode,
            Account_Group__c = 'Z001',
            Customer_Group__c = custGrp,
            zBlock__c = '00',
            Sales_Org__c = salesOrg,
            Exclusion_Type__c = 'ZB01',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
        );
        //insert accTest;
        return accTest;
    }//end createAccount

    public static Account createAccountNew(String accName, String salesOrg, String distChannel, String sapCode, String custGrp ){
        Account accTest = new Account(
            Name = accName,
            SAP_Sold_To__c = sapCode,
            Account_Group__c = 'Z001',
            Customer_Group__c = custGrp,
            zBlock__c = '00',
            Sales_Org__c = salesOrg,
            Distribution_Channel__c = distChannel,
            Exclusion_Type__c = 'ZB01',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
        );
        //insert accTest;
        return accTest;
    }//end createAccount
    
    public static Account createAccountZ002(String accName, String salesOrg, String sapCode, String custGrp ){
        Account accTest = new Account(
            Name = accName,
            SAP_Sold_To__c = sapCode,
            Account_Group__c = 'Z002',
            Customer_Group__c = custGrp,
            zBlock__c = '00',
            Sales_Org__c = salesOrg,
            Exclusion_Type__c = 'ZB01',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('North American Customer').getRecordTypeId()
        );
        //insert accTest;
        return accTest;
    }//end createAccount
    
    public static Contact createContact(String firstName, String lastName, Id accId){
        Contact conTest = new Contact(
            LastName = lastName,
            AccountId = accId,
            FirstName = firstName,
            Email= firstName + lastName +'@test.com',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
            Title = 'Admin'
            //Business_Unit1__c = 'Anesthesia'
        );
        //insert conTest;
        return conTest;
    }//end createContact
    
    //create Pricing Portal Groups for contract sharing
    public static List<Group> createPublicGroups(){
        List<Group> ppGroups = new List<Group>();
        //loop to create US public groups
        for(Integer i =1;i<7;i++){
            Group usGroup = new Group(
                Name = 'Division '+i+'0'
            );
            ppGroups.add(usGroup);
        }//end loop to create public groups
        
        //loop to create Canada public groups
        for(Integer i =1;i<7;i++){
            Group caGroup = new Group(
                Name = 'CA Division '+i+'0'
            );
            ppGroups.add(caGroup);
        }//end loop to create public groups

        //loop to create LATAM public groups
        for(Integer i =1;i<7;i++){
            Group laGroup = new Group(
                Name = 'LA Division '+i+'0'
            );
            ppGroups.add(laGroup);
        }//end loop to create public groups

        //loop to create Mexico public groups
        for(Integer i =1;i<7;i++){
            Group mxGroup = new Group(
                Name = 'MX Division '+i+'0'
            );
            ppGroups.add(mxGroup);
        }//end loop to create public groups
        
        //loop to create Chile public groups
        for(Integer i =1;i<7;i++){
            Group clGroup = new Group(
                Name = 'CL Division '+i+'0'
            );
            ppGroups.add(clGroup);
        }//end loop to create public groups
        
        //loop to create Colombia public groups
        for(Integer i =1;i<7;i++){
            Group coGroup = new Group(
                Name = 'CO Division '+i+'0'
            );
            ppGroups.add(coGroup);
        }//end loop to create public groups
        
        return ppGroups;
    }
    
    public static Contract_Partnership__c createContractPartnership(String saleTo, String shipTo){
        Contract_Partnership__c cp = new Contract_Partnership__c(
            Sale_to__c = saleTo,
            Ship_to__c = shipTo
        );
        return cp;
    }//end createContractPartnership
    
    public static Product2 createProduct(String prodName, String salesOrg, String distChan, String matStatus) {
        Product2 prodTest = new Product2(
            Name = prodName,
            //ProductCode= 'AA-10511-1',
            UOM__c='CS',
            Each_per_Case__c=5,
            //Material_Status__c='MTS',
            Material_Status_Numeric__c = matStatus,
            Family = 'Hardware',
            //Material__c='AA-10511-1',
            Brand_Name__c='Arrow',
            Buom__c='EA',
            Class__c='Cardiac Care Specialty',
            Sales_Org__c = salesOrg,
            Distribution_Channel__c = distChan,
            Sales_Org_Key__c = salesOrg + distChan,
            Material_Key__c = prodName + '-' + salesOrg + '-' + distChan,
            Description = 'TEST PRODUCT',
            Product_Description_Custom__c = 'TEST PRODUCT',
            Group__c='Interventional',
            SubGroup__c = 'TransRadial Access',
            Qty_Sales_Unit__c=5,
            Sales_Unit__c='CS',
            //Distributor_List__c = 380.00,
            //Alt_Site_List__c = 380.00,
            List_Price__c=380.00,
            Rep_Price__c=350.00,
            RSM_Price__c=330.00,
            Cost__c=11587.40,
            Cost_Price_Unit__c=1000,
            Director_Price__c = 300.00,
            Floor_Price__c = 280.00,
            Duplicate__c = FALSE
        );
        return prodTest;
    }//end createProduct
    
    public static Product2 createProduct2(String prodName, String salesOrg, String distChan, String matStatus) {
        Product2 prodTest = new Product2(
            Name = prodName,
            //ProductCode= 'AA-10511-1',
            UOM__c='CS',
            Each_per_Case__c=5,
            //Material_Status__c='MTS',
            Material_Status_Numeric__c = matStatus,
            Family = 'Hardware',
            //Material__c='AA-10511-1',
            Brand_Name__c='Arrow',
            Buom__c='EA',
            Class__c='Medline',
            Sales_Org__c = salesOrg,
            Distribution_Channel__c = distChan,
            Sales_Org_Key__c = salesOrg + distChan,
            Material_Key__c = prodName + '-' + salesOrg + '-' + distChan,
            Description = 'SILENT HUMIDIFIER ADAPTOR 011',
            Product_Description_Custom__c = 'TEST PRODUCT',
            Group__c='Oxygen Therapy',
            SubGroup__c = 'Bubble Humidifiers',
            Qty_Sales_Unit__c=50,
            Sales_Unit__c='CS',
            List_Price__c=755.74,
            Distributor_List__c = 685.48 ,
            Alt_Site_List__c = 755.74,
            Rep_Price__c=540.00,
            RSM_Price__c=504.00,
            Cost__c=14270.00,
            Cost_Price_Unit__c=1000,
            Director_Price__c = 432.00,
            Floor_Price__c = 414.00,
            VP_Price__c = 432.00
        );
        return prodTest;
    }//end createProduct2

    //create products for Vascular Bundles
    public static Product2 createProductVascBundUltra(String prodName, String salesOrg, String distChan, String matStatus) {
        Product2 vascBundMat = new Product2(
            Name = prodName, ProductCode= prodName, UOM__c='EA', Each_per_Case__c=1, Material_Status_Numeric__c=matStatus,
            Family = 'Hardware', Material__c='000-40', Brand_Name__c='Arrow', Buom__c='EA',Class__c='Vascular',
            Cost__c=11587.40, Cost_Price_Unit__c=1000, Division__c='60', Description='TRANSRADIAL ACCESS TRAY',
            Group__c='Interventional', SubGroup__c = 'TransRadial Access', Qty_Sales_Unit__c=1, Sales_Unit__c='EA',
            List_Price__c=380.00, Rep_Price__c=350.00, Transfer_Price__c = 1000.00, Sales_Org__c = salesOrg,
            Distribution_Channel__c = distChan, Sales_Org_Key__c = salesOrg + distChan,
            Material_Key__c = prodName + '-' + salesOrg + '-' + distChan, RSM_Price__c=330.00,
            VPS_Rhythm_DLX_without_Ultrasound__c = true, VPS_Rhythm_DLX_with_Ultrasound__c = true,
            DLX_Ultrasound_Probe_Only__c = true, VPS_Rhythm__c = true, VPS_Rhythm_Refurb__c = true,
            G4__c = true, G4_Refurb__c = true, X1_year__c = false, X2_year__c = true,
            X3_year__c = false, X4_year__c = true
        );
        return vascBundMat;
    }//end createProductVascBund
    
    //create products for Vascular Bundles
    public static Product2 createProductVascBundRhythm(String prodName, String salesOrg, String distChan, String matStatus) {
        Product2 vascBundMat = new Product2(
            Name = prodName, ProductCode= prodName, UOM__c='EA', Each_per_Case__c=1, Material_Status_Numeric__c=matStatus,
            Family = 'Hardware', Material__c='000-40', Brand_Name__c='Arrow', Buom__c='EA',Class__c='Vascular',
            Cost__c=11587.40, Cost_Price_Unit__c=1000, Division__c='60', Description='TRANSRADIAL ACCESS TRAY',
            Group__c='Interventional', SubGroup__c = 'TransRadial Access', Qty_Sales_Unit__c=1, Sales_Unit__c='EA',
            List_Price__c=380.00, Rep_Price__c=350.00, Transfer_Price__c = 1000.00, Sales_Org__c = salesOrg,
            Distribution_Channel__c = distChan, Sales_Org_Key__c = salesOrg + distChan,
            Material_Key__c = prodName + '-' + salesOrg + '-' + distChan, RSM_Price__c=330.00,
            VPS_Rhythm_DLX_without_Ultrasound__c = false, VPS_Rhythm_DLX_with_Ultrasound__c = false,
            DLX_Ultrasound_Probe_Only__c = false, VPS_Rhythm__c = true, VPS_Rhythm_Refurb__c = true,
            G4__c = false, G4_Refurb__c = false, X1_year__c = true, X2_year__c = true,
            X3_year__c = true, X4_year__c = true
        );
        return vascBundMat;
    }//end createProductVascBundRhythm
    
    //create products for Vascular Bundles
    public static Product2 createProductVascBundG4(String prodName, String salesOrg, String distChan, String matStatus) {
        Product2 vascBundMat = new Product2(
            Name = prodName, ProductCode= prodName, UOM__c='EA', Each_per_Case__c=1, Material_Status_Numeric__c=matStatus,
            Family = 'Hardware', Material__c='000-40', Brand_Name__c='Arrow', Buom__c='EA',Class__c='Vascular',
            Cost__c=11587.40, Cost_Price_Unit__c=1000, Division__c='60', Description='TRANSRADIAL ACCESS TRAY',
            Group__c='Interventional', SubGroup__c = 'TransRadial Access', Qty_Sales_Unit__c=1, Sales_Unit__c='EA',
            List_Price__c=380.00, Rep_Price__c=350.00, Transfer_Price__c = 1000.00, Sales_Org__c = salesOrg,
            Distribution_Channel__c = distChan, Sales_Org_Key__c = salesOrg + distChan,
            Material_Key__c = prodName + '-' + salesOrg + '-' + distChan, RSM_Price__c=330.00,
            VPS_Rhythm_DLX_without_Ultrasound__c = false, VPS_Rhythm_DLX_with_Ultrasound__c = false,
            DLX_Ultrasound_Probe_Only__c = false, VPS_Rhythm__c = false, VPS_Rhythm_Refurb__c = false,
            G4__c = true, G4_Refurb__c = true, X1_year__c = true, X2_year__c = true,
            X3_year__c = true, X4_year__c = true
        );
        return vascBundMat;
    }//end createProductVascBundG4
    
    public static Product2 createProductVascBundTradein(String prodName, String salesOrg, String distChan, String matStatus) {

        Product2 vascTradein = new Product2(
            Name = prodName, ProductCode= prodName, UOM__c='EA', Each_per_Case__c=1, Material_Status_Numeric__c=matStatus,
            Family = 'Hardware', Material__c='000-40', Brand_Name__c='Arrow', Buom__c='EA',Class__c='Vascular',
            Cost__c=11587.40, Cost_Price_Unit__c=1000, Division__c='60', Description='TRANSRADIAL ACCESS TRAY',
            Group__c='Interventional', SubGroup__c = 'TransRadial Access', Qty_Sales_Unit__c=1, Sales_Unit__c='EA',
            List_Price__c=380.00, Rep_Price__c=350.00, Transfer_Price__c = 1000.00, Sales_Org__c = salesOrg,
            Distribution_Channel__c = distChan, Sales_Org_Key__c = salesOrg + distChan,
            Material_Key__c = prodName + '-' + salesOrg + '-' + distChan, RSM_Price__c=330.00,
            X1_year__c = true, X2_year__c = true, X3_year__c = true,X4_year__c = true
        );
        return vascTradein;
    }//end vascBundTradein

    public static Cross_Reference__c createCrossRef(String prodId){
        Cross_Reference__c CRTest = new Cross_Reference__c(
            Competitor_Product_Code__c = '320250',
            Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
            Competitor_Name__c ='Jarit/Integra',
            Percent_Match__c=100,
            Product__c = prodId
        );
        return CRTest;
    }//end createCrossRef
    
    public static Contract_Header__c createContractHeader(String agreeNum, String owner, String gpoRefLev, String salesOrg){
        Integer pta = 1;
        if(gpoRefLev == 'M'){
            pta = 2;
        }
        else if(gpoRefLev == 'D'){
            pta = 3;
        }
        else{
            pta = 1;
        }
        
        Contract_Header__c ch = new Contract_Header__c(
            Name = agreeNum, //ex: 50009064,50010864,50010001,
            Agreement_Number__c = agreeNum,
            Description__c = 'Test Description',
            Owner__c = owner, //ex: 123310,
            Owner_Name__c = 'Teleflex',
            GPO_Contract_Ref__c = 'ANES-'+gpoRefLev,
            Valid_From__c = Date.Today() - 1,
            Valid_To__c = Date.Today() + 1000,
            Sub_Group__c = '8',
            Pricing_Tier_Access__c = pta,
            Sales_Org__c = salesOrg,
            Division_10__c = true, Division_20__c = true, Division_30__c = true,
            Division_40__c = true, Division_50__c = true, Division_60__c = true
        );
        
        return ch;
    }//end createContractHeader
    
    //Pricing Tier Contract Headers
    public static Contract_Header__c createContractHeaderPt(String agreeNum, String owner, String gpoRefLev, String salesOrg){
        Integer pta = 1;
        if(gpoRefLev == 'M'){
            pta = 2;
        }
        else if(gpoRefLev == 'D'){
            pta = 3;
        }
        else{
            pta = 1;
        }
        
        Contract_Header__c ch = new Contract_Header__c(
            Name = agreeNum, //ex: 50009064,50010864,50010001,
            Agreement_Number__c = agreeNum,
            Description__c = 'Test Description PT',
            Owner__c = owner, //ex: 123310,
            Owner_Name__c = 'Teleflex',
            GPO_Contract_Ref__c = 'RESP-'+gpoRefLev,
            Valid_From__c = Date.Today() - 1,
            Valid_To__c = Date.Today() + 1000,
            Group__c = '04',
            Sub_Group__c = '8',
            Pricing_Tier_Access__c = pta,
            Sales_Org__c = salesOrg,
            Division_10__c = false, Division_20__c = false, Division_30__c = false,
            Division_40__c = false, Division_50__c = false, Division_60__c = false,
            Objective__c = '01'
        );
        
        return ch;
    }//end createContractHeader
    
    public static Contract_Material__c createContractMaterial(String agreeHeaderId, String agreeNum, String prodName, 
                                                              String prodId, String salesOrg, String div, String distChannel){
        Contract_Material__c conMat = new Contract_Material__c(
            Name = agreeNum,
            Agreement__c = agreeHeaderId,
            Material_Name__c = prodName,
            Product__c = prodId,
            Sales_Org__c = salesOrg,
            Valid_From__c = Date.Today(),
            Valid_To__c = Date.Today() + 1000,
            Material_Division__c = div,
            Distribution_Channel__c = distChannel,
            Price__c = 123.00,
            Rep_price__c = 123.00,
            RSM_Price__c = 123.00,
            Director_price__c = 113.00,
            VP_price__c = 100.00,
            Level_fix__c = 2.0,
            Maintenance_Key__c = '123'
        );
        return conMat;   
    }//end createContractMaterial
    
    //Pricing Tier Material Agreements
    public static Contract_Material__c createContractMaterialPt(String agreeHeaderId, String agreeNum, String prodName, String prodId,
                                                              String salesOrg, String div, String distChannel, String gpoRef, Integer levelFix,
                                                               Decimal listPrice, Decimal repPrice, Decimal rsmPrice, Decimal dirPrice, Decimal conPrice){
        Contract_Material__c conMat = new Contract_Material__c(
            Name = agreeNum,
            Agreement__c = agreeHeaderId,
            Material_Name__c = prodName,
            Product__c = prodId,
            Sales_Org__c = salesOrg,
            Valid_From__c = Date.Today(),
            Valid_To__c = Date.Today() + 1000,
            Material_Division__c = div,
            Distribution_Channel__c = distChannel,
            Price__c = conPrice,
            Rep_price__c = repPrice,
            RSM_Price__c = rsmPrice,
            Director_price__c = dirPrice,
            VP_price__c = dirPrice,
            List_Price__c = listPrice,
            Level_fix__c = levelFix,
            GPO_Contract_Ref__c = 'RESP-R',
            Maintenance_Key__c = '123'
        );
        return conMat;   
    }//end createContractMaterial
    
    public static Contract_Customer__c createContractCustomer(String agreeHeaderId, String agreeNum, String salesOrg, 
                                                              String accId, String sapCode, String distChannel){
        Contract_Customer__c conCust = new Contract_Customer__c(
            Name = agreeNum,
            Agreement__c = agreeHeaderId,
            Account__c = accId,
            SAP_Code__c = sapCode,
            Sales_Org__c = salesOrg,
            Valid_From__c = Date.Today(),
            Valid_To__c = Date.Today() + 1000,
            Distribution_Channel__c = distChannel,
            Condition__c = 'XNAF',
            Maintenance_Key__c = '123'
        );
        return conCust;
    }//end createContractCustomer
    
    public static Price_Quote__c createPriceQuote(String accId,String conId,String salesOrgKey,Boolean oneTime, String bu){
        Price_Quote__c PQTest = new Price_Quote__c(
            Account_Name__c = accId,
            Contact_Name__c = conId,
            Status__c = 'In Progress',
            Expiration_Date__c = Date.today() + 90,
            Sales_Org_Key__c = salesOrgKey, //ex: US6010,US6020,CA1010,US103010,US103020,AU1010,NZ1010,CL1010,CO1010,MX4010
            One_Time_Purchase__c = oneTime,
            BusinessUnit__c = bu
        );
        
        if(PQTest.Sales_Org_Key__c == 'US6010'){
            PQTest.Language__c = 'English';
        }
        else if(PQTest.Sales_Org_Key__c == 'US6020' || PQTest.Sales_Org_Key__c == 'CL1010' || PQTest.Sales_Org_Key__c == 'CO1010' || PQTest.Sales_Org_Key__c == 'MX4010'){
            PQTest.Language__c = 'Spanish';
        }
        else{
            PQTest.Language__c = 'English';
        }
        
        return PQTest;
    }//end createPriceQuote

    public static Price_Quote_Line_Item__c createPriceQLineItem(String pqId,String prodId) {
        Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
            Price_Quote__c = pqId,
            Material_Name__c = prodId,
            Sales_Price__c = 230.00,
            Quantity__c = 1
            //Extended_Price__c = 230.00
            //Eligible_Price__c = 230.00,
            //Rep_Price__c = 350.00,
            //RSM_Price__c = 330.00,
            //List_Price__c = 380.00,
            //Product_Description__c='Test Description'
            //Competetive_Product__c = crId
        );
        //insert PQLineItem;
        return PQLineItem;
    }//end createPriceQLineItem

    public static Price_Quote_Line_Item__c createPqLineItemRefresh(String pqId,String prodId) {
        Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
            Price_Quote__c = pqId,
            Material_Name__c = prodId,
            Sales_Price__c = 230.00,
            Quantity__c = 1,
            Refresh__c = true
            //Extended_Price__c = 230.00,
            //Eligible_Price__c = 230.00,
            //Rep_Price__c = 350.00,
            //RSM_Price__c = 330.00,
            //List_Price__c = 380.00,
            //Product_Description__c='Test Description'
            //Competetive_Product__c = crId
        );
        //insert PQLineItem;
        return PQLineItem;
    }//end createPriceQLineItem
    
    public static PRF__c createPrf(String accId, String conId, String salesOrgKey, String bu){
        PRF__c prfTest = new PRF__c(
            Account__c = accId,
            Contact__c = conId,
            Status__c = 'New',
            Requisition_Date__c = Date.valueOf('2015-03-11'),
            Sales_Org_Key__c = salesOrgKey,
            Business_Unit__c = bu,
            GPO_Affiliation__c = ''
        );
        return prfTest;
    }//end createPrf
    
    public static Prf_Line_Item__c createPrfLineItem(String prfId, String prodId){
        PRF_Line_Item__c prfLineItem = new PRF_Line_Item__c(
            PRF__c = prfId,
            Material_Name__c = prodId,
            Eligible_Price__c = 230.00,
            Rep_Price__c = 350.00,
            RSM_Price__c = 330.00,
            List_Price__c = 380.00,
            Requested_Price__c = 230.00
        );
        return prfLineItem;
    }//end createPrfLineItem
    
    public static Contract_User__c createPricingPortalUser(String uName, String uId, String activeRegion, String salesOrgKey, Integer tierAccess)
    {
        Contract_User__c cu = new Contract_User__c(
            Name = uName,
            User__c = uId,
            Pricing_Portal_Access__c = TRUE,
            Active_Currency__c = 'USD',
            Pricing_Tier_Access__c = tierAccess
        );
                                                              
        if(activeRegion == 'US - Teleflex'){
            cu.Active_Region__c = activeRegion;
            cu.Active_Sales_Org_Key__c = salesOrgKey;
            cu.US_Material__c = TRUE;
            cu.Division_10__c = TRUE;
            cu.Division_20__c = TRUE;
            cu.Division_30__c = TRUE;
            cu.Division_40__c = TRUE;
            cu.Division_50__c = TRUE;
            cu.Division_60__c = TRUE;
        }
        else if(activeRegion == 'CA - Canada'){
            cu.Active_Region__c = activeRegion;
            cu.Active_Sales_Org_Key__c = salesOrgKey;
            cu.CA_Material__c = TRUE;
            cu.CA_Division_10__c = TRUE;
            cu.CA_Division_20__c = TRUE;
            cu.CA_Division_30__c = TRUE;
            cu.CA_Division_40__c = TRUE;
            cu.CA_Division_50__c = TRUE;
            cu.CA_Division_60__c = TRUE;
        }
        else if(activeRegion == 'LA - Latin America'){
            cu.Active_Region__c = activeRegion;
            cu.Active_Sales_Org_Key__c = salesOrgKey;
            cu.LA_Material__c = TRUE;
            cu.LA_Division_10__c = TRUE;
            cu.LA_Division_20__c = TRUE;
            cu.LA_Division_30__c = TRUE;
            cu.LA_Division_40__c = TRUE;
            cu.LA_Division_50__c = TRUE;
            cu.LA_Division_60__c = TRUE;
        }
        else if(activeRegion == 'MX - Mexico'){
            cu.Active_Region__c = activeRegion;
            cu.Active_Sales_Org_Key__c = salesOrgKey;
            cu.MX_Material__c = TRUE;
            cu.MX_Division_10__c = TRUE;
            cu.MX_Division_20__c = TRUE;
            cu.MX_Division_30__c = TRUE;
            cu.MX_Division_40__c = TRUE;
            cu.MX_Division_50__c = TRUE;
            cu.MX_Division_60__c = TRUE;
        }
        else if(activeRegion == 'CL - Chile'){
            cu.Active_Region__c = activeRegion;
            cu.Active_Sales_Org_Key__c = salesOrgKey;
            cu.CL_Material__c = TRUE;
            cu.CL_Division_10__c = TRUE;
            cu.CL_Division_20__c = TRUE;
            cu.CL_Division_30__c = TRUE;
            cu.CL_Division_40__c = TRUE;
            cu.CL_Division_50__c = TRUE;
            cu.CL_Division_60__c = TRUE;
        }
        else if(activeRegion == 'CO - Colombia'){
            cu.Active_Region__c = activeRegion;
            cu.Active_Sales_Org_Key__c = salesOrgKey;
            cu.CO_Material__c = TRUE;
            cu.CO_Division_10__c = TRUE;
            cu.CO_Division_20__c = TRUE;
            cu.CO_Division_30__c = TRUE;
            cu.CO_Division_40__c = TRUE;
            cu.CO_Division_50__c = TRUE;
            cu.CO_Division_60__c = TRUE;
        }
        else if(activeRegion == 'BR - Brazil'){
            cu.Active_Region__c = activeRegion;
            cu.Active_Sales_Org_Key__c = salesOrgKey;
            cu.BR_Material__c = TRUE;
            cu.BR_Division_10__c = TRUE;
            cu.BR_Division_20__c = TRUE;
            cu.BR_Division_30__c = TRUE;
            cu.BR_Division_40__c = TRUE;
            cu.BR_Division_50__c = TRUE;
            cu.BR_Division_60__c = TRUE;
        }
        else{
            cu.Active_Region__c = activeRegion;
            cu.Active_Sales_Org_Key__c = salesOrgKey;
            //set all materials access
            cu.US_Material__c = TRUE;
            cu.CA_Material__c = TRUE;
            cu.LA_Material__c = TRUE;
            cu.MX_Material__c = TRUE;
            cu.CL_Material__c = TRUE;
            cu.CO_Material__c = TRUE;
            cu.AU_Material__c = TRUE;
            cu.NZ_Material__c = TRUE;
            
            //Set US divisions access
            cu.Division_10__c = TRUE;
            cu.Division_20__c = TRUE;
            cu.Division_30__c = TRUE;
            cu.Division_40__c = TRUE;
            cu.Division_50__c = TRUE;
            cu.Division_60__c = TRUE;
            
            //Set Canada divisions access
            cu.CA_Division_10__c = TRUE;
            cu.CA_Division_20__c = TRUE;
            cu.CA_Division_30__c = TRUE;
            cu.CA_Division_40__c = TRUE;
            cu.CA_Division_50__c = TRUE;
            cu.CA_Division_60__c = TRUE;
            
            //Set LATAM divisions access
            cu.LA_Division_10__c = TRUE;
            cu.LA_Division_20__c = TRUE;
            cu.LA_Division_30__c = TRUE;
            cu.LA_Division_40__c = TRUE;
            cu.LA_Division_50__c = TRUE;
            cu.LA_Division_60__c = TRUE;
            
            //Set Mexico divisions access
            cu.MX_Division_10__c = TRUE;
            cu.MX_Division_20__c = TRUE;
            cu.MX_Division_30__c = TRUE;
            cu.MX_Division_40__c = TRUE;
            cu.MX_Division_50__c = TRUE;
            cu.MX_Division_60__c = TRUE;
            
            //Set Chile divisions access
            cu.CL_Division_10__c = TRUE;
            cu.CL_Division_20__c = TRUE;
            cu.CL_Division_30__c = TRUE;
            cu.CL_Division_40__c = TRUE;
            cu.CL_Division_50__c = TRUE;
            cu.CL_Division_60__c = TRUE;
            
            //Set Colombia divisions access
            cu.CO_Division_10__c = TRUE;
            cu.CO_Division_20__c = TRUE;
            cu.CO_Division_30__c = TRUE;
            cu.CO_Division_40__c = TRUE;
            cu.CO_Division_50__c = TRUE;
            cu.CO_Division_60__c = TRUE;
            
            //Set Australia divisions access
            cu.AU_Division_10__c = TRUE;
            cu.AU_Division_20__c = TRUE;
            cu.AU_Division_30__c = TRUE;
            cu.AU_Division_40__c = TRUE;
            cu.AU_Division_50__c = TRUE;
            cu.AU_Division_60__c = TRUE;
            
            //Set New Zealand divisions access
            cu.NZ_Division_10__c = TRUE;
            cu.NZ_Division_20__c = TRUE;
            cu.NZ_Division_30__c = TRUE;
            cu.NZ_Division_40__c = TRUE;
            cu.NZ_Division_50__c = TRUE;
            cu.NZ_Division_60__c = TRUE;
            
            //Set Brazil divisions access
            cu.BR_Division_10__c = TRUE;
            cu.BR_Division_20__c = TRUE;
            cu.BR_Division_30__c = TRUE;
            cu.BR_Division_40__c = TRUE;
            cu.BR_Division_50__c = TRUE;
            cu.BR_Division_60__c = TRUE; 
        }
        return cu;
    }//end createPricingPortalUser
    
    /*
    Sample_Request__c srec = new Sample_Request__c(
    Account__c = a.Id,
    Contact__c = c.Id,
    Default_Quantity__c = 1,
    Default_Unit_of_Measure__c = 'Each',
    Shipping_Method__c = 'Standard',
    Status__c = 'New',
    Territory__c = tm.Id,
    Shipping_Address_1__c = '3015 Carrington Mill Blvd',
    Shipping_City__c = 'Morrisville',
    Shipping_State__c = 'NC',
    Shipping_Zipcode__c = '27560',
    Shipping_Country__c = 'US',
    Type__c = 'Sample',
    Sales_Org_Key__c = 'US6010'
    );
    insert srec; 
    */
    
    public static Sample_Request__c createSampleRequest(String accId,String conId,String salesOrgKey, String territoryId, String sampleType, String status){
        Sample_Request__c srRec = new Sample_Request__c(
            Account__c = accId,
            Contact__c = conId,
            Default_Quantity__c = 1,
            Default_Unit_of_Measure__c = 'Each',
            Shipping_Method__c = 'Standard',
            Status__c = status,
            Territory__c = territoryId,
            Shipping_Address_1__c = '3015 Carrington Mill Blvd',
            Shipping_City__c = 'Morrisville',
            Shipping_State__c = 'NC',
            Shipping_Zipcode__c = '27560',
            Shipping_Country__c = 'US',
            Type__c = sampleType,
            Sales_Org_Key__c = salesOrgKey,
            RecordTypeId = '01244000000g56p',
            Medical_License__c = 'Unit Testing'
        );

        return srRec;
    }//end createSampleRequest

    public static Sample_Request_Line_Item__c createSampleRequestLineItem(String sampleId,String prodId) {
        Sample_Request_Line_Item__c srliRec = new Sample_Request_Line_Item__c(
            Sample_Request__c = sampleId,
            Material__c = prodId,
            Quantity__c = 1,
            Exception__c = 'Testing'
        );
        //insert PQLineItem;
        return srliRec;
    }//end createSampleRequestLineItem
    
    public static Invoiced_Sales_Tracking__c createInvoicedSalesTracking(String materialName,String sampleNumber, String deliveryPriority, String trackingNumber) {
        Invoiced_Sales_Tracking__c istRec = new Invoiced_Sales_Tracking__c(
            Material_Name__c = materialName,
            PO_Number__c = sampleNumber,
            Plant__c = 'US21',
            Ship_Date__c = Date.today(),
            Tracking_Number__c = trackingNumber,
            Delivery_Priority__c = deliveryPriority,
            Delivery_Number__c = '8002240954 ',
            Delivery_Line_Number__c = '000010 ',
            Delivery_Priority_2_Digit__c = '01'  
        );
        //insert PQLineItem;
        return istRec;
    }//end createSampleRequestLineItem
    
    public static Territory_Master__c createTerritoryMaster(String territoryNumber, String bu ){
        Territory_Master__c tmRec = new Territory_Master__c(
            Name = territoryNumber,
            Territory_Number__c = territoryNumber,
            Business_Unit__c = bu,
            Shipping_Street__c = '123 Main St',
            Shipping_City__c = 'Raleigh',
            Shipping_State__c = 'NC',
            Shipping_Postal_Code__c = '27614',
            Shipping_Country__c = 'US'
        );
        
        return tmRec;
    }//end createTerritoryMaster
    
    public static Territory_User__c createTerritoryUser(String tmId, String tmNumber, String userId ){
        Territory_User__c tuRec = new Territory_User__c(
            Territory_Master__c = tmId,
            Territory_Number__c = tmNumber,
            User__c = userId,
            Primary__c = TRUE
        );
        
        return tuRec;
    }//end createTerritoryUser
    
    public static Maintenance_Objects__c createMaintenanceObjects(String mainName, String mainNamePretty, String type, Integer maxLimit){
        Maintenance_Objects__c mainObj = new Maintenance_Objects__c(
            Name = mainName,
            Pretty_Name__c = mainNamePretty,
            Type__c = type,
            Limit__c = maxLimit
        );

        return mainObj;
    }//end createMaintenanceObjects
}//end class