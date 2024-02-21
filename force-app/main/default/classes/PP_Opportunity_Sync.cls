/*********************************************************************
* Description      : Controller Class for Pricing Portal Opportunity Sync.
* Test Class       : PP_Opportunity_Sync_Test
* VisualForce      : PP_Price_Quote
* Author(s)        : Eric Clay
**********************************************************************/
public class PP_Opportunity_Sync {
    // Test Class: PP_Opportunity_Sync_Test
    // Test Class(2): PP_Global_Test_Class

    public static void addOLI(list<Price_Quote_Line_Item__c> newTrigger){

        system.debug('-- Starting the addOLI Class: ' + newTrigger);

        if(master_TriggerHelperClass.runOnce('addOLI')){
            //boolean activeCheck;

            set<Id> plist = new set<Id>(); // Set of Id's for querying the Price Book Products
            set<String> salesdealnum = new set<String>(); // Set for capturing the Sales/Contract Numbers

            list<Price_Books__c> pbList = Price_Books__c.getall().values(); // Creates list of all Price Book entries from the custom setting 'Price Book'
            list<Price_Quote_Line_Item__c> pqliList = new list<Price_Quote_Line_Item__c>();
            list<OpportunityLineItem> newOLI = new list<OpportunityLineItem>(); // List for new Opportunity line items

            Map<String, String> pbcheckMap = new Map<String, String>(); // Map for checking with the product is in the price book
            Map<Id, Id> pqliMap = new Map<Id, Id>(); // PQ to Opp ID


            // Work

            // Loop through the line item(s) to create a list of Material/Product ID's and Contract Numbers
            for(Price_Quote_Line_Item__c pqli : newTrigger){
                system.debug('pqli: ' + pqli);
                system.debug('IsActive__c & OpportunityId__c: ' + + pqli.IsActive__c + ' & ' + pqli.OpportunityId__c);

                /*if(pqli.IsActive__c == NULL){
                    activeCheck = TRUE;
                }else{
                    activeCheck = pqli.IsActive__c;
                }/*/

                if(pqli.Material_Name__c != NULL && pqli.OpportunityId__c != NULL && pqli.IsActive__c){
                  // This filters out blanks lines
                    plist.add(pqli.Material_Name__c);
                    pqliList.add(pqli);
                    pqliMap.put(pqli.Price_Quote__c, pqli.OpportunityId__c);
                }

                if(pqli.Sales_Number__c != NULL){ // This is used for the Contract Map
                    salesdealnum.add(pqli.Sales_Number__c);
                }

            }
            if(pqliList.size() > 0){

                list<String> pbidList = new list<String>(); // List for Price Book ID's from the Price Book Custom Setting
                list<Price_Quote_Line_Item__c> updatePQLI_oliId = new list<Price_Quote_Line_Item__c>(); // List for updating the Price Quote Line Item with the Opportunity Products Line ID
                Map<String, String> cidMap = new Map<String, String>(); // Map for storing the Contract Number to ID
                Map<String, String> oliIdMap = new Map<String, String>(); // Map for storing the 2 ID's

                // Build list of Price Book ID's from the Custom Setting Object
                for(Price_Books__c pb : pbList){
                    pbidList.add(pb.Id__c);
                }
                system.debug('pbidList: ' + pbidList);

                // Create Contract Number to Contract ID Mapping for the Opportunity Line Item "Contract" field
                for(Contract_Header__c ch : [SELECT ID, Agreement_Number__c
                                             FROM Contract_Header__c
                                             WHERE Agreement_Number__c =:salesdealnum])
                {
                    cidMap.put(ch.Agreement_Number__c, ch.Id);
                }
                system.debug('cidMap: ' + cidMap);

                // Create the Price Book map for validating the product is in the Price Book AND
                // creating the Opportunity Product Line Item (Need that ID!)
                for(PricebookEntry pbe : [SELECT Product2Id, Id, Product2.Sales_Org_Key__c FROM PricebookEntry
                                          WHERE Pricebook2Id =:pbidList
                                          AND Product2Id =:plist ])
                {
                    pbcheckMap.put(pbe.Product2Id, pbe.Id);
                }
                system.debug('pbcheckMap: ' + pbcheckMap);

                for(Price_Quote_Line_Item__c pqli : pqliList){
                    if(pbcheckMap.get(pqli.Material_Name__c) != NULL && pqli.Quantity__c != 0){
                        system.debug(' -- Adding Product! -- ');
                        system.debug('Product Description: ' + pqli.Material_Name__r.Description);
                        OpportunityLineItem oli = new OpportunityLineItem(
                            //Description = pqli.Product_Description__c, //
                            Description = pqli.Description__c,
                            OpportunityId = pqli.OpportunityId__c,
                            PricebookEntryId = pbcheckMap.get(pqli.Material_Name__c),
                            Quantity = pqli.Quantity__c,
                            //SortOrder = pqli.Row_Order__c,
                            UnitPrice = pqli.Sales_Price__c,
                            Rep_Price__c = pqli.Rep_Price__c,
                            RSM_Price__c = pqli.RSM_Price__c,
                            Eligible_Price__c = pqli.Eligible_Price__c,
                            Price_Quote_Line_Item_ID__c = pqli.Id
                        );
                        if(pqli.Sales_Number__c != NULL){
                            oli.Contract__c = cidMap.get(pqli.Sales_Number__c);
                        }
                        system.debug('New Line Item: ' + oli);
                        newOLI.add(oli);
                    }
                } // End For Loop

                // Insert the new records
                system.debug('Inserting! -- ' + newOLI);
                if(newOLI.size() > 0){
                    insert newOLI;
                    system.debug('Inserting! -- ' + newOLI);
                }

                // Time to update the Price Quote Line Items with the Opportunity Line ID
                for(OpportunityLineItem oli : newOLI)
                {
                    oliIdMap.put(oli.Price_Quote_Line_Item_ID__c, oli.Id);
                }

                // Create the list of Price Quote Line Item's to update
                for(Price_Quote_Line_Item__c pqli : pqliList)
                {
                    if(oliIdMap.get(pqli.Id) != NULL){
                        Price_Quote_Line_Item__c updatePQLI = new Price_Quote_Line_Item__c(
                            Id = pqli.Id,
                            Opportunity_Products_Line_ID__c  = oliIdMap.get(pqli.Id)
                        );
                        updatePQLI_oliId.add(updatePQLI);
                    }
                }
                if(updatePQLI_oliId.size() > 0){
                    update updatePQLI_oliId;
                }
                system.debug('-- Finished the addOLI Class --');

            } // Last Work If
        } // END master_TriggerHelperClass.runOnce - addOLI

    }

