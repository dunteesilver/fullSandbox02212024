/*********************************************************************
* Description      : Controller class for SAP Connection and Send/Receive xml responses.
* Test Class       : SAPSoapStubControllerTest.apxc
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
* Date         	   : 04/25/2023
* Work Item		   : W-025980
**********************************************************************/
public class SAPSoapWrapperHub {  
    //sales rep wrapper
    public class SAPSalesRepInfoWrapper
    {
        @AuraEnabled public String fname { get; set; }
        @AuraEnabled public String lname { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String phoneExt { get; set; }
        @AuraEnabled public String message { get; set; }
    } 
    //order history wrapper
    public class SAPOrderHistoryWrapper
    {
        @AuraEnabled public String sapcode { get; set; }
        @AuraEnabled public String vbeln { get; set; }
        @AuraEnabled public String bstkd { get; set; }
        @AuraEnabled public String audat { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String bname { get; set; }
        @AuraEnabled public String bsark { get; set; }
        @AuraEnabled public String auart { get; set; }
        @AuraEnabled public String brtwr { get; set; }
        @AuraEnabled public String message { get; set; }
    }
    
    //order details wrapper
    public class SAPOrderDetailsWrapper
    {
        @AuraEnabled public String vbeln { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String doctype { get; set; }
        @AuraEnabled public String ponum { get; set; }
        @AuraEnabled public String podate { get; set; }
        @AuraEnabled public String orderer {get;set;}
        @AuraEnabled public String accountnum { get; set; }
        @AuraEnabled public String potype { get; set; }
        @AuraEnabled public String total { get; set; }
        @AuraEnabled public String waerk { get; set; }
        @AuraEnabled public String billto { get; set; }
        @AuraEnabled public String name1bp { get; set; }
        @AuraEnabled public String name2bp { get; set; }
        @AuraEnabled public String street1bp { get; set; }
        @AuraEnabled public String citybp { get; set; }
        @AuraEnabled public String regionbp { get; set; }
        @AuraEnabled public String postlcodebp { get; set; }
        @AuraEnabled public String shipto { get; set; }
        @AuraEnabled public String name1sh { get; set; }
        @AuraEnabled public String name2sh { get; set; }
        @AuraEnabled public String street1sh { get; set; }
        @AuraEnabled public String citysh { get; set; }
        @AuraEnabled public String regionsh { get; set; }
        @AuraEnabled public String postlcodesh { get; set; }
        @AuraEnabled public String invoiceind { get; set; }
        @AuraEnabled public List<SAPOrderItemWrapper> items; //List to hold item details     
     
     //Constructor
    public SAPOrderDetailsWrapper(){
        this.items=new List<SAPOrderItemWrapper>();
    }
    }
    
    public class SAPOrderItemWrapper{
        @AuraEnabled public String posnr { get; set; }
        @AuraEnabled public String matnr { get; set; }
        @AuraEnabled public String maktx { get; set; }
        @AuraEnabled public String uom { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String orderqty { get; set; }
        @AuraEnabled public String shippedqty { get; set; }
        @AuraEnabled public String openqty { get; set; }
        
    }
    
    //order's item shipping details wrapper
   /* public class SAPItemShippingWrapper{
        @AuraEnabled public String vbeln { get; set; }
        @AuraEnabled public String posnr{ get; set; }
        @AuraEnabled public String matnr{ get; set; }
        @AuraEnabled public List<ShippingDetailsWrapper> shippingDetails { get; set; }
        
        //constr
        public SAPItemShippingWrapper(){
        this.shippingDetails=new List<ShippingDetailsWrapper>();
    }
        
    }
    public class ShippingDetailsWrapper
    {
        @AuraEnabled public String vbeln { get; set; }
        @AuraEnabled public String schedline { get; set; }
        @AuraEnabled public String matnr { get; set; }
        @AuraEnabled public String maktx { get; set; }
        @AuraEnabled public String quantity { get; set; }
        @AuraEnabled public String uom { get; set; }
        @AuraEnabled public String shipdate { get; set; }
        @AuraEnabled public String carrier { get; set; }
        @AuraEnabled public String trackingid { get; set; }
        @AuraEnabled public String trackingurl { get; set; }
        @AuraEnabled public String packinglist { get; set; }
    }   */ 
}