public With Sharing class TPRecordsController {
    public List<Target_Profile__c> targetProfs {get;set;}
    
    public TPRecordsController(){
        string potentialRange;
        potentialRange = ApexPages.currentPage().getParameters().get('pr');
        string saturantionRange;
        saturantionRange = ApexPages.currentPage().getParameters().get('sr');
        Id userId;
        userId = UserInfo.getUserId();
        Set<Id> accountIds;
        accountIds = new Set<Id>();
        string additionalWhereCriteria;
        
        List<Territory_Master__c> territories = [SELECT Id FROM Territory_Master__c WHERE Sales_Rep__c=:userId];
        //system.debug('territories:'+territories);
        If(territories != null && territories.size() > 0){
            List<Territory_Assignment__c> territoryAssignments = [SELECT Id, account__c FROM Territory_Assignment__c WHERE territory__c IN:territories AND Account__r.Target_Profiles_Count__c!=0];
            //system.debug('territoryAssignments:'+territoryAssignments);
            If(territoryAssignments != null && territoryAssignments.size() > 0){
                for(Territory_Assignment__c ta:territoryAssignments){
                    accountIds.add(ta.account__c);
                }
                //system.debug('accountIds:'+accountIds);
            }
            if(accountIds.size()>0){
                additionalWhereCriteria = ' AND Account__c IN:accountIds';
            }
        }
        String queryStr;
        queryStr = 'SELECT Id,Name,Account__r.Name,State__c,Protocol_Ranking__c,';
        queryStr += 'Last_Year_Eaches__c,X12_Month_Rolling_Sales_eaches__c,Actual_IO_Potential_eaches__c ';
        queryStr += 'FROM Target_Profile__c ';
        queryStr += 'WHERE IO_potential_Range__c=:potentialRange ';
        queryStr += 'AND Account_Saturation_Range__c =:saturantionRange';
        if(string.isNotBlank(additionalWhereCriteria)){
            queryStr += additionalWhereCriteria;
        }
        targetProfs = database.query(queryStr);
    }
}