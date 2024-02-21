/*********************************************************************
* Description      : Controller Class for Contract Details.
* Test Class       : PP_Contract_Detail_Test
* VisualForce      : PP_Contract_Detail
* Author(s)        : Dun Silver, Eric Clay
**********************************************************************/

public with sharing class PP_Contract_Detail {

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

    Public String todaysdate {get{
        Datetime myDT = Datetime.now();
        todaysdate = myDT.format('ddMMMyyyy');
        return todaysdate;
    } set;}

    public PageReference addQuoteLine() {
        string pqid;
        if(ApexPages.currentPage().getParameters().get('pqid') != NULL){
            pqid = ApexPages.currentPage().getParameters().get('pqid');
        }
        else{
            try{
                pqid = [SELECT Id
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
        //sapPrice.savePriceQuoteItems(pqid, mlist, false, null, null, false);

        return NULL;

    }

    public map<string, string> gethtmlMap(){

        list<Contract_Header__c> chList = new list<Contract_Header__c>();
        list<Contract_Material__c> mmList = new list<Contract_Material__c>();
        String gporef = ApexPages.currentPage().getParameters().get('gporef');
        String oid = ApexPages.currentPage().getParameters().get('oid');
        if(oid != NULL && gporef != NULL){
            chList = [SELECT Description__c, Agreement_Number__c, Valid_To__c, Valid_From__c
                  FROM Contract_Header__c
                  WHERE GPO_Contract_Ref__c = :ApexPages.currentPage().getParameters().get('gporef')
                  AND Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                  AND Active__c = TRUE
                  ORDER BY Description__c];

            mmlist = [SELECT Price__c, Agreement__r.Agreement_Number__c, Product__r.Id, Product__r.name, Valid_From__c, Valid_To__c
                  FROM Contract_Material__c
                  WHERE Agreement__r.GPO_Contract_Ref__c = :ApexPages.currentPage().getParameters().get('gporef')
                  AND Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                  AND Agreement__r.Active__c = TRUE
                  AND Active__c = TRUE
                  ORDER BY Product__r.name];

        }
        else{
            chList = [SELECT Description__c, Agreement_Number__c, Valid_To__c, Valid_From__c
                  FROM Contract_Header__c
                  WHERE Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                  AND Active__c = TRUE
                  ORDER BY Description__c];

            mmlist = [SELECT Price__c, Agreement__r.Agreement_Number__c, Product__r.Id, Product__r.name, Valid_From__c, Valid_To__c
                  FROM Contract_Material__c
                  WHERE Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                  AND Agreement__r.Active__c = TRUE
                  AND Active__c = TRUE
                  ORDER BY Product__r.name];
        }//end if/else
        
        set<Id> pids = new set<Id>();
        for(Contract_Material__c cm : mmlist){
            pids.add(cm.Product__r.Id);
        }
        list<Product2> plist = new list<Product2>();
        plist = [SELECT Name FROM Product2 WHERE Id IN :pids];

        map<string, decimal> matMap = new map<string, decimal>();
        map<string, string> htmlMap = new map<string, string>();
        string htmlstr;

        for(Contract_Material__c cm : mmlist ){
            matMap.put(cm.Agreement__r.Agreement_Number__c + cm.Product__r.name, cm.Price__c);
            //system.debug('matMap: ' + matMap);
        }
        for(Product2 p : plist){
            htmlstr = '';
            for(Contract_Header__c ch : chlist){
                if(matMap.get(ch.Agreement_Number__c + p.Name) == NULL){
                    htmlstr = htmlstr + '<td align="center">0</td>';
                }
                else{
                    htmlstr = htmlstr + '<td align="center">$' + matMap.get(ch.Agreement_Number__c + p.Name) + '</td>';
                }

            }
            htmlMap.put(p.Name, htmlstr);
        }
        system.debug('htmlMap' + htmlMap);
        return htmlMap;

    }

    //get contract materials for NA and EMEA
    public list<Product2> getplist(){
        set<Id> pids = new set<Id>();
        String gporef = ApexPages.currentPage().getParameters().get('gporef');
        String oid = ApexPages.currentPage().getParameters().get('oid');
        if(oid != NULL && gporef != NULL){
            for(Contract_Material__c cm : [SELECT Product__r.Id, Valid_From__c, Valid_To__c
                                       FROM Contract_Material__c
                                       WHERE Agreement__r.GPO_Contract_Ref__c = :ApexPages.currentPage().getParameters().get('gporef')
                                       AND Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                                       AND Agreement__r.Active__c = TRUE
                                       AND Active__c = TRUE
                                       ORDER BY Product__r.name])
            {
                pids.add(cm.Product__r.Id);
            }
        }
        else{
            for(Contract_Material__c cm : [SELECT Product__r.Id, Valid_From__c, Valid_To__c
                                       FROM Contract_Material__c
                                       WHERE Agreement__r.Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                                       AND Agreement__r.Active__c = TRUE
                                       AND Active__c = TRUE
                                       ORDER BY Product__r.name])
            {
                pids.add(cm.Product__r.Id);
            }
        }//end if/else null check

        try{
            return [SELECT Id, Name, Description, Sales_Unit__c, Qty_Sales_Unit__c, CurrencyIsoCode
                FROM Product2
                WHERE Id IN :pids
                ORDER BY Name];
        }
        catch(Exception e){
            system.debug('Exception: ' + e);
            return NULL;
        }
    }//end getplist

    //get contract headers for NA and EMEA
    public list<Contract_Header__c> getcontractHeaders(){
        String gporef = ApexPages.currentPage().getParameters().get('gporef');
        String oid = ApexPages.currentPage().getParameters().get('oid');

        if(oid != NULL && gporef != NULL){
            return [SELECT Description__c, Contract_Detail__c, Agreement_Number__c, Valid_To__c, Valid_From__c
                FROM Contract_Header__c
                WHERE GPO_Contract_Ref__c = :ApexPages.currentPage().getParameters().get('gporef')
                AND Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                AND Active__c = TRUE
                ORDER BY Description__c];
        }
        else{
            return [SELECT Description__c, Contract_Detail__c, Agreement_Number__c, Valid_To__c, Valid_From__c
                FROM Contract_Header__c
                WHERE Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                AND Active__c = TRUE
                ORDER BY Description__c];
        }
    }//end getcontractHeaders

    public boolean getaltui(){
        list<Contract_Header__c> chl = new list<Contract_Header__c>([SELECT ID FROM Contract_Header__c 
                                                                    WHERE Alt_UI__c = TRUE AND GPO_Contract_Ref__c = :ApexPages.currentPage().getParameters().get('gporef') 
                                                                    AND Owner__c = :ApexPages.currentPage().getParameters().get('oid')]);
        if(chl.size() > 0){
            return TRUE;
        }
        else {
            return FALSE;
        }

    }

    public String oid {
        get {
            try {
                return ApexPages.currentPage().getParameters().get('oid');
            }
            catch (Exception e) {
                system.debug('Exception: ' + e);
                return NULL;
            }
        }
        set;
    }

    public String oidname {
        get {
            try {
                return [SELECT Owner_Name__c FROM Contract_Header__c where Owner__c = :ApexPages.currentPage().getParameters().get('oid') LIMIT 1].Owner_Name__c;
            } catch (Exception e) {
                system.debug('Exception: ' + e);
                return NULL;
            }
        }
        set;
    }

    public String gporef {
        get {
            try {
                return ApexPages.currentPage().getParameters().get('gporef');
            } catch (Exception e) {
                system.debug('Exception: ' + e);
                return NULL;
            }
        }
        set;
    }

    public String rxls {
        get {
            string temp_name;
            if(ApexPages.currentPage().getParameters().get('rs') == 'xls'){
                temp_name = [Select Owner_Name__c
                             FROM Contract_Header__c
                             WHERE Owner__c = :ApexPages.currentPage().getParameters().get('oid')
                             AND Active__c = TRUE
                             LIMIT 1].Owner_Name__c;
                temp_name = temp_name.replace(',','');
                temp_name += ' Contract Detail ';
                temp_name += datetime.now().format('MM-dd-yyyy');
                //System.debug('Temp_Name ===================================== ' + temp_name);
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

    @RemoteAction
    @readOnly

    public static list<string> htmlList(string oid, string gporef){
        // This is used for JS Remote and large data queries
        string htmlstr;
        string htmlheader;
        integer lnum = 1;
        list<string> htmlList = new list<string>();
        map<string, decimal> matMap = new map<string, decimal>();

        list<Contract_Header__c> chlist = new list<Contract_Header__c>();
        //Contract Details
        if(oid != NULL && gporef != NULL){
            chlist = [SELECT Agreement_Number__c, Description__c, Contract_Detail__c, Valid_From__c, Valid_To__c
                      FROM Contract_Header__c
                      WHERE GPO_Contract_Ref__c = :gporef AND Owner__c = :oid AND Active__c = TRUE
                      ORDER BY Description__c];
        }
        else{
            chlist = [SELECT Agreement_Number__c, Description__c, Contract_Detail__c, Valid_From__c, Valid_To__c
                      FROM Contract_Header__c
                      WHERE Owner__c = :oid AND Active__c = TRUE
                      ORDER BY Description__c];
        }

        //Agreement Details
        /*if(oid != NULL && gporef == '123'){
            chlist = [SELECT Agreement_Number__c, Description__c, Contract_Detail__c, Valid_From__c, Valid_To__c
                      FROM Contract_Header__c
                      WHERE Agreement_Number__c = :oid AND Active__c = TRUE
                      ORDER BY Description__c];
        }*/

        //system.debug('chlist: ' + chlist);

        //Building the Static Part of the Header

        htmlheader = '<tr><th align="center">#</th><th>Material Name</th>';
        htmlheader += '<th width="300px">Description</th>';
        htmlheader += '<th align="center">SU</th><th align="center">#SU</th>';
        htmlheader += '<th align="center">Valid From - Valid To</th>';
        //<th class="text-center">Quote</th>

        // Build the Contract Header
        for(Contract_Header__c thb : chlist){
            Date vfrom = thb.Valid_From__c;
            String vfromstr = vfrom.format();

            Date vto = thb.Valid_To__c;
            String vtostr = vto.format();

            htmlstr = '<th><center><a href="/apex/PP_Agreement_Detail?aid=' + thb.Agreement_Number__c + '">' + thb.Description__c + '<br/>';
            htmlstr += thb.Agreement_Number__c + '<br/>' + vfromstr + ' to ' + vtostr + '</a><br/><div class="text-wrap">' + thb.Contract_Detail__c + '</div></center></th>';
            htmlheader += htmlstr;
        }
        htmlheader += '</tr>';
        htmlList.add(htmlheader);

        set<Id> pids = new set<Id>();
        Map<String,Contract_Material__c> matKeyDate = new Map<String,Contract_Material__c>();
        //Contract Details
        if(oid != NULL && gporef != NULL){
            for(Contract_Material__c cm : [SELECT Price__c, Agreement__r.Agreement_Number__c, Product__r.Id, Product__r.name, Material_Lookup_Key__c, Valid_From__c, Valid_To__c
                                           FROM Contract_Material__c
                                           WHERE Agreement__r.GPO_Contract_Ref__c = :gporef
                                           AND Agreement__r.Owner__c = :oid
                                           AND Agreement__r.Active__c = TRUE
                                           AND Active__c = TRUE
                                           ORDER BY Product__r.Name])
            {
                pids.add(cm.Product__r.Id);
                matMap.put(cm.Agreement__r.Agreement_Number__c + cm.Product__r.Name, cm.Price__c);
                matKeyDate.put(cm.Material_Lookup_Key__c,cm);
                //system.debug('matMap: ' + matMap);
            }
        }
        else{
            for(Contract_Material__c cm : [SELECT Price__c, Agreement__r.Agreement_Number__c, Product__r.Id, Product__r.name, Material_Lookup_Key__c, Valid_From__c, Valid_To__c
                                           FROM Contract_Material__c
                                           WHERE Agreement__r.Owner__c = :oid
                                           AND Agreement__r.Active__c = TRUE
                                           AND Active__c = TRUE
                                           ORDER BY Product__r.Name])
            {
                pids.add(cm.Product__r.Id);
                matMap.put(cm.Agreement__r.Agreement_Number__c + cm.Product__r.Name, cm.Price__c);
                matKeyDate.put(cm.Material_Lookup_Key__c,cm);
                //system.debug('matMap: ' + matMap);
            }
        }

        for(Product2 p : [SELECT Id, Name, Description, Sales_Unit__c, Qty_Sales_Unit__c, Material_Key__c FROM Product2 WHERE Id IN :pids]){
            //below handles date converstion to string
            Date vfrom = matKeyDate.get(p.Material_Key__c).Valid_From__c;
            Date vto = matKeyDate.get(p.Material_Key__c).Valid_To__c;
            String vfromstr = vfrom.format();
            String vtostr = vto.format();

            htmlstr = '<tr><td>' + lnum + '</td><td><a href="/apex/PP_Material_Info?pid=' + p.Name + '">' + p.Name + '</a></td>';
            htmlstr += '<td><a href="/apex/PP_Material_Info?id=' + p.Id + '">' + p.Description + '</a></td>';
            htmlstr += '<td>' + p.Sales_Unit__c + '</td><td>' + p.Qty_Sales_Unit__c + '</td>';
            htmlstr += '<td>' + vfromstr + '-' + vtostr + '</td>';
            //<td><a href="" class="btn btn-primary btn-xs">Add</a></td>
            //
            for(Contract_Header__c ch : chlist){
                if(matMap.get(ch.Agreement_Number__c + p.Name) == NULL){
                    htmlstr += '<td align="center">0</td>';
                }
                else{
                    htmlstr += '<td align="center">$' + matMap.get(ch.Agreement_Number__c + p.Name) + '</td>';
                }

            }
            htmlstr += '</tr>';
            htmlList.add(htmlstr);
            lnum++;
        }
        //system.debug('htmlList' + htmlList);

        return htmlList;

    }

    public Id getbigreport(){
        try{
            return [SELECT Id FROM Report WHERE Name = 'Contract Detail Export Report' LIMIT 1].id;
        }
        catch(Exception e){
            return NULL;
        }

    }


}