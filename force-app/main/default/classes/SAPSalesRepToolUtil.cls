/*********************************************************************
* Description      : Utility methods to get relative data from multiple data sources.
* Test Class       : SAPSoapStubControllerTest.apxc
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
* Date         	   : 04/25/2023
* Work Item		   : W-025980
**********************************************************************/
public class SAPSalesRepToolUtil {
/******************************************************************************************/
/*************************************SalesRepLookup***************************************/
/******************************************************************************************/
    /*
     *Method Name 		  : getProductValsFrmMDT
	 *Method Input Params : 
     *Method Return type  : List<String>
     */
    public static List<String> getProductValsFrmMDT(){
        Set<String> prodCatSet = new Set<String>();
        List<Product_Mapping__mdt> prodMapinMDTLst = Product_Mapping__mdt.getAll().values();
        for(Product_Mapping__mdt forEchMDTObj : prodMapinMDTLst){
            prodCatSet.add(forEchMDTObj.Product_Category_Name__c);
        }
        return new List<String>(prodCatSet);
    }
    
    /*
     *Method Name 		  : getProductAreaValsFrmMDT
	 *Method Input Params : String prodCatVal	
     *Method Return type  : List<String>
     */
    public static List<String> getProductAreaValsFrmMDT(String prodCatVal){
        List<String> prodAreaLst = new List<String>();
        List<Product_Mapping__mdt> prodMapinMDTLst = Product_Mapping__mdt.getAll().values();
        for(Product_Mapping__mdt forEchMDTObj : prodMapinMDTLst){
            if(forEchMDTObj.Product_Category_Name__c.equals(prodCatVal))
                prodAreaLst.add(forEchMDTObj.Product_Area_Name__c);
        }
        return prodAreaLst;
    }
    
    /*
     *Method Name 		  : buildProdInfoMap
	 *Method Input Params : Map<String, String> prodInfoMap
     *Method Return type  : Map<String, String>
     */
    public static Map<String, String> buildProdInfoMap(Map<String, String> prodInfoMap){
        System.debug('fetch acc details for id===>'+prodInfoMap.get('accSfId'));
        Account accObj = fetchAccDetails(prodInfoMap.get('accSfId'));
        System.debug('after fetch acc details adding SAP code to prodInfoMap=>'+accObj.SAP_Sold_To__c);
        System.debug('after fetch acc details adding salesorg to prodInfoMap=>'+accObj.Sales_Org__c);
        prodInfoMap.put('salesOrg', accObj.Sales_Org__c);
        prodInfoMap.put('accCustCode', accObj.SAP_Sold_To__c);
        System.debug('after fetch product details adding product name to prodInfoMap=>'+fetchProductDetailsByID(prodInfoMap.get('ItemNumber')));
        prodInfoMap.put('ItemNumber', fetchProductDetailsByID(prodInfoMap.get('ItemNumber')));
        List<Product_Mapping__mdt> prodMapinMDTLst = Product_Mapping__mdt.getAll().values();
        System.debug('prodInfoMap prodCatVal==>'+prodInfoMap.get('prodCatVal'));
        System.debug('prodInfoMap prodAreaVal=>'+prodInfoMap.get('prodAreaVal'));
        for(Product_Mapping__mdt forEchMDTObj : prodMapinMDTLst){
            if(forEchMDTObj.Product_Category_Name__c.equals(prodInfoMap.get('prodCatVal')) && forEchMDTObj.Product_Area_Name__c.equals(prodInfoMap.get('prodAreaVal'))){
                System.debug('SF custom mdt match value exists=>'+forEchMDTObj.Product_Category_Code__c+'---'+forEchMDTObj.Product_Area_Code__c);
                prodInfoMap.put('prodCatVal', forEchMDTObj.Product_Category_Code__c);
                if(prodInfoMap.get('prodAreaVal').equals('NA') || String.isBlank(prodInfoMap.get('prodAreaVal'))){prodInfoMap.put('prodAreaVal', ''); System.debug('in if - prodareaval blank--->'+forEchMDTObj.Product_Category_Code__c+'---'+forEchMDTObj.Product_Area_Code__c);}
                else{prodInfoMap.put('prodAreaVal', forEchMDTObj.Product_Area_Code__c); System.debug('in else - prodareaval not blank--->'+forEchMDTObj.Product_Category_Code__c+'---'+forEchMDTObj.Product_Area_Code__c);}
            }
        }
        //add logged in user details to prodInfoMap
        prodInfoMap = getLoggedInUser(prodInfoMap);
        return prodInfoMap;
    }
    
   /*
    *Method Name         : fetchAccDetails
    *Method Input Params : Salesforce Account Id
    *Method Return type  : Account
    */
    public static Account fetchAccDetails(String accId){return [SELECT SAP_Sold_To__c, Sales_Org__c FROM Account WHERE Id =: accId];}
    
    /*
    *Method Name         : fetchProductDetailsByID
    *Method Input Params : Salesforce Product Id
    *Method Return type  : Product Name
    */
    public static String fetchProductDetailsByID(String prodId){return [SELECT Name FROM Product2 WHERE Id =: prodId].Name;}
    
    /*
     *Method Name         : getLoggedInUser
	 *Method Input Params : Map<String, String> prodInfoMap
     *Method Return type  : Map<String, String>
     */
    public static Map<String, String> getLoggedInUser(Map<String, String> prodInfoMap){
        User loggedUser = [SELECT Id, FirstName, LastName, Email FROM User WHERE Id =: UserInfo.getUserId()];
        prodInfoMap.put('UserFname', loggedUser.FirstName);
        prodInfoMap.put('UserLname', loggedUser.LastName);
        prodInfoMap.put('UserEmail', loggedUser.Email);
        return prodInfoMap;
    }
/******************************************************************************************/
/***************************************OrderHistory***************************************/
/******************************************************************************************/
    /*
     *Method Name         : buildOrderReqMap
	 *Method Input Params : Map<String, String> orderReqMap
     *Method Return type  : Map<String, String>
     */
    public static Map<String, String> buildOrderReqMap(Map<String, String> orderReqMap){
        Map<String, String> newOrderReqMap=new Map<String, String>();
        newOrderReqMap.put('Kunag',orderReqMap.get('accCustCode'));
        newOrderReqMap.put('Vkorg',orderReqMap.get('salesOrg'));
        newOrderReqMap.put('Audat', orderReqMap.get('fromDate'));
        newOrderReqMap.put('AudatBis', orderReqMap.get('toDate'));
       // System.debug('newOrderMap==> '+newOrderReqMap);
        return newOrderReqMap;
    }
     /*
     *Method Name         : buildOrderDetailsReqMap
	 *Method Input Params : Map<String, String> orderDetailsReqMap
     *Method Return type  : Map<String, String>
     */
    public static Map<String, String> buildOrderDetailsReqMap(Map<String, String> orderDetailsReqMap){
        Map<String, String> newOrderDetailsReqMap=new Map<String, String>();
        newOrderDetailsReqMap.put('IvVbeln',orderDetailsReqMap.get('orderNum'));
        newOrderDetailsReqMap.put('IvSoldTo',orderDetailsReqMap.get('accCustCode'));
       // System.debug('newOrderDetailsReqMap==> '+newOrderDetailsReqMap);
        return newOrderDetailsReqMap;
    }
}