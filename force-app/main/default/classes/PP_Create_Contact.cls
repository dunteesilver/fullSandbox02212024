/*********************************************************************
* Description     : Controller Class is used for PP_Create_Contact Page
* Test Class      : PP_Create_Contact_Test
* VisualForce     : PP_Create_Contact
* Author          : Dun Silver, Eric Clay
**********************************************************************/

Public without sharing class PP_Create_Contact{

    public String strCust{get; set;}
    public Account accountInfo {get; set;} //holds custList account info
    public Contract_Partnership__c soldToAcc {get; set;} //holds custList account info
    public Contact contactRec {get; set;}
    public boolean displayPopup {get; set;}
    public string salesCurrency {get; set;}
    public string salesOrgKey {get; set;}
    public Contract_User__c contractUserRec {get; set;}
    Public Boolean emeaUserFlag {get; set;}
    public Account soldToAccObj {get;set;}
    public String soldToAccStr;
    public String soldToPriceListType;
    //get owner's current bu setting on user record
    public String userBu {get{
        userBu = [Select Id, Business_Unit__c FROM User
                 WHERE id =:UserInfo.getUserId() LIMIT 1].Business_Unit__c;
        return userBu;
    }set;}
    //end of getter setters to handle User bu change
    
    public PP_Create_Contact() {
        contactRec = new Contact();
        strCust = ApexPages.currentPage().getParameters().get('cid');
        string aid = ApexPages.currentPage().getParameters().get('id');
        String sapCode = ApexPages.currentPage().getParameters().get('sap');
        System.debug('*** PP_Create_Contact constructor strCust *** ' + strCust);
        System.debug('*** PP_Create_Contact constructor aid *** ' + aid);
        System.debug('*** PP_Create_Contact constructor sapCode *** ' + sapCode);
        
       
        
        contractUserRec = [SELECT Active_Currency__c, Active_Sales_Org_Key__c, Pricing_Tier_Access__c
                                FROM Contract_User__c
                                WHERE User__c = :UserInfo.getUserId()
                                LIMIT 1];

        //contractUserRec = cu;
        salesCurrency = contractUserRec.Active_Currency__c;
        salesOrgKey = contractUserRec.Active_Sales_Org_Key__c;
        Sales_Orgs__c  srkey = Sales_Orgs__c.getInstance(salesOrgKey);
        emeaUserFlag = false;
        if(srkey?.Region__c !='' && srkey?.Region__c =='EMEA'){
            emeaUserFlag = true;

        }else{
            emeaUserFlag = false;
        }
        //query Account for Customer's info using SAP Code
        if(strCust != NULL){
            accountInfo = [SELECT Name, Id, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Main_GPO__c,
                            Sap_Sold_to__c, Account_Group__c, Price_List_Type__c, Language__c, CurrencyIsoCode
                           FROM Account
                           WHERE SAP_Sold_To__c = :strCust
                           LIMIT 1 FOR VIEW];

            System.debug('*** PP_Create_Contact Constructor accountInfo using SAP Code *** ' + accountInfo);
        }
        else if(aid != NULL){
            accountInfo = [SELECT Name, Id, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Main_GPO__c,
                            Sap_Sold_to__c, Account_Group__c, Price_List_Type__c, Language__c, CurrencyIsoCode
                           FROM Account
                           WHERE Id  = :aid
                           LIMIT 1 FOR VIEW];

            strCust = accountInfo.Sap_Sold_To__c; //setting strCust value
            System.debug('*** PP_Create_Contact Constructor accountInfo using Account ID *** ' + accountInfo);
        }

        //creating list to avoid null exception
        List<Contract_Partnership__c> soldToAccCheck = new List<Contract_Partnership__c>();
        //checks if account is ship-to
        if(accountInfo.Account_Group__c !=null && accountInfo.Account_Group__c == 'Z002' ){
            System.debug('*** PP_Create_Contact Constructor Account Group is ZOO2 (Ship-To) *** ');
            soldToAccCheck = [SELECT Id, Key__c, Disabled__c, Sale_to__c, Ship_to__c
                            FROM Contract_Partnership__c 
                            WHERE Ship_to__c = :strCust
                            AND Disabled__c = FALSE
                            LIMIT 1];

            if(soldToAccCheck.size() > 0){
                System.debug('*** PP_Create_Contact Constructor Account has a Sold-To *** ');
                //soldToAcc = soldToAccCheck[0];
                soldToAccStr = soldToAccCheck[0].Sale_to__c;
                System.debug('*** PP_Create_Contact Constructor soldToAcc *** ' + soldToAccCheck[0]);
            }
            else{
                System.debug('*** PP_Create_Contact Constructor soldToAcc is NULL *** ');
                soldToAccStr = strCust;
            }
        }
        else{
            System.debug('*** PP_Create_Contact Constructor Account Group is ZOO1 (Sale-To) *** ');
            soldToAccStr = strCust;
            soldToPriceListType = accountInfo.Price_List_Type__c;
        }

        //getting account information for Sold-To if available
        //if not available... make Sold-To current account
        if( soldToAccCheck.size() > 0 ){
            System.debug('*** PP_Create_Contact Constructor getting Price List Type of Sale-To *** ');
            soldToAccObj = [SELECT Name, Id, ShippingStreet, ShippingCity, ShippingState, Main_GPO__c,
            ShippingPostalCode, Sap_Sold_to__c,Account_Group__c, Price_List_Type__c, Language__c, CurrencyIsoCode
            FROM Account
            WHERE Sap_Sold_to__c = :soldToAccStr
            LIMIT 1 FOR VIEW];

            soldToPriceListType = soldToAccObj.Price_List_Type__c;
        }
        else{
            System.debug('*** PP_Create_Contact Constructor Sold-To is same as Ship-To ***');
            soldToAccObj = accountInfo;
        }
        
    }//end of constructor

    //get list of user's BU Contacts
    public List<Contact> getMyBuContacts(){
      System.debug('*** userBu in getMyBuContacts *** ' + userBu );
        List<Contact> buCons = [SELECT Name, FirstName, Email,OwnerId, Phone, Business_Unit1__c, Position_Job_Title__c,
                                Position_Job_Title_ANZ__c,Credentials__c,Preferred_language__c,Title, AccountId,
                                EMEA_Department__c, EMEA_Position_Job_Title__c
                                FROM Contact
                                WHERE AccountId =: ApexPages.currentPage().getParameters().get('id')
                                AND Contact.Business_Unit1__c INCLUDES (:userBu)
                                ORDER BY Name ASC 
                                LIMIT 1000];

      System.debug('*** buCons.size() *** ' + buCons.size() );
      return buCons;
    }

    //get list of Account's Contacts
    public List<Contact> getAcctContacts(){
        System.debug('*** myUserBu in getAcctContacts *** ' + userBu );
        List<Contact> accCons = [SELECT Name, FirstName, Email,OwnerId, Phone, Business_Unit1__c, Position_Job_Title__c,
                                 Position_Job_Title_ANZ__c,Credentials__c,Preferred_language__c, Title, AccountId,
                                 EMEA_Department__c, EMEA_Position_Job_Title__c
                                 FROM Contact
                                 WHERE AccountId =: ApexPages.currentPage().getParameters().get('id')
                                 AND Contact.Business_Unit1__c EXCLUDES (:userBu)
                                 ORDER BY Name ASC
                                 LIMIT 1000];

      System.debug('*** accCons.size() *** ' + accCons.size() );
      return accCons;
    }

    public void closePopup() {
        displayPopup = false;
    }

    public void showPopup() {
        displayPopup = true;
        system.debug('*****displayPopup****'+displayPopup);
    }

    public PageReference processSelectContact(){
        System.debug('*** userBu *** ' + userBu);
        //System.debug('*** myUserBu *** ' + myUserBu);
        string url;
        pageReference objP;

        try{
          if(ApexPages.currentPage().getParameters().get('pqId') != NULL && ApexPages.currentPage().getParameters().get('pqId') != ''){
            system.debug('Creating Quote from Clone Quote button');
            PP_Create_Contact clone = new PP_Create_Contact();
            clone.doCloning();
            List<Price_Quote__c> latest = [SELECT Id FROM Price_Quote__c ORDER BY CreatedDate DESC LIMIT 1];
            system.debug('New Quote Id: ' + latest[0].Id + ' Old Quote Id: a0Sc0000002ILGrEAO');
            PageReference newQuote = new Pagereference('/apex/PP_Price_Quote?pqId=' + latest[0].Id + '&refresh=yes').setRedirect(True);
            return newQuote;
          }
          else{
            if(ApexPages.currentPage().getParameters().get('PRF') != NULL && ApexPages.currentPage().getParameters().get('PRF') != ''){
              system.debug('Creating Quote from PRF');
                url = '/apex/PP_PRF_Edit?step=3&aid=' + ApexPages.currentPage().getParameters().get('id') + '&cid=' + ApexPages.currentPage().getParameters().get('contId') +
                    '&salesOrgKey=' + salesOrgKey;
            }
            else{
                String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
                /*
                if(soldToAcc.Sale_to__c == NULL){
                    System.debug('*** PP_Create_Contact processSelectContact Sale-to is Null ***');
                    soldToAccStr = accountInfo.Sap_Sold_To__c;
                    soldToPriceListType = accountInfo.Price_List_Type__c;

                }
                else{
                    System.debug('*** PP_Create_Contact processSelectContact Setting Sale-to Value ***');
                    soldToAccStr = soldToAccObj.Sap_Sold_To__c;
                    soldToPriceListType = soldToAccObj.Price_List_Type__c;
                }
                */
                system.debug('Creating Quote from Scratch');
                system.debug('*** salesCurrency *** ' + salesCurrency);

                Date anzDate = system.today() +30; //date for ANZ
                Date allDate = system.today() +90; //date for Other BUs
                Integer currentYear = System.Today().year(); //used to build expiration date for EMEA
                Date emeaDate = Date.newInstance(currentYear+1, 12, 31); //set expiration date for EMEA after December 01st 
                Date checkEmeaDate =Date.newInstance(currentYear, 12, 01);
               
                PP_Menu menu = new PP_Menu();
				System.debug('*** PP_Create_Contact processSelectContact Account ID or SAP *** ' + ApexPages.currentPage().getParameters().get('id'));
                System.debug('*** PP_Create_Contact processSelectContact soldToAccStr *** ' + soldToAccStr );
                System.debug('*** PP_Create_Contact processSelectContact soldToPriceListType *** ' + soldToPriceListType );
                Price_Quote__c priceQuote = new Price_Quote__c(
                    Account_Name__c = ApexPages.currentPage().getParameters().get('id'),
                    Contact_Name__c =  ApexPages.currentPage().getParameters().get('contId'),
                    Sold_To__c = ApexPages.currentPage().getParameters().get('soldTo'),
                    Date__c = system.today(),
                    //Expiration_Date__c = system.today() +90,
                    CurrencyIsoCode = salesCurrency,
                    Sales_Org_Key__c = salesOrgKey,
                    No_Opp__c = TRUE,
                    BusinessUnit__c = userBu,
                    How_Created__c = userAgent + ' From Scratch',
                    Sold_To_Price_List_Type__c = ApexPages.currentPage().getParameters().get('soldToPriceListType'),
                    Language__c = accountInfo.Language__c,
                    Pricing_Tier_Level__c = contractUserRec.Pricing_Tier_Access__c
                );

                //logic to handle ANZ Price Quotes
                if(userBu == 'Australia' || userBu == 'New Zealand'){
                    priceQuote.Expiration_Date__c = anzDate;
                }
                else if(userBu == 'EMEA'){
                    //if(Date.Today()>=checkEmeaDate){
                    //String emeaD = '31/12/'+currentYear;
                   // Date d = Date.valueOf(emeaD)
                       priceQuote.Expiration_Date__c =  Date.newInstance(currentYear, 12, 31);
                    /*}else{
                    priceQuote.Expiration_Date__c = anzDate;
                    }*/
                }
                else{
                    priceQuote.Expiration_Date__c = allDate;
                }
                
                if(userBu == 'Commercial Operations'){
                    System.debug('*** userBu in Scratch *** ' + userBu);
                   userBu = 'Vascular';
                   priceQuote.BusinessUnit__c = 'Vascular'; 
                }
                else{
                   priceQuote.BusinessUnit__c = userBu;
                }

                System.debug('???soldToAccObj'+ soldToAccObj);
                //updating currency for EMEA Process to Sold-To Account's Currency
                if(userBu == 'EMEA'){
                    priceQuote.CurrencyIsoCode = soldToAccObj.CurrencyIsoCode;    
                }

                //check for Latin American User
                system.debug('salesOrgKey ' + salesOrgKey);
                if(salesOrgKey.right(2) == '20' || menu.cUser.User__r.UserRole.Name.containsIgnoreCase('EMEA')){
                  priceQuote.One_Time_Purchase__c = true;
                }

                system.debug('priceQuote Inserted: ' + priceQuote);
                if(ApexPages.currentPage().getParameters().get('id') != NULL && ApexPages.currentPage().getParameters().get('contId') != NULL){
                    insert priceQuote;
                }
                else{
                    apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.label.EMEA_Not_able_to_create_your_quote_Please_contact_someone_from_your_SF_Team));
                	return NULL;
                }


                url = '/apex/PP_Price_Quote?pqId=' + priceQuote.Id;

            }

            objP = new Pagereference(url).setRedirect(True);
          }//end else
        }
        catch(Exception ex){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, +ex.getMessage()) );
        }
        return objp;
    }

    public pageReference saveMethod() {
        string url;
        pageReference objp = NULL;
        PP_Menu menu = new PP_Menu();
        Boolean userLogicCheck = false;
        
         /* The boolean and if statements below are used when a user is creating a contact when creating a quote.
        ** NA/LATAM/ANZ/EMEA have different fields and picklist values they use when entering a contact.
        ** The logic below sets a boolean value based on the current user to manage what fields are required.
        */
        
        //logic to check user w/required fields per sales org/bu
        if(userBu == 'Australia' || userBu == 'New Zealand'){
            if(contactRec.FirstName != null && contactRec.LastName != null && contactRec.Title != null && contactRec.Email != null
            && contactRec.Preferred_language__c != null && contactRec.Position_Job_Title_ANZ__c!=null){
                userLogicCheck = true;
            }
            else{
                userLogicCheck = false;
            }
        }
        else if(userBu == 'EMEA' || emeaUserFlag){
            if(contactRec.FirstName != null && contactRec.LastName != null && contactRec.Title != null && contactRec.Email != null
            && contactRec.Preferred_language__c != null && contactRec.EMEA_Position_Job_Title__c !=null && contactRec.EMEA_Department__c != null){
                userLogicCheck = true;
            }
            else{
                userLogicCheck = false;
            }
        }
        else{ //logic below if for North America and LATAM
            if(contactRec.FirstName != null && contactRec.LastName != null && contactRec.Title != null && contactRec.Email != null
            && contactRec.Preferred_language__c != null && contactRec.Position_Job_Title__c !=null && contactRec.Credentials__c != null){
                userLogicCheck = true;
            }
            else{
                userLogicCheck = false;
            }
        }
        
        System.debug('*** userLogicCheck *** ' + userLogicCheck);
		System.debug('*** userBu saveMethod PP_Create_Contact Class *** ' + userBu);
        
        try{
            if(userLogicCheck)
            {
                System.debug('*** In saveMethod IF ***');
                contactRec.AccountId = ApexPages.currentPage().getParameters().get('id');
                
              insert contactRec;
                system.debug('contactRec: ' + contactRec);

                if(ApexPages.currentPage().getParameters().get('PRF') != NULL){
                    url = '/apex/PP_PRF_Edit?step=3&aid=' + ApexPages.currentPage().getParameters().get('id') + '&cid=' + contactRec.id;
                }
                else if(ApexPages.currentPage().getParameters().get('pqId') != NULL){
                    system.debug('Creating Quote from Clone Quote button');
                    PP_Create_Contact clone = new PP_Create_Contact();
                    clone.doCloning();
                    List<Price_Quote__c> latest = [SELECT Id FROM Price_Quote__c ORDER BY CreatedDate DESC LIMIT 1];
                    system.debug('New Quote Id: ' + latest[0].Id + ' Old Quote Id: a0Sc0000002ILGrEAO');
                    PageReference newQuote = new Pagereference('/apex/PP_Price_Quote?pqId=' + latest[0].Id + '&refresh=yes').setRedirect(True);
                    return newQuote;
                }
                else{
                    if(ApexPages.currentPage().getParameters().get('id') != NULL && contactRec.Id != NULL){
                        Date anzDate = system.today() +30; //date for ANZ
                        Date allDate = system.today() +90; //date for Other BUs
                        Integer currentYear = System.Today().year(); //used to build expiration date for EMEA
                        Date emeaDate = Date.newInstance(currentYear+1, 12, 31); //set expiration date for EMEA after December 01st 
                        Date checkEmeaDate =Date.newInstance(currentYear, 12, 01);
                         /*
                        if(soldToAcc.Sale_to__c == NULL){
                            soldToAccStr = accountInfo.Sap_Sold_To__c;
                            soldToPriceListType = accountInfo.Price_List_Type__c;
        
                        }
                        else{
                            soldToAccStr = soldToAcc.Sale_to__c;
                            soldToPriceListType = soldToAccObj.Price_List_Type__c;
                        }
                        */
                        System.debug('*** PP_Create_Contact saveMethod soldToAccStr *** ' + soldToAccStr );
                        System.debug('*** PP_Create_Contact saveMethod soldToPriceListType *** ' + soldToPriceListType );
                        Price_Quote__c priceQuote = new Price_Quote__c(
                            Account_Name__c = ApexPages.currentPage().getParameters().get('id'),
                            Contact_Name__c =  contactRec.Id,
                            Sold_To__c = ApexPages.currentPage().getParameters().get('soldTo'),
                            Date__c = system.today(),
                            //Expiration_Date__c = system.today() +90,
                            CurrencyIsoCode = salesCurrency,
                            Sales_Org_Key__c = salesOrgKey,
                            BusinessUnit__c = userBu,
                            Sold_To_Price_List_Type__c = ApexPages.currentPage().getParameters().get('soldToPriceListType'),
                            Language__c = accountInfo.Language__c
                        );
                        //logic to handle ANZ Price Quotes
                        if(userBu == 'Australia' || userBu == 'New Zealand'){
                            priceQuote.Expiration_Date__c = anzDate;
                        }
                        else if(userBu == 'EMEA'){
                          if(Date.Today()>=checkEmeaDate){
                       priceQuote.Expiration_Date__c =  emeaDate;
                    }else{
                    priceQuote.Expiration_Date__c = anzDate;
                    }
                        }
                        else{
                            priceQuote.Expiration_Date__c = allDate;
                        }
                        
                        //updating currency for EMEA Process to Sold-To Account's Currency
                        if(userBu == 'EMEA'){
                            priceQuote.CurrencyIsoCode = soldToAccObj.CurrencyIsoCode;
                        }

                        system.debug('priceQuote Inserted: ' + priceQuote);
                        system.debug('salesOrgKey ' + salesOrgKey);

                        if(salesOrgKey.right(2) == '20' || menu.cUser.User__r.UserRole.Name.containsIgnoreCase('EMEA')){
                            priceQuote.One_Time_Purchase__c = true;
                        }

                        insert priceQuote;

                        url = '/apex/PP_Price_Quote?pqId=' + priceQuote.Id;
                    }
                }

                objp = new Pagereference(url).setRedirect(True);
            }else{
                System.debug('*** In saveMethod ELSE ***');
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.label.EMEA_Please_fill_required_fields) );

            }
        }catch(Exception ex){
            System.debug('*** In CATCH ***');
            system.debug('Exception: ' + ex);
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, +ex.getMessage()) );

        }
        return objp;
    }

    //method to clone quote
    public Pagereference doCloning() {
      String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
      system.debug('userAgent ***** ' + userAgent);
        //String cloneType = Apexpages.currentpage().getParameters().get('cloneType');
        //List of line items to insert
        List<Price_Quote_Line_Item__c> newLines = new List<Price_Quote_Line_Item__c>();

        Price_Quote__c cloneQuote = new Price_Quote__c();
        List<Price_Quote_Line_Item__c> cloneLines = new List<Price_Quote_Line_Item__c>();

        if(ApexPages.currentPage().getParameters().get('pqId') != NULL){
            cloneQuote = [SELECT Name, No_Opp__c, One_Time_Purchase__c, Sales_Org_Key__c, Quote_Description__c, Shipping__c, Tax__c, Product_Class_Count__c,
                          Customer_comments__c, Internal_Comments_Only__c, CurrencyIsoCode, Opportunity__c, Line_Count__c, Type__c,
                          BusinessUnit__c, Sold_To__c, Sold_To_Price_List_Type__c
                          FROM Price_Quote__c WHERE Id =:ApexPages.currentPage().getParameters().get('pqId')];

          cloneLines = [Select id, Name, Sales_Price__c, Approval_Flag__c, Extended_Price__c,Objective__c, Director_Price__c, Floor_Price__c,
                           Quantity__c, Eligible_Price__c, Material_Status__c, Condition__c, Material_Name__r.Image_URL__c, Cost__c,
                           Sales_deal_Description__c, Sales_Number__c, Competetive_Product__r.Competitor_Product_Code__c,
                           Material_Name__r.Name,Description__c, Sales_Unit_Qty__c, Sales_Unit__c, RSM_Price__c, Row_Order__c,
                           Rep_Price__c, List_Price__c, Line_Price__c, Material_Status_Description__c, Product_Description__c, IsBold__c, CurrencyIsoCode
                           FROM Price_Quote_Line_Item__c
                           WHERE Price_Quote__c =:ApexPages.currentPage().getParameters().get('pqId')];
        }

        Savepoint sp = Database.setSavepoint();
        PageReference newPage = null;

        try {
          Price_Quote__c quoteClone = new Price_Quote__c(
              Account_Name__c = ApexPages.currentPage().getParameters().get('id'),
              Contact_Name__c  = ApexPages.currentPage().getParameters().get('contId'),
              Sold_To__c = cloneQuote.Sold_To__c,
              No_Opp__c = cloneQuote.No_Opp__c,
              One_Time_Purchase__c = cloneQuote.One_Time_Purchase__c,
              Sales_Org_Key__c = cloneQuote.Sales_Org_Key__c,
              Quote_Description__c = cloneQuote.Quote_Description__c,
              Customer_comments__c = cloneQuote.Customer_comments__c,
              Internal_Comments_Only__c = cloneQuote.Internal_Comments_Only__c,
              CurrencyIsoCode = cloneQuote.CurrencyIsoCode,
              Shipping__c = cloneQuote.Shipping__c,
              Tax__c = cloneQuote.Tax__c,
              Product_Class_Count__c = cloneQuote.Product_Class_Count__c,
              BusinessUnit__c = cloneQuote.BusinessUnit__c,
              Type__c = cloneQuote.Type__c,
              Expiration_Date__c = system.today() +90,
              How_Created__c = userAgent + ' Quote Cloned from: ' + cloneQuote.Name,
              Sold_To_Price_List_Type__c = cloneQuote.Sold_To_Price_List_Type__c,
              Language__c = accountInfo.Language__c,
              Pricing_Tier_Level__c = contractUserRec.Pricing_Tier_Access__c
              //Opportunity__c = cloneQuote.Opportunity__c
          );

          insert quoteClone;

          If(cloneQuote.Line_Count__c > 0){
            system.debug('line count ***** ' + cloneQuote.Line_Count__c);

            for(Price_Quote_Line_Item__c curr : cloneLines){
              system.debug('In Line Item Create For Loop *****');
              Price_Quote_Line_Item__c lineItems = new Price_Quote_Line_Item__c(
                  Price_Quote__c = quoteClone.Id,
                  Material_Name__c = curr.Material_Name__c,
                  Product_Description__c = curr.Product_Description__c,
                  Row_Order__c = curr.Row_Order__c,
                  Material_Status__c = curr.Material_Status__c,
                  Sales_Deal_Description__c = curr.Sales_Deal_Description__c,
                  Competetive_Product__c = curr.Competetive_Product__c,
                  List_Price__c = curr.List_Price__c,
                  RSM_Price__c = curr.RSM_Price__c,
                  Rep_Price__c = curr.Rep_Price__c,
                  Eligible_Price__c = curr.Eligible_Price__c,
                  Director_Price__c = curr.Director_Price__c,
                  Floor_Price__c = curr.Floor_Price__c,
                  Cost__c = curr.Cost__c,
                  Quantity__c = curr.Quantity__c,
                  Sales_Price__c = curr.Eligible_Price__c,
                  Sales_Number__c = curr.Sales_Number__c,
                  Condition__c = curr.Condition__c,
                  Objective__c = curr.Objective__c,
                  IsBold__c = curr.IsBold__c,
                  CurrencyIsoCode = curr.CurrencyIsoCode
              );

              newLines.add(lineItems);
            }//end of for loop

            If(newLines.size()>0){
              system.debug('Inserting Line Items ***** ');
              insert newLines;
            }
            newPage = new Pagereference('/apex/PP_Create_Contact?pqId='+quoteClone.Id).setRedirect(True);
            return newPage;
          }
        }catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        return newPage;
    }
    //end of method to clone quote

}