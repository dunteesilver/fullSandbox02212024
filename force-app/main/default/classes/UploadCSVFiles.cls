public with sharing class UploadCSVFiles {
    
public static void setConnection(){
String hostUrl='10.49.1.106';
String userName='SFDC_User';
String password='uJhw$ch^2S9MZ7Nq';


HttpRequest request =new HttpRequest();

request.setEndpoint('http://'+hostUrl);
request.setMethod('POST');

Blob headerValue=Blob.valueOf(userName + ':' + password);
String authorizationHeader='BASIC '+EncodingUtil.base64Encode(headerValue);
request.setHeader('Content-Type', 'text/csv');
request.setHeader('Authorization', authorizationHeader);
String csvContent = 'Id,FirstName,LastName,Email\n0037V000034CZW5QAO,Tyler,Mason,tyler.mason@teleflex.com\n003Oy000008lT6pIAE,Gena,Chapman,gena.chapman@teleflex.com\n';
request.setBody(csvContent);

HttpResponse response =new Http().send(request);

System.debug('FTP Server Response: '+response.getBody());
System.debug('Request URL: ' + request.getEndpoint());
System.debug('Request Headers: ' + request.getHeader('Authorization'));
System.debug('Request Body: ' + request.getBody());

}


}