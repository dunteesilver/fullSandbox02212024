/*********************************************************************
* Description      : Class to handle Competitor Product Search in Pricing Portal.
* Test Classes     : PP_CompProductSearch_Test
* VisualForce      : PP_CompProductSearch
* Author(s)        : Dun Silver
**********************************************************************/
public class PP_CompProductSearch{
    Public Integer size{get;set;}
    Public Integer noOfRecords{get; set;}
    public String compEntry {get;set;}
    Public String strQuoteId;
    String compEntry2;
    String rowIndex;

    Public String recID {get; set;}
    Public String recName {get; set;}
    Public String recType {get; set;}
    Public String recSales_Org_Key {get; set;}
    public List<Cross_Reference__c> prodList {get;set;}
    public String userLocale {get;set;}
    public Map<Id,String> formatListPrices {get;set;}
    public Map<Id,String> formatDistributorPrices {get;set;}
    public Map<Id,String> formatAltSitePrices {get;set;}
    public Map<Id,String> formatRsmPrices {get;set;}
    public Map<Id,String> formatRepPrices {get;set;}

    //get active quote of current user
    public String activeQuoteIdStr {get{
        List<User> userList = [Select id, Active_Quote_Id__c from User Where Id=: UserInfo.getUserId()];
        if(userList.size() > 0) {
            activeQuoteIdStr = userList[0].Active_Quote_Id__c;
        }
        return activeQuoteIdStr;
    }set;}

