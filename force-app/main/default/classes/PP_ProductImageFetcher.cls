/*********************************************************************
* Description      : Callout Class to fetch Product Images from TFX Catalog.
* Test Class       : PP_ProductExternalTool_Test
* Author(s)        : Dun Silver
**********************************************************************/
global class PP_ProductImageFetcher {
    
    public ImageWrapper img{get;set;}
    
    public class ImageWrapper {
        //class to handle JSON
        //public String name {get;set;} //handle JSON field
        //public String prodId {get;set;}
        //public String prodCode {get;set;}
        //public String prodDesc {get;set;}
        public List<images> images{get;set;} //handle JSON array
    }
    
    public class images{
        public String format{get;set;}
        public List<String> urls{get;set;}
    }//end of images inner class
    
    @future(callout=true)
    public static void UpdateProductImageBatchFuture(List<Id> productIds){
        //UpdateProductImageBatch(productIds);
        UpdateProductImageBatchNew(productIds);
    }
    
    /* Siva Nov. 20, 2018 Commenting the static approach as new dynamic approach based on custom setting 
has been implemented below in UpdateProductImageBatchNew()

//webservice allows for javascript callout using "update image" button on Product
webservice static void UpdateProductImageBatch(List<Id> productIds){
List<Product2> updProds = new List<Product2>();
List<Product2> prds = [Select Id,Name, Brand_Name__c,Image_URL__c, SBU__c, Sales_Org__c,
Group__c, Low_Res_Image__c, Hi_Res_Image__c from Product2 where Id in:productIds];
string endPoint = 'https://www.teleflexsurgicalcatalog.com/';
string ImgURL;         
string lowResImgURL;
string hiResImgURL;                                                          

//Instantiate a new HTTP request
HTTP h = new HTTP();                     

for(Product2 p : prds)
{
system.debug('Product: ' + p.Name + ' Sales Org: ' + p.Sales_Org__c);
HttpRequest req = new HttpRequest();
if(p.SBU__c == 'Anesthesia'){

endPoint = 'https://www.teleflexarcatalog.com/';

//Regional Anesthesia is group "Pain"           
if(p.Group__c == 'Regional Anesthesia'){
System.debug('*** SBU = Anesthesia, Group Regional Anesthesia ***');
endpoint = endpoint+'anesthesia-respiratory/pain/products/'+p.name+'/images';
System.debug('*** endpoint *** ' + endpoint);
req.setEndpoint(endPoint);
endPoint = 'https://www.teleflexarcatalog.com/';
}
else if(p.Group__c == 'Airway'){ //Airway is group "Airway"
System.debug('*** SBU = Anesthesia, Group Airway ***');
endpoint = endpoint+'anesthesia-respiratory/airway/products/'+p.name+'/images';
System.debug('*** endpoint *** ' + endpoint);
req.setEndpoint(endPoint);
endPoint = 'https://www.teleflexarcatalog.com/';
}
else if(p.Group__c != 'Airway' || p.Group__c != 'Pain'){ //respiratory is group "All Other Groups under SBU"
System.debug('*** SBU = Anesthesia, Group NOT Airway OR Pain ***');
system.debug('In not airway or pain');
endpoint = endpoint+'anesthesia-respiratory/respiratory/products/'+p.name+'/images';
System.debug('*** endpoint *** ' + endpoint);
req.setEndpoint(endPoint);
endPoint = 'https://www.teleflexarcatalog.com/';
}

}//end Anesthesia if
else{
if(p.brand_name__c == 'Pilling'){
System.debug('*** PILLING BRAND NAME ***');
endpoint = endpoint+'surgical/pilling/products/'+p.name+'/images';
System.debug('*** endpoint *** ' + endpoint);
req.setEndpoint(endPoint);
endPoint = 'https://www.teleflexarcatalog.com/';
}
else if(p.brand_name__c == 'Weck'){
System.debug('*** WECK BRAND NAME ***');
endpoint = endpoint+'surgical/weck/products/'+p.name+'/images';
System.debug('*** endpoint *** ' + endpoint);
//endpoint = 'http://www.teleflexsurgicalcatalog.com/surgical/weck/products/'+p.name+'/images';
req.setEndpoint(endPoint);
endPoint = 'https://www.teleflexarcatalog.com/';
}
else if(p.brand_name__c == 'Airway'){
System.debug('*** AIRWAY BRAND NAME ***');
endpoint = endpoint+'anesthesia-respiratory/airway/products/'+p.name+'/images';
System.debug('*** endpoint *** ' + endpoint);
//endpoint = 'http://www.teleflexsurgicalcatalog.com/anesthesia-respiratory/airway/products/'+p.name+'/images';
req.setEndpoint(endPoint);
endPoint = 'https://www.teleflexarcatalog.com/';
}
else if(p.brand_name__c == 'Rusch'){
System.debug('*** RUSCH BRAND NAME ***');
endpoint = endpoint+'anesthesia-respiratory/pain/products/'+p.name+'/images';
System.debug('*** endpoint *** ' + endpoint);
//endpoint = 'http://www.teleflexsurgicalcatalog.com/anesthesia-respiratory/airway/products/'+p.name+'/images';
req.setEndpoint(endPoint);
endPoint = 'https://www.teleflexarcatalog.com/';
}
else if(p.brand_name__c != 'Pilling' && p.brand_name__c != 'Weck' &&
p.brand_name__c != 'Airway' && p.Brand_Name__c != 'Rusch'){
System.debug('*** NOT PILLING, WECK, OR AIRWAY BRAND NAME ***');
//set a generic endpoint
endpoint = 'https://www.teleflexsurgicalcatalog.com/surgical/rusch/pain/products/';
System.debug('*** endpoint *** ' + endpoint);
//endpoint = 'http://www.teleflexsurgicalcatalog.com/anesthesia-respiratory/airway/products/'+p.name+'/images';
//specify endpoint as request
req.setEndpoint(endPoint);
endPoint = 'https://www.teleflexarcatalog.com/';
}
}//end else

system.debug('endPoint =====================' + endPoint);
//specify the method (GET)
req.setMethod('GET');

// Send the request, and return a response
HttpResponse res = h.send(req);

//Logic to handle invalid endpoints
if(endpoint != null && endpoint != ''){
//status code success from 200 to 299
system.debug('In If Endpoint Logic !!!!!!!!!!!!!!');
if(res.getStatusCode() >= 200 && res.getStatusCode() < 300){ //status code check
//string to hold response info
system.debug('if(res.getStatusCode() >= 200 !!!!!!!!!!!!!!');
string imageJSON = res.getBody();
string status = res.getStatus();
system.debug('imageJSON=====================' + imageJSON);
system.debug('status=====================' + status);
JSONParser parser = JSON.createParser(imageJSON); //create JSON parser

if(imageJSON.containsIgnoreCase('image')){
system.debug('*** HAS imageJSON ***');
while (parser.nextToken() != null) {
//system.debug('In While parser.nextToken !!!!!!!!!!!!!!');
if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
// Read entire JSON object, including its array of items.
String urlString;
ImageWrapper img = (ImageWrapper)JSON.deserialize(imageJSON, ImageWrapper.class);
System.debug('*** img *** ' + img);

//System.debug('*** img.images *** ' + img.images);
for(Integer i = 0; i < img.images.size(); i++){
if(img.images[i].format == 'hi-res'){
if(img.images[i].urls != null && img.images[i].urls.size() > 0){
urlString = img.images[i].urls[0];
p.Hi_Res_Image__c = urlString.replace('http','https');
System.debug('*** p.Hi_Res_Image__c *** ' + p.Hi_Res_Image__c);
}
else{
p.Hi_Res_Image__c = '';
}
}//end of if

if(img.images[i].format == 'thumb'){
if(img.images[i].urls != null && img.images[i].urls.size() > 0){
urlString = img.images[i].urls[0];
p.Image_URL__c = urlString.replace('http','https');
System.debug('*** p.Image_URL__c *** ' + p.Image_URL__c);
}
else{
p.Image_URL__c = '';
}
}//end of if

if(img.images[i].format == 'listing'){
if(img.images[i].urls != null && img.images[i].urls.size() > 0){
urlString = img.images[i].urls[0];
p.Low_Res_Image__c = urlString.replace('http','https');
System.debug('*** p.Low_Res_Image__c *** ' + p.Low_Res_Image__c);
}
else{
p.Low_Res_Image__c = '';
}
}//end of if

}//end of for loop

}//end of if

}//end of while parser

}//if check for imageJSON
else{
p.Image_URL__c = '';
p.Low_Res_Image__c = '';
p.Hi_Res_Image__c = '';
}
}//end of if(res.getStatus....)

updProds.add(p);//add products to list to update

}//end of if(endpoint...)

//end of endpoint logic

}//end of for loop

if(updProds.size() > 0 ){
Database.update(updProds,false); //update products
}
}
//end of webservice method

*/
    
    /*Siva Nov. 20, 2018 Dynmaic approach based on custom setting */
    //webservice allows for javascript callout using "update image" button on Product
    webservice static void UpdateProductImageBatchNew(List<Id> productIds){
        List<Product2> updProds = new List<Product2>();
        List<Product2> prds = [Select Id,Name, Brand_Name__c,Image_URL__c, SBU__c, Sales_Org__c,
                               Group__c, Low_Res_Image__c, Hi_Res_Image__c from Product2 where Id in:productIds];
        string endPoint = 'https://www.teleflexsurgicalcatalog.com/';
        string ImgURL;         
        string lowResImgURL;
        string hiResImgURL;                                                          
        
        //Instantiate a new HTTP request
        HTTP h = new HTTP();
        //To hold unique set of SBUs available in ProductImageUrls__c custom setting
        Set<string> SBUs = new Set<string>();
        //To hold Groups available for each SBUs in ProductImageUrls__c custom setting
        Map<string, string> SBUGroups = new Map<string, string>();
        //To hold URL suffix available for each SBUs & its Group in ProductImageUrls__c custom setting
        Map<string, string> SBUGroupUrlMap = new Map<string, string>();
        //To hold URL suffix available for each BrandName in ProductImageUrls__c custom setting
        Map<string, string> BrandUrlMap = new Map<string, string>();
        //Default URL
        string DefaultUrl;
        
        //Fetch the custom setting data
        List<ProductImageUrls__c> urlData = ProductImageUrls__c.getall().values();
        
        //Iterating over the custom settings to fill our collections
        for(ProductImageUrls__c urlInfo: urlData){
            
            if(urlInfo.SBU__c != null){
                SBUs.add(urlInfo.SBU__c);
                SBUGroups.put(urlInfo.SBU__c, urlInfo.Group__c);
                SBUGroupUrlMap.put(urlInfo.SBU__c+'|'+urlInfo.Group__c, urlInfo.EndpointSuffix__c);
            }
            else if(urlInfo.BrandName__c != null){
                BrandUrlMap.put(urlInfo.BrandName__c , urlInfo.EndpointSuffix__c);
            }
            else if(urlInfo.Name == 'Default'){
                DefaultUrl = urlInfo.EndpointSuffix__c;
            }
        }
        for(Product2 p : prds)
        {
            system.debug('Product: ' + p.Name + ' Sales Org: ' + p.Sales_Org__c);
            HttpRequest req = new HttpRequest();
            endPoint = 'https://www.teleflexarcatalog.com/';
            if(p.SBU__c != null && SBUs.contains(p.SBU__c)){
                if(p.Group__c != null && SBUGroups.get(p.SBU__c).contains(p.Group__c) && SBUGroupUrlMap.containsKey(p.SBU__c+'|'+p.Group__c)){
                    string endpointSuffix = SBUGroupUrlMap.get(p.SBU__c+'|'+p.Group__c);
                    System.debug('*** SBU = '+p.SBU__c+', Group = '+p.Group__c+', UrlSuffix = '+endpointSuffix+' ***');
                    PP_ProductImageFetcher.SetReqEndPoint(req,p.name,endpointSuffix);
                    endPoint = 'https://www.teleflexarcatalog.com/';
                }
                else{
                    string endpointSuffix = SBUGroupUrlMap.get(p.SBU__c+'|'+null);
                    System.debug('*** SBU = '+p.SBU__c+', Group = '+p.Group__c+', UrlSuffix = '+endpointSuffix+' ***');
                    PP_ProductImageFetcher.SetReqEndPoint(req,p.name,endpointSuffix);
                    endPoint = 'https://www.teleflexarcatalog.com/';
                }
            }
            else if(p.brand_name__c != null && BrandUrlMap.containsKey(p.brand_name__c)){
                string endpointSuffix = BrandUrlMap.get(p.brand_name__c);
                System.debug('*** Brand = '+p.brand_name__c+', UrlSuffix = '+endpointSuffix+' ***');
                PP_ProductImageFetcher.SetReqEndPoint(req,p.name,endpointSuffix);
                endPoint = 'https://www.teleflexarcatalog.com/';
            }
            else{
                System.debug('*** Default Case, UrlSuffix = '+DefaultUrl+' ***');
                PP_ProductImageFetcher.SetReqEndPoint(req,p.name,DefaultUrl);
                endPoint = 'https://www.teleflexarcatalog.com/';
            }
            
            system.debug('endPoint =====================' + endPoint);
            //specify the method (GET)
            req.setMethod('GET');
            
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            
            //Logic to handle invalid endpoints
            if(endpoint != null && endpoint != ''){
                //status code success from 200 to 299
                system.debug('In If Endpoint Logic !!!!!!!!!!!!!!');
                if(res.getStatusCode() >= 200 && res.getStatusCode() < 300){ //status code check
                    //string to hold response info
                    system.debug('if(res.getStatusCode() >= 200 !!!!!!!!!!!!!!');
                    string imageJSON = res.getBody();
                    string status = res.getStatus();
                    system.debug('imageJSON=====================' + imageJSON);
                    system.debug('status=====================' + status);
                    JSONParser parser = JSON.createParser(imageJSON); //create JSON parser
                    
                    if(imageJSON.containsIgnoreCase('image')){
                        system.debug('*** HAS imageJSON ***');
                        while (parser.nextToken() != null) {
                            //system.debug('In While parser.nextToken !!!!!!!!!!!!!!');
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                // Read entire JSON object, including its array of items.
                                String urlString;
                                ImageWrapper img = (ImageWrapper)JSON.deserialize(imageJSON, ImageWrapper.class);
                                System.debug('*** img *** ' + img);
                                
                                //System.debug('*** img.images *** ' + img.images);
                                for(Integer i = 0; i < img.images.size(); i++){
                                    if(img.images[i].format == 'hi-res'){
                                        if(img.images[i].urls != null && img.images[i].urls.size() > 0){
                                            urlString = img.images[i].urls[0];
                                            p.Hi_Res_Image__c = urlString.replace('http','https');
                                            System.debug('*** p.Hi_Res_Image__c *** ' + p.Hi_Res_Image__c);
                                        }
                                        else{
                                            p.Hi_Res_Image__c = '';
                                        }
                                    }//end of if
                                    
                                    if(img.images[i].format == 'thumb'){
                                        if(img.images[i].urls != null && img.images[i].urls.size() > 0){
                                            urlString = img.images[i].urls[0];
                                            p.Image_URL__c = urlString.replace('http','https');
                                            System.debug('*** p.Image_URL__c *** ' + p.Image_URL__c);
                                        }
                                        else{
                                            p.Image_URL__c = '';
                                        }
                                    }//end of if
                                    
                                    if(img.images[i].format == 'listing'){
                                        if(img.images[i].urls != null && img.images[i].urls.size() > 0){
                                            urlString = img.images[i].urls[0];
                                            p.Low_Res_Image__c = urlString.replace('http','https');
                                            System.debug('*** p.Low_Res_Image__c *** ' + p.Low_Res_Image__c);
                                        }
                                        else{
                                            p.Low_Res_Image__c = '';
                                        }
                                    }//end of if
                                    
                                }//end of for loop
                                
                            }//end of if
                            
                        }//end of while parser
                        
                    }//if check for imageJSON
                    else{
                        System.debug('*** ERASING PRODUCT IMAGE FIELDS ***');
                        p.Image_URL__c = '';
                        p.Low_Res_Image__c = '';
                        p.Hi_Res_Image__c = '';
                    }
                }//end of if(res.getStatus....)
                
                updProds.add(p);//add products to list to update
                
            }//end of if(endpoint...)
            
            //end of endpoint logic
            
        }//end of for loop
        
        if(updProds.size() > 0 ){
            System.debug('*** UPDATING PRODUCT IMAGE FIELDS ***');
            System.debug('*** updProds *** ' + updProds);
            Database.update(updProds,false); //update products
        }
    }//end of webservice method
    
    public static Void SetReqEndPoint(HttpRequest req, String productName, string url){
        string endPoint = 'https://www.teleflexarcatalog.com/';
        endpoint = endpoint+string.format(url, new List<String> {productName});
        System.debug('*** endpoint *** ' + endpoint);
        req.setEndpoint(endPoint);
    }
}