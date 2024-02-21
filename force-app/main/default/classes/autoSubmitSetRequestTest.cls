//Test class created by Dunte'e Silver
@isTest
public class autoSubmitSetRequestTest {   
    static testMethod void TestAutoSubmitSetRequest(){
          
        list<Account> acc = new list<Account>();
        for(integer i=0;i<10;i++){
            Account a = new Account(Name='Test'+i);
            acc.add(a);
        }
        insert acc;
        System.assertEquals(10,acc.size());
        
        //create new Product test records
        list<Product2> prods = new list<Product2>();
        for(integer a=0;a<10;a++){
            Product2 p = new Product2();
            p.Name = 'test product ' + a;
            p.IsActive = true;
            p.National_Pool__c = true;
            p.Family = 'Other';
            prods.add(p);
        }
        insert prods;
        System.assertEquals(10, prods.size());
        
        //create National Pool Set test records
		list<National_Pool_Set__c> nps = new list<National_Pool_Set__c>();
        for(integer b=0;b<10;b++){
            National_Pool_Set__c n = new National_Pool_Set__c();
            n.Status__c = 'Available';
            n.Product__c = prods[b].Id;
            n.Name = 'NPS ' + b;
            n.Lot_Number__c = 'Lot 0' + b;
            nps.add(n);
        }
        insert nps;
        system.assertEquals(10, nps.size());
        
        //create Set Request test records
        list<Set_Request__c> reqs = new list<Set_Request__c>();
        for(integer j = 0;j<10;j++){
            Set_Request__c s = new Set_Request__c();
            s.Status__c='Pending Return';
            s.Account__c = acc[j].Id;
			s.National_Pool_Set__c = nps[j].Id;
            s.Did_this_result_in_a_sale__c = 'Yes';
            s.Status__c = 'Pending Return';
            reqs.add(s);
        }
        insert reqs;
        System.assertEquals(10,reqs.size());
        
        //update Set Request to Pending
        for(Set_Request__c curr : reqs){
            curr.Status__c = 'Pending';
        }
        update reqs;       

        //update Set Request to Fulfilled
        for(Set_Request__c curr : reqs){
            curr.Status__c = 'Fulfilled';
        }
        update reqs;
        
        //update Set Request to Pending Return
        for(Set_Request__c curr : reqs){
            curr.Status__c = 'Pending Return';
        }
        update reqs;        

        //update Set Request to Returned
        for(Set_Request__c curr : reqs){
            curr.Status__c = 'Returned';
        }
        update reqs;
        
        //create Set Request test records
        list<Set_Request__c> reqs3 = new list<Set_Request__c>();
        for(integer k = 0;k<10;k++){
            Set_Request__c s = new Set_Request__c();
            s.Status__c='Pending';
            s.Account__c = acc[k].Id;
			s.National_Pool_Set__c = nps[k].Id;            
            reqs3.add(s);
        }
        
        //insert new Set Request
        insert reqs3;
        system.assertEquals(10,reqs3.size());
        
        //test for parent record update to Available
        for(Set_Request__c curr : reqs3){
            curr.Status__c = 'Denied';
        }
        
        update reqs3;           
    }

}