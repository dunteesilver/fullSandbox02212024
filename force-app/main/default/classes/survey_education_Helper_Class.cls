public class survey_education_Helper_Class {
    public static void fixMultiSelects(list<Survey_Education__c> newTrigger){

        string multiString;
        for(Survey_Education__c se : newTrigger){
            // Test Class Coverage: survey_education_Helper_Class_Test
            //Multi_Catch__c
            if(se.Multi_Catch__c != NULL){ // Please Rate your education program experience 
                multiString = se.Multi_Catch__c;
                multiString = multiString.replace('=', ',');
                multiString = multiString.replace('Very Satisfied', '5,');
                multiString = multiString.replace('Very Unsatisfied', '1,');
                multiString = multiString.replace('Unsatisfied', '2,');
                multiString = multiString.replace('Satisfied', '4,');
                multiString = multiString.replace('Neutral', '3,');
                List<String> newDesc = multiString.split(',', -2);
                system.debug('newDesc: ' + newDesc);
                
                map<String, String> qaMap = new map<String, String>();
                string qstring;
                string numstring;
                boolean flip = true;

                for(string s : newDesc){
                    numstring = NULL;
                    if(flip){
                        qstring = s.trim();
                        qstring = qstring.left(4);
                        flip = false;
                    }
                    else{
                        numstring = s;
                        numstring = numstring.trim();
                        if(numstring != NULL && numstring != ''){
                            qaMap.put(qstring,numstring);                                
                        }
                        flip = true;
                    }
                }
                system.debug('qaMap: ' + qaMap);
                
                if(qaMap.size() > 0){
                    if(qaMap.get('Ease') != NULL){
                        se.Ease_of_coordinating_your_education_prog__c = integer.valueof(qaMap.get('Ease'));
                    }
                    if(qaMap.get('Punc') != NULL){
                        se.Punctuality_and_preparedness_of_speaker__c = integer.valueof(qaMap.get('Punc'));
                    }
                    if(qaMap.get('Prof') != NULL){
                        se.Professionalism_and_expertise_of_speaker__c = integer.valueof(qaMap.get('Prof'));
                    }
                    if(qaMap.get('Teac') != NULL){
                        se.Teaching_methods_met_the_learning_needs__c = integer.valueof(qaMap.get('Teac'));
                    }
                    if(qaMap.get('Cour') != NULL){
                        se.Course_material_structure_facilitated_le__c = integer.valueof(qaMap.get('Cour'));
                    }
                }
            }
            //Multi_Catch_2__c 
            if(se.Multi_Catch_2__c != NULL){
                multiString = se.Multi_Catch_2__c;
                multiString = multiString.replace('=', ',');
                multiString = multiString.replace('Strongly Agree', '5');
                multiString = multiString.replace('Strongly Disagree', '1');
                multiString = multiString.replace('Disagree', '2');
                multiString = multiString.replace('Agree', '4');
                multiString = multiString.replace('Unknown', '3');
                List<String> newDesc = multiString.split(',', -2);
                
                boolean flip = true;
                integer mc2;

                for(string s : newDesc){
                    if(flip){
                        flip = false;
                    }
                    else{
                        mc2 = integer.valueof(s.trim());
                        se.Program_Increased_Attendees_Knowledge__c = mc2;
                    }
                }
            } // END Multi_Catch_2__c
            // Start Multi_Catch_3__c
            if(se.Multi_Catch_3__c != NULL){
                multiString = se.Multi_Catch_3__c;
                multiString = multiString.replace('=', ',');
                List<String> newDesc = multiString.split(',', -2);
                
                boolean flip = true;
                //integer mc2;
                
                for(string s : newDesc){
                    if(flip){
                        flip = false;
                    }
                    else{
                        //mc2 = integer.valueof(s.trim());
                        se.Education_program_will_Improve_your_Prac__c = s.trim();
                    }
                }
            } // END Multi_Catch_3__c
            // Start Multi_Catch_4__c
            if(se.Multi_Catch_4__c != NULL){
                multiString = se.Multi_Catch_4__c;
                multiString = multiString.replace('\r\n', ' ');
                
                system.debug('multiString: ' + multiString);
                if(multiString.contains('Clinical & Medical Affairs')){
                    se.Clinical_Medical_Affairs__c = TRUE;
                }
                if(multiString.contains('Continuing Education')){
                    se.Continuing_Education__c = TRUE;
                }
                if(multiString.contains('Sales')){
                    se.Sales__c = TRUE;
                }
                /*if(multiString.contains('Other')){
                    se.Other_More_Info__c = 'Other';
                } */                
            } // Start Multi_Catch_4__c

             


                
            
        } // End FOR/LOOP
        
    }

}