/*********************************************************************
 * Class Name      : PP_Price_Quote
 * Description     : This class is used for PP_Price_Quote Page
 * Created Date    :
 * Author          : Sankarsh
 * -------------------------------------------------------------------
 * Modified History :
 **********************************************************************/

Public with sharing class PP_Create_Quote{

    public String strCust{get; set;}
    public String strCon{get; set;}
    public String strPriceQuote{get; set;}
    public String globalQty {get; set;}
    public List<Account> accountInfo {get; set;} //list holds custList account info
    public Datetime Today {get;set;}
    public Contact conRow{get; set;}
    public Integer counter{get;set;}


    public Map<String,priceQuoteLineItems> mapWrapperClass;
    public list <priceQuoteLineItems > lstpriceQuoteLineItems {get;set;}
    public String contextItem{get;set;}
    public boolean IsEdit { get; set; }

    public Price_Quote__c prdQuoteRow  { get; set; }
    public Price_Quote__c pq {get;set;}
    public Decimal GrandTotal{get;set;}
    //Dun's variables
    public String strMats{get;set;}

    public String strQuoteId{get;set;}
    Public Boolean reviseClone {get;set;}
    Public String counterwrap {get;set;}
    Public String strMaterialnumber {get;set;}
    public String strCrossReference{get;set;}
    public String imageURL {get;set;}
    public List<Price_Quote_Line_Item__c> lstlineItems{get;set;}

    //boolean for re-rendering button to red to go through approval process
    public Boolean subButton {get{
        Price_Quote__c pQuote = [Select Id, Approval_Flag_Rollup__c FROM Price_Quote__c
                                WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        if(pQuote.Approval_Flag_Rollup__c < 1){
            comButton = true;
            subButton = false;
        }else{
            comButton = false;
            subButton = true;
        }
        return subButton;
    }set;}

    //boolean for re-rendering button to blue to skip through approval process
    public Boolean comButton {get{
       Price_Quote__c pQuote1 = [Select Id, Approval_Flag_Rollup__c FROM Price_Quote__c
                                WHERE id = :ApexPages.currentPage().getParameters().get('pqid') LIMIT 1];
        if(pQuote1.Approval_Flag_Rollup__c < 1){
            comButton = true;
            subButton = false;
        }else{
            comButton = false;
            subButton = true;
        }
        return comButton;
    }set;}

    //end of Dun's variables

    public String getActiveQuoteIdStr() {
        return ApexPages.currentPage().getParameters().get('pqid');
    }

    public Map<String, String> calSalesOrgStr(String cnNo, Set<String> searchMaterials ) {
        String salesOrgToRet;
        Map<String, String> cmMapToRet = new Map<String, String>();
        list<String> ccaList = new list<String>();
        for(Contract_Customer__c cc : [SELECT Agreement__r.Agreement_Number__c
                                       FROM Contract_Customer__c
                                       WHERE Account__r.SAP_Sold_To__c =:cnNo
                                       AND Active__c = TRUE])
        {
            ccaList.add(cc.Agreement__r.Agreement_Number__c);
        }

        system.debug('ccalist:' + ccaList);

        for(Contract_Material__c cm : [SELECT Product__r.Name, Agreement__r.Agreement_Number__c, Sales_Org__c
                                       FROM Contract_Material__c
                                       WHERE Product__r.Name IN: searchMaterials
                                       AND Agreement_Number__c IN :ccaList
                                       LIMIT 1])
        {
            cmMapToRet.put(cm.Product__r.Name , cm.Sales_Org__c);
        }
        system.debug('cmMapToRet:' + cmMapToRet);
        return cmMapToRet;
    }

    public PP_Create_Quote() {
        /*
        List<User> userList = [Select Business_Unit__c From User Where Id=: UserInfo.getUserId()];

        if( userList[0].Business_Unit__c == 'Vascular' || userList[0].Business_Unit__c == 'Interventional' ) {
            salesOrgStr = 'US30';
        }else {
            salesOrgStr = 'US10';
        }
        */


        pq = getpq();
        reviseClone = True;
        strCust = '';
        strCon= '';
        strPriceQuote = '';
        counter = 0;
        conRow = new Contact();
        contextItem = '';
        IsEdit  = false;

        GrandTotal = 0;
        mapWrapperClass = new  Map<String,priceQuoteLineItems>();
        accountInfo = new List<Account>();
        prdQuoteRow  = new Price_Quote__c();
        lstpriceQuoteLineItems = new list <priceQuoteLineItems >();


        strPriceQuote = ApexPages.currentPage().getParameters().get('pqId');
        String cloneType = Apexpages.currentpage().getParameters().get('cloneType');

        if(cloneType == 'Revise Customer') {
            reviseClone = False;
            IsEdit = True;
        }

        //query Account for Customer's info
        /*
        if(strPriceQuote != null) {
            prdQuoteRow = [Select id, name,Owner.Id,Owner.Name,Internal_Comments_Only__c,Customer_comments__c, Account_Name__c, Status__c ,
                                Contact_Name__c, Date__c, Expiration_Date__c from Price_Quote__c where Id=:strPriceQuote LIMIT 1];
            accountInfo = [SELECT Name, Id, ShippingStreet,ShippingCity,ShippingState, Account_Status__c,
                           ShippingPostalCode,SAP_Sold_To__c FROM Account WHERE Id  = :prdQuoteRow.Account_Name__c LIMIT 1];

            if(prdQuoteRow != null && prdQuoteRow.Contact_Name__c != null) {
                conRow = [Select Id, Name, Expiration_Date__c, FirstName, LastName, Email, Phone, Business_Unit1__c, createddate
                            from Contact where Id =: prdQuoteRow.Contact_Name__c LIMIT 1];
                today = conRow.createddate +90;
            }

        }
        */
        if(strPriceQuote != '') {
            Integer count =1;
            //List<Price_Quote_Line_Item__c> lstlineItems = new List<Price_Quote_Line_Item__c>();
            lstlineItems = [select id, Name, Hide_Crossreference__c, Competetive_Product__r.Competitor_Product_Code__c, Description__c ,
                            Sales_Unit_Qty__c, Sales_Unit__c, Sales_Number__c, Sales_deal_Description__c,
                            Condition__c, Material_Status__c, Material_Status_Description__c, Competetive_Product__r.Name,
                            Cost_Price__c, Material_Name__c, Material_Name__r.Name, Material_Name__r.Material_Status__c, Material_Name__r.Id,
                            Quantity__c, Sales_Price__c, Approval_Flag__c, Material_Name__r.Image_URL__c,
                            Eligible_Price__c, Extended_Price__c,  Price_Quote__c, Price_Quote__r.Account_Name__c,
                            Price_Quote__r.Contact_Name__c, List_Price__c, Rep_Price__c, RSM_Price__c
                            FROM Price_Quote_Line_Item__c
                            WHERE Price_Quote__c = :strPriceQuote
                            Order By Row_Order__c];// Order By Name

            if(lstlineItems.size()>0) {
                for(Price_Quote_Line_Item__c priceQuoteLineRec :lstlineItems) {
                    priceQuoteLineItems priceWrapper = new priceQuoteLineItems();
                    priceWrapper.counterWrap = count;
                    priceWrapper.strMaterialnumber = priceQuoteLineRec.Material_Name__r.Name;
                    priceWrapper.strMaterialnumberId = priceQuoteLineRec.Material_Name__r.Id;
                    priceWrapper.strMaterialStatus = priceQuoteLineRec.Material_Name__r.Material_Status__c;
                    priceWrapper.priceQuoteLine = priceQuoteLineRec;
                    priceWrapper.imageURL = priceQuoteLineRec.Material_Name__r.Image_URL__c;
                    priceWrapper.innerlineprices = 0;
                    priceWrapper.colorName = createMatStatColorCode(priceQuoteLineRec.Material_Status__c);

                    if(priceQuoteLineRec.Sales_Price__c != null && priceQuoteLineRec.Quantity__c != null){
                        priceWrapper.innerlineprices = priceQuoteLineRec.Sales_Price__c*priceQuoteLineRec.Quantity__c;
                    }
                    GrandTotal = GrandTotal + priceWrapper.innerlineprices;
                    lstpriceQuoteLineItems.add(priceWrapper);
                    count++;
                }

                Set<String> setMaterialnumber = new Set<String>();
                Map<String,priceQuoteLineItems> mapWrapper = new  Map<String,priceQuoteLineItems>();

                for( priceQuoteLineItems items :lstpriceQuoteLineItems) {
                    if(items.strMaterialnumber != null) {
                        setMaterialnumber.add(items.strMaterialnumber);
                    }
                }



                if(!setMaterialnumber.Isempty()){
                    //List< Product2> lstProduct = new List< Product2>();
                    For( Product2 prd :  [Select id, Name, Rep_Price__c,RSM_Price__c,Description, Image_URL__c, Cost_Price__c,Sales_Unit__c,Material_Status__c, Qty_Sales_Unit__c, Cost_Price_Unit__c, (Select id, Name,Competitor_Product_Code__c, Competitor_Name__c from Cross_References__r ORDER BY lastmodifiedDate LIMIT 1), (Select Id, Price__c,Agreement__r.Agreement_Number__c, Agreement__r.Description__c from Contract_Material__r ORDER BY lastmodifiedDate LIMIT 1) from  Product2 where Name IN : setMaterialnumber]) {
                        priceQuoteLineItems priceWrapper = new priceQuoteLineItems();
                        priceWrapper.prod = prd;

                        if(prd.Cross_References__r.size()>0)
                            priceWrapper.crossRef = prd.Cross_References__r[0];
                        if(prd.Contract_Material__r.size()>0)
                            priceWrapper.contractMaterial = prd.Contract_Material__r[0];
                        mapWrapper.put(prd.Name ,priceWrapper);
                    }
                }
                addRow();
             } else {
                 priceQuoteLineItems priceWrapper = new priceQuoteLineItems();
                 priceWrapper.counterWrap = 1;
                 lstpriceQuoteLineItems.add(priceWrapper);
             }
         }else{
             priceQuoteLineItems priceWrapper = new priceQuoteLineItems();
             priceWrapper.counterWrap = 1;
             lstpriceQuoteLineItems.add(priceWrapper);
         }
         processGrandTotal();
    }

    //Handles return from PP_ProductSearch page to add material to line items, reference in <apex:page> tag on PP_Price_Quote
    public void populateMaterialName() {
        String matrealNameStr = Apexpages.currentpage().getParameters().containsKey('prdsrch')?Apexpages.currentpage().getParameters().get('prdsrch'):'';
        String rowIndex = Apexpages.currentpage().getParameters().containsKey('rowIndex')?Apexpages.currentpage().getParameters().get('rowIndex'):'';
        Integer rowIndexVal;


        if(rowIndex != null && rowIndex != '')
            rowIndexVal = Integer.valueOf(rowIndex)-1;

        if(matrealNameStr != null && matrealNameStr != '') {
            if(lstpriceQuoteLineItems.size()>0 && rowIndexVal != null &&lstpriceQuoteLineItems.size()>rowIndexVal) {
                lstpriceQuoteLineItems.get(rowIndexVal).strMaterialnumber = matrealNameStr;
            }

            if(rowIndexVal != null) {
                autoPopulateRowDate(rowIndexVal+1);
                processPriceQuote();
                processGrandTotal();
                addRow();
            }
        }
/*
        User currentUser = new User(id = UserInfo.getUserId());
        currentUser.Active_Quote_Id__c = pq.id;
        update currentUser;
*/
    }

    //investigate further
    public void editContactWithExpiration(){
        IsEdit = true;
        /*conRow.FirstName = conRow.FirstName;
        conRow.LastName= conRow.LastName;
        conRow.Email= conRow.Email;
        conRow.Phone= conRow.Phone;
        conRow.Business_Unit1__c = conRow.Business_Unit1__c;*/
    }

    /* Description : Mass updating the quantity.
    */
    public void quantityUpd() {
        system.debug('globalQty =================== ' + globalQty);
        if( lstpriceQuoteLineItems.size()>0 && globalQty != null && globalQty != '' ) {
            Integer qtyVal = Integer.valueOf(globalQty);
            for( priceQuoteLineItems wrapItem : lstpriceQuoteLineItems ) {
                if(qtyVal != null && wrapItem.priceQuoteLine != null)
                    wrapItem.priceQuoteLine.Quantity__c = qtyVal;
                if(qtyVal != null && wrapItem.priceQuoteLine.Sales_Price__c != null)
                    wrapItem.innerlineprices = qtyVal*wrapItem.priceQuoteLine.Sales_Price__c;
            }
            processPriceQuote();
            processGrandTotal();
        }
        //add else logic to catch invalid quantity entry
    }

    public void cancelEditContact() {
        IsEdit = false;
    }

    /* Description : Getting used to update pqli record for flag btn click.
    */
    public void updateFlag() {
        Integer rowNo = Integer.valueOf(Apexpages.currentpage().getParameters().get('rowNo'));
        String flagVal = Apexpages.currentpage().getParameters().get('flagVal');

        Savepoint sp = Database.setSavepoint();
        if(lstpriceQuoteLineItems.size()>rowNo) {
            try {
                Price_Quote_Line_Item__c lineObj = lstpriceQuoteLineItems.get(rowNo-1).priceQuoteLine;
                if(flagVal == 'True')
                    lineObj.IsBold__c = True;
                else
                    lineObj.IsBold__c = False;
                if(lineObj.id != null)
                    update lineObj;
            }catch(Exception ex) {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
        }
    }

    /* Description : For update button.
    */
    public void processUpdate() {
        Savepoint sp = Database.setSavepoint();
        Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
        strMaterialnumber = Apexpages.currentpage().getParameters().get('strCode');
        strCrossReference = Apexpages.currentpage().getParameters().get('strCross');
        system.debug('strMaterialnumber ======================= ' + strMaterialnumber);
        system.debug('strCrossReference ======================= ' + strCrossReference);


        //checks if quote is in Approved stage to not allow edits
        system.debug('pq.status__c: ' + pq.Id);
        if(pq.Status__c == 'Approved' || pq.Status__c == 'Waiting For RSM Approval' || pq.Status__c == 'Waiting for Contracts Approval'){
        //if(pq.Status__c != 'In Progress' || pq.Status__c != 'Rejected'){
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.Label.EMEA_Sorry_cannot_update_line_items_on_an_approved_quote));
            return;
        }
        else{
            try {

                Set<String> setMaterialnumber = new Set<String>();
                Set<String> setCrossRef = new Set<String>();
                Boolean crossRefDisplayChk = True;

                for( priceQuoteLineItems items : lstpriceQuoteLineItems ) {
                    system.debug('***items.counterWrap***'+(items.strCrossReference  != null && items.strCrossReference  != '' && items.counterWrap == param));
                    if(items.strMaterialnumber != null && items.strMaterialnumber != '' && items.counterWrap == param ) {

                        setMaterialnumber.add(items.strMaterialnumber);

                        items.showHidenField = True;
                        crossRefDisplayChk = True;
                    }
                    /*
                    if(items.strCrossReference  != null && items.strCrossReference != '' && items.counterWrap == param) {
                        setCrossRef.add(items.strCrossReference);

                        if(items.strCrossReferenceHidden != null && items.strCrossReferenceHidden != '') {
                            items.showHidenField = False;
                            crossRefDisplayChk = False;
                        }
                    }
                    */
                }
                system.debug('setMaterialnumber ======================= ' + setMaterialnumber);
                /*
                if(setCrossRef.size()>0) {
                    String strmat = '';
                    for(Cross_Reference__c crPrd : [Select id, Product__r.Name
                                                    from Cross_Reference__c where Competitor_Product_Code__c IN: setCrossRef]){
                        setMaterialnumber.add(crPrd.Product__r.Name);
                        strmat = crPrd.Product__r.Name;
                    }
                    if(lstpriceQuoteLineItems.size()<=param)
                        lstpriceQuoteLineItems[param-1].strMaterialnumber = strmat;
                }
                */
                system.debug('setMaterialnumber 2 ======================= ' + setMaterialnumber);
                List<Product2> productListTemp = new List<Product2>();
                if(!setMaterialnumber.Isempty()) {
                    productListTemp = [Select id, Name, Image_URL__c,Cost__c,Rep_Price__c,RSM_Price__c, Description,List_Price__c, Cost_Price__c,Sales_Unit__c,Material_Status__c, Qty_Sales_Unit__c, Cost_Price_Unit__c,
                                              (Select id, Name,Competitor_Product_Code__c, Competitor_Name__c from Cross_References__r ORDER BY lastmodifiedDate LIMIT 1),
                                              (Select Id, Price__c,Agreement__r.Agreement_Number__c, Agreement__r.Description__c from Contract_Material__r ORDER BY lastmodifiedDate LIMIT 1)
                                              From  Product2
                                              Where Name IN : setMaterialnumber AND Sales_Org_Key__c =:pq.Sales_Org_Key__c LIMIT 1];
                }
                system.debug('**********productListTemp**********'+productListTemp);
                Product2 prdObj = (productListTemp!=null && productListTemp.size()>0)?productListTemp[0]:null;
                system.debug('**********prdObj**********'+prdObj);

                if(prdObj!=null) {
                    Map<String,SAPRealPriceSet__x> sapPriceMap = createSapMap(setMaterialnumber);
                    PriceQuoteLineItems pqliWrapObj = (lstpriceQuoteLineItems != null && lstpriceQuoteLineItems.size()>=param)?lstpriceQuoteLineItems.get(param-1):null;
                    SAPRealPriceSet__x sapObj = sapPriceMap.containsKey(pqliWrapObj.strMaterialnumber)?sapPriceMap.get(pqliWrapObj.strMaterialnumber):null;

                    sapPriceMap.clear();

                    system.debug('**********sapObj**********'+sapObj);
                    if(pqliWrapObj != null) {
                        pqliWrapObj.strMaterialnumber = prdObj.Name;
                        if(prdObj.Cross_References__r.size()>0 && strCrossReference != null && strMaterialnumber == pqliWrapObj.strMaterialnumber){
                        System.debug('*********** adding Cross Reference ***********');
                            pqliWrapObj.strCrossReference = strCrossReference;
                            crossRefDisplayChk = false;
                        }else{
                            pqliWrapObj.strCrossReference = null;
                            pqliWrapObj.imageURL = prdObj.Image_URL__c;
                        }

                        Price_Quote_Line_Item__c priceQuoteLineObjToIns = createPriceQuoteLineObj(prdObj,sapObj);
                        priceQuoteLineObjToIns.Hide_Crossreference__c = crossRefDisplayChk;

                        if(pqliWrapObj.priceQuoteLine != null && pqliWrapObj.priceQuoteLine.id != null) {
                            priceQuoteLineObjToIns.Quantity__c = pqliWrapObj.priceQuoteLine.Quantity__c;
                            if(strMaterialnumber == pqliWrapObj.strMaterialnumber){
                              priceQuoteLineObjToIns.Sales_Price__c = pqliWrapObj.priceQuoteLine.Sales_Price__c;
                            }

                            if(pqliWrapObj.priceQuoteLine.Sales_Price__c != null && pqliWrapObj.priceQuoteLine.Quantity__c != null)
                                priceQuoteLineObjToIns.Extended_Price__c = pqliWrapObj.priceQuoteLine.Quantity__c*pqliWrapObj.priceQuoteLine.Sales_Price__c;
                            priceQuoteLineObjToIns.id = pqliWrapObj.priceQuoteLine.id;
                        }
                        upsert priceQuoteLineObjToIns;

                        if(priceQuoteLineObjToIns.id != null) {
                            pqliWrapObj.priceQuoteLine = [Select id,Sales_Price__c,Rep_Price__c, RSM_Price__c,List_Price__c ,Hide_Crossreference__c, Approval_Flag__c,Extended_Price__c,Quantity__c,Eligible_Price__c,Material_Status__c,
                                                     Condition__c,Sales_deal_Description__c,Sales_Number__c,Competetive_Product__c,Material_Name__c, Material_Status_Description__c,
                                                     Description__c,Sales_Unit_Qty__c,Sales_Unit__c From Price_Quote_Line_Item__c Where Id=: priceQuoteLineObjToIns.id];
                        }
                        //system.assertequals(pqliWrapObj.priceQuoteLine , null);
                    }
                }
                processGrandTotal();
            }catch( Exception ex ) {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }//end of Try/Catch Block
        }
    }

    public Map<String,Contract_Material__c> createcontMaterialMap( String searchAgreements, Set<String> setMaterialnumber) {
        Map<String,Contract_Material__c> contMaterialMap = new Map<String,Contract_Material__c>();

        Decimal aConLevel = 0;
        if(searchAgreements <> NULL && setMaterialnumber<> NULL) {
            list<string> cnlist = new list<String>();
            cnlist.add(searchAgreements);
            for(Contract_Partnership__c cp : [SELECT Sale_to__c, Ship_to__c FROM Contract_Partnership__c WHERE Ship_to__c = :searchAgreements]){
                cnlist.add(cp.Sale_to__c);
            }

            list<Contract_Customer__c> agreementList;
            agreementList = [SELECT Agreement__r.Agreement_Number__c, Condition_Rank__c FROM Contract_Customer__c WHERE Account__r.SAP_Sold_To__c IN :cnlist AND Agreement__c IN
            (SELECT Agreement__c FROM Contract_Material__c WHERE Product__r.Material__c IN:setMaterialnumber) ORDER BY Condition_Rank__c];

            if(agreementList.size()>0){

                list<string> alist = new list<String>();
                for(Contract_Customer__c cc : agreementList){
                    if(aConLevel == 0){
                        aConLevel = cc.Condition_Rank__c;
                    }
                    if(cc.Condition_Rank__c == aConLevel){
                        alist.add(cc.Agreement__r.Agreement_Number__c);
                    }
                }


                for( Contract_Material__c conMatObj : [SELECT Product__r.Material__c,Product__r.Material_Status_Numeric__c, Agreement__r.Objective__c, Agreement__r.Agreement_Number__c, Agreement__r.Description__c,
                                                      Material_Name__c, Price__c, Agreement__r.Owner__c, Agreement__r.Owner_Name__c, Agreement__r.GPO_Contract_Ref__c, Valid_To__c, Valid_From__c,
                                                      Agreement__r.Objective_Name__c FROM Contract_Material__c WHERE Product__r.Material__c IN:setMaterialnumber AND Agreement_Number__c IN :alist ORDER BY Price__c]) {
                    contMaterialMap.put(conMatObj.Product__r.Material__c ,conMatObj);

                }

            }//end if(agreementList.size()>0)
        }

        return contMaterialMap;
    }

    /* Description: It is like assistance method for other methods.
                    Fetching data from SAP and creating a map of Material Name to External obj record.
    */
    public Map<String,SAPRealPriceSet__x> createSapMap( Set<String> setMaterialnumber ) {
        String salesOrgStr;
        String matName;
        String distChannel;

        Map<String,SAPRealPriceSet__x> sapPriceMap = new  Map<String,SAPRealPriceSet__x>();
        List<Contract_Partnership__c> cpChk = new List<Contract_Partnership__c>();

        if(pq.Account_Name__r.SAP_Sold_To__c != null) {
            cpChk = [Select Sale_to__c, Ship_to__c
                     FROM Contract_Partnership__c
                     WHERE Ship_to__c=: pq.Account_Name__r.SAP_Sold_To__c
                     LIMIT 1];
        }

        for(String matNo : setMaterialnumber) {
             matName = matNo;
        }

        string cusSAP;
        if(pq.Account_Name__r.Account_Group__c =='Z002' && cpChk.size()>0) {
            cusSAP = cpChk[0].Sale_to__c;
        }
        else{
            cusSAP = pq.Account_Name__r.SAP_Sold_To__c;
        }
        system.debug('setMaterialnumber: ' + setMaterialnumber);

        // Check for multiple products using the same name and key
        list<Product2> mcheck = [SELECT Sales_Org__c, Distribution_Channel__c
                                 FROM Product2
                                 WHERE Name IN :setMaterialnumber
                                 AND Sales_Org_Key__c = :pq.Sales_Org_Key__c];
        if(mcheck.size() == 1){
            salesOrgStr = mcheck[0].Sales_Org__c;
            distChannel = mcheck[0].Distribution_Channel__c;
        }
        else if(mcheck.size() > 1){
            Map<String, String> cmMapsalesOrg = calSalesOrgStr(cusSAP, setMaterialnumber);
            if(cmMapsalesOrg.get(matName) != NULL) {
                salesOrgStr = cmMapsalesOrg.get(matName);
                system.debug('***********salesOrgStr**** '+salesOrgStr);
            }
            distChannel = pq.Sales_Org_Key__c.right(2);
        }

        system.debug('cusSAP: ' + cusSAP);
        system.debug('distChannel: ' + distChannel);
        system.debug('setMaterialnumber: ' + setMaterialnumber);

        for(SAPRealPriceSet__x sap : [SELECT Price__c, Material__c, Agreement__c, SalesDeal__c, ListPrice__c,
                                      MtrlStatus__c, AgrDesc__c, Condition__c,
                                      SalesOrg__c, DistChnl__c, Customer__c
                                      FROM SAPRealPriceSet__x
                                      WHERE SalesOrg__c = :salesOrgStr
                                      AND DistChnl__c = :distChannel
                                      AND Customer__c = :cusSAP
                                      AND Material__c = :setMaterialnumber
                                      //strMaterialnumber
                                      //AND Material__c = :searchMaterials
                                      AND EffDate__c = :datetime.now()
                                      LIMIT 1])
        {
            sapPriceMap.put(sap.Material__c,sap);
        }
        system.debug('***********sapPriceMap****'+sapPriceMap);

        return sapPriceMap;
    }

    /* Description: Calculate Color coding.
    */
    public String createMatStatColorCode( String pqLinMatStr ) {
        String colorStr = 'White';
        if(  pqLinMatStr == 'Z4' || pqLinMatStr == 'Z5'|| pqLinMatStr == 'Z9' || pqLinMatStr == 'Z0' || pqLinMatStr == 'ZU' ) {
            colorStr = '#CC3333';
        }else if( pqLinMatStr == 'Z1' || pqLinMatStr == 'Z2' || pqLinMatStr == 'Z3' || pqLinMatStr == 'Z7' || pqLinMatStr == 'Z8' ) {
            colorStr = '#CCFF66';
        }
        else if( pqLinMatStr == '40' ){ colorStr = '#66FF66';}

        else if( pqLinMatStr == 'Z6' || pqLinMatStr == 'ZR'  ){colorStr = '#0099FF';}
        else if(pqLinMatStr != null  && pqLinMatStr != ''){
            colorStr = 'White';
        }
        return colorStr;
    }

    /* Description: It is used to create record for pqli object.
                    This is centralized method which is getting called from various methods
                    when we map the row values to pqli records in Database ONLY IN CASE OF GKN PRICING LOGIC.
    */

    public Price_Quote_Line_Item__c createPriceQuoteLineObjSFDC( Product2 prdObj,  Contract_Material__c contMaterialObj) {
        Price_Quote_Line_Item__c priceQuoteLineObjToIns = new Price_Quote_Line_Item__c();
        if(prdObj!=null) {
            priceQuoteLineObjToIns.Material_Name__c = prdObj.id;
            priceQuoteLineObjToIns.Material_Status__c = (contMaterialObj!=null)?contMaterialObj.Product__r.Material_Status_Numeric__c:'';

            if(prdObj.Cross_References__r.size()>0)
                priceQuoteLineObjToIns.Competetive_Product__c = prdObj.Cross_References__r[0].id;
            else
                priceQuoteLineObjToIns.Competetive_Product__c = null;

            priceQuoteLineObjToIns.Rep_Price__c = prdObj.Rep_Price__c;
            priceQuoteLineObjToIns.RSM_Price__c = prdObj.RSM_Price__c;
            priceQuoteLineObjToIns.List_Price__c = prdObj.List_Price__c;
            priceQuoteLineObjToIns.Cost__c= prdObj.Cost__c;


            if( contMaterialObj!=null && contMaterialObj.Agreement__r.Agreement_Number__c != null) {
                if(contMaterialObj.Agreement__r.Agreement_Number__c.startsWith('00'))
                    priceQuoteLineObjToIns.Sales_Number__c = contMaterialObj.Agreement__r.Agreement_Number__c.removeStart('00');
                else
                    priceQuoteLineObjToIns.Sales_Number__c = contMaterialObj.Agreement__r.Agreement_Number__c;
            }else
                priceQuoteLineObjToIns.Sales_Number__c = '';

            priceQuoteLineObjToIns.Sales_deal_Description__c = (contMaterialObj!=null)?contMaterialObj.Agreement__r.Description__c:'';

            /*

            if(contMaterialObj!=null && conditionMap != null && conditionMap.containsKey(contMaterialObj.Condition__c))
                priceQuoteLineObjToIns.Condition__c = conditionMap.get(contMaterialObj.Condition__c).Mapped_Value__c;
            else
                priceQuoteLineObjToIns.Condition__c = '';
            */

            priceQuoteLineObjToIns.Eligible_Price__c = (contMaterialObj!=null)?contMaterialObj.Price__c:0;
            priceQuoteLineObjToIns.Sales_Price__c = (contMaterialObj!=null)?contMaterialObj.Price__c:0;

            priceQuoteLineObjToIns.Quantity__c = 1;
            priceQuoteLineObjToIns.Extended_Price__c = priceQuoteLineObjToIns.Sales_Price__c;
            priceQuoteLineObjToIns.Price_Quote__c = pq.id;

        }
        return priceQuoteLineObjToIns;
    }

    /* Description: It is used to create record for pqliu object
                    This is centralized method which is getting called from various methods when we map the row values to pqli records in Database.
    */
    public Price_Quote_Line_Item__c createPriceQuoteLineObj( Product2 prdObj, SAPRealPriceSet__x sapObj) {
        Price_Quote_Line_Item__c priceQuoteLineObjToIns = new Price_Quote_Line_Item__c();
        Map<String, Sales_Condition_Mapping__c> conditionMap = Sales_Condition_Mapping__c.getAll();
        if(prdObj!=null) {
            priceQuoteLineObjToIns.Material_Name__c = prdObj.id;
            priceQuoteLineObjToIns.Material_Status__c = (sapObj!=null)?sapObj.MtrlStatus__c:'';

            if(prdObj.Cross_References__r.size()>0)
                priceQuoteLineObjToIns.Competetive_Product__c = prdObj.Cross_References__r[0].id;
            else
                priceQuoteLineObjToIns.Competetive_Product__c = null;

            priceQuoteLineObjToIns.Rep_Price__c = prdObj.Rep_Price__c;
            priceQuoteLineObjToIns.RSM_Price__c = prdObj.RSM_Price__c;
            priceQuoteLineObjToIns.List_Price__c = prdObj.List_Price__c;
            priceQuoteLineObjToIns.Cost__c= prdObj.Cost__c;
            if( sapObj!=null && sapObj.SalesDeal__c != null) {
                if(sapObj.SalesDeal__c.startsWith('00'))
                    priceQuoteLineObjToIns.Sales_Number__c = sapObj.SalesDeal__c.removeStart('00');
                else
                    priceQuoteLineObjToIns.Sales_Number__c = sapObj.SalesDeal__c;
            }else
                priceQuoteLineObjToIns.Sales_Number__c = '';
            priceQuoteLineObjToIns.Sales_deal_Description__c = (sapObj!=null)?sapObj.AgrDesc__c:'';

            if(sapObj!=null && conditionMap != null && conditionMap.containsKey(sapObj.Condition__c))
                priceQuoteLineObjToIns.Condition__c = conditionMap.get(sapObj.Condition__c).Mapped_Value__c;
            else
                priceQuoteLineObjToIns.Condition__c = '';

            priceQuoteLineObjToIns.Eligible_Price__c = (sapObj!=null)?sapObj.Price__c:0;

            if( priceQuoteLineObjToIns.Eligible_Price__c != null && priceQuoteLineObjToIns.Eligible_Price__c !=0 ) {
                priceQuoteLineObjToIns.Sales_Price__c = (sapObj!=null)?sapObj.Price__c:0;
            }else {
                //priceQuoteLineObjToIns.Sales_Price__c = (sapObj!=null)?sapObj.ListPrice__c:0;
                priceQuoteLineObjToIns.Sales_Price__c = priceQuoteLineObjToIns.List_Price__c;
                priceQuoteLineObjToIns.Eligible_Price__c = priceQuoteLineObjToIns.Sales_Price__c;
            }

            priceQuoteLineObjToIns.Quantity__c = 1;
            priceQuoteLineObjToIns.Extended_Price__c = priceQuoteLineObjToIns.Sales_Price__c;
            priceQuoteLineObjToIns.Price_Quote__c = pq.id;

        }

        return priceQuoteLineObjToIns;
    }

    /* Description: It is used to put the information in pqli rows.
                    This is centralized method which is getting called from various methods whereever we need to set values for pqli rows.
    */
    public void autoPopulateRowDate(Integer param) {
        Savepoint sp = Database.setSavepoint();
        String crossId = null;
            Set<String> setMaterialnumber = new Set<String>();
            List<String> currProd = new List<String>();
            Set<String> setCrossRef = new Set<String>();
            Boolean crossRefDisplayChk = True;

            for( priceQuoteLineItems items : lstpriceQuoteLineItems ) {
                system.debug('***items.counterWrap***'+(items.counterWrap == param));
                if(items.strMaterialnumber != null && items.strMaterialnumber != '' && items.counterWrap == param ) {
                  system.debug('*** items.strMaterialnumber *** '+ items.strMaterialnumber);
                    setMaterialnumber.add(items.strMaterialnumber);
                    currProd.add(items.strMaterialnumber);
                    items.showHidenField = True;
                    crossRefDisplayChk = True;
                }

                if(items.strCrossReference  != null && items.strCrossReference  != '' && items.counterWrap == param) {
                  system.debug('*** items.strCrossReference *** '+ items.strCrossReference);
                    setCrossRef.add(items.strCrossReference);
                    items.showHidenField = False;
                    crossRefDisplayChk = False;
                }
            }

            if(setCrossRef.size()>0) {
                String strmat = '';
                for(Cross_Reference__c crPrd : [Select id, Product__r.Name from Cross_Reference__c where Competitor_Product_Code__c IN: setCrossRef]){
                    setMaterialnumber.add(crPrd.Product__r.Name);
                    crossId = crPrd.Id;
                    strmat = crPrd.Product__r.Name;
                }
                if(lstpriceQuoteLineItems.size()<=param)
                    lstpriceQuoteLineItems[param-1].strMaterialnumber = strmat;
            }

            List<Product2> productListTemp = new List<Product2>();
            if(!setMaterialnumber.Isempty()) {
                productListTemp = [Select id,Cost__c, Name, Image_URL__c,Rep_Price__c,RSM_Price__c, Description,List_Price__c, Cost_Price__c,Sales_Unit__c,Material_Status__c, Qty_Sales_Unit__c, Cost_Price_Unit__c,
                                          (Select id, Name,Competitor_Product_Code__c, Competitor_Name__c from Cross_References__r ORDER BY lastmodifiedDate LIMIT 1),
                                          (Select Id, Price__c,Agreement__r.Agreement_Number__c, Agreement__r.Description__c from Contract_Material__r ORDER BY lastmodifiedDate LIMIT 1)
                                          From  Product2
                                          Where Name IN : setMaterialnumber AND Sales_Org_Key__c =:pq.Sales_Org_Key__c ORDER BY List_Price__c DESC LIMIT 1 ];
            }

            Product2 prdObj = (productListTemp!=null && productListTemp.size()>0)?productListTemp[0]:null;
            system.debug('**********prdObj**********'+prdObj);

            if(prdObj!=null) {
                try{
                Map<String,SAPRealPriceSet__x> sapPriceMap = createSapMap(setMaterialnumber);
                  system.debug('sapPriceMap ================== ' + sapPriceMap);
                PriceQuoteLineItems pqliWrapObj = (lstpriceQuoteLineItems != null && lstpriceQuoteLineItems.size()>=param)?lstpriceQuoteLineItems.get(param-1):null;

                SAPRealPriceSet__x sapObj = sapPriceMap.containsKey(pqliWrapObj.strMaterialnumber)?sapPriceMap.get(pqliWrapObj.strMaterialnumber):null;

                sapPriceMap.clear();

                system.debug('**********sapObj**********'+sapObj);
                if(pqliWrapObj != null) {
                    pqliWrapObj.strMaterialnumber = prdObj.Name;
                    if(prdObj.Cross_References__r.size()>0){
                        pqliWrapObj.strCrossReference = prdObj.Cross_References__r[0].Competitor_Product_Code__c;
                    }else{
                        pqliWrapObj.strCrossReference = null;
                    pqliWrapObj.imageURL = prdObj.Image_URL__c;
                  }

                    Price_Quote_Line_Item__c priceQuoteLineObjToIns = createPriceQuoteLineObj(prdObj,sapObj);
                    priceQuoteLineObjToIns.Hide_Crossreference__c = crossRefDisplayChk;
                    priceQuoteLineObjToIns.Row_Order__c = lstpriceQuoteLineItems.size();
                    priceQuoteLineObjToIns.CurrencyIsoCode = pq.CurrencyIsoCode;
                    if(crossId != null){
                      priceQuoteLineObjToIns.Competetive_Product__c = crossId;
                    }
                    insert priceQuoteLineObjToIns;

                    pqliWrapObj.colorName = createMatStatColorCode(priceQuoteLineObjToIns.Material_Status__c);

                    if(priceQuoteLineObjToIns.id != null) {
                        pqliWrapObj.priceQuoteLine = [Select id,Sales_Price__c,Rep_Price__c,RSM_Price__c,List_Price__c , Approval_Flag__c,Extended_Price__c,Quantity__c,Eligible_Price__c,Material_Status__c,
                                                 Condition__c,Sales_deal_Description__c,Sales_Number__c,Competetive_Product__c,Material_Name__c,Material_Status_Description__c,CurrencyIsoCode,
                                                 Description__c,Hide_Crossreference__c,Sales_Unit_Qty__c,Sales_Unit__c From Price_Quote_Line_Item__c Where Id=: priceQuoteLineObjToIns.id];
                    lstlineItems = [Select id,Sales_Price__c,Rep_Price__c,RSM_Price__c,List_Price__c ,Approval_Flag__c,Extended_Price__c,Quantity__c,Eligible_Price__c,Material_Status__c,
                                                 Condition__c,Sales_deal_Description__c,Sales_Number__c,Competetive_Product__c,Material_Name__c,Material_Status_Description__c,CurrencyIsoCode,
                                                 Description__c,Hide_Crossreference__c,Sales_Unit_Qty__c,Sales_Unit__c From Price_Quote_Line_Item__c Where Id=: priceQuoteLineObjToIns.id];
                    }

                }
                processGrandTotal();
            	  addRow();
                }catch (Exception ex) {
                    Database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                }

            }
            else{
              removingRow();
              addRow();
                apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.label.EMEA_Please_enter_valid_material_name));
            	return;
            }
    }

    // Description: When user clicks on add button. It just calls various written methods.
    public void searchMethod() {
      Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
      System.debug('--------------param--------------------'+param);
        //check is quote is in approval process
        List<Product2> currProd = [SELECT Name FROM Product2 WHERE Name =:strMaterialnumber];
        if(pq.Status__c == 'Approved' || pq.Status__c == 'Waiting For RSM Approval' || pq.Status__c == 'Waiting for Contracts Approval'){
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.label.EMEA_Search_Terms_must_be_longer_than_one_character));
            return;
        }
        else{
            //Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
            //System.debug('--------------param--------------------'+param);
            autoPopulateRowDate(param);
            //processPriceQuote();
            //processGrandTotal();
            //addRow();
        }
    }


    public void processCalculationMethod() {
        system.debug('*******Integer.valueOf(contextItem)*******'+Integer.valueOf(contextItem));
        for( priceQuoteLineItems items : lstpriceQuoteLineItems) {
        system.debug('items.priceQuoteLine.Quantity__c =============================== ' + items.priceQuoteLine.Quantity__c);
            if(items.counterWrap == Integer.valueOf(contextItem) && items.priceQuoteLine.Quantity__c != null && items.priceQuoteLine.Quantity__c != 0 && items.priceQuoteLine.Sales_Price__c != 0 && items.priceQuoteLine.Sales_Price__c != null) {
                items.priceQuoteLine.Extended_Price__c = items.priceQuoteLine.Sales_Price__c*items.priceQuoteLine.Quantity__c;
            }
        }
        processGrandTotal();
    }

    // Description: It was getting used for grand total of sales price. Not using any more
    public void processGrandTotal() {
        GrandTotal = 0;
        for( priceQuoteLineItems items :lstpriceQuoteLineItems){

            if(items.innerlineprices != 0 && items.innerlineprices != null) {
                GrandTotal = GrandTotal + items.innerlineprices;
            }
        }
    }


    // Description: Add a blank row with input fields.
    public void addRow() {
        priceQuoteLineItems priceWrapper = new priceQuoteLineItems();
        priceWrapper.counterWrap = lstpriceQuoteLineItems.size() +1;
        lstpriceQuoteLineItems.add(priceWrapper);
    }


    // Description: Thsi is getting used when user delete or remove any row for pqli.
    public PageReference removingRow() {

        Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
        Savepoint sp = Database.setSavepoint();

        List<Price_Quote_Line_Item__c> lstPriceQuote = new List<Price_Quote_Line_Item__c>();
        try{
             for( priceQuoteLineItems items :lstpriceQuoteLineItems){

                if(items.counterWrap == param && items.priceQuoteLine.Id != null){

                    lstPriceQuote.add(items.priceQuoteLine);
                }
              }
              if(lstPriceQuote.size()>0)
                  delete lstPriceQuote;
         }catch(Exception ex){
             Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
         }
         if(lstpriceQuoteLineItems.size() > 1){
            for(Integer i=0;i<lstpriceQuoteLineItems.size();i++){
                if(lstpriceQuoteLineItems[i].counterWrap == param ){
                    lstpriceQuoteLineItems.remove(i);
                }
            }
            for(Integer i=1;i<=lstpriceQuoteLineItems.size();i++){
                lstpriceQuoteLineItems[i-1].counterWrap = i;
            }
        }
        counter--;
        return null;
    }



    public PageReference processPriceQuote() {
        Savepoint sp = Database.setSavepoint();
        pageReference objP = null;
        List<Price_Quote_Line_Item__c> lstPriceQuote = new List<Price_Quote_Line_Item__c>();
        try {
            if(lstpriceQuoteLineItems.size()> 0) {
                system.debug('***********lstpriceQuoteLineItems************'+lstpriceQuoteLineItems);
                system.debug('***********lstpriceQuoteLineItems.size()************'+lstpriceQuoteLineItems.size());
                for(priceQuoteLineItems newLines : lstpriceQuoteLineItems) {
                    if(newLines.strMaterialnumber != null && newLines.strMaterialnumber != '') {

                        Price_Quote_Line_Item__c prodQuoteLineRow = new Price_Quote_Line_Item__c();
                        if(newLines.priceQuoteLine.Id != null) {
                            prodQuoteLineRow.Id = newLines.priceQuoteLine.Id;
                        }
                        prodQuoteLineRow = newLines.priceQuoteLine;
                        if(newLines.crossRef != null && newLines.crossRef.id !=  null)
                            prodQuoteLineRow.Competetive_Product__c = newLines.crossRef.Id;
                        if(newLines.prod != null && newLines.prod.id !=  null)
                            prodQuoteLineRow.Material_Name__c = newLines.prod.Id;
                        if(newLines.priceQuoteLine.Id == null)
                            prodQuoteLineRow.Price_Quote__c = prdQuoteRow.Id;
                        //prodQuoteLineRow.Price__c = newLines.contractMaterial.Id;
                        prodQuoteLineRow.Quantity__c = newLines.priceQuoteLine.Quantity__c;
                        lstPriceQuote.add(prodQuoteLineRow);
                    }
                }

                if(lstPriceQuote.size() > 0)
                    upsert lstPriceQuote;

                //objP = new Pagereference('/'+prdQuoteRow.Id).setRedirect(True);
                objP = new Pagereference('/apex/PP_Price_Quote?pqId='+prdQuoteRow.Id).setRedirect(True);
            }

        }catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return objP;
    }


    public boolean hasError { get; set; }
    public Pagereference doUpdateAccountValue() {
        hasError = false;
        system.debug('****Account_Name__c****'+pq.Account_Name__c);
        system.debug('****pq.Contact_Name__c****'+pq.Contact_Name__c);
        Map<Id, Contact> mapContact = new Map<Id, Contact>([Select Id from Contact where AccountId =: pq.Account_Name__c]);
        //List<Contact> lstContact = [Select Id from Contact where AccountId =: pq.Account_Name__c];
        system.debug('****lstContact****'+mapContact);
        if(mapContact.containsKey(pq.Contact_Name__c)){
            String pqid = Apexpages.currentpage().getParameters().get('pqid');
            //Price_Quote__c pqObj = getpq();
            update pq;
            return new Pagereference('/apex/PP_Price_Quote?pqId='+pqid).setRedirect(True);
        }
        else{
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.EMEA_Please_choose_contact_related_to_account));
             return null;
        }
    }


    public Pagereference doCloning() {
        //String cloneType = Apexpages.currentpage().getParameters().get('cloneType');

        Savepoint sp = Database.setSavepoint();
        pageReference objP = null;
        List<Price_Quote_Line_Item__c> lstPriceQuote = new List<Price_Quote_Line_Item__c>();
        try {
            Price_Quote__c prdQuoteRowClone = new Price_Quote__c();
            prdQuoteRowClone.Account_Name__c = pq.Account_Name__c;
            prdQuoteRowClone.Contact_Name__c  = pq.Contact_Name__c;
            prdQuoteRowClone.No_Opp__c = pq.No_Opp__c;
            prdQuoteRowClone.Sales_Org_Key__c = pq.Sales_Org_Key__c;
            if(pq.Opportunity__c != null){
                prdQuoteRowClone.Opportunity__c = pq.Opportunity__c;
            }

            insert prdQuoteRowClone;

            system.debug('****prdQuoteRowClone****'+prdQuoteRowClone);
            system.debug('****lstpriceQuoteLineItems.size****'+lstpriceQuoteLineItems.size());
            if(lstpriceQuoteLineItems.size()> 0) {
                for(priceQuoteLineItems newLines : lstpriceQuoteLineItems) {
                    if(newLines.strMaterialnumber != null && newLines.strMaterialnumber != '') {
                        Price_Quote_Line_Item__c prodQuoteLineRow = new Price_Quote_Line_Item__c();
                        prodQuoteLineRow = newLines.priceQuoteLine.clone();
                        if(newLines.crossRef != null && newLines.crossRef.id !=  null)
                            prodQuoteLineRow.Competetive_Product__c = newLines.crossRef.Id;
                        if(newLines.prod != null && newLines.prod.id !=  null)
                            prodQuoteLineRow.Material_Name__c = newLines.prod.Id;
                        if(prodQuoteLineRow != null && prdQuoteRowClone != null && prdQuoteRowClone.id != null)
                            prodQuoteLineRow.Price_Quote__c = prdQuoteRowClone.id;

                        if(prodQuoteLineRow.id != null)
                            prodQuoteLineRow.id = null;
                        lstPriceQuote.add(prodQuoteLineRow);
                    }
                }

                if(lstPriceQuote.size() > 0)
                    insert lstPriceQuote;

                objP = new Pagereference('/apex/PP_Price_Quote?pqId='+prdQuoteRowClone.Id).setRedirect(True);
            }
        }catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return objP;
    }



    //start of Dun's method
    //SAP bulk insert price lookup
    // Description: Thsi is getting used when user do bulk insert materials using sap(External objects) logic.
    public void bulkInsert() {
        List<Price_Quote_Line_Item__c> qLineItem = new List<Price_Quote_Line_Item__c>();
        strQuoteId = ApexPages.currentPage().getParameters().get('pqId');

        if(strMats == '' || strMats == null){
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'No products found..'));
            //return null;
        }else {
            List<String> bulkMats = new List<String>();
            strMats = strMats.toUpperCase();
            //bulkMats = strMats.split('[\n\r]');
            for( String str : strMats.split('\n') ) {
                bulkMats.add(str.trim());
            }
            //bulkMats = strMats.split('\n');
            //system.assertequals(bulkMats.size(),null);
            Map<String,Product2> prodMap = new Map<String,Product2>();
            for( Product2 prodStr : [Select id, Name,Rep_Price__c,Cost__c,RSM_Price__c, Description, Image_URL__c, Cost_Price__c, Sales_Unit__c, Qty_Sales_Unit__c, Cost_Price_Unit__c,List_Price__c,
                                    (Select id,Competitor_Product_Code__c, Name, Competitor_Name__c from Cross_References__r ORDER BY lastmodifiedDate LIMIT 1),
                                    (Select Id, Price__c,Agreement__r.Agreement_Number__c, Agreement__r.Description__c
                                     from Contract_Material__r ORDER BY lastmodifiedDate) from  Product2 where Name IN :bulkMats AND Sales_Org_Key__c =:pq.Sales_Org_Key__c]) {
                prodMap.put(prodStr.Name,prodStr);
            }


            lstpriceQuoteLineItems.remove(lstpriceQuoteLineItems.size()-1);
            Map<String,SAPRealPriceSet__x> sapPriceMap = createSapMap(prodMap.keySet());
            //Map<String,SAPRealPriceSet__x> sapPriceMap = createSapMap(new Set<String>{'DTRC-10S','175030'});
            system.debug('sapPriceMap ================== ' + sapPriceMap);
            Product2 currProdObj;
            SAPRealPriceSet__x sapObj;
            priceQuoteLineItems pqliWrapObj;


            Map<String, String> cmMapsalesOrg = calSalesOrgStr(pq.Account_Name__r.SAP_Sold_To__c, prodMap.keySet());

            for(String prodName : bulkMats) {
                currProdObj = prodMap.containsKey(prodName)?prodMap.get(prodName):null;
                //sapObj = sapPriceMap.containsKey(prodName)?sapPriceMap.get(prodName):null;

                sapObj = new SAPRealPriceSet__x();

                String salesOrgStr = cmMapsalesOrg.containsKey(prodName)?cmMapsalesOrg.get(prodName):'';
                List<SAPRealPriceSet__x> sapObjList = [SELECT Price__c,Material__c,Agreement__c,ListPrice__c,SalesDeal__c,MtrlStatus__c,AgrDesc__c,Condition__c FROM SAPRealPriceSet__x where SalesOrg__c =:salesOrgStr
                                      And DistChnl__c = '10' And Customer__c = :pq.Account_Name__r.SAP_Sold_To__c And Material__c =: prodName
                                      And EffDate__c=:System.Now()];

                if(sapObjList != null && sapObjList.size()>0){
                    sapObj = sapObjList[0];
                }
                system.debug('**********currProdObj**********'+currProdObj);
                system.debug('**********sapObj**********'+sapObj);

                if(currProdObj != null) {
                    Price_Quote_Line_Item__c lineObj = createPriceQuoteLineObj( currProdObj,sapObj );


                    lineObj.Row_Order__c = lstpriceQuoteLineItems.size()+1;
                    lineObj.CurrencyIsoCode = pq.CurrencyIsoCode;
                    system.debug('**********lineObj **********'+lineObj);

                    pqliWrapObj = new priceQuoteLineItems();
                    pqliWrapObj.counterWrap = lstpriceQuoteLineItems.size()+1;
                    pqliWrapObj.strMaterialnumber = currProdObj.Name;

                    if(currProdObj.Cross_References__r.size()>0)
                        pqliWrapObj.strCrossReference = currProdObj.Cross_References__r[0].Competitor_Product_Code__c;
                    else
                        pqliWrapObj.strCrossReference = null;
                    pqliWrapObj.imageURL = currProdObj.Image_URL__c;
                    pqliWrapObj.colorName = createMatStatColorCode(lineObj.Material_Status__c);
                    lineObj.Hide_Crossreference__c = False;
                    //pqliWrapObj.showHidenField = False;
                    //pqliWrapObj.priceQuoteLine = lineObj;
                    qLineItem.add(lineObj);
                    system.debug('*****pqliWrapObj.priceQuoteLine*****' + pqliWrapObj.priceQuoteLine);
                    lstpriceQuoteLineItems.add(pqliWrapObj);
                }
            }
            sapPriceMap.clear();
            if(qLineItem.size()>0)
                insert qLineItem;
            system.debug('qLineItem============================================= ' + qLineItem.size());

            Integer countVar=0;
            for( Price_Quote_Line_Item__c liObj : [Select id,Sales_Price__c,Rep_Price__c,RSM_Price__c,List_Price__c , Approval_Flag__c,Hide_Crossreference__c,Extended_Price__c,Quantity__c,Eligible_Price__c,Material_Status__c,
                                                    Condition__c,Sales_deal_Description__c,Sales_Number__c,Competetive_Product__c,Material_Name__c,Material_Status_Description__c,
                                                    Description__c,Sales_Unit_Qty__c,Sales_Unit__c From Price_Quote_Line_Item__c Where Price_Quote__c=: strQuoteId Order By Row_Order__c]) {
                //system.assertequals(liObj,null);
                lstpriceQuoteLineItems[countVar].priceQuoteLine = liObj;
                countVar++;
            }

            addRow();
            //return new Pagereference('/apex/PP_Price_Quote?pqid='+strQuoteId);
        }

    }
    //end of Dun's method



    // Description: Thsi is getting used when user do bulk insert materials using gkn custom price logic.
    public void gknBulkInsert() {
        List<Price_Quote_Line_Item__c> qLineItem = new List<Price_Quote_Line_Item__c>();
        strQuoteId = ApexPages.currentPage().getParameters().get('pqId');

        if(strMats == '' || strMats == null){
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, System.label.EMEA_No_products_found));
            //return null;
        }else {
            List<String> bulkMats = new List<String>();
            strMats = strMats.toUpperCase();
            //bulkMats = strMats.split('[\n\r]');
            for( String str : strMats.split('\n') ) {
                bulkMats.add(str.trim());
            }
            //bulkMats = strMats.split('\n');
            //system.assertequals(bulkMats.size(),null);
            Map<String,Product2> prodMap = new Map<String,Product2>();
            for( Product2 prodStr : [Select id, Name,Rep_Price__c,Cost__c,RSM_Price__c, Description, Image_URL__c, Cost_Price__c, Sales_Unit__c, Qty_Sales_Unit__c, Cost_Price_Unit__c,List_Price__c,
                                    (Select id,Competitor_Product_Code__c, Name, Competitor_Name__c from Cross_References__r ORDER BY lastmodifiedDate LIMIT 1),
                                    (Select Id, Price__c,Agreement__r.Agreement_Number__c, Agreement__r.Description__c
                                     from Contract_Material__r ORDER BY lastmodifiedDate) from  Product2 where Name IN :bulkMats AND Sales_Org_Key__c =:pq.Sales_Org_Key__c]) {
                prodMap.put(prodStr.Name,prodStr);
            }


            lstpriceQuoteLineItems.remove(lstpriceQuoteLineItems.size()-1);
            Map<String,Contract_Material__c> contMaterialMap = createcontMaterialMap(pq.Account_Name__r.SAP_Sold_To__c, prodMap.keySet());

            system.debug('**********contMaterialMap**********'+contMaterialMap);

            Product2 currProdObj;
            Contract_Material__c contMatObj;
            priceQuoteLineItems pqliWrapObj;
            for(String prodName : bulkMats) {
                currProdObj = prodMap.containsKey(prodName)?prodMap.get(prodName):null;
                contMatObj = new Contract_Material__c();
                contMatObj = contMaterialMap.containsKey(prodName)?contMaterialMap.get(prodName):null;


                system.debug('**********currProdObj**********'+currProdObj);
                system.debug('**********contMatObj**********'+contMatObj);

                if(currProdObj != null) {
                    Price_Quote_Line_Item__c lineObj = createPriceQuoteLineObjSFDC(currProdObj,contMatObj);

                    lineObj.Row_Order__c = lstpriceQuoteLineItems.size()+1;
                    lineObj.CurrencyIsoCode = pq.CurrencyIsoCode;
                    system.debug('**********lineObj **********'+lineObj);

                    pqliWrapObj = new priceQuoteLineItems();
                    pqliWrapObj.counterWrap = lstpriceQuoteLineItems.size()+1;
                    pqliWrapObj.strMaterialnumber = currProdObj.Name;

                    if(currProdObj.Cross_References__r.size()>0)
                        pqliWrapObj.strCrossReference = currProdObj.Cross_References__r[0].Competitor_Product_Code__c;
                    else
                        pqliWrapObj.strCrossReference = null;
                    pqliWrapObj.imageURL = currProdObj.Image_URL__c;
                    lineObj.Hide_Crossreference__c = False;
                    //pqliWrapObj.showHidenField = False;
                    //pqliWrapObj.priceQuoteLine = lineObj;
                    qLineItem.add(lineObj);
                    system.debug('*****pqliWrapObj.priceQuoteLine*****' + pqliWrapObj.priceQuoteLine);
                    lstpriceQuoteLineItems.add(pqliWrapObj);
                }
            }
            contMaterialMap.clear();
            if(qLineItem.size()>0)
                insert qLineItem;
            system.debug('qLineItem============================================= ' + qLineItem.size());

            Integer countVar=0;
            for( Price_Quote_Line_Item__c liObj : [Select id,Sales_Price__c,Rep_Price__c,RSM_Price__c,List_Price__c , Approval_Flag__c,Hide_Crossreference__c,Extended_Price__c,Quantity__c,Eligible_Price__c,Material_Status__c,
                                                    Condition__c,Sales_deal_Description__c,Sales_Number__c,Competetive_Product__c,Material_Name__c,Material_Status_Description__c,
                                                    Description__c,Sales_Unit_Qty__c,Sales_Unit__c From Price_Quote_Line_Item__c Where Price_Quote__c=: strQuoteId Order By Row_Order__c]) {
                //system.assertequals(liObj,null);
                lstpriceQuoteLineItems[countVar].priceQuoteLine = liObj;
                countVar++;
            }

            addRow();
            //return new Pagereference('/apex/PP_Price_Quote?pqid='+strQuoteId);
        }
    }

    // Not getting used anymore.
    // sort line items
    public Pagereference sortLineItems(){
        String strPriceQuoteId = ApexPages.currentPage().getParameters().get('pqId');
        return new Pagereference('/apex/PP_Sort_LineItems?pqid='+strPriceQuoteId);
    }

    /*
        Description: Thsi is getting used when user save after sorting the rows.
    */
    @RemoteAction
    public static String saveSortedRows(List<String> rowsIdList) {
        try {
            List<Price_Quote_Line_Item__c> pqliListToUpdate = new List<Price_Quote_Line_Item__c>();

            String messageStr = '';
            Map<id,Price_Quote_Line_Item__c> pqliMap = new Map<id,Price_Quote_Line_Item__c>([Select id from Price_Quote_Line_Item__c Where ID IN:rowsIdList]);
            if(rowsIdList.size() > 0) {
                Price_Quote_Line_Item__c pqObjOpr;
                String idVal;
                System.debug('---------------rowsIdList--------------'+rowsIdList);
                for( Integer i=0; i<rowsIdList.size(); i++ ) {
                    pqObjOpr = new Price_Quote_Line_Item__c();
                    idVal = rowsIdList[i];
                    if(String.IsNotBlank(idVal)){
                        if(pqliMap.containsKey(idVal)) {
                            pqObjOpr = pqliMap.get(idVal);
                            pqObjOpr.Row_Order__c = i;
                            pqliListToUpdate.add(pqObjOpr);
                        }
                    }
                }
            }

            if(pqliListToUpdate.size()>0) {
                update pqliListToUpdate;
            }
            return 'True';
        }catch(Exception e) {
            return 'False';
        }
    }


    /*
        Description: Wrapper class is getting used to display pqli rows.
    */
    public class priceQuoteLineItems {

        public Integer counterWrap    {get;set;}
        public boolean showHidenField {get; set;}
        public String strMaterialnumber {get;set;}
        public String strMaterialnumberId {get;set;}
        public String strMaterialStatus {get;set;}
        public String strCrossReference {get;set;}
        public String strCrossReferenceHidden {get;set;}
        public Product2 prod {get;set;}
        public string imageURL {get;set;}
        //public Decimal eligiblePrice {get;set;}
        public Decimal innerlineprices {get;set;}
        public Cross_Reference__c crossRef {get;set;}
        public Contract_Material__c contractMaterial {get; set;}
        public Price_Quote_Line_Item__c priceQuoteLine {get; set;}
        public String colorName {get; set;}

    }


    /*
        Description: This is getting used to fetch whole price quote information.
                     Get Price quote header info.
    */
    public Price_Quote__c getpq() {
        try{
            return [Select Id, Name, Opportunity__r.Name, Opportunity__c, Price_Quote_Name__c, Status__c, Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c,
                    Customer_comments__c, Internal_Comments_Only__c, Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity,
                    Account_Name__r.BillingState, Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c,Account_Name__r.Account_Group__c,
                    Quote_Description__c, No_Opp__c, Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Owner_Cell__c, Owner_Phone__c, Owner_Email__c, Contact_Name__r.name,
                    Business_Unit__c, Contact_Name__r.id, Contact_Name__r.phone, Contact_Name__r.email, LastModifiedById, CreatedById, Territory__r.Territory_Name__c,
                    Territory__r.Territory_Number__c,Approval_Flag_Rollup__c, CurrencyIsoCode,Sales_Org_Key__c
                    FROM Price_Quote__c
                    WHERE id = :ApexPages.currentPage().getParameters().get('pqid')
                    LIMIT 1];
        }

        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }


    /*
        Description: Get the active quote for user.

    public String getActiveQuoteIdStr() {
        String activeQuoteIdStr = '';
        List<User> userList = [Select id, Active_Quote_Id__c from User Where Id=: UserInfo.getUserId()];
        if(userList.size() > 0) {
            activeQuoteIdStr = userList[0].Active_Quote_Id__c;
        }
        return activeQuoteIdStr;
    }*/

    // Saving the Do Not Create Opportunity Checkbox
    public PageReference saveCheck(){
        system.debug('pq.No_Opp__c =========================== ' + pq.No_Opp__c);
            strQuoteId = ApexPages.currentPage().getParameters().get('pqid');
        Price_Quote__c mypq = new Price_Quote__c(id=strQuoteId,No_Opp__c=pq.No_Opp__c);
        update pq;
        return null;
    }

	//Start of new pricing functionality
    //single line RSM price update
    public PageReference updateRSMprice(){
        String listPrice = Apexpages.currentpage().getParameters().get('rsmPrice');
        String row = Apexpages.currentpage().getParameters().get('index');
        Integer rowId = integer.valueOf(row);
        system.debug('rowId ====================== ' + rowId);
        system.debug('listPrice ====================== ' + listPrice);
        Decimal myListPrice;
        myListPrice = decimal.valueOf(listPrice);
        system.debug('myListPrice ====================== ' + myListPrice);
        List<Price_Quote_Line_Item__c> upToRsm = new List<Price_Quote_Line_Item__c>();

        for(priceQuoteLineItems curr : lstpriceQuoteLineItems){
            if(curr.counterwrap == rowId){
              system.debug('curr.priceQuoteLine.Sales_Price__c ====================== ' + curr.priceQuoteLine.Sales_Price__c);
              system.debug('myListPrice ====================== ' + myListPrice);
                curr.priceQuoteLine.Sales_Price__c = myListPrice;
                curr.priceQuoteLine.Extended_Price__c = myListPrice * curr.priceQuoteLine.Quantity__c;
                upToRsm.add(curr.priceQuoteLine);
            }
        }
        update upToRsm;
        return null;
    }

    //single line Rep Price update
    public PageReference updateRepPrice(){
        String listPrice = Apexpages.currentpage().getParameters().get('repPrice');
        String row = Apexpages.currentpage().getParameters().get('index');
        Integer rowId = integer.valueOf(row);
        system.debug('listPrice ====================== ' + listPrice);
        Decimal myListPrice;
        myListPrice = decimal.valueOf(listPrice);
        system.debug('myListPrice ====================== ' + myListPrice);
        List<Price_Quote_Line_Item__c> upToRep = new List<Price_Quote_Line_Item__c>();

        for(priceQuoteLineItems curr : lstpriceQuoteLineItems){
            if(curr.counterwrap == rowId){
            	curr.priceQuoteLine.Sales_Price__c = myListPrice;
                curr.priceQuoteLine.Extended_Price__c = myListPrice * curr.priceQuoteLine.Quantity__c;
                upToRep.add(curr.priceQuoteLine);
            }
        }
        update upToRep;
        return null;
    }

    //single line List Price update
    public PageReference updateListPrice(){
        String listPrice = Apexpages.currentpage().getParameters().get('listPrice');
        String row = Apexpages.currentpage().getParameters().get('index');
        Integer rowId = integer.valueOf(row);
        system.debug('listPrice ====================== ' + listPrice);
        Decimal myListPrice;
        myListPrice = decimal.valueOf(listPrice);
        system.debug('myListPrice ====================== ' + myListPrice);
        List<Price_Quote_Line_Item__c> upToList = new List<Price_Quote_Line_Item__c>();

        for(priceQuoteLineItems curr : lstpriceQuoteLineItems){
            if(curr.counterwrap == rowId){
            	curr.priceQuoteLine.Sales_Price__c = myListPrice;
                curr.priceQuoteLine.Extended_Price__c = myListPrice * curr.priceQuoteLine.Quantity__c;
                upToList.add(curr.priceQuoteLine);
            }
        }
        update upToList;
        return null;
    }

    //single line List Price update
    public PageReference updateEligiblePrice(){
        String listPrice = Apexpages.currentpage().getParameters().get('eligiblePrice');
        String row = Apexpages.currentpage().getParameters().get('index');
        Integer rowId = integer.valueOf(row);
        system.debug('listPrice ====================== ' + listPrice);
        Decimal myListPrice;
        myListPrice = decimal.valueOf(listPrice);
        system.debug('myListPrice ====================== ' + myListPrice);
        List<Price_Quote_Line_Item__c> upToEligible = new List<Price_Quote_Line_Item__c>();

        for(priceQuoteLineItems curr : lstpriceQuoteLineItems){
            if(curr.counterwrap == rowId){
            	curr.priceQuoteLine.Sales_Price__c = myListPrice;
                curr.priceQuoteLine.Extended_Price__c = myListPrice * curr.priceQuoteLine.Quantity__c;
                upToEligible.add(curr.priceQuoteLine);
            }
        }
        update upToEligible;
        return null;
    }

    //mass List Price update
    public PageReference massUpdList(){
		strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
        system.debug('strQuoteId ======================== ' + strQuoteId);
        List<Price_Quote_Line_Item__c> upToList = new List<Price_Quote_Line_Item__c>();
        for(priceQuoteLineItems curr : lstpriceQuoteLineItems){
            system.debug('curr.priceQuoteLine.Sales_price__c============================== ' + curr.priceQuoteLine.Sales_price__c);
            system.debug('curr.priceQuoteLine.List_Price__c============================== ' + curr.priceQuoteLine.List_Price__c);
            if(curr.priceQuoteLine.Sales_price__c != null && curr.priceQuoteLine.List_price__c != null){
                curr.priceQuoteLine.Sales_price__c = curr.priceQuoteLine.List_Price__c;
            }
            if(curr.priceQuoteLine.Extended_Price__c != null && curr.priceQuoteLine.Quantity__c != null){
                curr.priceQuoteLine.Extended_Price__c = curr.priceQuoteLine.Sales_Price__c * curr.priceQuoteLine.Quantity__c;
            }

            if(curr.priceQuoteLine != null){
                upToList.add(curr.priceQuoteLine);
            }
            system.debug('upToList============================== ' + upToList);
        }
        update upToList;
        return null;
    }

    //mass RSM Price update
    public PageReference massUpdRSM(){
		strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
        system.debug('strQuoteId ======================== ' + strQuoteId);
        List<Price_Quote_Line_Item__c> upToRsm = new List<Price_Quote_Line_Item__c>();
        for(priceQuoteLineItems curr : lstpriceQuoteLineItems){
            system.debug('curr.priceQuoteLine.Sales_price__c============================== ' + curr.priceQuoteLine.Sales_price__c);
            system.debug('curr.priceQuoteLine.Rsm_Price__c============================== ' + curr.priceQuoteLine.RSM_Price__c);
            if(curr.priceQuoteLine.Sales_price__c != null && curr.priceQuoteLine.RSM_price__c != null){
                curr.priceQuoteLine.Sales_price__c = curr.priceQuoteLine.RSM_Price__c;
            }
            if(curr.priceQuoteLine.Extended_Price__c != null && curr.priceQuoteLine.Quantity__c != null){
                curr.priceQuoteLine.Extended_Price__c = curr.priceQuoteLine.Sales_Price__c * curr.priceQuoteLine.Quantity__c;
            }

            if(curr.priceQuoteLine != null){
                upToRsm.add(curr.priceQuoteLine);
            }
            system.debug('upToRsm============================== ' + upToRsm);
        }
        update upToRsm;
        return null;
    }

    //mass Rep Price update
    public PageReference massUpdRep(){
		strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
        system.debug('strQuoteId ======================== ' + strQuoteId);
        List<Price_Quote_Line_Item__c> upToRep = new List<Price_Quote_Line_Item__c>();
        for(priceQuoteLineItems curr : lstpriceQuoteLineItems){
            system.debug('curr.priceQuoteLine.Sales_price__c============================== ' + curr.priceQuoteLine.Sales_price__c);
            system.debug('curr.priceQuoteLine.Rep_Price__c============================== ' + curr.priceQuoteLine.Rep_Price__c);
            if(curr.priceQuoteLine.Sales_price__c != null && curr.priceQuoteLine.Rep_price__c != null){
                curr.priceQuoteLine.Sales_price__c = curr.priceQuoteLine.Rep_Price__c;
            }
            if(curr.priceQuoteLine.Extended_Price__c != null && curr.priceQuoteLine.Quantity__c != null){
                curr.priceQuoteLine.Extended_Price__c = curr.priceQuoteLine.Sales_Price__c * curr.priceQuoteLine.Quantity__c;
            }

            if(curr.priceQuoteLine != null){
                upToRep.add(curr.priceQuoteLine);
            }
            system.debug('upToRep============================== ' + upToRep);
        }
        update upToRep;
        return null;
    }

    //mass Eligible Price update
    public PageReference massUpdEligible(){
		strQuoteId = Apexpages.currentpage().getParameters().get('pqid');
        system.debug('strQuoteId ======================== ' + strQuoteId);
        List<Price_Quote_Line_Item__c> upToEligible = new List<Price_Quote_Line_Item__c>();
        for(priceQuoteLineItems curr : lstpriceQuoteLineItems){
            system.debug('curr.priceQuoteLine.Sales_price__c============================== ' + curr.priceQuoteLine.Sales_price__c);
            system.debug('curr.priceQuoteLine.Eligible_Price__c============================== ' + curr.priceQuoteLine.Eligible_Price__c);
            if(curr.priceQuoteLine.Sales_price__c != null && curr.priceQuoteLine.Eligible_Price__c != null){
                curr.priceQuoteLine.Sales_price__c = curr.priceQuoteLine.Eligible_Price__c;
            }
            if(curr.priceQuoteLine.Extended_Price__c != null && curr.priceQuoteLine.Quantity__c != null){
                curr.priceQuoteLine.Extended_Price__c = curr.priceQuoteLine.Sales_Price__c * curr.priceQuoteLine.Quantity__c;
            }

            if(curr.priceQuoteLine != null){
                upToEligible.add(curr.priceQuoteLine);
            }
            system.debug('upToEligible============================== ' + upToEligible);
        }
        update upToEligible;
        return null;
    }
    //End of new pricing functionality

    //functionality to add or update line item
    public void addOrUpdate(){
      strMaterialnumber = ApexPages.currentPage().getParameters().get('strCode');
      //Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
      system.debug('strMaterialnumber ============================== ' + strMaterialnumber);
      //system.debug('param ============================== ' + param);
      if(strMaterialnumber == null){
        searchMethod();
        //autoPopulateRowDate(param);
      }
      else{
        processUpdate();
      }

    }
