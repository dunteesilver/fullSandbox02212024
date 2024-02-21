public with sharing class LATAM_RR {
//AggregateResult 
    //public map<String, Double> megamap { get; set; }
    public list<String> getpgs(){
        Map<String, LATAM_RR_Products__c > csMap = LATAM_RR_Products__c.getAll();
        set<String> csSet = csMap.keySet();
        list<String> pgs_list = new list<String>();
        list<String> temp_list = new list<String>();
        temp_list.addall(csSet);
        temp_list.sort();
        pgs_list.add('Total');
        pgs_list.addall(temp_list);

        /*
         * Vascular, Total, VSI, Cardiac, Respiratory, Surgical, Urology, Interventional, Anesthesia
		list<String> pgs_list = new list<String>();
		pgs_list.add('Total');
        pgs_list.add('Anesthesia');
        pgs_list.add('Respiratory');
        pgs_list.add('Cardiac');
        pgs_list.add('Interventional');
        pgs_list.add('Surgical');
        pgs_list.add('Urology');
        pgs_list.add('Vascular');
        pgs_list.add('LMA');
*/
        system.debug('pgs_list' + pgs_list);
        return pgs_list;
    }
    public list<string> getRegions(){

        Map<String, LATAM_RR_Regions__c > csMap = LATAM_RR_Regions__c.getAll();
        set<String> csSet = csMap.keySet();
        list<String> rlist = new list<String>();
        list<String> temp_list = new list<String>();
        temp_list.addall(csSet);
        temp_list.sort();
        rlist.add('Total Region');
        rlist.addall(temp_list);
        /*
        rlist.add('Brazil');
        rlist.add('Central America - North Cone');
        rlist.add('Mexico');
        rlist.add('Southern Cone');
        rlist.add('US Exports');
        rlist.add('Venezuela');
        rlist.add('Chile');
        rlist.add('Total Region');*/
        return rlist;
    }
    public string year = '2018';//String.valueOf(System.Today().year());
    
    
    public map<string, double> getmegamap(){
        system.debug('Starting LATAM_RR Class!');
        string lst_key;
        double lst_amount;
        string ltt_key;
        double ltt_amount;
        
        //LATAM_RR_Regions__c 
        //LATAM_RR_Products
        
        Map<String, LATAM_RR_Products__c > csphMap = LATAM_RR_Products__c.getAll();
        set<String> csphSet = csphMap.keySet();
        list<String> pgs_list = new list<String>();
        pgs_list.addAll(csphSet);
        pgs_list.sort();
        pgs_list.add('Total');
        /*
        
        pgs_list.add('Anesthesia');
        pgs_list.add('Cardiac');
        pgs_list.add('Respiratory');
        pgs_list.add('Surgical');
        pgs_list.add('Urology');
        pgs_list.add('Vascular');
        pgs_list.add('Interventional');
        pgs_list.add('LMA');*/
        
        Map<String, LATAM_RR_Regions__c > csrrMap = LATAM_RR_Regions__c.getAll();
        set<String> csrrSet = csrrMap.keySet();
        list<String> rlist = new list<String>();
        rlist.addAll(csrrSet);
        rlist.sort();
        rlist.add('Total Region');
        /*
        rlist.add('Brazil');
        rlist.add('Central America - North Cone');
        rlist.add('Mexico');
        rlist.add('Southern Cone');
        rlist.add('US Exports');
        rlist.add('Venezuela');
        rlist.add('Chile');
        rlist.add('Colombia');
        
        */
        
        
        set<String> acct_set = new set<String>();
        for(AggregateResult ar : [SELECT Account_Name__c 
                                  //   FROM Latam_Sales_Transactions__c 
                                  FROM LATAM_Target__c 
                                  WHERE Account_Name__c != NULL
                                  AND Year__c = :year
                                  GROUP BY Account_Name__c])
        {
            acct_set.add((string) ar.get('Account_Name__c')); 
        }
        
        system.debug('acct_set' + acct_set);
        list<Account> alist = [SELECT RR_ID__c, Name  
                               FROM Account 
                               WHERE Name IN :acct_set 
                               AND RR_ID__c != NULL
                               AND Sales_Region__c  != NULL];

        
        map<string, double> megamap = new map<string, double>();
        for(AggregateResult ar : [SELECT Account_Name__c, Sum(Transaction_Amount__c) Amount, Product_family1__c ProductFamily 
                                  FROM Latam_Sales_Transactions__c   
                                  WHERE Account_Name__c != NULL 
                                  //AM Add this to filter by the current year
                                  AND Transaction_Date__c = LAST_YEAR
                                  AND Transaction_Amount__c != NULL 
                                  AND Product_Family1__c != NULL
                                  GROUP BY ROLLUP(Account__r.Sales_Region__c, Account_Name__c, Product_Family1__c)])
        {
            lst_key = (string) ar.get('Account_Name__c') + ar.get('ProductFamily') + 'LST';
            //system.debug('lst_key: ' + lst_key);
            lst_amount = (double) ar.get('Amount');
            //system.debug('lst_amount: ' + lst_amount);
            
            megamap.put(lst_key, lst_amount);
            //system.debug('megamap' + megamap);
        }
        
        for(AggregateResult ar : [SELECT Account_Name__c, Sum(Transaction_Amount__c) Amount, Product_family1__c ProductFamily 
                                  FROM LATAM_Order_Transaction__c   
                                  WHERE Account_Name__c != NULL 
                                  //AM Add this to filter by the current year
                                  AND Required_Date__c <= LAST_YEAR
                                  AND Transaction_Amount__c != NULL 
                                  AND Product_Family1__c != NULL
                                  GROUP BY ROLLUP(Account__r.Sales_Region__c, Account_Name__c, Product_Family1__c)])
        {
            lst_key = (string) ar.get('Account_Name__c') + ar.get('ProductFamily') + 'LOT';
            //system.debug('lst_key: ' + lst_key);
            lst_amount = (double) ar.get('Amount');
            //system.debug('lst_amount: ' + lst_amount);
            
            megamap.put(lst_key, lst_amount);
            //system.debug('megamap' + megamap);
        }
        //---
        
        for(AggregateResult ar : [SELECT Account_Name__c, Sum(Target_Amount__c) Amount, Product_family__c ProductFamily 
                                  FROM LATAM_Target__c   
                                  WHERE Account_Name__c != NULL
                                  AND Year__c = : year
                                  AND Target_Amount__c != NULL 
                                  AND Product_Family__c != NULL
                                  GROUP BY ROLLUP(Account__r.Sales_Region__c, Account_Name__c, Product_Family__c)])
        {
            ltt_key = (string) ar.get('Account_Name__c') + ar.get('ProductFamily') + 'LTT';
            //system.debug('ltt_key: ' + ltt_key);
            ltt_amount = (double) ar.get('Amount');
            //system.debug('ltt_amount: ' + ltt_amount);
            
            megamap.put(ltt_key, ltt_amount);
            //system.debug('megamap' + megamap);
        
        }
        
        // Aggregate for the Rollup by Region
        for(AggregateResult ar : [SELECT Sum(Transaction_Amount__c) Amount, Product_family1__c ProductFamily, Sales_Region__c     
                                  FROM Latam_Sales_Transactions__c    
                                  WHERE Account_ID__c != NULL 
                                   //AM Add this to filter by the current year
                                  AND Transaction_Date__c = LAST_YEAR
                                  AND Transaction_Amount__c != NULL 
                                  AND Product_Family1__c != NULL 
                                  GROUP BY ROLLUP(Sales_Region__c, Product_Family1__c)])
        {
            // Key will be Sales Region + Product Family + LST
            ltt_key = (string) ar.get('Sales_Region__c') + ar.get('ProductFamily') + 'LST';
            //system.debug('ltt_key: ' + ltt_key);
            ltt_amount = (double) ar.get('Amount');
            //system.debug('ltt_amount: ' + ltt_amount);
            
            megamap.put(ltt_key, ltt_amount);
            //system.debug('megamap' + megamap);
            
            // If we get nulls for this, we can put in a check to make sure the amount is not NULL/Zero
        
        }
        
        // Aggregate for the Rollup by Region
        for(AggregateResult ar : [SELECT Sum(Transaction_Amount__c) Amount, Product_family1__c ProductFamily, Sales_Region__c     
                                  FROM LATAM_Order_Transaction__c   
                                  WHERE Account_ID__c != NULL 
                                  //AM Add this to filter by the current year
                                  AND Required_Date__c <= LAST_YEAR
                                  AND Transaction_Amount__c != NULL 
                                  AND Product_Family1__c != NULL 
                                  GROUP BY ROLLUP(Sales_Region__c, Product_Family1__c)])
        {
            // Key will be Sales Region + Product Family + LST
            ltt_key = (string) ar.get('Sales_Region__c') + ar.get('ProductFamily') + 'LOT';
            //system.debug('ltt_key: ' + ltt_key);
            ltt_amount = (double) ar.get('Amount');
            //system.debug('ltt_amount: ' + ltt_amount);
            
            megamap.put(ltt_key, ltt_amount);
            //system.debug('megamap' + megamap);
            
            // If we get nulls for this, we can put in a check to make sure the amount is not NULL/Zero
            
        }
        
        // Aggregate for the Rollup by Region
        for(AggregateResult ar : [SELECT Sum(Target_Amount__c) Amount, Product_family__c ProductFamily, Sales_Region__c     
                                  FROM LATAM_Target__c   
                                  WHERE Account_Name__c != NULL 
                                  AND Target_Amount__c != NULL 
                                  AND Year__c = : year
                                  AND Product_Family__c != NULL 
                                  GROUP BY ROLLUP(Sales_Region__c, Product_Family__c)])
        {
            // Key will be Sales Region + Product Family + LST
            ltt_key = (string) ar.get('Sales_Region__c') + ar.get('ProductFamily') + 'LTT';
            //system.debug('ltt_key: ' + ltt_key);
            ltt_amount = (double) ar.get('Amount');
            //system.debug('ltt_amount: ' + ltt_amount);
            
            megamap.put(ltt_key, ltt_amount);
            //system.debug('megamap' + megamap);
            
            // If we get nulls for this, we can put in a check to make sure the amount is not NULL/Zero
            
        }
        
        // By Account - Invoiced Orders
        for(AggregateResult ar : [SELECT Account_Name__c, Sum(Transaction_Amount__c) Amount, Sales_Region__c 
                                  FROM Latam_Sales_Transactions__c   
                                  WHERE Account_Name__c != NULL 
                                  //AM Add this to filter by the current year
                                  AND Transaction_Date__c = LAST_YEAR
                                  GROUP BY ROLLUP(Sales_Region__c, Account_Name__c)])
        {
            lst_key = (string) ar.get('Account_Name__c') + 'TotalLST';
            //system.debug('lst_key: ' + lst_key);
            lst_amount = (double) ar.get('Amount');
            //system.debug('lst_amount: ' + lst_amount);
            
            megamap.put(lst_key, lst_amount);
            //system.debug('megamap' + megamap);
        }
        
        // By Account - Open Orders Sales
        for(AggregateResult ar : [SELECT Account_Name__c, Sum(Transaction_Amount__c) Amount, Sales_Region__c 
                                  FROM LATAM_Order_Transaction__c  
                                  WHERE Account_Name__c != NULL 
                                  //AM Add this to filter by the current year
                                  AND Required_Date__c <= LAST_YEAR
                                  GROUP BY ROLLUP(Sales_Region__c, Account_Name__c)])
        {
            lst_key = (string) ar.get('Account_Name__c')  + 'TotalLOT';
            //system.debug('lst_key: ' + lst_key);
            lst_amount = (double) ar.get('Amount');
            //system.debug('lst_amount: ' + lst_amount);
            
            megamap.put(lst_key, lst_amount);
            //system.debug('megamap' + megamap);
        }
        
        // By Account - Target
        for(AggregateResult ar : [SELECT Account_Name__c, Sum(Target_Amount__c) Amount, Sales_Region__c 
                                  FROM LATAM_Target__c   
                                  WHERE Account_Name__c != NULL
                                  AND Year__c = : year
                                  GROUP BY ROLLUP(Sales_Region__c, Account_Name__c)])
        {
            lst_key = (string) ar.get('Account_Name__c')  + 'TotalLTT';
            //system.debug('lst_key: ' + lst_key);
            lst_amount = (double) ar.get('Amount');
            //system.debug('lst_amount: ' + lst_amount);
            
            megamap.put(lst_key, lst_amount);
            //system.debug('megamap' + megamap);
        }
        
        // By Product - Invoiced Orders
        for(AggregateResult ar : [SELECT Product_Family1__c ProductFamily, Sum(Transaction_Amount__c) Amount, Sales_Region__c 
                                  FROM Latam_Sales_Transactions__c   
                                  WHERE Account_ID__c != NULL 
                                   //AM Add this to filter by the current year
                                  AND Transaction_Date__c = LAST_YEAR
                                  GROUP BY ROLLUP(Sales_Region__c, Product_Family1__c)])
        {
            lst_key = (string) ar.get('Sales_Region__c') + 'TotalLST';
            //system.debug('lst_key: ' + lst_key);
            lst_amount = (double) ar.get('Amount');
            //system.debug('lst_amount: ' + lst_amount);
            
            megamap.put(lst_key, lst_amount);
            //system.debug('megamap' + megamap);
        }
        
        // By Product - Open Orders Sales
        for(AggregateResult ar : [SELECT Product_Family1__c ProductFamily, Sum(Transaction_Amount__c) Amount, Sales_Region__c 
                                  FROM LATAM_Order_Transaction__c   
                                  WHERE Account_Name__c != NULL 
                                  //AM Add this to filter by the current year
                                  AND Required_Date__c <= LAST_YEAR
                                  GROUP BY ROLLUP(Sales_Region__c, Product_Family1__c)])
        {
            lst_key = (string) ar.get('Sales_Region__c')  + 'TotalLOT';
            //system.debug('lst_key: ' + lst_key);
            lst_amount = (double) ar.get('Amount');
            //system.debug('lst_amount: ' + lst_amount);
            
            megamap.put(lst_key, lst_amount);
            //system.debug('megamap' + megamap);
        }
        
        // By Product - Target
        for(AggregateResult ar : [SELECT Product_family__c ProductFamily, Sum(Target_Amount__c) Amount, Sales_Region__c 
                                  FROM LATAM_Target__c   
                                  WHERE Account_Name__c != NULL
                                  AND Year__c = : year
                                  GROUP BY ROLLUP(Sales_Region__c, Product_family__c)])
        {
            lst_key = (string) ar.get('Sales_Region__c')  + 'TotalLTT';
            //system.debug('lst_key: ' + lst_key);
            lst_amount = (double) ar.get('Amount');
            //system.debug('lst_amount: ' + lst_amount);
            
            megamap.put(lst_key, lst_amount);
            //system.debug('megamap' + megamap);
        }
        
        // Grand Total by Product
        // 
        for(AggregateResult ar : [SELECT Sum(Transaction_Amount__c) Amount, Product_family1__c ProductFamily 
                                  FROM Latam_Sales_Transactions__c   
                                  WHERE Account_Name__c != NULL 
                                  //AM Add this to filter by the current year
                                  AND Transaction_Date__c = LAST_YEAR
                                  AND Transaction_Amount__c != NULL 
                                  AND Product_Family1__c != NULL
                                  GROUP BY ROLLUP(Product_Family1__c)])
        {
            lst_key = (string) ar.get('ProductFamily') + 'GTST';
            //system.debug('lst_key: ' + lst_key);
            lst_amount = (double) ar.get('Amount');
            //system.debug('lst_amount: ' + lst_amount);
            
            megamap.put(lst_key, lst_amount);
            //system.debug('megamap' + megamap);
        }
        
        for(AggregateResult ar : [SELECT Sum(Transaction_Amount__c) Amount, Product_family1__c ProductFamily 
                                  FROM LATAM_Order_Transaction__c   
                                  WHERE Account_Name__c != NULL 
                                  //AM Add this to filter by the current year
                                  AND Required_Date__c <= LAST_YEAR
                                  AND Transaction_Amount__c != NULL 
                                  AND Product_Family1__c != NULL
                                  GROUP BY ROLLUP(Product_Family1__c)])
        {
            lst_key = (string) ar.get('ProductFamily') + 'GTOT';
            //system.debug('lst_key: ' + lst_key);
            lst_amount = (double) ar.get('Amount');
            //system.debug('lst_amount: ' + lst_amount);
            
            megamap.put(lst_key, lst_amount);
            //system.debug('megamap' + megamap);
        }
        //---
        
        for(AggregateResult ar : [SELECT Sum(Target_Amount__c) Amount, Product_family__c ProductFamily 
                                  FROM LATAM_Target__c   
                                  WHERE Account_Name__c != NULL 
                                  AND Target_Amount__c != NULL
                                  // Re-enabled Year
                                  AND Year__c = : year
                                  AND Product_Family__c != NULL
                                  GROUP BY ROLLUP(Product_Family__c)])
        {
            ltt_key = (string) ar.get('ProductFamily') + 'GTLT';
            //system.debug('ltt_key: ' + ltt_key);
            ltt_amount = (double) ar.get('Amount');
            //system.debug('ltt_amount: ' + ltt_amount);
            
            megamap.put(ltt_key, ltt_amount);
            //system.debug('megamap' + megamap);
        
        }
        // End Grand by Product
        
        // Grand Grand Grand Total
        
        for(AggregateResult ar : [SELECT Sum(Transaction_Amount__c) Amount  
                                  FROM Latam_Sales_Transactions__c 
                                  //AM Add this to filter by the current year
                                  WHERE Transaction_Date__c = LAST_YEAR])
        {
            lst_amount = (double) ar.get('Amount');
            megamap.put('TotalGTST', lst_amount);

        }
        
        for(AggregateResult ar : [SELECT Sum(Transaction_Amount__c) Amount 
                                  FROM LATAM_Order_Transaction__c   
                                  WHERE Account_Name__c != NULL 
                                  //AM Add this to filter by the current year
                                  AND Required_Date__c <= LAST_YEAR
                                  AND Transaction_Amount__c != NULL 
                                  AND Product_Family1__c != NULL])
        {
            lst_amount = (double) ar.get('Amount');
            megamap.put('TotalGTOT', lst_amount);

        }
        //---
        
        for(AggregateResult ar : [SELECT Sum(Target_Amount__c) Amount 
                                  FROM LATAM_Target__c   
                                  WHERE Account_Name__c != NULL 
                                  AND Target_Amount__c != NULL 
                                  AND Year__c = : year
                                  AND Product_Family__c != NULL])
        {
            ltt_amount = (double) ar.get('Amount');
            megamap.put('TotalGTLT', ltt_amount);

        
        }
        // End Grand Total
        
        
        
        for(String reg : rlist){
            for(String prod : pgs_list){
                if(megamap.get(reg+prod+'LST') == NULL){
                    megamap.put(reg+prod+'LST', 0);
                }
                if(megamap.get(reg+prod+'LOT') == NULL){
                    megamap.put(reg+prod+'LOT', 0);
                }
                if(megamap.get(reg+prod+'LTT') == NULL){
                    megamap.put(reg+prod+'LTT', 0);
                }
                // Check the Grand Totals
                if(megamap.get(prod+'GTST') == NULL){
                    megamap.put(prod+'GTST', 0);
                }
                if(megamap.get(prod+'GTOT') == NULL){
                    megamap.put(prod+'GTOT', 0);
                }
                if(megamap.get(prod+'GTLT') == NULL){
                    megamap.put(prod+'GTLT', 0);
                }
            }
        }
        
        
        
        //---
        for(Account a : alist){
            for(String s : pgs_list){
                if(megamap.get(a.Name+s+'LST') == NULL){
                    megamap.put(a.Name+s+'LST', 0);
                }
                if(megamap.get(a.Name+s+'LOT') == NULL){
                    megamap.put(a.Name+s+'LOT', 0);
                }
                //--
                if(megamap.get(a.Name+s+'LTT') == NULL){
                    megamap.put(a.Name+s+'LTT', 0);
                }
                //--
            }
        }
        
        //system.debug('megamap' + megamap);
        //Latam_Sales_Transactions__c
        return megamap; 
        
    }
    public list<Account> getaccts(){
        /*
        set<String> acct_set = new set<String>();
        for(AggregateResult ar : [SELECT Account_Name__c 
                                  FROM Latam_Sales_Transactions__c 
                                  WHERE Account_Name__c != NULL 
                                  GROUP BY Account_Name__c])
        {
            acct_set.add((string) ar.get('Account_Name__c')); 
        }
        
        
        system.debug('acct_set' + acct_set);
        return [SELECT Name, Sales_Region__c, BillingCountry  
                FROM Account  
                WHERE Name IN :acct_set 
                AND RR_ID__c != NULL
                AND Sales_Region__c != NULL 
                ORDER BY Sales_Region__C, BillingCountry, Name ];
*/
        
        set<String> acct_set = new set<String>();
        for(AggregateResult ar : [SELECT Account_Name__c 
                                  FROM LATAM_Target__c 
                                  WHERE Account_Name__c != NULL
                                  AND Year__c = :year
                                  GROUP BY Account_Name__c])
        {
            acct_set.add((string) ar.get('Account_Name__c')); 
        }
        
        system.debug('acct_set' + acct_set);
        return [SELECT Name, Sales_Region__c, BillingCountry  
                FROM Account  
                WHERE Name IN :acct_set 
                AND RR_ID__c != NULL
                AND Sales_Region__c != NULL 
                ORDER BY Sales_Region__C, BillingCountry, Name ];
    }
    
    
}