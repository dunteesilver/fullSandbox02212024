/*********************************************************************
* Description      : Controller Class for Customer Details.
* Test Class       : PP_Customer_Details_Test
* VisualForce      : PP_Customer_Details
* Author(s)        : Dun Silver
**********************************************************************/
Public with sharing class PP_Customer_Details{

    public Account acct {get; set;}

    public String strCust{get; set;}

    public boolean refreshpage {get; set;}
    public boolean showSoldTo {get; set;}

    public map<String, Account> CCList{get; set;}

    public set<String> cnlist{get; set;}
    public set<String> acheck{get; set;}

    public list<Account> cplist{get; set;}
    
    // New Account Team - 26Jun2018
    public list<Territory_Master__c> ATMlist {get; set;}
    public list<String> tsort {get; set;}
    public map<String, String> tSales {get; set;}
    public map<String, Territory_Master__c> atmMap {get; set;}
    public map<String, String> repMap {get; set;}
    public map<String, String> repId {get; set;}
    
    public boolean atmCheck {get; set;}
    // End New

    //get language of end user
    public String userLang{get{
        return UserInfo.getLanguage();
    }set;}

    Public String cid{get{
        return ApexPages.currentPage().getParameters().get('cid');
    } set;}

    public PP_Customer_Details(){
        system.debug('-- Starting Inner Class --');
        //String AcctNum;
        acct = new Account();
        cnlist = new set<String>();

        acheck = new set<string>();
        CCList = new map<String, Account>();
        cplist = new list<Account>();
        refreshpage = FALSE;
        showSoldTo = FALSE;

        if(ApexPages.currentPage().getParameters().get('cid') != NULL){
            acct = [SELECT Id, Name, ShippingStreet, ShippingCity, ShippingState, Terms__c,
                    ShippingPostalCode, ShippingCountry, SAP_Sold_To__c, Free_Freight_Threshold__c,
                    ERP_Active__c, Type, Customer_Group_Formula__c, Main_GPO__c, Secondary_GPO__c,
                    Last_SAP_Update__c, Agreement_Count__c, List_Price_Type__c,
                    Territory_Key__c, Account_Name_2__c
                    FROM Account
                    WHERE SAP_Sold_To__c = :ApexPages.currentPage().getParameters().get('cid')
                    LIMIT 1];

        }
        else if(ApexPages.currentPage().getParameters().get('id') != NULL){
            acct = [SELECT Id, Name, ShippingStreet, ShippingCity, ShippingState, Terms__c,
                    ShippingPostalCode, ShippingCountry, SAP_Sold_To__c, Free_Freight_Threshold__c,
                    ERP_Active__c, Type, Customer_Group_Formula__c, Main_GPO__c, Secondary_GPO__c,
                    Last_SAP_Update__c, Agreement_Count__c, List_Price_Type__c, RecordType.Name,
                    Territory_Key__c, Account_Name_2__c
                    FROM Account
                    WHERE Id = :ApexPages.currentPage().getParameters().get('id')
                    LIMIT 1];
        }
        system.debug('acct: ' + acct);

        if(acct != NULL){
            list<String> soldtoList = new list<String>();

            if(acct.SAP_Sold_To__c != NULL){
                //loop to grab Sold To Partner codes and store in list
                if(acct.Agreement_Count__c > 0){
                    cnlist.add(acct.SAP_Sold_To__c);
                }
                else{
                    system.debug('Skipping Primary Account - Missing Contracts: ' + acct.SAP_Sold_To__c);
                }

                for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                                  FROM Contract_Partnership__c
                                                  WHERE Ship_to__c = :acct.SAP_Sold_To__c 
                                                  AND Disabled__c = FALSE])
                {
                    cnlist.add(cp.Sale_to__c);
                    soldtoList.add(cp.Sale_to__c);
                }
                System.debug('cnlist ===================================== ' + cnlist);

                // Build List of Accounts to Check if User has access to Sold-To Accounts
                for(Account a : [SELECT SAP_Sold_To__c FROM Account WHERE SAP_Sold_To__c IN :cnlist ORDER BY SAP_Sold_To__c]){
                    acheck.add(a.SAP_Sold_To__c);
                }
                System.debug('acheck ===================================== ' + acheck);
                // If the size is the same - ALL Good!
                if(cnlist.size() == acheck.size()){
                    System.debug('acheck: ' + acheck.size());
                    refreshpage = FALSE;
                }
                else if(acheck.isEmpty()){ // Support for Prospect Accounts - ALL Good!
                  System.debug('*** acheck.isEmpty() ***');
                    refreshpage = TRUE;
                }
                else{ // ELSE when the page loads the page action/method checkSecurity will fire.
                // This will add the user to the Sold-To account share
                  System.debug('*** ELSE AFTER acheck.isEmpty() ***');
                  refreshpage = TRUE;
                }

                //PP_Customer_Detail_Helper newChk = new PP_Customer_Detail_Helper();
                //newChk.checkSecurity(cnlist,acheck);
                System.debug('*** refreshpage after else *** ' + refreshpage);
                if(refreshpage == FALSE && soldtoList.size() > 0){
                    for(Account a : [SELECT Name, SAP_Sold_To__c FROM Account where SAP_Sold_To__c = :soldtoList])
                    {
                        cplist.add(a);
                        showSoldTo = TRUE;
                    }
                }


            } // END SAP != NULL IF

            // Build List of Contracts
            //if(acct != NULL){
            system.debug('-- Building List of Contracts -- ');
            for(Account a : [SELECT Name, SAP_Sold_To__c,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,
                             (SELECT Name, Agreement__r.Owner__c, Agreement__r.Name, Agreement__r.GPO_Contract_Ref__c,
                              Agreement__r.Owner_Name__c, Agreement__r.Description__c,Account__r.SAP_Sold_To__c,
                              Agreement__r.Objective__c, Agreement__r.Objective_Name__c,
                              Valid_From__c, Valid_To__c, Condition__c, Agreement__r.Divisions__c
                              FROM Contract_Customers__r
                              WHERE Active_Future__c = TRUE
                              ORDER BY Agreement__r.Description__c ASC)
                             FROM Account
                             WHERE SAP_Sold_To__c IN :cnlist
                             //AND Agreement_Count__c > 0
                             Order BY Account_Group__c DESC])
            {
                CCList.put(a.SAP_Sold_To__c, a);
            }
                system.debug(' -- List of Contracts: ' + CCList.size());
            //}
            
            // Build out the Account Team - 26Jun2018 - ESC
            // Pulled from the VF Account Page
            ATMlist = new list<Territory_Master__c>();
            tsort = new list<String>();
            atmMap = new map<String, Territory_Master__c>();
            repMap = new map<String, String>();
            repId = new map<String, String>();
            tSales = new map<String, String>();
            atmCheck = false;

            // This builds out a map of Territories that have Sales
          List<String> sortedvalue = new List<String>(); 
            if(acct.Territory_Key__c != NULL){
                string poiList = acct.Territory_Key__c;
                sortedvalue = poiList.split(';');
                sortedvalue.sort();
                for(string s : sortedvalue){
                    tSales.put(s, '$');
                } 
            }
            
            // New ATMlist
            set<String> tset = new set<String>();
            for(Territory_Assignment__c ta : [SELECT Territory_Number__c 
                                              FROM Territory_Assignment__c
                                              WHERE Account__c =:acct.Id 
                                              AND Territory_Alignment__r.Active__c = TRUE 
                                              ORDER BY Business_Unit__c])
            {
                tset.add(ta.Territory_Number__c);
            }
            //adding the territories that have sales
            tset.addAll(sortedvalue);
            //Check standard account team memebers and add thier territories to tset
		Set<Id> accountTeamUsersSet = new Set<Id>();
        for(AccountTeamMember atm: [SELECT UserId 
                                          FROM AccountTeamMember
                                          WHERE AccountId =: acct.Id])
        {
            accountTeamUsersSet.add(atm.UserId);
        }
        if(!accountTeamUsersSet.isEmpty()){
            for(Territory_Master__c tmByUser :[SELECT Id, Territory_Number__c
                                     FROM Territory_Master__c 
                                     WHERE Primary_Territory_User__c IN:accountTeamUsersSet OR Sales_Rep__c IN:accountTeamUsersSet])
            {
                 tset.add(tmByUser.Territory_Number__c);
            }
        }

            
            for(Territory_Master__c tm :[SELECT Id, Name, Role__c, Business_Unit__c, Primary_Territory_User__r.Name, Sales_Rep__r.Name,
                                         Territory_Number__c
                                         FROM Territory_Master__c 
                                         WHERE Territory_Number__c =:tset
                                         ORDER BY Business_Unit__c, Role__c DESC])
            {
                atmCheck = true;
                tsort.add(tm.Territory_Number__c);
                atmMap.put(tm.Territory_Number__c, tm);
                if(tm.Sales_Rep__r.Name != NULL){
                    repMap.put(tm.Territory_Number__c, tm.Sales_Rep__r.Name);
                    repId.put(tm.Territory_Number__c, tm.Sales_Rep__r.Id);
                }
                else if(tm.Primary_Territory_User__r.Name != NULL){
                    repMap.put(tm.Territory_Number__c, tm.Primary_Territory_User__r.Name);
                    repId.put(tm.Territory_Number__c, tm.Primary_Territory_User__r.Id);
                }
                else{
                    repMap.put(tm.Territory_Number__c, 'Open');
                    repId.put(tm.Territory_Number__c, 'Blank');
                }
                if(!tSales.containsKey(tm.Territory_Number__c)){
                    tSales.put(tm.Territory_Number__c, '-');
                }
            }
            // End new ATM
            
            
        } // END acct != NULL IF
    }



    /*Public set<String> cnlist {get{

        String AcctNum = ApexPages.currentPage().getParameters().get('cid');
        AcctNum = AcctNum.trim();

        cnlist = new set<String>();

        //loop to grab Sold To Partner codes and store in list
        cnlist.add(AcctNum);
        for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                          FROM Contract_Partnership__c
                                          WHERE Ship_to__c = :AcctNum])
        {
            cnlist.add(cp.Sale_to__c);
        }
        System.debug('cnlist ===================================== ' + cnlist);
        set<string> acheck = new set<string>();
        for(Account a : [SELECT SAP_Sold_To__c FROM Account WHERE SAP_Sold_To__c IN :cnlist]){
            acheck.add(a.SAP_Sold_To__c);
        }
        PP_Customer_Detail_Helper checkSecurity = new PP_Customer_Detail_Helper();
        checkSecurity.checkSecurity(cnlist,acheck);

        return cnlist;

    } set;} */

    Public void checkSecurity(){
        /*
        String AcctNum = ApexPages.currentPage().getParameters().get('cid');
        AcctNum = AcctNum.trim();

        set<string> cnlist2 = new set<String>();

        //loop to grab Sold To Partner codes and store in list
        cnlist2.add(AcctNum);
        for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c
                                          FROM Contract_Partnership__c
                                          WHERE Ship_to__c = :AcctNum])
        {
            cnlist2.add(cp.Sale_to__c);
        }
        */
        System.debug('*** refreshpage checkSecurity *** ' + refreshpage);
        if(refreshpage){
            System.debug('*** IN PP_Customer_Details checkSecurity IF(refreshpage) ***');
            set<string> acheck = new set<string>();
            for(Account a : [SELECT SAP_Sold_To__c FROM Account WHERE SAP_Sold_To__c IN :cnlist]){
                acheck.add(a.SAP_Sold_To__c);
            }
            System.debug('*** cnlist *** ' + cnlist);
            System.debug('*** acheck *** ' + acheck);
            PP_Customer_Detail_Helper checkSecurity = new PP_Customer_Detail_Helper();
            checkSecurity.checkSecurity(cnlist,acheck);
        }
    }
    // Catch 'Lookup Customer' and redirect back
    public pagereference getURL(){
        System.debug('strCust ============================== ' + strCust);
        string search = strCust;
        if(search != NULL){
            search = search.trim();
            list<Account> AcctCheck = [SELECT Id FROM Account WHERE SAP_Sold_To__c  = :search LIMIT 1];

            if(AcctCheck.size() > 0){
                system.debug('search: ' + search);
                PageReference getCustomer = New Pagereference('/apex/PP_Customer_Details?cid='+search);
                getCustomer.setRedirect(true);
                return getCustomer;
            }
            else{
                apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Not a valid Contract Customer Number...'));
                return NULL;
            }

        }
        else{
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a Customer Number...'));
            return NULL;
        }
    }

    /* public map<String, Account> getCCList(){

        try{

            system.debug('-- Starting getCCList --');
            map<String, Account> aMap = new map<String, Account>();
            for(Account a : [SELECT Name, SAP_Sold_To__c,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,
                             (SELECT Name, Agreement__r.Owner__c, Agreement__r.Name, Agreement__r.GPO_Contract_Ref__c,
                              Agreement__r.Owner_Name__c, Agreement__r.Description__c,Account__r.SAP_Sold_To__c,
                              Agreement__r.Objective__c, Agreement__r.Objective_Name__c,
                              Valid_From__c, Valid_To__c, Condition__c, Agreement__r.Divisions__c
                              FROM Contract_Customers__r
                              WHERE Active_Future__c = TRUE
                              ORDER BY Agreement__r.Description__c ASC)
                             FROM Account
                             WHERE SAP_Sold_To__c IN :cnlist
                             //AND Agreement_Count__c > 0
                             Order BY Account_Group__c DESC])
            {
                aMap.put(a.SAP_Sold_To__c, a);
            }
            return aMap;
        }
        catch (Exception e){
            return NULL;
        }


    }
*/
    /*
    //method to get recent accounts and quotes
    public void createRecentLists() {
        recentAccList = new List<Account>();
        recentQuoteList = new List<Price_Quote__c>();

        recentAccList = [SELECT Id, Name,LastViewedDate,SAP_Sold_To__c FROM Account WHERE LastViewedDate !=null ORDER BY LastViewedDate DESC limit 10];
        recentQuoteList = [SELECT Id, Account_Name__R.Name, Name,LastViewedDate,Contact_Name__r.Name FROM Price_Quote__c WHERE LastViewedDate !=null ORDER BY LastViewedDate DESC limit 10];
    }
    */
    public Id getcustomerreport(){
        try {
            return [SELECT Id FROM Report WHERE Name = 'Contract Customer Detail' LIMIT 1].id;
        }
        catch (Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }
    /*
    public list<Account> getcplist(){
        if(ApexPages.currentPage().getParameters().get('cid') != NULL){
            list<Account> soldtoAcc = new list<Account>();
            list<String> sapList = new list<String>();
            try{
                if(ApexPages.currentPage().getParameters().get('cid') != NULL){
                    for(Contract_Partnership__c cp : [SELECT Sale_to__c
                                                      FROM Contract_Partnership__c
                                                      WHERE Ship_to__c = :ApexPages.currentPage().getParameters().get('cid')])
                    {
                        sapList.add(cp.Sale_to__c);
                    }
                    if(sapList.size() > 0){
                        soldtoAcc = [SELECT Name, SAP_Sold_To__c FROM Account where SAP_Sold_To__c = :sapList];
                        return soldtoAcc;
                    }
                }
                return NULL;
            }
            catch (Exception e){
                system.debug('Exception: ' + e);
                return NULL;
            }
        }
        else{
            return NULL;
        }
    }*/

    //method to get searched customer info
    /*
    public Account getcc(){
        if(ApexPages.currentPage().getParameters().get('cid') != NULL){
            try{
                return [SELECT Id, Name, ShippingStreet, ShippingCity, ShippingState,
                        ShippingPostalCode, ShippingCountry, SAP_Sold_To__c,
                        ERP_Active__c, Type, Customer_Group_Formula__c, Main_GPO__c, Secondary_GPO__c,
                        Last_SAP_Update__c
                        FROM Account
                        WHERE SAP_Sold_To__c = :ApexPages.currentPage().getParameters().get('cid')];
            }
            catch(Exception e){
                system.debug('Exception: ' + e);
                return NULL;
            }
        }
        else if(ApexPages.currentPage().getParameters().get('id') != NULL){
            try{
                return [SELECT Id, Name, ShippingStreet, ShippingCity, ShippingState,
                        ShippingPostalCode, ShippingCountry, SAP_Sold_To__c,
                        ERP_Active__c, Type, Customer_Group_Formula__c, Main_GPO__c, Secondary_GPO__c,
                        Last_SAP_Update__c
                        FROM Account
                        WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
            }
            catch(Exception e){
                system.debug('Exception: ' + e);
                return NULL;
            }
        }
        else{
            return NULL;
        }

    }
*/
}