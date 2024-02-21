public class formStack {
    // Test Class: account_Page_Helper_Test (at the bottom)
    public static void lpAddressFix(List<Lab_Participant__c> newTrigger, Map<Id,Lab_Participant__c> oldTrigger,String type){
        // This is version 2 of the 'Lets guess the address!' pulling from the raw address field: Address__c
        // Basically use commas and spaces with math to guess where the address, city, state, zip, and country data is in an address field that is dynamic based on the form.
        // 13Jan2016 - ESC

        string shortCity;
        String newAddress;
        String newCity;
        String newCityRaw;
        String newZip;
        String newCountry;
        String addressSplitTrim;
        Integer pos;

        List<String> newAddressRaw;
        List<String> newAddressSplit;
        List<String> newCitySplit;
        set<String> citySet = new set<String>();
        set<String> zipSet = new set<String>();
        set<String> newzipCitySet = new set<String>();
        map<String, String> cityMap = new map<String, String>();

        system.debug(' -- Starting lpAddressFix --');

        for(Lab_Participant__c l : newTrigger){
            if(l.Affiliation__c != NULL){
                l.Business_Unit__c = l.Zip_Code_Business_Unit__c;
            }

            if(l.Mailing_City__c == NULL || l.Mailing_Street_Address__c  == NULL || l.Mailing_State__c == NULL){
                newAddressRaw = new List<String>();
                newAddressSplit = new List<String>();
                newCitySplit = new List<String>();

                if(l.Address__c != NULL){
                    newAddressRaw = l.Address__c.split(',', -2);
                    system.debug('newAddress' + newAddressRaw);
                }
                if(!newAddressRaw.isEmpty()){
                    pos = newAddressRaw.size() - 1; // Some Addresses have more than one comma so we look for the last one.
                    addressSplitTrim = newAddressRaw[pos].trim();

                    l.Mailing_Street_Address__c = newAddressRaw[0];
                    newCityRaw = newAddressRaw[0];
                    // If this is greater than 2 then it means there's an address2 and possibly 3. We ignore more than 2.
                    if(newAddressRaw.size() == 3){
                        l.Mailing_Street_Address_2__c = newAddressRaw[1];
                        newCityRaw = newAddressRaw[1];
                    }
                    if(newAddressRaw.size() == 4){
                        newCityRaw = newAddressRaw[2];
                    }


                    // Start the City Guessing Fun
                    newCityRaw = newCityRaw.trim();
                    newCitySplit = newCityRaw.split(' ', -2);
                    pos = newCitySplit.size() - 1;
                    if(newCitySplit[pos].trim() != NULL){
                        newCity = newCitySplit[pos];
                    }
                    else{
                        pos = pos - 1;
                        newCity = newCitySplit[pos];
                    }

                    system.debug('newCity Guess: ' + newCity + ' - Size: ' + newCitySplit.size() + ' - City Contents: ' + newCitySplit);

                    l.Mailing_City__c = newCity;
                    newCity = '%' + newCity;
                    citySet.add(newCity);

                    newAddressSplit = addressSplitTrim.split(' ', 2);
                    system.debug('newAddressSplit' + newAddressSplit);
                    if(newAddressSplit[0] != NULL){
                        l.Mailing_State__c = newAddressSplit[0];
                        system.debug('State: ' + l.Mailing_State__c);
                    }
                    if(newAddressSplit[1] != NULL){
                        newZip = newAddressSplit[1];
                        newCountry = newAddressSplit[1];
                        newCountry = newCountry.right(2);

                        newZip = newZip.left(newZip.length()-3);
                        l.Mailing_Zip_Code__c = newZip;
                        zipSet.add(newZip);
                        l.Mailing_Country__c = newCountry;
                        system.debug('Zip: ' + l.Mailing_Zip_Code__c + ' - Country: ' + l.Mailing_Country__c);
                    }
                }
            }
        }

        system.debug('*** zipset.size() *** ' + zipset.size() );
        system.debug('*** zipset *** ' + zipset );
        system.debug('*** citySet.size() *** ' + citySet.size() );
        system.debug('*** citySet *** ' + citySet );

        if(zipSet.size() > 0 && citySet.size() > 0){
            for(Account a : [SELECT BillingCity
                             FROM Account
                             WHERE BillingPostalCode =:zipSet
                             AND BillingPostalCode != NULL
                             AND (ERP_Active__c = true or Active_Sales__c = true)
                             //AND BillingCity like :citySet
                            ])
            {
                if(a.BillingCity != NULL){
                    newCityRaw = a.BillingCity;
                    newCitySplit = newCityRaw.split(' ', -2);
                    if(newCitySplit.size() > 1){
                        pos = newCitySplit.size() - 1;
                        newCity = newCitySplit[pos].trim();
                        cityMap.put(newCity, a.BillingCity);
                    }
                }

            }
        }

        system.debug('cityMap: ' + cityMap);
        for(Lab_Participant__c l : newTrigger){
            if(cityMap.containsKey(l.Mailing_City__c)){
                l.Mailing_City__c = cityMap.get(l.Mailing_City__c);
                system.debug('Updating City! ' + cityMap.get(l.Mailing_City__c));
            }
            if(l.Mailing_Street_Address__c != NULL){
                newAddress = l.Mailing_Street_Address__c;
                newAddress = newAddress.remove(l.Mailing_City__c);
                l.Mailing_Street_Address__c = newAddress;
            }
        }
        system.debug(' -- Finished lpAddressFix --');

    }
    public static void assignLabUser(List<Lab_Participant__c> newTrigger, Map<Id,Lab_Participant__c> oldTrigger,String type){
        // This 'before' trigger/class assigns a user ID to the 'Territory Based Owner'
        // field using State, Zip, and Business unit in confunction with the ZPSA rules
        // found in the 'Territory Alignment Rules' object in order to get away from using
        // a Zip Code database. ESC - 08Mar2016
        // This is a 'copied' method from: territory_User_Assignment.assignUser - ESC 14Apr2016

        //
        // Lab_Participant__c
        // Mailing_State__c
        // Mailing_Zip_Code__c
        //

        if(master_TriggerHelperClass.qd('assignLabUser')){
            system.debug(' -- Starting assignLabUser Class - ZPSA Territory Assignment -- ');

            set<String> regionFilterKey = new set<String>();
            set<String> zipFilterKey = new set<String>();
            set<String> buList = new set<String>();
            list<Lab_Participant__c> changedLPs = new list<Lab_Participant__c>();


            set<Id> labIds = new set<Id>();
            for(Lab_Participant__c lpu : newTrigger){
                labIds.add(lpu.Lab__c);
            }

            Map<Id, Lab__c> labMap = new Map<Id, Lab__c>([SELECT Id, Default_Approver__c FROM Lab__c WHERE Id =:labIds]);
            for(Lab_Participant__c lp : newTrigger){
                if(labMap.get(lp.Lab__c).Default_Approver__c != NULL){
                    system.debug('Exception Approver Assignment using Default Approver on Lab');
                    lp.Zip_Code_Auto_Route__c = TRUE;
                    lp.Approver__c = labMap.get(lp.Lab__c).Default_Approver__c;
                }
            }

            //Let's check to see if anything changed and remove it from the list if it has.
            if(type == 'insert'){
                for(Lab_Participant__c l : newTrigger){
                    if(
                        // If BU, State or Zip are not NULL and the Force Check is TRUE add the lead to the list
                        l.Business_Unit__c != NULL &&
                        (l.Mailing_State__c != NULL ||
                         l.Mailing_Zip_Code__c != NULL)
                    ){
                        changedLPs.add(l);
                        buList.add(l.Business_Unit__c);
                    }
                }
            }
            else if(type == 'update'){
                for(Lab_Participant__c l : newTrigger){
                    IF(
                        // If BU is not NULL and the BU, Zip, State have changed add the lead to the list
                        l.Business_Unit__c != NULL &&
                        (l.Mailing_State__c != oldTrigger.get(l.Id).Mailing_State__c ||
                         l.Mailing_Zip_Code__c != oldTrigger.get(l.Id).Mailing_Zip_Code__c ||
                         l.Business_Unit__c != oldTrigger.get(l.Id).Business_Unit__c
                        )
                    ){
                        changedLPs.add(l);
                        buList.add(l.Business_Unit__c);
                    }
                    else if(
                        // If BU, State or Zip are not NULL and the Force Check is TRUE add the lead to the list
                        l.Business_Unit__c != NULL &&
                        (l.Mailing_State__c != NULL ||
                         l.Mailing_Zip_Code__c != NULL) &&
                        l.Status__c == 'New'
                        //l.Force_Territory_Assigment_Check__c == TRUE
                        /*
                        (l.Force_Territory_Assigment_Check__c == TRUE ||
                         l.Assign_Using_Territories__c)
                        */
                    ){
                        changedLPs.add(l);
                        buList.add(l.Business_Unit__c);
                    }
                }
            }



            boolean stage2 = FALSE; // Used to validate that there are any records to process.
            integer rnum = 0;
            if(changedLPs.size() > 0){
                for(Lab_Participant__c l : changedLPs){
                    if(l.Approver__c == NULL){
                        if(l.Mailing_State__c != NULL){
                            regionFilterKey.add(l.Mailing_State__c + '-A659');
                            regionFilterKey.add(l.Mailing_State__c + '-A688');
                            regionFilterKey.add(l.Mailing_State__c + '-A689');
                            system.debug('Adding regionFilterKey: ' + regionFilterKey);
                            stage2 = TRUE;
                        }
                        if(l.Mailing_Zip_Code__c != NULL){
                            zipFilterKey.add(l.Mailing_Zip_Code__c + '-A626');
                            zipFilterKey.add(l.Mailing_Zip_Code__c.left(3) + '-A675');
                            zipFilterKey.add(l.Mailing_Zip_Code__c.left(5) + '-A667');
                            zipFilterKey.add(l.Mailing_Zip_Code__c.left(5) + '-A668');
                            // Non-Standard Zip Code ZPSA Tables - These are the Zip+Customer Group Tables
                            zipFilterKey.add(l.Mailing_Zip_Code__c.left(3) + '-A672');
                            zipFilterKey.add(l.Mailing_Zip_Code__c.left(3) + '-A671');
                            zipFilterKey.add(l.Mailing_Zip_Code__c.left(5) + '-A663');
                            zipFilterKey.add(l.Mailing_Zip_Code__c.left(5) + '-A664');
                            system.debug('Adding zipFilterKey: ' + zipFilterKey);
                            stage2 = TRUE;
                        }
                        if(!stage2){
                            changedLPs.remove(rnum);
                            system.debug('Removing: ' + l.Name);
                        }
                        rnum++;
                    }
                }
            }
            else{
                system.debug('Missing both Zip AND State OR Business Unit');
            }

            system.debug('List of BUs: ' + buList);

            if(stage2){
                system.debug('-- Starting Stage2 of User Assign --');
                map<string,Id> tuMap = new map<string,Id>();
                for(Territory_User__c tm : [Select User__c, User__r.Name, Territory_Number__c
                                            FROM Territory_User__c
                                            WHERE Business_Unit__c  = :buList
                                            AND User_Active__c = TRUE
                                            AND Role__c != 'Inside Sales'
                                            ORDER BY Territory_Number__c])
                {
                    tuMap.put(tm.Territory_Number__c, tm.User__c);
                    system.debug('Adding Territory Number: ' + tm.Territory_Number__c + ' and the User: ' + tm.User__r.Name);
                }

                map<string,string> stateMap = new map<string,string>();
                map<string,string> zipMap = new map<string,string>();
                // Match State/Region
                if(regionFilterKey.size() > 0){
                    for(Territory_Alignment__c ta : [SELECT Territory__c, Region__c
                                                     FROM Territory_Alignment__c
                                                     WHERE Filter_Key__c IN :regionFilterKey
                                                     AND Business_Unit__c IN :buList
                                                     AND Expired__c = FALSE])
                    {
                        stateMap.put(ta.Region__c, ta.Territory__c);
                        system.debug('Adding State: ' + stateMap);
                    }
                }
                else{
                    system.debug('No State Filters');
                }

                // Match Zipcode
                if(zipFilterKey.size() > 0){
                    for(Territory_Alignment__c ta : [SELECT Territory__c, Zipcode__c
                                                     FROM Territory_Alignment__c
                                                     WHERE Alt_Filter_Key__c IN :zipFilterKey
                                                     AND Business_Unit__c IN :buList
                                                     AND Expired__c = FALSE])
                    {
                        zipMap.put(ta.Zipcode__c, ta.Territory__c);
                        system.debug('Adding Zip: ' + zipMap);
                    }
                }
                else{
                    system.debug('No Zip Filters');
                }


                string tnumber;
                string tuserid;
                rnum = 0;
                for(Lab_Participant__c l : changedLPs){
                    ++rnum;
                    system.debug('[' + rnum + '] Final Check: ' + l.Full_Name__c );
                    if(l.Approver__c == NULL){
                        if(l.Mailing_Zip_Code__c != NULL){

                            if(zipMap.get(l.Mailing_Zip_Code__c.left(5)) != NULL){
                                tnumber = zipMap.get(l.Mailing_Zip_Code__c.left(5));
                            }
                            else if(zipMap.get(l.Mailing_Zip_Code__c.left(3)) != NULL){
                                tnumber = zipMap.get(l.Mailing_Zip_Code__c.left(3));
                            }
                            else if(zipMap.get(l.Mailing_Zip_Code__c) != NULL){
                                tnumber = zipMap.get(l.Mailing_Zip_Code__c);
                            }

                            if(tuMap.get(tnumber) != NULL){
                                tuserid = tuMap.get(tnumber);
                                system.debug('[' + rnum + '] Zip Match! - UserId: ' + tuserid);
                            }
                        }
                        else{
                            system.debug('[' + rnum + ']Empty Zip Code!');
                        }
                        if(l.Mailing_State__c == NULL){
                            system.debug('[' + rnum + ']Empty State Code!');
                        }
                        if(l.Mailing_State__c != NULL && tuserid == NULL){
                            if(stateMap.get(l.Mailing_State__c) != NULL){
                                tnumber = stateMap.get(l.Mailing_State__c);
                            }
                            if(tuMap.get(tnumber) != NULL){
                                tuserid = tuMap.get(tnumber);
                                system.debug('[' + rnum + '] State Match! - UserId: ' + tuserid);
                            }
                        }


                        if(tuserid != NULL){
                            l.Approver__c = tuserid;
                            l.Force_Territory_Assigment_Check__c = FALSE;
                        }
                        else{
                            system.debug('[' + rnum + ']No Match!');
                        }
                    }


                } // End Final Loop
            } // End stage2 IF/Then
            else{
                system.debug('No Stage 2');
            }
        }
        system.debug(' -- Existing assignLabUser Class - ZPSA Territory Assignment -- ');
    } // End Class



    public static void addLP(List<Lab_Evaluations__c> newTrigger){
        // Links the Lab and Lab Participent to the Lab Evaluation
        // Creates the related Lead if Create_Lead__c is TRUE
        // Terms:
        // Lab Participant = lp
        // Lab Evaluation = le

        string key;
        map<String, Id> lpMap = new map<String, Id>();
        map<String, Id> labMap = new map<String, Id>();

        list<Lead> createLead = new list<Lead>();
        list<Lab_Participant__c> updateLP = new list<Lab_Participant__c>();

        set<Id> labIds = new set<Id>();
        set<Id> updatelabIds = new set<Id>();
        set<String> emailList = new set<String>();
        set<String> labNames = new set<String>();

        for(Lab_Evaluations__c le : newTrigger){
            if(le.Course_Name__c != NULL){
                labNames.add(le.Course_Name__c);
            }
            if(le.Email__c != NULL){
                emailList.add(le.Email__c);
            }
        }
        for(Lab__c lab : [SELECT Id, Name
                          FROM Lab__c
                          WHERE Name =:labNames])
        {
            labMap.put(lab.Name, lab.Id);
        }

        for(Lab_Participant__c lp : [SELECT Id, Email__c, Lab__r.Id
                                     FROM Lab_Participant__c
                                     WHERE Email__c =:emailList
                                     AND Lab__c =:labMap.values()])
        {
            lpMap.put(lp.Lab__c + lp.Email__c, lp.Id);
        }

        for(Lab_Evaluations__c le : newTrigger){
            // Associate the Lab
            if(labMap.containsKey(le.Course_Name__c) && le.Lab__c == NULL){
                le.Lab__c = labMap.get(le.Course_Name__c);
            }

            // Associate the Lab Participant
            if(lpMap.containsKey(le.Lab__c + le.Email__c) && le.Lab_Participant__c == NULL){
                le.Lab_Participant__c = lpMap.get(le.Lab__c + le.Email__c);
            }

            if(le.Create_Lead__c && le.Lead__c == NULL){
                updatelabIds.add(le.Lab_Participant__c);
            }

        }

        // Create the Lead!
        if(updatelabIds.size() > 0){

            for(Lab_Participant__c lp : [SELECT Id, First_Name__c, Last_Name__c, Title__c, Email__c, Phone__c,
                                         Hospital_Agency__c, Business_Unit__c, Mailing_Street_Address__c, Mailing_Street_Address_2__c,
                                         Mailing_City__c, Mailing_State__c, Mailing_Zip_Code__c, Mailing_Country__c
                                         FROM Lab_Participant__c
                                         WHERE Id =:updatelabIds])
            {
                lead newLead = new lead(
                    FirstName = lp.First_Name__c,
                    LastName = lp.Last_Name__c,
                    Title = lp.Title__c,
                    Company = lp.Hospital_Agency__c,
                    LeadSource = 'Lab',
                    Phone = lp.Phone__c,
                    Email = lp.Email__c,
                    Business_Unit__c = lp.Business_Unit__c,
                    Street = lp.Mailing_Street_Address__c + ' ' + lp.Mailing_Street_Address_2__c,
                    City = lp.Mailing_City__c,
                    State = lp.Mailing_State__c,
                    PostalCode = lp.Mailing_Zip_Code__c,
                    Country = lp.Mailing_Country__c,
                    Lab_Key__c = lp.Id // Field wasn't being used, hijacking it to associate the lead back to the LP
                );
                createLead.add(newLead);
            }
            if(createLead.size() > 0){
                insert createLead;

                // This associated associates the Lead with the LP
                for(lead l : createLead){
                    Lab_Participant__c upLab = new Lab_Participant__c(
                        Id = l.Lab_Key__c,
                        Lead__c = l.Id
                    );
                    updateLP.add(upLab);
                }
                if(updateLP.size() > 0){
                    update updateLP;
                }
            }
        }
    }

    public static void addNewLead(List<Lab_Evaluations__c> newTrigger){
        // Relates the created lead to the Lab Eval - Had to use after trigger to get the le Id

        map<String, Id> leadMap = new map<String, Id>();
        map<String, Id> leMap = new map<String, Id>();
        set<String> labEvalKey = new set<String>();

        list<Lab_Evaluations__c> updateLE = new list<Lab_Evaluations__c>();

        for(Lab_Evaluations__c le : newTrigger){
            if(le.Create_Lead__c && le.Lead__c == NULL){
                labEvalKey.add(le.Lab_Participant__c + le.Email__c);
                system.debug('Adding Key!' + le.Lab_Participant__c + le.Email__c);
            }
        }

        if(labEvalKey.size() > 0){

            for(Lead l : [SELECT Id, Lab_Eval_Key__c
                          FROM Lead
                          WHERE Lab_Eval_Key__c =:labEvalKey
                          ORDER BY CreatedDate])
            {
                leadMap.put(l.Lab_Eval_Key__c, l.Id);
            }

            for(Lab_Evaluations__c le : newTrigger){
                if(le.Lead__c == NULL && leadMap.containsKey(le.Lab_Participant__c + le.Email__c)){
                    Lab_Evaluations__c upLE = new Lab_Evaluations__c(
                        Id = le.Id,
                        Lead__c = leadMap.get(le.Lab_Participant__c + le.Email__c)
                    );
                    updateLE.add(upLE);
                }
            }
            if(updateLE.size() > 0){ update updateLE; }
        }
    }


    /*
    public static void zipLookup_Before(List<Lab_Participant__c> newTrigger){
        // This method looks at the zip code and the business unit and determines
        // Which 'Zip Code Territory' file should be related in order to do the
        // Business Unit looking and relates it to the Lab Participant record.
        // 03/Sept/2015 - ESC
        // Changed this to a 'Before' trigger - 22Feb2016 - ESC

        System.debug('Starting Legacy Lab_Participant__c ZipLookup! -------');
        set<String> zips = new set<String>();
        for(Lab_Participant__c lp : newTrigger){
            if(lp.Lead_Zip_Code__c  != NULL){
                zips.add(lp.Lead_Zip_Code__c );
            }
            else if(lp.Zip_Code_Zip__c != NULL){
                zips.add(lp.Zip_Code_Zip__c);
            }
        }

        Map<String, Id> listZip = new Map<String, Id>();
        for(Zip_Code_Territories__c zcMap : [SELECT Zip_Code__c, Id
                                             FROM Zip_Code_Territories__c
                                             WHERE Zip_Code__c IN :zips])
        {
            listZip.put(zcMap.Zip_Code__c, zcMap.Id);
            System.debug('Zip Code Map:' + listZip);
        }
        System.debug('listZip Size: ' + listZip.size());

        for(Lab_Participant__c lp : newTrigger){
            if(lp.Lead_Zip_Code__c != NULL && listZip.size() > 0 && listZip.get(lp.Lead_Zip_Code__c) != NULL){
                lp.Zip_Code_Territories__c = listZip.get(lp.Lead_Zip_Code__c);
                system.debug('Assigning Zip Code Territory:' + listZip.get(lp.Lead_Zip_Code__c) );
            }
        }
        System.debug('Existing Legacy Lab_Participant__c ZipLookup! -------');
    }*/
    /*
    public static void approval(List<Lab_Participant__c> newTrigger){
        System.debug('Starting: Approval Call');
        List<Approval.ProcessSubmitRequest> requestList = new List<Approval.ProcessSubmitRequest> ();
        for(Lab_Participant__c lpa : newTrigger){
            if(lpa.Status__c == 'New' && lpa.Approver__c != NULL && lpa.Auto_Approve_All_Attendees__c == FALSE){
                //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ProcessSubmitRequest.htm#apex_ProcessSubmitRequest
                Approval.ProcessSubmitRequest addRequest = new Approval.ProcessSubmitRequest();
                addRequest.setObjectId(lpa.id);
                addRequest.setComments('Submitted for approval. Please Approve.');
                addRequest.setSubmitterId(lpa.Approver__c);
                addRequest.setProcessDefinitionNameOrId('Lab_Approval');
                addRequest.setSkipEntryCriteria(true);
                system.debug('req:'+addRequest);

                requestList.add(addRequest);
                //Approval.ProcessResult result = Approval.process(addRequest);
                //List<Approval.ProcessResult> result = Approval.process(addRequest);
            }
        }
        Approval.ProcessResult[] processResults = null;
        try {
            if(requestList.size() > 0){
                processResults = Approval.process(requestList, true);
            }
        }
        catch (System.DmlException e) {
            System.debug('Exception Is ' + e.getMessage());
        }
    }*/

    /*
    public static void updateApprover(List<Lab_Participant__c> newTrigger){

//        SELECT Id FROM ProcessInstance WHERE TargetObjectId IN :trigger.newMap.keySet()
//        SELECT ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId
//
//        SELECT Id FROM ProcessInstance WHERE TargetObjectId = 'a1cE00000020CjA'
//        SELECT ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = '04gE0000004xGaEIAU'
//        SELECT Id (SELECT Actor.Id FROM WorkItems) FROM ProcessInstance WHERE
//        WHERE Account__r.id IN :trigger.newMap.keySet()
//
//        SELECT Id,TargetObjectId, (SELECT ActorId FROM Workitems)
//        FROM ProcessInstance
//        WHERE TargetObjectId IN :trigger.newMap.keySet()
//

        system.debug('Starting updateApprover');
        map<Id,Id> actorMap = new map<Id,Id>();
        map<Id,Id> updateMap = new map<Id,Id>();
        map<id,ProcessInstanceWorkitem> pMap = new map<id,ProcessInstanceWorkitem>();
        set<Id> pId = new set<Id>();
        for(ProcessInstanceWorkitem p : [SELECT p.Id, p.ProcessInstance.TargetObjectId, p.ActorId
                                         FROM ProcessInstanceWorkitem p
                                         WHERE p.ProcessInstance.TargetObjectId IN :newTrigger])
        {
            system.debug('p: ' + p.ProcessInstance.TargetObjectId);
            pMap.put(p.ProcessInstance.TargetObjectId, p);
        }
        list<ProcessInstanceWorkitem> piList = new list<ProcessInstanceWorkitem>();

        for(Lab_Participant__c lp : newTrigger){
            if(pMap.get(lp.Id) != NULL){
                ProcessInstanceWorkitem updatePI = new ProcessInstanceWorkitem(
                    ActorId = lp.Approver__c,
                    Id = pMap.get(lp.Id).Id
                );
                piList.add(updatePI);
            }
        }
        if(piList.size() > 0){
            update piList;
        }
        //SELECT ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = '04gE0000004xGaEIAU'
    }*/

    // The rest of this class is dormant code that I used at one point but either due to process change removed or found that formstack could
    // accomplish I discontinued the use of. - ESC - 13Jan2017

        /*
    public static void cloneUser(List<Lab_Participant__c> newTrigger){
        list<Lab_Participant__c> LPlist = new list<Lab_Participant__c>();
        for(Lab_Participant__c lp : newTrigger){
            if(lp.Lab_Time_2__c != NULL){
                Lab_Participant__c newLP = new Lab_Participant__c(
                    Name = lp.Name,
                    Address__c = lp.Address__c,
                    Affiliation__c = lp.Affiliation__c,
                    Email__c = lp.Email__c,
                    First_Name__c = lp.First_Name__c,
                    Full_Name__c = lp.Full_Name__c,
                    Hospital_Agency__c = lp.Hospital_Agency__c,
                    Lab__c = lp.Lab__c,
                    Lab_Participant_Browserr__c = lp.Lab_Participant_Browserr__c,
                    Lab_Participant_IP__c = lp.Lab_Participant_IP__c,
                    Lab_Time__c = lp.Lab_Time_2__c,
                    Lab_Unique_ID__c = lp.Lab_Unique_ID__c,
                    Last_Name__c = lp.Last_Name__c,
                    License_Certificate_Number__c = lp.License_Certificate_Number__c,
                    License_Expiration__c = lp.License_Expiration__c,
                    Licensure_Certificate_Country__c = lp.Licensure_Certificate_Country__c,
                    Licensure_Certificate_State__c = lp.Licensure_Certificate_State__c,
                    Mailing_State__c = lp.Mailing_State__c,
                    Mailing_Zip_Code__c = lp.Mailing_Zip_Code__c,
                    Phone__c = lp.Phone__c,
                    Place_of_Employment__c = lp.Place_of_Employment__c,
                    Signed_up_for_Airway__c = lp.Signed_up_for_Airway__c,
                    Signed_up_for_EZIO__c = lp.Signed_up_for_EZIO__c,
                    Title__c = lp.Title__c,
                    Type_of_Licensure_Certificate__c = lp.Type_of_Licensure_Certificate__c,
                    What_is_your_department__c = lp.What_is_your_department__c,
                    What_is_your_level_of_responsibility__c = lp.What_is_your_level_of_responsibility__c,
                    Zip_Code_Formstack_Affiliation__c = lp.Zip_Code_Formstack_Affiliation__c
                );
                LPlist.add(newLP);
                lp.Lab_Time_2__c = NULL;
            }
        }
        if(LPlist.size() > 0){
            insert LPlist;
        }


    }*/

    /* More automation that Formstack handles so not going to use code if unnecessary. 22Sept2015 - ESC
    public static void addCampaign(List<Lab__c> newTrigger){
        list<String> listLabs = new list<String>();
        for(Lab__c l : newTrigger){
            listLabs.add(l.Name);
        }
        map<String, Id> mapCampaigns = new map<String, Id>();
        for(Campaign c : [SELECT Name, Id FROM Campaign where Name IN :listLabs]){
            mapCampaigns.put(c.Name, c.Id);
        }
        list<Lab__c> labupdate = new list<Lab__c>();
        for(Lab__c l : newTrigger){
            if(mapCampaigns.get(l.Name) != NULL){
                Lab__c lrec = new Lab__c(
                    Id = l.Id,
                    Campaign__c = mapCampaigns.get(l.Name)
                );
                labupdate.add(lrec);
            }
        }
        if(labupdate.size() > 0){
            update labupdate;
        }
    } */
    /* More automation that Formstack handles so not going to use code if unnecessary. 22Sept2015 - ESC
    public static void addMember(List<Lead> newTrigger){
        set<String> setCampaign = new set<String>();
        for(Lead l : newTrigger){
            setCampaign.add(l.lab_key__c);
        }
        list<Campaign> checkCampaign = new list<Campaign>([SELECT NAME, Id from Campaign WHERE Name IN :setCampaign]);
        map<String, Id> cmap = new map<String, Id>();
        for(Campaign c : checkCampaign){
                cmap.put(c.Name, c.Id);
        }

        list<CampaignMember> cmList = new list<CampaignMember>();

        for(Lead l : newTrigger){
            if(l.Lab_Key__c != NULL){
                boolean campaignExists = FALSE;
                id campaignID;
                for(Campaign c : checkCampaign){
                    if(cmap.get(l.Lab_Key__c) == NULL){
                        Campaign cc = New Campaign(
                            Name = l.Lab_Key__c,
                            Status = 'In Progress',
                            IsActive = TRUE,
                            Type = 'Lab'
                        );
                        insert cc;
                        campaignID = cc.id;
                    }
                    else{
                        campaignID = cmap.get(l.Lab_Key__c);
                    }

                    // Associate to the Campaign
                    CampaignMember cmAdd = new CampaignMember(
                        CampaignId = campaignID,
                        LeadId = l.Id,
                        Status = 'Responded'
                    );
                    cmList.add(cmAdd);
                }
            }
        }
        if(cmlist.size() > 0){
            system.debug('Adding user to Campaign - addMember: SUCCESS!');
            insert cmlist;
        }
    }
*/
    /* Works wonderfully - Formstack also can do this and does so removing this. 22Sept2015 - ESC
    public static void linkLead(List<Lab_Participant__c> newTrigger){
        // This links the Lead to the Lab Participant
        System.debug('Starting Lead Linking to Lab Partcipant');
        list<String> listLabKey = new list<String>();
        for(Lab_Participant__c l : newTrigger){
            listLabKey.add(l.Lab_Unique_ID__c);
        }

        Map<String, Id> leadMap = new Map<String, Id>();
        for(Lead ld : [SELECT Lab_Unique_ID__c, Id FROM LEAD WHERE Lab_Unique_ID__c IN :listLabKey]){
            leadMap.put(ld.Lab_Unique_ID__c, ld.Id);
        }

        for(Lab_Participant__c l : newTrigger){
            if(l.Lab_Unique_ID__c != NULL && l.Lead__c == NULL){
                if(l.Business_Unit__c == NULL){
                    l.Business_Unit__c = l.Zip_Code_Business_Unit__c;
                }
                if(l.Lead__c == NULL){
                    system.debug('Linking Lead to Lab:' + leadMap.get(l.Lab_Unique_ID__c));
                    l.Lead__c = leadMap.get(l.Lab_Unique_ID__c);
                }
            }
        }
    }
*/

    /* This was the 'After' Code
    public static void zipLookup(List<Lab_Participant__c> newTrigger){
        // This method looks at the zip code and the business unit and determines
        // Which 'Zip Code Territory' file should be related in order to do the
        // Business Unit looking and relates it to the Lab Participant record.
        // 03/Sept/2015 - ESC

        System.debug('Starting --------- Lab_Participant__c ZipLookup! -------');
        set<String> zips = new set<String>();
        for(Lab_Participant__c lp : newTrigger){
            if(lp.Lead_Zip_Code__c  != NULL){
                zips.add(lp.Lead_Zip_Code__c );
            }
            else if(lp.Zip_Code_Zip__c != NULL){
                zips.add(lp.Zip_Code_Zip__c);
            }
        }

        Map<String, Id> listZip = new Map<String, Id>();
        for(Zip_Code_Territories__c zcMap : [SELECT Zip_Code__c, Id
                                             FROM Zip_Code_Territories__c
                                             WHERE Zip_Code__c IN :zips])
        {
            listZip.put(zcMap.Zip_Code__c, zcMap.Id);
            System.debug('Zip Code Map:' + listZip);
        }
        System.debug('listZip Size: ' + listZip.size());
        list<Lab_Participant__c> lpUpdate = new list<Lab_Participant__c>();
        for(Lab_Participant__c lp : newTrigger){
            if(lp.Lead_Zip_Code__c != NULL && listZip.size() > 0){
                Lab_Participant__c lpadd = new Lab_Participant__c(
                    Zip_Code_Territories__c = listZip.get(lp.Lead_Zip_Code__c),
                    Id = lp.Id
                );
                system.debug('Assigning Zip Code Territory:' + listZip.get(lp.Lead_Zip_Code__c) );
                lpUpdate.add(lpadd);
            }
        }
        if(lpUpdate.size() > 0){
            update lpUpdate;
        }
    }*/


    /*public static void assignApprover_Before(List<Lab_Participant__c> newTrigger){
        System.debug('--------- Starting UserAssign! -------');
        set<String> usrs = new set<String>();
        set<Id> labIds = new set<Id>();

        for(Lab_Participant__c lpu : newTrigger){
            usrs.add(lpu.Zip_Code_Territory_User__c);
            labIds.add(lpu.Lab__c);
        }
        system.debug('usrs: ' + usrs);
        system.debug('labIds: ' + labIds);

        Map<Id, Lab__c> labMap = new Map<Id, Lab__c>([SELECT Id, Default_Approver__c FROM Lab__c WHERE Id =:LabIds]);



        Map<String, ID> listUsrs = new Map<String, ID>();
        system.debug('labMap: ' + labMap);

        for(Territory_User__c usrMap : [SELECT Territory_Master__r.name, User__c
                                        FROM Territory_User__c
                                        WHERE Territory_Master__r.name IN :usrs AND User__r.IsActive = TRUE])
        {
            listUsrs.put(usrMap.Territory_Master__r.name, usrMap.User__c);
            System.debug('Map List Debug:Name -------' + usrMap.Territory_Master__r.name);
            System.debug('Map List Debug:UserId -------' + usrMap.User__c);
        }

        list<Lab_Participant__c> lpUpdate = new list<Lab_Participant__c>();
        for(Lab_Participant__c lp : newTrigger){
            if(labMap.get(lp.Lab__c).Default_Approver__c != NULL){
                system.debug('Exception Approver Assignment using Default Approver on Lab');
                lp.Zip_Code_Auto_Route__c = TRUE;
                lp.Approver__c = labMap.get(lp.Lab__c).Default_Approver__c;

            }
            else if(lp.Zip_Code_Auto_Route__c == FALSE && listUsrs.size() > 0 && listUsrs.get(lp.Zip_Code_Territory_User__c) != NULL){
                system.debug('Standard Approver Assignment using Territories');
                lp.Zip_Code_Auto_Route__c = TRUE;
                lp.Approver__c = listUsrs.get(lp.Zip_Code_Territory_User__c);
            }
        }
    }*/
    /*
    public static void assignApprover(List<Lab_Participant__c> newTrigger){
        // Method looks at the related Zip Code Territory record and the business unit and
        // Assigns the related 'active' territory user.
        System.debug('--------- Starting UserAssign! -------');
        set<String> usrs = new set<String>();
        set<Id> labIds = new set<Id>();

        for(Lab_Participant__c lpu : newTrigger){
            usrs.add(lpu.Zip_Code_Territory_User__c);
            labIds.add(lpu.Lab__c);
        }

        system.debug('usrs: ' + usrs);
        system.debug('labIds: ' + labIds);

        Map<Id, Lab__c> labMap = new Map<Id, Lab__c>([SELECT Id, Default_Approver__c FROM Lab__c WHERE Id =:LabIds]);



        Map<String, ID> listUsrs = new Map<String, ID>();
        system.debug('labMap: ' + labMap);

        for(Territory_User__c usrMap : [SELECT Territory_Master__r.name, User__c
                                        FROM Territory_User__c
                                        WHERE Territory_Master__r.name IN :usrs AND User__r.IsActive = TRUE])
        {
            listUsrs.put(usrMap.Territory_Master__r.name, usrMap.User__c);
            System.debug('Map List Debug:Name -------' + usrMap.Territory_Master__r.name);
            System.debug('Map List Debug:UserId -------' + usrMap.User__c);
        }

        list<Lab_Participant__c> lpUpdate = new list<Lab_Participant__c>();
        for(Lab_Participant__c lp : newTrigger){
            if(labMap.get(lp.Lab__c).Default_Approver__c != NULL){
                system.debug('Exception Approver Assignment using Default Approver on Lab');
                Lab_Participant__c lpadd = new Lab_Participant__c(
                    Id = lp.Id,
                    Zip_Code_Auto_Route__c = TRUE,
                    Approver__c = labMap.get(lp.Lab__c).Default_Approver__c
                );
                lpUpdate.add(lpadd);
            }
            else if(lp.Zip_Code_Auto_Route__c == FALSE && listUsrs.size() > 0 && listUsrs.get(lp.Zip_Code_Territory_User__c) != NULL){
                system.debug('Standard Approver Assignment using Territories');
                Lab_Participant__c lpadd = new Lab_Participant__c(
                    Id = lp.Id,
                    Zip_Code_Auto_Route__c = TRUE,
                    Approver__c = listUsrs.get(lp.Zip_Code_Territory_User__c)
                );
                lpUpdate.add(lpadd);
            }
        }
        if(lpUpdate.size() > 0){
            system.debug('Approver DML: ' + lpUpdate);
            update lpUpdate;
        }
    }
    public static void beforealtassignApprover(List<Lab_Participant__c> newTrigger){

        for(Lab_Participant__c lp : newTrigger){
            system.debug('-- Starting ALT Approval Assignment Class --');
            if(lp.Approver__c == NULL && lp.Territory_Based_Owner_ID__c  != NULL){
                lp.Approver__c = lp.Territory_Based_Owner_ID__c;
                system.debug('-- Adding Approval User Id --' + lp.Territory_Based_Owner_ID__c );
            }
        }
    }
    */
    /*
    public static void altassignApprover(List<Lab_Participant__c> newTrigger){
        list<Lab_Participant__c> lpList = new list<Lab_Participant__c>();
        for(Lab_Participant__c lp : newTrigger){
            system.debug('-- Starting ALT Approval Assignment Class --');
            if(lp.Approver__c == NULL && lp.Territory_Based_Owner_ID__c  != NULL){
                Lab_Participant__c updateLP = new Lab_Participant__c(
                    Id = lp.Id,
                    Approver__c = lp.Territory_Based_Owner_ID__c
                );
                system.debug('-- Adding Approval User Id --' + lp.Territory_Based_Owner_ID__c );
                lpList.add(updateLP);
            }
        }
        if(lpList.size() > 0){
            update lpList;
        }
    }
    */



    // Mega Class
    /*public static void Mega3Class(List<Lab_Participant__c> newTrigger){
        // This method looks at the zip code and the business unit and determines
        // Which 'Zip Code Territory' file should be related in order to do the
        // Business Unit looking and relates it to the Lab Participant record.
        // 03/Sept/2015 - ESC
        // Changed this to a 'Before' trigger - 22Feb2016 - ESC

        System.debug('Starting --------- Lab_Participant__c ZipLookup! -------');
        set<String> zips = new set<String>();
        for(Lab_Participant__c lp : newTrigger){
            if(lp.Lead_Zip_Code__c  != NULL){
                zips.add(lp.Lead_Zip_Code__c );
            }
            else if(lp.Zip_Code_Zip__c != NULL){
                zips.add(lp.Zip_Code_Zip__c);
            }
        }

        Map<String, Id> listZip = new Map<String, Id>();
        for(Zip_Code_Territories__c zcMap : [SELECT Zip_Code__c, Id
                                             FROM Zip_Code_Territories__c
                                             WHERE Zip_Code__c IN :zips])
        {
            listZip.put(zcMap.Zip_Code__c, zcMap.Id);
            System.debug('Zip Code Map:' + listZip);
        }
        System.debug('listZip Size: ' + listZip.size());

        for(Lab_Participant__c lp : newTrigger){
            if(lp.Lead_Zip_Code__c != NULL && listZip.size() > 0 && listZip.get(lp.Lead_Zip_Code__c) != NULL){
                lp.Zip_Code_Territories__c = listZip.get(lp.Lead_Zip_Code__c);
                system.debug('Assigning Zip Code Territory:' + listZip.get(lp.Lead_Zip_Code__c) );
            }
        }


    //public static void assignApprover(List<Lab_Participant__c> newTrigger){
        // Method looks at the related Zip Code Territory record and the business unit and
        // Assigns the related 'active' territory user.
        System.debug('--------- Starting UserAssign! -------');
        set<String> usrs = new set<String>();
        set<Id> labIds = new set<Id>();

        for(Lab_Participant__c lpu : newTrigger){
            usrs.add(lpu.Zip_Code_Territory_User__c);
            labIds.add(lpu.Lab__c);
        }

        Map<Id, Lab__c> labMap = new Map<Id, Lab__c>([SELECT Id, Default_Approver__c FROM Lab__c WHERE Id =:LabIds]);



        Map<String, ID> listUsrs = new Map<String, ID>();
        system.debug('labMap: ' + labMap);

        for(Territory_User__c usrMap : [SELECT Territory_Master__r.name, User__c
                                        FROM Territory_User__c
                                        WHERE Territory_Master__r.name IN :usrs AND User__r.IsActive = TRUE])
        {
            listUsrs.put(usrMap.Territory_Master__r.name, usrMap.User__c);
            System.debug('Map List Debug:Name -------' + usrMap.Territory_Master__r.name);
            System.debug('Map List Debug:UserId -------' + usrMap.User__c);
        }

        list<Lab_Participant__c> lpUpdate = new list<Lab_Participant__c>();
        for(Lab_Participant__c lp : newTrigger){
            if(labMap.get(lp.Lab__c).Default_Approver__c != NULL){
                system.debug('Exception Approver Assignment using Default Approver on Lab');
                    lp.Zip_Code_Auto_Route__c = TRUE;
                    lp.Approver__c = labMap.get(lp.Lab__c).Default_Approver__c;

            }
            else if(lp.Zip_Code_Auto_Route__c == FALSE && listUsrs.size() > 0 && listUsrs.get(lp.Zip_Code_Territory_User__c) != NULL){
                system.debug('Standard Approver Assignment using Territories');
                    lp.Zip_Code_Auto_Route__c = TRUE;
                    lp.Approver__c = listUsrs.get(lp.Zip_Code_Territory_User__c);
            }
        }



    //public static void approval(List<Lab_Participant__c> newTrigger){
        System.debug('Starting: Approval Call');
        List<Approval.ProcessSubmitRequest> requestList = new List<Approval.ProcessSubmitRequest> ();
        for(Lab_Participant__c lpa : newTrigger){
            if(lpa.Status__c == 'New' && lpa.Approver__c != NULL){
                //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ProcessSubmitRequest.htm#apex_ProcessSubmitRequest
                Approval.ProcessSubmitRequest addRequest = new Approval.ProcessSubmitRequest();
                addRequest.setObjectId(lpa.id);
                addRequest.setComments('Submitted for approval. Please Approve.');
                addRequest.setSubmitterId(lpa.Approver__c);
                addRequest.setProcessDefinitionNameOrId('Lab_Approval');
                addRequest.setSkipEntryCriteria(true);
                system.debug('req:'+addRequest);

                requestList.add(addRequest);
                //Approval.ProcessResult result = Approval.process(addRequest);
                //List<Approval.ProcessResult> result = Approval.process(addRequest);
            }
        }
        Approval.ProcessResult[] processResults = null;
        try {
            if(requestList.size() > 0){
                processResults = Approval.process(requestList, true);
            }
        }
        catch (System.DmlException e) {
            System.debug('Exception Is ' + e.getMessage());
        }
    }*/




}