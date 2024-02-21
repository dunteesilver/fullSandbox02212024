@isTest
public class SAPMockHttpSoapStubTest implements HttpCalloutMock {
       
        //flag to determine a server error
        private Boolean serverDown;
     
      //Setting flag in the constructor
        public SAPMockHttpSoapStubTest(Boolean serverDown){
            this.serverDown=serverDown;
        }
    public HTTPResponse respond(HTTPRequest req) {
        //Creating a fake response
        HttpResponse response=new HttpResponse();
        String responseXMLBody; 
       
        if(serverDown){
            //simulating fault response when SOAP server is down
             responseXMLBody='<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
                + '<soap:Body>'
                + '<soap:Fault>'
                + '<faultcode>SOAP-ENV:Server</faultcode>'
                + '<faultstring>Server Error</faultstring>'
                + '</soap:Fault>'
                + '</soap:Body>'
                + '</soap:Envelope>';
             response.setBody(responseXMLBody);
             response.setStatusCode(500);
             return response;
        }
        //mock response body
        else if(req.getEndpoint().contains('SAP_SOAP_SalesRepLookup')){
        responseXMLBody='<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
            +'<soap:Header/>'+
            +' <soap:Body>'+
            +'<n0:ZofI443SalesRepLookupResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style" xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">'+
            +'<EtMessage/>'+
            +'<EtSalesRepInfo>'+
            +'<item>'+
            +'<FirstName>Rob</FirstName>'+
            +'<LastName>Haffey</LastName>'+
            +'<Email>robert.haffey@teleflex.com</Email>'+
            +'<PhoneNumber>111-111-1111</PhoneNumber>'+
            +'<PhoneExt/>'+
            +'</item>'+
            +'</EtSalesRepInfo>'+
            +'</n0:ZofI443SalesRepLookupResponse>'+
            +'</soap:Body>'+
            +'</soap:Envelope>';
       
        } else if(req.getEndpoint().contains('SAP_SOAP_OrderHistory')){
            responseXMLBody='<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
            +'<soap:Header/>'+
            +'<soap:Body>'+
            +'<ns0:ZofI420OrderHistEcommResponse xmlns:ns0="urn:sap-com:document:sap:soap:functions:mc-style">'+
            +'<EtMessage/>'+
            +'<TOrdHist>'+
            +'<item>'+
            +'<Kunag>0000154368</Kunag>'+
            +'<Vbeln>9991380</Vbeln>'+
            +'<Bstkd>2101023148</Bstkd>'+
            +'<Audat>2023-03-20</Audat>'+
            +'<Status>Fully Shipped</Status>'+
            +'<Bname>Ryan Reichard</Bname>'+
            +'<Bsark>Fax</Bsark>'+
            +'<Auart>Standard Order</Auart>'+
            +'<Brtwr>31334.96</Brtwr>'+
            +'</item>'+
            +'<item>'+
            +'<Kunag>0000154368</Kunag>'+
            +'<Vbeln>10018104</Vbeln>'+
            +'<Bstkd>2101024289</Bstkd>'+
            +'<Audat>2023-03-27</Audat>'+
            +'<Status>In Progress</Status>'+
            +'<Bname/>'+
            +'<Bsark>EDI</Bsark>'+
            +'<Auart>Standard Order</Auart>'+
            +'<Brtwr>29339.03</Brtwr>'+
            +'</item>'+
            +'<item>'+
            +'<Kunag>0000154368</Kunag>'+
            +'<Vbeln>10004579</Vbeln>'+
            +'<Bstkd>2101023744</Bstkd>'+
            +'<Audat>2023-03-22</Audat>'+
            +'<Status>Fully Shipped</Status>'+
            +'<Bname/>'+
            +'<Bsark>EDI</Bsark>'+
            +'<Auart>Standard Order</Auart>'+
            +'<Brtwr>4626.72</Brtwr>'+
            +'</item>'+
            +'</TOrdHist>'+
            +'</ns0:ZofI420OrderHistEcommResponse>'+
            +'</soap:Body>'+
            +'</soap:Envelope>';
                   
        } else if(req.getEndpoint().contains('SAP_SOAP_OrderDetails')){
            responseXMLBody='<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
    + '<soap:Header/>'
    + '<soap:Body>'
    + '<n0:ZofI420OrderDetailsEcommResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'
    + '<EtMessage/>'
    + '<OrderDetails>'
    + '<Vbeln>9941204</Vbeln>'
    + '<Status>Fully Shipped</Status>'
    + '<DocType>ZOR</DocType>'
    + '<CanCancel/>'
    + '<PoNum>10511885</PoNum>'
    + '<PoDate>2023-03-06</PoDate>'
    + '<Orderer/>'
    + '<AccountNum>1014431</AccountNum>'
    + '<PoType>EDI</PoType>'
    + '<PromoCode/>'
    + '<Total>7890.00</Total>'
    + '<Waerk>USD</Waerk>'
    + '<BillTo>1014431</BillTo>'
    + '<Name1Bp>North Memorial Medical Center</Name1Bp>'
    + '<Name2Bp>Ambulance Service</Name2Bp>'
    + '<Street1Bp>4501 68th Avenue North SPRINT26</Street1Bp>'
    + '<CityBp>Brooklyn Center</CityBp>'
    + '<RegionBp>MN</RegionBp>'
    + '<PostlCodeBp>55429-1712</PostlCodeBp>'
    + '<ShipTo>1014431</ShipTo>'
    + '<Name1Sh>North Memorial Medical Center</Name1Sh>'
    + '<Name2Sh>Ambulance Service</Name2Sh>'
    + '<Street1Sh>4501 68th Avenue North SPRINT26</Street1Sh>'
    + '<CitySh>Brooklyn Center</CitySh>'
    + '<RegionSh>MN</RegionSh>'
    + '<PostlCodeSh>55429-1712</PostlCodeSh>'
    + '<InvoiceInd>X</InvoiceInd>'
    + '<ItemsList>'
    + '<item>'
    + '<Posnr>000010</Posnr>'
    + '<Matnr>9001-VC-005</Matnr>'
    + '<Maktx>EZ-IO 25MM NEEDLE (BOX OF 5)</Maktx>'
    + '<OrderQty>14.0</OrderQty>'
    + '<Uom>BX</Uom>'
    + '<Status>Shipped</Status>'
    + '<ShippedQty>14.0</ShippedQty>'
    + '<OpenQty>0.0</OpenQty>'
    + '</item>'
    + '<item>'
    + '<Posnr>000020</Posnr>'
    + '<Matnr>4150150</Matnr>'
    + '<Maktx>RUSCH POLARIS FO BLADE MAC 5</Maktx>'
    + '<OrderQty>2.0</OrderQty>'
    + '<Uom>BX</Uom>'
    + '<Status>Shipped</Status>'
    + '<ShippedQty>2.0</ShippedQty>'
    + '<OpenQty>0.0</OpenQty>'
    + '</item>'
    + '<item>'
    + '<Posnr>000030</Posnr>'
    + '<Matnr>77700</Matnr>'
    + '<Maktx>RUSCH DISPOLED SU FO HANDLE</Maktx>'
    + '<OrderQty>1.0</OrderQty>'
    + '<Uom>BX</Uom>'
    + '<Status>Shipped</Status>'
    + '<ShippedQty>1.0</ShippedQty>'
    + '<OpenQty>0.0</OpenQty>'
    + '</item>'
    + '</ItemsList>'
    + '</OrderDetails>'
    + '</n0:ZofI420OrderDetailsEcommResponse>'
    + '</soap:Body>'
    + '</soap:Envelope>';
                } 
        response.setBody(responseXMLBody);
        response.setStatusCode(200);
        return response;
    }
      
}