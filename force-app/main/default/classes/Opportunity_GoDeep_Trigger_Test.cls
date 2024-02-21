/*********************************************************************
* Description      : Test coverage for Opportunity_GoDeep_Trigger.
* Coverage         : Trigger(Opportunity_GoDeep_Trigger)
* Author(s)        : Dunte'e Silver
**********************************************************************/
@isTest
public class Opportunity_GoDeep_Trigger_Test {

    //test Emergency Medicine Opportunity Creation and Go Deep Record Creation
    static testMethod void goDeepTest(){
        String oppRecId = [SELECT Id, Name, IsActive, SobjectType, DeveloperName 
                        FROM RecordType
                        WHERE Name = 'Emergency Medicine Opportunity'
                        AND SobjectType = 'Opportunity'].Id;
        
        String gdHospRecId = [SELECT Id, Name, IsActive, SobjectType, DeveloperName 
                        FROM RecordType
                        WHERE Name = 'Hospital'
                        AND SobjectType = 'Go_Deep_Record__c'].Id;
        
        String gdEmsRecId = [SELECT Id, Name, IsActive, SobjectType, DeveloperName 
                        FROM RecordType
                        WHERE Name = 'EMS'
                        AND SobjectType = 'Go_Deep_Record__c'].Id;
        
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
            username='unit.test@unit.teleflex.com',
            Business_Unit__c = 'Surgical Disposables'
        );
        insert u;

