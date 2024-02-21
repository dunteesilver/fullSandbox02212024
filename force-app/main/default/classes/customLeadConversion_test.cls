@istest
public class customLeadConversion_test {
    
    public static testMethod void customLeadConversionTest() {
        
        Quick_Disable__c cs = new Quick_Disable__c(
            Name = 'insertSAP',
            Enable__c = TRUE
        );
        System.debug('insert cs-->' + cs);
        insert cs;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            
            Account a = new account(
                Name = 'Test',
                SAP_Sold_To__c = '999999',
                BillingStreet = '123 Street',
                BillingCity = 'Raleigh',
                BillingState = 'NC',
                BillingPostalCode = '27614'
            );
            insert a;
            system.debug('a: '+ a);
            
            Account a2 = new account(
                Name = 'Test Acct2',
                SAP_Sold_To__c = '999998'
            );
            insert a2;
            system.debug('a2: '+ a2);
            
            Contact cont = new Contact(
                FirstName ='Test',
                email = 'abc@123.com',   
                lastname='test',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                AccountId = a.id
            );
            insert cont;
            system.debug('Cont: '+ cont);
            
            Contact c2 = new Contact(
                FirstName ='Test',
                email = 'abc@123.com',   
                lastname='second',
                Position_Job_Title__c='Administrator',
                Credentials__c='RN',
                Preferred_language__c='English (American)',
                AccountId = a2.id
            );
            insert c2;
            system.debug('c2: '+ c2);
            
            Opportunity opp = new Opportunity(
                Name=a.Name,
                Account=a,
                StageName='Target',
                Closedate=date.today() + 1,
                Primary_Contact__c=cont.id,
                Business_Unit_GPL__c='Anesthesia',
                Product_Family_GPL__c='Airway',
                Product_of_Interest_GPL__c='TruLite'
                //RecordTypeId = '01244000000NNcz'
            );
            insert Opp;
            system.debug('Opp: '+ Opp);
            
            Lead lead1 = new Lead(
                FirstName='trey',
                LastName='stone',
                Product_Family__c='test',
                Product_Of_Interest__c='test',
                Business_Unit__c='Surgical Disposables',
                Product_Family_GPL__c='Ligation',
                Product_of_Interest_GPL__c='Metal',
                Contact__c =c2.Id,
                Company='test'
            );
            insert lead1;
            system.debug('lead1: '+ lead1);
            
            lead1.Status = 'Qualified';
            update lead1;
            lead1.Account__c = a.Id;
            update lead1;
            
            
            Lead lead2 = new Lead(
                FirstName='trey',
                LastName='wood',
                Product_Family__c='test',
                Product_Of_Interest__c='test',
                Business_Unit__c='Surgical Disposables',
                Product_Family_GPL__c='Ligation',
                Product_of_Interest_GPL__c='Metal',
                Company='test',
                Contact__c =c2.Id,
                Account__c =a.Id,
                Existing_Opportunity__c=opp.Id
            );
            insert lead2;
            system.debug('lead2: '+ lead2);
            
            Lead lead3 = new Lead(
                FirstName='trey',
                LastName='smokey',
                Product_Family__c='test',
                Product_Of_Interest__c='test',
                Business_Unit__c='Surgical Disposables',
                Product_Family_GPL__c='Ligation',
                Product_of_Interest_GPL__c='Metal',
                Account__c =a.Id,
                Company='test',
                Contact__c =c2.Id,
                Existing_Opportunity__c=opp.Id
            );
            insert lead3;
            system.debug('lead3: '+ lead3);
            
            Account_Contact__c accCont= new Account_Contact__c (
                Account__c= a.Id,
                Contact__c= c2.Id
            );
            INSERT accCont;
            //Create a reference to the VF page
            //PageReference pageRef = Page.accountsRedirect;
            //Test.setCurrentPageReference(pageRef);
            // if you wanted to test an existing lead, use the line below (assuming your extension expects the ID param to be set)
            //ApexPages.currentPage().getParameters().put('id', lead.Id);
            
            // create an instance of your extension
            // this assumes a new Lead...
            //accountRedirect extension = new accountRedirect(new ApexPages.StandardController(new Lead()));
            // if you wanted to test an existing lead, use the line below...
            customLeadConversion extension = new customLeadConversion(new ApexPages.StandardController(lead1));
            customLeadConversion extension2 = new customLeadConversion(new ApexPages.StandardController(lead2));
            customLeadConversion extension3 = new customLeadConversion(new ApexPages.StandardController(lead3));
            
            extension.doConvert();
            extension2.doConvert();
            extension3.doConvert();
            
            // ... start calling methods to exercise your code ...
            
            // tear down objects created in the test        }
            
        }
    }
    
}