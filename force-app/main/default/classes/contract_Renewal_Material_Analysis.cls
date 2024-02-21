/*********************************************************************
* Description      : Class provides details of Materials per contract.
* Test Class       : Contract_Renewal_Test
* VisualForce      : contract_Renewal_Material_Analysis
* Author(s)        : Eric Clay
**********************************************************************/
public class contract_Renewal_Material_Analysis {

    public Contract_Renewal__c cr {get; set;}
    public Account Acct {get; set;}
    public map<String, Contract_Customer__c> ccMap {get; set;}
    public map<Id, list<Contract_Material__c>> cmMap {get; set;}
    public map<String, Decimal> criPrice {get; set;}
    public list<Contract_Customer__c> ccList {get; set;}
    public list<Contract_Material__c> cmList {get; set;}
    public string fname {get; set;}
    public string cid {get; set;}

    public contract_Renewal_Material_Analysis(){
        cmMap = new map<ID, list<Contract_Material__c>>();
        ccMap = new map<String, Contract_Customer__c>();
        criPrice = new map<String, Decimal>();
        ccList = new list<Contract_Customer__c>();
        cmList = new list<Contract_Material__c>();
        cr = new Contract_Renewal__c();
        Acct = new Account();

        set<Id> chIdSet = new set<Id>();
        set<Id> criSet = new set<Id>();
        string aid;

        if(Apexpages.currentPage().getParameters().get('id') != NULL){

            cid = Apexpages.currentPage().getParameters().get('id');
            cr = [SELECT Contract_Header__r.Id, Contract_Header__r.Agreement_Number__c, Contract_Header__r.Description__c
                  FROM Contract_Renewal__c
                  WHERE Id =:cid];

            Id chId = cr.Contract_Header__r.Id;

            fname = cr.Contract_Header__r.Agreement_Number__c + '-Customers-';
            fname += datetime.now().format('MM-dd-yyyy');

            aid = Apexpages.currentPage().getParameters().get('aid');
            for(Contract_Renewal_Item__c cri : [SELECT Id, Product__c, Requested_Renewal_Price__c, Product__r.Name
                                               FROM Contract_Renewal_Item__c
                                               WHERE Contract_Renewal__c =:cid])
            {
                criSet.add(cri.Product__c);
                criPrice.put(cri.Product__r.name, cri.Requested_Renewal_Price__c);
            }
            //system.debug('CRIs: ' + criSet);
            for(Contract_Customer__c cc : [SELECT Id, Agreement__c, Condition__c, Condition_Rank__c, Agreement_Number__c, Agreement__r.Description__c, Agreement__r.GPO_Contract_Ref__c,
                                           Valid_From__c, Valid_To__c, Agreement__r.Objective__c, Agreement__r.Objective_Name__c,
                                           Agreement__r.Owner__c, Agreement__r.Owner_Name__c, Agreement__r.Distribution_Channel__c,
                                           Agreement__r.Group__c, Agreement__r.Sub_Group__c
                                           FROM Contract_Customer__c
                                           WHERE Account__c =:aid])
            {
                //ccList.add(cc);
                ccMap.put(cc.Agreement_Number__c, cc);
                //chIdSet.add(cc.Agreement__c);
            }
            //system.debug('chIdSet: ' + chIdSet);
            for(Contract_Material__c cm : [SELECT Agreement_Number__c, Product__r.Name, Agreement__r.Id,
                                           Agreement__r.Agreement_Number__c, Price__c
                                           FROM Contract_Material__c
                                           WHERE Product__c =:criSet
                                           AND Active__c = TRUE
                                           ORDER BY Product__r.Name])
            {

                if(ccMap.get(cm.Agreement_Number__c) != NULL){
                    cmList.add(cm);
                }

            }


        }

    }
}