    public static void updateOLI(list<Price_Quote_Line_Item__c> newTrigger){

        system.debug('-- Starting the updateOLI Class: ' + newTrigger);

        if(master_TriggerHelperClass.runOnce('updateOLI')){

            set<String> salesdealnum = new set<String>(); // Set for capturing the Sales/Contract Numbers
            Map<String, String> cidMap = new Map<String, String>(); // Map for storing the Contract Number to ID
            list<Price_Quote_Line_Item__c> pqliList = new list<Price_Quote_Line_Item__c>();
            list<OpportunityLineItem> updateOLI = new list<OpportunityLineItem>(); // List for updating existing Opportunity line items

            // Check to see if we have work to do...
            for(Price_Quote_Line_Item__c pqli : newTrigger){
                if(pqli.Opportunity_Products_Line_ID__c != NULL) // Make sure we have an OLI ID
                    //pqli.Material_Name__c != NULL // Make sure there is a related Material - Might be redundant
                    //&& pqli.OpportunityId__c != NULL // Make sure we still have an opportunity related to the PQLI - Might be redundant
                {
                    pqliList.add(pqli);
                }
                if(pqli.Sales_Number__c != NULL){ // This is used for the Contract Map
                    salesdealnum.add(pqli.Sales_Number__c);
                }
            }

            // We got work to do...
            if(pqliList.size() > 0){
                // Map the does a lookup on Contract Number for the Contract Lookup on the OLI
                for(Contract_Header__c ch : [SELECT ID, Agreement_Number__c
                                             FROM Contract_Header__c
                                             WHERE Agreement_Number__c =:salesdealnum])
                {
                    cidMap.put(ch.Agreement_Number__c, ch.Id);
                }
                system.debug('cidMap: ' + cidMap);

                system.debug(' -- Updating Product! -- ');

                for(Price_Quote_Line_Item__c pqli : pqliList){
                    OpportunityLineItem oli = new OpportunityLineItem(
                        Id = pqli.Opportunity_Products_Line_ID__c,
                        Description = pqli.Description__c,
                        Quantity = pqli.Quantity__c,
                        //SortOrder = pqli.Row_Order__c, // Cannot write to SortOrder -- So Sad ;(
                        UnitPrice = pqli.Sales_Price__c,
                        Rep_Price__c = pqli.Rep_Price__c,
                        RSM_Price__c = pqli.RSM_Price__c,
                        Eligible_Price__c = pqli.Eligible_Price__c
                    );
                    if(pqli.Sales_Number__c != NULL){
                        oli.Contract__c = cidMap.get(pqli.Sales_Number__c);
                    }
                    updateOLI.add(oli);
                    system.debug('updateOLI: ' + updateOLI);
                }
                if(updateOLI.size() > 0){
                    update updateOLI;
                }
            }

        }
        system.debug('-- Finished the updateOLI Class --');
    }

