@isTest
public class riskUpdaterTest {
    static testMethod void riskUpdaterTest() {
        Risk_Lookup__c lookup = new Risk_Lookup__c(Name='66',Rating__c='Low',Traffic_Light__c='Low');
        insert lookup;
        Project__c proj = new Project__c(Name='TESTING');
        insert proj;
        Risk__c risk = new Risk__c(Initiative__c = proj.Id,Impact_Of_Risk__c='6',Likelihood_Of_Occurrence__c='6');
        insert risk;
        
        Risk__c newRisk = [SELECT Current_Risk_Level__c FROM Risk__c WHERE Id=:risk.Id];
        System.AssertEquals('Low',newRisk.Current_Risk_Level__c);
    }
}