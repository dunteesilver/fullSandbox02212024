/*********************************************************************
* Description      : mapping of response xml nodes to respective pojo classes.
* Test Class       : SAPSoapStubControllerTest.apxc
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
* Date         	   : 04/25/2023
* Work Item		   : W-025980
**********************************************************************/
public class SAPSoapXml2POJOMapperCls {
    //sales rep wrapper
    public static List<SAPSoapWrapperHub.SAPSalesRepInfoWrapper> getSalesRepXMLNodesToWrapper(Map<Integer, Map<String,String>> respItemsMap){
        Map<String,String> nodesMap = new Map<String,String>();
        List<SAPSoapWrapperHub.SAPSalesRepInfoWrapper> salesrepinfoLst = new List<SAPSoapWrapperHub.SAPSalesRepInfoWrapper>();
        for (Integer item : respItemsMap.keySet()) {
            SAPSoapWrapperHub.SAPSalesRepInfoWrapper salesRepInfoWrapperObj = new SAPSoapWrapperHub.SAPSalesRepInfoWrapper();
            nodesMap = respItemsMap.get(item);
            for(String nodeName : nodesMap.keySet()){
                if(nodeName == 'FirstName')salesRepInfoWrapperObj.fname = nodesMap.get(nodeName);
                if(nodeName == 'LastName')salesRepInfoWrapperObj.lname = nodesMap.get(nodeName);
                if(nodeName == 'Email')salesRepInfoWrapperObj.email = nodesMap.get(nodeName);
                if(nodeName == 'PhoneNumber')salesRepInfoWrapperObj.phone = nodesMap.get(nodeName);
                if(nodeName == 'PhoneExt')salesRepInfoWrapperObj.phoneExt = nodesMap.get(nodeName);
                if(nodeName == 'Message')salesRepInfoWrapperObj.message = nodesMap.get(nodeName);
                if(nodeName == 'faultcode')salesRepInfoWrapperObj.message = nodesMap.get(nodeName);
            }
            salesrepinfoLst.add(salesRepInfoWrapperObj);
        }
        return salesrepinfoLst;
    }
    //order history wrapper
    public static List<SAPSoapWrapperHub.SAPOrderHistoryWrapper> getOrdHistXMLNodesToWrapper(Map<Integer, Map<String,String>> respItemsMap){
        Map<String,String> nodesMap = new Map<String,String>();
        List<SAPSoapWrapperHub.SAPOrderHistoryWrapper> orderhistoryLst = new List<SAPSoapWrapperHub.SAPOrderHistoryWrapper>();
        for (Integer item : respItemsMap.keySet()) {
            SAPSoapWrapperHub.SAPOrderHistoryWrapper ordHistWrapperObj = new SAPSoapWrapperHub.SAPOrderHistoryWrapper();
            nodesMap = respItemsMap.get(item);
            for(String nodeName : nodesMap.keySet()){
                if(nodeName == 'Kunag')ordHistWrapperObj.sapcode = nodesMap.get(nodeName);
                if(nodeName == 'Vbeln')ordHistWrapperObj.vbeln = nodesMap.get(nodeName);
                if(nodeName == 'Bstkd')ordHistWrapperObj.bstkd = nodesMap.get(nodeName);
                if(nodeName == 'Audat')ordHistWrapperObj.audat = nodesMap.get(nodeName);
                if(nodeName == 'Status')ordHistWrapperObj.status = nodesMap.get(nodeName);
                if(nodeName == 'Bname')ordHistWrapperObj.bname = nodesMap.get(nodeName);
                if(nodeName == 'Bsark')ordHistWrapperObj.bsark = nodesMap.get(nodeName);
                if(nodeName == 'Auart')ordHistWrapperObj.auart = nodesMap.get(nodeName);
                if(nodeName == 'Brtwr')ordHistWrapperObj.brtwr = nodesMap.get(nodeName);
                if(nodeName == 'Message')ordHistWrapperObj.message = nodesMap.get(nodeName);
            }
            orderhistoryLst.add(ordHistWrapperObj);
        }
        return orderhistoryLst;
    }
    