/*
    public PageReference createPRF() {
        string newPRFid;
        list<PRF__c> insertPRF = new list<PRF__c>();
        list<PRF_Line_Item__c> insertPRFLI = new list<PRF_Line_Item__c>();
        for(Price_Quote__c pq : [SELECT Account_Name__c , Contact_Name__c, CurrencyIsoCode, Sales_Org_Key__c
                                 FROM Price_Quote__c
                                 WHERE Id = :ApexPages.currentPage().getParameters().get('pqid')])
        {
            PRF__c addPRF = new PRF__c(
                Account__c = pq.Account_Name__c,
                Contact__c = pq.Contact_Name__c,
                CurrencyIsoCode = pq.CurrencyIsoCode,
                Sales_Org_Key__c = pq.Sales_Org_Key__c
            );
            insertPRF.add(addPRF);
        }
        if(insertPRF.size() > 0){
            insert insertPRF;
            newPRFid = insertPRF[0].id;

            for(Price_Quote_Line_Item__c  pqli : [SELECT Rep_Price__c, RSM_Price__c, Sales_Price__c,
                                                  Sales_Deal__c, Material_Name__c, List_Price__c, Price_Quote__c,
                                                  CurrencyIsoCode
                                                  FROM Price_Quote_Line_Item__c
                                                  WHERE Price_Quote__c = :ApexPages.currentPage().getParameters().get('pqid')
                                                  ORDER BY Row_Order__c])
            {
                PRF_Line_Item__c addPRFli = new PRF_Line_Item__c(
                    PRF__c = newPRFid,
                    CurrencyIsoCode = pqli.CurrencyIsoCode,
                    List_Price__c = pqli.List_Price__c,
                    Rep_Price__c = pqli.Rep_Price__c,
                    RSM_Price__c = pqli.RSM_Price__c,
                    Current_Price__c = pqli.Sales_Price__c,
                    Sales_Deal__c = pqli.Sales_Deal__c,
                    Material_Name__c = pqli.Material_Name__c
                );
                system.debug('addPRFli: ' + addPRFli);
                insertPRFLI.add(addPRFli);
            }

            if(insertPRFLI.size() > 0){
                insert insertPRFLI;
            }

        }

        PageReference redir = New Pagereference('/apex/PP_PRF?id=' + newPRFid);
        redir.setRedirect(false);
        return redir;
    }
*/
}