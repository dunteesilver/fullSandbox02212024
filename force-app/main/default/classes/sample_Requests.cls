/*********************************************************************
* Description      : Class to handle logic for Sample Request Process.
* Test Classes     : sample_Requests_Test
* VisualForce      : sample_Requests
* Author(s)        : Dun Silver
**********************************************************************/

public class sample_Requests {

    // Test Class: sample_Requests_Test

    private ApexPages.StandardController controller;

    public String searchStr {get; set;}
    public boolean step1 {get; set;}
    public boolean SkipVFPage {get; set;}
    public Boolean isLoaner{get;set;} //get Type value to rerender fields for Loaner process
    public String setUofM {get;set;} //used to set Unit of Measure based on type selection
    public String setShippingMethod {get;set;} //used to hold shipping method value.
    public String salesOrgKey {get;set;} //used to hold Active Sales Org Key of user
    public boolean latamUser {get{
        string userRole;
        try{
            //userRole = [SELECT Name FROM UserRole WHERE Id =:UserInfo.getUserRoleId()].Name;
            //userRole = userRole.left(5);
            salesOrgKey = [SELECT Id, Active_Sales_Org_Key__c
                    	  FROM Contract_User__c
                          WHERE User__c = :UserInfo.getUserId() LIMIT 1].Active_Sales_Org_Key__c;
            
            System.debug('*** salesOrgKey getter *** ' + salesOrgKey);
        }
        catch(Exception e) {
        }

        //check salesOrgKey to determine user
        system.debug(salesOrgKey);
        if(salesOrgKey == 'US6010' || salesOrgKey == 'CA1010' || salesOrgKey == 'AU1010' || salesOrgKey == 'NZ1010' || salesOrgKey == 'US103010'){
            return FALSE;
        }
        else{
            return TRUE;
        }
        /*
        if(userRole == 'Latin'){
            return TRUE;
        }
        else{
            return FALSE;
        }
		*/
    } set;}
    public Id tnId {get; set;}
    public Id tid {get; set;}

    public list<Territory_Master__c> tmList {get; set;}
    public list<Account> aList {get; set;}
    public Sample_Request__c newSample {get; set;}

