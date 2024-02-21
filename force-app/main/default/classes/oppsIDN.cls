public with sharing class oppsIDN {

    private Account acct;
    Set<Id> members = new Set<Id>();

    public oppsIDN(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
        for(Account m : [SELECT Id FROM Account WHERE IDN__c =:acct.Id]){
            members.add(m.Id);
        }
    }


    List<Opportunity> openIDNOpps;
    List<Opportunity> lostIDNOpps;
    List<Account> topIDNAccts;




    //public Set<Id> getIDNMembers() {
    //    for(Account m : [SELECT Id FROM Account WHERE IDN__c =:acct.Id]){
    //        members.add(m.Id);
    //    }
    //    return members;
    //}

    public List<Opportunity> getIDNOpps(){
        if(members != null){
            openIDNOpps = [SELECT Id, AccountId, Name, RecordTypeId, Product_of_Interest_GPL__c, Product_of_interest__c,
                          Vascular_Net_Amount__c, Amount, CloseDate, StageName, Account.SAP_Sold_To__c
                          FROM Opportunity WHERE AccountId IN :members AND isClosed = False ORDER BY Amount DESC];
            return openIDNOpps;
        }else{
            return null;
        }

    }
    /*
    public decimal getAnnualValue(){
        if(members != null){
            AggregateResult[] groupedResults = [SELECT Sum(Total_PFY_rollup__c) FROM Account WHERE Id IN :members];
            decimal Total = double.valueof(groupedResults[0].get('expr0'));
            return Total;
        }else{
            return 0;
        }

    }

    public decimal getYTDValue(){
        if(members != null){
            AggregateResult[] groupedResults = [SELECT Sum(Total_CFYTD_rollup__c) FROM Account WHERE Id IN :members];
            decimal TotalYTD = double.valueof(groupedResults[0].get('expr0'));
            return TotalYTD;
        }else{
            return 0;
        }
    }

    public decimal getGrowthPct(){
        decimal growth;
        List<Top_10_Selling_Products__c> t10Sample = [SELECT createdDate FROM Top_10_Selling_Products__c Limit 1];
        Integer daysYear = t10Sample[0].createdDate.dayofyear();
        system.debug('test' + daysYear);
        decimal cfytd = getYTDValue();
        system.debug('ytd' + cfytd);
        decimal pytd = getAnnualValue();
        system.debug('pytd' + pytd);
        if(pytd != null){
            pytd = pytd / 365 * daysYear;
        } else {
            pytd = 0;
        }
        if((pytd == null || pytd == 0) && (cfytd != null || cfytd != 0)) {
            growth = 100;
        }else if((cfytd == null || cfytd == 0) && (pytd != null || pytd != 0)) {
            growth = -100;
        }else if((cfytd == null || cfytd == 0) && (pytd == null || pytd == 0)) {
            growth = 0;
        }else{
            growth = ((cfytd - pytd) / pytd)*100;
        }
        return growth;
    }*/

    public List<Opportunity> getIDNLost(){
        lostIDNOpps = [SELECT Id, AccountId, Name, RecordTypeId, Product_of_Interest_GPL__c, Product_of_interest__c, 
                      Vascular_Net_Amount__c, Amount, CloseDate, StageName, Account.SAP_Sold_To__c
                      FROM Opportunity WHERE AccountId IN :members AND isClosed = TRUE AND isWon = FALSE ORDER BY Amount DESC];
        return lostIDNOpps;
    }

    public List<Account> getTopAccts(){
        topIDNAccts = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                      Open_Opportunity_Value__c
                      FROM Account WHERE Id IN :members AND Open_Opportunity_Value__c != 0
                      ORDER BY Open_Opportunity_Value__c DESC];
        return topIDNAccts;
    }

}