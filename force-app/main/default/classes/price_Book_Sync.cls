public class price_Book_Sync {
    public static void insertProducts(list<Product2> newTrigger){
        //if(master_TriggerHelperClass.qd('price_Book_Sync')){
            // Setup
            system.debug('Starting Price Book Product Insert');
            
            Decimal plistprice;
            string spbId;
            string pbreckey;
            
            set<Id> pids = new set<Id>();
            set<Product2> plist = new set<Product2>(); // Filtered list of Products
            set<String> sokSet = new set<String>(); // Sales Org Key Set to filter down the list of Price Books
            
            list<PricebookEntry> pbeStdFix = new list<PricebookEntry>();
            list<PricebookEntry> pbeInsertStd = new list<PricebookEntry>();
            list<PricebookEntry> pbeUpdate = new list<PricebookEntry>();
            
            list<String> pbidList = new list<String>();
            list<PricebookEntry> pbeInsert = new list<PricebookEntry>();

            Map<String, String> pbidMap = new Map<String, String>();
            Map<String, PricebookEntry> stdpbcheckMap = new Map<String, PricebookEntry>();
            Map<String, PricebookEntry> pbcheckMap = new Map<String, PricebookEntry>();
            
            // Get the Standard Price Book ID
            if (Test.isRunningTest()) {
                spbId = Test.getStandardPricebookId();
            }
            else{
                spbId = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE].Id;
            }
            system.debug('Standard Price Book ID: ' + spbId);
            
            // Build the Work List
            for(Product2 p : newTrigger){
                /*if(p.Material_Key__c == NULL && p.Sales_Org__c != NULL && p.Distribution_Channel__c != NULL){
                    p.Material_Key__c = p.Name + '-' + p.Sales_Org__c + '-' + p.Distribution_Channel__c;
                }*/
                if(p.Material_Key__c != NULL && p.Sales_Org_Key__c != NULL && p.List_Price__c != NULL){
                    pids.add(p.Id);
                    plist.add(p);
                    sokSet.add(p.Sales_Org_Key__c);
                }
            }
            //system.debug('pids: ' + pids);
            
            // Custom Setting to Map the Price Books to the ID
            for(Price_Books__c pb : [SELECT Name, Id__c, Price_Book_Name__c
                                     FROM Price_Books__c
                                     WHERE Name =:sokSet])
            {
                pbidMap.put(pb.Name, pb.Id__c);
                //pbidList.add(pb.Id__c);
            }
            system.debug('pbidMap: ' + pbidMap);
            
            // Fix Price Book Entries without Material Key's
            for(PricebookEntry pbe : [SELECT Id, Product2.Material_Key__c
                                      FROM PricebookEntry
                                      WHERE Pricebook2Id =:spbId AND Product2Id =:pids
                                      AND Material_Key__c = NULL])
            {
                PricebookEntry newPBR = new PricebookEntry(
                    Id = pbe.Id,
                    Material_Key__c = pbe.Product2.Material_Key__c
                );
                pbeStdFix.add(newPBR);
            }
            if(pbeStdFix.size() > 0){
                update pbeStdFix;
            }
            
            // Standard Price Book
            // Check to see if the Product has already been added to the standard Price Book
            for(PricebookEntry pbe : [SELECT Product2Id, Material_Key__c, Product2.Material_Key__c, Product2.CurrencyIsoCode, Id, UnitPrice, CurrencyIsoCode 
                                      FROM PricebookEntry
                                      WHERE Pricebook2Id =:spbId
                                      AND Product2Id =:pids])
            {
                stdpbcheckMap.put(pbe.Product2Id + '-' + pbe.Product2.CurrencyIsoCode, pbe);
            }
            system.debug('stdpbcheckMap: ' + stdpbcheckMap);
            
            // Custom Price Book
            // Check to see if the Product is already in the Price Book
            for(PricebookEntry pbe : [SELECT Product2Id, Material_Key__c, Id, UnitPrice, Product2.CurrencyIsoCode 
                                      FROM PricebookEntry
                                      WHERE Pricebook2Id =:pbidMap.values()
                                      AND Product2Id =:pids])
            {
                pbcheckMap.put(pbe.Product2Id + '-' + pbe.Product2.CurrencyIsoCode, pbe);
            }
            system.debug('pbcheckMap: ' + pbcheckMap);
            
            
            for(Product2 p : plist){
                if(p.List_Price__c == 0 || p.List_Price__c == NULL){
                    plistprice = 0;
                }
                else{
                    plistprice = p.List_Price__c;
                }
                pbreckey = p.Id + '-' + p.CurrencyIsoCode;
                
                // Standard Pricebook Check
                // Check to make sure the record does not already exist
                if(stdpbcheckMap.containsKey(pbreckey)){
                    PricebookEntry newPBR = new PricebookEntry(
                        Id = stdpbcheckMap.get(pbreckey).Id,
                        Pricebook2Id = spbId,
                        Product2Id = p.Id,
                        UnitPrice = plistprice,
                        IsActive = TRUE,
                        Material_Key__c = p.Material_Key__c,
                        CurrencyIsoCode = p.CurrencyIsoCode
                    );
                    pbeUpdate.add(newPBR);
                    System.debug('*** Updating Standard Price (Exists) *** ' + p.Material_Key__c);
                }
                else{ // Doesn't exist in the Standard Price Book so we're going to add it.
                    //system.debug('Adding: ' + p.Material_Key__c + ' to Standard Price Book');
                    PricebookEntry newPBR = new PricebookEntry(
                        Pricebook2Id = spbId,
                        Product2Id = p.Id,
                        UnitPrice = plistprice,
                        IsActive = TRUE,
                        Material_Key__c = p.Material_Key__c,
                        CurrencyIsoCode = p.CurrencyIsoCode
                    );
                    pbeInsertStd.add(newPBR);
                    System.debug('*** Inserting Standard Price (New) *** ' + p.Material_Key__c);
                }
                
                // Custom Price Books
                if(pbcheckMap.containsKey(pbreckey)){ // Exists but the List Price has Changed
                    if(pbcheckMap.get(pbreckey).UnitPrice != plistprice){ // Exists but the List Price has Changed
                        //system.debug('Updating Price on: ' + p.Material_Key__c + ' in the Sales Org Price Book');
                        PricebookEntry newPBR = new PricebookEntry(
                            Id = pbcheckMap.get(pbreckey).Id,
                            Pricebook2Id = spbId,
                            Product2Id = p.Id,
                            UnitPrice = plistprice,
                            IsActive = TRUE,
                            Material_Key__c = p.Material_Key__c,
                            CurrencyIsoCode = p.CurrencyIsoCode
                        );
                        pbeUpdate.add(newPBR);
                        System.debug('*** Updating Custom Price Book (Exists) *** ' + p.Material_Key__c);
                    }
                }
                // Doesn't exist in that Product's Sales Org Price Book
                else if(pbidMap.containsKey(p.Sales_Org_Key__c)){ 
                    //system.debug('Adding: ' + p.Material_Key__c + ' to the Sales Org Price Book');
                    PricebookEntry newPBR = new PricebookEntry(
                        Pricebook2Id = pbidMap.get(p.Sales_Org_Key__c),
                        Product2Id = p.Id,
                        UnitPrice = plistprice,
                        IsActive = TRUE,
                        Material_Key__c = p.Material_Key__c,
                        CurrencyIsoCode = p.CurrencyIsoCode
                    );
                    pbeInsert.add(newPBR);
                    System.debug('*** pbeInsert *** ' + pbeInsert);
                }
            }
            
            // Before checking the other price books let's insert and update the mapping
            // We have to add to the map any inserts before adding to the other Price Books
            if(pbeInsertStd.size() > 0){
                system.debug('Standard Pricebook List: ' + pbeInsertStd);
                insert pbeInsertStd;
            }
            if(pbeInsert.size() > 0){
                System.debug('*** Custom Pricebook Insert *** ' + pbeInsert);
                insert pbeInsert;
            }
            if(pbeUpdate.size() > 0){
                system.debug('Exists Update List: ' + pbeUpdate);
                update pbeUpdate;
            }
            system.debug(' -- Ending Price Book Product Insert --');
        //}
    }
    public static void checkProducts(list<Product2> newTrigger){
        
        if(master_TriggerHelperClass.qd('price_Book_Sync')){
            // Setup
            
            Decimal plistprice;
            string spbId;
            
            set<Product2> plist = new set<Product2>(); // Filtered list of Products
            set<Id> pids = new set<Id>();
            set<String> pkey = new set<String>();
            set<String> sokSet = new set<String>(); // Sales Org Key Set to filter down the list of Price Books
            
            list<String> pbidList = new list<String>();
            list<PricebookEntry> pbeInsert = new list<PricebookEntry>();
            list<PricebookEntry> pbeUpdate = new list<PricebookEntry>();
            
            Map<String, String> pbidMap = new Map<String, String>();
            Map<String, PricebookEntry> pbcheckMap = new Map<String, PricebookEntry>();
            Map<String, PricebookEntry> stdpbcheckMap = new Map<String, PricebookEntry>();
            Map<String, Boolean> productSkipper = new Map<String, Boolean>();
            
            // Build the Work List
            for(Product2 p : newTrigger){
                if(p.Material_Key__c != NULL && p.Sales_Org_Key__c != NULL && p.List_Price__c != NULL){
                    plist.add(p);
                    pids.add(p.Id);
                    sokSet.add(p.Sales_Org_Key__c);
                    pkey.add(p.Material_Key__c);
                }
            }
            system.debug('sokSet: ' + sokSet + ' - plist: ' + plist);
            
            
            // Get the Standard Price Book ID
            if (Test.isRunningTest()) {
                spbId = Test.getStandardPricebookId();
            }
            else{
                spbId = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE].Id;
            }
            
            // Custom Setting to Map the Price Books to the ID
            for(Price_Books__c pb : [SELECT Name, Id__c, Price_Book_Name__c
                                     FROM Price_Books__c
                                     WHERE Name =: sokSet])
            {
                pbidMap.put(pb.Name, pb.Id__c);
                pbidList.add(pb.Id__c);
            }
            system.debug('pbidMap: ' + pbidMap);
            
            
            if(plist.size() > 0) {
                // Check to see if the Product is already in the Price Book
                for(PricebookEntry pbe : [SELECT Product2Id, Material_Key__c, Id, UnitPrice FROM PricebookEntry
                                          WHERE Pricebook2Id =:pbidList
                                          AND Material_Key__c =:pkey ])
                {
                    pbcheckMap.put(pbe.Product2Id, pbe);
                }
                system.debug('pbcheckMap: ' + pbcheckMap);
                
                for(PricebookEntry pbe : [SELECT Product2Id, Id, Material_Key__c, UnitPrice FROM PricebookEntry
                                          WHERE Pricebook2Id =:spbId
                                          AND Material_Key__c =:pkey ])
                {
                    stdpbcheckMap.put(pbe.Product2Id, pbe);
                }
                system.debug('stdpbcheckMap: ' + stdpbcheckMap);
                
                // Second Loop - Look at the other Price Books
                for(Product2 p : plist){
                    
                    if(p.List_Price__c == 0 || p.List_Price__c == NULL){
                        plistprice = 0;
                    }
                    else{
                        plistprice = p.List_Price__c;
                    }
                    
                    if(stdpbcheckMap.containsKey(p.Id)){
                        if(pbcheckMap.containsKey(p.Id)){ // Exists but the List Price has Changed
                            if(pbcheckMap.get(p.Id).UnitPrice != plistprice){ // Exists but the List Price has Changed
                                //system.debug('Updating Price on: ' + p.Material_Key__c + ' in the Sales Org Price Book');
                                PricebookEntry newPBR = new PricebookEntry(
                                    Id = pbcheckMap.get(p.Id).Id,
                                    Pricebook2Id = spbId,
                                    Product2Id = p.Id,
                                    UnitPrice = plistprice,
                                    IsActive = TRUE,
                                    Material_Key__c = p.Material_Key__c,
                                    CurrencyIsoCode = p.CurrencyIsoCode
                                );
                                pbeUpdate.add(newPBR);
                                System.debug('*** Updating Custom Price Book (Exists) *** ' + p.Material_Key__c);
                            }
                        }
                        else if(pbcheckMap.containsKey(p.Id) == FALSE && pbidMap.containsKey(p.Sales_Org_Key__c) == TRUE){ // Doesn't exist in that Product's Sales Org Price Book
                            //system.debug('Adding: ' + p.Material_Key__c + ' to the Sales Org Price Book');
                            PricebookEntry newPBR = new PricebookEntry(
                                Pricebook2Id = pbidMap.get(p.Sales_Org_Key__c),
                                Product2Id = p.Id,
                                UnitPrice = plistprice,
                                IsActive = TRUE,
                                Material_Key__c = p.Material_Key__c,
                                CurrencyIsoCode = p.CurrencyIsoCode
                            );
                            pbeInsert.add(newPBR);
                            System.debug('*** pbeInsert *** ' + pbeInsert);
                        }
                    }
                    
                }
                
                if(pbeInsert.size() > 0){
                    System.debug('*** pbeInsert *** ' + pbeInsert);
                    insert pbeInsert;
                }
                if(pbeUpdate.size() > 0){
                    update pbeUpdate;
                }
                
            }// END IF PLIST is Empty
        }// END master_TriggerHelperClass.runOnce('pbSync')
    }// END of the Class
    
}