    public sample_Requests(ApexPages.StandardController controller) {
        system.debug('*** setUofM *** ' + setUofM);
        System.debug('*** latamUser Sample Request Constructor *** ' + latamUser);
        setUofM = 'Default';
        if(setShippingMethod == NULL){
            setShippingMethod = 'Standard';
        }
        
        //setShippingMethod = newSample.Shipping_Method__c;
        newSample = new Sample_Request__c(); // Sample Request object
        tmList = new list<Territory_Master__c>(); // List of Territory Master records returned in Search
        aList = new list<Account>(); // List of Accounts records returned in Search
        step1 = FALSE; // This Drives whether the user goes straight to the form or to the Territory Search Page
        SkipVFPage = False ;//This is for Latin America Users that goes to Standard Page
        boolean laTest = FALSE; // Determines if the user picks the Latam Sample Request record type

        // Skip #1 - If user picks the Latam Sample Request record type this will use the LATAM process
        if(ApexPages.currentPage().getParameters().get('RecordType') != NULL){
            string recType = [SELECT Name FROM RecordType WHERE Id =:ApexPages.currentPage().getParameters().get('RecordType')].Name;
            if(recType == 'Latam Sample Request'){
                laTest = TRUE;
            }
        }

        // Standard Sales/Territory User Process
        System.debug('*** latamUser *** '+latamUser+' *** laTest *** '+laTest);
        if(latamUser == FALSE && laTest == FALSE){
            // Let's Check to see if the User has a related Territory
            for(Territory_User__c tu : [SELECT Territory_Master__c, Territory_Number__c, Territory_Master__r.Manager__c
                                        FROM Territory_User__c
                                        WHERE User__c =:UserInfo.getUserId()
                                        AND Primary__c = TRUE])
            {
              //check from clinical 900 territory numbers
              String tNumber = tu.Territory_Number__c;
              System.debug('*** tNumber *** ' + tNumber);
              if(tNumber.left(1) == '9'){
                System.debug('*** Left Most Number is 9 ***');
                tnId = NULL;
              }
              else{
                tnId = tu.Territory_Master__c;
              }

            }
        }

        // Determine whether to show the Sales User the territory search page or not
        if(ApexPages.currentPage().getParameters().get('tid') != NULL){
            // Provided by the Territory Search Page
            tid = ApexPages.currentPage().getParameters().get('tid');
        }
        else if(tnId != NULL){
            // User has an associated Territory
            tid = tnId;
        }

        // Step #2 - Show the Form
        if(tid != NULL){
            // LATAM Record Type users the Account
            // recordtype id 01244000000g54o (Latam Sample Request)
            if(latamUser){
                for(Account a : [SELECT Id, SAP_Code__c, ShippingAddress, ShippingCity, ShippingCountry,
                                 ShippingPostalCode, ShippingState, ShippingStreet
                                 FROM Account
                                 WHERE Id = :tid])
                {
                    newSample.Account__c = a.Id;
                    newSample.Shipping_Method__c = setShippingMethod;
                    newSample.Default_Quantity__c = 1;
                    newSample.Default_Unit_of_Measure__c = 'Default';
                    newSample.Shipping_Address_1__c = a.ShippingStreet;
                    newSample.Shipping_City__c = a.ShippingCity;
                    newSample.Shipping_State__c = a.ShippingState;
                    newSample.Shipping_Zipcode__c = a.ShippingPostalCode;
                    newSample.Shipping_Country__c = a.ShippingCountry;
                    newSample.RecordTypeId = '01244000000g54o';
                    newSample.Sales_Org_Key__c = salesOrgKey;
                }
            }
            // Standard 'Sample Request' record type uses the Territory Master
            else{ //Standard RecordtypeId 01244000000g56p (Sample Request)
                for(Territory_Master__c tm : [SELECT Territory_Number__c, Shipping_Street__c, Shipping_City__c,
                                              Shipping_State__c, Shipping_Postal_Code__c, Shipping_Country__c, Territory_Name_2__c,
                                              Territory_Name__c, Manager__c
                                              FROM Territory_Master__c
                                              WHERE Id = :tid])
                {
                    newSample.Territory__c = tid;
                    newSample.Shipping_Method__c = setShippingMethod;
                    newSample.Default_Quantity__c = 1;
                    newSample.Default_Unit_of_Measure__c = setUofM;
                    newSample.Shipping_Address_1__c = tm.Shipping_Street__c;
                    newSample.Shipping_City__c = tm.Shipping_City__c;
                    newSample.Shipping_State__c = tm.Shipping_State__c;
                    newSample.Shipping_Zipcode__c = tm.Shipping_Postal_Code__c;
                    newSample.Shipping_Country__c = tm.Shipping_Country__c;
                    newSample.TerritoryManager__c = tm.Manager__c;
                    newSample.RecordTypeId = '01244000000g56p';
                    newSample.Sales_Org_Key__c = salesOrgKey;
                }
            }

        }
        else{
            // This Forces the Territory or Account Search Page depending on the role
            step1 = TRUE;
        }

        // Populate the Search Results List based on the search term.
        //string srchString = ApexPages.currentPage().getParameters().get('s') + '%';
        searchStr = ApexPages.currentPage().getParameters().get('s');

        if(searchStr != NULL){
            if(latamUser){
                for(Account a : [SELECT Id, Name, SAP_Code__c, ShippingAddress, ShippingCity, ShippingCountry,
                                 ShippingPostalCode, ShippingState, ShippingStreet
                                 FROM Account
                                 //WHERE SAP_Code__c = :srchString])
                                 WHERE SAP_Code__c LIKE :searchStr OR
                                 Name LIKE :searchStr + '%'])
                {
                    if(a.SAP_Code__c != NULL){
                        aList.add(a);
                    }
                }
            }//end if(latamUser)
            else{
                for(Territory_Master__c tm : [SELECT Id, Territory_Number__c, Shipping_Street__c, Shipping_City__c,
                                              Shipping_State__c, Shipping_Postal_Code__c, Shipping_Country__c, Territory_Name_2__c,
                                              Territory_Name__c, Manager__c
                                              FROM Territory_Master__c
                                              WHERE Territory_Number__c =:searchStr])
                {
                    tmList.add(tm);
                }
            }//end else
        }

        if(newSample.Type__c == 'Loaner'){
          System.debug('*** Setting Loaner to TRUE ***');
          isLoaner = TRUE;
        }
        else{
            System.debug('*** Setting Loaner to FALSE ***');
            isLoaner = FALSE;
        }
    }//end of constructor

    public pagereference search(){
        if(searchStr != NULL){
            return new Pagereference('/apex/sample_Requests?s=' + searchStr).setRedirect(True);
        }
        else{
            return NULL;
        }
    }
    
