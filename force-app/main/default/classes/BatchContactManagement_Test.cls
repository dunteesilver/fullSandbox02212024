@isTest
public class BatchContactManagement_Test {
    
    static List<Account> testAcclst;
    static List<Contact> testConlst;
    static List<Contact> testConlstAcc;
    
    public static testMethod void TestcaseOne() { 
        
        testAcclst = loadAccount(10);
        insert testAcclst;
        
        testConlstAcc = createContactWithAccount(10,testAcclst);
        insert testConlstAcc;
        
        
        testConlst = createContactWithoutAccount(10);
        insert testConlst;
        
        
        BatchContactManagement b = new BatchContactManagement();
        Database.executeBatch(b);
        
        
    }
    
    public static testMethod void TestcaseTwo() { 
        
        testAcclst = loadAccount(10);
        insert testAcclst;
        
        testConlstAcc = createContactWithAccount(10,testAcclst);
        insert testConlstAcc;
        
        
        testConlst = createContactWithoutAccount(10);
        insert testConlst;
        
        findDuplicateContactsBatch b = new findDuplicateContactsBatch();
        Database.executeBatch(b);
        
        Duplicate_Contact__c dupRow = new Duplicate_Contact__c();
        dupRow.Contact__c = testConlstAcc[1].Id;
        dupRow.Account__c = testAcclst[1].Id;
        dupRow.Contact_Owner__c = userInfo.getUserId();
        insert dupRow;
        deleteDuplicateContactsBatch del = new deleteDuplicateContactsBatch();
        Database.executeBatch(del);
        
        
        
    }
    
    // Create a list of account records specified in the size...
    public static List<Account> loadAccount(Integer size){
        List<Account> accts = new List<Account> ();
        Id recId = Schema.SObjectType.Account.RecordTypeInfosByName.get('North American Customer').RecordTypeId;
        
        for(Integer i=0;i<size;i++){
            Account acc  = new Account(name='Test Account' + String.valueOf(i), Industry='Other', BillingCity='San Francisco', RecordTypeId = recId,
                                       BillingStreet='Ellis Street, CA', Website= 'www.domain.net');
            accts.add(acc);
        }
        return accts;
    }
    
    
    public static List<Contact> createContactWithAccount(Integer size, List<account> acclst){
        List<Contact> conts = new List<Contact> ();
        for(Integer i=0;i<size;i++){
            Contact con = New Contact(FirstName ='Test',
                                      email = 'abc@123.com',LastName = 'Test Contact', Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)',accountId = acclst[i].Id);
            conts.add(con);
        }
        Contact con = New Contact(FirstName ='Test1',
                                  email = 'abc@123.com',LastName = 'Test Contact', Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)',accountId = acclst[1].Id);
        return conts;    
    }
    
    public static List<Contact> createContactWithoutAccount(Integer size){
        List<Contact> conts = new List<Contact> ();
        for(Integer i=0;i<size;i++){
            Contact con = New Contact(FirstName ='Test',
                                      email = 'abc@123.com',LastName = 'Test Contact',Position_Job_Title__c='Administrator',
Credentials__c='RN',
Preferred_language__c='English (American)');
            conts.add(con);
        }
        return conts;    
    }
}