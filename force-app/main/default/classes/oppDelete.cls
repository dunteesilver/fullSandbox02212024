public class oppDelete{
/*
    private ApexPages.StandardController controller {get; set;}
    private Opportunity opp {get;set;}


    public oppDelete(ApexPages.StandardController controller) {
        this.controller = controller;
        this.opp = (Opportunity)controller.getRecord();
    }

    public PageReference doDelete(){

        PageReference finalURL = new pagereference('/006/o');
       User u = [SELECT Id, ManagerId, Name FROM User WHERE Id=:opp.OwnerId];

        if(!Schema.SObjectType.Opportunity.isDeletable()){
           if(opp.OwnerId != userinfo.getuserid()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'You do not have access to flag this Opportunity as deleted'));
                return null;
            }else if(u.ManagerId != null){

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String emailAddr = [select Email from User where Id = :u.ManagerId].Email;

                String[] toAddresses = new String[] {emailAddr};
                mail.setToAddresses(toAddresses);

                mail.setSubject('You have an Opportunity Pending Deletion: ' + Opp.Name);

                mail.setPlainTextBody('Please check the "Opportunities Pending Deletion" view on your Opportunities tab');

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

                opp.Previous_Owner_Id__c = opp.OwnerId;
                opp.OwnerId = u.ManagerId;
                opp.Deletion_Pending__c = true;
                update opp;


                return finalURL;
            }else if(u.ManagerId == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Your manager must be specified in your user profile in order to delete an Opportunity'));
                return null;
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Unable to delete Opportunity'));
                return null;
            }
        }else{
            //delete opp;
            return finalURL;
        }

    }

    public PageReference doReinstate(){
        opp.Deletion_Pending__c = false;
        opp.OwnerId = opp.Previous_Owner_Id__c;
        opp.Previous_Owner_Id__c = null;
        update opp;
        return null;
    }

    public static testMethod void oppDeleteTest() {

        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            Username='trey.flowers@teleflex.com.testing1',
            Email='trflowers@teleflex.com',
            Lastname='User',
            Firstname='Test',
            Alias='tuser',
            emailencodingkey='UTF-8',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid=p.Id,
            timezonesidkey='America/New_York'
        );
        insert u;
        system.debug('Admin Standard: ' + u);
//        Standard User
        //Profile p1 = [SELECT Id FROM Profile WHERE Id='00eE0000000h4XTIAY'];
        Profile p1 = [select id from profile where name='Standard User'];
        User u1 = new User(
            Username='trey.flowers@teleflex.com.testing2',
            ManagerId=u.Id,
            Email='trflowers@teleflex.com',
            Lastname='User',
            Firstname='Test',
            Alias='tuser1',
            emailencodingkey='UTF-8',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid=p1.Id,
            timezonesidkey='America/New_York'
        );
        insert u1;
        system.debug('User Standard: ' + u1);

        Account acct = new Account(Name='Test Account ');
        insert acct;

        Contact c = new Contact(
            lastname='second',
            AccountId = acct.id
        );
        insert c;

        Opportunity opp = new Opportunity(
            Name='a',
            Account=acct,
            StageName='Target',
            Closedate=date.today() + 1,
            Product_Family__c='test',
            Product_Of_Interest__c='test',
            OwnerId = u1.Id,
            Primary_Contact__c = c.id
        );
        insert Opp;
        system.debug('Opportunity: ' + Opp);

        system.runas(u1){
            oppDelete extension = new oppDelete(new ApexPages.StandardController(opp));
            extension.doDelete();
        }
        system.runas(u){
            oppDelete extension2 = new oppDelete(new ApexPages.StandardController(opp));
            //extension2.doReinstate();
        }
        system.runas(u1){
            oppDelete extension3 = new oppDelete(new ApexPages.StandardController(opp));
            extension3.doDelete();
        }
        system.runas(u){
            oppDelete extension4 = new oppDelete(new ApexPages.StandardController(opp));
            extension4.doDelete();
        }
    }
*/
}