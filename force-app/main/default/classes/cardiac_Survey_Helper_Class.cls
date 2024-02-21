public class cardiac_Survey_Helper_Class {
    
    public static void fixMultiSelects(list<Survey_Cardiac_Service__c> newTrigger){
        string msList;
        string splitValue;
        string splitKey;
        
        for(Survey_Cardiac_Service__c scs : newTrigger){
            
            if(scs.X2_Multi_Catch__c != NULL){
                // Question #2 
                msList = scs.X2_Multi_Catch__c;
                msList = msList.replace('The service representative was easy to contact = ', '1=');
                msList = msList.replace('The service representative was knowledgeable about our products and services = ', '2=');
                msList = msList.replace('The service representative was able to solve my problem, or was able to get me to the right resource to solve my problem = ', '3=');
                msList = msList.replace('The service representative was able to resolve my issue in a timely manner = ', '4=');
                msList = msList.replace('Overall, I was very satisfied with the last interaction with the service representative = ', '5=');
                List<String> sortedvalue = msList.split('\n');
                
                for(string s : sortedvalue){
                    system.debug('s: ' + s);
                    splitKey = s;
                    splitKey = splitKey.left(1);
                    splitValue = s;
                    if(splitKey == '1'){
                        splitValue = splitValue.remove('1=');
                        scs.X2a_Easy_to_contact__c = splitValue;
                    }
                    else if(splitKey == '2'){
                        splitValue = splitValue.remove('2=');
                        scs.X2b_knowledgeable__c = splitValue;
                    }
                    else if(splitKey == '3'){
                        splitValue = splitValue.remove('3=');
                        scs.X2c_Solved_problem_referred_to_resource__c = splitValue;
                    }
                    else if(splitKey == '4'){
                        splitValue = splitValue.remove('4=');
                        scs.X2d_Resolved_in_timely_manner__c = splitValue;
                    }
                    else if(splitKey == '5'){
                        splitValue = splitValue.remove('5=');
                        scs.X2e_Overall_Satisfaction__c = splitValue;
                    }
                }
            }
            // END Question #2
            
        }
        
    }

}