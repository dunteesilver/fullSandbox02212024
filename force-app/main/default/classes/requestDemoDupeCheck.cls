global with sharing class requestDemoDupeCheck {
		public requestDemoDupeCheck() {
		}

		Public Boolean dupeCheck(Map<Id,String> repMap){
				Map<Id,String> repUnit = new Map<Id,String>();
				List<String> listOfDupes = new List<String>();
				List<Request_Demo_Unit__c> listReps = [SELECT User__c, Choose_Unit__c
																							FROM Request_Demo_Unit__c];

				for(Request_Demo_Unit__c curr : listReps){
						repUnit.put(curr.User__c,curr.Choose_Unit__c);
				}//end of for(Request_Demo_Unit__c curr : listReps)

				for(String curr : repMap.keySet() ){
						//logic to check for keys in both maths
						System.debug('*** repUnit.containsKey(curr) *** ' + repUnit.containsKey(curr) );
						System.debug('*** repUnit.get(curr) *** ' + repUnit.get(curr) );
						System.debug('*** repMap.get(curr) *** ' + repMap.get(curr) );
						//System.debug('*** listOfDupes *** ' + listOfDupes);
						if(repUnit.containsKey(curr) && (repUnit.get(curr) == repMap.get(curr) ) &&
						 	repMap.get(curr) != NULL ){
								listOfDupes.add(curr);
						}
				}//end of for(String curr : repMap.keySet() )
				System.debug('*** listOfDupes *** ' + listOfDupes);

				//set boolean based on dupeList
				if(listOfDupes.size() > 0){
						return true;
				}
				else{
						return false;
				}

		}//end of boolean dupeCheck

		/*
		Public Boolean dupeCheck1(Map<Id,String> repMap){
				Map<Id,String> repUnit = new Map<Id,String>();
				List<String> listOfDupes = new List<String>();
				List<Request_Demo_Unit__c> listReps = [SELECT User__c, Choose_Unit__c, Trainings__c
																							FROM Request_Demo_Unit__c];

				for(Request_Demo_Unit__c curr : listReps){
						repUnit.put(curr.User__c,curr.Trainings__c);
				}//end of for(Request_Demo_Unit__c curr : listReps)

				System.debug('*** repUnit *** ' + repUnit);

				for(String curr : repMap.keySet() ){
						//logic to check for keys in both maths
						System.debug('*** repUnit.containsKey(curr) *** ' + repUnit.containsKey(curr) );
						System.debug('*** repUnit.get(curr) *** ' + repUnit.get(curr) );
						System.debug('*** repMap.get(curr) *** ' + repMap.get(curr) );
						//System.debug('*** listOfDupes *** ' + listOfDupes);
						if(repUnit.containsKey(curr) && (repUnit.get(curr) == repMap.get(curr) ) &&
						 	repMap.get(curr) != NULL ){
								listOfDupes.add(curr);
						}
				}//end of for(String curr : repMap.keySet() )
				System.debug('*** listOfDupes *** ' + listOfDupes);

				//set boolean based on dupeList
				if(listOfDupes.size() > 0){
						return true;
				}
				else{
						return false;
				}
		}//end of boolean dupeCheck1
		*/
}