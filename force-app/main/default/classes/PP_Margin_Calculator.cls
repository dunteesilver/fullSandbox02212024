/*********************************************************************
* Description      : Controller Class for Margin Calculator.
* Test Class       : PP_Margin_Calculator_Test
* VisualForce      : PP_Margin_Calculator
* Author(s)        : Dun Silver
**********************************************************************/
public with sharing class PP_Margin_Calculator {

    Public String prodSrch {get;set;}
    Public String price {get;set;}
    Public List<Product2> prodRet {get;set;}
    Public Boolean priceListTable {get;set;}
    list<Double> prodPrice = new list<Double>();
    Public Double newCost {get;set;}
    Public Integer convUnit = 1000;
    Public Decimal grossMargin  {get; set;}

    //get active sales org key of User
    public String myActiveSalesOrg { get{

      try{
        myActiveSalesOrg = [SELECT Active_Sales_Org_Key__c
                          FROM Contract_User__c
                          WHERE User__c = :UserInfo.getUserId()
                          LIMIT 1].Active_Sales_Org_Key__c;

        if(myActiveSalesOrg == '' || myActiveSalesOrg == NULL){
            myActiveSalesOrg = 'US6010';
        }
      }
      catch(Exception e){
        System.debug('Exception occured in PP_Margin_Calculator myActiveSalesOrg: ' + e);
      }

      return myActiveSalesOrg;
    } set;}

    public pagereference getURL(){
        system.debug('In PP_Margin_Calculator getURL Method!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        PageReference marginCalculator = New Pagereference('/apex/PP_Margin_Calculator?pid='+prodSrch+'&price='+price);
        marginCalculator.setRedirect(true);
        return marginCalculator;
    }

    Public PP_Margin_Calculator(){
        system.debug('*** In PP_Margin_Calculator Method PP_Margin_Calculator Class ***');
        prodRet = new List<Product2>();
        priceListTable = False;
        prodSrch = ApexPages.currentPage().getParameters().get('pid');
        price = ApexPages.currentPage().getParameters().get('price');
        //check for values in URL variables
        if(prodSrch == '' && price == ''){
            priceListTable = False;
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a Material Number and Price...'));
        }
        else{
            if(prodSrch == '' || price == ''){
                priceListTable = False;
                if(prodSrch == ''){
                    apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a Material Number...'));
                }

                if(price == ''){
                    apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a price...'));
                }

            }
            else{
                if(prodSrch <> null && price <> null){
                    priceListTable = False;
                    //prodRet = [SELECT Name,Description,Cost__c,Sales_Unit__c,Qty_Sales_Unit__c,Transfer_Price__c FROM PRODUCT2 WHERE Name = :prodSrch LIMIT 1];

                    System.debug('prodSrch ===================================== ' + prodSrch);
                    prodRet = [SELECT Name,Description,Cost__c,Sales_Unit__c,Qty_Sales_Unit__c,Transfer_Price__c, Sales_Org_Key__c, Cost_Price_Unit__c,
                                Cost_Formula__c, Cost_Price__c
                              FROM PRODUCT2
                              WHERE Name = :prodSrch AND Sales_Org_Key__c =:myActiveSalesOrg LIMIT 1];
                    System.debug('prodRet ===================================== ' + prodRet);
                    if(prodRet.size()>0 ){
                        System.debug('IM IN IF =====================================');
                        //check if list has values
                        System.debug('prodRet ===================================== ' + prodRet);
                        //System.debug('myDecimal ===================================== ' + myDecimal);
                        priceListTable = True; //set Boolean to true due to list having value

                        if(prodRet[0].Qty_Sales_Unit__c == 0){
                            prodRet[0].Qty_Sales_Unit__c = 1;
                        }

                        //logic to check Cost Price Unit value
                        if(prodRet[0].Cost_Price_Unit__c == NULL){
                            convUnit = 1000;
                        }else{
                            convUnit = Integer.valueOf(prodRet[0].Cost_Price_Unit__c);
                        }

                        system.debug('*** prodRet[0].Cost__c *** ' + prodRet[0].Cost__c);
                        system.debug('*** convUnit *** ' + convUnit);
                        system.debug('*** prodRet[0].Transfer_Price__c *** ' + prodRet[0].Transfer_Price__c);
                        Decimal convertedCost = 0;
                        newCost = (prodRet[0].Cost__c/convUnit) - prodRet[0].Transfer_Price__c;
                        newCost *= prodRet[0].Qty_Sales_Unit__c;
                        system.debug('*** newCost *** ' + newCost);
                        if(!price.isNumeric() ){
                          priceListTable = False;
                          apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a numeric value for price...'));
                        }
                        else{
                          Decimal myDecimal = decimal.valueOf(price);
                          if(myDecimal == 0){
                              priceListTable = False;
                              apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter a price other than 0...'));
                          }
                          else if(myDecimal == NULL){
                            priceListTable = False;
                            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Invalid Price Entered...'));
                          }
                          else{
                              grossMargin = ((myDecimal - newCost)/(myDecimal)).setScale(3) *100;
                              grossMargin = grossMargin.stripTrailingZeros();
                          }
                      }
                    }
                    else{
                        System.debug('IM IN ELSE =====================================');
                        priceListTable = False;
                        apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Material not found...'));
                    }
                    System.debug('THE END =====================================');

                }
            }
        }
    }
}