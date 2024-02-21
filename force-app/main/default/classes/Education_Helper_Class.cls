public class Education_Helper_Class {
    // CE_Reimbursement_Expense_Helper_Class is the sister class
    public static void addERLookups(List<Education_Record__c> newTrigger){
        list<Education_Record__c> erList = new list<Education_Record__c>();
        set<Id> uSet = new set<Id>();
        for(Education_Record__c er : newTrigger){
            if(er.Sales_Rep__c != NULL){
                if(er.CEM__c == NULL ||
                   er.RSM__c == NULL ||
                   er.RCEM__c == NULL){
                       erList.add(er);
                       uSet.add(er.Sales_Rep__c);
                   }
            }
        }
        if(uSet.size() > 0){
            map<Id, User> uMap = new map<Id, User>();
            for(User u : [SELECT Id, ManagerId, CEM__c, RCEM__c
                         FROM User
                         WHERE Id = :uSet])
            {
                uMap.put(u.Id, u);
            }
            for(Education_Record__c er : erList){
                if(uMap.containsKey(er.Sales_Rep__c)){
                    if(er.CEM__c == NULL && uMap.get(er.Sales_Rep__c).CEM__c != NULL){
                        er.CEM__c = uMap.get(er.Sales_Rep__c).CEM__c;
                    }
                    if(er.RSM__c == NULL && uMap.get(er.Sales_Rep__c).ManagerId != NULL){
                        er.RSM__c = uMap.get(er.Sales_Rep__c).ManagerId;
                    }
                    if(er.RCEM__c == NULL && uMap.get(er.Sales_Rep__c).RCEM__c != NULL){
                        er.RCEM__c = uMap.get(er.Sales_Rep__c).RCEM__c;
                    }
                }
            }
        }

    }
    public static void addLookups(List<Education_Contractor__c> newTrigger){
    //public static void addLookups(List<Education_Contractor__c> newTrigger, map<Id, Education_Contractor__c> oldTrigger, string type){
        // Helper Class to add the lookups for the Education Contract Record
        // 03Oct2017 - ESC
        // Test Class:

        set<Id> profileSet = new set<Id>();
        set<Id> eduSet = new set<Id>();
        //boolean doWork = FALSE;
        //set<Id> ppSet = new set<Id>();

        list<Education_Contractor__c> ecList = new list<Education_Contractor__c>();
        //Reimbursement Rate
        // Check to see if work needs to be done otherwise no.
        for(Education_Contractor__c ec : newTrigger){
            //doWork = FALSE;
            if(ec.Reimbursement_Rate__c != ec.Workflow_Reimbursement_Rate__c){
                System.debug('*** ec.Workflow_Reimbursement_Rate__c *** ' + ec.Workflow_Reimbursement_Rate__c);
                ec.Reimbursement_Rate__c = ec.Workflow_Reimbursement_Rate__c;
            }
            if(ec.Travel_Rate__c != ec.Workflow_Travel_Rate__c){
                ec.Travel_Rate__c = ec.Workflow_Travel_Rate__c;
            }
            // Create the Key that will be used later for checking if the record already exists
            if(ec.Key__c == NULL || ec.Key__c != ec.Education_Record__c + '-' + ec.Contractor_Profile__c){
                ec.Key__c = ec.Education_Record__c + '-' + ec.Contractor_Profile__c;
            }

            // Determine if we need to pull data from the Education Record
            if(ec.Sales_Rep__c == NULL || ec.Sales_Manager__c == NULL || ec.RCEM__c == NULL || ec.CEM__c == NULL){
                //doWork = TRUE;
                eduSet.add(ec.Education_Record__c);
            }
            /*
            // Determine if we should pull fields from the Profile
            if(ec.Email__c == NULL || ec.Pay_Rate_Card__c == NULL){
                //doWork = TRUE;
                profileSet.add(ec.Contractor_Profile__c);
            }
            if(type == 'update' && oldTrigger.get(ec.Id).Contractor_Profile__c != ec.Contractor_Profile__c){
                doWork = TRUE;

            }
            if(doWork){

            }
            */
            profileSet.add(ec.Contractor_Profile__c);
            ecList.add(ec);
        }

        if(ecList.size() > 0){
            System.debug('*** ecList *** ' + ecList);
            map<Id, Profile__c> pMap = new map<Id, Profile__c>();
            map<Id, Education_Record__c> erMap = new map<Id, Education_Record__c>();


            // Look up the Profile Email Address
            if(profileSet.size() > 0){
                for(Profile__c p : [SELECT Id, E_mail_Address__c, Pay_Rate_Card__c, CurrencyIsoCode
                                    FROM Profile__c
                                    WHERE Id = :profileSet])
                {
                    pMap.put(p.Id, p);
                    //ppSet.add(p.Pay_Rate_Card__c);
                }
            }
            // Look up the Sales Lookups for Rep, RSM, CEM, and RCEM that will be used on the expense report approval
            if(eduSet.size() > 0){
                for(Education_Record__c er : [SELECT Id, Sales_Rep__c, RSM__c, RCEM__c, CEM__c
                                              FROM Education_Record__c
                                              WHERE Id =:eduSet])
                {
                    erMap.put(er.Id, er);
                }
            }

            // Final Loop if there's work to do
            for(Education_Contractor__c ec : ecList){
                if(pMap.containsKey(ec.Contractor_Profile__c)){
                    if(ec.Email__c == NULL || ec.Email__c != pMap.get(ec.Contractor_Profile__c).E_mail_Address__c){
                        ec.Email__c = pMap.get(ec.Contractor_Profile__c).E_mail_Address__c;
                    }
                    if(ec.Pay_Rate_Card__c == NULL || ec.Pay_Rate_Card__c != pMap.get(ec.Contractor_Profile__c).Pay_Rate_Card__c){
                        ec.Pay_Rate_Card__c = pMap.get(ec.Contractor_Profile__c).Pay_Rate_Card__c;
                    }
                    ec.CurrencyIsoCode = pMap.get(ec.Contractor_Profile__c).CurrencyIsoCode;
                }

                if(ec.Sales_Rep__c == NULL || ec.Sales_Manager__c == NULL || ec.RCEM__c == NULL || ec.CEM__c == NULL){
                    if(erMap.containsKey(ec.Education_Record__c)){
                        ec.Sales_Rep__c = erMap.get(ec.Education_Record__c).Sales_Rep__c;
                        ec.Sales_Manager__c = erMap.get(ec.Education_Record__c).RSM__c;
                        ec.RCEM__c = erMap.get(ec.Education_Record__c).RCEM__c;
                        ec.CEM__c = erMap.get(ec.Education_Record__c).CEM__c;
                    }
                }
            }
        }

    }

    public static void TrainingComplete(List<Education_Record__c> newTrigger){
        for(Education_Record__c er : newTrigger){
            if(er.Simulate_Training_Complete__c){
                system.debug('Marking Training Complete');
                er.stage__c = 'Training Completed';
                er.Simulate_Training_Complete__c = FALSE;
            }
        }
    }

    public static void updateCEApprovalStatus(List<Education_Record__c> newTrigger, map<Id, Education_Record__c> oldTrigger){

        map<Id, String> erMap = new map<Id, String>();
        list<Education_Contractor__c> updateEC = new list<Education_Contractor__c>();

        for(Education_Record__c er : newTrigger){
            if(oldTrigger.get(er.Id).Approval_Status__c != er.Approval_Status__c){
                erMap.put(er.Id, er.Approval_Status__c);
            }
        }

        if(erMap.size() > 0){
            for(Education_Contractor__c ec : [SELECT Id, Education_Record__c, Approval_Status__c
                                              FROM Education_Contractor__c
                                              WHERE Education_Record__c = :erMap.keyset()])
            {
                Education_Contractor__c newEC = new Education_Contractor__c(
                    id = ec.Id,
                    Approval_Status__c = erMap.get(ec.Education_Record__c)
                );
                updateEC.add(newEC);
            }
            if(updateEC.size() > 0){
                update updateEC;
            }
        }
    }

    public static void CreateCRFs(List<Education_Record__c> newTrigger){
        list<CE_Reimbursement_Expense__c> crfList = new list<CE_Reimbursement_Expense__c>();
        list<Education_Contractor__c> updateEC = new list<Education_Contractor__c>();

        for(Education_Contractor__c ec : [SELECT Id, CEM__c, RCEM__c, Contractor_Profile__c, Pay_Rate_Card__c,
                                          Education_Record__c, Email__c, CurrencyIsoCode, Reimbursement_Rate__c,
                                          Engagement_Type__c, Education_Record__r.RCEM__c, Education_Record__r.CEM__c,
                                          Pay_Rate_Card__r.Travel_Eligible__c, Travel_Rate__c, Workflow_Travel_Rate__c,
                                          Education_Record__r.Milage_Rate__c
                                          FROM Education_Contractor__c
                                          WHERE Education_Record__c = :newTrigger
                                          AND Education_Record__r.Stage__c = 'Training Completed'
                                          AND Status_Filter__c = FALSE
                                          AND CE_Reimbursement_Expense__c = NULL])
        {
            CE_Reimbursement_Expense__c createCRF = new CE_Reimbursement_Expense__c(
                Education_Contractor__c = ec.Id,
                Education_Record__c = ec.Education_Record__c,
                CEM__c = ec.Education_Record__r.CEM__c,
                RCEM__c = ec.Education_Record__r.RCEM__c,
                Clinical_Educator_Name__c = ec.Contractor_Profile__c,
                CE_Email__c = ec.Email__c,
                CurrencyIsoCode = ec.CurrencyIsoCode,
                Reimbursement_Rate__c = ec.Reimbursement_Rate__c,
                Engagement_Type__c = ec.Engagement_Type__c,
                Pay_Rate_Card__c = ec.Pay_Rate_Card__c,
                Status__c = 'New',
                Travel_Eligible__c = ec.Pay_Rate_Card__r.Travel_Eligible__c,
                TravelRate__c = ec.Workflow_Travel_Rate__c,
                Mil_Rate__c = ec.Education_Record__r.Milage_Rate__c

            );
            crfList.add(createCRF);
        }

        if(crfList.size() > 0){
            System.debug('*** crfList *** ' + crfList);
            insert crfList;
            // Now let's write back the Expense record to the related Education Contractor record
            for(CE_Reimbursement_Expense__c crf : crfList){
                Education_Contractor__c addEC = new Education_Contractor__c(
                    Id = crf.Education_Contractor__c,
                    CE_Reimbursement_Expense__c = crf.Id
                );
                updateEC.add(addEC);
            }
            if(updateEC.size() > 0){
                update updateEC;
            }
        }
    }

    public static void flipCRFs(List<Education_Record__c> newTrigger){
        List<CE_Reimbursement_Expense__c> updateCRF = new List<CE_Reimbursement_Expense__c>();
        for(CE_Reimbursement_Expense__c ercma: [SELECT Status__c
                                                FROM CE_Reimbursement_Expense__c
                                                WHERE Education_Record__c = :newTrigger
                                                AND Education_Record__r.Stage__c = 'Training Completed'
                                                AND Status__c = 'Save'
                                                AND Email_Sent_to_Contractor__c = FALSE])
        {
            system.debug('Marking from Save to New');
            ercma.status__c = 'New';
            updateCRF.add(ercma);
        }

        if(updateCRF.size() > 0){
            update updateCRF;
        }
    }

    public static void ecCheck(List<Education_Contractor__c> newTrigger){

        //Education_Contractor__c
        set<Id> erSet = new set<Id>();
        set<Id> ecSet = new set<Id>();
        list<Education_Contractor__c> ecList = new list<Education_Contractor__c>();

        for(Education_Contractor__c ec : newTrigger){
            if(ec.CE_Reimbursement_Expense__c == NULL){
                erSet.add(ec.Education_Record__c);
                ecSet.add(ec.Id);
                ecList.add(ec);
            }
        }
        if(erSet.size() > 0){
            map<String, Id> ceMap = new map<String, Id>();
            map<Id, CE_Reimbursement_Expense__c> crfMap = new map<Id, CE_Reimbursement_Expense__c>();
            for(CE_Reimbursement_Expense__c ce : [SELECT Id, Education_Contractor__c, Education_Record__c
                                                  FROM CE_Reimbursement_Expense__c
                                                  WHERE Education_Contractor__c = :ecSet
                                                  AND Education_Record__c = :erSet])
            {
                //ceMap.put(ce.Education_Contractor__c + '-' + ce.Clinical_Educator_Name__c, ce.Id);
                crfMap.put(ce.Education_Contractor__c, ce);
            }
            if(crfMap.size() > 0){
                for(Education_Contractor__c ec : ecList){
                    if(crfMap.containsKey(ec.Id)){
                        if(crfMap.get(ec.Id).Education_Record__c == ec.Education_Record__c){
                            ec.CE_Reimbursement_Expense__c = crfMap.get(ec.Id).Id;
                        }
                        //ec.Contractor_Profile__c = ceMap.get(ec.Education_Record__c + '-' + ec.Contractor_Profile__c);
                    }
                }
            }
        }
    }

    public static void cePayCheck(List<CE_Reimbursement_Expense__c > newTrigger){
        set<Id> pSet = new set<Id>();
        set<Id> erSet = new set<Id>();
        list<CE_Reimbursement_Expense__c> ceList = new list<CE_Reimbursement_Expense__c>();
        for(CE_Reimbursement_Expense__c ce : newTrigger){
            if(
                (ce.Education_Contractor__c == NULL || ce.TravelRate__c == NULL || ce.Mil_Rate__c == NULL)
                &&
                (ce.Status__c == 'New' || ce.Status__c == 'Save'))
            {
                erSet.add(ce.Education_Record__c);
                ceList.add(ce);


            }
            /*if(ce.Mil_Rate__c == NULL){
                ce.Mil_Rate__c = ce.Workflow_Mileage_Rate__c;
            }*/
        }

        if(ceList.size()>0 ){
          System.debug('*** ceList *** ' + ceList);
        }

        if(erSet.size() > 0){
            System.debug('*** erSet *** ' + erSet);
            map<string, Education_Contractor__c> ecMap = new map<string, Education_Contractor__c>();
            string keys;
            for(Education_Contractor__c ec : [SELECT Id, Pay_Rate_Card__c, Reimbursement_Rate__c, Engagement_Type__c,
                                              Contractor_Profile__c, Education_Record__c, Travel_Rate__c, Workflow_Travel_Rate__c
                                              FROM Education_Contractor__c
                                              WHERE Education_Record__c = :erSet])
            {
                ecMap.put(ec.Contractor_Profile__c + '-' + ec.Education_Record__c, ec);
            }
            if(ecMap.size() > 0){
                for(CE_Reimbursement_Expense__c ce : ceList){
                    keys = ce.Clinical_Educator_Name__c + '-' + ce.Education_Record__c;
                    if(ecMap.containsKey(keys)){
                        if(ce.Pay_Rate_Card__c == NULL && ecMap.get(keys).Pay_Rate_Card__c != NULL){
                            ce.Pay_Rate_Card__c =  ecMap.get(keys).Pay_Rate_Card__c;
                        }
                        if((ce.Reimbursement_Rate__c == NULL || ce.Reimbursement_Rate__c == 0) && ecMap.get(keys).Reimbursement_Rate__c != NULL){
                            System.debug('*** ecMap.get(keys).Reimbursement_Rate__c *** ' + ecMap.get(keys).Reimbursement_Rate__c);
                            ce.Reimbursement_Rate__c =  ecMap.get(keys).Reimbursement_Rate__c;
                        }
                        if(ce.Engagement_Type__c == NULL && ecMap.get(keys).Engagement_Type__c != NULL){
                            ce.Engagement_Type__c =  ecMap.get(keys).Engagement_Type__c;
                        }
                        if(ce.Education_Contractor__c == NULL && ecMap.get(keys).Id != NULL){
                            ce.Education_Contractor__c =  ecMap.get(keys).Id;
                        }
                        if(ce.TravelRate__c == NULL && ecMap.get(keys).Workflow_Travel_Rate__c != NULL){
                            ce.TravelRate__c =  ecMap.get(keys).Workflow_Travel_Rate__c;
                        }
                    }
                }
            }

        }

    }

    public static void createLegacyEducators(List<Education_Record__c> newTrigger){
        // This Method looks at the three Educator Fields and Creates related 'Education Contractors'
        // Oct 2017 - ESC

        set<Id> profileSet = new set<Id>();

        for(Education_Record__c er : newTrigger){
            if(er.Clinical_Educator__c != NULL && er.Clinical_Educator_Converted_1__c == FALSE){
                profileSet.add(er.Clinical_Educator__c);
            }
            if(er.Clinical_Educator2__c != NULL && er.Clinical_Educator_Converted_2__c == FALSE){
                profileSet.add(er.Clinical_Educator2__c);
            }
            if(er.Clinical_Educator3__c != NULL && er.Clinical_Educator_Converted_3__c == FALSE){
                profileSet.add(er.Clinical_Educator3__c);
            }
        }

        if(profileSet.size() > 0){
            list<Education_Contractor__c> ecList = new list<Education_Contractor__c>();
            string dupKey;
            map<String, Id> ecCheck = new map<String, Id>();
            map<String, Boolean> dupCheck = new map<String, Boolean>();
            map<Id, Boolean> profileCheck = new map<Id, Boolean>();

            for(Profile__c p : [SELECT Id
                                FROM Profile__c
                                WHERE Id = :profileSet
                                AND RecordType.Name = 'Contractor'])
            {
                profileCheck.put(p.Id, TRUE);
            }

            for(Education_Contractor__c ec : [SELECT Id, CEM__c, RCEM__c, Contractor_Profile__c,
                                              Education_Record__c, Email__c, CurrencyIsoCode,
                                              Key__c
                                              FROM Education_Contractor__c
                                              WHERE Education_Record__c = :newTrigger])
            {
                ecCheck.put(ec.Key__c, ec.Education_Record__c);
                system.debug('Key: ' + ec.Key__c);
            }

            for(Education_Record__c er : newTrigger){

                //Clinical_Educator__c #1
                if(er.Clinical_Educator__c != NULL && er.Clinical_Educator_Converted_1__c == FALSE){
                    if(profileCheck.containsKey(er.Clinical_Educator__c)){
                        er.Clinical_Educator_Converted_1__c = TRUE;
                        dupKey = er.Id + '-' + er.Clinical_Educator__c;

                        Education_Contractor__c newEC = new Education_Contractor__c(
                            Education_Record__c = er.Id,
                            Contractor_Profile__c = er.Clinical_Educator__c,
                            Key__c = dupKey
                        );
                        ecList.add(newEC);
                    }
                    else{
                        system.debug('Profile is not a Contractor Record Type!');
                    }
                }

                //Clinical_Educator2__c #2
                if(er.Clinical_Educator2__c != NULL && er.Clinical_Educator_Converted_2__c == FALSE){
                    if(profileCheck.containsKey(er.Clinical_Educator2__c)){
                        er.Clinical_Educator_Converted_2__c = TRUE;
                        dupKey = er.Id + '-' + er.Clinical_Educator2__c;

                        Education_Contractor__c newEC = new Education_Contractor__c(
                            Education_Record__c = er.Id,
                            Contractor_Profile__c = er.Clinical_Educator2__c,
                            Key__c = dupKey
                        );
                        ecList.add(newEC);
                    }
                    else{
                        system.debug('Profile is not a Contractor Record Type!');
                    }
                }

                //Clinical_Educator3__c #3
                if(er.Clinical_Educator3__c != NULL && er.Clinical_Educator_Converted_3__c == FALSE){
                    if(profileCheck.containsKey(er.Clinical_Educator3__c)){
                        er.Clinical_Educator_Converted_3__c = TRUE;
                        dupKey = er.Id + '-' + er.Clinical_Educator3__c;

                        Education_Contractor__c newEC = new Education_Contractor__c(
                            Education_Record__c = er.Id,
                            Contractor_Profile__c = er.Clinical_Educator3__c,
                            Key__c = dupKey
                        );
                        ecList.add(newEC);
                    }
                    else{
                        system.debug('Profile is not a Contractor Record Type!');
                    }
                }

            }
            if(ecList.size() > 0){
                insert ecList;
            }
        }

    }

    public static void LiveTrainingValidations(List<Education_Record__c> newTrigger, map<Id, Education_Record__c> oldTrigger){

        set<Id> repIds = new set<Id>();

        for(Education_Record__c er : newTrigger){
            // Updates related Sales Lookups if the Sales Rep Changes
            If(oldTrigger.get(er.Id).Sales_Rep__c != er.Sales_Rep__c){
                repIds.add(er.Sales_Rep__c);
            }
            //logic to enforce validation rules while in Approval Process
            if(oldTrigger.get(er.Id).Approval_Status__c != er.Approval_Status__c && er.RecordType.Name == 'Live Education Program Request'){
                system.debug('IN MAP CONDITION *****');
                if(er.Approval_Status__c == 'Approved' && er.Date_of_Event_Start__c == NULL){
                    er.Date_of_Event_Start__c.addError('Please fill in confirmed start date!');
                }
                else if(er.Approval_Status__c == 'Approved' && er.Ending_Date__c == NULL){
                    er.Ending_Date__c.addError('Please fill in confirmed end date!');
                }
            }
        }

        // If Sales Rep has Changed do the following
        if(repIds.size() > 0){
            map<Id, User> userMap = new map<Id, User>();
            // Create the User Map that matches the user id to the Manager, CEM, and RCEM fields
            for(User u : [SELECT Id, ManagerID, CEM__c, RCEM__c
                          FROM User
                          WHERE Id = :repIds])
            {
                userMap.put(u.Id, u);
            }

            // Put it all back together and update the record. If the record has changed and there is a value in the map it will update the record.
            for(Education_Record__c er : newTrigger){
                If(oldTrigger.get(er.Id).Sales_Rep__c != er.Sales_Rep__c && userMap.containsKey(er.Sales_Rep__c)){
                    er.RSM__c = userMap.get(er.Sales_Rep__c).ManagerID;
                    er.CEM__c = userMap.get(er.Sales_Rep__c).CEM__c;
                    er.RCEM__c = userMap.get(er.Sales_Rep__c).RCEM__c;
                }
            }
        }
    }
    /*
    public static void createReimbursementRecords(List<Education_Record__c> newTrigger){
        system.debug('Starting Create CRF Records');

        set<Id> erSET = new set<Id>();
        list<Education_Record__c> updateER = new list<Education_Record__c>();

        for(Education_Record__c er : newTrigger){
            // Check to see if the 'Create Expense Records' checkbox is true and if so add it to the Id set
            if(er.Create_Expense_Records__c || er.Stage__c == 'Training Complete'){
                erSET.add(er.Id);
                system.debug('Add Record: ' + er.Id);

                if(er.Create_Expense_Records__c){
                    // Set the Checkbox 'Create Expense Records' back to FALSE
                    Education_Record__c upER = new Education_Record__c(
                        Id = er.Id,
                        Create_Expense_Records__c = FALSE
                    );
                    updateER.add(upER);
                }

            }
        }
        // Check to see if there's work to be done otherwise exit the method
        if(erSET.size() > 0){
            list<CE_Reimbursement_Expense__c> crfList = new list<CE_Reimbursement_Expense__c>();
            list<Education_Contractor__c> updateEC = new list<Education_Contractor__c>();

            // Create the Expense Records from the related Education Contractor records off the Education Record
            for(Education_Contractor__c ec : [SELECT Id, CEM__c, RCEM__c, Contractor_Profile__c, Pay_Rate_Card__c,
                                              Education_Record__c, Email__c, CurrencyIsoCode, Reimbursement_Rate__c,
                                              Engagement_Type__c, Education_Record__r.RCEM__c, Education_Record__r.CEM__c
                                              FROM Education_Contractor__c
                                              WHERE Education_Record__c = :erSET
                                              AND Status_Filter__c = FALSE
                                              AND CE_Reimbursement_Expense__c = NULL])
            {
                CE_Reimbursement_Expense__c createCRF = new CE_Reimbursement_Expense__c(
                    Education_Contractor__c = ec.Id,
                    Education_Record__c = ec.Education_Record__c,
                    CEM__c = ec.Education_Record__r.CEM__c,
                    RCEM__c = ec.Education_Record__r.RCEM__c,
                    Clinical_Educator_Name__c = ec.Contractor_Profile__c,
                    CE_Email__c = ec.Email__c,
                    CurrencyIsoCode = ec.CurrencyIsoCode,
                    Reimbursement_Rate__c = ec.Reimbursement_Rate__c,
                    Engagement_Type__c = ec.Engagement_Type__c,
                    Pay_Rate_Card__c = ec.Pay_Rate_Card__c
                    //Status = NEW
                );
                crfList.add(createCRF);
            }

            if(crfList.size() > 0){
                insert crfList;
                // Now let's write back the Expense record to the related Education Contractor record
                for(CE_Reimbursement_Expense__c crf : crfList){
                    Education_Contractor__c addEC = new Education_Contractor__c(
                        Id = crf.Education_Contractor__c,
                        CE_Reimbursement_Expense__c = crf.Id
                    );
                    updateEC.add(addEC);
                }
                if(updateEC.size() > 0){
                    update updateEC;
                }
            }
            // And finally set the Checkbox 'Create Expense Records' back to FALSE
            if(updateER.size() > 0){
                // Better to use a try/catch block when updating Education Records
                try{
                    update updateER;
                }
                catch (DMLException e){
                }
            }
        }
    } // End Method
*/
    /*
    public static void simulateTrainingComplete(List<Education_Record__c> newTrigger){
        // Method that allows a record to be marked 'Training Complete' for testing purposes
        // Oct 2017 - ESC

        set<Id> eId = new set<Id>();
        list<Education_Record__c> updateEC = new list<Education_Record__c>();
        for(Education_Record__c er : newTrigger){
            if(er.Simulate_Training_Complete__c){
                system.debug('Adding Training Complete');
                eId.add(er.Id);
            }
        }

        if(eId.size() > 0){
            // Start CMA Update
            // Update Expense records from Save to New to start Expense Process

            List<CE_Reimbursement_Expense__c> crfcmaUpdate = new List<CE_Reimbursement_Expense__c>();
            for(CE_Reimbursement_Expense__c ercma: [SELECT Status__c
                                                    FROM CE_Reimbursement_Expense__c
                                                    WHERE Education_Record__c = :eId
                                                    /*
                                                    AND Education_Record__r.Ending_Date__c = TODAY
                                                    AND Education_Record__r.Stage__c = 'Confirmed'
                                                     */
                                                    /*AND (
                                                        Education_Record__r.Record_Type_Name__c ='CMA Record'
                                                        OR Education_Record__r.Record_Type_Name__c ='CMA Record MEG'
                                                        OR Education_Record__r.Record_Type_Name__c ='CMA Procedural Lab'
                                                        OR Education_Record__r.Record_Type_Name__c ='CMA Speaking Engagement'
                                                    )
                                                    AND Status__c = 'Save'])
            {
                system.debug('Marking from Save to New');
                ercma.status__c = 'New';
                crfcmaUpdate.add(ercma);
            }

            if(crfcmaUpdate.size() > 0){
                Database.update(crfcmaUpdate,false);
                System.debug(JSON.serializePretty(crfcmaUpdate));
            }

            // Finish CMA Update
            //
            // Update Education to 'Training Completed'
            List<Education_Record__c> edrecUpdate = new List<Education_Record__c>();
            for(Education_Record__c er: [SELECT Id, Stage__c
                                         FROM Education_Record__c
                                         WHERE Id = :eId
                                         /*
                                         AND Stage__c = 'Confirmed'
                                         AND Ending_Date__c = TODAY

                                         AND (
                                             Record_Type_Name__c ='Live Education Program Request'
                                             OR Record_Type_Name__c ='Inservice Record'
                                             OR Record_Type_Name__c ='Strategic Marketing Education Program Request'
                                         )
                                        ])
            {
                system.debug('Marking as Training Complete');
                er.stage__c = 'Training Completed';
                er.Simulate_Training_Complete__c = FALSE;
                edrecUpdate.add(er);
                eId.remove(er.Id);
            }
            if(edrecUpdate.size() > 0){
                Database.update(edrecUpdate,false);
                System.debug(JSON.serializePretty(edrecUpdate));
            }

            // Finish Training Complete
        }
        if(eId.size() > 0){
            for(Id er : eId){
                Education_Record__c fixEC = new Education_Record__c(
                    Id = er,
                    Simulate_Training_Complete__c = FALSE
                );
                updateEC.add(fixEC);
            }
            update updateEC;
        }

    }*/
}