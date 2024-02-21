/*********************************************************************
* Description      : Controller Class for all components on Winner's Guide record type/lightning record pages.
* Test Class       : WinnersGuideHandlerTest
* VisualForce      : Winner*.cmp
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
**********************************************************************/
public class WinnersGuideHandler {
    /*
     *Method Name 		  : getWGinfoForRecID
	 *Method Input Params : String wgRecId
     *Method Return type  : List<ConRoleWrapper>
     */
    @AuraEnabled
    public static List<ConRoleWrapper> getWGinfoForRecID(String wgRecId){
        List<ConRoleWrapper> conWrpLst = new List<ConRoleWrapper>();
        Winners_Guide__c wgObj = [select 
                                  Id, 
                                  Opportunity__r.Name
                                  from Winners_Guide__c 
                                  where Id =: wgRecId];
        List<OpportunityContactRole> ocrObjLst = [select 
                                                  Id,
                                                  Role,
                                                  Contact.Position_Job_Title__c,
                                                  Contact.Name,
                                                  Contact.Email
                                                  from OpportunityContactRole 
                                                  where OpportunityId =: wgObj.Opportunity__c
                                                  and Role in ('Champion', 'Blocker', 'Neutral', 'Supporter')];
        for(OpportunityContactRole ocrObj : ocrObjLst){ConRoleWrapper conWrpObj = new ConRoleWrapper();conWrpObj.contactName = ocrObj.Contact.Name; conWrpObj.title = ocrObj.Contact.Position_Job_Title__c;conWrpObj.role = ocrObj.Role; conWrpObj.email = ocrObj.Contact.Email; conWrpLst.add(conWrpObj);
                                                      }
        return conWrpLst;
    }
    /*
     *Method Name 		  : saveWGBalSellerDetails
	 *Method Input Params : String  newVPSWinGuide
     *Method Return type  : String
     */
    @AuraEnabled
    public static String saveWGBalSellerDetails(String  newVPSWinGuide){
        System.debug('newVPSWinGuide>>>'+newVPSWinGuide);
        Winners_Guide__c saveModfdWGObj = (Winners_Guide__c)JSON.deserialize(newVPSWinGuide, Winners_Guide__c.class);
        Database.update(saveModfdWGObj);
        return JSON.serialize(saveModfdWGObj);
    }
    /*
     *Method Name 		  : getWGDetails
	 *Method Input Params : ID wgId
     *Method Return type  : Winners_Guide__c
     */
    @AuraEnabled
    public static Winners_Guide__c getWGDetails(ID wgId)
    {
        Winners_Guide__c thisWGObj = [ select 
                                      Id,
                                      Name,
                                      BS_VAT_DirMgr_Nme_Em_Ph__c,
                                      BS_VAT_DirMgr_Lvl_of_Sup__c,
                                      BS_VAT_DirMgr_Sup_Comments__c,
                                      BS_VAT_DirMgr_Cap_Equip_Comm__c,
                                      BS_VAT_Lead_Nme_Em_Ph__c,
                                      BS_VAT_Lead_Lvl_of_Sup__c,
                                      BS_VAT_Lead_Sup_Comments__c,
                                      BS_VAT_Lead_Cap_Equip_Comm__c,
                                      BS_IR_Lead_Tech_Nme_Em_Ph__c,
                                      BS_IR_Lead_Tech_Lvl_of_Sup__c,
                                      BS_IR_Lead_Tech_Sup_Comments__c,
                                      BS_IR_Lead_Tech_Cap_Equip_Comm__c,
                                      BS_MatMgmt_SuppChn_Nme_Em_Ph__c,
                                      BS_MatMgmt_SuppChn_Lvl_of_Sup__c,
                                      BS_MatMgmt_SuppChn_Sup_Comments__c,
                                      BS_MatMgmt_SuppChns_Cap_Equip_Comm__c,
                                      BS_NurEdu_Nme_Em_Ph__c,
                                      BS_NurEdu_Lvl_of_Sup__c,
                                      BS_NurEdu_Sup_Comments__c,
                                      BS_NurEdu_Cap_Equip_Comm__c,
                                      BS_QualityRskMgmt_Nme_Em_Ph__c,
                                      BS_QualityRskMgmt_Lvl_of_Sup__c,
                                      BS_QualityRskMgmt_Sup_Comments__c,
                                      BS_QualityRskMgmt_Cap_Equip_Comm__c,
                                      BS_CSuite_Nme_Em_Ph__c,
                                      BS_CSuite_Lvl_of_Sup__c,
                                      BS_CSuite_Sup_Comments__c,
                                      BS_CSuite_Cap_Equip_Comm__c,
                                      BS_VAC_Nme_Em_Ph__c,
                                      BS_VAC_Lvl_of_Sup__c,
                                      BS_VAC_Sup_Comments__c,
                                      BS_VAC_Cap_Equip_Comm__c,
                                      BS_FinancialDecisionMaker_Nme_Em_Ph__c,
                                      BS_FinancialDecisionMaker_Lvl_of_Sup__c,
                                      BS_FinancialDecisionMaker_Sup_Comments__c,
                                      BS_FinancialDecisionMaker_Cap_Equip_Comm__c,
                                      BS_Biomed_Nme_Em_Ph__c,
                                      BS_Biomed_Lvl_of_Sup__c,
                                      BS_Biomed_Sup_Comments__c,
                                      BS_Biomed_Cap_Equip_Comm__c,
                                      BS_Other_Nme_Em_Ph__c,
                                      BS_Other_Lvl_of_Sup__c,
                                      BS_Other_Sup_Comments__c,
                                      BS_Other_Cap_Equip_Comm__c
                                      from Winners_Guide__c where Id =: wgId
                                     ];
        return thisWGObj;
    }
    /*
     *Inner Class of type Wrapper
     */        
    public class ConRoleWrapper{
        @AuraEnabled public String contactName {get; set;}
        @AuraEnabled public String role {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String email {get; set;}
    }
    
}