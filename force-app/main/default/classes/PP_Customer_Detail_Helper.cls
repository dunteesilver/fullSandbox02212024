public without sharing class PP_Customer_Detail_Helper {

    public void checkSecurity(set<string> cnlist,set<string> acheck){
        list<AccountShare> addAccountShare = new list<AccountShare>();
        for(Account a : [SELECT Id, SAP_Sold_To__c
                         FROM Account
                         WHERE SAP_Sold_To__c IN :cnlist])
        {
            if(a.SAP_Sold_To__c != ApexPages.currentPage().getParameters().get('cid')){
                System.debug('Check Security!');
                if(!acheck.contains(a.SAP_Sold_To__c)){
                    AccountShare addAS = new AccountShare(
                        AccountId = a.Id,
                        //Changed from Read-Only to Private/None (04/Sept/2015 - ESC)
                        OpportunityAccessLevel = 'None',
                        CaseAccessLevel = 'None',
                        AccountAccessLevel = 'Edit',
                        UserOrGroupId = UserInfo.getUserId()
                    );
                    System.debug('Add Account Share: ' + addAS);
                    addAccountShare.add(addAS);
                }
            }
        }
        if(addAccountShare.size() > 0){
            insert addAccountShare;
        }
    }

}