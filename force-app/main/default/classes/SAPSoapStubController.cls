/*********************************************************************
* Description      : Controller class for SAP Connection and Send/Receive xml responses.
* Test Class       : SAPSoapStubControllerTest.apxc
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
* Date         	   : 04/25/2023
* Work Item		   : W-025980
**********************************************************************/
public class SAPSoapStubController {
/******************************************************************************************/
/*************************************SalesRepLookup***************************************/
/******************************************************************************************/
    //connections
    @AuraEnabled public static List<SAPSoapWrapperHub.SAPSalesRepInfoWrapper> connect2GetSalesRepLookupInfoFromSAP(Map<String, String> prodInfoMap){return SAPSoapConnectionsImpl.getSalesRepInfoFromSAP(prodInfoMap);}
    //sales rep lookup utils
    @AuraEnabled public static List<String> getProductsDetailsInternal(){return SAPSalesRepToolUtil.getProductValsFrmMDT();}
    @AuraEnabled public static List<String> getProductAreaVals(String prodCatVal){return SAPSalesRepToolUtil.getProductAreaValsFrmMDT(prodCatVal);}
    @AuraEnabled (cacheable=true)public static Account getAccDetailsById(String accId){return SAPSalesRepToolUtil.fetchAccDetails(accId);} 
    
/******************************************************************************************/
/***************************************OrderHistory***************************************/
/******************************************************************************************/
    @AuraEnabled(cacheable=true) public static List<SAPSoapWrapperHub.SAPOrderHistoryWrapper> connect2GetOrderHistoryInfoFromSAP(Map<String, String> orderReqMap){return SAPSoapConnectionsImpl.getOrderHistoryFromSAP(orderReqMap);}
    
    
    /******************************************************************************************/
/***************************************OrderDetails***************************************/
/******************************************************************************************/
    @AuraEnabled(cacheable=true) public static List<SAPSoapWrapperHub.SAPOrderDetailsWrapper> connect2GetOrderDetailsFromSAP(Map<String, String> orderReqMap){return SAPSoapConnectionsImpl.getOrderDetailsFromSAP(orderReqMap);}
    
    
    
     /******************************************************************************************/
/***************************************ShippingDetails***************************************/
/******************************************************************************************/
   // @AuraEnabled(cacheable=true) public static List<SAPSoapWrapperHub.SAPItemShippingWrapper> connect2GetShippingDetailsFromSAP(Map<String, String> orderReqMap){return SAPSoapConnectionsImpl.getShippingDetailsFromSAP(orderReqMap);}
}