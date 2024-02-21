/*********************************************************************
* Description      : Test coverage for Pricing Portal Margin Calculator.
* Coverage         : Classes(PP_Margin_Calculator)
* Author(s)        : Dun Silver
**********************************************************************/
@isTest
public class PP_Margin_Calculator_Test {

    static testmethod void PP_Margin_Calculator_UnitTest(){

        //createUser(String firstName, String lastName, String approvalRole, String bu)
        User u = testDataFactoryPP.createUser('Adam','Franks','Sales VP','Anesthesia');
        insert u;

        User u1 = testDataFactoryPP.createUser('Testfn1','Testln1','Sales Rep','Anesthesia');
        insert u1;
        
        User u2 = testDataFactoryPP.createUser('Testfn2','Testln2','Sales Manager','Anesthesia');
        insert u2;
        
        User u3 = testDataFactoryPP.createUser('Testfn3','Testln3','Sales Director','Anesthesia');
        insert u3;
        
        User u4 = testDataFactoryPP.createUser('Testfn4','Testln4','Sales VP','Anesthesia');
        insert u4;

        Test.startTest();
        System.runAs(u){
             //create a contract user record
            Contract_User__c cu = new Contract_User__c(
                Name = 'Adam Franks',
                User__c = u.id,
                Active_Region__c = 'US - Teleflex',
                US_Material__c = TRUE,
                CA_Material__c = TRUE,
                MX_Material__c = TRUE,
                LA_Material__c = TRUE,
                CL_Material__c = TRUE,
                AU_Material__c = TRUE,
                NZ_Material__c = TRUE,
                Pricing_Portal_Access__c = TRUE,
                Pricing_Tier_Access__c = 1,
                CO_Material__c = TRUE,
                BR_Material__c = TRUE,
                DE_Material__c = TRUE,
                UK_Material__c = TRUE,
                AT_Material__c  = TRUE,
                BE_Material__c = TRUE,
                CH_Material__c = TRUE,
                CZ_Material__c = TRUE,
                ES_Material__c = TRUE,
                FR_Material__c = TRUE,
                GR_Material__c = TRUE,
                IT_Material__c = TRUE,
                NL_Material__c = TRUE,
                PL_Material__c = TRUE,
                SK_Material__c = TRUE,
                PT_Material__c = TRUE,
                IE_Material__c = TRUE,
                SA_Material__c = TRUE,
                Update_Type__c = NULL
                //Division_10__c = TRUE
            );
            insert cu;
            system.debug('CU:' + cu);

            Product2 prodTest = new Product2(Name = 'AA-10511-1',
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
                                            Qty_Sales_Unit__c=0,
                                            Sales_Unit__c='CS',
                                            Transfer_Price__c=1000.00,
                                            List_Price__c=380.00,
                                            Rep_Price__c=350.00,
                                            RSM_Price__c=330.00,
                                            Sales_Org__c = 'US60',
                                            Distribution_Channel__c = '10',
                                            Sales_Org_Key__c = 'US6010',
                                            Material_Key__c = 'AA-10511-1-US60-10');
            insert prodTest;

            
            PageReference mc = Page.PP_Margin_Calculator;

            mc.getParameters().put('pid','');
            mc.getParameters().put('price','');
            Test.setCurrentPage(mc);
            PP_Margin_Calculator mcController = new PP_Margin_Calculator();

            String activeSalesOrg = mcController.myActiveSalesOrg;
            // Assert the results
            System.assertEquals('US6010', activeSalesOrg); // Replace 'US6010' with your expected result

            mcController.prodSrch = '';
            mcController.price = '';
            mcController.grossMargin = 0;
            mcController.getURL();
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            boolean err = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('Please enter a Material Number and Price...')){
                    err = true;
                }
            }
            System.assert(err);
            Double myCost = mcController.newCost;
            //String mySalesKey = mcController.myActiveSalesOrg;
            Boolean priceListTable = mcController.priceListTable;
            
            PageReference mc0 = Page.PP_Margin_Calculator;
            mc0.getParameters().put('pid','AA-10511-1');
            mc0.getParameters().put('price','');
            Test.setCurrentPage(mc0);
            PP_Margin_Calculator mcController0 = new PP_Margin_Calculator();
            mcController0.prodSrch = 'AA-10511-1';
            mcController0.price = '';
            mcController0.getURL();
            msgs = ApexPages.getMessages();
            err = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('Please enter a price...')){
                    err = true;
                }
            }
            system.assert(err);
            mc.getParameters().put('pid','');
            mc.getParameters().put('price','200');
            Test.setCurrentPage(mc);
            mcController = new PP_Margin_Calculator();
            mcController.prodSrch = '';
            mcController.price = '200';

            mcController.priceListTable = True;
            priceListTable = mcController.priceListTable;

            mcController.getURL();
            msgs = ApexPages.getMessages();
            err = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('Please enter a Material Number...')){
                    err = true;
                }
            }
            system.assert(err);

            PageReference mc1 = Page.PP_Margin_Calculator;
            mc1.getParameters().put('pid','AA-10511-1');
            mc1.getParameters().put('price','0');
            Test.setCurrentPage(mc1);
            PP_Margin_Calculator mcController1 = new PP_Margin_Calculator();
            mcController1.prodSrch = 'AA-10511-1';
            mcController1.price = '0';
            mcController1.getURL();
            msgs = ApexPages.getMessages();
            err = true;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('Please enter a price other than 0...')){
                    err = true;
                }
            }
            system.assert(err);

            PageReference mc2 = Page.PP_Margin_Calculator;
            mc2.getParameters().put('pid','AA-10511-1');
            mc2.getParameters().put('price','200');
            Test.setCurrentPage(mc2);
            PP_Margin_Calculator mcController2 = new PP_Margin_Calculator();
            mcController2.getURL();
            //mcController2.newCost;

            PageReference mc3 = Page.PP_Margin_Calculator;
            mc3.getParameters().put('pid','adfdafd');
            mc3.getParameters().put('price','200');
            Test.setCurrentPage(mc3);
            PP_Margin_Calculator mcController3 = new PP_Margin_Calculator();
            mcController3.getURL();
            msgs = ApexPages.getMessages();
            err = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('Material not found...')){
                    err = true;
                }
            }
            system.assert(err);
        }//end System.runAs
        Test.stopTest();
	}// End of static testmethod void PP_Margin_Calculator_UnitTest()
}