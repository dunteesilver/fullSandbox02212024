/*********************************************************************
* Description     : Invoiced_Sales_Helper_Class
* Test Classes    : Invoiced_Global_Test_Class, Invoiced_Sales_Tracking_Class_Test
* Author(s)       : Dunte'e Silver
**********************************************************************/
public class Invoiced_Sales_Helper_Class {
    
    public static void addShipping(List<Invoiced_Sales_Detail__c> newTrigger){
        System.debug('*** Starting addShipping in Invoiced_Sales_Helper_Class ***');
        set<String> sKey = new set<String>();
        map<String, list<Invoiced_Sales_Tracking__c>> stMap = new map<String, list<Invoiced_Sales_Tracking__c>>();
        
        for(Invoiced_Sales_Detail__c isd : newTrigger){
            if(isd.Sales_Order_Key__c != NULL){
                sKey.add(isd.Sales_Order_Key__c);
            }
        }//end for loop
        
        if(sKey.size() > 0){
            string stURL;
            string stAddTracking;
            string stCarrier;
            string stNumbers;
            for(Invoiced_Sales_Tracking__c ist : [SELECT Sales_Order_Key__c, Tracking_Number__c, Delivery_Priority__c,
                                                  Ship_Date__c
                                                  FROM Invoiced_Sales_Tracking__c
                                                  WHERE Sales_Order_Key__c = :sKey
                                                  AND Tracking_Number__c != NULL])
            {
                if(stMap.containsKey(ist.Sales_Order_Key__c)){
                    stMap.get(ist.Sales_Order_Key__c).add(ist);
                }
                else{
                    stMap.put(ist.Sales_Order_Key__c, new list<Invoiced_Sales_Tracking__c>{ist});
                }
            }//end for loop ist
            
            if(stMap.size() > 0){
                for(Invoiced_Sales_Detail__c isd : newTrigger){
                    if(isd.Sales_Order_Key__c != NULL && stMap.containsKey(isd.Sales_Order_Key__c)){
                        stURL = NULL;
                        stCarrier = NULL;
                        stNumbers = NULL;
                        stAddTracking = NULL;
                        isd.Shipping_Tracking_Number_Count__c = stMap.get(isd.Sales_Order_Key__c).size();
                        for(Invoiced_Sales_Tracking__c ist : stMap.get(isd.Sales_Order_Key__c)){
                            if(ist.Delivery_Priority__c != NULL){
                                stCarrier = ist.Delivery_Priority__c;
                                stCarrier = stCarrier.left(3);
                            }//end if Delivery Priority
                            if(
                                stCarrier != NULL &&
                                ist.Tracking_Number__c != NULL &&
                                (
                                    stNumbers == NULL ||
                                    stNumbers.contains(ist.Tracking_Number__c) == FALSE
                                )
                            ){
                                if(stCarrier == 'UPS'){
                                    if(stURL == NULL){
                                        stURL = 'https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=' + ist.Tracking_Number__c;
                                    }
                                    else if(stURL.contains(ist.Tracking_Number__c) == FALSE){
                                        stAddTracking = ist.Tracking_Number__c;
                                        if(stAddTracking.length() + stURL.length() < 255){
                                            stURL = stURL + '%0D' + ist.Tracking_Number__c;
                                        }
                                    }
                                }
                                else if(stCarrier == 'Fed'){
                                    stCarrier = 'FedEx';
                                    if(stURL == NULL){
                                        stURL = 'https://www.fedex.com/apps/fedextrack/?action=track&cntry_code=us&trackingnumber=' + ist.Tracking_Number__c;
                                    }
                                    else if(stURL.contains(ist.Tracking_Number__c) == FALSE){
                                        stAddTracking = ist.Tracking_Number__c;
                                        if(stAddTracking.length() + stURL.length() < 255){
                                            stURL = stURL + ',' + ist.Tracking_Number__c;
                                        }
                                        
                                    }
                                }
                                else if(stCarrier == 'Pur'){
                                    stCarrier = 'Purolator';
                                    if(stURL == NULL){
                                        stURL = 'https://www.purolator.com/purolator/ship-track/tracking-summary.page?pin=' + ist.Tracking_Number__c;
                                    }
                                    else if(stURL.contains(ist.Tracking_Number__c) == FALSE){
                                        stAddTracking = ist.Tracking_Number__c;
                                        if(stAddTracking.length() + stURL.length() < 255){
                                            stURL = stURL + ',' + ist.Tracking_Number__c;
                                        }
                                        
                                    }
                                }
                                else if(stCarrier == 'YRC'){
                                    stCarrier = 'YRC Freight';
                                    if(stURL == NULL){
                                        stURL = 'https://my.yrc.com/tools/track/shipments?referenceNumber=' + ist.Tracking_Number__c;
                                    }
                                    else if(stURL.contains(ist.Tracking_Number__c) == FALSE){
                                        stAddTracking = ist.Tracking_Number__c;
                                        if(stAddTracking.length() + stURL.length() < 255){
                                            stURL = stURL + ',' + ist.Tracking_Number__c;
                                        }
                                        
                                    }
                                }//end else if YRC
                                else if(stCarrier == 'AAA'){
                                    stCarrier = 'AAA Cooper';
                                }
                                else if(stCarrier == 'Air'){
                                    stCarrier = 'Air Freight';
                                }
                                else if(stCarrier == 'Roa'){
                                    //http://tools.rrts.com/LTLTrack/?searchValues=416269601
                                    stCarrier = 'Road Runner';
                                    if(stURL == NULL){
                                        stURL = 'https://my.yrc.com/tools/track/shipments?referenceNumber=' + ist.Tracking_Number__c;
                                    }
                                    else{
                                        stAddTracking = ist.Tracking_Number__c;
                                        if(stAddTracking.length() + stURL.length() < 255){
                                            stURL = stURL + ',' + ist.Tracking_Number__c;
                                        }
                                    }
                                    
                                    
                                }//end else if Roa
                                else if(stCarrier == 'Sea'){
                                    stCarrier = 'Sea Freight';
                                }
                                else if(stCarrier == 'Old'){
                                    stCarrier = 'Old Dominion';
                                }
                                else if(stCarrier == 'Hol'){
                                    stCarrier = 'Holland';
                                }
                                
                                if(stNumbers == NULL){
                                    stNumbers = ist.Tracking_Number__c;
                                }
                                else{
                                    stNumbers = stNumbers + ', ' + ist.Tracking_Number__c;
                                }
                                
                                isd.Shipping_Date__c = ist.Ship_Date__c;
                                isd.Shipping_Carrier__c = stCarrier;
                                isd.Shipping_Priority__c = ist.Delivery_Priority__c;
                            }//end if stCarrier != NULL && ist.Tracking_Number__c != NULL
                            
                        }//end for Invoiced_Sales_Tracking__c ist : stMap.get(isd.Sales_Order_Key__c)
                        
                        if(stURL != NULL){
                            stURL = stURL.left(255);
                            isd.Shipping_Tracking__c = stURL;
                        }
                        if(stNumbers != NULL){
                            isd.Shipping_Tracking_Numbers__c = stNumbers;
                        }
                        
                    }//end if isd.Sales_Order_Key__c != NULL && stMap.containsKey(isd.Sales_Order_Key__c)
                    else{
                        isd.Shipping_Tracking_Numbers__c = NULL;
                        isd.Shipping_Tracking__c = NULL;
                        isd.Shipping_Carrier__c = NULL;
                        isd.Shipping_Date__c = NULL;
                        isd.Shipping_Tracking_Number_Count__c = 0;
                        isd.Shipping_Priority__c = NULL;
                    }//end else
                }//end for loop Invoiced_Sales_Detail__c isd : newTrigger
                
            }//end stMap.size()
            
        }//end if sKey size
        
    }//end of method
    
    
    public string getMaintenanceKey(string obj){
        System.debug('*** Starting getMaintenanceKey in Invoiced_Sales_Helper_Class ***');
        // New Class Logic 20Nov2017 - ESC
        string setQuery = 'SELECT Maintenance_Key__c FROM ' + obj + ' ORDER BY CreatedDate DESC LIMIT 1';
        string mKey;
        for(sObject s : database.query(setQuery)){
            mKey = (String) s.get('Maintenance_Key__c');
        }
        return mKey;
    }
    
    /* Not Used
public boolean checkMaintenance(string obj, string mkey){
boolean checksOk = FALSE;
string setQuery = 'SELECT COUNT() FROM ' + obj + ' WHERE Maintenance_Key__c = \'' + mkey + '\' LIMIT 40000';
integer keyCount = 0;
keyCount = database.countQuery(setQuery);
if(keyCount > 0 && keyCount < 40000){
checksOk = TRUE;
}
//string setQuery = 'SELECT Maintenance_Key__c FROM ' + obj + ' ORDER BY CreatedDate DESC LIMIT 1';

return checksOk;
} */
    