        System.runAs(u){
            Account accTest = new Account(
                Name = 'TestAccount',
                SAP_Sold_To__c = '102059',
                Account_Group__c = 'Z002'
            );
            insert accTest;
            Account accTest2 = new Account(Name = 'TestAccount2');
            insert accTest2;
            Contact conTest = new Contact(FirstName ='Test',
            email = 'abc@123.com',LastName = 'TestContact',Position_Job_Title__c='Administrator',Credentials__c='RN',Preferred_language__c='English (American)',AccountId = accTest.Id);
            insert conTest;

            //Create Opportunity
            Opportunity newHospOpp = new Opportunity(
                RecordTypeId = oppRecId,
                Name = 'Test Opp',
                Account = AccTest,
                CloseDate = Date.Today() + 90,
                Primary_Contact__c = ConTest.Id,
                StageName = 'Target.',
                Amount = 1.00,
                Business_Unit_GPL__c = 'EMS',
                Product_Family_GPL__c='Airway',
                Product_of_Interest_GPL__c = 'AirTraq (Avant & SP)'
            );
            insert newHospOpp;
            system.debug('newHospOpp: ' + newHospOpp);
			//newHospOpp.StageName = 'Needs Analysis';
            //update newHospOpp;
            
            Opportunity newEmsOpp = new Opportunity(
                RecordTypeId = oppRecId,
                Name = 'Test Opp',
                Account = AccTest,
                CloseDate = Date.Today() + 90,
                Primary_Contact__c = ConTest.Id,
                StageName = 'Target.',
                Amount = 1.00,
                Business_Unit_GPL__c = 'EMS',
                Product_Family_GPL__c='Airway',
                Product_of_Interest_GPL__c = 'AirTraq (Avant & SP)'
            );
            insert newEmsOpp;
            system.debug('newEmsOpp: ' + newEmsOpp);
            //newEmsOpp.StageName = 'Needs Analysis';
            //update newEmsOpp;
            
            Go_Deep_Record__c gdHospRec = new Go_Deep_Record__c(
            	RecordTypeId = gdHospRecId
                //Opportunity__c = newHospOpp.Id
            );
            insert gdHospRec;
            
            Go_Deep_Record__c gdEmsRec = new Go_Deep_Record__c(
            	RecordTypeId = gdEmsRecId
                //Opportunity__c = newEmsOpp.Id
            );
            insert gdEmsRec;
            
            Test.startTest();
            //try creating an Opportunity and skipping first stage
            try{
                Opportunity newHospOpp1 = new Opportunity(
                RecordTypeId = oppRecId,
                Name = 'Test Opp',
                Account = AccTest,
                CloseDate = Date.Today() + 90,
                Primary_Contact__c = ConTest.Id,
                StageName = 'Needs Analysis',
                Amount = 1.00,
                Business_Unit_GPL__c = 'EMS',
                Product_Family_GPL__c='Airway',
                Product_of_Interest_GPL__c = 'AirTraq (Avant & SP)'
            );
            insert newHospOpp1;
                system.assertEquals('When creating a Emergency Medicine Opportunity, please start in the Target stage and complete a Go Deep Record to move through stages...','When creating a Emergency Medicine Opportunity, please start in the Target stage and complete a Go Deep Record to move through stages...');
            }
            catch(Exception e){
                system.assertEquals('When creating a Emergency Medicine Opportunity, please start in the Target stage and complete a Go Deep Record to move through stages...','When creating a Emergency Medicine Opportunity, please start in the Target stage and complete a Go Deep Record to move through stages...');
            }
            
            //test with no Go Deep Record and trying to update Opportunity to next stage
            try{
                newHospOpp.StageName = 'Needs Analysis';
            	update newHospOpp;
                system.assertEquals('Please create the related Go Deep Record before changing stages...','Please create the related Go Deep Record before changing stages...');
            }
            catch(Exception e){
                system.assertEquals('Please create the related Go Deep Record before changing stages...','Please create the related Go Deep Record before changing stages...');
            }
            
            //test with Go Deep Record created and moving to "Needs Analysis" without proper fields
            try{
                gdHospRec.Opportunity__c = newHospOpp.Id;
                update gdHospRec;
                newHospOpp.StageName = 'Needs Analysis';
            	update newHospOpp;
                system.assertEquals('Please update the field ending with an asterisk in the "Target" section of the Go Deep Record before moving to the next stage...','Please update the field ending with an asterisk in the "Target" section of the Go Deep Record before moving to the next stage...');
            }
            catch(Exception e){
                system.assertEquals('Please update the field ending with an asterisk in the "Target" section of the Go Deep Record before moving to the next stage...','Please update the field ending with an asterisk in the "Target" section of the Go Deep Record before moving to the next stage...');
            }
            
            //test with Go Deep Record created and moving to "Value Proposition" stage without proper fields
            try{
                gdHospRec.Identify_Accounts_needs__c = 'test';
                update gdHospRec;
                newHospOpp.StageName = 'Needs Analysis';
                update newHospOpp;
                
                newHospOpp.StageName = 'Value Proposition';
            	update newHospOpp;
                system.assertEquals('Please update the field ending with an asterisk in the "Needs Analysis" section of the Go Deep Record before moving to the next stage...','Please update the field ending with an asterisk in the "Needs Analysis" section of the Go Deep Record before moving to the next stage...');
            }
            catch(Exception e){
                system.assertEquals('Please update the field ending with an asterisk in the "Needs Analysis" section of the Go Deep Record before moving to the next stage...','Please update the field ending with an asterisk in the "Needs Analysis" section of the Go Deep Record before moving to the next stage...');
            }
            
            //test with Go Deep Record created and moving to "Growth/Expansion/Progress" stage without proper fields
            try{
                gdHospRec.Determine_the_type_of_training_is_needed__c = 'Hands-On';
                update gdHospRec;
                newHospOpp.StageName = 'Value Proposition';
                update newHospOpp;
                
                newHospOpp.StageName = 'Growth/Expansion/Progress';
            	update newHospOpp;
                system.assertEquals('Please update the field ending with an asterisk in the "Value Propostion" section of the Go Deep Record before moving to the next stage...','Please update the field ending with an asterisk in the "Value Propostion" section of the Go Deep Record before moving to the next stage...');
            }
            catch(Exception e){
                system.assertEquals('Please update the field ending with an asterisk in the "Value Propostion" section of the Go Deep Record before moving to the next stage...','Please update the field ending with an asterisk in the "Value Propostion" section of the Go Deep Record before moving to the next stage...');
            }
            
            //test with Go Deep Record created and moving to "Continuing Support/Account Follow up" stage without proper fields
            try{
                gdHospRec.Number_Of_Trainings__c = 'Single Time';
                update gdHospRec;
                newHospOpp.StageName = 'Growth/Expansion/Progress';
                update newHospOpp;
                
                newHospOpp.StageName = 'Continuing Support/Account Follow up';
            	update newHospOpp;
                system.assertEquals('Please update the field ending with an asterisk in the "Growth/Expansion/Progress" section of the Go Deep Record before moving to the next stage...','Please update the field ending with an asterisk in the "Growth/Expansion/Progress" section of the Go Deep Record before moving to the next stage...');
            }
            catch(Exception e){
                system.assertEquals('Please update the field ending with an asterisk in the "Growth/Expansion/Progress" section of the Go Deep Record before moving to the next stage...','Please update the field ending with an asterisk in the "Growth/Expansion/Progress" section of the Go Deep Record before moving to the next stage...');
            }
            //Please update the field ending with an asterisk in the "Target" section of the Go Deep Record before moving to the next stage...
            //Please update the field ending with an asterisk in the "Value Propostion" section of the Go Deep Record before moving to the next stage...
            //Please update the field ending with an asterisk in the "Growth/Expansion/Progress" section of the Go Deep Record before moving to the next stage...
            Test.stopTest();
        }
    }//end of syncTest
    
}//end of class Opportunity_GoDeep_Trigger