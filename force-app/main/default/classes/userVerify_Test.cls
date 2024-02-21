@istest
public class userVerify_Test {
    static testMethod void testUserLookup() {
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'uflex76',
            email='unit.test@unit.teleflex.com',
            emailencodingkey='UTF-8',
            firstname='Adam',
            lastname='Franks',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p.Id,
            timezonesidkey='Europe/London',
            username='unit.test@unit.teleflex.com'
        );
        insert u;
        
        PageReference pageRefpre = new PageReference('/apex/userVerify');
        system.debug('Price Quote Page' + pageRefpre);
        Test.setCurrentPage(pageRefpre);
        
        //System.currentPageReference().getParameters().put('searchStr', 'unit.test@unit.teleflex.com');
        
        userVerify uv = new userVerify();
        uv.searchStr = 'unit.test@unit.teleflex.com';
        uv.userCheck();
    }

}