    /*
public list<String> getEmailList(string obj){
list<String> emailList = new list<String>();
for(SObject mea : Maintenance_Email_Addresses__c.getall().values()){
if((Boolean) mea.get(obj) == TRUE){
emailList.add((String) mea.get('Email__c'));
if((String) mea.get('SMS_Notification__c') != NULL){
emailList.add((String) mea.get('SMS_Notification__c'));
system.debug('SMS Email Added: ' + (String) mea.get('SMS_Notification__c'));
}
system.debug('Email Added: ' + (String) mea.get('Email__c'));
}
}
return emailList;
}*/
    
    public static string randomKey(){
        System.debug('*** Starting randomKey in Invoiced_Sales_Helper_Class ***');
        Blob blobKey = crypto.generateAesKey(128);
        //String key = EncodingUtil.convertToHex(blobKey);
        return EncodingUtil.convertToHex(blobKey);
    }
    
    
    /* Enable 'removeJobs' when refreshing sandboxes and run the following command in anonymous console:
* Invoiced_Sales_Helper_Class isKill = new Invoiced_Sales_Helper_Class();
* isKill.removeJobs();
*
* Each time it runs it will delete 100 subscribed reports - Run it until there are zero. You can increase the limit but it can fail so buyer beware. - ESC
*/
    
    /*
public void removeJobs(){

//Invoiced_Sales_Helper_Class isKill = new Invoiced_Sales_Helper_Class();
//isKill.removeJobs();
//for(CronTrigger c : [SELECT Id FROM CronTrigger LIMIT 100]) System.abortJob(c.Id);
set<Id> cDetails = new set<Id>();
list<CronTrigger> cRemove = new list<CronTrigger>();
for(CronJobDetail cjd : [SELECT Id FROM CronJobDetail WHERE JobType = 'A' LIMIT 100]){
cDetails.add(cjd.Id);
}
for(CronTrigger c : [SELECT Id
FROM CronTrigger
WHERE CronJobDetailId = :cDetails])
{
System.abortJob(c.Id);

}

}*/
    
    /*
// Maintenance Class - Determines if maintenance should be run on the object passed using the custom class to determine the limit.
public string getMaintenanceCheck(string obj, string key){
// Created: 20Aug2018 - ESC
string sizeCheck;
string mLimitString;
integer mLimit;

Map<String,Maintenance_Objects__c> moMap = Maintenance_Objects__c.getAll();

// Set the limit from the Custom Setting
if(moMap.get(obj).Limit__c != NULL){
mLimit = integer.valueOf(moMap.get(obj).Limit__c);
mLimitString = String.valueOf(mLimit);
}
else{
mLimit = 0;
mLimitString = '0';
}

// Pull the count from the object
string setQuery = 'SELECT count() FROM ' + obj + ' WHERE Maintenance_Key__c != \'' + key + '\' LIMIT ' + mLimit;
system.debug('setQuery: ' + setQuery);

// Check the count
integer dbcount = database.countQuery(setQuery);
system.debug('dbcount: ' + dbcount);

// Determine if maintenance can proceed
if(dbcount == 0){
sizeCheck = 'Database Maintenance: 0 Records to Purge. This is ok for Invoiced Sales Detail - all other objects start troubleshooting why.';
}
else if(dbcount >= mLimit){
sizeCheck = 'Database Maintenance: ' + mLimit + ' - Set Object Limit Hit. Run the maintenance report and then check timing, that the upload is not still running, or that the files generated completely (disk space).';
}
else{
sizeCheck = 'Ready';
}
system.debug('sizeCheck: ' + sizeCheck);
return sizeCheck;
}

public void sendEmailHelper(string emailSubj, string emailBody, list<String> emailList){
Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
newEmail.setToAddresses(emailList);
newEmail.setSubject(emailSubj);
newEmail.setPlainTextBody(emailBody);
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { newEmail });
}*/
    
    
    public static void currencyReset(List<SObject> newTrigger){
        System.debug('*** Starting currencyReset in Invoiced_Sales_Helper_Class ***');
        // Wave/EA will convert all currency not USD to USD.
        // This Class flips the currency from anything not USD...to USD
        // and makes a backup to the Original Currency field. -- March 2017 ESC
        
        string cISO;
        for(SObject i : newTrigger){
            // Currency Test
            cISO = (String) i.get('CurrencyIsoCode');
            if(cISO == 'CAD'){
                i.put('Original_Currency__c', cISO);
                i.put('CurrencyIsoCode', 'USD');
            }
            else if(cISO == 'AUD'){
                i.put('Original_Currency__c', cISO);
                i.put('CurrencyIsoCode', 'USD');
            }
            else if(cISO == 'NZD'){
                i.put('Original_Currency__c', cISO);
                i.put('CurrencyIsoCode', 'USD');
            }
        }
    }
    
    public static void checkProduct(List<SObject> newTrigger){
        System.debug('*** Starting checkProduct in Invoiced_Sales_Helper_Class ***');
        // This Class creates the product if it doesn't already exist. -- June 2017 - ESC
        string pkey;
        Id prod;
        map<String, Boolean> pkCheck = new map<String, Boolean>();
        list<Product2> newProducts = new list<Product2>();
        
        for(SObject i : newTrigger){
            // Product Test
            pkey = (String) i.get('Material_Key__c');
            prod = (Id) i.get('Product__c');
            System.debug('*** pkey *** ' + pkey);
            System.debug('*** prod *** ' + prod);
            if(pkey != NULL && prod == NULL){
                if(!pkCheck.containsKey(pkey)){
                    pkCheck.put(pkey, TRUE);
                    Product2 newPRec = new Product2(
                        Name = String.valueOf(i.get('Material_Name__c')),
                        Material_Key__c = pkey = String.valueOf(i.get('Material_Key__c')),
                        Sales_Org__c = String.valueOf(i.get('Sales_Org__c')),
                        Distribution_Channel__c = String.valueOf(i.get('Distribution_Channel__c')),
                        Product_Class__c = String.valueOf(i.get('Product_Class__c')),
                        Product_Group__c = String.valueOf(i.get('Product_Group__c')),
                        Product_Sub_Group__c = String.valueOf(i.get('Product_Sub_Group__c')),
                        Product_Line__c = String.valueOf(i.get('Product_Line__c')),
                        CurrencyIsoCode = String.valueOf(i.get('CurrencyIsoCode'))
                    );
                    newProducts.add(newPRec);
                }
            }
        }
        if(newProducts.size() > 0){
            System.debug('*** newProducts *** ' + newProducts);
            insert newProducts;
        }
    }
    
    public static void updateBusinessDay(List<SObject> newTrigger){
        System.debug('*** Starting updateBusinessDay in Invoiced_Sales_Helper_Class ***');
        Id bdId;
        Id compareId;
        try{
            bdId = [SELECT ID FROM Business_Days__c WHERE Date__c = TODAY LIMIT 1].Id;
        }
        catch (Exception e){
            
        }
        
        if(bdId != NULL){
            for(SObject i : newTrigger){
                compareId = (Id) i.get('Business_Days__c');
                if(compareId != bdId){
                    i.put('Business_Days__c', bdId);
                }
            }
        }
    }
    
    public static void updateDayNumber(List<SObject> newTrigger, String type){
        System.debug('*** Starting updateDayNumber in Invoiced_Sales_Helper_Class ***');
        // This is used to do accurate to the day YOY comparisons - ESC
        set<Date> dateSet = new set<Date>();
        set<Date> fiscaldateSet = new set<Date>();
        list<SObject> sList = new list<SObject>();
        for(SObject i : newTrigger){
            if(type == 'Invoiced_Sales_Detail__c' && (Decimal) i.get('Fiscal_Day_Number__c') == NULL){
                dateSet.add((Date) i.get('Commissionable_Date__c'));
                sList.add(i);
            }
            else if(type == 'Invoiced_Sales__c' && (Decimal) i.get('Fiscal_Day_Total__c') == NULL){
                fiscaldateSet.add((Date) i.get('Date__c'));
                sList.add(i);
            }
        }//end for loop
        
        map<Date, Decimal> dayMap = new map<Date, Decimal>();
        for(Business_Days__c b : [SELECT Date__c, Days_In__c
                                  FROM Business_Days__c
                                  WHERE Date__c = :dateSet])
        {
            dayMap.put(b.Date__c, b.Days_In__c);
        }//end for loop
        
        map<Date, Decimal> maxDayMap = new map<Date, Decimal>();
        for(AggregateResult ar : [SELECT Date_Key__c, MAX(Days_In__c) Max_Days
                                  FROM Business_Days__c
                                  WHERE Date_Key__c = :fiscaldateSet
                                  GROUP BY Date_Key__c])
        {
            maxDayMap.put((Date) ar.get('Date_Key__c'), (Decimal) ar.get('Max_Days'));
        }//end for loop
        
        
        //Fiscal_Day_Number__c
        if(sList.size() > 0){
            for(SObject i : sList){
                if(
                    type == 'Invoiced_Sales_Detail__c'
                    && (Decimal) i.get('Fiscal_Day_Number__c') == NULL
                    && dayMap.containsKey((Date) i.get('Commissionable_Date__c'))
                ){
                    i.put('Fiscal_Day_Number__c', dayMap.get((Date) i.get('Commissionable_Date__c')));
                }
                else if(
                    type == 'Invoiced_Sales__c'
                    && (Decimal) i.get('Fiscal_Day_Total__c') == NULL
                    && maxDayMap.containsKey((Date) i.get('Date__c'))
                    
                ){
                    i.put('Fiscal_Day_Total__c', maxDayMap.get((Date) i.get('Date__c')));
                }
            }//end for loop
        }//end if
    }//end method
    
