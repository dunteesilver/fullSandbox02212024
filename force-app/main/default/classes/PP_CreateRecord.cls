/*********************************************************************
* Description      : Controller Class for Create Opportunities for Price Quotes.
* Test Class       : PP_CreateRecord_Test
* Author(s)        : Dun Silver
**********************************************************************/
public without sharing class PP_CreateRecord {

    String prfId = '';
    String quoteId = '';

    public void CreateOppy(List<Price_Quote__c> approvedQuotes){
        //Query for quote record
        List<Opportunity> opps = new List<Opportunity>();
        List<Price_Quote__c> qs = new List<Price_Quote__c>();
        //Map<Id,String> pqOpp = new Map<Id,String>();
        for(Price_Quote__c curr : approvedQuotes){
            System.debug('curr.Status__c =================== ' + curr.Status__c);
            System.debug('curr.No_Opp__c =================== ' + curr.No_Opp__c);
            System.debug('curr.OwnerId =================== ' + curr.OwnerId);
            System.debug('curr.Name =================== ' + curr.Name);
            if(curr.No_Opp__c != true){
                if(curr.Opportunity__c == null && curr.Status__c == 'Approved'){
                    Opportunity newOpp = new Opportunity(
                        Name='Test',
                        CloseDate=curr.Expiration_Date__c,
                        AccountId=curr.Account_Name__c,
                        StageName='Qualified Prospect',
                        Primary_Contact__c=curr.Contact_Name__c,
                        Amount=curr.Grand_Total__c,
                        Product_Family__c='Please Update...',
                        Product_Family_LatAm__c='Please Update...',
                        Price_Quote__c=curr.Id,
                        One_Time_Sale__c = curr.One_Time_Purchase__c,
                        OwnerId=curr.OwnerId
                    );
                    opps.add(newOpp);
                    system.debug('opps========================= '+ opps);

                }
            }//end of if Opp true

        }//end of for loop approvedQuotes
        insert opps;

        for(integer i=0;i<approvedQuotes.size();i++){
            if(approvedQuotes[i].No_Opp__c != true){
                if(approvedQuotes[i].Opportunity__c == null && approvedQuotes[i].status__c == 'Approved'){
                    Price_Quote__c newQ = new Price_Quote__c(id=approvedQuotes[i].id, Opportunity__c=opps[i].id);

                    qs.add(newQ);
                    //opps.add(newOpp);
                    //curr.Opportunity__c = opps[i].id;
                    system.debug('qs========================= '+ qs);
                }//end of if Opp null
            }//end of if Opp true

            If(approvedQuotes[0].Opportunity__c != null){
                Opportunity newOpp = new Opportunity(id=approvedQuotes[0].Opportunity__c,Amount=approvedQuotes[0].Grand_Total__c,
                                                     AccountId=approvedQuotes[0].Account_Name__c,
                                                     Primary_Contact__c=approvedQuotes[0].Contact_Name__c,
                                                     CloseDate=approvedQuotes[0].Expiration_Date__c,OwnerId=approvedQuotes[0].OwnerId);
                opps.add(newOpp);
                system.debug('opps========================= '+ opps);
            }//end of if Opp null

        }//end of for loop

        if(qs.size()>0){
            update qs;
        }

        if(opps.size()>0){
            update opps;
        }

    }//end of CreateOppy Method

    //start of Update Price Quote method
    public void updatePQ(List<String> prfIds){
        List<Price_Quote__c> pq = new List<Price_Quote__c>();
        List<Price_Quote_Line_Item__c> pqli = new List<Price_Quote_Line_Item__c>();
        List<Price_Quote_Line_Item__c> pqli2 = new List<Price_Quote_Line_Item__c>();
        List<String> newPqli = new List<String>();
        List<PRF_Line_Item__c> prfli = new List<PRF_Line_Item__c>();
        String pqStatus = null;

        List<Prf__c> approvedPRF = [SELECT Id, Name, Price_Quote__r.Status__c, Price_Quote__c, Status__c
                               		FROM Prf__c WHERE Id IN :prfIds];
        //List<PRF__c> prfQstatus = [SELECT Id, Name, Price_Quote__c, Price_Quote__r.Status__c FROM PRF__c WHERE name = :approvedPRF[0].Name];
        //if(prfQstatus[0].Price_Quote__c != NULL){
        //for loop gets related Price Quote Id and updates status to In Progress
        //system.debug('approvedPRF size is ***** ' + approvedPRF.size());
        for(PRF__c curr : approvedPRF){
            system.debug('curr.Price_Quote__r.Status__c =================== ' + curr.Price_Quote__r.Status__c);

            pqStatus = curr.Price_Quote__r.Status__c;
            prfId = curr.Id;
            quoteId = curr.Price_Quote__c;
            if(pqStatus !='Approved'){
                system.debug('pqStatus =================== ' + pqStatus);
                if(curr.Status__c == 'Approved'){
                    Price_Quote__c updatedPQ = new Price_Quote__c(
                        Id = quoteId,
                        Status__c = 'In Progress',
                        PRF__c = prfId
                    );

                    pq.add(updatedPQ);
                    system.debug('pq ========================= '+ pq);
                }//end of if Opp true
                else if(curr.Status__c == 'Rejected'){
                    Price_Quote__c updatedPQ = new Price_Quote__c(
                        Id = quoteId,
                        Status__c = 'Rejected',
                        PRF__c = prfId
                    );

                    pq.add(updatedPQ);
                    system.debug('pq ========================= '+ pq);
                }//end of else if

            }//end of quote status if
        }//end of for loop approvedPRF

        if(pqStatus != 'Approved'){
            update pq;
        }

        if(pqStatus !='Approved'){
            system.debug('prfId ***** ' + prfId);
            //get list of PRF Line Items
            /*prfli = [SELECT Id,Condition__c,Current_Price__c,Eligible_Price__c,List_Price__c,Material_Name__c,
                     Material_Status__c,Name,PQLI_ID__c,PRF__c,Rep_Price__c,Requested_Price__c,RSM_Price__c,
                     Sales_Deal_Description__c,Sales_Deal_Num__c,Sales_Deal__c,SAP_Sold_to__c,CurrencyIsoCode
                     FROM PRF_Line_Item__c WHERE PRF__c =:prfId]; */

            //system.debug('prfli ***** ' + prfli);
            //for loop to upsert Line Items of PRF to Price Quote
            for(PRF_Line_Item__c curr : [SELECT Id,Condition__c,Current_Price__c,Eligible_Price__c,List_Price__c,Material_Name__c,
                                         Material_Status__c,Name,PQLI_ID__c,PRF__c,Rep_Price__c,Requested_Price__c,RSM_Price__c,
                                         Sales_Deal_Description__c,Sales_Deal_Num__c,Sales_Deal__c,SAP_Sold_to__c,CurrencyIsoCode
                                         FROM PRF_Line_Item__c
                                         WHERE PRF__c =:prfId])
            {
                system.debug('PRF_Line_Item__c curr Record: ' + curr);
                If(curr.PQLI_ID__c != NULL){
                    Price_Quote_Line_Item__c updLineItems = new Price_Quote_Line_Item__c(
                        Id = curr.PQLI_ID__c,
                        Price_Quote__c = quoteId,
                        Sales_Price__c = curr.Requested_Price__c,
                        Eligible_Price__c = curr.Eligible_Price__c,
                        CurrencyIsoCode = curr.CurrencyIsoCode
                    );
                    pqli.add(updLineItems);
                }
                else{
                    Price_Quote_Line_Item__c updLineItems = new Price_Quote_Line_Item__c(
                        Price_Quote__c = quoteId,
                        Condition__c = curr.Condition__c,
                        Eligible_Price__c = curr.Eligible_Price__c,
                        List_Price__c = curr.List_Price__c,
                        RSM_Price__c = curr.RSM_Price__c,
                        Rep_Price__c = curr.Rep_Price__c,
                        Sales_Price__c = curr.Requested_Price__c,
                        Material_Name__c = curr.Material_Name__c,
                        Material_Status__c = curr.Material_Status__c,
                        Sales_Deal_Description__c = curr.Sales_Deal_Description__c,
                        Sales_Number__c = curr.Sales_Deal_Num__c,
                        Sales_Deal__c = curr.Sales_Deal__c,
                        CurrencyIsoCode = curr.CurrencyIsoCode,
                        Quantity__c = 1
                    );

                    pqli2.add(updLineItems);
                }

            }//end of PRF_Line_Item__c for loop

            //update current Line Items
            if(pqli.size()>0){
                system.debug('pqli ***** ' + pqli);
                //update pqli;
                Database.update(pqli,false);
            }

            if(pqli2.size()>0){
                system.debug('pqli2 ***** ' + pqli2);
                //insert pqli2;
                Database.update(pqli2,false);
            }
        }//end if for quote status check

        //}//if to check for attached Price Quote
    }
    //end of Update Price Quote method

}//end of class