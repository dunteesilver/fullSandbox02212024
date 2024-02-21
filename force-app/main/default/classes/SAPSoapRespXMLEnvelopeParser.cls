/*********************************************************************
* Description      : Controller class for SAP Connection and Send/Receive xml responses.
* Test Class       : SAPSoapStubControllerTest.apxc
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
* Date         	   : 04/25/2023
* Work Item		   : W-025980
**********************************************************************/
public class SAPSoapRespXMLEnvelopeParser {
    public static Map<Integer, Map<String, String>> genericXmlNodesParserAllEndpoints(String xmlRespStr){
        Integer numOfItemsInt = 200;
        Map<Integer, Map<String, String>> sapSOAPRespEnvMap = new Map<Integer, Map<String, String>>();
        Dom.Document doc = new Dom.Document();  
        doc.load(xmlRespStr);  
        Dom.XMLNode rootElement = doc.getRootElement();  
        for ( Dom.XMLNode childElement : rootElement.getChildElements() ) {
            //root elements of each array
           // system.debug(childElement.getName() + '-' + childElement.getText());
            for (Dom.XMLNode detailElement : childElement.getChildElements()){
                //childs elements of each array
               // system.debug(detailElement.getName() + '-' + detailElement.getText());
                for (Dom.XMLNode detailElement1 : detailElement.getChildElements()){
                    Map<String, String> internalServerErrMap = new Map<String, String>();
                   // system.debug('one elements --->'+detailElement1.getName() + '-' + detailElement1.getText());
                    if(detailElement1.getName().equals('faultcode')){
                    internalServerErrMap.put(detailElement1.getName(), detailElement1.getText());
                    sapSOAPRespEnvMap.put(500, internalServerErrMap);
                    }
                    //childs elements of each childs array
                    //system.debug(detailElement1.getName() + '-' + detailElement1.getText());
                    for (Dom.XMLNode detailElement2 : detailElement1.getChildElements()){
                        Map<String, String> responseXMLElemMap = new Map<String, String>();
                        //childs elements of each childs array
                     //   system.debug(detailElement2.getName() + '-' + detailElement2.getText());
                        //check if node name is <item>
                        if(detailElement2.getName().equals('item')){
                            for (Dom.XMLNode detailElement3 : detailElement2.getChildElements()){
                                //childs elements of each childs array
                               // system.debug('three elements --->'+detailElement3.getName() + '-' + detailElement3.getText());
                                responseXMLElemMap.put(detailElement3.getName(), detailElement3.getText());
                                sapSOAPRespEnvMap.put(numOfItemsInt, responseXMLElemMap);
                            }
                        }
                        numOfItemsInt++;
                    }
                }
            } 
        }  
        return sapSOAPRespEnvMap;
    } 
    
    
    /******************************************************************************************/
    /**************************************Order and Shipping Details***************************************/
    //Parses XML string to extract order details and items list
    public static Map<String, Object> xmlNodesParserFromOrderDetailsEndPoint(String xmlRespStr){
        //to store Order Details
        Map<String, Object> orderDetailsMap= new Map<String, Object>();
        
        //List to hold items details maps
        List<Map<String, String>> itemList= new List<Map<String, String>>();
        
        //Loading XML from string
        Dom.Document doc =new Dom.Document();
        doc.load(xmlRespStr);
       //Get the root element
       Dom.XMLNode rootElement= doc.getRootElement();
        //Looping through the XML to the body
        for(Dom.XMLNode bodyNode:rootElement.getChildElements()){
            if('Body'.equalsIgnoreCase(bodyNode.getName())){
                DOM.XMLNode firstChild=bodyNode.getChildElements()[0];
                if('Fault'.equalsIgnoreCase(firstChild.getName())){
                    Map<String, String> faultDetailsMap=new Map<String, String>();
                     Dom.XMLNode faultStringNode = firstChild.getChildElement('faultstring', null);
                   // System.debug('faultStringNode '+faultStringNode); 
                    for(DOM.XMLNode faultDetail:firstChild.getChildElements()){
                       faultDetailsMap.put(faultDetail.getName(), faultDetail.getText());
                    //    System.debug('Fault details '+ faultDetailsMap);
                        if(faultStringNode!=null){
                           faultDetailsMap.put(faultStringNode.getName(), faultStringNode.getText());
                        }
                        orderDetailsMap.put('Fault', faultDetailsMap);
                            return  orderDetailsMap;
                    }
                } else{
                    //Processing order details
                    Map<String, String> orderDetails=new Map<String, String>();
                    for(Dom.XMLNode orderDetailsNode:firstChild.getChildElements()){
                        if('OrderDetails'.equalsIgnoreCase(orderDetailsNode.getName())){
                            
                           //Calling shipping method
                          // List<Map<String, Object>>  itemShippingLst=parseItemShippingDetails(orderDetailsNode);
                          // orderDetailsMap.put('ItemShipping',itemShippingLst);
                            for(DOM.XMLNode detailNode:orderDetailsNode.getChildElements()){
                                if(!'ItemsList'.equalsIgnoreCase(detailNode.getName())){
                                    orderDetails.put(detailNode.getName(), detailNode.getText());
                                } else{
                                    //Processing ItemsList
                                    for(DOM.XMLNode itemNode:detailNode.getChildElements()){
                                        Map<String, String> itemDetails= new Map<String, String>();
                                        for( DOM.XMLNode itemDetail:itemNode.getChildElements()){
                                            itemDetails.put(itemDetail.getName(), itemDetail.getText());
                                        }
                                        itemList.add(itemDetails);
                                    }
                                    
                                }
                            }
                        }
                    }
                    orderDetailsMap.put('OrderDetails',orderDetails);
                    if(!itemList.isEmpty()){
                         orderDetailsMap.put('Items', itemList);
                    }
                    
                }
                
            }
        }
        return orderDetailsMap;
    }
    