    public static void delOpportunityLines(set<Id> oliID){
        system.debug('-- Starting the delOpportunityLines Class: ' + oliID);
        list<OpportunityLineItem> delOLI = [SELECT Id
                                            FROM OpportunityLineItem
                                            WHERE Id =:oliID];
        if(delOLI.size() > 0){
            system.debug('-- Cleaning out Line Items - delOLI: ' + delOLI);
            delete delOLI;
        }
        system.debug('-- Finished the delOpportunityLines Class --');
    }

    public static void remove_PQOLI_ID(list<OpportunityLineItem> newTrigger){
        system.debug('-- Starting the remove_PQOLI_ID Class: ' + newTrigger);
        // This Class tries to remove the Opportunity ID From the Price Quote Line Item if that line still exists.
        // For Delete's of PQLI's it will fail (silently) but for deletion of OLI's it will succeed. This will happen
        // When users switch the Active Quote or Delete the line item off the Opportunity from the Opportunity.
        //
        // Critical for Updating PQLI's
        set<Id> removePQLI_ID = new set<Id>();
        list<Price_Quote_Line_Item__c> uPQLI = new list<Price_Quote_Line_Item__c>();
        for(OpportunityLineItem oli : newTrigger){
            if(oli.Price_Quote_Line_Item_ID__c != NULL){
                removePQLI_ID.add(oli.Price_Quote_Line_Item_ID__c);
            }
        }
        if(removePQLI_ID.size() > 0){
            for(Price_Quote_Line_Item__c pqli : [SELECT ID FROM Price_Quote_Line_Item__c
                                                 WHERE ID =: removePQLI_ID
                                                AND Opportunity_Products_Line_ID__c != NULL])
            {
                Price_Quote_Line_Item__c updPQLI = new Price_Quote_Line_Item__c(
                    Id = pqli.Id,
                    Opportunity_Products_Line_ID__c = ''
                );
                uPQLI.add(updPQLI);
            }
            if(uPQLI.size() > 0){
                update uPQLI;
            }
        }
        system.debug('-- Starting the remove_PQOLI_ID Class --');
    }

    public static void delOpportunityLines_trigger(list<Price_Quote_Line_Item__c> oldTrigger){
        system.debug('-- Starting the delOpportunityLines_trigger Class: ' + oldTrigger);
        set<Id> removeOLI = new set<Id>();

        for(Price_Quote_Line_Item__c pqli : oldTrigger){
            if(pqli.Opportunity_Products_Line_ID__c != NULL){
                removeOLI.add(pqli.Opportunity_Products_Line_ID__c);
            }
        }

        if(removeOLI.size() > 0){
            system.debug('Deleting Lines: ' + removeOLI);
            PP_Opportunity_Sync.delOpportunityLines(removeOLI);
        }
        system.debug('-- Finished the delOpportunityLines_trigger Class --');
    }

    public static void updateOpp(list<Price_Quote__c> newTrigger,map<Id, Price_Quote__c> oldTrigger,string triggerType){
        system.debug('-- Starting the updateOpp Class: (' + triggerType + '):' + newTrigger);
        if(master_TriggerHelperClass.runOnce('updateOpp')){
            list<Opportunity> updOpp = new list<Opportunity>();
            for(Price_Quote__c pq : newTrigger){
                if(triggerType == 'insert'){
                    if(pq.Opportunity__c != NULL){
                        Opportunity newOppRec = new Opportunity(
                            Id = pq.Opportunity__c,
                            Price_Quote__c = pq.Id
                        );
                        updOpp.add(newOppRec);
                    }
                }
                else{
                    if(oldTrigger.get(pq.Id).Opportunity__c != pq.Opportunity__c){
                        Opportunity newOppRec = new Opportunity(
                            Id = pq.Opportunity__c,
                            Price_Quote__c = pq.Id
                        );
                        updOpp.add(newOppRec);
                    }

                    //update one time purchase checkbox
                    if(oldTrigger.get(pq.Id).One_Time_Purchase__c != pq.One_Time_Purchase__c && pq.IsActive__c){
                      Opportunity newOppRec = new Opportunity(
                          Id = pq.Opportunity__c,
                          One_Time_Sale__c = pq.One_Time_Purchase__c
                      );
                      updOpp.add(newOppRec);
                    }
                }
            }
            if(updOpp.size() > 0){
                update updOpp;
            }
        }
        system.debug('-- Finished the updateOpp Class --');
    }

