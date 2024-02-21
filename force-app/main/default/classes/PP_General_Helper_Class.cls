public class PP_General_Helper_Class {
    
    public static void addContractLookup(List<SObject> newTrigger, String type){
        
        set<String> chSet = new set<String>();
        map<String, Id> chMap = new map<String, Id>();
        
        string SalesNumber;
        string SalesDeal;
        for(SObject i : newTrigger){
            if(type == 'PQ'){
                SalesNumber = (String) i.get('Sales_Number__c');               
            }
            /*else if(type == 'PRF'){
                SalesNumber = (String) i.get('Sales_Deal_Num__c');                
            }*/

            if((Id) i.get('Sales_Deal__c') == NULL && SalesNumber != NULL){
                chSet.add(SalesNumber);
            }
        }
        //system.debug('chSet: ' + chSet);
        //Sales_Deal__c = PQ
        //Sales_Deal_Num__c = PRF

        if(chSet.size() > 0){
            for(Contract_Header__c ch : [SELECT Id, Agreement_Number__c 
                                         FROM Contract_Header__c 
                                         WHERE Agreement_Number__c = :chSet])
            {
                chMap.put(ch.Agreement_Number__c, ch.Id);
            }
            //system.debug('chMap: ' + chMap);
            if(chMap.size() > 0){
                
                for(SObject i : newTrigger){
                    if(type == 'PQ'){
                        SalesNumber = (String) i.get('Sales_Number__c');               
                    }
                    /*else if(type == 'PRF'){
                        SalesNumber = (String) i.get('Sales_Deal_Num__c');                
                    }*/
                    
                    if(
                        (Id) i.get('Sales_Deal__c') == NULL && 
                        SalesNumber != NULL && 
                        chMap.containsKey(SalesNumber)
                    ){
                        i.put('Sales_Deal__c', chMap.get(SalesNumber));
                    }
                }
            } // END chMap Check
        } // END chSet Check
    } // END Class
    
    
    // Test Class: PP_Global_Test_Class.Daily_Cleanup_Test
    
    public static void checkGPO(List<Contract_Header__c> newTrigger){
        map<String, Boolean> gpoCheck = new map<String, Boolean>();
        list<GPO_PickList__c> gpoList = GPO_PickList__c.getall().values();
        for(GPO_PickList__c gpo : gpoList)
        {
            gpoCheck.put(gpo.Key__c, TRUE);
        }
        
        for(Contract_Header__c ch : newTrigger){
            if(gpoCheck.containsKey(ch.Owner__c)){
                ch.GPO_Contract__c = TRUE;    
            }
            else if(ch.GPO_Contract__c = TRUE){
                ch.GPO_Contract__c = FALSE;
            }
        }
    }
    
    public map<String,String> mstatus(){
        // Test Class: PP_Global_Test_Class.PriceLookupTest
        
        map<String,String> mstatus = new map<String,String>();
        
        mstatus.put('40', 'Saleable (40)');
        mstatus.put('60', 'Discont pend\'g stock (60)');
        mstatus.put('Z1', 'Constrained Product (Z1)');
        mstatus.put('Z8', 'Discontinued Pending Stock (Z8)');
        
        mstatus.put('01', 'Discontinued w/o replacement (01)');
        mstatus.put('02', 'Discontinued w replacement (02)');
        mstatus.put('03', 'Technical defect (03)');
        mstatus.put('04', 'Test Part (04)');
        mstatus.put('11', 'Under Development (11)');
        mstatus.put('20', 'Pre-Sales only (20)');
        mstatus.put('50', 'Limited Availability (50)');
        mstatus.put('70', 'Archive (70)');
        mstatus.put('80', 'Obsolete-No Activity (80)');
        mstatus.put('90', 'Obsolete+Cred+Debit (90)');
        mstatus.put('99', 'Temp Stop Shipment (99)');
        mstatus.put('Z2', 'Discontinued w/o replacement (Z2)');
        mstatus.put('Z3', 'Discontinued w replacement (Z3)');
        mstatus.put('Z4', 'Technical defect (Z4)');
        mstatus.put('Z5', 'Under Development (Z5)');
        mstatus.put('Z6', 'Pre-Sales Only (Z6)');
        mstatus.put('Z7', 'Limited Availability (Z7)');
        mstatus.put('Z9', 'Archive (Z9)');
        mstatus.put('ZM', 'Moved To Sa/Org US60 (ZM)');
        mstatus.put('ZO', 'Obsolete-No Activity (ZO)');
        mstatus.put('ZQ', 'Insufficient License (ZQ)');
        mstatus.put('ZR', 'Under R&D Development (ZR)');
        mstatus.put('ZT', 'Temp Stop Shipment (ZT)');
        mstatus.put('ZU', 'Obsolete w Replacement (ZU)');
        return mstatus;
    }
    
    //Fix currency issues with script
    public static void fixCurrency(List<Contract_Header__c> newTrigger){
        //check and set currency
        for(Contract_Header__c curr : newTrigger){
            //logic check
            if(curr.Sales_Org__c == 'MX40'){
                curr.CurrencyIsoCode = 'MXN';
            }
            else if(curr.Sales_Org__c == 'CL10'){
                curr.CurrencyIsoCode = 'CLP';
            }
            else if(curr.Sales_Org__c == 'CO10'){
                curr.CurrencyIsoCode = 'COP';
            }
            else if(curr.Sales_Org__c == 'BR10'){
                curr.CurrencyIsoCode = 'BRL';
            }
            else{
                curr.CurrencyIsoCode = 'USD';
            }
        }//end for loop
        
    }

    //fix character issues with languages
    public static void updateContractHeaderFields(List<Contract_Header__c> contracts) {
        for (Contract_Header__c con : contracts) {
            if (con.Description__c != null) {
                con.Description__c = SObjectUtility.replaceMessedUpCharacters(con.Description__c);
            }
            if (con.Owner_Name__c != null) {
                con.Owner_Name__c = SObjectUtility.replaceMessedUpCharacters(con.Owner_Name__c);
            }
            if (con.Contract_Detail__c != null) {
                con.Contract_Detail__c = SObjectUtility.replaceMessedUpCharacters(con.Contract_Detail__c);
            }
        } 
        // Perform any additional logic or DML operations on the updated accounts
    }

}