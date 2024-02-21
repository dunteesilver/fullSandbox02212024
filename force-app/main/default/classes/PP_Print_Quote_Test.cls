@istest
public class PP_Print_Quote_Test {
    
    @istest static void Test_Print_Test(){
        //PageReference pageRefpre = new PageReference('/apex/PP_Print_Quote');
        //system.debug('PRF Page' + pageRefpre);
        //Test.setCurrentPage(pageRefpre);
        
        //PP_Print_Quote pretest = new PP_Print_Quote();
        //Price_Quote__c pqgettest = pretest.pq;
        //pretest.getpqli();
        //pretest.getpqli_export();
        
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
            username='unit.test@unit.teleflex.com'
        );
        insert u;
        
        Standard_Text__c st = new Standard_Text__c();
        st.Name = 'TestStandardText';
        st.Sales_Org__c = 'AU10';
        insert st;
        
        System.runAs(u){
            
            Account a = new Account(
                Name = 'Test PP Account', 
                SAP_Sold_To__c ='100123', 
                ShippingStreet='123 Main Street ', 
                ShippingCity='Raleigh',
                ShippingState='NC', 
                ShippingPostalCode='27614',
                Customer_Group__c = '19'
            );
            insert a;
            system.debug('a:' + a);
            
            Contact c = new Contact(
                FirstName='Test',
                lastname = 'Marcus',
                AccountId = a.id,
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                
                Email = 'abc@123.com'
            );
            insert c;
            system.debug('c:' + c);
            
            Price_Quote__c pq = new Price_Quote__c( 
                Account_Name__c = a.id,
                Contact_Name__c = c.id,
                Ownerid = u.id,
                Expiration_Date__c = Date.today(),
                Stationary__c = 'Urology',
                Sales_Org_Key__c = 'AU1010',
                Sold_To__c = '100123',
                BusinessUnit__c = 'EMEA'
            );
            insert pq;
            system.debug('PQ:' + pq);
            
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
            master_TriggerHelperClass.runOnce('resetOnceSet');
            insert prodTest;
            
             Cross_Reference__c CRTest = new Cross_Reference__c(
                Competitor_Product_Code__c = '320250',
                Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                Competitor_Name__c ='Jarit/Integra',
                Percent_Match__c=100,
                Product__c = prodTest.Id);
            insert CRTest;
           
             Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
                Price_Quote__c = pq.Id,
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
            
            Quote_Logos__c qlogo = new Quote_Logos__c(
                Name = 'Urology',
                URL__c = '/servlet/servlet.ImageServer?id=015c00000008Zt3&oid=00Dc0000003vErY',
                Footer__c = '/servlet/servlet.ImageServer?id=015c00000008Zt3&oid=00Dc0000003vErY',
                Quote_Page__c = 'PP_Print_Quote'
            );
            insert qlogo; 
            
            PageReference pageRef2 = Page.PP_Print_Center; // new PageReference('/apex/PP_Print_Center?');
            pageRef2.getParameters().put('id', pq.Id);
            //system.debug('PRF Page' + pageRef2);
            Test.setCurrentPage(pageRef2);
            
            PP_Print_Center pctest = new PP_Print_Center();
            pctest.cancel();
            pctest.getpq();
            pctest.getsm();
            pctest.preview();
            pctest.print();
            pctest.sendReport();
            pctest.save();
            pctest.saveFile();
            boolean bccCheck = pctest.bccCheck;
            //pctest.getSecurity();
            
            pctest.send();
            pctest.sendEmail();
            pctest.noEmail();
            pctest.doCancel();
            
            PageReference pageRef3 = new PageReference('/apex/PP_Print_Quote?r=pdf&id=' + pq.Id);
            //system.debug('PRF Page' + pageRef3);
            Test.setCurrentPage(pageRef3);
            
            PP_Print_Quote pqtest = new PP_Print_Quote();
            string pdfFileName = pqtest.pdfFileName;
            string qURL = pqtest.qURL;
            //pqgettest = pqtest.pq;
            //pqgettest = pqtest.pqRec;
            pqtest.getpqli();
            pqtest.getsm();
            pqtest.getpqli_export();
            pqtest.getApproversList();
            pqtest.getGroupedLineItemsMap();
            pqtest.getSoldToAccount();
            string rpdf = pqtest.r;
            string uRegion = pqtest.userRegion;
            string myOrgId = pqtest.OrgId;
            //string userRegion = 'Canada';
            //System.assertEquals(userRegion,'Canada');
            
            /********    Price_Quote_c.Language == 'French'    **********/
            pq.Sold_To__c = '';
            pq.Language__c = 'French';
            update pq;
            
            pageRef3 = new PageReference('/apex/PP_Print_Quote?rs=xls&id=' + pq.Id);
            //system.debug('PRF Page' + pageRef3);
            Test.setCurrentPage(pageRef3);
            
            pqtest = new PP_Print_Quote();
            pqtest.getSoldToAccount();
            string rxls = pqtest.rxls;
            
             
            /********    Price_Quote_c.Language == 'Spanish'    **********/
            pq.Language__c = 'Spanish';
            update pq;
            pageRef3 = new PageReference('/apex/PP_Print_Quote?rs=xls&id=' + pq.Id);
            Test.setCurrentPage(pageRef3);
            new PP_Print_Quote();            
            
            /********    Price_Quote_c.Language == 'Spanish'    **********/
            pq.Language__c = 'German';
            update pq;
            pageRef3 = new PageReference('/apex/PP_Print_Quote?rs=xls&id=' + pq.Id);
            Test.setCurrentPage(pageRef3);
            new PP_Print_Quote();
            
            pq.Language__c = 'Dutch';
            update pq;
            pageRef3 = new PageReference('/apex/PP_Print_Quote?rs=xls&id=' + pq.Id);
            Test.setCurrentPage(pageRef3);
            new PP_Print_Quote();
            
        } 
    }
  
    @istest static void Test_Print_Test2(){
        //PageReference pageRefpre = new PageReference('/apex/PP_Print_Quote');
        //system.debug('PRF Page' + pageRefpre);
        //Test.setCurrentPage(pageRefpre);
        
        //PP_Print_Quote pretest = new PP_Print_Quote();
        //Price_Quote__c pqgettest = pretest.pq;
        //pretest.getpqli();
        //pretest.getpqli_export();
        
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
            username='unit.test@unit.teleflex.com'
        );
        insert u;
        
        Standard_Text__c st = new Standard_Text__c();
        st.Name = 'TestStandardText';
        st.Sales_Org__c = 'AU10';
        insert st;
        
        System.runAs(u){
            
            Account a = new Account(
                Name = 'Test PP Account', 
                SAP_Sold_To__c ='100123', 
                ShippingStreet='123 Main Street ', 
                ShippingCity='Raleigh',
                ShippingState='NC', 
                ShippingPostalCode='27614',
                Customer_Group__c = '19'
            );
            insert a;
            //system.debug('a:' + a);
            
            Contact c = new Contact(
                FirstName='Test',
                lastname = 'Marcus',
                AccountId = a.id,
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                
                Email = 'abc@123.com'
            );
            insert c;
            //system.debug('c:' + c);
            
            Price_Quote__c pq = new Price_Quote__c( 
                Account_Name__c = a.id,
                Contact_Name__c = c.id,
                Ownerid = u.id,
                Expiration_Date__c = Date.today(),
                Stationary__c = 'Urology',
                Sales_Org_Key__c = 'AU1010',
                Sold_To__c = '100123',
                BusinessUnit__c = 'EMEA'
            );
            insert pq;
            //system.debug('PQ:' + pq);
            
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
            master_TriggerHelperClass.runOnce('resetOnceSet');
            insert prodTest;
            
            Cross_Reference__c CRTest = new Cross_Reference__c(
                Competitor_Product_Code__c = '320250',
                Competitor_Product_Description__c = 'DEBAKEY PV CLAMP 7 ANG',
                Competitor_Name__c ='Jarit/Integra',
                Percent_Match__c=100,
                Product__c = prodTest.Id);
            insert CRTest;
            
            Price_Quote_Line_Item__c PQLineItem = new Price_Quote_Line_Item__c(
                Price_Quote__c = pq.Id,
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
            
            Quote_Logos__c qlogo = new Quote_Logos__c(
                Name = 'Urology',
                URL__c = '/servlet/servlet.ImageServer?id=015c00000008Zt3&oid=00Dc0000003vErY',
                Footer__c = '/servlet/servlet.ImageServer?id=015c00000008Zt3&oid=00Dc0000003vErY',
                Quote_Page__c = 'PP_Print_Quote'
            );
            insert qlogo;
            
            Label_Translation__c lt = new Label_Translation__c();
            lt.Label_Name__c = 'EMEA_Phone_Number';
            lt.Translated_Value__c = 'Tel.';
            insert lt;
            
            
            PageReference pageRef2 = Page.PP_Print_Center; // new PageReference('/apex/PP_Print_Center?');
            pageRef2.getParameters().put('id', pq.Id);
            //system.debug('PRF Page' + pageRef2);
            Test.setCurrentPage(pageRef2);
            
            PP_Print_Center pctest = new PP_Print_Center();
            pctest.cancel();
            pctest.getpq();
            pctest.getsm();
            pctest.preview();
            pctest.print();
            pctest.sendReport();
            pctest.save();
            pctest.saveFile();
            boolean bccCheck = pctest.bccCheck;
            //pctest.getSecurity();
            
            pctest.send();
            pctest.sendEmail();
            pctest.noEmail();
            pctest.doCancel();
            
            PageReference pageRef3 = new PageReference('/apex/PP_Print_Quote?r=pdf&id=' + pq.Id);
            //system.debug('PRF Page' + pageRef3);
            Test.setCurrentPage(pageRef3);
            
            PP_Print_Quote pqtest = new PP_Print_Quote();
            string pdfFileName = pqtest.pdfFileName;
            string qURL = pqtest.qURL;
            //pqgettest = pqtest.pq;
            //pqgettest = pqtest.pqRec;
            pqtest.getpqli();
            pqtest.getsm();
            pqtest.getpqli_export();
            pqtest.getApproversList();
            pqtest.getGroupedLineItemsMap();
            pqtest.getSoldToAccount();
            pqtest.getLabelsMap(new List<Label_Translation__c>{lt});
            string rpdf = pqtest.r;
            string uRegion = pqtest.userRegion;
            string myOrgId = pqtest.OrgId;
            //string userRegion = 'Canada';
            //System.assertEquals(userRegion,'Canada');
           
            pq.Language__c = 'Czech';
            update pq;
            pageRef3 = new PageReference('/apex/PP_Print_Quote?rs=xls&id=' + pq.Id);
            Test.setCurrentPage(pageRef3);
            new PP_Print_Quote();
            
            pq.Language__c = 'Slovak';
            update pq;
            pageRef3 = new PageReference('/apex/PP_Print_Quote?rs=xls&id=' + pq.Id);
            Test.setCurrentPage(pageRef3);
            new PP_Print_Quote();
            
            pq.Language__c = 'Portugal_European';
            update pq;
            pageRef3 = new PageReference('/apex/PP_Print_Quote?rs=xls&id=' + pq.Id);
            Test.setCurrentPage(pageRef3);
            new PP_Print_Quote();
            
            pq.Language__c = 'Polish';
            update pq;
            pageRef3 = new PageReference('/apex/PP_Print_Quote?rs=xls&id=' + pq.Id);
            Test.setCurrentPage(pageRef3);
            new PP_Print_Quote();
            
                        
        } 
    }
    
    
    @istest static void Test_Print_Quote_Language(){
        
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
            username='unit.test@unit.teleflex.com'
        );
        insert u;
        
        Standard_Text__c st = new Standard_Text__c();
        st.Name = 'TestStandardText';
        st.Sales_Org__c = 'AU10';
        insert st;
        
        System.runAs(u){
            
            Account a = new Account(
                Name = 'Test PP Account', 
                SAP_Sold_To__c ='100123', 
                ShippingStreet='123 Main Street ', 
                ShippingCity='Raleigh',
                ShippingState='NC', 
                ShippingPostalCode='27614',
                Customer_Group__c = '19'
            );
            insert a;
            
            Contact c = new Contact(
                FirstName='Test',
                lastname = 'Marcus',
                AccountId = a.id,
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                
                Email = 'abc@123.com'
            );
            insert c;
            
            Price_Quote__c pq = new Price_Quote__c( 
                Account_Name__c = a.id,
                Contact_Name__c = c.id,
                Ownerid = u.id,
                Expiration_Date__c = Date.today(),
                Stationary__c = 'Urology',
                Sales_Org_Key__c = 'AU1010',
                Sold_To__c = '100123',
                BusinessUnit__c = 'EMEA'
            );
            insert pq;            
            
            PageReference pageRef3 = new PageReference('/apex/PP_Print_Quote?r=pdf&id=' + pq.Id);
            Test.setCurrentPage(pageRef3);
            new PP_Print_Quote();

            a.Language__c = 'French';
            update a;
            new PP_Print_Quote();
            
            a.Language__c = 'Spanish';
            update a;
            new PP_Print_Quote();
            
            a.Language__c = 'German';
            update a;
            new PP_Print_Quote();
            
            a.Language__c = 'Dutch';
            update a;
            new PP_Print_Quote();
            
             a.Language__c = 'Czech';
            update a;
            new PP_Print_Quote();
            
             a.Language__c = 'Slovak';
            update a;
            new PP_Print_Quote();
            
            a.Language__c = 'Portugal_European';
            update a;
            new PP_Print_Quote();
            
            a.Language__c = 'Polish';
            update a;
            new PP_Print_Quote();
            
        } 
    }
   
     @istest static void Test_Print_Center_Language(){
        
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
            username='unit.test@unit.teleflex.com'
        );
        insert u;
        
        Standard_Text__c st = new Standard_Text__c();
        st.Name = 'TestStandardText';
        st.Sales_Org__c = 'AU10';
        insert st;
        
        System.runAs(u){
            
            Account a = new Account(
                Name = 'Test PP Account', 
                SAP_Sold_To__c ='100123', 
                ShippingStreet='123 Main Street ', 
                ShippingCity='Raleigh',
                ShippingState='NC', 
                ShippingPostalCode='27614',
                Customer_Group__c = '19'
            );
            insert a;
            
            Contact c = new Contact(
                FirstName='Test',
                lastname = 'Marcus',
                AccountId = a.id,
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                
                Email = 'abc@123.com'
            );
            insert c;
            
            Price_Quote__c pq = new Price_Quote__c( 
                Account_Name__c = a.id,
                Contact_Name__c = c.id,
                Ownerid = u.id,
                Expiration_Date__c = Date.today(),
                Stationary__c = 'Urology',
                Sales_Org_Key__c = 'AU1010',
                Sold_To__c = '100123',
                BusinessUnit__c = 'EMEA'
            );
            insert pq;            
            
            PageReference pageRef2 = Page.PP_Print_Center;
            pageRef2.getParameters().put('id', pq.Id);
            Test.setCurrentPage(pageRef2);
            
            pq.Language__c = 'French';
            update pq;
            PP_Print_Center pp = new PP_Print_Center();
            String lang = pp.lang;
            
            pq.Language__c = 'Spanish';
            update pq;
            pp = new PP_Print_Center();
            lang = pp.lang;
            
            pq.Language__c = 'German';
            update pq;
            pp = new PP_Print_Center();
            lang = pp.lang;
            
            pq.Language__c = 'Dutch';
            update pq;
            pp = new PP_Print_Center();
            lang = pp.lang;
            
            pq.Language__c = 'Czech';
            update pq;
            pp = new PP_Print_Center();
            lang = pp.lang;
            
            pq.Language__c = 'Slovak';
            update pq;
            pp = new PP_Print_Center();
            lang = pp.lang;
            
            pq.Language__c = 'Portugal_European';
            update pq;
            pp = new PP_Print_Center();
            lang = pp.lang;
            
            pq.Language__c = 'Polish';
            update pq;
            pp = new PP_Print_Center();
            lang = pp.lang;

        } 
    }
   
}