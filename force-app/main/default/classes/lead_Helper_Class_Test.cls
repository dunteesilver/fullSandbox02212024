@istest
public class lead_Helper_Class_Test {
    public static testMethod void validate_ZuantLead(){
        
        
        Lead_Settings__c ldsettings =new Lead_Settings__c();
        ldsettings.LeadSource__c='EMS On24';
        ldsettings.LeadQuequeId__c='00G7V000004avUhUAI';
        ldsettings.Name='EMS On24';
        ldsettings.Business_Unit__c='EMS';
        insert ldsettings;
        
        Account accTest = new Account(
            Name = 'TestAccount',
            SAP_Sold_To__c = '102059',
            Account_Group__c = 'Z002',
            zBlock__c = '00'
        );
        insert accTest;
        
        Contact conTest = new Contact(
            FirstName ='Test',
            email = 'abc@123.com',   
            LastName = 'TestContact',
            Position_Job_Title__c='Administrator',
            Credentials__c='RN',
            Preferred_language__c='English (American)',
            
            AccountId = accTest.Id
        );
        insert conTest;
        
        Campaign c = New Campaign(
            Name = 'Zuant Test',
            Status = 'In Progress',
            IsActive = TRUE,
            Type = 'Lead Test'
        );
        insert c;
        
        Lead l = new lead(
            lastname = 'test',
            company = 'test',
            Status = 'Open'
         );
        insert l;
        
        CampaignMember cm = new CampaignMember(
            CampaignId = c.Id,
            LeadId = l.Id,
            Status = 'Responded'
        );
        insert cm;
        
        l.Campaign_External_Id__c = c.Id;
        update l;
        
        Lead l2 = new lead(
            lastname = 'test',
            company = 'test',
            Status = 'Open',
            Campaign_External_Id__c = c.Id
        );
        insert l2;
        master_TriggerHelperClass.runOnce('resetOnceSet');
        update l2;
        
        New_Product_Tracking__c  newNPT = new New_Product_Tracking__c(
            Name = 'EFx Shield',
            Business_Unit__c = 'Surgical',
            Start_Date__c = Date.today() - 90,
            End_Date__c = Date.today() + 90,
            New_Product_Key__c = 'Surgical-EFx Shield'
        );
        insert newNPT;
        
        New_Product_Tracking_Rule__c newNPTR = new New_Product_Tracking_Rule__c(
            Product__c = 'EFx Shield',
            Business_Unit__c = 'Surgical',
            Key__c = 'Surgical-EFx Shield',
            New_Product_Tracking__c = newNPT.Id
        );
        insert newNPTR;
        
        list<Opportunity> newOpps = new list<Opportunity>();
        Opportunity newOpp = new Opportunity(
            Name = 'Test Opp',
            Account = AccTest,
            CloseDate = Date.Today() + 90,
            Primary_Contact__c = ConTest.Id,
            StageName = 'Qualified Prospect',
            Amount = 1.00,
            Product_Family__c = 'Airway',
            Product_of_Interest__c = 'EFx Shield;T Shield',
            Business_Unit__c = 'Surgical'
        );
        newOpps.add(newOpp);
        //insert newOpp;
        //system.debug('newOpp: ' + newOpp);
        
        newOpp = new Opportunity(
            Name = 'Test Opp2',
            Account = AccTest,
            CloseDate = Date.Today() + 90,
            Primary_Contact__c = ConTest.Id,
            StageName = 'Qualified Prospect',
            Amount = 1.00,
            Product_Family__c = 'Airway',
            Product_of_Interest__c = 'No Shield',
            Business_Unit__c = 'Surgical',
            New_Product_Tracking__c = newNPT.Id
        );
        //master_TriggerHelperClass.runOnce('resetOnceSet');
        //insert newOpp2;
        //system.debug('newOpp: ' + newOpp2);
        newOpps.add(newOpp);
        insert newOpps;
        
        list<Lead> newLeads = new list<Lead>();
        l = new lead(
            lastname = 'test',
            company = 'test',
            Status = 'Open',
            Product_of_Interest__c = 'EFx Shield;T Shield',
            Business_Unit__c = 'Surgical'
        );
        newLeads.add(l);
        
        l = new lead(
            lastname = 'test',
            company = 'test',
            Status = 'Open',
            Product_of_Interest__c = 'T Shield',
            New_Product_Tracking__c = newNPT.Id,
            Business_Unit__c = 'Surgical'
        );
        newLeads.add(l);
        
        //test emsOn24Routing
        l = new lead(
            firstname = 'firstOn24',
            lastname = 'lastOn24',
            company = 'testOn24',
            Status = 'New',
            Contact_Local_Teleflex_Rep__c = 'No',
            LeadSource = 'EMS On24',
            Business_Unit__c = 'EMS'
        );
        newLeads.add(l);
        master_TriggerHelperClass.runOnce('resetOnceSet');
        insert newLeads;
        /*
lead newPTL = new lead(
lastname = 'test',
company = 'test',
Status = 'Open',
Business_Unit__c = 'Surgical'
);
insert newPTL;
newPTL.Product_of_Interest__c = 'T Shield';
newPTL.New_Product_Tracking__c = newNPT.Id;
master_TriggerHelperClass.runOnce('resetOnceSet');
update newPTL;*/
        
        
    }
    
}