    public static void newProductTracking(List<SObject> newTrigger){
        System.debug('*** Starting newProductTracking in Invoiced_Sales_Helper_Class ***');
        string nptKey;
        string bu;
        string npt;
        set<String> nptFilter = new set<String>();
        map<String, Id> nptMap = new map<String, Id>();
        
        
        for(SObject i : newTrigger){
            // New Product Tracking
            bu = (String) i.get('Business_Unit__c');
            //npt = (Id) i.get('New_Product_Tracking__c');
            if(bu != NULL){
                if(bu.left(8) == 'Surgical'){ // Hack for the Surgical BU names
                    bu = 'Surgical';
                }
                nptKey = (String) i.get('Material_Name__c');
                nptKey = bu + '-' + nptKey;
                nptKey = nptKey.toUpperCase();
                nptFilter.add(nptKey);
            }
        }
        
        if(nptFilter.size() > 0){
            for(New_Product_Tracking_Rule__c r : [SELECT New_Product_Tracking__c, Key__c
                                                  FROM New_Product_Tracking_Rule__c
                                                  WHERE Key__c =:nptFilter
                                                  AND New_Product_Tracking__r.Active__c = TRUE
                                                  AND Active__c = TRUE
                                                  AND IsProductSales__c = TRUE])
            {
                nptKey = r.Key__c;
                nptKey = nptKey.toUpperCase();
                system.debug('nptKey: ' + nptKey);
                nptMap.put(nptKey, r.New_Product_Tracking__c);
            }
        }
        
        for(SObject i : newTrigger){
            // New Product Tracking
            npt = (String) i.get('New_Product_Tracking__c');
            bu = (String) i.get('Business_Unit__c');
            if(bu != NULL){
                if(bu.left(8) == 'Surgical'){ // Hack for the Surgical BU names
                    bu = 'Surgical';
                }
                nptKey = (String) i.get('Material_Name__c');
                nptKey = bu + '-' + nptKey;
                nptKey = nptKey.toUpperCase();
                if(nptMap.containsKey(nptKey)){
                    i.put('New_Product_Tracking__c', nptMap.get(nptKey));
                }
                else if(npt != NULL){
                    i.put('New_Product_Tracking__c', NULL);
                }
            }
        }
    }
    
