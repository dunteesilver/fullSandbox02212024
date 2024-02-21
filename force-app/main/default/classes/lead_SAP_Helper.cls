public class lead_SAP_Helper {
    public static void insertSAP(list<Lead> newtrigger,map<id,lead> oldtrigger,string trigType){
        if(master_TriggerHelperClass.qd('insertSAP')){
            
            // This class takes the SAP Customer number and looks up the related account and updates
            // the Name and Address fields. Works on insert and update and does not error if the SAP
            // code is not valid. - ESC
            set<string> setsap = new set<string>();
            string sapCompare;
            for(lead l : newtrigger){
                if(trigType == 'update'){
                    sapCompare = oldtrigger.get(l.Id).SAP_Code__c;                     
                }

                if(l.SAP_Code__c != sapCompare && l.SAP_Code__c != NULL){
                    setsap.add(l.SAP_Code__c);
                }
                
                // Update the BU if Empty and Formstack BU is valid
                if(l.Zip_Code_Business_Unit__c != NULL && l.Business_Unit__c == NULL){
                    l.Business_Unit__c = l.Zip_Code_Business_Unit__c;
                }
            }
            
            if(setsap.size() > 0){
                map<String, Account> sapmap = new map<String, Account>();
                for(Account a : [SELECT Id, Name, SAP_Sold_To__c, BillingStreet, 
                                 BillingCity, BillingState, BillingPostalCode 
                                 FROM Account 
                                 WHERE SAP_Sold_To__c = :setsap])
                {
                    sapmap.put(a.SAP_Sold_To__c, a);
                }
                
                for(lead l : newtrigger){
                    if(l.SAP_Code__c != NULL && sapmap.get(l.SAP_Code__c) != NULL){
                        l.Company = sapmap.get(l.SAP_Code__c).Name;
                        l.Street = sapmap.get(l.SAP_Code__c).BillingStreet;
                        l.City = sapmap.get(l.SAP_Code__c).BillingCity;
                        l.State = sapmap.get(l.SAP_Code__c).BillingState;
                        l.PostalCode = sapmap.get(l.SAP_Code__c).BillingPostalCode;
                        l.Account__c = sapmap.get(l.SAP_Code__c).Id;
                    } 
                } 
            } // End If
            
        } // End qd
        
    }
}