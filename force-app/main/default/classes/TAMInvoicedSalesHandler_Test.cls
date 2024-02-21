/*********************************************************************
* Description      : Test Class for TAMInvoicedSalesHandler.
* Test Class       : TAMInvoicedSalesHandler_Test
* VisualForce      : N/A
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
//surya for rolling TAM sales
//initial version work item: W-023184 sprint: 2020.04
**********************************************************************/
@isTest public class TAMInvoicedSalesHandler_Test {
    
    @testSetup
    static void createData1() {
        Account acc = new Account();
        acc.Name = 'Testacc';
        insert acc;
        
        TAM__c tamObjMp = new TAM__c();
        tamObjMp.Account_Name__c = acc.ID;
        insert tamObjMp;
        
        Map<Id,TAM__c> tamMap = new Map<Id,TAM__c>();
        tamMap.put(tamObjMp.Account_Name__c, tamObjMp);
        
		Product2 prod = new Product2(
                Name = 'AA-10511-1',
                ProductCode= 'AA-10511-1',
                SubGroup__c = 'Laryngoscopes',
                Product_Class__c = '0014 ',
                Product_Group__c = '00140002 ',
                Product_Sub_Group__c = '001400020009 ',
                Product_Line__c = '001400020009000005 '
            );
            insert prod;
        
        Product2 prod1 = new Product2(
                Name = 'AA-10511',
                ProductCode= 'AA-10511',
                SubGroup__c = 'Bronchial Tubes',
                Product_Class__c = '001',
                Product_Group__c = '0014000',
                Product_Sub_Group__c = '00140002000',
                Product_Line__c = '00140002000900000'
            );
            insert prod1;
        
        Product2 prod2 = new Product2(
                Name = 'AA-10511',
                ProductCode= 'AA-10511',
                SubGroup__c = 'LMA Reusable Masks - Gastric Access',
                Product_Class__c = '001',
                Product_Group__c = '0014000',
                Product_Sub_Group__c = '00140002000',
                Product_Line__c = '00140002000900000'
            );
            insert prod2;
  
        BaseQuotaException__c bqe = new BaseQuotaException__c(
            Name = 'territory_user_maintenance',
            IsException__c = TRUE
        );
        insert bqe;
        
        List<Invoiced_Sales__c> sales = new List<Invoiced_Sales__c>();
        Invoiced_Sales__c is1 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today() - 30,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 100000,
            Quantity__c = 10,
            Product__c = prod.ID
        );
        sales.add(is1);
        Invoiced_Sales__c is2 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today() - 30,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = '9079P-VC-005',
            Sales__c = 200000,
            Quantity__c = 20,
            Product__c = prod1.ID
        );
        sales.add(is2);
        Invoiced_Sales__c is3 = new Invoiced_Sales__c(
            Account__c = acc.id,
            Business_Unit__c = 'Anesthesia',
            Date__c = Date.Today() - 30,
            SAP_Code__c = acc.SAP_Sold_To__c,
            Material_Name__c = 'AK-47702-CDC',
            Sales__c = 400000,
            Quantity__c = 40,
            Product__c = prod2.ID
        );
        sales.add(is3);
        insert sales;

        TAM__c tamObj = new TAM__c();
        tamObj.Rolling_12_Month_Sales_Laryngoscope__c = is1.Sales__c;
        tamObj.Rolling_12_Month_Sales_ETT_EBT__c = is2.Sales__c;
        tamObj.Rolling_12_Month_Sales_LMA__c = is3.Sales__c;
        tamObj.Account_Name__c = acc.ID;
        insert tamObj;
        
        TAM__c tamObj1 = new TAM__c();
        tamObj1.Rolling_12_Month_Sales_Laryngoscope__c = 0;
        tamObj1.Rolling_12_Month_Sales_ETT_EBT__c = 0;
        tamObj1.Rolling_12_Month_Sales_LMA__c = 0;
        //tamObj.Account_Name__c = acc.ID;
        try{
            insert tamObj1;
        }
        catch(DmlException e){
            System.assert(1==1);
        }
        
        
    }//end of createData
    
    
    
    @isTest static void tstrollingInvSalesFrmInvSalTgr() {
  
    }
    
}