trigger Opportunity_GoDeep_Trigger on Opportunity (before insert, before update, after insert, after update, after delete) {
    System.debug('------- Opportunity_GoDeep_Trigger -------');
    if(Trigger.isInsert && Trigger.isBefore){
        //loop thru records to compare values
        for(Opportunity curr : Trigger.New){
            //check for Emergency Medicine Opportunity
            System.debug('*** curr.Record_Type_Name__c *** ' + curr.Record_Type_Name__c);
            if(curr.Record_Type_Name__c == 'Emergency Medicine Opportunity' && curr.StageName != 'Target.'){
              curr.addError('When creating a Emergency Medicine Opportunity, please start in the Target stage and complete a Go Deep Record to move through stages...');
            }//end of RecordType Name
        }//end for loop
    }//end of if trigger.insert/before
    
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('------- UPDATE and BEFORE trigger -------');
        List<Go_Deep_Record__c> gdList = [SELECT Identify_Accounts_needs__c, Determine_the_type_of_training_is_needed__c,
                                          Number_Of_Trainings__c, Items_To_Follow_That_Came_Up_In_Training__c
                                          FROM Go_Deep_Record__c
                                          WHERE Opportunity__c IN :Trigger.New
                                          ORDER BY Createddate DESC LIMIT 1];
        
        /*****
         * Target Section field(s) - Identify Accounts needs
         * Needs Analysis field(s) - Determine the type of training needed
         * Value Proposition field(s) - Number Of Trainings
         * Growth/Expansion/Progress field(s) - Items To Follow That Came Upon Training
         * Continuing Support/Account Follow up field(s)
        *****/
        
        //loop thru records to compare values
        for(Opportunity curr : Trigger.New){
            //check for Emergency Medicine Opportunity
            String oldValue = Trigger.oldMap.get(curr.Id).StageName;
            String newValue = curr.StageName;
            System.debug('*** curr.Record_Type_Name__c *** ' + curr.Record_Type_Name__c);
            if(curr.Record_Type_Name__c == 'Emergency Medicine Opportunity'){
                //logic to check for fields not filled in
                
                //Check if Go Deep Record Exists before moving to any stage
                if( (oldValue != newValue) && gdList.size() == 0 ) {
                    curr.addError('Please create the related Go Deep Record before changing stages...');
                }
                
                //Validation for Target Section
                if( (Trigger.oldMap.get(curr.Id).StageName == 'Target.' && gdList.size() > 0 && gdList[0].Identify_Accounts_needs__c == NULL) 
                   && (curr.StageName == 'Needs Analysis' || curr.StageName == 'Value Proposition' || curr.StageName == 'Growth/Expansion/Progress' || curr.StageName == 'Continuing Support/Account Follow up') ){
                    curr.addError('Please update the field ending with an asterisk in the "Target" section of the Go Deep Record before moving to the next stage...');
                }//end of if
                               
                //Validation for Needs Analysis Section for Hospital 
                if( (Trigger.oldMap.get(curr.Id).StageName == 'Needs Analysis' && gdList.size() > 0 && gdList[0].Determine_the_type_of_training_is_needed__c  == NULL) &&
                  (curr.StageName == 'Value Proposition' || curr.StageName == 'Growth/Expansion/Progress' || curr.StageName == 'Continuing Support/Account Follow up') ){
                  System.debug('Needs Analysis to Value Proposition');
                  curr.addError('Please update the field ending with an asterisk in the "Needs Analysis" section of the Go Deep Record before moving to the next stage...');
                }//end of Target stage check
                
                //Validation for Value Proposition to Growth/Expansion/Progress
                if( (Trigger.oldMap.get(curr.Id).StageName == 'Value Proposition' && gdList.size() > 0 && gdList[0].Number_Of_Trainings__c  == NULL) &&
                  (curr.StageName == 'Growth/Expansion/Progress' || curr.StageName == 'Continuing Support/Account Follow up') ){
                  System.debug('Value Proposition to Growth/Expansion/Progress');
                  curr.addError('Please update the field ending with an asterisk in the "Value Propostion" section of the Go Deep Record before moving to the next stage...');
                }//end of Target stage check
                
                //Validation for Growth/Expansion/Progress for Hospital
                if( (Trigger.oldMap.get(curr.Id).StageName == 'Growth/Expansion/Progress' && gdList.size() > 0 && gdList[0].Items_To_Follow_That_Came_Up_In_Training__c  == NULL) &&
                  (curr.StageName == 'Continuing Support/Account Follow up') ){
                  System.debug('Growth/Expansion/Progress to Continuing Support/Account Follow up');
                  curr.addError('Please update the field ending with an asterisk in the "Growth/Expansion/Progress" section of the Go Deep Record before moving to the next stage...');
                }//end of Target stage check
                
            }//end of RecordType Name
        }//end for loop 
    }//end if Trigger isUpdate/before 
        
}//end of Trigger