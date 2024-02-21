@isTest
private class oppProbabilityTriggerTest {
/*
    static testMethod void testoppProbability(){

        Account a = new Account(Name='Test Account ');
        insert a;

        Contact c = new Contact(
            LastName = 'Test',
            AccountId = a.Id
        );
        insert c;

        Id Anesthesia_ID = [select id from RecordType where Name = 'Anesthesia Opportunity' LIMIT 1].id;

        Opportunity o = new Opportunity(
            Name = 'test',
            AccountId = a.Id,
            RecordTypeId = Anesthesia_ID,
            StageName = 'Qualified Prospect',
            Amount = 1,
            Primary_Contact__c = c.id,
            CloseDate = system.today() + 90,
            Product_Family__c = 'Airway',
            Product_Of_Interest__c = 'DispoLED'
        );
        system.debug('Record ID' + Anesthesia_ID);
        insert o;

        o.Product_Of_Interest__c = 'Spinals';
        update o;

        o.Product_Of_Interest__c = 'DispoLED,Spinals';
        update o;

        Id Surgical_ID = [select id from RecordType where Name = 'Surgical Sales Opportunity' LIMIT 1].id;

        Opportunity o2 = new Opportunity(
            Name = 'test2',
            AccountId = a.Id,
            RecordTypeId = Surgical_ID,
            StageName = 'Qualified Prospect',
            Amount = 1,
            Primary_Contact__c = c.id,
            CloseDate = system.today() + 90,
            Product_Family__c = 'Instruments',
            Product_Of_Interest__c = 'EFx'
        );
        //Opportunity o2 = new Opportunity(Name='Test',AccountId=a.Id,Type='New Business', LeadSource='Self Generated',Description='Test',Amount=10000,CloseDate=system.today(), Product_Family__c='Ligation',Product_Of_Interest__c='Metal',StageName='Close');
        insert o2;

        o2.Product_Family__c = 'Skin Stapling';
        update o2;

        o2.Product_Of_Interest__c = 'Cholangiography';
        o2.Focus__c='';
        update o2;

    }*/
}