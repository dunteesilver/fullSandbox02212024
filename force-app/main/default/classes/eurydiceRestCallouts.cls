public class eurydiceRestCallouts {

    public static void getUsers(){
        //prepare request
        HttpRequest request =new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('http://erp-ewedev1:8088/users');

        //set the Authorization header with bearer token
        String bearerToken='​iSxyJ2gc89CZ7h9AaLzuiLLpKc9vfQJ65Ges7vZEuPD3QLERa46cRWnuhTaJuNe6';
        request.setHeader('Authorization', 'Bearer '+bearerToken);
       // request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        

        //send the request over the internet
        Http http =new Http();
        HttpResponse response =http.send(request);
        System.debug('*** response *** '+response);
        //process the responce
        if(response.getStatusCode()==200){
            String jsonString=response.getBody();
            System.debug(jsonString);
        } else{
        System.debug('***printing status code*** '+response.getStatusCode()+': '+response.getStatus());
        }
    }

    public static void getCustomers(){

        //prepare request
        HttpRequest request =new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('http://erp-ewedev1:8088/customers');

        //set the Authorization header with bearer token
        String bearerToken='​iSxyJ2gc89CZ7h9AaLzuiLLpKc9vfQJ65Ges7vZEuPD3QLERa46cRWnuhTaJuNe6';
        request.setHeader('Authorization', 'Bearer '+bearerToken);
       // request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        

        //send the request over the internet
        Http http =new Http();
        HttpResponse response =http.send(request);
        System.debug('*** response *** '+response);
        //process the responce
        if(response.getStatusCode()==200){
            String jsonString=response.getBody();
            System.debug(jsonString);
        } else{
        System.debug('***printing status code*** '+response.getStatusCode()+': '+response.getStatus());
        }
    }
    }