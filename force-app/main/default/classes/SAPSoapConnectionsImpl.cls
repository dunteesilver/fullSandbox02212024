/*********************************************************************
* Description      : Implementation class for SAP Connections and Send/Receive xml responses.
* Test Class       : SAPSoapStubControllerTest.apxc
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
* Date         	   : 04/25/2023
* Work Item		   : W-025980
**********************************************************************/
public class SAPSoapConnectionsImpl {
    /******************************************************************************************/
    /**************************************SalesReLookup***************************************/
    /******************************************************************************************/
    //Global Initilizations
    String endpoint_uri;
    //salesreplookup - this method will connect to sap hana endpoint using named credential basic authentication and get sales rep lookup info.
    //constructs xml envelope for request body.
    public static List<SAPSoapWrapperHub.SAPSalesRepInfoWrapper> getSalesRepInfoFromSAP(Map<String,String> prodInfoMap){
        //initializations
        String endpoint_uri = Label.SAP_SALESREP_ENDPOINT_NMD_CRED_ENV;
        Map<Integer, Map<String,String>> addNodesToWrapperMap;
        List<SAPSoapWrapperHub.SAPSalesRepInfoWrapper> salesrepinfoLst;
        String requestXMLBody;
        //add to prodInfoMap map with prod category and area codes plus user info sales org
        prodInfoMap = SAPSalesRepToolUtil.buildProdInfoMap(prodInfoMap);
        //generate request xml body for sales rep lookup api
        requestXMLBody = SAPReqXMLEnvelopeGenerator.getReqXMLForSalesRep(prodInfoMap);
        //http post connection with soap envelope body
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:'+endpoint_uri);
        System.debug('endpoint-->'+endpoint_uri);
        request.setMethod('POST');
        request.setBody(requestXMLBody);
        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned with sales rep lookup endpoint: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
            System.debug(response.getBody());
            addNodesToWrapperMap = SAPSoapRespXMLEnvelopeParser.genericXmlNodesParserAllEndpoints(response.getBody());
            salesrepinfoLst = SAPSoapXml2POJOMapperCls.getSalesRepXMLNodesToWrapper(addNodesToWrapperMap);
            return salesrepinfoLst;
        } 
        else {
            return salesrepinfoLst;
        }
    }
    /******************************************************************************************/
    /***************************************OrderHistory***************************************/
    /******************************************************************************************/    
    //orderhistory - this method will connect to sap hana endpoint using named credential basic authentication and get order history lookup info.
    //constructs xml envelope for request body.
    public static List<SAPSoapWrapperHub.SAPOrderHistoryWrapper> getOrderHistoryFromSAP(Map<String,String> orderReqMap){
        //initializations
        String endpoint_uri = Label.SAP_ORDHIST_ENDPOINT_NMD_CRED_ENV;
        Map<Integer, Map<String,String>> addNodesToWrapperMap;
        List<SAPSoapWrapperHub.SAPOrderHistoryWrapper> orderHistoryLst;
        String requestXMLBody;
        //modify map to fetch respective prod category and area codes
        orderReqMap = SAPSalesRepToolUtil.buildOrderReqMap(orderReqMap);
        //generate request xml body for sales rep lookup api
        requestXMLBody = SAPReqXMLEnvelopeGenerator.getReqXMLForOrderHistory(orderReqMap);
        //http post connection with soap envelope body
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:'+endpoint_uri);
        request.setMethod('POST');
        request.setBody(requestXMLBody);
        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned with order history endpoint: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
            System.debug(response.getBody());
            addNodesToWrapperMap = SAPSoapRespXMLEnvelopeParser.genericXmlNodesParserAllEndpoints(response.getBody());
            orderHistoryLst = SAPSoapXml2POJOMapperCls.getOrdHistXMLNodesToWrapper(addNodesToWrapperMap);
            return orderHistoryLst;
        } else {
            return orderHistoryLst;
        }
    }
    
    
    /******************************************************************************************/
    /***************************************OrderDetails***************************************/
    /******************************************************************************************/        
    //orderdetails - this method will connect to sap hana endpoint using named credential basic authentication and get a specific order details info.
    //constructs xml envelope for request body.
    public static List<SAPSoapWrapperHub.SAPOrderDetailsWrapper> getOrderDetailsFromSAP(Map<String,String> orderReqMap){
        //initializations
        String endpoint_uri =Label.SAP_ORDDETAILS_ENDPOINT_NMD_CRED_ENV;
        Map<String, Object> addNodesToWrapperMap;
        List<SAPSoapWrapperHub.SAPOrderDetailsWrapper> orderDetailsLst;
        String requestXMLBody;
        //modify map to fetch respective order details
        orderReqMap = SAPSalesRepToolUtil.buildOrderDetailsReqMap(orderReqMap);
        //generate request xml body for sales rep lookup api
        requestXMLBody = SAPReqXMLEnvelopeGenerator.getReqXMLForOrderDetails(orderReqMap);
        //http post connection with soap envelope body
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:'+endpoint_uri);
        request.setMethod('POST');
        request.setBody(requestXMLBody);
        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 201) {
           // System.debug('The status code returned with order history endpoint: ' +
            //             response.getStatusCode() + ' ' + response.getStatus());
            //System.debug('Response body : '+response.getBody());
            addNodesToWrapperMap = SAPSoapRespXMLEnvelopeParser.xmlNodesParserFromOrderDetailsEndPoint(response.getBody());
            System.debug('Print =>addNodesToWrap '+addNodesToWrapperMap);
            orderDetailsLst = SAPSoapXml2POJOMapperCls.getOrdDetailsXMLNodesToWrapper(addNodesToWrapperMap);
            return orderDetailsLst;
        } else {
            return orderDetailsLst;
        }
    }
    
    
    /******************************************************************************************/
    /***************************************ShippingDetails***************************************/
    /******************************************************************************************/        
    //shipping details of the orders - this method will connect to sap hana endpoint using named credential basic authentication and get a specific order's shipping details info.
    //constructs xml envelope for request body.
   /* public static List<SAPSoapWrapperHub.SAPItemShippingWrapper> getShippingDetailsFromSAP(Map<String,String> orderReqMap){
        //initializations
        String endpoint_uri = 'SAP_SOAP_ShippingDetails_QA';
        Map<String, Object> addNodesToWrapperMap;
        List<SAPSoapWrapperHub.SAPItemShippingWrapper> orderDetailsLst;
        String requestXMLBody;
        //modify map to fetch respective order details
        orderReqMap = SAPSalesRepToolUtil.buildOrderDetailsReqMap(orderReqMap);
        //generate request xml body for sales rep lookup api
        requestXMLBody = SAPReqXMLEnvelopeGenerator.getReqXMLForShippingDetails(orderReqMap);
        //http post connection with soap envelope body
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:'+endpoint_uri);
        request.setMethod('POST');
        request.setBody(requestXMLBody);
        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned with order history endpoint: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
            System.debug('Response body : '+response.getBody());
            addNodesToWrapperMap = SAPSoapRespXMLEnvelopeParser.xmlNodesParserFromOrderDetailsEndPoint(response.getBody());
            System.debug('Print =>addNodesToWrap '+addNodesToWrapperMap);
            orderDetailsLst = SAPSoapXml2POJOMapperCls.getShippingDetXMLNodesToWrapper(addNodesToWrapperMap);
            return orderDetailsLst;
        } else {
            return orderDetailsLst;
        }
    }*/
    
}