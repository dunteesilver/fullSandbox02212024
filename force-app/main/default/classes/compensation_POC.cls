public class compensation_POC {
 
    // Test Class: Invoiced_Global_Test_Class

    public map<string, boolean> prodCompMap {get; set;}

    public set<string> pcSet {get; set;}
    public list<string> pcList {get; set;}
    public set<string> pgSet {get; set;}
    public list<string> pgList {get; set;}
    public set<string> psgSet {get; set;}
    public list<string> psgList {get; set;}
    public set<string> plSet {get; set;}
    public list<string> plList {get; set;}
    public set<string> pSet {get; set;}
    public list<string> pList {get; set;}
    public list<String> buList {get; set;}
    public map<String, String> buMap {get; set;}
    public map<String, String> cpMap {get; set;}
    public map<String, String> prodMap {get; set;}
    public map<String, String> compMap {get; set;}
    public list<String> boldSet {get; set;}
    public list<Product2> prodList {get; set;}
    public string buString {get; set;}

    public compensation_POC(){
        system.debug('DEBUG!');
        
        prodCompMap = new map<string, boolean>();
        pcSet = new set<string>();
        pcList = new list<string>();
        pgSet = new set<string>();
        pgList = new list<string>();
        psgSet = new set<string>();
        psgList = new list<string>();
        plSet = new set<string>();
        plList = new list<string>();
        pSet = new set<string>();
        pList = new list<string>();
        buList = new list<String>();
        buMap = new map<String, String>();
        cpMap = new map<String, String>();
        prodMap = new map<String, String>();
        compMap = new map<String, String>();
        boldSet = new list<String>();
        prodList = new list<Product2>();

        List<AggregateResult> phSet;
        List<AggregateResult> phCompare;
        string setQuery;
        string compareQuery;
        string prodQuery;
        
        string prodClass;
        string buType;
        string compType;
        
        string compare = 'start';
        
        // Set up the BU List and Map
        buMap.put('Surgical_Disposables__c', 'Surgical Disposables');
        buMap.put('Surgical_Instruments__c', 'Surgical Instruments');
        buMap.put('Surgical_Inside_Sales__c', 'Surgical');
        buMap.put('Surgical_Canada__c', 'Surgical');
        buMap.put('Interventional_Access__c', 'Interventional Access');
        buMap.put('Interventional_Access_Canada__c', 'Interventional Access');
        buMap.put('Urology__c', 'Urology');
        buMap.put('Vascular__c', 'Vascular');
        buMap.put('Vascular_Canada__c', 'Vascular');
        buMap.put('Vascular_KAMs__c', 'Vascular');
        buMap.put('Respiratory__c', 'Respiratory');
        buMap.put('Respiratory_Inside_Sales__c', 'Respiratory');
        buMap.put('Resp_Uro_AltCare_Canada__c', 'Resp/Uro/AltCare - Canada');
        buMap.put('EMS__c', 'EMS');
        buMap.put('Anesthesia__c', 'Anesthesia');
        buMap.put('Anesthesia_Canada__c', 'Anesthesia');
        buMap.put('SBM_Pain_Management__c', 'SBM Pain Management');
        buMap.put('Alt_Care__c', 'Alt Care');
        buMap.put('Alt_Care_ISR__c', 'Alt Care ISR');
        system.debug('buList: ' + buList);
        
        // Set up the BU List and Map
        cpMap.put('Default', 'Home');
        cpMap.put('Surgical_Disposables__c', 'Surgical Disposables');
        cpMap.put('Surgical_Instruments__c', 'Surgical Instruments');
        cpMap.put('Surgical_Instruments__c', 'Surgical Instruments');
        cpMap.put('Surgical_Inside_Sales__c', 'Surgical Inside Sales');
        cpMap.put('Surgical_Canada__c', 'Surgical Canada');
        cpMap.put('Interventional_Access__c', 'Interventional Access');
        cpMap.put('Interventional_Access_Canada__c', 'Interventional Access Canada');
        cpMap.put('Vascular__c', 'Vascular');
        cpMap.put('Urology__c', 'Urology');
        cpMap.put('Vascular_Canada__c', 'Vascular Canada');
        cpMap.put('Vascular_KAMs__c', 'Vascular KAMs');
        cpMap.put('Respiratory__c', 'Respiratory');
        cpMap.put('Respiratory_Inside_Sales__c', 'Respiratory Inside Sales');
        cpMap.put('Resp_Uro_AltCare_Canada__c', 'Resp/Uro/AltCare - Canada');
        cpMap.put('EMS__c', 'EMS');
        cpMap.put('Anesthesia__c', 'Anesthesia');
        cpMap.put('Anesthesia_Canada__c', 'Anesthesia Canada');
        cpMap.put('SBM_Pain_Management__c', 'SBM Pain Management');
        cpMap.put('Alt_Care__c', 'Alt Care');
        cpMap.put('Alt_Care_ISR__c', 'Alt Care ISR');
        system.debug('buList: ' + buList);
        
        // Product Class
        //for(String bu : buList){

        if(ApexPages.currentPage().getParameters().get('id') != NULL){
            buString = ApexPages.currentPage().getParameters().get('id');
        }
        else{
            buString = 'Default';
        }
        
        if(buString != NULL && buString != 'Default'){
            

            setQuery = 'SELECT Product_Class__c, ' + buString + ' FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != NULL AND ' + buString + ' != \'Not Applicable\' GROUP BY Product_Class__c, ' + buString + ' Order BY Product_Class__c';
            compareQuery = 'SELECT Product_Class__c, ' + buString + ' FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != NULL AND ' + buString + ' = \'Not Applicable\' GROUP BY Product_Class__c, ' + buString + ' Order BY Product_Class__c';
            
            phSet = database.query(setQuery);
            phCompare = database.query(compareQuery);
            
            for(AggregateResult ar : phSet)
            {
                prodClass = String.valueOf(ar.get('Product_Class__c'));
                compType = String.valueOf(ar.get(buString));
                compMap.put(prodClass, compType);
                if(compare != prodClass){
                    prodCompMap.put('pc+'+prodClass,TRUE);
                    compare = prodClass;
                }
                else{
                    prodCompMap.put('pc-'+prodClass,TRUE);
                }

                pcSet.add(prodClass);
                system.debug('CompType: ' + compType + ' Class: ' + prodClass);
            }
            
            for(AggregateResult ar : phCompare)
            {
                prodClass = String.valueOf(ar.get('Product_Class__c'));
                prodCompMap.put('pc-'+prodClass,TRUE);
                pcSet.add(prodClass);
            }
            
            for(string s : pcSet){
                //system.debug('S: (' + s + ') Level 1: ' + prodCompMap.get('pc+'+s) + 'and Level 2: ' + prodCompMap.get('pc-'+s));
                if(prodCompMap.get('pc+'+s) != NULL){
                    if(prodCompMap.get('pc-'+s) == NULL){
                        pcList.add(s);
                    }
                }
            }
            
            // Product Group
            
            setQuery = 'SELECT Product_Group__c, ' + buString + ' FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != NULL AND ' + buString + ' != \'Not Applicable\' AND Product_Class__c != :pcList GROUP BY Product_Group__c, ' + buString + ' Order BY Product_Group__c';
            compareQuery = 'SELECT Product_Group__c FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != NULL AND ' + buString + ' = \'Not Applicable\' AND Product_Class__c != :pcList GROUP BY Product_Group__c';
            
            phSet = database.query(setQuery);
            phCompare = database.query(compareQuery);
            
            for(AggregateResult ar : phSet)
            {
                prodClass = String.valueOf(ar.get('Product_Group__c'));
                compType = String.valueOf(ar.get(buString));
                compMap.put(prodClass, compType);
                if(compare != prodClass){
                    prodCompMap.put('pg+'+prodClass,TRUE);
                    compare = prodClass;
                }
                else{
                    prodCompMap.put('pg-'+prodClass,TRUE);
                }
                pgSet.add(prodClass);
            }
            
            for(AggregateResult ar : phCompare)
            {
                prodClass = String.valueOf(ar.get('Product_Group__c'));
                prodCompMap.put('pg-'+prodClass,TRUE);
                pgSet.add(prodClass);
            }
            
            for(string s : pgSet){
                system.debug('S: (' + s + ') Level 1: ' + prodCompMap.get('pc+'+s) + 'and Level 2: ' + prodCompMap.get('pc-'+s));
                if(prodCompMap.get('pg+'+s) != NULL){
                    if(prodCompMap.get('pg-'+s) == NULL){
                        pgList.add(s);
                    }
                }
            }
            
            // Product Sub-Group
            
            setQuery = 'SELECT Product_Sub_Group__c, ' + buString + ' FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != NULL AND ' + buString + ' != \'Not Applicable\' AND Product_Class__c != :pcList AND Product_Group__c != :pgList GROUP BY Product_Sub_Group__c, ' + buString + ' Order BY Product_Sub_Group__c';
            compareQuery = 'SELECT Product_Sub_Group__c FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != NULL AND ' + buString + ' = \'Not Applicable\' AND Product_Class__c != :pcList AND Product_Group__c != :pgList GROUP BY Product_Sub_Group__c';
            
            phSet = database.query(setQuery);
            phCompare = database.query(compareQuery);
            
            for(AggregateResult ar : phSet)
            {
                prodClass = String.valueOf(ar.get('Product_Sub_Group__c'));
                compType = String.valueOf(ar.get(buString));
                compMap.put(prodClass, compType);
                if(compare != prodClass){
                    prodCompMap.put('psg+'+prodClass,TRUE);
                    compare = prodClass;
                }
                else{
                    prodCompMap.put('psg-'+prodClass,TRUE);
                }
                psgSet.add(prodClass);
            }
            
            for(AggregateResult ar : phCompare)
            {
                prodClass = String.valueOf(ar.get('Product_Sub_Group__c'));
                prodCompMap.put('psg-'+prodClass,TRUE);
                psgSet.add(prodClass);
            }
            
            for(string s : psgSet){
                //system.debug('S: (' + s + ') Level 1: ' + prodCompMap.get('pc+'+s) + 'and Level 2: ' + prodCompMap.get('pc-'+s));
                if(prodCompMap.get('psg+'+s) != NULL){
                    if(prodCompMap.get('psg-'+s) == NULL){
                        psgList.add(s);
                    }
                }
            }
            
            // Product Line
            
            setQuery = 'SELECT Product_Line__c, ' + buString + ' FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != NULL AND ' + buString + ' != \'Not Applicable\' AND Product_Class__c != :pcList AND Product_Group__c != :pgList AND Product_Sub_Group__c != :psgList GROUP BY Product_Line__c, ' + buString + ' Order BY Product_Line__c';
            compareQuery = 'SELECT Product_Line__c FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != NULL AND ' + buString + ' = \'Not Applicable\' AND Product_Class__c != :pcList AND Product_Group__c != :pgList AND Product_Sub_Group__c != :psgList GROUP BY Product_Line__c';
            
            phSet = database.query(setQuery);
            phCompare = database.query(compareQuery);
            
            for(AggregateResult ar : phSet)
            {
                prodClass = String.valueOf(ar.get('Product_Line__c'));
                compType = String.valueOf(ar.get(buString));
                compMap.put(prodClass, compType);
                if(compare != prodClass){
                    prodCompMap.put('pl+'+prodClass,TRUE);
                    compare = prodClass;
                }
                else{
                    prodCompMap.put('pl-'+prodClass,TRUE);
                }
                plSet.add(prodClass);
            }
            
            for(AggregateResult ar : phCompare)
            {
                prodClass = String.valueOf(ar.get('Product_Line__c'));
                prodCompMap.put('pl-'+prodClass,TRUE);
                plSet.add(prodClass);
            }
            
            for(string s : plSet){
                //system.debug('S: (' + s + ') Level 1: ' + prodCompMap.get('pc+'+s) + 'and Level 2: ' + prodCompMap.get('pc-'+s));
                if(prodCompMap.get('pl+'+s) != NULL){
                    if(prodCompMap.get('pl-'+s) == NULL){
                        plList.add(s);                        
                    }
                }
            }
            
            // Product Name
            
            setQuery = 'SELECT Name, ' + buString + ' FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != NULL AND ' + buString + ' != \'Not Applicable\' AND Product_Class__c != :pcList AND Product_Group__c != :pgList AND Product_Sub_Group__c != :psgList AND Product_Line__c != :plList GROUP BY Name, ' + buString + ' Order BY Name';
            compareQuery = 'SELECT Name FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != NULL AND ' + buString + ' = \'Not Applicable\' AND Product_Class__c != :pcList AND Product_Group__c != :pgList AND Product_Sub_Group__c != :psgList AND Product_Line__c != :plList GROUP BY Name';
            
            phSet = database.query(setQuery);
            phCompare = database.query(compareQuery);
            
            for(AggregateResult ar : phSet)
            {
                prodClass = String.valueOf(ar.get('Name'));
                compType = String.valueOf(ar.get(buString));
                compMap.put(prodClass, compType);
                prodCompMap.put('p+'+prodClass,TRUE);
                pSet.add(prodClass);
            }
            
            for(AggregateResult ar : phCompare)
            {
                prodClass = String.valueOf(ar.get('Name'));
                prodCompMap.put('p-'+prodClass,TRUE);
                pSet.add(prodClass);
            }
            
            for(string s : pSet){
                //system.debug('S: (' + s + ') Level 1: ' + prodCompMap.get('pc+'+s) + 'and Level 2: ' + prodCompMap.get('pc-'+s));
                if(prodCompMap.get('p+'+s) != NULL){
                    if(prodCompMap.get('p-'+s) == NULL){
                        pList.add(s);                        
                    }
                }
            }
            
            // Build out the Matching Product List
            boolean firstWhere = FALSE;
            prodQuery = 'SELECT Name, Product_Line__c, Product_Group__c, Product_Sub_Group__c, Product_Class__c, Class__c, Group__c, SubGroup__c,' + buString + ' , Material_Key__c ';
            //Surgical_Canada__c,Surgical_Disposables__c,Surgical_Inside_Sales__c,Surgical_Instruments__c,Vascular__c,Vascular_Canada__c,Vascular_KAMs__c,Respiratory__c,Respiratory_Inside_Sales__c,Interventional_Access__c,Interventional_Access_Canada__c,EMS__c,Alt_Care__c,Alt_Care_Darren_Stigers__c,Anesthesia__c,Anesthesia_Canada__c
            prodQuery += 'FROM Product2 ';
            if(pcList.size() > 0){
                prodQuery += ' WHERE Product_Class__c = :pcList ';
                firstWHERE = TRUE;
            }
            if(pgList.size() > 0){
                if(firstWHERE){
                    prodQuery += ' OR Product_Group__c = :pgList ';
                }
                ELSE{
                    prodQuery += ' WHERE Product_Group__c = :pgList ';
                    firstWHERE = TRUE;
                }
            }
            if(psgList.size() > 0){
                if(firstWHERE){
                    prodQuery += ' OR Product_Sub_Group__c = :psgList ';
                }
                ELSE{
                    prodQuery += ' WHERE Product_Sub_Group__c = :psgList ';
                    firstWHERE = TRUE;
                }
            }
            if(plList.size() > 0){
                if(firstWHERE){
                    prodQuery += ' OR Product_Line__c = :plList ';
                }
                ELSE{
                    prodQuery += ' WHERE Product_Line__c = :plList ';
                    firstWHERE = TRUE;
                }
            }
            prodQuery += ' LIMIT 10000';

            prodList = database.query(prodQuery);
            if(prodList.size() > 0){
                prodList.sort();
            }
        }
        
        
            
    }
    
    public PageReference refreshing(){
        PageReference pageReturn = new PageReference('/apex/compensation_POC?id='+ buString).setRedirect(True);
        return pageReturn;
    }

    
}