    //order details wrapper
    public static List<SAPSoapWrapperHub.SAPOrderDetailsWrapper> getOrdDetailsXMLNodesToWrapper(Map<String, Object> respItemsMap){
         List<SAPSoapWrapperHub.SAPOrderDetailsWrapper> orderDetailsLst = new List<SAPSoapWrapperHub.SAPOrderDetailsWrapper>();
         SAPSoapWrapperHub.SAPOrderDetailsWrapper orderWrapper = new SAPSoapWrapperHub.SAPOrderDetailsWrapper();
        //Checking for SOAP Fault error
        if(respItemsMap.containsKey('Fault')){
            Map<String, String> faultDetails=(Map<String, String>) respItemsMap.get('Fault');
            System.debug('SOAP Fault is returned ::: '+faultDetails);
            return orderDetailsLst;
        }
         
         Map<String, String> orderDetails =(Map<String, String>)respItemsMap.get('OrderDetails');
        System.debug('Printing orderDetails '+orderDetails);
        if(orderDetails !=null){
            //mapping each property of the wrapper
            orderWrapper.vbeln=orderDetails.get('Vbeln');
            orderWrapper.status=orderDetails.get('Status');
            orderWrapper.doctype=orderDetails.get('DocType');
            orderWrapper.ponum=orderDetails.get('PoNum');
            orderWrapper.podate=orderDetails.get('PoDate');
            orderWrapper.orderer=orderDetails.get('Orderer');
            orderWrapper.accountnum=orderDetails.get('AccountNum');
            orderWrapper.potype=orderDetails.get('PoType');
            orderWrapper.total=orderDetails.get('Total');
            orderWrapper.waerk=orderDetails.get('Waerk');            
            orderWrapper.billto=orderDetails.get('BillTo');
            orderWrapper.name1bp=orderDetails.get('Name1Bp');
            orderWrapper.name2bp=orderDetails.get('Name2Bp');
            orderWrapper.street1bp=orderDetails.get('Street1Bp');
            orderWrapper.citybp=orderDetails.get('CityBp');
            orderWrapper.regionbp=orderDetails.get('RegionBp');
            orderWrapper.postlcodebp=orderDetails.get('PostlCodeBp');
            orderWrapper.shipto=orderDetails.get('ShipTo');
            orderWrapper.name1sh=orderDetails.get('Name1Sh');
            orderWrapper.name2sh=orderDetails.get('Name2Sh');
            orderWrapper.street1sh=orderDetails.get('Street1Sh');
            orderWrapper.citySh=orderDetails.get('CitySh');
            orderWrapper.regionsh=orderDetails.get('RegionSh');
            orderWrapper.postlcodesh=orderDetails.get('PostlCodeSh');
            orderWrapper.invoiceind=orderDetails.get('InvoiceInd');
            
        }
        
        List<Map<String, String>> itemLst =(List<Map<String, String>>)respItemsMap.get('Items');
        if(itemLst!=null){
            for(Map<String, String> itemDetails:itemLst){
                SAPSoapWrapperHub.SAPOrderItemWrapper itemWrapper =new SAPSoapWrapperHub.SAPOrderItemWrapper();
                itemWrapper.posnr=itemDetails.get('Posnr');
                itemWrapper.maktx=itemDetails.get('Maktx');
                itemWrapper.matnr=itemDetails.get('Matnr');
                itemWrapper.orderqty=itemDetails.get('OrderQty');
                itemWrapper.uom=itemDetails.get('Uom');
                itemWrapper.status=itemDetails.get('Status');
                itemWrapper.shippedqty=itemDetails.get('ShippedQty');
                itemWrapper.openqty=itemDetails.get('OpenQty');
                orderWrapper.items.add(itemWrapper);
                
            }
        }
        orderDetailsLst.add(orderWrapper);
        return orderDetailsLst;
       
    }
    //shipping details wrapper
    /*public static List<SAPSoapWrapperHub.SAPItemShippingWrapper> getShippingDetXMLNodesToWrapper(Map<String, Object> respItemsMap){
         List<SAPSoapWrapperHub.SAPItemShippingWrapper> shippingDetailsLst = new List<SAPSoapWrapperHub.SAPItemShippingWrapper>();
          //Checking for SOAP Fault error
        if(respItemsMap.containsKey('Fault')){
            Map<String, String> faultDetails=(Map<String, String>) respItemsMap.get('Fault');
            System.debug('SOAP Fault is returned ::: '+faultDetails);
            return shippingDetailsLst;
        }
         
         Map<String, String> shippedItemList =(Map<String, String>)respItemsMap.get('ItemShipping');
        System.debug('Printing ItemShipping '+shippedItemList);
        if(shippedItemList !=null){
        }  
        return shippingDetailsLst;
      
}*/
}