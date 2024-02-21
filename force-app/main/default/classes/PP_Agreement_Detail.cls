/*********************************************************************
* Description      : Test coverage for demoAssigned VPS process.
* Test Class       : PP_Agreement_Detail_Test
* VisualForce      : PP_Agreement_Detail
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/
public with sharing class PP_Agreement_Detail {
    String lastId;

    public String pqId {get{
        if(ApexPages.currentPage().getParameters().get('pqid') != NULL){
            return ApexPages.currentPage().getParameters().get('pqid');
        }
        else{
            try{
                return [SELECT Id
                        FROM Price_Quote__c
                        WHERE LastViewedDate != NULL
                        ORDER BY LastViewedDate DESC limit 1].Id;
            }
            catch(Exception e){
                system.debug('Catch Exception: ' + e);
                return NULL;
            }
        }
    } set;}

    //get user language
    public String userLang{get{
        return UserInfo.getLanguage();
    }set;}
    
    public PP_Agreement_Detail() {
        String activeQuoteIdStr = '';
        List<User> userList = [Select id, Active_Quote_Id__c from User Where Id=: UserInfo.getUserId()];
        if(userList.size() > 0) {
            activeQuoteIdStr = userList[0].Active_Quote_Id__c;
        }
        pqId = activeQuoteIdStr;
    }

    public Contract_Header__c getad(){
        try {
            return [SELECT Name, Owner_Name__c, Description__c, Agreement_Number__c,
                    GPO_Contract_Ref__c, Valid_To__c, Valid_From__c,Owner__c,
                    Contract_Detail__c, Account_Count__c, Material_Count__c, Objective_Name__c 
                    FROM Contract_Header__c
                    WHERE Agreement_Number__c = :ApexPages.currentPage().getParameters().get('aid')];
        } catch (Exception e) {
            return NULL;
        }
    }
public PRF__c getPRF(){
        try {
            return [SELECT Name, Sales_Deal__c, Owner.Name
                    FROM PRF__c
                    WHERE Sales_Deal__c = :ApexPages.currentPage().getParameters().get('aid') Limit 1];
        } catch (Exception e) {
            return NULL;
        }
    }
    public list<Contract_Material__c> getplist(){
        try{
            List<Contract_Material__c> plist = [SELECT Price__c, Product__r.Id, Product__r.Name, Product__r.Description,
                    Product__r.Sales_Unit__c, Product__r.Qty_Sales_Unit__c, CurrencyIsoCode, Valid_From__c, Valid_To__c
                    FROM Contract_Material__c
                    WHERE Agreement__r.Name = :ApexPages.currentPage().getParameters().get('aid')
                    AND Agreement__r.Active__c = TRUE
                    AND Active__c = TRUE
                    ORDER BY Product__r.name
                   	LIMIT 10000];
            
            lastId = plist[plist.size()-1].Product__r.name;
            //system.debug('*** accList.size() *** ' + accList.size() );
            //system.debug('*** lastId *** ' + lastId);
            return plist;
        }
        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }

	public list<Contract_Material__c> getplist2(){
        try{
            return [SELECT Price__c, Product__r.Id, Product__r.Name, Product__r.Description,
                    Product__r.Sales_Unit__c, Product__r.Qty_Sales_Unit__c, CurrencyIsoCode
                    FROM Contract_Material__c
                    WHERE Agreement__r.Name = :ApexPages.currentPage().getParameters().get('aid')
                    AND Agreement__r.Active__c = TRUE
                    AND Active__c = TRUE
                    AND Product__r.name > :lastId
                    ORDER BY Product__r.name
                   	LIMIT 10000];
        }
        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }

    public Id getbigreport(){
        try {
            return [SELECT Id FROM Report WHERE Name = 'Agreement Detail Export Report' LIMIT 1].id;
        }
        catch (Exception e){
            return NULL;
        }
    }

    public boolean getaltui(){
        list<Contract_Header__c> chl = new list<Contract_Header__c>();
        try {
            chl = [SELECT ID FROM Contract_Header__c WHERE Alt_UI__c = TRUE AND Agreement_Number__c = :ApexPages.currentPage().getParameters().get('aid')];
        }
        catch(Exception e){
            system.debug('Exceptions' + e);
        }

        if(chl.size() > 0){
            return TRUE;
        }
        else {
            return FALSE;
        }
    }

    public String filename {
        get {
            String temp_name = [Select Agreement_Number__c FROM Contract_Header__c WHERE Agreement_Number__c = :ApexPages.currentPage().getParameters().get('aid') LIMIT 1].Agreement_Number__c;
            temp_name = temp_name.replace(',','');
            temp_name += ' Contract Detail ';
            temp_name += datetime.now().format('MM-dd-yyyy');
            System.debug('Temp_Name ===================================== ' + temp_name);
            return temp_name;
        }
        set; }

    public String rxls {
        get {
            string temp_name;
            if(ApexPages.currentPage().getParameters().get('rs') == 'xls'){
                temp_name = [Select Agreement_Number__c FROM Contract_Header__c WHERE Agreement_Number__c = :ApexPages.currentPage().getParameters().get('aid') LIMIT 1].Agreement_Number__c;
                temp_name = temp_name.replace(',','');
                temp_name += ' Agreement Detail ';
                temp_name += datetime.now().format('MM-dd-yyyy');
                temp_name += 'application/vnd.ms-excel#' + temp_name + '.xls';
            }
            return temp_name;
        }
        set; }

    public String rpdf {
        get {
            string temp_name;
            if(ApexPages.currentPage().getParameters().get('rs') == 'pdf'){
                temp_name = 'PDF';
            }
            return temp_name;
        }
        set; }

    public String aid {
        get {
            string agreement;
            if(ApexPages.currentPage().getParameters().get('aid') != NULL){
                agreement = ApexPages.currentPage().getParameters().get('aid');
            }
            return agreement;
        }
        set;
    }

    public PageReference addQuoteLine() {
        string pqid;
        if(ApexPages.currentPage().getParameters().get('pqid') != NULL){
            pqid = ApexPages.currentPage().getParameters().get('pqid');
        }
        else{
            try{
                pqid = [SELECT Id, Status__c
                        FROM Price_Quote__c
                        WHERE LastViewedDate != NULL
                        ORDER BY LastViewedDate DESC limit 1].Id;
            }
            catch(Exception e){
                system.debug('Catch Exception: ' + e);
            }
        }


        list<String> mlist = new list<String>();
        mlist.add(ApexPages.currentPage().getParameters().get('materialId'));

        PP_SAP_Price sapPrice = new PP_SAP_Price();
        sapPrice.getSAPprice(mlist,NULL,NULL,pqid);

        return NULL;

    }

    @RemoteAction
    @readOnly

    public static list<string> htmlList(string aid){

        string htmlstr;
        string htmlheader;
        integer lnum = 1;
        list<string> htmlList = new list<string>();

        //Building the Static Part of the Header
        //Below string values are used to get API field labels for translations for EMEA
        String prodNameLabel;
        String prodDescLabel;
        String valFromLabel;
        String valToLabel;
        String suLabel;
        String qtySuLabel;
        String currSuLabel;
        //Below is to get the api labels for each field that is being injecting into the VF page via javascript
        //get api label for prodNameLabel
        Schema.DescribeFieldResult fieldResult1 = Product2.Name.getDescribe();
        prodNameLabel = fieldResult1.getLabel();
        //Get api label for prodDescLabel
        Schema.DescribeFieldResult fieldResult2 = Product2.Description.getDescribe();
        prodDescLabel = fieldResult2.getLabel();
        //Get api label for valFromLabel
        Schema.DescribeFieldResult fieldResult3 = Contract_Material__c.Valid_From__c.getDescribe();
        valFromLabel = fieldResult3.getLabel();
        //Get api label for valToLabel
        Schema.DescribeFieldResult fieldResult4 = Contract_Material__c.Valid_To__c.getDescribe();
        valToLabel = fieldResult4.getLabel();
        //Get api label for suLabel
        Schema.DescribeFieldResult fieldResult5 = Product2.Sales_Unit__c.getDescribe();
        suLabel = fieldResult5.getLabel();
        //Get api label for qtySuLabel
        Schema.DescribeFieldResult fieldResult6 = Product2.Qty_Sales_Unit__c.getDescribe();
        qtySuLabel = fieldResult6.getLabel();
        
        htmlheader = '<tr><th align="center">#</th><th>'+prodNameLabel+'</th>'; //{!$ObjectType.Contract_Header__c.fields.Owner__c.label}
        htmlheader += '<th width="300px">'+prodDescLabel+'</th>';
        htmlheader += '<th>'+valFromLabel+'</th><th>'+valToLabel+'</th>';
        htmlheader += '<th align="center">'+suLabel+'</th><th align="center">#'+qtySuLabel+'</th>';
        htmlheader += '<th >Currency</th>';

        // Build the Contract Header
        for(Contract_Header__c thb : [SELECT Agreement_Number__c, Description__c, Contract_Detail__c,
                                      Valid_From__c, Valid_To__c, Objective_Name__c
                                      FROM Contract_Header__c
                                      WHERE Agreement_Number__c = :aid
                                      ORDER BY Description__c])
        {
            Date vfrom = thb.Valid_From__c;
            String vfromstr = vfrom.format();

            Date vto = thb.Valid_To__c;
            String vtostr = vto.format();
            
            if(thb.Contract_Detail__c == NULL){
                thb.Contract_Detail__c = '';
            }

            htmlstr = '<th><center><a href="/apex/PP_Agreement_Detail?aid=' + thb.Agreement_Number__c + '">' + thb.Description__c + '<br/>';
            htmlstr += thb.Agreement_Number__c + '<br/>' + vfromstr + ' to ' + vtostr + '</a><br/><div class="text-wrap">' + thb.Contract_Detail__c + '</div></center></th>';
            htmlheader += htmlstr;
        }
        htmlheader += '</tr>';
        htmlList.add(htmlheader);

        for(Contract_Material__c p : [SELECT Price__c, Product__r.Id, Product__r.name, Product__r.Description,
                                      Product__r.Sales_Unit__c, Product__r.Qty_Sales_Unit__c,
                                      Valid_From__c, Valid_To__c, Product__r.CurrencyIsoCode
                                      FROM Contract_Material__c
                                      WHERE Agreement_Number__c = :aid
                                      AND Agreement__r.Active__c = TRUE
                                      AND Active__c = TRUE
                                      ORDER BY Product__r.Name])
        { 
            Date vfrom = p.Valid_From__c;
            String vfromstr = vfrom.format();

            Date vto = p.Valid_To__c;
            String vtostr = vto.format();
            //Name=TestId, Product__c=01t56000000RdCoAAK,
            //Agreement__c=a0W56000000GYT7EAO, Sales_Org__c=US10, Id=a0Z56000000Zl1WEAS
            htmlstr = '<tr><td>' + lnum + '</td><td><a href="/apex/PP_Material_Info?id=' + p.Product__r.Id + '">' + p.Product__r.Name + '</a></td>';
            htmlstr += '<td><a href="/apex/PP_Material_Info?id=' + p.Product__r.Id + '">' + p.Product__r.Description + '</a></td>';
            htmlstr += '<td>' + vfromstr + '</td><td>' + vtostr + '</td>';
            htmlstr += '<td>' + p.Product__r.Sales_Unit__c + '</td><td>' + p.Product__r.Qty_Sales_Unit__c + '</td>';
            htmlstr += '<td>' + p.Product__r.CurrencyIsoCode + '</td>';
            htmlstr += '<td align="center">' + p.Price__c + '</td></tr>';
            htmlList.add(htmlstr);
            lnum++;
        }
        //system.debug('htmlList' + htmlList);

        return htmlList;
    }

}