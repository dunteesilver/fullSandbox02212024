public class account_Helper_Class {
    
    public static void updateAccountType(List<Account> newTrigger){
        // Test Class: account_Page_Helper_Test
        
        for(Account a : newTrigger){
            if(a.Account_Group_Name__c != a.Type && a.Account_Group_Name__c != NULL){
                a.Type = a.Account_Group_Name__c;
            }
            if(a.zBlock__c != '00' 
               && a.ERP_Active__c){
                   a.ERP_Active__c = FALSE;
               }
            else if(a.zBlock__c == '00' && !a.ERP_Active__c){
                a.ERP_Active__c = TRUE;
            }
        }
    }//end of updateAccountType
        
    //method to assign different recordtype to Reporting Parent if IDN 
    public static void accRecordTypeCheck(List<Account> newTrigger){
        System.debug('*** idnAccountCheck method account_Helper_Class ***');
        Map<String,RecordType> recordTypeMap = new Map<String,RecordType>(); //holds map of recordtype name and object
        
        //get list of account recordtypes
        List<RecordType> recTypes = [SELECT Id, Name, IsActive, SobjectType, DeveloperName 
                                     FROM RecordType
                                     WHERE SobjectType = 'Account'
                                     ORDER BY SobjectType ASC];
        
        //loop to create map of account recordtypes
        for(RecordType curr : recTypes){
            recordTypeMap.put(curr.Name,curr);
        } 
        
        //below are variables and logic to update account recordtypes
        String sapCode = NULL;
        String idnAccount = 'IDN Account';
        String gpoAccount = 'GPO Account';
    
        for(Account a : newTrigger){
            System.debug('*** SAP Code *** ' + a.SAP_Sold_To__c);
            sapCode = a.SAP_Sold_To__c;
            if(sapCode != NULL && sapCode.containsIgnoreCase('IDN')){
                System.debug('*** Account is IDN ***');
                a.RecordTypeId = recordTypeMap.get(idnAccount).Id;
                a.IDN_Number__c = a.SAP_Sold_To__c;
            }
            
            if(sapCode != NULL && sapCode.containsIgnoreCase('GPO')){
                System.debug('*** Account is GPO ***');
                a.RecordTypeId = recordTypeMap.get(gpoAccount).Id;
            }
            
            if(a.Sales_Org__c == 'CO10' || a.Sales_Org__c == 'MX40' || a.Sales_Org__c == 'CL10' || a.Sales_Org__c == 'BR10'){
                System.debug('*** Account is LATAM ***');
                a.RecordTypeId = recordTypeMap.get('LatAm Customer').Id;
            }
            
            if(a.Sales_Org__c == 'AU10' || a.Sales_Org__c == 'NZ10'){
                System.debug('*** Account is ANZ ***');
                a.RecordTypeId = recordTypeMap.get('ANZ Customer').Id;
                a.anz_account__c = true;
            }
            
            System.debug('*** a *** ' + a);
        }
    }//end of updateAccountRecordType
    
    //method to add IDN value from ParentId to IDN field
    public static void addIDNs(List<Account> newTrigger){
        System.debug('*** STARTING addIDNs METHOD IN account_Helper_Class ***');
        Set<ID> idnSet = new Set<ID>(); //set to hold IDN Account IDs
        //list to hold IDN Accounts to add to set
        List<Account> accList = [SELECT Id,IDN_Number__c,IDN__c,Name,SAP_Sold_To__c FROM Account WHERE RecordType.Name = 'IDN Account'];
        System.debug('*** accList.size() *** ' + accList.size() );

        //for loop to create map of ID and IDN Number to Map
        for(Account curr : accList){
            idnSet.add(curr.Id); //adding IDN Account IDs to set
        }//end of for accList
        
        //for loop to update IDN Lookup field on Accounts
        for(Account curr : newTrigger){
            //check if ParentId of current Account matches any Id in Set
            if(curr.ParentId != NULL && idnSet.contains(curr.ParentId) ){
                curr.IDN__c = curr.ParentId;
                
            }//end if  
        }//end of for newTrigger
        
    }//end of void addIDN method
    
    //method to add and remove Parent Account
    public static void addParentAccount(List<Account> newTrigger){
        /*
        for(Account a : newTrigger){
            if(a.Sap_Sold_to__c != a.Type && a.Account_Group_Name__c != NULL){
                a.Type = a.Account_Group_Name__c;
            }
            if(a.zBlock__c != '00' 
               && a.ERP_Active__c){
                   a.ERP_Active__c = FALSE;
               }
            else if(a.zBlock__c == '00' && !a.ERP_Active__c){
                a.ERP_Active__c = TRUE;
            }
      }
    */
        
        String accId;
        String parentAccId;
        for(Account curr : newTrigger){
            //check to make sure Ids are not Null
            if(curr.ParentId != NULL){
                accId = curr.Id;
                parentAccId = curr.ParentId;
                if( accId.left(15) == parentAccId.left(15) ){
                    curr.ParentId = NULL;
                }//end of if id comparison check
            }//end of if null Id check
            
        }//end of for loop
        
    }//end of public static void addParentAccount
    
    //method to add and remove Parent Account (adding new, updating existing)
    public static void addIdnCustomSetting(List<Account> newTrigger){
        //create map of IDN Accounts
        Map<String,Account> accMap = new Map<String,Account>();
        Map<String,IDN_Picklist__c> idnMap = new Map<String,IDN_Picklist__c>();
        List<IDN_Picklist__c> idnRecordList = new List<IDN_Picklist__c>();
        List<IDN_Picklist__c> currIdns = [SELECT Id, Name, Key__c, Sales_Org_Key__c, Active__c FROM IDN_Picklist__c ];
        Set<String> idnSet = new Set<String>();
        
        //create IDN Map
        for(IDN_Picklist__c curr : currIdns){
            idnMap.put(curr.Key__c,curr);
            idnSet.add(curr.Key__c);
        }//end IDN Picklist for loop
        
        for(Account curr: newTrigger){
            String sapCode = curr.Sap_Sold_To__c;
            String recTypeId = curr.RecordtypeId;
            //String idnId = idnMap.get(curr.Sap_Sold_To__c).Id;
            //Prospect Recordtype check
            system.debug('*** curr.RecordtypeId *** ' + curr.RecordtypeId);
            //if(!Test.isRunningTest()){
                if(recTypeId.left(15) != '012E0000000RVFO' && recTypeId.left(15) != '012E0000000NJhu'){
                    if(sapCode != NULL && sapCode.left(3) == 'IDN' ){
                        if(curr.BillingCountry == NULL){
                            curr.BillingCountry = 'US';
                        }//end inner if
                        accMap.put(curr.Sap_Sold_To__c, curr);
                        
                        if(idnSet.contains(curr.Sap_Sold_To__c)){
                            IDN_Picklist__c idnRecord = new IDN_Picklist__c(
                                Id = idnMap.get(curr.Sap_Sold_To__c).Id,
                                Key__c = curr.Sap_Sold_To__c,
                                Name = curr.Name,
                                Sales_Org_Key__c = curr.BillingCountry,
                                Active__c = idnMap.get(curr.Sap_Sold_To__c).Active__c
                            );
                            idnRecordList.add(idnRecord);
                        }
                        else{
                            IDN_Picklist__c idnRecord = new IDN_Picklist__c(
                                Key__c = curr.Sap_Sold_To__c,
                                Name = curr.Name,
                                Sales_Org_Key__c = curr.BillingCountry,
                                Active__c = true
                            );
                            
                            idnRecordList.add(idnRecord);
                        }  
                    }//end if sapCode
                }//end else to Prospect Recordtype check
            //}//end of test running check
            
            
        }//end for loop Account
        
        //upsert records
        if( idnRecordList.size() > 0 ){
            if(!Test.isRunningTest()){
                Database.upsert(idnRecordList, false);
            }//end inner if
            //end upsert success check
        }//end if for custom settings list size check 
    }//end of public static void addIdnCustomSetting
 
    //fix messed up characters with names and addresses
    public static void updateAccountFields(List<Account> accounts) {
        for (Account acc : accounts) {
            if (acc.Name != null) {
                acc.Name = SObjectUtility.replaceMessedUpCharacters(acc.Name);
            }
            if (acc.ShippingCity != null) {
                acc.ShippingCity = SObjectUtility.replaceMessedUpCharacters(acc.ShippingCity);
            }
            if (acc.ShippingStreet != null) {
                acc.ShippingStreet = SObjectUtility.replaceMessedUpCharacters(acc.ShippingStreet);
            }
            if (acc.ShippingState != null) {
                acc.ShippingState = SObjectUtility.replaceMessedUpCharacters(acc.ShippingState);
            }
            if (acc.ShippingStreet != null) {
                acc.ShippingStreet = SObjectUtility.replaceMessedUpCharacters(acc.ShippingStreet);
            }
            if (acc.Account_Name_2__c != null) {
                acc.Account_Name_2__c = SObjectUtility.replaceMessedUpCharacters(acc.Account_Name_2__c);
            }
            if (acc.Incoterms_1__c != null) {
                acc.Incoterms_1__c = SObjectUtility.replaceMessedUpCharacters(acc.Incoterms_1__c);
            }
            if (acc.Incoterms_2__c != null) {
                acc.Incoterms_2__c = SObjectUtility.replaceMessedUpCharacters(acc.Incoterms_2__c);
            }
            if (acc.Terms__c != null) {
                acc.Terms__c = SObjectUtility.replaceMessedUpCharacters(acc.Terms__c);
            }
            if(acc.Language__c == 'Slovakian'){
                acc.Language__c = 'Slovak';
            }
        } 
        // Perform any additional logic or DML operations on the updated accounts
    }
    
}//end of class