    //Method to parse ItemShipping details from XML response
   /* public static List<Map<String, Object>> parseItemShippingDetails(Dom.XMLNode orderDetailsNode){
        List<Map<String, Object>> itemShippingLst=new List<Map<String, Object>>();
        
        for(Dom.XMLNode itemShippingNode :orderDetailsNode.getChildElements()){
            if('ItemShipping'.equalsIgnoreCase(itemShippingNode.getName())){
                
                for(Dom.XMLNode shippingNode:itemShippingNode.getChildElements()){
                    Map<String, Object> shippingDetailsMap =new Map<String, Object>();
                    List<Map<String, String>> shippingDetailsLst=new List<Map<String, String>>();
                    for(Dom.XMLNode shippingDetail:shippingNode.getChildElements()){
                        if('ShippingDetails'.equalsIgnoreCase(shippingDetail.getName())){
                            
                            for (Dom.XMLNode shippingItem:shippingDetail.getChildElements()){
                                Map<String, String> shippingItemsInfo= new Map<String, String>();
                                
                                for(Dom.XMLNode detail:shippingItem.getChildElements()){
                                    shippingItemsInfo.put(detail.getName(), detail.getText());
                                    
                                }
                                System.debug('shippingItemsInfo size='+shippingItemsInfo.size());
                                shippingDetailsLst.add(shippingItemsInfo);
                                System.debug('shippingDetailsLst size'+ shippingDetailsLst.size());
                            }
                        } else{
                            shippingDetailsMap.put(shippingDetail.getName(), shippingDetail.getText());
                            
                        }
                    }
                    if(!shippingDetailsLst.isEmpty()){
                         shippingDetailsMap.put('Shipping Details', shippingDetailsLst);
                        
                    } itemShippingLst.add(shippingDetailsMap);
                    System.debug('shippingDetailsMap and size='+shippingDetailsMap.size()+' '+shippingDetailsMap);
                }
            }
        }
           return itemShippingLst;        
    }*/
  
    
    
}