public class whatismyip {
    public string getIP(){
        string ipAddress;
        Map<String, String> mapHeaders = ApexPages.currentPage().getHeaders();
        system.debug('mapHeaders: ' + mapHeaders);
        if(mapHeaders != null){
            ipAddress = mapHeaders.get('True-Client-IP');
            if(ipAddress == null){
                ipAddress = mapHeaders.get('X-Salesforce-SIP');
            }
        }
        return ipAddress;
        
    }

}