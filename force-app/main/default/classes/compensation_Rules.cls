public class compensation_Rules {
    
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
    public list<string> pl2List {get; set;}
    public list<string> pexecsList {get; set;}
    public set<string> pSet {get; set;}
    public list<string> pList {get; set;}
    public list<list<string>> p2List {get; set;}
    public list<string> peList {get; set;}
    public list<list<string>> pe2List {get; set;}
    public list<String> buList {get; set;}
    public map<String, String> buMap {get; set;}
    public map<String, String> cpMap {get; set;}
    public map<String, String> prodMap {get; set;}
    public map<String, String> compMap {get; set;}
    public list<String> boldSet {get; set;}
    public list<Product2> prodList {get; set;}
    public string buString {get; set;}

    public compensation_Rules(){
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
        pl2List = new list<string>();
        pexecsList = new list<string>();
        pSet = new set<string>();
        pList = new list<string>();
        p2List = new list<list<string>>();
        peList = new list<string>();
        pe2List = new list<list<string>>();
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
        string prodExceptions;

        string prodClass;
        string buType;
        string compType;

        string compare = 'start';

        // Set up the BU List and Map
        buMap.put('Surgical_Disposables__c', 'Surgical Disposables');
        buMap.put('Surgical_Instruments__c', 'Surgical Instruments');
        buMap.put('Surgical_Inside_Sales__c', 'Surgical');
        buMap.put('Surgical_Canada__c', 'Surgical');
        buMap.put('Interventional__c', 'Interventional');
        buMap.put('Interventional_ISR__c', 'Interventional ISR');
        buMap.put('Interventional_Access_Canada__c', 'Interventional Access');
        buMap.put('Interventional_Capital__c', 'Interventional Capital');
        buMap.put('Interventional_Capital_Canada__c', 'Interventional Capital Canada');
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
        cpMap.put('Interventional_Capital__c', 'Interventional Capital');
        cpMap.put('Interventional_Capital_Canada__c', 'Interventional Capital Canada');
        cpMap.put('Interventional__c', 'Interventional');
        cpMap.put('Interventional_ISR__c', 'Interventional ISR');
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

        set<String> pcFilter = new set<String>();
        set<String> pgFilter = new set<String>();
        set<String> psgFilter = new set<String>();
        set<String> plFilterM1 = new set<String>();
        set<String> plFilterM2 = new set<String>();
        set<String> naFilter = new set<String>();
        
        set<String> phx = new set<String>();

        // Product Class
        
        if(ApexPages.currentPage().getParameters().get('id') != NULL){
            buString = ApexPages.currentPage().getParameters().get('id');
        }
        else{
            buString = 'Default';
        }

        if(buString != NULL && buString != 'Default'){
            
            // Define the Product Class
            setQuery = 'SELECT Product_Class__c, ' + buString + '  FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Duplicate__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != NULL AND ' + buString + ' != \'Not Applicable\' GROUP BY Product_Class__c, ' + buString + ' Order BY Product_Class__c';
            
            // Get a list of the Product Classes to filter on.
            for(AggregateResult ar : database.query(setQuery)){
                prodClass = (String) ar.get('Product_Class__c');
                pcFilter.add(prodClass);
            }
            system.debug('pcFilter: ' + pcFilter);
            
            // Product Class
            setQuery = 'SELECT Product_Class__c, ' + buString + '  FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Duplicate__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != NULL AND Product_Class__c = :pcFilter GROUP BY Product_Class__c, ' + buString + ' Order BY Product_Class__c';
            system.debug('setQuery: ' + setQuery);
            
            // Get a list of the Product Classes to filter on.
            for(AggregateResult ar : database.query(setQuery)){
                prodClass = (String) ar.get('Product_Class__c');
                compType = (String) ar.get(buString);
                if(pcFilter.contains(prodClass) || compMap.containsKey(prodClass)){
                    pcFilter.add(prodClass);
                    // Pull it from the compMap if it exists
                    if(compMap.containsKey(prodClass)){
                        pcSet.remove(prodClass);
                        compMap.remove(prodClass);
                    }
                }
                // First Timers
                else{
                    pcSet.add(prodClass);
                    compMap.put(prodClass, compType);
                    pcFilter.remove(prodClass);
                }
            }
            pcList.addAll(pcSet);
            //system.debug('pcList: ' + pcList);
            
            
            // Product Group
            setQuery = 'SELECT Product_Group__c, ' + buString + ' FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Duplicate__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND Product_Class__c = :pcFilter GROUP BY Product_Group__c, ' + buString + ' Order BY Product_Group__c';
            for(AggregateResult ar : database.query(setQuery))
            {
                
                prodClass = (String) ar.get('Product_Group__c');
                compType = (String) ar.get(buString);
                if(pgFilter.contains(prodClass) || compMap.containsKey(prodClass)){
                    pgFilter.add(prodClass);
                    // Pull it from the compMap if it exists
                    if(compMap.containsKey(prodClass)){
                        pgSet.remove(prodClass);
                        compMap.remove(prodClass);
                    }
                }
                // First Timers
                else{
                    if(compType == 'Not Applicable'){
                        pgFilter.add(prodClass);
                    }
                    else{
                        pgSet.add(prodClass);
                        compMap.put(prodClass, compType);
                    }
                }
            }
            pgList.addAll(pgSet);
            //system.debug('pgList: ' + pgList);

            // Product Sub-Group
            setQuery = 'SELECT Product_Sub_Group__c, ' + buString + ' FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Duplicate__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND Product_Group__c = :pgFilter GROUP BY Product_Sub_Group__c, ' + buString + ' Order BY Product_Sub_Group__c';
            for(AggregateResult ar : database.query(setQuery))
            {
                prodClass = (String) ar.get('Product_Sub_Group__c');
                compType = (String) ar.get(buString);
                //system.debug('Prod Class: ' + prodClass + ' Comp Type: ' + compType);
                if(psgFilter.contains(prodClass) || compMap.containsKey(prodClass)){
                    psgFilter.add(prodClass);
                    // Pull it from the compMap if it exists
                    if(compMap.containsKey(prodClass)){
                        psgSet.remove(prodClass);
                        compMap.remove(prodClass);
                    }
                }
                // First Timers
                else{
                    if(compType == 'Not Applicable'){
                        psgFilter.add(prodClass);
                    }
                    else{
                        psgSet.add(prodClass);
                        compMap.put(prodClass, compType);
                    }
                }
            }
            psgList.addAll(psgSet);
            //system.debug('psgList: ' + psgList);

            // Product Line - This is the step where the magic truly happens. 
            // The last stop between using the PL and listing the exceptions and just breaking out the Product Line by Material.
            setQuery = 'SELECT Product_Line__c, ' + buString + ' FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Duplicate__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND Product_Sub_Group__c = :psgFilter GROUP BY Product_Line__c, ' + buString + ' Order BY Product_Line__c';
            for(AggregateResult ar : database.query(setQuery))
            {
                
                prodClass = (String) ar.get('Product_Line__c');
                compType = (String) ar.get(buString);
                system.debug('Prod Class: ' + prodClass + ' Comp Type: ' + compType);
                if(naFilter.contains(prodClass) || compMap.containsKey(prodClass)){
                    if(plFilterM1.contains(prodClass)){ // Three Times means we'll have to break out Compensatory down to the product to catch the different Comp Buckets (Focus, Core, etc)
                        plFilterM1.remove(prodClass);
                        plSet.remove(prodClass);
                        // Add's the Product Line to the Method that breaks out all of the products in the Product Line
                        plFilterM2.add(prodClass);
                    }
                    else{ // Second Timers - Use Method One of Including the Product Line and List out the Exceptions
                        // Add's the Product Line to the Method of including the Product Line but excluding certain SKU's
                        if(compMap.get(prodClass) == 'Not Applicable' || compType == 'Not Applicable'){
                            plFilterM1.add(prodClass);                            
                        }
                        else{
                            plFilterM2.add(prodClass);
                        }

                    }
                }
                // First Timers - No Exceptions
                else{
                    if(compType != 'Not Applicable'){
                        plSet.add(prodClass);
                        compMap.put(prodClass, compType);
                    }
                    else{
                        naFilter.add(prodClass);
                    }
                }
            }
            plList.addAll(plSet);
            //system.debug('plFilterM1: ' + plFilterM1);
            
            // Product Name - Method 1
            // Add the Product Line and then pull out the "Not Applicable" products as exceptions
            // This greatly reduces the number of rules especially in the Surgical Product Lines that cause us to approach the 10k DML limit
            // 20Jul2017 - ESC
            prodQuery = 'SELECT Name,' + buString + ' FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Duplicate__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' = \'Not Applicable\' AND Product_Line__c = :plFilterM1 ORDER BY Name';

            integer num = 1;
            for(SObject ar : database.query(prodQuery))
            {
                
                //prodClass = p.Name;
                prodClass = (String) ar.get('Name');
                compType = (String) ar.get(buString);
                if(!compMap.containsKey(prodClass)){
                    compMap.put(prodClass, compType);
                    peList.add(prodClass);
                    if(num == 1000){
                        pe2List.add(peList);
                        peList = new list<String>();
                        num = 0;
                    }
                    ++num;
                }
            }
            pe2List.add(peList);
            
            // Product Name - Method 2
            prodQuery = 'SELECT Name,' + buString + ' FROM Product2 WHERE Duplicate_Product_Class__c = FALSE AND Duplicate__c = FALSE AND Sales_Org_Key__c = \'US103010\' AND ' + buString + ' != \'Not Applicable\' AND Product_Line__c = :plFilterM2 ORDER BY Name';

            num = 1;
            for(SObject ar : database.query(prodQuery))
            {
                
                //prodClass = p.Name;
                prodClass = (String) ar.get('Name');
                compType = (String) ar.get(buString);
                if(compType == NULL){
                    compType = 'Not Applicable';
                }
                if(compType != 'Not Applicable' && !compMap.containsKey(prodClass)){
                    compMap.put(prodClass, compType);
                    pList.add(prodClass);
                    if(num == 1000){
                        p2List.add(pList);
                        pList = new list<String>();
                        num = 0;
                    }
                    ++num;
                }
            }
            p2List.add(pList);
            //system.debug('*** p2List.size() *** ' + p2List.size() );
        }
    }

    public PageReference save(){

        string buName = cpMap.get(buString);
        set<Id> resetFilter = new set<Id>();
        map<String, Id> crMap = new map<String, Id>();
        for(Compensation_Rules__c cr : [SELECT Id, Key__c
                                       FROM Compensation_Rules__c
                                       WHERE Business_Unit__c = :buName])
        {
            crMap.put(cr.Key__c, cr.Id);
        }
        system.debug('crMap: ' + crMap);
        list<Compensation_Rules__c> crList = new list<Compensation_Rules__c>();
        list<Compensation_Rules__c> resetList = new list<Compensation_Rules__c>();
        if(pcList.size() > 0){
            for(String s : pcList){
                Compensation_Rules__c cr = new Compensation_Rules__c(
                    Business_Unit__c = buName,
                    Product_Class__c = s,
                    Key__c = buName + '-' + s,
                    Alt_Key__c = s,
                    Compensation_Profile__c = buName,
                    Compensation_Type__c  = compMap.get(s),
                    Active__c = TRUE
                );
                if(crMap.containsKey(buName + '-' + s)){
                    cr.Id = crMap.get(buName + '-' + s);
                    resetFilter.add(crMap.get(buName + '-' + s));
                }
                crList.add(cr);
            }
        }
        if(pgList.size() > 0){
            for(String s : pgList){
                Compensation_Rules__c cr = new Compensation_Rules__c(
                    Business_Unit__c = buName,
                    Product_Group__c = s,
                    Key__c = buName + '-' + s,
                    Alt_Key__c = s,
                    Compensation_Profile__c = buName,
                    Compensation_Type__c  = compMap.get(s),
                    Active__c = TRUE
                );
                if(crMap.containsKey(buName + '-' + s)){
                    cr.Id = crMap.get(buName + '-' + s);
                    resetFilter.add(crMap.get(buName + '-' + s));
                }
                crList.add(cr);
            }
        }
        if(psgList.size() > 0){
            for(String s : psgList){
                Compensation_Rules__c cr = new Compensation_Rules__c(
                    Business_Unit__c = buName,
                    Product_Sub_Group__c = s,
                    Key__c = buName + '-' + s,
                    Alt_Key__c = s,
                    Compensation_Profile__c = buName,
                    Compensation_Type__c  = compMap.get(s),
                    Active__c = TRUE
                );
                if(crMap.containsKey(buName + '-' + s)){
                    cr.Id = crMap.get(buName + '-' + s);
                    resetFilter.add(crMap.get(buName + '-' + s));
                }
                crList.add(cr);
            }
        }
        if(plList.size() > 0){
            for(String s : plList){
                Compensation_Rules__c cr = new Compensation_Rules__c(
                    Business_Unit__c = buName,
                    Product_Line__c = s,
                    Key__c = buName + '-' + s,
                    Alt_Key__c = s,
                    Compensation_Profile__c = buName,
                    Compensation_Type__c  = compMap.get(s),
                    Active__c = TRUE
                );
                if(crMap.containsKey(buName + '-' + s)){
                    cr.Id = crMap.get(buName + '-' + s);
                    resetFilter.add(crMap.get(buName + '-' + s));
                }
                crList.add(cr);
            }
        }
        if(pe2List.size() > 0){
            for(list<String> pl : pe2List){
                for(String s : pl){
                    Compensation_Rules__c cr = new Compensation_Rules__c(
                        Business_Unit__c = buName,
                        Product_Name__c = s,
                        Key__c = buName + '-x-' + s,
                        Alt_Key__c = s,
                        Compensation_Profile__c = buName,
                        Compensation_Type__c  = compMap.get(s),
                        Active__c = TRUE,
                        Compensatory_Rule_Exception__c = TRUE
                    );
                    if(crMap.containsKey(buName + '-x-' + s)){
                        cr.Id = crMap.get(buName + '-x-' + s);
                        resetFilter.add(crMap.get(buName + '-x-' + s));
                    }
                    crList.add(cr);
                }
            }
        }
        if(p2List.size() > 0){
            for(list<String> pl : p2List){
                for(String s : pl){
                    Compensation_Rules__c cr = new Compensation_Rules__c(
                        Business_Unit__c = buName,
                        Product_Name__c = s,
                        Key__c = buName + '-' + s,
                        Alt_Key__c = s,
                        Compensation_Profile__c = buName,
                        Compensation_Type__c  = compMap.get(s),
                        Active__c = TRUE,
                        Compensatory_Rule_Exception__c = FALSE
                    );
                    if(crMap.containsKey(buName + '-' + s)){
                        cr.Id = crMap.get(buName + '-' + s);
                        resetFilter.add(crMap.get(buName + '-' + s));
                    }
                    crList.add(cr);
                }
            }
        }
        //pexecsList
        /*if(pexecsList.size() > 0){
            
            for(String s : pexecsList){
                Compensation_Rules__c cr = new Compensation_Rules__c(
                    Business_Unit__c = buName,
                    Product_Name__c = s,
                    Key__c = buName + '-x-' + s,
                    Alt_Key__c = s,
                    Compensation_Profile__c = buName,
                    Compensation_Type__c  = compMap.get(s),
                    Active__c = TRUE,
                    Compensatory_Rule_Exception__c = TRUE
                );
                if(crMap.containsKey(buName + '-x-' + s)){
                    cr.Id = crMap.get(buName + '-x-' + s);
                    resetFilter.add(crMap.get(buName + '-x-' + s));
                }
                crList.add(cr);
            }

        }
        */
        if(resetFilter.size() > 0){
            for(Compensation_Rules__c cr : [SELECT Id, Key__c
                                            FROM Compensation_Rules__c
                                            WHERE Active__c = TRUE
                                            AND Compensation_Profile__c =: cpMap.get(buString)
                                            AND Id !=:resetFilter])
            {
                Compensation_Rules__c newcr = new Compensation_Rules__c(
                    Id = cr.Id,
                    Active__c = FALSE
                );
                resetList.add(newcr);
            }
            if(resetList.size() > 0){
                system.debug('De-activating!');
                UPDATE resetList;
            }
        }
        if(crList.size() > 0){
            system.debug('Upserting!');
            UPSERT crList;
        }

        PageReference pageReturn = new PageReference('/apex/compensation_Rules?id='+ buString).setRedirect(True);
        return pageReturn;
    }

    public PageReference refreshing(){
        PageReference pageReturn = new PageReference('/apex/compensation_POC?id='+ buString).setRedirect(True);
        return pageReturn;
    }


}