    public static void addLookups(List<SObject> newTrigger, String type){
        System.debug('*** Starting addLookups in Invoiced_Sales_Helper_Class ***');
        System.debug('*** newTrigger *** ' + newTrigger);
        System.debug('*** type *** ' + type);
        Id acct;
        Id prod;
        Id tid;
        
        String pkey;
        String sap;
        string Sales_Deal;
        
        set<String> acctSet = new set<String>();
        set<String> cset = new set<String>();
        set<String> prodSet = new set<String>();
        set<Id> tSet = new set<Id>();
        
        //map<String, Id> acctMap = new map<String, Id>();
        map<String, Id> cMap = new map<String, Id>();
        map<String, Id> prodMap = new map<String, Id>();
        map<Id, Territory_Master__c> tMap = new map<Id, Territory_Master__c>();
        
        // New 11Sept2017 - ESC - Adding KAM Support
        boolean checkKAM = FALSE;
        set<String> altacctSet = new set<String>();
        map<String, Territory_Master__c> kamTerrMap = new map<String, Territory_Master__c>();
        map<String, Territory_Master__c> kamAcctMap = new map<String, Territory_Master__c>();
        // New 04Oct2017 - ESC - Adding DNA Support
        map<String, Territory_Master__c> dnaAcctMap = new map<String, Territory_Master__c>();
        // New 16Oct2017 - ESC - Adding IDN Support, Optimized If Statements to not check for as many NULL's
        map<String, Account> aMap = new map<String, Account>();
        
        // New 02Feb2018 - ESC - Adding Fiscal Date Support for Invoiced Sales
        set<Date> fDateSet = new set<Date>();
        map<Date, Date> fDateMap = new map<Date, Date>();
        
        // New 24Aug2018 - ESC - Adding ASR Support
        map<String, Territory_Master__c> asrAcctMap = new map<String, Territory_Master__c>();
        
        for(SObject i : newTrigger){
            // Contract Header Check
            Sales_Deal = (String) i.get('Sales_Deal__c');
            if(Sales_Deal != '#' && Sales_Deal != NULL){
                cset.add(Sales_Deal);
            }
            
            // Account Lookup Check
            sap = (String) i.get('SAP_Code__c');
            acct = (Id) i.get('Account__c');
            if(sap != NULL){
                acctSet.add(sap);
            }
            altacctSet.add(sap); // KAM and DNA Support...and now ASR Support
            
            // Parent Account Lookup
            if((String) i.get('Parent_SAP_Code__c') != NULL){
                acctSet.add((String) i.get('Parent_SAP_Code__c'));
            }
            //system.debug('Echo!' + i.getSObjectType());
            
            // Product Lookup Check
            pkey = (String) i.get('Material_Key__c');
            prod = (Id) i.get('Product__c');
            if(pkey != NULL && prod == NULL){
                prodSet.add(pkey);
            }
            
            // BU and Comp Profile
            //tid = (Id) i.get('Territory__c');
            System.debug('*** (Id) i.get(Territory__c) *** ' + (Id) i.get('Territory__c') );
            if((Id) i.get('Territory__c') != NULL){
                tSet.add((Id) i.get('Territory__c'));
            }
            if(type == 'Invoiced_Sales_Detail__c' && (Date) i.get('Fiscal_Date__c') == NULL){
                fDateSet.add((Date) i.get('Commissionable_Date__c'));
            }
            //Sharing_Key__c
            /*if((String) i.get('Sharing_Key__c') != NULL){

}*/        
        }
        
        // Create Map of Fiscal Dates - 04Feb2018 - ESC
        if(fDateSet.size() > 0){
            for(Business_Days__c b : [SELECT Date__c, Fiscal_Date__c
                                      FROM Business_Days__c
                                      WHERE Date__c = :fDateSet])
            {
                if(b.Fiscal_Date__c != NULL){
                    fDateMap.put(b.Date__c, b.Fiscal_Date__c);
                }
            }
        }
        
        // Create Map of Contract Numbers to Contract Header ID's
        if(cset.size() > 0){
            for(Contract_Header__c c : [SELECT Id, Agreement_Number__c
                                        FROM Contract_Header__c
                                        WHERE Agreement_Number__c =:cset])
            {
                cMap.put(c.Agreement_Number__c, c.Id);
            }
            
        }
        
        
        // Territory Map
        if(tSet.size() > 0){
            for(Territory_Master__c tm : [SELECT Id, Business_Unit__c, Compensation_Profile__c, Sharing_Key__c
                                          FROM Territory_Master__c
                                          WHERE Id =:tSet])
            {
                tMap.put(tm.Id, tm);
                if(tm.Business_Unit__c == 'Vascular'){
                    checkKAM = TRUE;
                }
            }
        }
        system.debug('tMap: ' + tMap);
        // Create the Account Id Map
        if(acctSet.size() > 0){
            for(Account a : [SELECT Id, SAP_Sold_To__c, IDN_Region_from_IDN_Acct__c
                             FROM Account
                             WHERE SAP_Sold_To__c =:acctSet])
            {
                aMap.put(a.SAP_Sold_To__c, a);
            }
        }
        
        // New 11Sept2017 - ESC
        if(checkKAM){
            // Create the Map of KAM's
            for(Territory_Master__c tm : [SELECT Id, Territory_Number__c, Sales_Rep_Name__c, Role__c
                                          FROM Territory_Master__c
                                          WHERE (Role__c = 'KAM' OR Role__c = 'ASR')
                                          AND Business_Unit__c = 'Vascular'])
            {
                kamTerrMap.put(tm.Territory_Number__c, tm);
            }
            system.debug('kamTerrMap: ' + kamTerrMap);
            
            // Check the A681 SAP Table to finish building out the KAM Mapping
            for(Territory_Alignment__c ta : [SELECT Territory__c, Territory2__c, Territory3__c, Territory4__c, SAP_Code__c
                                             FROM Territory_Alignment__c
                                             WHERE SAP_Code__c =:altacctSet
                                             AND ZPSA_Table__c = 'A681' AND Active__c = TRUE])
            {
                system.debug('ta: ' + ta);
                // There should only be one match per record
                // it and not else if because we could have the DNA and KAM data on the same record
                if(kamTerrMap.containsKey(ta.Territory__c)){ // If T1 == KAM add them to the map, shouldn't get a hit here but just in case.
                    if(kamTerrMap.get(ta.Territory__c).Role__c == 'ASR'){
                        asrAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory__c));
                    }
                    else{
                        kamAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory__c));
                    }
                    
                }
                if(kamTerrMap.containsKey(ta.Territory2__c)){ // If T2 == KAM add them to the map, this should be where we get a hit.
                    if(kamTerrMap.get(ta.Territory2__c).Role__c == 'ASR'){
                        asrAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory2__c));
                    }
                    else{
                        kamAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory2__c));
                    }
                }
                if(kamTerrMap.containsKey(ta.Territory3__c)){ // If T3 == KAM add them to the map, shouldn't get a hit here but just in case.
                    if(kamTerrMap.get(ta.Territory3__c).Role__c == 'ASR'){
                        asrAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory3__c));
                    }
                    else{
                        kamAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory3__c));
                    }
                }
                if(kamTerrMap.containsKey(ta.Territory4__c)){ // If T3 == KAM add them to the map, shouldn't get a hit here but just in case.
                    if(kamTerrMap.get(ta.Territory4__c).Role__c == 'ASR'){
                        asrAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory4__c));
                    }
                    else{
                        kamAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory4__c));
                    }
                }
                /* Old Logic
if(kamTerrMap.containsKey(ta.Territory__c)){ // If T1 == KAM add them to the map, shouldn't get a hit here but just in case.
if(ta.Territory__c == '800205'){
dnaAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory__c));
}
else{
kamAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory__c));
}
}
if(kamTerrMap.containsKey(ta.Territory2__c)){ // If T2 == KAM add them to the map, this should be where we get a hit.
if(ta.Territory2__c == '800205'){
dnaAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory2__c));
}
else{
kamAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory2__c));
}
}
if(kamTerrMap.containsKey(ta.Territory3__c)){ // If T3 == KAM add them to the map, shouldn't get a hit here but just in case.
if(ta.Territory3__c == '800205'){
dnaAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory3__c));
}
else{
kamAcctMap.put(ta.SAP_Code__c, kamTerrMap.get(ta.Territory3__c));
}
}*/
            }
        }
        
        // Create Product Id Map
        if(prodSet.size() > 0){
            for(Product2 p : [SELECT Id, Material_Key__c
                              FROM Product2
                              WHERE Material_Key__c =:prodSet])
            {
                prodMap.put(p.Material_Key__c, p.Id);
            }
        }
        system.debug('*** prodMap *** ' + prodMap);
        for(SObject i : newTrigger){
            // Update BU and Comp Profile
            tid = (Id) i.get('Territory__c');
            if(tMap.containsKey(tid)){
                i.put('Business_Unit__c', tMap.get(tid).Business_Unit__c);
                i.put('Compensation_Profile__c', tMap.get(tid).Compensation_Profile__c);
                i.put('Sharing_Key__c', tMap.get(tid).Sharing_Key__c);
                /*if((String) i.get('Sharing_Key__c') == NULL){

}*/
            }
            system.debug('*** tMap *** ' + tMap);
            // Contract Lookup
            Sales_Deal = (String) i.get('Sales_Deal__c');
            if(cMap.containsKey(Sales_Deal)){
                i.put('Contract_Header__c', cMap.get(Sales_Deal));
            }
            
            // Account Lookup
            sap = (String) i.get('SAP_Code__c');
            acct = (Id) i.get('Account__c');
            if(aMap.containsKey(sap)){
                if(acct == NULL){
                    i.put('Account__c', aMap.get(sap).Id);
                }
                if((String) i.get('IDN_Region_Text__c') != aMap.get(sap).IDN_Region_from_IDN_Acct__c){
                    i.put('IDN_Region_Text__c', aMap.get(sap).IDN_Region_from_IDN_Acct__c);
                }
            }
            
            // KAM Check - 11Sept2017 - ESC
            // Product_Group__c
            // Territory_Number__c
            // 800205
            if(
                checkKAM &&
                kamAcctMap.containsKey(sap) &&
                (String) i.get('Business_Unit__c') == 'Vascular' &&
                (String) i.get('Product_Group__c') != '00230005'
            ){
                if(kamAcctMap.get(sap).Territory_Number__c == '800205'){
                    i.put('KAM__c', NULL);
                    i.put('KAM_Name__c', NULL);
                }
                else{
                    i.put('KAM__c', kamAcctMap.get(sap).Id);
                    i.put('KAM_Name__c', kamAcctMap.get(sap).Sales_Rep_Name__c);
                }
                i.put('DNA__c', kamTerrMap.get('800205').Id);
                i.put('DNA_Name__c', kamTerrMap.get('800205').Sales_Rep_Name__c);
                
                /*
if(kamAcctMap.containsKey(sap)){
i.put('KAM__c', kamAcctMap.get(sap).Id);
i.put('KAM_Name__c', kamAcctMap.get(sap).Sales_Rep_Name__c);
}
else{
}
if(dnaAcctMap.containsKey(sap)){
i.put('DNA__c', dnaAcctMap.get(sap).Id);
i.put('DNA_Name__c', dnaAcctMap.get(sap).Sales_Rep_Name__c);
}
else{
i.put('DNA__c', NULL);
i.put('DNA_Name__c', NULL);
}*/
            }
            else{
                i.put('KAM__c', NULL);
                i.put('KAM_Name__c', NULL);
                i.put('DNA__c', NULL);
                i.put('DNA_Name__c', NULL);
            }
            
            // ASR Section - 24Aug2018 - ESC
            if(
                checkKAM &&
                asrAcctMap.containsKey(sap) &&
                (String) i.get('Business_Unit__c') == 'Vascular' &&
                (
                    // This Flags which products are compensible for ASR's
                    (String) i.get('Product_Group__c') == '00230005' ||
                    (String) i.get('Product_Sub_Group__c') == '002300020005'
                )
                
            ){
                i.put('ASR__c', asrAcctMap.get(sap).Id);
                i.put('ASR_Name__c', asrAcctMap.get(sap).Sales_Rep_Name__c);
            }
            else{
                i.put('ASR__c', NULL);
                i.put('ASR_Name__c', NULL);
            }
            // END ASR Changes
            
            
            
            // Parent Account Lookup
            if((Id) i.get('Parent_Account__c') == NULL && aMap.containsKey((String) i.get('Parent_SAP_Code__c'))){
                i.put('Parent_Account__c', aMap.get((String) i.get('Parent_SAP_Code__c')).Id);
            }
            
            // Product Lookup
            pkey = (String) i.get('Material_Key__c');
            prod = (Id) i.get('Product__c');
            if(prod == NULL && prodMap.containsKey(pkey)){
                i.put('Product__c', prodMap.get(pkey));
            }
            
            // Add Fiscal Date
            if(type == 'Invoiced_Sales_Detail__c' && (Date) i.get('Fiscal_Date__c') == NULL && fDateMap.containsKey((Date) i.get('Commissionable_Date__c'))){
                i.put('Fiscal_Date__c', fDateMap.get((Date) i.get('Commissionable_Date__c')));
            }
            
            // Add Sales Order Number Key
            //            if(type == 'Invoiced_Sales_Detail__c'
            //            Sales_Order_Key__c
            //            Sales_Order_Number__c
            //            Line_Item_Number__c
            //            Invoice_Order_Number__c
            //if(type == 'Invoiced_Sales_Detail__c' && (String) i.get('Sales_Order_Key__c') == NULL){
            if(type == 'Invoiced_Sales_Detail__c'){
                Decimal lineNum = (Decimal) i.get('Line_Item_Number__c');
                lineNum = lineNum.round();
                i.put('Sales_Order_Key__c', (String) i.get('Sales_Order_Number__c') + '-' + lineNum + '-' + (String) i.get('Invoice_Order_Number__c'));
            }
        }
    }
    
    public static void addCompensatory(List<SObject> newTrigger, String objName){
        System.debug('*** Starting addCompensatory in Invoiced_Sales_Helper_Class ***');
        string Product_Class;
        string Product_Group;
        string Product_Sub_Group;
        string Product_Line;
        string Product_Name;
        string Product_Name_Exception;
        string bu;
        string subGroup;
        
        System.debug('*** objName *** ' + objName);
        System.debug('*** newTrigger *** ' + newTrigger);
        List<BaseQuotaException__c> bqe = BaseQuotaException__c.getall().values();
        System.debug('*** bqe *** ' + bqe);
        Boolean IsException = bqe[0].IsException__c;
        date thisYear = date.today();
        
        map<String, Compensation_Rules__c> compMap = new map<String, Compensation_Rules__c>();
        set<String> compKeys = new set<String>(); // Used to build the CompMap
        set<String> altcompKeys = new set<String>(); // Used to build the Alt CompMap
        
        for(SObject i : newTrigger){
            bu = (String) i.get('Compensation_Profile__c');
            subGroup = (String) i.get('Product_Sub_Group__c');
            //system.debug('bu[1]: ' + bu);
            System.debug('*** bu *** ' + bu);
            if(bu != NULL){
                compKeys.add(bu + '-' + (String) i.get('Product_Class__c'));
                compKeys.add(bu + '-' + (String) i.get('Product_Group__c'));
                compKeys.add(bu + '-' + (String) i.get('Product_Sub_Group__c'));
                if(subGroup == 'Langston'){
                    compKeys.add(bu + '-x-' + (String) i.get('Product_Sub_Group__c'));
                }//end if
                compKeys.add(bu + '-' + (String) i.get('Product_Line__c'));
                compKeys.add(bu + '-' + (String) i.get('Material_Name__c'));
                compKeys.add(bu + '-x-' + (String) i.get('Material_Name__c'));
            }
        }
        
        System.debug('*** compKeys *** ' + compKeys);
        
        if(compKeys.size() > 0){
            // Create Map of Compensation Rules
            for(Compensation_Rules__c cr : [SELECT Id, Key__c, Compensation_Type__c, Compensation_Profile__c,
                                            Compensatory_Rule_Exception__c, Exception_Reason__c
                                            FROM Compensation_Rules__c
                                            WHERE Key__c =:compKeys
                                            AND Active__c = TRUE])
            {
                compMap.put(cr.Key__c, cr);
                //system.debug('Key: ' + cr.Key__c + ' - Compensation Profile: ' + cr.Compensation_Profile__c);
            }
        }
        System.debug('*** compMap *** ' + compMap);
        
        for(SObject i : newTrigger){
            system.debug('-- Starting Second Loops --');
            
            // Validate that there is a Compensation Profile associated to the Sales Record
            bu = (String) i.get('Compensation_Profile__c');
            subGroup = (String) i.get('Product_Sub_Group__c');
            System.debug('*** bu *** ' + bu);
            if(bu != NULL){
                // Rebuild the keys
                Product_Class = bu + '-' + (String) i.get('Product_Class__c');
                Product_Group = bu + '-' + (String) i.get('Product_Group__c');
                Product_Sub_Group = bu + '-' + (String) i.get('Product_Sub_Group__c');
                //adding exception for Interventional
                if(subGroup == 'Langston'){
                    Product_Sub_Group = bu + '-x-' + (String) i.get('Product_Sub_Group__c');
                }//end if
                Product_Line = bu + '-' + (String) i.get('Product_Line__c');
                Product_Name = bu + '-' + (String) i.get('Material_Name__c');
                Product_Name_Exception = bu + '-x-' + (String) i.get('Material_Name__c');
                System.debug('*** Product_Name_Exception *** ' + Product_Name_Exception);
                
                // Used to determine if the sales happened this year or last. Open Orders and Invoice Detail should always show compensable.
                // Invoice Detail Sales from previous year should be compensable as we only use that data to compare sales this year vs. last
                // 08Mar2018 - ESC
                date compareDate;
                Integer compareDateYear;
                if(objName == 'Invoiced_Sales__c'){
                    compareDate = (Date) i.get('Date__c');
                    compareDateYear = compareDate.year();
                }
                else{
                    compareDate = date.today();
                }
                
                //Add to help with logic for EOY freeze of Sales Cockpit
                //making sure compareDateYear is not NULL for Test Class
                if(compareDateYear == NULL){
                    compareDateYear = thisYear.year() - 1;
                }
                
                Integer compareDateFinal = thisYear.year() - compareDateYear;
                
                system.debug('*** compMap.containsKey(Product_Name_Exception) *** ' + compMap.containsKey(Product_Name_Exception));
                system.debug('*** compareDateFinal *** ' + compareDateFinal);
                system.debug('*** compareDate.year() *** ' + compareDate.year());
                system.debug('*** thisYear.year() *** ' + thisYear.year());
                system.debug('*** IsException *** ' + IsException);
                // Loops through the rules and if there's a match associate the related Comp Rule and the Comp Type
                if(compMap.containsKey(Product_Name_Exception)){
                    // Exception Rules with a reason of 'BASEQUOTA' should be compensible this year and not compensible last as they are not part of baseline (usually capital materials)
                    //Added by Dunte'e Silver to fix EOY BASEQUOTA issue when Sales Cockpit is frozen
                    if(compMap.get(Product_Name_Exception).Exception_Reason__c == 'BASEQUOTA' && compareDateFinal == 1 && IsException){
                        system.debug('*** compMap.get(Product_Name_Exception).Exception_Reason__c *** ' + compMap.get(Product_Name_Exception).Exception_Reason__c);
                        i.put('Compensation_Rules__c', compMap.get(Product_Name_Exception).Id);
                        i.put('Compensation_Type__c', compMap.get(Product_Name_Exception).Compensation_Type__c);
                        //system.debug('*** compMap.get(Product_Name_Exception).Id *** ' + compMap.get(Product_Name_Exception).Id);
                        //system.debug('*** compMap.get(Product_Name_Exception).Compensation_Type__c *** ' + compMap.get(Product_Name_Exception).Compensation_Type__c);
                    }
                    else if(compMap.get(Product_Name_Exception).Exception_Reason__c == 'BASEQUOTA' && compareDate.year() == thisYear.year()){
                        i.put('Compensation_Rules__c', compMap.get(Product_Name_Exception).Id);
                        i.put('Compensation_Type__c', compMap.get(Product_Name_Exception).Compensation_Type__c);
                    }
                    else{
                        i.put('Compensation_Rules__c', NULL);
                        i.put('Compensation_Type__c', 'Non-Compensatory');
                    }
                }
                else if(compMap.containsKey(Product_Name)){
                    system.debug('*** compMap.containsKey(Product_Name) *** ' + compMap.containsKey(Product_Name) );
                    i.put('Compensation_Rules__c', compMap.get(Product_Name).Id);
                    i.put('Compensation_Type__c', compMap.get(Product_Name).Compensation_Type__c);
                }
                else if(compMap.containsKey(Product_Line)){
                    system.debug('*** compMap.containsKey(Product_Line) *** ' + compMap.containsKey(Product_Line) );
                    i.put('Compensation_Rules__c', compMap.get(Product_Line).Id);
                    i.put('Compensation_Type__c', compMap.get(Product_Line).Compensation_Type__c);
                }
                else if(compMap.containsKey(Product_Sub_Group)){
                    system.debug('*** compMap.containsKey(Product_Sub_Group) *** ' + compMap.containsKey(Product_Sub_Group) );
                    i.put('Compensation_Rules__c', compMap.get(Product_Sub_Group).Id);
                    i.put('Compensation_Type__c', compMap.get(Product_Sub_Group).Compensation_Type__c);
                }
                else if(compMap.containsKey(Product_Group)){
                    system.debug('*** compMap.containsKey(Product_Group) *** ' + compMap.containsKey(Product_Group) );
                    i.put('Compensation_Rules__c', compMap.get(Product_Group).Id);
                    i.put('Compensation_Type__c', compMap.get(Product_Group).Compensation_Type__c);
                }
                else if(compMap.containsKey(Product_Class)){
                    system.debug('*** compMap.containsKey(Product_Class) *** ' + compMap.containsKey(Product_Class) );
                    i.put('Compensation_Rules__c', compMap.get(Product_Class).Id);
                    i.put('Compensation_Type__c', compMap.get(Product_Class).Compensation_Type__c);
                }
                // If no rules match and there is a value for Compensation, remove it!
                else{
                    i.put('Compensation_Rules__c', NULL);
                    i.put('Compensation_Type__c', 'Non-Compensatory');
                }
                System.debug('*** i 1st *** ' + i);
            }
            // If no comp profile make sure there's no associated compensation data!
            else{
                system.debug('*** NO COMP PROFILE *** ');
                i.put('Compensation_Rules__c', NULL);
                i.put('Compensation_Type__c', 'Non-Compensatory');
            }
            // End Else
            System.debug('*** i 2nd *** ' + i);
        } // End Loop
    }//end of addCompensatory
    
    public static void addAccountAfter(List<SObject> newTrigger){
        System.debug('*** Starting addAccountAfter in Invoiced_Sales_Helper_Class ***');
        // Used to add an Account from Customer Master Reference Object
        set<String> acctSet = new set<String>();
        set<String> newSAPS = new set<String>();
        list<Account> newAccts = new list<Account>();
        list<SObject> updateObj = new list<SObject>();
        map<String, Id> acctMap = new map<String, Id>();
        Id acct;
        String sap;
        
        // Check to see if we need to do a lookup
        for(SObject i : newTrigger){
            sap = (String) i.get('SAP_Code__c');
            acct = (Id) i.get('Account__c');
            if(sap != NULL && acct == NULL){
                acctSet.add(sap);
            }
        }
        
        // Create Account Id Map
        if(acctSet.size() > 0){
            for(Customer_Master_Reference__c cmr : [SELECT Account_Group__c, Name,
                                                    City__c, Country__c, Customer_Group__c, SAP_Code__c, State__c,
                                                    Street__c, zBlock__c, Zip_Code__c
                                                    FROM Customer_Master_Reference__c
                                                    WHERE SAP_Code__c =:acctSet])
            {
                if(newSAPS.contains(cmr.SAP_Code__c) == FALSE){
                    Account insAcct = new Account(
                        Name = cmr.Name,
                        Account_Group__c = cmr.Account_Group__c,
                        BillingCity = cmr.City__c,
                        BillingCountry = cmr.Country__c,
                        BillingState = cmr.State__c,
                        BillingStreet = cmr.Street__c,
                        BillingPostalCode = cmr.Zip_Code__c,
                        ShippingCity = cmr.City__c,
                        ShippingCountry = cmr.Country__c,
                        ShippingState = cmr.State__c,
                        ShippingStreet = cmr.Street__c,
                        ShippingPostalCode = cmr.Zip_Code__c,
                        Customer_Group__c = cmr.Customer_Group__c,
                        SAP_Sold_To__c = cmr.SAP_Code__c,
                        zBlock__c = cmr.zBlock__c
                    );
                    newAccts.add(insAcct);
                    newSAPS.add(cmr.SAP_Code__c);
                }
                
            }
            if(newAccts.size() > 0){
                insert newAccts;
                for(Account a : newAccts){
                    acctMap.put(a.SAP_Sold_To__c, a.Id);
                }
            }
            
            // Associate the account to the record
            List<SObject> sObjList = new List<SObject>();
            string recid;
            Schema.SObjectType sot = newTrigger.getSObjectType();
            for(SObject i : newTrigger){
                sap = (String) i.get('SAP_Code__c');
                acct = (Id) i.get('Account__c');
                recid = (Id) i.get('Id');
                if(sap != NULL && acct == NULL){
                    if(acctMap.containsKey(sap)){
                        SObject sObj = sot.newSObject();
                        sObj.put('Account__c', acctMap.get(sap));
                        sObj.put('Id', recid);
                        sObjList.add(sObj);
                    }
                }
            }
            if(sObjList.size() > 0){
                update sObjList;
            }
        }
    }
    
      /*Invoking Class/Component - master_Invoiced_Sales || master_Invoiced_Sales_Detail
*Input Params - Trigger.New (Material_Name__c, Territory_Number__c, Account__r.BillingState)
*Output Params - Return Void, Updates this object OwnerId, Territory_Number__c (ISR), Territory__c,Compensation_Rules__c
*Method Description - grab input params and match in custom mdt
*-------------------- find and assign ISR to incoming territory number.
*Invocation Class/Component -
*/
    public static void addOwnerAndSnaresRep2ISR(List<SObject> newTrigger){
        List<Account> accSteRecLst;
        Set<String> tnumSet = new Set<String>();
        List<Territory_Master__c> terrMstrRecLst;
        Map<String,Id> terrId = new Map<String,Id>();
        Map<String, Id> terrSalesRepInfoMap = new Map<String, Id>();
        Map<String,String> recId2AccIdMap = new Map<String,String>();
        Map<String,String> accId2StateMap = new Map<String,String>();
        Map<String,String> recId2StateMap = new Map<String,String>();
        Map<String,String> recId2territoryMap = new Map<String,String>();
        String sot = newTrigger.getSObjectType().getDescribe().getName();
        Map<String,Snares_Mapping__mdt> custMDTRecsMap = new Map<String,Snares_Mapping__mdt>();
        //collection to construct map+set of custom settings products
        Map<String,Snare_Products__c> snareMap = Snare_Products__c.getAll();
        Set<String> snareSet = snareMap.keySet();
        //collection to construct list of custom metadata records
        List<Snares_Mapping__mdt> smapMdtList = Snares_Mapping__mdt.getAll().values();
        //collection loop to construct map of curr rec id keys with accid value pair + curr recid keys with territory number value pair
        for(SObject sObjRec : newTrigger){
            if(sot == 'Invoiced_Sales__c' || sot == 'Invoiced_Sales_Detail__c'){recId2AccIdMap.put((String)sObjRec.get('Id'), (String)sObjRec.get('Account__c'));}
            recId2territoryMap.put((String)sObjRec.get('Id'), (String)sObjRec.get('Territory_Number__c'));
            tnumSet.add((String)sObjRec.get('Territory_Number__c'));
        }
        for(Snares_Mapping__mdt forEachCustMdtObj : smapMdtList){
            tnumSet.add(forEachCustMdtObj.ISR_Rep_Number__c);
            tnumSet.add(forEachCustMdtObj.Territory_Number__c);
            custMDTRecsMap.put(forEachCustMdtObj.DeveloperName, forEachCustMdtObj);
        }
        //get sales rep info into map for all territory and ISR numbers from the custom metadata recs
        terrMstrRecLst = [SELECT Sales_Rep__c, Manager__c, Territory_Number__c, Primary_Territory_User__c, Territory__c,
                          Sales_Rep__r.IsActive, Manager__r.IsActive, Primary_Territory_User__r.IsActive,
                          Primary_Sales_Rep_Flip__c, Parent_Territory__r.Sales_Rep__r.IsActive, Parent_Territory__r.Primary_Sales_Rep_Flip__c,
                          Region_Number__c, Parent_Territory__r.Sales_Rep__c, Parent_Territory__r.Primary_Territory_User__c,
                          Parent_Territory__r.Primary_Territory_User__r.IsActive
                          FROM Territory_Master__c
                          WHERE Territory_Number__c =:tnumSet];
        //get billing state for curr rec accs in recId2AccIdMap
        accSteRecLst = [SELECT Id, BillingState FROM Account WHERE Id IN :recId2AccIdMap.values()];
        //collection loop to construct map of account id keys with billingstate value pair
        for(Account forEachAccountObj : accSteRecLst){
            if(String.isBlank(forEachAccountObj.BillingState)){accId2StateMap.put(forEachAccountObj.Id, 'NOSTATE');}
            else{accId2StateMap.put(forEachAccountObj.Id, forEachAccountObj.BillingState);}
        }
        //collection loop to construct map of curr rec id id keys with billingstate value pair
        for(String recId : recId2AccIdMap.keySet()){
            recId2StateMap.put(recId, accId2StateMap.get(recId2AccIdMap.get(recId)));
        }
        
        //main for loop to execute snares logic or just update the non snares with ownerid
        for(SObject forEachOfSobj : newTrigger){
            String prodName = '';
            if(sot == 'Invoiced_Sales__c' || sot == 'Invoiced_Sales_Detail__c'){prodName = (String) forEachOfSobj.get('Material_Name__c');}
            String stateName = '';
            if(sot == 'Invoiced_Sales__c' || sot == 'Invoiced_Sales_Detail__c'){stateName = String.valueOf(recId2StateMap.get((String)forEachOfSobj.get('Id')));}
            // Create Territory Id Map
            for(Territory_Master__c terrMasterObj : terrMstrRecLst)
            {
                if(terrMasterObj.Sales_Rep__r.IsActive && terrMasterObj.Primary_Sales_Rep_Flip__c == FALSE){
                    terrSalesRepInfoMap.put(terrMasterObj.Territory_Number__c, terrMasterObj.Sales_Rep__c);
                    terrId.put(terrMasterObj.Territory_Number__c,terrMasterObj.Id);
                }
                else if(terrMasterObj.Primary_Territory_User__r.IsActive){
                    terrSalesRepInfoMap.put(terrMasterObj.Territory_Number__c, terrMasterObj.Primary_Territory_User__c);
                    terrId.put(terrMasterObj.Territory_Number__c,terrMasterObj.Id);
                }
                else if(terrMasterObj.Parent_Territory__r.Sales_Rep__r.IsActive && terrMasterObj.Parent_Territory__r.Primary_Sales_Rep_Flip__c == FALSE){
                    terrSalesRepInfoMap.put(terrMasterObj.Territory_Number__c, terrMasterObj.Parent_Territory__r.Sales_Rep__c);
                    terrId.put(terrMasterObj.Territory_Number__c,terrMasterObj.Id);
                }
                else if(terrMasterObj.Parent_Territory__r.Primary_Territory_User__r.IsActive){
                    terrSalesRepInfoMap.put(terrMasterObj.Territory_Number__c, terrMasterObj.Parent_Territory__r.Primary_Territory_User__c);
                    terrId.put(terrMasterObj.Territory_Number__c,terrMasterObj.Id);
                }
                else{// If no matches reset to the TFX Service Account User Id
                    terrSalesRepInfoMap.put(terrMasterObj.Territory_Number__c, UserInfo.getUserId());
                    terrId.put(terrMasterObj.Territory_Number__c,terrMasterObj.Id);
                }
            }
            if(custMDTRecsMap.containsKey(stateName+'_'+forEachOfSobj.get('Territory_Number__c')) && snareSet.contains(prodName)){               
                Snares_Mapping__mdt smapObj = new Snares_Mapping__mdt();
                smapObj= custMDTRecsMap.get(String.valueOf(recId2StateMap.get((String)forEachOfSobj.get('Id'))+'_'+forEachOfSobj.get('Territory_Number__c')));
                System.debug('snares match found in mdt--'+'invid'+forEachOfSobj.get('Id')+'--'+String.valueOf(recId2StateMap.get((String)forEachOfSobj.get('Id'))+'_'+forEachOfSobj.get('Territory_Number__c'))+'--value--'+smapObj.ISR_Rep_Number__c);
                forEachOfSobj.put('OwnerId', terrSalesRepInfoMap.get(smapObj.ISR_Rep_Number__c));
                forEachOfSobj.put('Territory_Number__c',smapObj.ISR_Rep_Number__c);
                forEachOfSobj.put('Territory__c',terrId.get(smapObj.ISR_Rep_Number__c));
                forEachOfSobj.put('Compensation_Rules__c', System.Label.Snares_Comp_Rule_SF_Id);//adding Interventional ISR Compensation Rule
                forEachOfSobj.put('Compensation_Type__c', System.Label.Snares_Comp_Type);
                //comp profile needs to be added from territory
            }
            else {
                if(terrSalesRepInfoMap.containsKey((String)forEachOfSobj.get('Territory_Number__c'))){
                    System.debug('snares else if-->'+forEachOfSobj.get('Id')+'--tnum--'+terrSalesRepInfoMap.get((String)forEachOfSobj.get('Territory_Number__c')));
                    forEachOfSobj.put('OwnerId', terrSalesRepInfoMap.get((String)forEachOfSobj.get('Territory_Number__c')));
                }
            }
        }
    }//end of method addOwnerAndSnaresRep2ISR
    
    public static void fixOpenOrderKeys(List<Open_Orders__c> newTrigger){
        System.debug('*** Starting fixOpenOrderKeys in Invoiced_Sales_Helper_Class ***');
        string aid;
        string mid;
        
        for(Open_Orders__c oo : newTrigger){
            /*if(oo.Account_Material_Key__c == NULL && oo.Account__c != NULL && oo.Product__c != NULL){
aid = oo.Account__c;
aid = aid.left(15);
mid = oo.Product__c;
mid = mid.left(15);
oo.Account_Material_Key__c = aid + '-' + mid;
}*/
            if(oo.Material_Key__c == NULL){
                oo.Material_Key__c = oo.Material_Name__c + '-' + oo.Sales_Org__c + '-' + oo.Distribution_Channel__c;
            }
            
        }
    }
    /*
public static void guessTerritory(List<Open_Orders__c> newTrigger){

// This is the hail mary using the Sales Accounts to look at the related BU/Account relationship and pulling the territory.
// If there's more than one match we'll have to go back to the drawing board on how to guess...
set<Id> acctId = new set<Id>();
set<String> buSet = new set<String>();
map<String, Id> saMap = new map<String, Id>();
list<Open_Orders__c> secondWave = new list<Open_Orders__c>();

for(Open_Orders__c oo : newTrigger){
if(oo.Business_Unit__c != NULL && oo.Territory__c == NULL){
acctId.add(oo.Account__c);
buSet.add(oo.Business_Unit__c);
secondWave.add(oo);
}
}

if(buSet.size() > 0){
for(Sales_Accounts__c sa : [SELECT Account__c, Business_Unit__c, Territory__c
FROM Sales_Accounts__c
WHERE Account__c =:acctId
AND Business_Unit__c =:buSet])
{
saMap.put(sa.Account__c + '-' + sa.Business_Unit__c, sa.Territory__c);
}
for(Open_Orders__c oo : secondWave){
if(saMap.containsKey(oo.Account__c + '-' + oo.Business_Unit__c)){
oo.Territory__c = saMap.get(oo.Account__c + '-' + oo.Business_Unit__c);
oo.Territory_Guess__c = TRUE;
}
}

}
}*/
    public static void backupAlternatives(List<Open_Orders__c> newTrigger){
        System.debug('*** Starting backupAlternatives in Invoiced_Sales_Helper_Class ***');
        // This class is used for determining Vascular Open Order Alternatives for Products that are on backorder.
        // Dec 2017 - ESC
        
        string mkey;
        integer row = 0;
        set<String> mSet = new set<String>();
        map<String, List<String>> megaMap = new map<String, List<String>>();
        map<String, PRODUCT2> pMap = new map<String, PRODUCT2>();
        list<Open_Orders__c> workList = new list<Open_Orders__c>();
        list<Open_Orders__c> workListManualSubs = new list<Open_Orders__c>();
        set<id> manualSubs = new set<id>();
        map<id, Product2> manualSubsProductsMap;
        //map<String, Backorder_Replacement_Matrix__c> backMap = new map<String, Backorder_Replacement_Matrix__c>();
        
        // Step 1 - Create the 'Work' list
        for(Open_Orders__c oo : newTrigger){
            //if((oo.Business_Unit__c == 'Vascular' && oo.Back_Ordered__c == TRUE) || test.isRunningTest()){
            if(oo.Business_Unit__c == 'Vascular' || test.isRunningTest()){
                //Manual sub values have been entered, in that case only 
                if(oo.Manual_Sub_Values__c){workListManualSubs.add(oo);} 
                else{
                    //Manual sub values have NOT been entered, in that case only 
                    mSet.add(oo.Material_Key__c); // Add the Primary Products to the Material Set
                    workList.add(oo);
                }
            }
        }
        
        // Step 2(For Automatic Subs) - Create the Map Lookups
        System.debug('Printing workList: '+workList);
        
        if(mSet.size() > 0){
            // Create the Alternative Products Matrix 'Mega' Map
            // Backorder_Replacement_Matrix__c is a simple object used to easily store, update, and consume 1-3 alternative products per Product
            for(Backorder_Replacement_Matrix__c brm : [SELECT Id, Alt_Product_1__c, Alt_Product_2__c, Alt_Product_3__c,
                                                       Material_Key__c, Product__c, Distribution_Channel__c, Sales_Org__c
                                                       FROM Backorder_Replacement_Matrix__c
                                                       WHERE Material_Key__c = :mSet])
            {
                System.debug('Printing backorder replacement matrix: '+brm);
                //backMap.put(brm.Material_Key__c, brm);
                 
                if(brm.Alt_Product_1__c != NULL){
                  
                    mkey = brm.Alt_Product_1__c + '-' + brm.Sales_Org__c + '-' + brm.Distribution_Channel__c;
                    mSet.add(mkey); // Add the Alt Products to the Material Set
                    if(megaMap.containsKey(brm.Material_Key__c)) {
                        megaMap.get(brm.Material_Key__c).add(mkey);
                    }
                    else {
                        megaMap.put(brm.Material_Key__c, new String[]{mkey});
                    }
                    
                }
                if(brm.Alt_Product_2__c != NULL){
                    mkey = brm.Alt_Product_2__c + '-' + brm.Sales_Org__c + '-' + brm.Distribution_Channel__c;
                    mSet.add(mkey); // Add the Alt Products to the Material Set
                    if(megaMap.containsKey(brm.Material_Key__c)) {
                        megaMap.get(brm.Material_Key__c).add(mkey);
                    }
                    else {
                        megaMap.put(brm.Material_Key__c, new String[]{mkey});
                    }
                    
                }
                if(brm.Alt_Product_3__c != NULL){
                    mkey = brm.Alt_Product_3__c + '-' + brm.Sales_Org__c + '-' + brm.Distribution_Channel__c;
                    mSet.add(mkey); // Add the Alt Products to the Material Set
                    if(megaMap.containsKey(brm.Material_Key__c)) {
                        megaMap.get(brm.Material_Key__c).add(mkey);
                    }
                    else {
                        megaMap.put(brm.Material_Key__c, new String[]{mkey});
                    }
                    
                }
            }
            system.debug('mSet' + mSet);
            // Create Product Map using the Material Key
            for(Product2 p : [SELECT Id, Name, Material_Key__c, Product_On_Constraint__c, Weeks_On_Hand__c, Valuated_Unrestricted_Use_Stock__c
                              FROM PRODUCT2
                              //WHERE Weeks_On_Hand__c > 0 AND Material_Key__c = :mSet])
                              WHERE Material_Key__c = :mSet])
            {
                pMap.put(p.Material_Key__c, p);
            }
            system.debug('megaMap: ' + megaMap);
            system.debug('pMap: ' + pMap);
            
            // Step 3(For Automatic Subs) - Putting it all together
            for(Open_Orders__c oo : workList){
                //Manual sub values have been entered, in that case we don't want to override those values by trigger
                if(!oo.Manual_Sub_Values__c){
                    if(megaMap.containsKey(oo.Material_Key__c)){
                        system.debug('Step 3 - Matching Key: ' + oo.Material_Key__c);
                        row = 1;
                        for(String s : megaMap.get(oo.Material_Key__c))
                        {
                            system.debug('R:' + row + ' - Material: ' + s);
                            if(row == 1 && pMap.containsKey(s)){
                                // Round 1 goes in the first spot regardless
                                oo.Sub_1__c  = pMap.get(s).Id;
                                oo.Sub_1_Stock__c = pMap.get(s).Weeks_On_Hand__c;
                                oo.Subs_1_Product_on_Hand__c = pMap.get(s).Valuated_Unrestricted_Use_Stock__c;
                                oo.Sub_1_Status__c = pMap.get(s).Product_On_Constraint__c;
                                oo.Sub_2__c = NULL;
                                oo.Sub_2_Stock__c  = NULL;
                                oo.Subs_2_Product_on_Hand__c = NULL;
                                oo.Sub_2_Status__c = NULL;
                                oo.Sub_3__c = NULL;
                                oo.Sub_3_Stock__c  = NULL;
                                oo.Subs_3_Product_on_Hand__c = NULL;
                                oo.Sub_3_Status__c = NULL;
                                row++;
                            }
                            else if(row == 2 && pMap.containsKey(s)){
                                // Round 2 we check to see if 1 is still bigger than 2
                                if(oo.Sub_1_Stock__c > pMap.get(s).Weeks_On_Hand__c){
                                    // #2 goes in to #2 Slot
                                    oo.Sub_2__c = pMap.get(s).Id;
                                    oo.Sub_2_Stock__c  = pMap.get(s).Weeks_On_Hand__c;
                                    oo.Subs_2_Product_on_Hand__c = pMap.get(s).Valuated_Unrestricted_Use_Stock__c;
                                    oo.Sub_2_Status__c = pMap.get(s).Product_On_Constraint__c;
                                }
                                else{
                                    // Move #1 to #2 and put #2 in #1 slot
                                    oo.Sub_2__c = oo.Sub_1__c;
                                    oo.Sub_2_Stock__c  = oo.Sub_1_Stock__c;
                                    oo.Subs_2_Product_on_Hand__c = oo.Subs_1_Product_on_Hand__c;
                                    oo.Sub_2_Status__c = oo.Sub_1_Status__c;
                                    oo.Sub_1__c = pMap.get(s).Id;
                                    oo.Sub_1_Stock__c = pMap.get(s).Weeks_On_Hand__c;
                                    oo.Subs_1_Product_on_Hand__c = pMap.get(s).Valuated_Unrestricted_Use_Stock__c;
                                    oo.Sub_1_Status__c = pMap.get(s).Product_On_Constraint__c;
                                }
                                row++;
                            }
                            else if(row == 3 && pMap.containsKey(s)){
                                if(oo.Sub_2_Stock__c > pMap.get(s).Weeks_On_Hand__c){
                                    // #3 is smaller than #2 - #3 goes in #3 spot
                                    oo.Sub_3__c = pMap.get(s).Id;
                                    oo.Sub_3_Stock__c  = pMap.get(s).Weeks_On_Hand__c;
                                    oo.Subs_3_Product_on_Hand__c = pMap.get(s).Valuated_Unrestricted_Use_Stock__c;
                                    oo.Sub_3_Status__c = pMap.get(s).Product_On_Constraint__c;
                                }
                                else if(oo.Sub_1_Stock__c > pMap.get(s).Weeks_On_Hand__c){
                                    // #3 is smaller than #1 - #3 goes in #2 spot
                                    // #2 goes to #3 and #3 goes in #2
                                    oo.Sub_3__c = oo.Sub_2__c;
                                    oo.Sub_3_Stock__c  = oo.Sub_2_Stock__c;
                                    oo.Subs_3_Product_on_Hand__c = oo.Subs_2_Product_on_Hand__c;
                                    oo.Sub_3_Status__c = oo.Sub_2_Status__c;
                                    oo.Sub_2__c = pMap.get(s).Id;
                                    oo.Sub_2_Stock__c = pMap.get(s).Weeks_On_Hand__c;
                                    oo.Subs_2_Product_on_Hand__c = pMap.get(s).Valuated_Unrestricted_Use_Stock__c;
                                    oo.Sub_2_Status__c = pMap.get(s).Product_On_Constraint__c;
                                }
                                else{
                                    // #3 is larger than #1 and #2! - Everything gets shifted down
                                    // #1 goes to #2, #2, goes to #3, #3 goes in #1
                                    oo.Sub_3__c = oo.Sub_2__c;
                                    oo.Sub_3_Stock__c = oo.Sub_2_Stock__c;
                                    oo.Subs_3_Product_on_Hand__c = oo.Subs_2_Product_on_Hand__c;
                                    oo.Sub_3_Status__c = oo.Sub_2_Status__c;
                                    oo.Sub_2__c = oo.Sub_1__c;
                                    oo.Sub_2_Stock__c = oo.Sub_1_Stock__c;
                                    oo.Subs_2_Product_on_Hand__c = oo.Subs_1_Product_on_Hand__c;
                                    oo.Sub_2_Status__c = oo.Sub_1_Status__c;
                                    oo.Sub_1__c  = pMap.get(s).Id;
                                    oo.Sub_1_Stock__c = pMap.get(s).Weeks_On_Hand__c;
                                    oo.Subs_1_Product_on_Hand__c = pMap.get(s).Valuated_Unrestricted_Use_Stock__c;
                                    oo.Sub_1_Status__c = pMap.get(s).Product_On_Constraint__c;
                                }
                            }
                        }
                    }
                    else{
                        oo.Sub_1__c = NULL;
                        oo.Sub_1_Stock__c = NULL;
                        oo.Subs_1_Product_on_Hand__c = NULL;
                        oo.Sub_1_Status__c = NULL;
                        oo.Sub_2__c = NULL;
                        oo.Sub_2_Stock__c = NULL;
                        oo.Subs_2_Product_on_Hand__c = NULL;
                        oo.Sub_2_Status__c = NULL;
                        oo.Sub_3__c = NULL;
                        oo.Sub_3_Stock__c = NULL;
                        oo.Subs_3_Product_on_Hand__c = NULL;
                        oo.Sub_3_Status__c = NULL;
                        system.debug('Step 3 - No Matching Key! ' + oo.Material_Key__c);
                    }
                }
            }
        }
        
        // Step 2(For Manual Subs) - Create the Map Lookups
        if(workListManualSubs.size() > 0){
            for(Open_Orders__c oo : workListManualSubs){
                if(string.isNotBlank(oo.Sub_1__c)){manualSubs.add(oo.Sub_1__c);}
                if(string.isNotBlank(oo.Sub_2__c)){manualSubs.add(oo.Sub_1__c);}
                if(string.isNotBlank(oo.Sub_3__c)){manualSubs.add(oo.Sub_1__c);}
            }
            // Create Product Map using the Material Key
            manualSubsProductsMap = new map<id, Product2>([SELECT Id, Name, Material_Key__c, Product_On_Constraint__c, Weeks_On_Hand__c, Valuated_Unrestricted_Use_Stock__c
                                                           FROM PRODUCT2
                                                          // WHERE Weeks_On_Hand__c > 0 AND Id = :manualSubs]);
                                                          WHERE Id = :manualSubs]);
                                                          
            system.debug('manualSubs: ' + manualSubs);
            system.debug('manualSubsProductsMap: ' + manualSubsProductsMap);
            
            // Step 3(For Automatic Subs) - Putting it all together
            for(Open_Orders__c oo : workListManualSubs){
                if(manualSubsProductsMap.containsKey(oo.Sub_1__c)){
                    // For Sub 1
                    system.debug('OO: ' + oo.Id + '|Sub1: '+manualSubsProductsMap.get(oo.Sub_1__c));
                    oo.Sub_1_Stock__c = manualSubsProductsMap.get(oo.Sub_1__c).Weeks_On_Hand__c;
                    oo.Subs_1_Product_on_Hand__c = manualSubsProductsMap.get(oo.Sub_1__c).Valuated_Unrestricted_Use_Stock__c;
                    oo.Sub_1_Status__c = manualSubsProductsMap.get(oo.Sub_1__c).Product_On_Constraint__c;
                }
                if(manualSubsProductsMap.containsKey(oo.Sub_2__c)){
                    // For Sub 2 
                    system.debug('OO: ' + oo.Id + '|Sub2: '+manualSubsProductsMap.get(oo.Sub_2__c));
                    oo.Sub_2_Stock__c = manualSubsProductsMap.get(oo.Sub_2__c).Weeks_On_Hand__c;
                    oo.Subs_2_Product_on_Hand__c = manualSubsProductsMap.get(oo.Sub_2__c).Valuated_Unrestricted_Use_Stock__c;
                    oo.Sub_2_Status__c = manualSubsProductsMap.get(oo.Sub_2__c).Product_On_Constraint__c;
                }
                if(manualSubsProductsMap.containsKey(oo.Sub_3__c)){
                    // For Sub 3 
                    system.debug('OO: ' + oo.Id + '|Sub3: '+manualSubsProductsMap.get(oo.Sub_3__c));
                    oo.Sub_3_Stock__c = manualSubsProductsMap.get(oo.Sub_3__c).Weeks_On_Hand__c;
                    oo.Subs_3_Product_on_Hand__c = manualSubsProductsMap.get(oo.Sub_3__c).Valuated_Unrestricted_Use_Stock__c;
                    oo.Sub_3_Status__c = manualSubsProductsMap.get(oo.Sub_3__c).Product_On_Constraint__c;
                }
            }
        }
    }
}