    public Price_Quote__c tempQuote {get{
      try{
        tempQuote = [Select Id, Name, Status__c,Sales_Org_Key__c,Account_Name__r.SAP_Sold_To__c,
                  Account_Name__r.Account_Group__c,CurrencyIsoCode from Price_Quote__c WHERE LastViewedDate != NULL
                  ORDER BY LastViewedDate DESC limit 1];
        return tempQuote;
      }
      catch(Exception e){
        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+'User has no active quote: ' + e));
        return null;
      }

    }set;}

    public List<SelectOption> paginationSizeOptions{get;set;}

        /* Competitor search
        If(ApexPages.currentPage().getParameters().get('compsrch') != null || ApexPages.currentPage().getParameters().get('compsrch') != ''){

            PageReference compProductSearch = New Pagereference('/apex/PP_CompProductSearch?pqid='+strQuoteId+'&compsrch='+ strCrossReference+'&rowIndex='+rowIndex);
            System.debug('strCrossReference Create Quote1 ===================================== ' + strCrossReference);
            compProductSearch.setRedirect(true);
        }
        end Competitor search */

    public PageReference getURL() {
        strQuoteId = ApexPages.currentPage().getParameters().get('pqId');

        PageReference compProductSearch = New Pagereference('/apex/PP_CompProductSearch?pqid='+strQuoteId+'&compsrch='
                                                            + compEntry+'&gs=off');
        compProductSearch.setRedirect(true);
        System.debug('compEntry Create Quote1 ===================================== ' + compEntry);
        return compProductSearch;
    }
    
    public void clearSearch() {
        compEntry = '';
    }


    public PP_CompProductSearch(){
      userLocale = UserInfo.getLocale();
      formatListPrices = new Map<Id,String>();
      formatDistributorPrices = new Map<Id,String>();
      formatAltSitePrices = new Map<Id,String>();
      formatRsmPrices = new Map<Id,String>();
      formatRepPrices = new Map<Id,String>();

      if(ApexPages.currentPage().getParameters().get('pqId') != NULL){
          for(Price_Quote__c pq : [Select Sales_Org_Key__c, Price_Quote_Name__c
                                   FROM Price_Quote__c
                                   WHERE Id =: ApexPages.currentPage().getParameters().get('pqId')
                                   LIMIT 1])
          {
              recName = pq.Price_Quote_Name__c;
              recType = 'Quote';
              recSales_Org_Key = pq.Sales_Org_Key__c;
              recID = ApexPages.currentPage().getParameters().get('pqId');
          }

      }
      else if(ApexPages.currentPage().getParameters().get('prfId') != NULL){
          for(PRF__c prf : [Select Sales_Org_Key__c, PRF_Name__c
                            FROM PRF__c
                            WHERE Id =: ApexPages.currentPage().getParameters().get('prfId')
                            LIMIT 1])
          {
              recName = prf.PRF_Name__c;
              recType = 'PRF';
              recSales_Org_Key = prf.Sales_Org_Key__c;
              recID = ApexPages.currentPage().getParameters().get('prfId');
          }
      }
      else{
          String salesOrgKey = [SELECT Active_Sales_Org_Key__c
                                FROM Contract_User__c
                                WHERE User__c = :UserInfo.getUserId()
                                LIMIT 1].Active_Sales_Org_Key__c;
          
          recSales_Org_Key = salesOrgKey;
      }  

      rowIndex = ApexPages.currentPage().getParameters().get('rowIndex');

        compEntry = Apexpages.currentPage().getParameters().get('compsrch');
        System.debug('*** compEntry *** ' + compEntry);
        compEntry2 = '%' +compEntry+ '%';
        System.debug('*** compEntry2 *** ' + compEntry2);
        size=10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
    }//end of constructor

    public ApexPages.StandardSetController setCon {
        get {
            System.debug('*** setCon ***'+compEntry);
            /*Added by Siva on 15 Nov. 2018 to return null when serach string is not entered*/
            if(compEntry == '' || compEntry == null){
                System.debug('*** setCon *** Nothing has been searched!');
                return null;
            }
            else{
                if(setCon == null) {
                  System.debug('*** In setCon if ***');
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                          [SELECT Competitor_Product_Code__c,Competitor_Product_Description__c,TFX_Product__c, Product__c,Competitor_Name__c,
                          Percent_Match__c,Name,Product__r.List_Price__c,Product__r.Rep_Price__c,Product__r.RSM_price__c,Product__r.Sales_Org__c,
                          Product__r.Distribution_Channel__c, Product__r.Distributor_List__c, Product__r.Alt_Site_List__c
                          FROM Cross_Reference__c
                          WHERE Competitor_Product_Code__c LIKE :compEntry2
                          ORDER BY Competitor_Product_Code__c]));
                    setCon.setPageSize(size);
                    noOfRecords = setCon.getResultSize();
                }
            }
            System.debug('*** setCon *** ' + setCon);
            return setCon;
        }
        set;
    }

    //Changes the size of pagination
    public PageReference refreshPageSize() {
         setCon.setPageSize(size);
         return null;
    }

    // Initialize setCon and return a list of record

    public List<Cross_Reference__c> getCompProduct() {
      prodList = (List<Cross_Reference__c>) setCon.getRecords();
      formatListPrices = getFormatListPrices(prodList);
      formatDistributorPrices = getFormatDistributorPrices(prodList);
      formatAltSitePrices = getFormatAltSitePrices(prodList);
      formatRsmPrices = getFormatRsmPrices(prodList);
      formatRepPrices = getFormatRepPrices(prodList);
      return (List<Cross_Reference__c>) setCon.getRecords();
    }

    //method to create breadcrumb back to active quote
    public String getActiveQuoteIdStr() {
        String activeQuoteIdStr = '';

        //get active quoteId
        List<User> userList = [Select id, Active_Quote_Id__c from User Where Id=: UserInfo.getUserId()];
        if(userList.size() > 0) {
            activeQuoteIdStr = userList[0].Active_Quote_Id__c;
        }
        return activeQuoteIdStr;
    }

    //method to create breadcrumb back to active quote
    public String getActiveQuoteName() {
        String activeQuoteName = '';
        String activeQuoteIdStr = '';

        //get active quoteId
        List<User> userList = [Select id, Active_Quote_Id__c from User Where Id=: UserInfo.getUserId()];
        if(userList.size() > 0) {
            activeQuoteIdStr = userList[0].Active_Quote_Id__c;
        }

        //get quote name
        List<Price_Quote__c> qList = [Select Id, Name from Price_Quote__c Where Id=:activeQuoteIdStr];
        if(qList.size() > 0) {
            activeQuoteName = qList[0].Name;
        }
        return activeQuoteName;
    }

    //method to get SAP Price
    public PageReference sapPrice(){
      strQuoteId = ApexPages.currentPage().getParameters().get('pqId');
      PP_SAP_Price sapPrice = new PP_SAP_Price();
      List<String> matNames = new List<String>();
      String materialStr = ApexPages.currentPage().getParameters().get('prdsrchVal');
      String crossStr = ApexPages.currentPage().getParameters().get('compsrchVal');
      matNames.add(materialStr);
      sapPrice.getSAPprice(matNames,crossStr,NULL,strQuoteId);
      return null;
    }
    //end of SAP Price Method

    public Map<Id,String> getFormatListPrices(List<Cross_Reference__c> prodList ){
      System.debug('*** IN getFormatListPrices *** ');
        Decimal formDec;
        String newDec;
        for(Cross_Reference__c curr : prodList ){
          System.debug('*** curr.Id *** ' + curr.Id);
            if(userLocale != 'en_US'){
                System.debug('*** userLocale *** ' + userLocale);
                if(curr.Product__r.List_Price__c == NULL){
                  curr.Product__r.List_Price__c = 0;
                }
                formDec = curr.Product__r.List_Price__c;
                newDec = formDec.format();
                formatListPrices.put(curr.Id,newDec);
            }
            else{
              if(curr.Product__r.List_Price__c == NULL){
                curr.Product__r.List_Price__c = 0;
              }
              newDec = String.valueOf(curr.Product__r.List_Price__c);
              formatListPrices.put(curr.Id,newDec);
            }
        }
        System.debug('*** formatListPrices *** ' + formatListPrices);
        return formatListPrices;
    }//end of getFormatListPrices

    public Map<Id,String> getFormatDistributorPrices(List<Cross_Reference__c> prodList ){
      System.debug('*** IN getFormatDistributorPrices *** ');
        Decimal formDec;
        String newDec;
        for(Cross_Reference__c curr : prodList ){
          System.debug('*** curr.Id *** ' + curr.Id);
            if(userLocale != 'en_US'){
                System.debug('*** userLocale *** ' + userLocale);
                if(curr.Product__r.Distributor_List__c == NULL){
                  curr.Product__r.Distributor_List__c = 0;
                }
                formDec = curr.Product__r.Distributor_List__c;
                newDec = formDec.format();
                formatListPrices.put(curr.Id,newDec);
            }
            else{
              if(curr.Product__r.Distributor_List__c == NULL){
                curr.Product__r.Distributor_List__c = 0;
              }
              newDec = String.valueOf(curr.Product__r.Distributor_List__c);
              formatDistributorPrices.put(curr.Id,newDec);
            }
        }
        System.debug('*** formatDistributorPrices *** ' + formatDistributorPrices);
        return formatListPrices;
    }//end of getFormatDistributorPrices

    public Map<Id,String> getFormatAltSitePrices(List<Cross_Reference__c> prodList ){
      System.debug('*** IN getFormatAltSitePrices *** ');
        Decimal formDec;
        String newDec;
        for(Cross_Reference__c curr : prodList ){
          System.debug('*** curr.Id *** ' + curr.Id);
            if(userLocale != 'en_US'){
                System.debug('*** userLocale *** ' + userLocale);
                if(curr.Product__r.Alt_Site_List__c == NULL){
                  curr.Product__r.Alt_Site_List__c = 0;
                }
                formDec = curr.Product__r.Alt_Site_List__c;
                newDec = formDec.format();
                formatAltSitePrices.put(curr.Id,newDec);
            }
            else{
              if(curr.Product__r.Alt_Site_List__c == NULL){
                curr.Product__r.Alt_Site_List__c = 0;
              }
              newDec = String.valueOf(curr.Product__r.Alt_Site_List__c);
              formatAltSitePrices.put(curr.Id,newDec);
            }
        }
        System.debug('*** formatAltSitePrices *** ' + formatAltSitePrices);
        return formatAltSitePrices;
    }//end of getFormatAltSitePrices

    //format currency for different locales
    public Map<Id,String> getFormatRsmPrices(List<Cross_Reference__c> prodList ){
      System.debug('*** IN getFormatRsmPrices *** ');
        Decimal formDec;
        String newDec;
        for(Cross_Reference__c curr : prodList){
          System.debug('*** curr.Id *** ' + curr.Id);
            if(userLocale != 'en_US'){
                System.debug('*** userLocale *** ' + userLocale);
                if(curr.Product__r.Rsm_Price__c == NULL){
                  curr.Product__r.Rsm_Price__c = 0;
                }
                formDec = curr.Product__r.Rsm_Price__c;
                newDec = formDec.format();
                formatRsmPrices.put(curr.Id,newDec);
            }
            else{
              if(curr.Product__r.Rsm_Price__c == NULL){
                curr.Product__r.Rsm_Price__c = 0;
              }
              newDec = String.valueOf(curr.Product__r.Rsm_Price__c);
              formatRsmPrices.put(curr.Id,newDec);
            }
        }
        System.debug('*** formatRsmPrices *** ' + formatRsmPrices);
        return formatRsmPrices;
    }//end of getFormatRsmPrices

    //format currency for different locales
    public Map<Id,String> getFormatRepPrices(List<Cross_Reference__c> prodList ){
      System.debug('*** IN getFormatRepPrices *** ');
        Decimal formDec;
        String newDec;
        for(Cross_Reference__c curr : prodList){
          System.debug('*** curr.Id *** ' + curr.Id);
            if(userLocale != 'en_US'){
                System.debug('*** userLocale *** ' + userLocale);
                if(curr.Product__r.Rep_Price__c == NULL){
                  curr.Product__r.Rep_Price__c = 0;
                }
                formDec = curr.Product__r.Rep_Price__c;
                newDec = formDec.format();
                formatRepPrices.put(curr.Id,newDec);
            }
            else{
              if(curr.Product__r.Rep_Price__c == NULL){
                curr.Product__r.Rep_Price__c = 0;
              }
              newDec = String.valueOf(curr.Product__r.Rep_Price__c);
              formatRepPrices.put(curr.Id,newDec);
            }
        }
        System.debug('*** formatRepPrices *** ' + formatRepPrices);
        return formatRepPrices;
    }//end of getFormatRepPrices
}