    public static void updatePQ(list<Opportunity> newTrigger,map<Id, Opportunity> oldTrigger, string triggerType){

        system.debug('-- Starting the updatePQ Class: (' + triggerType + '):' + newTrigger);
        if(master_TriggerHelperClass.runOnce('updatePQ')){
            boolean updatePQ = FALSE;
            boolean changePQ = FALSE;

            set<Id> activePQ = new set<Id>();
            set<Id> removeLines = new set<Id>();

            list<Price_Quote__c> pqUpdate = new list<Price_Quote__c>();

            map<String, String> updateMap = new map<String, String>();
            map<String, String> changedMap = new map<String, String>();


            // Determine if the record(s) need to be processed and build the PQ and Opp Set's of Id's
            for(Opportunity o : newTrigger){
                updatePQ = FALSE; // Drives whether we should write the Opportunity ID back to the Price Quote
                changePQ = FALSE;

                if(triggerType == 'insert'){
                    system.debug(' -- Opportunity Type: New Record --');
                    if(o.Price_Quote__c != NULL){ // New Record
                        system.debug(' -- Opportunity Type: Opportunity Created with Price Quote --');
                        updateMap.put(o.Id, o.Price_Quote__c);
                        activePQ.add(o.Price_Quote__c);
                        updatePQ = TRUE;
                    }
                }
                else if(
                    oldTrigger.get(o.Id).Price_Quote__c == NULL // Price Quote Added to existing Opportunity
                    && o.Price_Quote__c != NULL
                )
                {
                    system.debug(' -- Opportunity Type: Price Quote Added to Existing Opportunity --');
                    updateMap.put(o.Id, o.Price_Quote__c);
                    activePQ.add(o.Price_Quote__c);
                    updatePQ = TRUE;
                    changePQ = TRUE;
                }
                else if(
                    o.Price_Quote__c != oldTrigger.get(o.Id).Price_Quote__c // Price Quote has Changed
                    && oldTrigger.get(o.Id).Price_Quote__c != NULL // Price Quote defined on the old record
                    && o.Price_Quote__c != NULL // Price Quote defined on the new record
                ){
                    system.debug(' -- Opportunity Type: Price Quote Exists and Switched --');
                    updateMap.put(o.Id, o.Price_Quote__c);
                    activePQ.add(o.Price_Quote__c);
                    updatePQ = TRUE;
                    changePQ = TRUE;
                }

                if(o.HasOpportunityLineItem && changePQ){ // Builds set of Id's to remove line items
                    removeLines.add(o.Id);
                }

                if(updatePQ){
                    Price_Quote__c pq = new Price_Quote__c(
                        Id = o.Price_Quote__c,
                        Opportunity__c = o.Id
                    );
                    pqUpdate.add(pq);
                }
            }

            if(pqUpdate.size() > 0){
                update pqUpdate;
            }

            // Clearing out the existing Opportunity Line Items
            if(removeLines.size() > 0){
                list<OpportunityLineItem> delOLI = new list<OpportunityLineItem>();
                for(OpportunityLineItem oli : [SELECT Id
                                               FROM OpportunityLineItem
                                               WHERE OpportunityId =:removeLines])
                {
                    delOLI.add(oli);
                }
                system.debug('-- Cleaning out Line Items - delOLI: ' + delOLI);
                if(delOLI.size() > 0){
                    delete delOLI;
                }
            }

            // Build the list of Price Quote Line Item's that will build out the Opp Line Item's
            system.debug('Price Quote ID: ');
            list<Price_Quote_Line_Item__c> pqliList = new list<Price_Quote_Line_Item__c>();
            for(Price_Quote_Line_Item__c pqli : [SELECT Id, Opportunity_Products_Line_ID__c, Product_Description__c,
                                                 OpportunityId__c, Material_Name__c, Quantity__c, Sales_Price__c,
                                                 Rep_Price__c, RSM_Price__c, Eligible_Price__c, Sales_Number__c,
                                                 IsActive__c, Price_Quote__c, Opportunity_Closed__c, Sales_Org_Key__c,
                                                 Material_Name__r.Description, Description__c
                                                 FROM Price_Quote_Line_Item__c
                                                 WHERE Price_Quote__c =:activePQ])
            {
                pqliList.add(pqli);
            }


            // Pass the list to the method that will do all the work
            system.debug('-- Add addOpportunityLines in the changeActivePQ Class: ' + pqliList);
            if(pqliList.size() > 0){
                PP_Opportunity_Sync.addOLI(pqliList);
            }

            // Check to make sure this Price Quote is not on another Opportunity
            if(activePQ.size() > 0){
                list<Opportunity> removePQ = new list<Opportunity>();

                for(Opportunity o : [SELECT ID, Price_Quote__c
                                     FROM Opportunity
                                     WHERE Price_Quote__c =:activePQ
                                     AND Id NOT IN :newTrigger])
                {
                    Opportunity rPQ = new Opportunity(
                        Id = o.Id,
                        Price_Quote__c = NULL
                    );
                    removePQ.add(rPQ);
                }
                if(removePQ.size() > 0){
                    update removePQ;
                }
            }

        }
        system.debug('-- Finished the updatePQ Class --');
    } // End Class

} // End of the Class