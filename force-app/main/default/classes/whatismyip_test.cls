@istest
public class whatismyip_test {

    static testMethod void testGetIP() {
        PageReference pageRefpre = new PageReference('/apex/whatismyip');
        system.debug('Price Quote Page' + pageRefpre);
        Test.setCurrentPage(pageRefpre);
             
        whatismyip myip = new whatismyip();
        myip.getIP();

    }    
    
}