    public pagereference save(){
        try{
            newSample.Sales_Org_Key__c = salesOrgKey;
            System.debug('*** newSample.Sales_Org_Key__c sample_Requests save() *** ' + newSample.Sales_Org_Key__c);
            if(newSample.Sales_Org_Key__c == NULL){
                if(latamUser){
                    newSample.Sales_Org_Key__c = 'US6020';
                }
                else if(newSample.Shipping_Country__c == 'US'){
                    newSample.Sales_Org_Key__c = 'US6010';
                }
                else if(newSample.Shipping_Country__c == 'CA'){
                    newSample.Sales_Org_Key__c = 'CA1010';
                }
                else if(newSample.Shipping_Country__c == 'AU'){
                    newSample.Sales_Org_Key__c = 'AU1010';
                }
                else if(newSample.Shipping_Country__c == 'NZ'){
                    newSample.Sales_Org_Key__c = 'NZ1010';
                }
                else{
                    newSample.Sales_Org_Key__c = 'US6010';
                }
            }//end if
            
            insert newSample;
            return new Pagereference('/' + newSample.Id).setRedirect(True);
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'All Shipping Information Must Be Completed... See asterisks below.'));
            return null;
        }
        
    }//end save() method

    public static void lineItemAdd(String newLines, String recId){
        string pUOM;
        list<Sample_Request_Line_Item__c> newSRLI = new list<Sample_Request_Line_Item__c>();
        Sample_Request__c sampleRec = [SELECT Name, Default_Quantity__c, Default_Unit_of_Measure__c, Sales_Org_Key__c
                                       FROM Sample_Request__c
                                       WHERE Id =:recId
                                       LIMIT 1];
        Product2 srMaterial = [SELECT Id, Name, Sales_Unit__c, Sales_Org_Key__c
                               FROM Product2
                               WHERE Id =:newLines AND Sales_Org_Key__c =:sampleRec.Sales_Org_Key__c LIMIT 1];


        if(sampleRec.Default_Unit_of_Measure__c == 'EACH'){
            pUOM = 'EA';
        }
        else if(srMaterial.Sales_Unit__c != NULL){
            pUOM = srMaterial.Sales_Unit__c;
        }
        
        Sample_Request_Line_Item__c insSTLI = new Sample_Request_Line_Item__c(
            Sample_Request__c = recId,
            Material__c = srMaterial.Id,
            Quantity__c = sampleRec.Default_Quantity__c,
            UOM__c = pUOM,
            Sales_Org_Key__c = srMaterial.Sales_Org_Key__c
        );

        insert insSTLI;
        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, srMaterial.Name + ' added to Sample Request: ' + sampleRec.Name));

    }
    
    public static void lineItemBulk(List<Product2> srMaterials, String recId){
        string pUOM;
        
        Sample_Request__c sampleRec = [SELECT Name, Default_Quantity__c, Default_Unit_of_Measure__c, Sales_Org_Key__c
                                       FROM Sample_Request__c
                                       WHERE Id =:recId
                                       LIMIT 1];
        
        List<Sample_Request_Line_Item__c> insSTLIs = new List<Sample_Request_Line_Item__c>();
        for(Product2 srMaterial: srMaterials){
            if(sampleRec.Default_Unit_of_Measure__c == 'EACH'){
            	pUOM = 'EA';
            }
            else if(srMaterial.Sales_Unit__c != NULL){
                pUOM = srMaterial.Sales_Unit__c;
            }
            Sample_Request_Line_Item__c insSTLI = new Sample_Request_Line_Item__c(
                Sample_Request__c = recId,
                Material__c = srMaterial.Id,
                Quantity__c = sampleRec.Default_Quantity__c,
                UOM__c = pUOM,
                Sales_Org_Key__c = srMaterial.Sales_Org_Key__c
            );
            insSTLIs.add(insSTLI);
        }

        insert insSTLIs;
        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, insSTLIs.size() +' Materials added to Sample Request: ' + sampleRec.Name));

    }

    //method to handle the loaner process
    public PageReference updateType(){
        system.debug('*** newSample.Shipping_Method__c *** ' + newSample.Shipping_Method__c);
        if(!latamuser){
            if(newSample.Type__c == 'Disposable/Single Use Demo Product (i.e., Not for Human Use)' ||
              newSample.Type__c == 'Disposable/Single Use Product Evaluation - Eaches'){
                system.debug('*** Is Disp/Single Use Demo OR Eval - Eaches ***');
                setUofM = 'Each';
                isLoaner = FALSE;
                updateUofM();
            }
            else if(newSample.Type__c == 'Loaner'){
                isLoaner = TRUE;
            }
            else{
                system.debug('*** Is Not Disp/Single Use Demo ***');
                setUofM = 'Default';
                isLoaner = FALSE;
                updateUofM();
            }    
        }//end of outter if Latam User check
        
        return null;
    }

    //method to update to Territory Address
    public PageReference updateAddressToTerritory(){
      System.debug('*** Set Territory Address ***');
      try{
          Territory_Master__c tm = [SELECT Territory_Number__c, Shipping_Street__c, Shipping_City__c,
                                    Shipping_State__c, Shipping_Postal_Code__c, Shipping_Country__c, Territory_Name_2__c,
                                    Territory_Name__c, Manager__c
                                    FROM Territory_Master__c
                                    WHERE Id =:tid];
    
          newSample.Territory__c = tid;
          //newSample.Default_Quantity__c = 1;
          //newSample.Default_Unit_of_Measure__c = 'Default';
          newSample.Shipping_Address_1__c = tm.Shipping_Street__c;
          newSample.Shipping_City__c = tm.Shipping_City__c;
          newSample.Shipping_State__c = tm.Shipping_State__c;
          newSample.Shipping_Zipcode__c = tm.Shipping_Postal_Code__c;
          newSample.Shipping_Country__c = tm.Shipping_Country__c;
          newSample.TerritoryManager__c = tm.Manager__c;
      }
      catch(Exception e) {
          //return null;
      }
            
      return null;
    }
    //end of method to handle Territory Address

    //method to update to Territory Address
    public PageReference updateAddressToAccount(){
            System.debug('*** Set Account Address ***');
      System.debug('*** newSample.Account__c *** ' + newSample.Account__c);

      if(newSample.Account__c != NULL){
        Account myAccount = [SELECT Id, Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
                             FROM Account WHERE Id = :newSample.Account__c];

        newSample.Shipping_Address_1__c = myAccount.ShippingStreet;
        newSample.Shipping_City__c = myAccount.ShippingCity;
        newSample.Shipping_State__c = myAccount.ShippingState;
        newSample.Shipping_Zipcode__c = myAccount.ShippingPostalCode;
        newSample.Shipping_Country__c = myAccount.ShippingCountry;

        return null;
      }
      else{
        System.debug('*** Assign Territory Data in updateAddressToAccount else ***');
        updateAddressToTerritory();
        return null;
      }//end else
    }
    //end of method to handle Account Address

    //method to update Default Unit of Measure based on Type selected
    public PageReference updateUofM(){
        newSample.Default_Unit_of_Measure__c = setUofM;
        return null;
    }
    
    //method to update to Territory Address
    public PageReference updateAddressToLead(){
            System.debug('*** Set Lead Address ***');
      System.debug('*** newSample.Lead__c *** ' + newSample.Lead__c);

      if(newSample.Lead__c != NULL){
        //System.debug('*** newSample.Lead__c *** ' + newSample.Lead__c);
        Lead l = [SELECT Id, Name, Street, City,
                  State, PostalCode, Country
                  FROM Lead
                  WHERE Id = :newSample.Lead__c];

        newSample.Territory__c = tid;
        //newSample.Default_Unit_of_Measure__c = 'Default';
        newSample.Shipping_Address_1__c = l.Street;
        newSample.Shipping_City__c = l.City;
        newSample.Shipping_State__c = l.State;
        newSample.Shipping_Zipcode__c = l.PostalCode;
        newSample.Shipping_Country__c = l.Country;

        return null;
      }
      else{
        System.debug('*** Assign Territory Data in updateAddressToLead else ***');
        updateAddressToTerritory();

        return null;
      }//end else
    }
    //end of method to handle Lead Address
    
    //method to update to Territory Address
    public PageReference updateAddressToContact(){
            System.debug('*** Set Contact Address ***');
      System.debug('*** newSample.Contact__c *** ' + newSample.Contact__c);

      if(newSample.Contact__c != NULL){
        Contact myContact = [SELECT Id, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
                             FROM Contact WHERE Id = :newSample.Contact__c];

        newSample.Shipping_Address_1__c = myContact.MailingStreet;
        newSample.Shipping_City__c = myContact.MailingCity;
        newSample.Shipping_State__c = myContact.MailingState;
        newSample.Shipping_Zipcode__c = myContact.MailingPostalCode;
        newSample.Shipping_Country__c = myContact.MailingCountry;

        return null;
      }
      else{
        System.debug('*** Assign Territory Data in updateAddressToAccount else ***');
        updateAddressToTerritory();
        return null;
      }//end else
    }
    //end of method to handle Account Address
    
    //function to update shipping method
    public PageReference updateShippingMethod(){
        setShippingMethod = newSample.Shipping_Method__c;
        return null;
    }
}