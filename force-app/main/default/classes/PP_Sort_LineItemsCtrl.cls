/*********************************************************************
* Description      : Controller Class for PP_Sort_LineItemsCtrl.
* Test Class       : PP_Sort_LineItemsCtrl_Test
* VisualForce      : PP_Sort_LineItemsCtrl
* Author(s)        : Eric Clay
**********************************************************************/
public class PP_Sort_LineItemsCtrl {
    public String strPriceQuote{get; set;}
        public list <priceQuoteLineItems > lstpriceQuoteLineItems {get;set;}
        public Decimal GrandTotal{get;set;}

        public class priceQuoteLineItems {

        public Integer counterWrap{get;set;}
        //public boolean showHidenField {get; set;}
        public String strMaterialnumber {get;set;}
        public String strMaterialStatus {get;set;}
        public String strCrossReference {get;set;}
        public Product2 prod {get;set;}
        //public Decimal eligiblePrice {get;set;}
        public Decimal innerlineprices {get;set;}
        public Cross_Reference__c crossRef {get;set;}
        public Contract_Material__c contractMaterial {get; set;}
        public Price_Quote_Line_Item__c priceQuoteLine {get; set;}
    }

        public PP_Sort_LineItemsCtrl(){
            strPriceQuote = '';
            GrandTotal = 0;
            lstpriceQuoteLineItems = new list <priceQuoteLineItems >();
            strPriceQuote = ApexPages.currentPage().getParameters().get('pqId');
            if(strPriceQuote != '') {
                Integer count =1;
                List<Price_Quote_Line_Item__c> lstlineItems = new List<Price_Quote_Line_Item__c>();
                lstlineItems = [select id,Name, Competetive_Product__c, Competetive_Product__r.Name , Cost_Price__c,Material_Name__c,Material_Name__r.Name,Material_Name__r.Material_Status__c,
                              Quantity__c,Sales_Price__c ,
                              Price_Quote__c, Price_Quote__r.Account_Name__c, Price_Quote__r.Contact_Name__c
                              from Price_Quote_Line_Item__c where Price_Quote__c = :strPriceQuote Order By Row_Order__c];
                              System.debug('---------lstlineItems---------'+lstlineItems[0].Material_Name__r.Name);
                if(lstlineItems.size()>0) {
                    for(Price_Quote_Line_Item__c priceQuoteLineRec :lstlineItems) {
                        priceQuoteLineItems priceWrapper = new priceQuoteLineItems();
                        priceWrapper.counterWrap = count;
                        //System.assertEquals(priceQuoteLineRec.Material_Name__r.Name, null);
                        System.debug('---------priceQuoteLineRec.Material_Name__r.Name---------'+priceQuoteLineRec.Material_Name__r.Name);
                        priceWrapper.strMaterialnumber = priceQuoteLineRec.Material_Name__r.Name;
                        priceWrapper.strMaterialStatus = priceQuoteLineRec.Material_Name__r.Material_Status__c;
                        priceWrapper.priceQuoteLine = priceQuoteLineRec;
                        priceWrapper.innerlineprices = 0;
                        if(priceQuoteLineRec.Sales_Price__c != null && priceQuoteLineRec.Quantity__c != null){
                            priceWrapper.innerlineprices = priceQuoteLineRec.Sales_Price__c*priceQuoteLineRec.Quantity__c;
                        }
                        GrandTotal = GrandTotal + priceWrapper.innerlineprices;
                        lstpriceQuoteLineItems.add(priceWrapper);
                        count++;
                    }//end of for(Price_Quote_Line_Item__c priceQuoteLineRec :lstlineItems)

                    Set<String> setMaterialnumber = new Set<String>();
                    Map<String,priceQuoteLineItems> mapWrapper = new  Map<String,priceQuoteLineItems>();

                    for( priceQuoteLineItems items :lstpriceQuoteLineItems) {
                    	//System.assertEquals(items.strMaterialnumber, null);
                    	System.debug('---------items.strMaterialnumber---------'+items.strMaterialnumber);
                        if(items.strMaterialnumber != null) {
                            setMaterialnumber.add(items.strMaterialnumber);
                        }
                    }//for( priceQuoteLineItems items :lstpriceQuoteLineItems)

                    if(!setMaterialnumber.Isempty()){
                        //List< Product2> lstProduct = new List< Product2>();
                        For( Product2 prd :  [Select id, Name, Description, Cost_Price__c,Sales_Unit__c,Material_Status__c, Qty_Sales_Unit__c, Cost_Price_Unit__c, (Select id, Name,Competitor_Product_Code__c, Competitor_Name__c from Cross_References__r ORDER BY lastmodifiedDate LIMIT 1), (Select Id, Price__c,Agreement__r.Agreement_Number__c, Agreement__r.Description__c from Contract_Material__r ORDER BY lastmodifiedDate LIMIT 1) from  Product2 where Name IN : setMaterialnumber]) {
                            priceQuoteLineItems priceWrapper = new priceQuoteLineItems();
                            priceWrapper.prod = prd;

                            if(prd.Cross_References__r.size()>0)
                                priceWrapper.crossRef = prd.Cross_References__r[0];
                            if(prd.Contract_Material__r.size()>0)
                                priceWrapper.contractMaterial = prd.Contract_Material__r[0];
                            mapWrapper.put(prd.Name ,priceWrapper);
                        }
                    }//end of if(!setMaterialnumber.Isempty())

                    if(!mapWrapper.isEmpty()) {
                        for( priceQuoteLineItems items :lstpriceQuoteLineItems) {
                            if(mapWrapper.containsKey(items.strMaterialnumber)){
                                    items.prod = mapWrapper.get(items.strMaterialnumber).prod;
                                    items.crossRef = mapWrapper.get(items.strMaterialnumber).crossRef;
                                    items.strCrossReference = mapWrapper.get(items.strMaterialnumber).crossRef.Competitor_Product_Code__c;
                                    items.strMaterialnumber  = mapWrapper.get(items.strMaterialnumber).prod.Name;
                                    items.strMaterialStatus = mapWrapper.get(items.strMaterialnumber).prod.Material_Status__c;
                                    items.contractMaterial = mapWrapper.get(items.strMaterialnumber).contractMaterial;
                                    items.prod.Cost_Price__c = mapWrapper.get(items.strMaterialnumber).prod.Cost_Price_Unit__c;
                            }
                        }//end of for( priceQuoteLineItems items :lstpriceQuoteLineItems)
                    }//end of if(!mapWrapper.isEmpty())
                }//end of if(lstlineItems.size()>0)
            }//end of if(strPriceQuote != '')
        }

    @RemoteAction
    public static String saveSortedRows(List<String> rowsIdList) {
        try {
            List<Price_Quote_Line_Item__c> pqliListToUpdate = new List<Price_Quote_Line_Item__c>();

            String messageStr = '';
            Map<id,Price_Quote_Line_Item__c> pqliMap = new Map<id,Price_Quote_Line_Item__c>([Select id from Price_Quote_Line_Item__c Where ID IN:rowsIdList]);
            if(rowsIdList.size() > 0) {
                Price_Quote_Line_Item__c pqObjOpr;
                String idVal;
                for( Integer i=0; i<rowsIdList.size(); i++ ) {
                    pqObjOpr = new Price_Quote_Line_Item__c();
                    idVal = rowsIdList[i];
                    if(pqliMap.containsKey(idVal)) {
                        pqObjOpr = pqliMap.get(idVal);
                        pqObjOpr.Row_Order__c = i;
                        pqliListToUpdate.add(pqObjOpr);
                    }
                }
            }

            if(pqliListToUpdate.size()>0) {
                update pqliListToUpdate;
            }
            return 'True';
        }catch(Exception e) {
            return 'False';
        }
    }
}